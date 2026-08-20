#!/usr/bin/env bash
set -Eeuo pipefail
set +x
umask 077
#НАПИСА С ПОМОЩЬЮ НЕЙРОСЕТИ !!!!!!!!!!!!!!!!!!!!!!!!!!!
readonly IMAGE_REPO='ghcr.io/nebyanov/devops'
readonly PROJECT_NAME='site'
readonly ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
readonly BASE="$ROOT/docker-compose.yaml"
readonly PROD="$ROOT/docker-compose-production.yaml"
readonly WAIT_SECONDS="${DEPLOY_WAIT_SECONDS:-120}"

die() {
  printf 'ERROR: %s\n' "$*" >&2
  exit 1
}

log() {
  printf '[deploy] %s\n' "$*" >&2
}

# Принимается:
#   sha256:<64 hex>
#   <64 hex>
[[ $# -eq 1 ]] ||
  die "Использование: $0 <sha256:64-hex или 64-hex>"

raw_digest="${1,,}"

case "$raw_digest" in
  sha256:*)
    TARGET_DIGEST="$raw_digest"
    ;;
  *)
    TARGET_DIGEST="sha256:$raw_digest"
    ;;
esac

readonly TARGET_DIGEST

[[ "$TARGET_DIGEST" =~ ^sha256:[0-9a-f]{64}$ ]] ||
  die 'Ожидается sha256:<64 hex> либо просто 64 hex'

readonly TARGET_IMAGE="${IMAGE_REPO}@${TARGET_DIGEST}"

[[ "$WAIT_SECONDS" =~ ^[1-9][0-9]*$ ]] ||
  die 'DEPLOY_WAIT_SECONDS должен быть положительным числом'

[[ -r "$BASE" ]] || die "Не найден $BASE"
[[ -r "$PROD" ]] || die "Не найден $PROD"

for command_name in docker jq flock; do
  command -v "$command_name" >/dev/null ||
    die "Не найдена команда: $command_name"
done

docker compose version >/dev/null

# Запускает Compose с указанным digest.
dc() {
  local digest="$1"
  shift

  WEB_IMAGE_DIGEST="$digest" \
    docker compose \
      --project-name "$PROJECT_NAME" \
      --project-directory "$ROOT" \
      -f "$BASE" \
      -f "$PROD" \
      "$@"
}

# Не допускаем одновременный запуск двух deploy.
exec 9>"${XDG_RUNTIME_DIR:-/tmp}/site-web-deploy-${UID}.lock"
flock -n 9 || die 'Другой deploy web уже выполняется'

# Проверяем итоговую объединённую Compose-конфигурацию:
# - используется нужный digest;
# - локальная build-конфигурация удалена;
# - включён healthcheck.
if ! dc "$TARGET_DIGEST" config --format json |
  jq -e --arg image "$TARGET_IMAGE" '
    .services.web.image == $image
    and (.services.web.build == null)
    and (.services.web.pull_policy == "always")
    and ((.services.web.healthcheck.test // []) | length > 0)
    and ((.services.web.healthcheck.disable // false) == false)
  ' >/dev/null
then
  die 'Production Compose не прошёл проверку'
fi

# Возвращает ID единственного контейнера web.
one_web_container() {
  local digest="$1"
  local ids

  ids="$(dc "$digest" ps --all --quiet web)" || return 1

  [[ -n "$ids" && "$ids" != *$'\n'* ]] || return 1

  printf '%s\n' "$ids"
}

# Проверяет:
# - контейнер использует ожидаемый image ID;
# - контейнер запущен;
# - контейнер healthy.
healthy_with_image() {
  local container_id="$1"
  local expected_image_id="$2"
  local actual_image_id
  local state
  local health

  actual_image_id="$(
    docker inspect --format '{{.Image}}' "$container_id"
  )" || return 1

  state="$(
    docker inspect --format '{{.State.Status}}' "$container_id"
  )" || return 1

  health="$(
    docker inspect \
      --format '{{if .State.Health}}{{.State.Health.Status}}{{else}}missing{{end}}' \
      "$container_id"
  )" || return 1

  [[ "$actual_image_id" == "$expected_image_id" ]] &&
    [[ "$state" == 'running' ]] &&
    [[ "$health" == 'healthy' ]]
}

# Находит GHCR digest указанного локального image ID.
# Это также позволяет перейти со старого Git SHA-тега на digest.
find_image_digest() {
  local image_id="$1"
  local refs
  local ref
  local candidate
  local prefix="${IMAGE_REPO}@"

  refs="$(
    docker image inspect \
      --format '{{range .RepoDigests}}{{println .}}{{end}}' \
      "$image_id"
  )" || return 1

  while IFS= read -r ref; do
    [[ "$ref" == "$prefix"* ]] || continue

    candidate="${ref#"$prefix"}"

    if [[ "$candidate" =~ ^sha256:[0-9a-f]{64}$ ]]; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done <<< "$refs"

  return 1
}

# Запоминаем текущий рабочий контейнер для возможного rollback.
previous_container="$(one_web_container "$TARGET_DIGEST")" ||
  die 'Ожидался ровно один существующий контейнер web'

previous_image_id="$(
  docker inspect --format '{{.Image}}' "$previous_container"
)" || die 'Не удалось определить текущий image ID'

previous_health="$(
  docker inspect \
    --format '{{if .State.Health}}{{.State.Health.Status}}{{else}}missing{{end}}' \
    "$previous_container"
)" || die 'Не удалось определить health текущего web'

[[ "$previous_health" == 'healthy' ]] ||
  die 'Текущий web не healthy, использовать его для rollback нельзя'

previous_digest="$(find_image_digest "$previous_image_id")" ||
  die 'У текущего web нет GHCR digest — безопасный rollback невозможен'

readonly PREVIOUS_DIGEST="$previous_digest"
readonly PREVIOUS_IMAGE="${IMAGE_REPO}@${PREVIOUS_DIGEST}"

previous_resolved_id="$(
  docker image inspect --format '{{.Id}}' "$PREVIOUS_IMAGE"
)" || die 'Предыдущий образ отсутствует локально'

[[ "$previous_resolved_id" == "$previous_image_id" ]] ||
  die 'Digest предыдущего образа указывает на другой image ID'

# Сначала скачиваем новый образ.
# Работающий контейнер на этом этапе не изменяется.
log "Pull $TARGET_IMAGE"

dc "$TARGET_DIGEST" pull --policy always web ||
  die "Не удалось скачать $TARGET_IMAGE"

target_image_id="$(
  docker image inspect --format '{{.Id}}' "$TARGET_IMAGE"
)" || die 'Скачанный образ отсутствует локально'

# Автоматический rollback на предыдущий digest.
rollback() {
  local rollback_container
  local resolved_previous_id

  log "Rollback на $PREVIOUS_IMAGE"

  # Убеждаемся, что старый образ всё ещё есть локально.
  resolved_previous_id="$(
    docker image inspect --format '{{.Id}}' "$PREVIOUS_IMAGE"
  )" || return 1

  [[ "$resolved_previous_id" == "$previous_image_id" ]] ||
    return 1

  # --pull never не позволяет случайно скачать другой образ.
  dc "$PREVIOUS_DIGEST" up \
    --detach \
    --no-deps \
    --no-build \
    --pull never \
    --force-recreate \
    --wait \
    --wait-timeout "$WAIT_SECONDS" \
    web || return 1

  rollback_container="$(one_web_container "$PREVIOUS_DIGEST")" ||
    return 1

  healthy_with_image "$rollback_container" "$previous_image_id"
}

log "Deploy $TARGET_IMAGE"

if dc "$TARGET_DIGEST" up \
  --detach \
  --no-deps \
  --no-build \
  --pull never \
  --force-recreate \
  --wait \
  --wait-timeout "$WAIT_SECONDS" \
  web
then
  if new_container="$(one_web_container "$TARGET_DIGEST")" &&
    healthy_with_image "$new_container" "$target_image_id"
  then
    log "Успешно: $TARGET_IMAGE запущен и healthy"
    exit 0
  fi
fi

log 'Deploy завершился ошибкой'

if rollback; then
  log "Rollback успешен: $PREVIOUS_IMAGE снова healthy"

  # Новый deploy был неуспешным, поэтому возвращается ошибка,
  # несмотря на успешный rollback.
  exit 1
fi

log 'ОШИБКА: deploy и rollback неуспешны'
exit 2

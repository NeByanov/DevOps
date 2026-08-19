#!/usr/bin/env bash
set -Eeuo pipefail
set +x
umask 077
#Срипт написан с помощью нейросети!!!!!!!!!!!!!!!!!!!!!!!!
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

[[ $# -eq 1 ]] ||
  die "Использование: $0 <полный-40-символьный-Git-SHA>"

readonly TARGET_TAG="$1"
readonly TARGET_IMAGE="${IMAGE_REPO}:${TARGET_TAG}"

[[ "$TARGET_TAG" =~ ^[0-9a-f]{40}$ ]] ||
  die 'Версия должна быть полным Git SHA: ровно 40 символов 0-9 и a-f'

[[ "$WAIT_SECONDS" =~ ^[1-9][0-9]*$ ]] ||
  die 'DEPLOY_WAIT_SECONDS должен быть положительным числом'

[[ -r "$BASE" ]] || die "Не найден $BASE"
[[ -r "$PROD" ]] || die "Не найден $PROD"

for command_name in sudo docker jq flock; do
  command -v "$command_name" >/dev/null ||
    die "Не найдена команда: $command_name"
done

sudo -v
sudo docker compose version >/dev/null

dc() {
  local tag="$1"
  shift

  sudo env WEB_IMAGE_TAG="$tag" \
    docker compose \
      --project-name "$PROJECT_NAME" \
      --project-directory "$ROOT" \
      -f "$BASE" \
      -f "$PROD" \
      "$@"
}

# Запрещаем одновременный запуск двух deploy.
exec 9>"${XDG_RUNTIME_DIR:-/tmp}/site-web-deploy-${UID}.lock"
flock -n 9 || die 'Другой deploy web уже выполняется'

# Проверяем, что итоговый Compose использует точный image,
# не содержит build и сохраняет healthcheck.
if ! dc "$TARGET_TAG" config --format json |
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

one_web_container() {
  local tag="$1"
  local ids

  ids="$(dc "$tag" ps --all --quiet web)" || return 1

  [[ -n "$ids" && "$ids" != *$'\n'* ]] || return 1
  printf '%s\n' "$ids"
}

healthy_with_image() {
  local container_id="$1"
  local expected_image_id="$2"
  local actual_image_id
  local state
  local health

  actual_image_id="$(
    sudo docker inspect --format '{{.Image}}' "$container_id"
  )" || return 1

  state="$(
    sudo docker inspect --format '{{.State.Status}}' "$container_id"
  )" || return 1

  health="$(
    sudo docker inspect \
      --format '{{if .State.Health}}{{.State.Health.Status}}{{else}}missing{{end}}' \
      "$container_id"
  )" || return 1

  [[ "$actual_image_id" == "$expected_image_id" ]]
  [[ "$state" == 'running' ]]
  [[ "$health" == 'healthy' ]]
}

# Запоминаем текущий заведомо рабочий image для rollback.
previous_container="$(one_web_container "$TARGET_TAG")" ||
  die 'Ожидался ровно один существующий контейнер web'

previous_ref="$(
  sudo docker inspect --format '{{.Config.Image}}' "$previous_container"
)" || die 'Не удалось определить текущий image web'

previous_image_id="$(
  sudo docker inspect --format '{{.Image}}' "$previous_container"
)" || die 'Не удалось определить текущий image ID'

[[ "$previous_ref" == "$IMAGE_REPO:"* ]] ||
  die 'Текущий web запущен не из ожидаемого GHCR repository'

previous_tag="${previous_ref#"$IMAGE_REPO:"}"

[[ "$previous_tag" =~ ^[0-9a-f]{40}$ ]] ||
  die 'Текущий web не имеет полного SHA-тега, rollback небезопасен'

previous_health="$(
  sudo docker inspect \
    --format '{{if .State.Health}}{{.State.Health.Status}}{{else}}missing{{end}}' \
    "$previous_container"
)"

[[ "$previous_health" == 'healthy' ]] ||
  die 'Текущий web не healthy, использовать его для rollback нельзя'

sudo docker image inspect "$previous_image_id" >/dev/null ||
  die 'Предыдущий image отсутствует локально'

# Сначала скачиваем image. Работающий контейнер пока не изменяется.
log "Pull $TARGET_IMAGE"

dc "$TARGET_TAG" pull --policy always web ||
  die "Не удалось скачать $TARGET_IMAGE"

target_image_id="$(
  sudo docker image inspect --format '{{.Id}}' "$TARGET_IMAGE"
)" || die 'Скачанный image не найден локально'

rollback() {
  local restored_id
  local rollback_container

  log "Rollback на $previous_ref"

  # Возвращаем старый тег именно на старый image ID.
  sudo docker image tag "$previous_image_id" "$previous_ref" ||
    return 1

  restored_id="$(
    sudo docker image inspect --format '{{.Id}}' "$previous_ref"
  )" || return 1

  [[ "$restored_id" == "$previous_image_id" ]] || return 1

  dc "$previous_tag" up \
    --detach \
    --no-deps \
    --no-build \
    --pull never \
    --force-recreate \
    --wait \
    --wait-timeout "$WAIT_SECONDS" \
    web || return 1

  rollback_container="$(one_web_container "$previous_tag")" ||
    return 1

  healthy_with_image "$rollback_container" "$previous_image_id"
}

log "Deploy $TARGET_IMAGE"

if dc "$TARGET_TAG" up \
  --detach \
  --no-deps \
  --no-build \
  --pull never \
  --force-recreate \
  --wait \
  --wait-timeout "$WAIT_SECONDS" \
  web
then
  if new_container="$(one_web_container "$TARGET_TAG")" &&
     healthy_with_image "$new_container" "$target_image_id"
  then
    log "Успешно: $TARGET_IMAGE запущен и healthy"
    exit 0
  fi
fi

log 'Deploy завершился ошибкой'

if rollback; then
  log "Rollback успешен: $previous_ref снова healthy"

  # Deploy всё равно был неуспешным, поэтому возвращаем ошибку.
  exit 1
fi

log 'ОШИБКА: deploy и rollback неуспешны'
exit 2

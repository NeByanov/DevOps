#!/usr/bin/env bash
set -euo pipefail

source ~/dockerproject/Site/.env

# Variables
BACKUP_DIR=~/dockerproject/Site/auto_backups
DB_NAME="${POSTGRES_DB}"
DB_USER="${POSTGRES_USER}"
DB_PASSWORD="${POSTGRES_PASSWORD}"
CONTAINER_NAME="site-postgres-1"
MAX_BACKUPS=7

mkdir -p "$BACKUP_DIR"

# Временный файл объявляем на уровне скрипта
TMP_FILE="$BACKUP_DIR/backup_${DB_NAME}_$(date +"%F_%T").sql.tmp"
BACKUP_FILE="$BACKUP_DIR/backup_${DB_NAME}_$(date +"%F_%T").sql"

# Функция очистки: удаляет временный файл, если он существует
cleanup() {
  if [[ -f "$TMP_FILE" ]]; then
    rm -f "$TMP_FILE"
    echo "Временный файл удалён: $TMP_FILE (ошибка или прерывание)."
  fi
}

# trap вызывает cleanup при любом завершении скрипта: ошибка, exit, kill и т.п.
trap cleanup EXIT

# Проверка, что контейнер запущен
if ! docker inspect -f '{{.State.Running}}' "$CONTAINER_NAME" 2>/dev/null | grep -q "^true$"; then
  echo "Контейнер не запущен. Запустите его и попробуйте снова."
  exit 1
fi

# Выполняем дамп во временный файл
# Если pg_dump падает — сработает trap, который удалит $TMP_FILE
PGPASSWORD="$DB_PASSWORD" docker exec -i "$CONTAINER_NAME" pg_dump -U "$DB_USER" "$DB_NAME" > "$TMP_FILE"

# Если мы здесь — pg_dump отработал без ошибок
# Проверяем, что файл не пустой (на всякий случай)
if [[ ! -s "$TMP_FILE" ]]; then
  echo "Ошибка: дамп получился пустым. Временный файл будет удалён."
  # trap уже запланирован на удаление, но можно вызвать явно
  cleanup
  exit 1
fi

# Переименовываем временный в итоговый (атомарно)
mv "$TMP_FILE" "$BACKUP_FILE"
# После mv временный файл уже не существует, trap ничего не сделает

echo "Backup completed: $BACKUP_FILE"

# Ротация: оставляем последние MAX_BACKUPS файлов
{
  find "$BACKUP_DIR" -maxdepth 1 -type f -name '*.sql' -printf '%T@ %p\n' \
    | sort -rn \
    | awk -v max="$MAX_BACKUPS" 'NR > max { print $2 }'
} | while IFS= read -r file; do
  [ -n "$file" ] && rm -f "$file"
done

echo "Ротация проведена: оставлены последние $MAX_BACKUPS бекапов."
ls -1t "$BACKUP_DIR"/*.sql 2>/dev/null || true

#!/usr/bin/env bash
set -euo pipefail

# Prefer env vars (from Ansible Vault), fall back to .env for standalone use
if [[ -z "${POSTGRES_DB:-}" || -z "${POSTGRES_USER:-}" || -z "${POSTGRES_PASSWORD:-}" ]]; then
  . ~/dockerproject/Site/ansible/.env
fi

# Variables
BACKUP_DIR="$HOME/backups/postgres-1c"
DB_NAME="${POSTGRES_DB}"
DB_USER="${POSTGRES_USER}"
DB_PASSWORD="${POSTGRES_PASSWORD}"
CONTAINER_NAME="postgres-1c"
MAX_BACKUPS=5

mkdir -p "$BACKUP_DIR"
chmod 0700 "$BACKUP_DIR"

TMP_FILE="$BACKUP_DIR/backup_${DB_NAME}_$(date +"%F_%T").dump.tmp"
BACKUP_FILE="$BACKUP_DIR/backup_${DB_NAME}_$(date +"%F_%T").dump"

cleanup() {
  if [[ -f "$TMP_FILE" ]]; then
    rm -f "$TMP_FILE"
    echo "Временный файл удалён: $TMP_FILE"
  fi
}
trap cleanup EXIT

# 1. Контейнер запущен?
if ! docker inspect -f '{{.State.Running}}' "$CONTAINER_NAME" 2>/dev/null | grep -q "^true$"; then
  echo "Контейнер не запущен."
  exit 1
fi

# 2. PostgreSQL готов? (с ожиданием до 30 секунд)
READY=0
for i in $(seq 1 15); do
  if docker exec "$CONTAINER_NAME" pg_isready -U "$DB_USER" -d "$DB_NAME" 2>/dev/null; then
    READY=1
    break
  fi
  echo "Ожидание PostgreSQL... попытка $i/15"
  sleep 2
done

if [[ "$READY" -ne 1 ]]; then
  echo "PostgreSQL не готов принимать подключения за 30 секунд."
  exit 1
fi

# 3. Дамп в custom-формате (-Fc) — поддерживает pg_restore --list
PGPASSWORD="$DB_PASSWORD" docker exec -e PGPASSWORD="$DB_PASSWORD" \
  "$CONTAINER_NAME" pg_dump -Fc -U "$DB_USER" "$DB_NAME" > "$TMP_FILE"

# 4. Проверка, что файл не пустой
if [[ ! -s "$TMP_FILE" ]]; then
  echo "Дамп пустой."
  exit 1
fi

# 5. Атомарное переименование + ограничение прав
mv "$TMP_FILE" "$BACKUP_FILE"
chmod 0600 "$BACKUP_FILE"

echo "Backup completed: $BACKUP_FILE"

# 6. Ротация (теперь по .dump, не .sql)
{
  find "$BACKUP_DIR" -maxdepth 1 -type f -name '*.dump' -printf '%T@ %p\n' \
    | sort -rn \
    | awk -v max="$MAX_BACKUPS" 'NR > max { print $2 }'
} | while IFS= read -r file; do
  [ -n "$file" ] && rm -f "$file"
done

echo "Ротация: оставлены последние $MAX_BACKUPS бекапов."

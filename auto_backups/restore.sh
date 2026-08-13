#!/usr/bin/env bash
set -euo pipefail

source ~/dockerproject/Site/.env

BACKUP_FILE="$1"
DB_NAME="${POSTGRES_DB}"
DB_USER="${POSTGRES_USER}"
DB_PASSWORD="${POSTGRES_PASSWORD}"
CONTAINER_NAME="site-postgres-1"
ANCHOR_DB="temp_anchor_$$"

if [[ -z "$BACKUP_FILE" || ! -f "$BACKUP_FILE" ]]; then
  echo "Ошибка: файл дампа не найден."
  exit 1
fi

echo "=== ПОЛНЫЙ ОТКАТ БАЗЫ $DB_NAME ==="
read -p "Введите 'yes' чтобы подтвердить (ВСЕ ДАННЫЕ В $DB_NAME БУДУТ УДАЛЕНЫ, приложение будет отключено): " CONFIRM
[[ "$CONFIRM" == "yes" ]] || { echo "Отменено."; exit 0; }

# ШАГ 0: Создаём временную базу-якорь
echo "Создаём временную базу $ANCHOR_DB..."
PGPASSWORD="$DB_PASSWORD" docker exec -i "$CONTAINER_NAME" psql -U "$DB_USER" -d "$DB_NAME" <<EOF
CREATE DATABASE "${ANCHOR_DB}";
EOF

# ШАГ 1: Заходим в временную базу и отключаем ВСЕ сессии к mysite
echo "Отключаем активные сессии к базе $DB_NAME..."
PGPASSWORD="$DB_PASSWORD" docker exec -i "$CONTAINER_NAME" psql -U "$DB_USER" -d "$ANCHOR_DB" <<EOF
SELECT pg_terminate_backend(pid)
FROM pg_stat_activity
WHERE datname = '${DB_NAME}' AND pid <> pg_backend_pid();
EOF

# Теперь можно дропнуть и создать базу
echo "Удаляем и создаём базу $DB_NAME..."
PGPASSWORD="$DB_PASSWORD" docker exec -i "$CONTAINER_NAME" psql -U "$DB_USER" -d "$ANCHOR_DB" <<EOF
DROP DATABASE IF EXISTS "${DB_NAME}";
CREATE DATABASE "${DB_NAME}";
EOF

# ШАГ 2: Восстанавливаем дамп
echo "Восстанавливаем данные из дампа..."
PGPASSWORD="$DB_PASSWORD" cat "$BACKUP_FILE" | \
  docker exec -i "$CONTAINER_NAME" psql -U "$DB_USER" -d "$DB_NAME"

# ШАГ 3: Удаляем временную базу
echo "Удаляем временную базу $ANCHOR_DB..."
PGPASSWORD="$DB_PASSWORD" docker exec -i "$CONTAINER_NAME" psql -U "$DB_USER" -d "$DB_NAME" <<EOF
DROP DATABASE IF EXISTS "${ANCHOR_DB}";
EOF

echo "✅ Готово! База $DB_NAME полностью обновлена."

#!/bin/bash
set -euo pipefail

BACKUP_DIR="/home/vboxuser/backups/postgres-1c"
MAX_AGE_HOURS=26

log() { echo "[$(date -u '+%Y-%m-%dT%H:%M:%SZ')] $*"; }
die() { log "FAIL: $*" >&2; exit 1; }

# ── 1. Каталог существует и права 0700 ──────────────────────────
[ -d "$BACKUP_DIR" ] || die "backup directory not found"

dir_mode=$(stat -c '%a' "$BACKUP_DIR")
[ "$dir_mode" = "700" ] || die "directory mode is $dir_mode, expected 700"

# ── 2. Нет .tmp-файлов (незавершённый бэкап) ────────────────────
tmp_count=$(find "$BACKUP_DIR" -maxdepth 1 -name '*.tmp' -type f 2>/dev/null | wc -l)
[ "$tmp_count" -eq 0 ] || die "$tmp_count .tmp file(s) detected — backup may be incomplete"

# ── 3. Самый свежий .dump ───────────────────────────────────────
dump_file=$(find "$BACKUP_DIR" -maxdepth 1 -name '*.dump' -type f -printf '%T@ %p\n' 2>/dev/null \
    | sort -rn | head -1 | cut -d' ' -f2-)

[ -n "$dump_file" ] || die "no .dump file found"
[ -s "$dump_file" ] || die "newest .dump is empty"

# ── 4. Права файла 0600 ────────────────────────────────────────
file_mode=$(stat -c '%a' "$dump_file")
[ "$file_mode" = "600" ] || die "file mode is $file_mode, expected 600"

# ── 5. Возраст не более 26 часов ────────────────────────────────
file_mtime=$(stat -c '%Y' "$dump_file")
now=$(date '+%s')
age_hours=$(( (now - file_mtime) / 3600 ))
[ "$age_hours" -le "$MAX_AGE_HOURS" ] \
    || die "newest .dump is $age_hours hours old (max $MAX_AGE_HOURS)"

# ── 6. Целостность через pg_restore --list ──────────────────────
#     Перехватываем stdout/stderr — pg_restore может вывести
#     имена объектов, но не секреты. Ошибку выводим обобщённо.
if ! pg_restore --list "$dump_file" >/dev/null 2>&1; then
    die "pg_restore --list failed — dump may be corrupted"
fi

# ── ОК ──────────────────────────────────────────────────────────
log "OK: $(basename "$dump_file"), ${age_hours}h old, $(stat -c '%s' "$dump_file") bytes"
exit 0

#!/usr/bin/env bash
#
# track-file-change.sh
# Registra alterações de arquivos em um banco SQLite para rastreamento.
#
# Uso: track-file-change.sh <file_path> [project_dir]
#
# - Recebe o caminho de um arquivo e, opcionalmente, o diretório do projeto.
# - Normaliza caminhos relativos para absolutos.
# - Ignora arquivos dentro da pasta .ai (evita auto-registro).
# - Cria/atualiza tabelas no banco .ai/file_changes.sqlite.
# - Registra uma entrada na tabela changed_files com contagem de alterações.
# - Insere um evento na tabela file_change_events para histórico completo.
# - Coleta metadados: branch git, status git e hash SHA-256 do arquivo.
#
set -euo pipefail

FILE_PATH="${1:-}"
PROJECT_DIR="${2:-$(pwd)}"

if [ -z "$FILE_PATH" ]; then
  echo "Uso: $0 <file_path> [project_dir]"
  exit 1
fi

# Normaliza caminhos
PROJECT_DIR="$(cd "$PROJECT_DIR" && pwd)"

# Se o arquivo vier relativo, transforma em absoluto baseado no PROJECT_DIR
if [[ "$FILE_PATH" != /* ]]; then
  FILE_PATH="$PROJECT_DIR/$FILE_PATH"
fi

# Ignora arquivos dentro da pasta .ai
if [[ "$FILE_PATH" == "$PROJECT_DIR/.ai"* ]]; then
  exit 0
fi

DB_PATH="$PROJECT_DIR/.ai/file_changes.sqlite"

mkdir -p "$(dirname "$DB_PATH")"

# Escape simples para SQLite string literal
sql_escape() {
  printf "%s" "$1" | sed "s/'/''/g"
}

# Hash compatível com macOS e Linux
file_hash() {
  local file="$1"

  if [ ! -f "$file" ]; then
    printf ""
    return 0
  fi

  if command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$file" | awk '{print $1}'
  elif command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$file" | awk '{print $1}'
  else
    printf ""
  fi
}

GIT_BRANCH="$(git -C "$PROJECT_DIR" branch --show-current 2>/dev/null || true)"
GIT_STATUS="$(git -C "$PROJECT_DIR" status --short -- "$FILE_PATH" 2>/dev/null || true)"
FILE_HASH="$(file_hash "$FILE_PATH")"

FILE_PATH_SQL="$(sql_escape "$FILE_PATH")"
PROJECT_DIR_SQL="$(sql_escape "$PROJECT_DIR")"
GIT_BRANCH_SQL="$(sql_escape "$GIT_BRANCH")"
GIT_STATUS_SQL="$(sql_escape "$GIT_STATUS")"
FILE_HASH_SQL="$(sql_escape "$FILE_HASH")"

sqlite3 "$DB_PATH" <<SQL
PRAGMA journal_mode = WAL;
PRAGMA busy_timeout = 3000;

CREATE TABLE IF NOT EXISTS changed_files (
  file_path TEXT PRIMARY KEY,
  project_dir TEXT NOT NULL,
  first_seen_at TEXT NOT NULL,
  last_seen_at TEXT NOT NULL,
  change_count INTEGER NOT NULL DEFAULT 1,
  git_branch TEXT,
  git_status TEXT,
  file_hash TEXT
);

CREATE TABLE IF NOT EXISTS file_change_events (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  file_path TEXT NOT NULL,
  project_dir TEXT NOT NULL,
  changed_at TEXT NOT NULL,
  git_branch TEXT,
  git_status TEXT,
  file_hash TEXT
);

INSERT INTO changed_files (
  file_path,
  project_dir,
  first_seen_at,
  last_seen_at,
  change_count,
  git_branch,
  git_status,
  file_hash
)
VALUES (
  '$FILE_PATH_SQL',
  '$PROJECT_DIR_SQL',
  datetime('now'),
  datetime('now'),
  1,
  '$GIT_BRANCH_SQL',
  '$GIT_STATUS_SQL',
  '$FILE_HASH_SQL'
)
ON CONFLICT(file_path) DO UPDATE SET
  project_dir = excluded.project_dir,
  last_seen_at = datetime('now'),
  change_count = changed_files.change_count + 1,
  git_branch = excluded.git_branch,
  git_status = excluded.git_status,
  file_hash = excluded.file_hash;

INSERT INTO file_change_events (
  file_path,
  project_dir,
  changed_at,
  git_branch,
  git_status,
  file_hash
)
VALUES (
  '$FILE_PATH_SQL',
  '$PROJECT_DIR_SQL',
  datetime('now'),
  '$GIT_BRANCH_SQL',
  '$GIT_STATUS_SQL',
  '$FILE_HASH_SQL'
);
SQL
#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

FORCE=false

if [[ "${1:-}" == "--force" ]]; then
  FORCE=true
fi

log() {
  echo "[setup-links] $*"
}

ensure_dir() {
  mkdir -p "$1"
}

link_path() {
  local source="$1"
  local target="$2"

  if [[ ! -e "$source" && ! -L "$source" ]]; then
    log "SKIP source does not exist: $source"
    return 0
  fi

  ensure_dir "$(dirname "$target")"

  if [[ -L "$target" ]]; then
    local current_target
    current_target="$(readlink "$target")"

    if [[ "$current_target" == "$source" ]]; then
      log "OK already linked: $target -> $source"
      return 0
    fi

    if [[ "$FORCE" == "true" ]]; then
      log "REPLACE symlink: $target -> $current_target"
      rm "$target"
    else
      log "SKIP existing symlink points elsewhere: $target -> $current_target"
      log "     use --force to replace"
      return 0
    fi

  elif [[ -e "$target" ]]; then
    if [[ "$FORCE" == "true" ]]; then
      local backup="${target}.backup.$(date +%Y%m%d%H%M%S)"
      log "BACKUP existing path: $target -> $backup"
      mv "$target" "$backup"
    else
      log "SKIP target already exists and is not a symlink: $target"
      log "     use --force to backup and replace"
      return 0
    fi
  fi

  ln -s "$source" "$target"
  log "LINK $target -> $source"
}

link_skill_to_opencode_and_kiro() {
  local skill_dir="$1"
  local skill_name
  skill_name="$(basename "$skill_dir")"

  link_path "$skill_dir" "$HOME/.config/opencode/skills/$skill_name"
  link_path "$skill_dir" "$HOME/.kiro/skills/$skill_name"
}

log "Root: $ROOT_DIR"

ensure_dir "$HOME/.config"
ensure_dir "$HOME/.config/scripts"
ensure_dir "$HOME/.config/opencode"
ensure_dir "$HOME/.config/opencode/skills"
ensure_dir "$HOME/.kiro"
ensure_dir "$HOME/.kiro/skills"
ensure_dir "$HOME/.kiro/hooks"

log "Linking skills..."

if [[ -d "$ROOT_DIR/.config/skills" ]]; then
  for skill_dir in "$ROOT_DIR/.config/skills"/*; do
    [[ -d "$skill_dir" ]] || continue

    skill_name="$(basename "$skill_dir")"

    case "$skill_name" in
      .DS_Store)
        continue
        ;;
    esac

    if [[ -f "$skill_dir/SKILL.md" ]]; then
      link_skill_to_opencode_and_kiro "$skill_dir"
    else
      log "SKIP not a skill directory: $skill_dir"
    fi
  done
else
  log "SKIP skills directory not found: $ROOT_DIR/.config/skills"
fi

log "Linking Kiro hooks..."

if [[ -d "$ROOT_DIR/.kiro/hooks" ]]; then
  for hook_file in "$ROOT_DIR/.kiro/hooks"/*.json; do
    [[ -f "$hook_file" ]] || continue

    hook_name="$(basename "$hook_file")"
    link_path "$hook_file" "$HOME/.kiro/hooks/$hook_name"
  done
else
  log "SKIP Kiro hooks directory not found: $ROOT_DIR/.kiro/hooks"
fi

log "Linking scripts..."

if [[ -d "$ROOT_DIR/.config/scripts" ]]; then
  for script_file in "$ROOT_DIR/.config/scripts"/*; do
    [[ -f "$script_file" ]] || continue

    script_name="$(basename "$script_file")"

    chmod +x "$script_file" || true

    link_path "$script_file" "$HOME/.config/scripts/$script_name"
  done
else
  log "SKIP scripts directory not found: $ROOT_DIR/.config/scripts"
fi

log "Done."
#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
DEST_ROOT="$CODEX_HOME/skills"
DRY_RUN=0

if [[ "${1:-}" == "--dry-run" && $# -eq 1 ]]; then
  DRY_RUN=1
elif [[ $# -ne 0 ]]; then
  printf 'Usage: %s [--dry-run]\n' "$0" >&2
  exit 2
fi

if ! command -v rsync >/dev/null 2>&1; then
  printf 'Error: rsync is required to install skills.\n' >&2
  exit 1
fi

shopt -s nullglob
SKILL_FILES=("$PROJECT_ROOT"/*/SKILL.md)
if ((${#SKILL_FILES[@]} == 0)); then
  printf 'No Skill directories containing SKILL.md were found in %s.\n' "$PROJECT_ROOT" >&2
  exit 1
fi

if ((DRY_RUN)); then
  if [[ -d "$DEST_ROOT" ]]; then
    :
  else
    printf '[dry-run] Create global Skill directory: %s\n' "$DEST_ROOT"
  fi
else
  mkdir -p "$DEST_ROOT"
fi

for skill_file in "${SKILL_FILES[@]}"; do
  skill_dir="${skill_file%/SKILL.md}"
  skill_name="${skill_dir##*/}"
  target="$DEST_ROOT/$skill_name"

  if [[ -L "$target" ]]; then
    printf 'Error: refusing to replace Skill symlink: %s\n' "$target" >&2
    exit 1
  fi
  if [[ -e "$target" && ! -d "$target" ]]; then
    printf 'Error: target exists but is not a directory: %s\n' "$target" >&2
    exit 1
  fi

  if ((DRY_RUN)); then
    if [[ -d "$target" ]]; then
      rsync --archive --delete --dry-run \
        --exclude='/config.local.json' \
        --exclude='/.DS_Store' \
        "$skill_dir/" "$target/"
    else
      printf '[dry-run] Install %s to %s\n' "$skill_name" "$target"
    fi
  else
    mkdir -p "$target"
    rsync --archive --delete \
      --exclude='/config.local.json' \
      --exclude='/.DS_Store' \
      "$skill_dir/" "$target/"
    printf 'Installed %s to %s\n' "$skill_name" "$target"
  fi
done

if ((DRY_RUN)); then
  printf 'Dry run complete; no Skill files were changed.\n'
fi

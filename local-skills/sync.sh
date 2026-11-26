#!/usr/bin/env bash
#
# sync.sh — symlink every skill under local-skills/ into each agent's skills
# directory, so a single source-of-truth is shared across Trae, Claude, Codex,
# Cursor, CodeBuddy, Copilot, etc.
#
# Single source of truth : <repo>/local-skills/<skill>/
# Targets                : each agent's global skills dir (~/.<agent>/skills)
#                          + this repo's project-level .trae/skills
# Method                 : symlinks (edits to the source instantly reflect
#                          everywhere; no duplication).
#
# Safety:
#   - A correct symlink is left untouched (idempotent).
#   - A symlink pointing elsewhere is relinked (with a warning).
#   - A REAL directory/file at the destination is NEVER overwritten — it is
#     skipped with a warning (use --force to replace symlinks only; real dirs
#     are always skipped to protect existing installed skills).
#   - Target base dirs that don't exist are skipped.
#
# Usage:
#   ./local-skills/sync.sh           # link all skills to all agent targets
#   ./local-skills/sync.sh --dry-run # show what would change, change nothing
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(cd "$SCRIPT_DIR/.." && pwd)"
SOURCE="$REPO/local-skills"

DRY_RUN=0
if [[ "${1:-}" == "--dry-run" ]]; then
  DRY_RUN=1
fi

# Agent skill directories. Only the ones that exist on this machine are used;
# add a new agent by appending its skills dir here.
TARGETS=(
  "$REPO/.trae/skills"                 # Trae (project-level, this repo)
  "$HOME/.agents/skills"               # Trae (real global dir)
  "$HOME/.claude/skills"               # Claude Code
  "$HOME/.codex/skills"                # Codex / ChatGPT
  "$HOME/.cursor/skills"               # Cursor
  "$HOME/.codebuddy/skills"            # CodeBuddy
  "$HOME/.copilot/skills"              # Copilot
)

GREEN=$'\033[0;32m'; YELLOW=$'\033[0;33m'; RED=$'\033[0;31m'; NC=$'\033[0m'

# Relative path from $1 (base dir) to $2 (target), both absolute. Pure bash,
# no external deps. Used so repo-internal symlinks stay portable across
# machines and never bake a machine-specific absolute path into git history.
relpath() {
  local base="${1%/}" target="${2%/}"
  local IFS='/'
  local -a b=($base) t=($target)
  local i=0
  while [[ $i -lt ${#b[@]} && $i -lt ${#t[@]} && "${b[$i]}" == "${t[$i]}" ]]; do i=$((i+1)); done
  local up="" j
  for ((j=i; j<${#b[@]}; j++)); do up="../$up"; done
  local down=""
  for ((j=i; j<${#t[@]}; j++)); do down="$down${t[$j]}/"; done
  down="${down%/}"
  echo "${up}${down}"
}

ok()   { echo "${GREEN}  ok${NC}   $*"; }
warn() { echo "${YELLOW}  warn${NC} $*"; }
skip() { echo "${RED}  skip${NC} $*"; }
info() { echo "  info $*"; }

if [[ ! -d "$SOURCE" ]]; then
  echo "ERROR: source dir not found: $SOURCE" >&2
  exit 1
fi

echo "Source : $SOURCE"
echo "Repo   : $REPO"
echo "Mode   : $([[ $DRY_RUN -eq 1 ]] && echo 'DRY-RUN' || echo 'apply')"
echo

linked=0; relinked=0; unchanged=0; skipped=0

for skill_path in "$SOURCE"/*/; do
  [[ -d "$skill_path" ]] || continue
  skill="$(basename "$skill_path")"
  src="$(cd "$skill_path" && pwd)"   # absolute, symlink-free

  # Only sync things that look like a skill.
  if [[ ! -f "$src/SKILL.md" ]]; then
    warn "$skill: no SKILL.md, skipping"
    continue
  fi

  echo "[$skill]"
  for base in "${TARGETS[@]}"; do
    if [[ ! -d "$base" ]]; then
      # Don't spam: report missing target dirs once at the end.
      continue
    fi
    dest="$base/$skill"

    # For targets inside the repo, use a relative symlink so it stays portable
    # across machines and never bakes a machine-specific absolute path into git history.
    # Global agent dirs (~/.<agent>/skills) keep the absolute path (correct,
    # since they live outside the repo).
    if [[ "$base" == "$REPO/"* ]]; then
      link_target="$(relpath "$base" "$src")"
    else
      link_target="$src"
    fi

    if [[ -L "$dest" ]]; then
      cur="$(readlink "$dest")"
      # Resolve to absolute for comparison (relative symlinks are fine too).
      if [[ "$cur" == "$src" || "$(cd "$base" && readlink -f "$dest" 2>/dev/null || true)" == "$src" ]]; then
        ok   "$base/$skill -> $cur (already linked)"
        unchanged=$((unchanged+1))
      else
        warn "$base/$skill -> $cur (points elsewhere, relinking)"
        if [[ $DRY_RUN -eq 0 ]]; then
          rm -f "$dest"
          ln -s "$link_target" "$dest"
        fi
        relinked=$((relinked+1))
      fi
    elif [[ -e "$dest" ]]; then
      skip "$base/$skill exists as a REAL dir/file — NOT overwritten (remove it manually first if intended)"
      skipped=$((skipped+1))
    else
      info "$base/$skill -> $link_target"
      if [[ $DRY_RUN -eq 0 ]]; then
        mkdir -p "$base"
        ln -s "$link_target" "$dest"
      fi
      linked=$((linked+1))
    fi
  done
  echo
done

echo "===== summary ====="
echo "  linked   : $linked"
echo "  relinked : $relinked"
echo "  unchanged: $unchanged"
echo "  skipped  : $skipped (real dirs protected)"

# Report which target dirs were missing (informational).
missing=()
for base in "${TARGETS[@]}"; do
  [[ -d "$base" ]] || missing+=("$base")
done
if (( ${#missing[@]} > 0 )); then
  echo
  echo "target dirs not present on this machine (skipped):"
  for m in "${missing[@]}"; do echo "  - $m"; done
fi

if [[ $DRY_RUN -eq 1 ]]; then
  echo
  echo "(dry-run: no changes made. Re-run without --dry-run to apply.)"
fi

#!/usr/bin/env bash
# dsh-plugin/sync.sh — keep dsh-plugin/skills/ in sync with the canonical
# skills/ source, and (optionally) bump + publish the npm package.
#
# The npm package must be self-contained, so the four skills are materialized
# as copies (not symlinks) under dsh-plugin/skills/. This script is the single
# way to refresh those copies.
#
# Usage:
#   dsh-plugin/sync.sh                sync skills (rsync, no version change)
#   dsh-plugin/sync.sh --check        verify copies match canonical source
#   dsh-plugin/sync.sh --bump patch   bump version (patch|minor|major|x.y.z)
#   dsh-plugin/sync.sh --publish      run npm publish after sync
#   dsh-plugin/sync.sh --bump patch --publish   full release flow
#
# Exit codes:
#   0  sync ok (and publish succeeded if --publish)
#   1  drift detected (--check) or publish failed

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"

# Reuse the canonical exclude list.
# shellcheck source=sync/manifest.sh
source "$repo_root/sync/manifest.sh"

# The four skills bundled into the npm package.
DSH_SKILLS=(
  "diagram-generator"
  "clarify-before-acting"
  "insight-challenge"
  "workflow-skill-designer"
)

src_root="$repo_root/skills"
dst_root="$script_dir/skills"
check_only=0
bump=""
do_publish=0
dry_run=0

log()  { printf '%s\n' "$*"; }
dry()  { printf 'DRY  %s\n' "$*"; }
die()  { printf 'error: %s\n' "$*" >&2; exit 1; }

usage() {
  cat <<'USAGE'
usage: dsh-plugin/sync.sh [options]

Sync canonical skills/ into dsh-plugin/skills/ and optionally publish.

Options:
  --check            Verify copies match canonical source (exit 1 on drift).
  --bump LEVEL       Bump version before publish: patch|minor|major|x.y.z.
  --publish          Run `npm publish` after sync.
  --dry-run          Print planned actions without writing.
  -h, --help         Show this help.
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --check)    check_only=1; shift ;;
    --bump)
      [[ -z "${2:-}" ]] && die "missing value for --bump"
      bump="$2"; shift 2 ;;
    --publish)  do_publish=1; shift ;;
    --dry-run)  dry_run=1; shift ;;
    -h|--help)  usage; exit 0 ;;
    *) echo "unknown option: $1" >&2; usage >&2; exit 2 ;;
  esac
done

# Build rsync exclude args from SYNC_COPY_EXCLUDES.
rsync_excludes=()
for pattern in "${SYNC_COPY_EXCLUDES[@]}"; do
  rsync_excludes+=(--exclude="$pattern")
done

sync_one() {
  local skill="$1"
  local src="$src_root/$skill"
  local dst="$dst_root/$skill"

  [[ -d "$src" ]] || die "canonical skill missing: $src"

  if [[ "$check_only" -eq 1 ]]; then
    if [[ ! -d "$dst" ]]; then
      printf 'DRIFT %s: missing copy at %s\n' "$skill" "$dst"
      return 1
    fi
    local out
    # --itemize-changes prints one line per differing path; filter out the
    # benign directory-mtime line so only real drift is reported.
    out="$(rsync -an --delete --itemize-changes "${rsync_excludes[@]}" "$src/" "$dst/" 2>&1 \
      | grep -v '^\.d\.\.t\.\.\.\. \./$' || true)"
    if [[ -n "$out" ]]; then
      printf 'DRIFT %s:\n%s\n' "$skill" "$out"
      return 1
    fi
    printf 'ok    %s\n' "$skill"
    return 0
  fi

  if [[ "$dry_run" -eq 1 ]]; then
    dry "rsync -a --delete ${rsync_excludes[*]} $src/ $dst/"
    return 0
  fi

  mkdir -p "$dst"
  rsync -a --delete "${rsync_excludes[@]}" "$src/" "$dst/"
  printf 'synced %s\n' "$skill"
}

bump_version() {
  local level="$1"
  local current new
  current="$(node -e "console.log(require('./package.json').version)")"

  case "$level" in
    patch|minor|major)
      new="$(npm version "$level" --no-git-tag-version --silent)"
      new="${new#v}"
      ;;
    *)
      # Exact version string x.y.z
      if [[ ! "$level" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        die "invalid --bump value: $level (use patch|minor|major|x.y.z)"
      fi
      new="$level"
      npm version "$new" --no-git-tag-version --silent >/dev/null
      ;;
  esac
  printf 'version %s -> %s\n' "$current" "$new"
}

main() {
  local skill rc=0

  log "dsh-plugin sync"
  log "source: $src_root"
  log "target: $dst_root"
  log ""

  for skill in "${DSH_SKILLS[@]}"; do
    sync_one "$skill" || rc=1
  done

  if [[ "$check_only" -eq 1 ]]; then
    if [[ "$rc" -ne 0 ]]; then
      printf '\nsummary: drift detected\n' >&2
      exit 1
    fi
    printf '\nsummary: all copies match canonical source\n'
    exit 0
  fi

  if [[ "$rc" -ne 0 ]]; then
    die "sync failed"
  fi

  if [[ -n "$bump" ]]; then
    if [[ "$dry_run" -eq 1 ]]; then
      dry "npm version $bump"
    else
      (cd "$script_dir" && bump_version "$bump")
    fi
  fi

  if [[ "$do_publish" -eq 1 ]]; then
    if [[ "$dry_run" -eq 1 ]]; then
      dry "npm publish (from $script_dir)"
    else
      log ""
      log "publishing..."
      (cd "$script_dir" && npm publish 2>&1) || die "npm publish failed"
      log "published OK"
    fi
  fi

  printf '\nsummary: sync complete\n'
}

main "$@"

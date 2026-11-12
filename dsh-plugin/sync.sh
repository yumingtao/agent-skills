#!/usr/bin/env bash
# dsh-plugin/sync.sh — keep each standalone package's skill/ copy in sync with
# the canonical skills/ source, and (optionally) bump + publish every npm package.
#
# Each skill is published as its own npm package under
# dsh-plugin/packages/<skill>/. The skill content lives at
# dsh-plugin/packages/<skill>/skill/ (a materialized copy of skills/<skill>/).
# This script is the single way to refresh those copies and release new versions.
#
# Usage:
#   dsh-plugin/sync.sh                sync all skill copies (no version change)
#   dsh-plugin/sync.sh --check        verify copies match canonical source
#   dsh-plugin/sync.sh --bump patch   bump version of all packages (patch|minor|major|x.y.z)
#   dsh-plugin/sync.sh --publish      run npm publish for every package after sync
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

# The four standalone packages. Directory name == skill id == npm package suffix.
DSH_SKILLS=(
  "diagram-generator"
  "clarify-before-acting"
  "insight-challenge"
  "workflow-skill-designer"
)

src_root="$repo_root/skills"
packages_root="$script_dir/packages"
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

Sync canonical skills/ into each dsh-plugin/packages/<skill>/skill/ and
optionally bump + publish every npm package.

Options:
  --check            Verify copies match canonical source (exit 1 on drift).
  --bump LEVEL       Bump version of all packages: patch|minor|major|x.y.z.
  --publish          Run `npm publish` for every package after sync.
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

# Path to the packaged skill copy directory for a given skill id.
pkg_skill_dir() {
  printf '%s/%s/skill' "$packages_root" "$1"
}

# Path to the package root directory for a given skill id.
pkg_dir() {
  printf '%s/%s' "$packages_root" "$1"
}

sync_one() {
  local skill="$1"
  local src="$src_root/$skill"
  local dst
  dst="$(pkg_skill_dir "$skill")"

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
  local pkg="$1"
  local level="$2"
  local current new
  current="$(cd "$pkg" && node -e "console.log(require('./package.json').version)")"

  case "$level" in
    patch|minor|major)
      new="$(cd "$pkg" && npm version "$level" --no-git-tag-version --silent)"
      new="${new#v}"
      ;;
    *)
      # Exact version string x.y.z
      if [[ ! "$level" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        die "invalid --bump value: $level (use patch|minor|major|x.y.z)"
      fi
      new="$level"
      (cd "$pkg" && npm version "$new" --no-git-tag-version --silent >/dev/null)
      ;;
  esac
  printf '  %s: %s -> %s\n' "$(basename "$pkg")" "$current" "$new"
}

publish_one() {
  local pkg="$1"
  if [[ "$dry_run" -eq 1 ]]; then
    dry "npm publish (from $pkg)"
    return 0
  fi
  (cd "$pkg" && npm publish 2>&1) || die "npm publish failed for $pkg"
  printf '  published %s\n' "$(basename "$pkg")"
}

main() {
  local skill pkg rc=0

  log "dsh-plugin sync"
  log "source:   $src_root"
  log "packages: $packages_root"
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
    log ""
    log "bumping versions ($bump):"
    for skill in "${DSH_SKILLS[@]}"; do
      pkg="$(pkg_dir "$skill")"
      if [[ "$dry_run" -eq 1 ]]; then
        dry "npm version $bump (from $pkg)"
      else
        bump_version "$pkg" "$bump"
      fi
    done
  fi

  if [[ "$do_publish" -eq 1 ]]; then
    log ""
    log "publishing:"
    for skill in "${DSH_SKILLS[@]}"; do
      pkg="$(pkg_dir "$skill")"
      publish_one "$pkg"
    done
    log "published OK"
  fi

  printf '\nsummary: sync complete\n'
}

main "$@"

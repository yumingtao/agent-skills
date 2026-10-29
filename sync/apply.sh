#!/usr/bin/env bash
# sync/apply.sh — distribute the canonical skills/ folders into agent platform
# install locations.
#
# The canonical source is the collection itself: skills/<skill>/. Each platform
# target receives that whole folder, either as a symlink (default; keeps exactly
# one source of truth) or as a materialized copy (--copy; for platforms or sync
# tools that cannot follow links).
#
# Safety: existing targets are never replaced silently. Pre-flight collects every
# conflict and aborts without writing anything unless --force is passed.

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"

# shellcheck source=sync/manifest.sh
source "$script_dir/manifest.sh"

mode="link"
force=0
dry_run=0
to_dir=""
platform_ids=()
skill_names=()
platforms=()
skills=()
conflicts=()
SYNC_RSYNC_EXCLUDES=()

usage() {
  cat <<'USAGE'
usage: sync/apply.sh [options]

Distribute the canonical skills/ folders into agent platform install locations.

Options:
  --platform ID   Restrict to a platform id (repeatable). Default: all detected.
  --skill NAME    Restrict to one skill (repeatable). Default: every skill.
  --to DIR        Install into DIR instead of each platform's global root
                  (project-local install; requires --platform).
  --copy          Materialize copies instead of symlinks.
  --link          Use symlinks (default).
  --force         Replace targets that already exist and are not synced links.
  --dry-run       Print planned changes without writing anything.
  -h, --help      Show this help.

Run sync/check.sh afterwards to verify every target matches the canonical source.
USAGE
}

log() { printf '%s\n' "$*"; }
dry() { printf 'DRY  %s\n' "$*"; }
die() { printf 'error: %s\n' "$*" >&2; exit 1; }

while [[ $# -gt 0 ]]; do
  case "$1" in
    --platform)
      if [[ -z "${2:-}" ]]; then
        die "missing value for --platform"
      fi
      platform_ids+=("$2")
      shift 2
      ;;
    --skill)
      if [[ -z "${2:-}" ]]; then
        die "missing value for --skill"
      fi
      skill_names+=("$2")
      shift 2
      ;;
    --to)
      if [[ -z "${2:-}" ]]; then
        die "missing value for --to"
      fi
      to_dir="$2"
      shift 2
      ;;
    --copy) mode="copy"; shift ;;
    --link) mode="link"; shift ;;
    --force) force=1; shift ;;
    --dry-run) dry_run=1; shift ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [[ -n "$to_dir" && ${#platform_ids[@]} -eq 0 ]]; then
  die "--to requires --platform ID (the entrypoint file is platform specific)"
fi

platform_entry_for() {
  local want="$1"
  local entry id
  for entry in "${PLATFORM_TARGETS[@]}"; do
    id="${entry%%|*}"
    if [[ "$id" == "$want" ]]; then
      printf '%s\n' "$entry"
      return 0
    fi
  done
  return 1
}

detect_platforms() {
  local entry id display install_root chain detect kind value
  for entry in "${PLATFORM_TARGETS[@]}"; do
    IFS='|' read -r id display install_root chain detect <<<"$entry"
    kind="${detect%%:*}"
    value="${detect#*:}"
    case "$kind" in
      dir)
        if [[ -d "$value" ]]; then
          platforms+=("$entry")
        fi
        ;;
      cmd)
        if command -v "$value" >/dev/null 2>&1; then
          platforms+=("$entry")
        fi
        ;;
      *)
        die "invalid detect rule in sync/manifest.sh for '$id': $detect"
        ;;
    esac
  done

  if [[ ${#platforms[@]} -eq 0 ]]; then
    die "no agent platform detected. Pass --platform ID, or create one of the config dirs listed in sync/manifest.sh."
  fi
}

discover_skills() {
  local dir skill
  for dir in "$repo_root"/skills/*; do
    if [[ ! -d "$dir" ]]; then
      continue
    fi
    skill="$(basename "$dir")"
    if [[ -f "$dir/SKILL.md" ]]; then
      skills+=("$skill")
    else
      printf 'warn: skills/%s has no SKILL.md; skipped\n' "$skill" >&2
    fi
  done

  if [[ ${#skills[@]} -eq 0 ]]; then
    die "no skills found under $repo_root/skills"
  fi
}

filter_skills() {
  local name dir

  if [[ ${#skill_names[@]} -eq 0 ]]; then
    return
  fi

  for name in "${skill_names[@]}"; do
    dir="$repo_root/skills/$name"
    if [[ ! -d "$dir" ]]; then
      die "unknown skill: $name"
    fi
    if [[ ! -f "$dir/SKILL.md" ]]; then
      die "skill '$name' has no SKILL.md"
    fi
  done

  skills=()
  for name in "${skill_names[@]}"; do
    skills+=("$name")
  done
}

resolve_entrypoint() {
  local src="$1"
  local chain="$2"
  local candidate
  local saved_ifs="$IFS"

  IFS=','
  for candidate in $chain; do
    IFS="$saved_ifs"
    if [[ -f "$src/$candidate" ]]; then
      printf '%s\n' "$candidate"
      return 0
    fi
    IFS=','
  done
  IFS="$saved_ifs"

  return 1
}

build_rsync_excludes() {
  local pattern
  SYNC_RSYNC_EXCLUDES=()
  for pattern in "${SYNC_COPY_EXCLUDES[@]}"; do
    SYNC_RSYNC_EXCLUDES+=(--exclude="$pattern")
  done
}

target_root() {
  if [[ -n "$to_dir" ]]; then
    printf '%s\n' "$to_dir"
  else
    printf '%s\n' "$1"
  fi
}

preflight_target() {
  local id="$1"
  local display="$2"
  local install_root="$3"
  local chain="$4"
  local skill="$5"

  local src="$repo_root/skills/$skill"
  local root
  local dst
  local current

  root="$(target_root "$install_root")"
  dst="$root/$skill"

  if ! resolve_entrypoint "$src" "$chain" >/dev/null; then
    conflicts+=("$display: skills/$skill ships none of: ${chain//,/, }")
    return
  fi

  if [[ "$src" -ef "$dst" ]] 2>/dev/null; then
    return
  fi

  if [[ -L "$dst" ]]; then
    current="$(readlink "$dst")"
    if [[ "$current" != "$src" && "$force" -ne 1 ]]; then
      conflicts+=("$display: $dst is a symlink to $current")
    fi
  elif [[ -e "$dst" ]]; then
    if [[ "$force" -ne 1 ]]; then
      conflicts+=("$display: $dst already exists")
    fi
  fi
}

remove_target() {
  local dst="$1"
  if [[ "$dry_run" -eq 1 ]]; then
    return
  fi
  if [[ -L "$dst" ]]; then
    rm -f "$dst"
  elif [[ -d "$dst" ]]; then
    rm -rf "$dst"
  elif [[ -e "$dst" ]]; then
    rm -f "$dst"
  fi
}

apply_skill() {
  local id="$1"
  local display="$2"
  local install_root="$3"
  local chain="$4"
  local skill="$5"

  local src="$repo_root/skills/$skill"
  local root
  local dst
  local entrypoint=""
  local current=""

  root="$(target_root "$install_root")"
  dst="$root/$skill"

  if ! entrypoint="$(resolve_entrypoint "$src" "$chain")"; then
    die "$display: skills/$skill ships none of: ${chain//,/, }"
  fi

  if [[ "$src" -ef "$dst" ]] 2>/dev/null; then
    log "ok   $display: $skill is already the canonical source"
    return
  fi

  if [[ -L "$dst" ]]; then
    current="$(readlink "$dst")"
    if [[ "$current" == "$src" ]]; then
      log "ok   $display: $skill already linked"
      return
    fi
    remove_target "$dst"
  elif [[ -e "$dst" ]]; then
    remove_target "$dst"
  fi

  if [[ "$dry_run" -eq 1 ]]; then
    dry "mkdir -p $root"
    if [[ "$mode" == "link" ]]; then
      dry "ln -s $src $dst"
    else
      dry "rsync -a --delete ${SYNC_RSYNC_EXCLUDES[*]} $src/ $dst/"
    fi
    log "plan $display: $skill -> $dst (entrypoint: $entrypoint)"
    return
  fi

  mkdir -p "$root"

  if [[ "$mode" == "link" ]]; then
    ln -s "$src" "$dst"
    log "link $display: $skill -> $dst (entrypoint: $entrypoint)"
  else
    mkdir -p "$dst"
    rsync -a --delete "${SYNC_RSYNC_EXCLUDES[@]}" "$src/" "$dst/"
    log "copy $display: $skill -> $dst (entrypoint: $entrypoint)"
  fi
}

main() {
  local entry id display install_root chain other
  local skill
  local ok=0

  if [[ ${#platform_ids[@]} -gt 0 ]]; then
    for id in "${platform_ids[@]}"; do
      if ! entry="$(platform_entry_for "$id")"; then
        die "unknown platform: $id (see sync/manifest.sh)"
      fi
      platforms+=("$entry")
    done
  else
    detect_platforms
  fi

  discover_skills
  filter_skills
  build_rsync_excludes

  log "agent-skills sync"
  log "repo:  $repo_root"
  log "mode:  $mode${to_dir:+ | target dir: $to_dir}"
  log ""

  if [[ "$force" -ne 1 ]]; then
    for entry in "${platforms[@]}"; do
      IFS='|' read -r id display install_root chain other <<<"$entry"
      for skill in "${skills[@]}"; do
        preflight_target "$id" "$display" "$install_root" "$chain" "$skill"
      done
    done

    if [[ ${#conflicts[@]} -gt 0 ]]; then
      printf '%s\n' "${conflicts[@]}" >&2
      printf 'error: %d target(s) already exist; re-run with --force to replace them. Nothing was written.\n' \
        "${#conflicts[@]}" >&2
      exit 1
    fi
  fi

  for entry in "${platforms[@]}"; do
    IFS='|' read -r id display install_root chain other <<<"$entry"
    log "== $display ($id) =="
    for skill in "${skills[@]}"; do
      apply_skill "$id" "$display" "$install_root" "$chain" "$skill"
      ok=$((ok + 1))
    done
    log ""
  done

  log "$ok target(s) synced"
  log "next: run sync/check.sh to verify every target matches the canonical source"
}

main "$@"

#!/usr/bin/env bash
# sync/check.sh — verify the collection's integrity and confirm that every
# installed platform target still matches the canonical skills/ source.
#
# Exit codes:
#   0  collection and installed targets are consistent
#   1  drift, missing files, or invalid skill metadata
#
# This is the CI-safe entry point: `--collection-only` inspects the repository
# only and never looks at anything outside it.

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"

# shellcheck source=sync/manifest.sh
source "$script_dir/manifest.sh"

check_collection=1
check_installs=1
quiet=0
to_dir=""
platform_ids=()
skill_names=()
platforms=()
skills=()
failures=()
diff_args=()

usage() {
  cat <<'USAGE'
usage: sync/check.sh [options]

Verify the collection and its installed platform targets.

Options:
  --platform ID       Restrict to a platform id (repeatable). Default: all detected.
  --skill NAME        Restrict to one skill (repeatable). Default: every skill.
  --to DIR            Check targets under DIR instead of the platform's global
                      root (requires --platform); mirrors sync/apply.sh --to.
  --collection-only   Validate the repository only (no platform installs).
  --installs-only     Validate installed targets only.
  --quiet             Print only failures and the summary.
  -h, --help          Show this help.
USAGE
}

log() {
  if [[ "$quiet" -eq 0 ]]; then
    printf '%s\n' "$*"
  fi
}

fail() {
  printf 'DRIFT %s\n' "$*"
  failures+=("$*")
}

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
    --collection-only) check_collection=1; check_installs=0; shift ;;
    --installs-only) check_collection=0; check_installs=1; shift ;;
    --quiet) quiet=1; shift ;;
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
  local entry id display detect kind value
  for entry in "${PLATFORM_TARGETS[@]}"; do
    IFS='|' read -r id display _ _ detect <<<"$entry"
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
}

discover_skills() {
  local dir skill
  for dir in "$repo_root"/skills/*; do
    if [[ ! -d "$dir" ]]; then
      continue
    fi
    skill="$(basename "$dir")"
    skills+=("$skill")
  done
}

filter_skills() {
  local name dir
  if [[ ${#skill_names[@]} -eq 0 ]]; then
    discover_skills
    return
  fi
  for name in "${skill_names[@]}"; do
    dir="$repo_root/skills/$name"
    if [[ ! -d "$dir" ]]; then
      die "unknown skill: $name"
    fi
  done
  skills=()
  for name in "${skill_names[@]}"; do
    skills+=("$name")
  done
}

build_diff_args() {
  local pattern
  diff_args=()
  for pattern in "${SYNC_COPY_EXCLUDES[@]}"; do
    diff_args+=(-x "${pattern%/}")
  done
}

validate_skill() {
  local skill="$1"
  local dir="$repo_root/skills/$skill"
  local label="skills/$skill"
  local problem=""

  if [[ ! -f "$dir/SKILL.md" ]]; then
    fail "$label: missing SKILL.md"
    return
  fi

  problem="$(awk -v skill="$skill" '
    NR == 1 { if ($0 != "---") { err = "first line is not \"---\"" } ; next }
    err == "" && $0 == "---" { closed = 1; exit }
    err == "" && /^name:[[:space:]]/ && fname == "" {
      line = $0
      sub(/^name:[[:space:]]*/, "", line)
      gsub(/["\047]/, "", line)
      fname = line
    }
    err == "" && /^description:[[:space:]]/ && !has_desc { has_desc = 1 }
    END {
      if (err == "" && !closed) { err = "unterminated frontmatter (no closing ---)" }
      if (err == "") {
        if (fname == "") { err = "missing frontmatter name" }
        else if (fname != skill) { err = "frontmatter name \"" fname "\" does not match folder \"" skill "\"" }
        else if (!has_desc) { err = "missing frontmatter description" }
      }
      if (err != "") { print err }
    }
  ' "$dir/SKILL.md")"

  if [[ -n "$problem" ]]; then
    fail "$label: $problem"
  else
    log "ok   $label"
  fi
}

validate_readme_index() {
  local readme="$repo_root/README.md"
  local listed skill found

  if [[ ! -f "$readme" ]]; then
    fail "README.md: missing collection index"
    return
  fi

  listed="$(grep -oE '\(skills/[A-Za-z0-9._-]+/\)' "$readme" | sed -E 's|^\(skills/(.+)/\)$|\1|' | sort -u)"

  for skill in "${skills[@]}"; do
    found=0
    if printf '%s\n' "$listed" | grep -Fxq "$skill"; then
      found=1
    fi
    if [[ "$found" -eq 0 ]]; then
      fail "README.md: skills/$skill is not listed in the skill table"
    else
      log "ok   README.md lists skills/$skill"
    fi
  done

  if [[ -n "$listed" ]]; then
    while IFS= read -r skill; do
      [[ -n "$skill" ]] || continue
      if [[ ! -d "$repo_root/skills/$skill" ]]; then
        fail "README.md: lists skills/$skill but no such folder exists"
      fi
    done <<<"$listed"
  fi
}

validate_manifest() {
  local entry id display root chain other
  local seen

  seen=()

  if [[ ${#PLATFORM_TARGETS[@]} -eq 0 ]]; then
    fail "sync/manifest.sh: PLATFORM_TARGETS is empty"
    return
  fi

  for entry in "${PLATFORM_TARGETS[@]}"; do
    IFS='|' read -r id display root chain other <<<"$entry"
    if [[ -z "$id" || -z "$display" || -z "$root" || -z "$chain" || -z "$other" ]]; then
      fail "sync/manifest.sh: malformed platform entry: $entry"
      continue
    fi
    seen+=("$id")
  done

  for entry in "${PLATFORM_TARGETS[@]}"; do
    IFS='|' read -r id display root chain other <<<"$entry"
    if [[ "$(printf '%s\n' "${seen[@]}" | grep -Fcx "$id")" -gt 1 ]]; then
      fail "sync/manifest.sh: duplicate platform id: $id"
    fi
  done

  log "ok   sync/manifest.sh declares ${#PLATFORM_TARGETS[@]} platform(s)"
}

target_root() {
  if [[ -n "$to_dir" ]]; then
    printf '%s\n' "$to_dir"
  else
    printf '%s\n' "$1"
  fi
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

check_target() {
  local id="$1"
  local display="$2"
  local install_root="$3"
  local chain="$4"
  local skill="$5"

  local src="$repo_root/skills/$skill"
  local root
  local dst
  local label="$display: $skill"
  local output=""
  local current=""

  root="$(target_root "$install_root")"
  dst="$root/$skill"

  if [[ ! -e "$dst" && ! -L "$dst" ]]; then
    fail "$label: not installed at $dst (run sync/apply.sh)"
    return
  fi

  if ! resolve_entrypoint "$src" "$chain" >/dev/null; then
    fail "$label: skills/$skill ships none of: ${chain//,/, }"
    return
  fi

  if [[ -L "$dst" ]]; then
    current="$(readlink "$dst")"
    if [[ "$current" != "$src" ]]; then
      fail "$label: symlink points at $current, expected $src"
      return
    fi
    log "ok   $label -> $dst"
    return
  fi

  if [[ ! -d "$dst" ]]; then
    fail "$label: $dst is not a directory"
    return
  fi

  output="$(diff -r "${diff_args[@]}" "$src" "$dst" 2>/dev/null || true)"
  if [[ -n "$output" ]]; then
    fail "$label: copy differs from canonical (run sync/apply.sh --copy --force)"
    return
  fi

  log "ok   $label (copy) -> $dst"
}

main() {
  local entry id display install_root chain skill

  filter_skills
  build_diff_args

  if [[ ${#skills[@]} -eq 0 ]]; then
    die "no skills found under $repo_root/skills"
  fi

  log "agent-skills sync check"
  log "repo:  $repo_root"
  log ""

  if [[ "$check_collection" -eq 1 ]]; then
    log "== collection =="
    validate_manifest
    for skill in "${skills[@]}"; do
      validate_skill "$skill"
    done
    validate_readme_index
    log ""
  fi

  if [[ "$check_installs" -eq 1 ]]; then
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

    if [[ ${#platforms[@]} -eq 0 ]]; then
      log "== installs =="
      log "skip no agent platform detected (pass --platform ID)"
      log ""
    else
      log "== installs =="
      for entry in "${platforms[@]}"; do
        IFS='|' read -r id display install_root chain _ <<<"$entry"
        for skill in "${skills[@]}"; do
          check_target "$id" "$display" "$install_root" "$chain" "$skill"
        done
      done
      log ""
    fi
  fi

  if [[ ${#failures[@]} -gt 0 ]]; then
    printf 'summary: %d problem(s)\n' "${#failures[@]}"
    exit 1
  fi

  printf 'summary: collection and installs in sync\n'
}

main "$@"

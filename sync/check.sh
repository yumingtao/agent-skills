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
tracked=()

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

split_entry() {
  IFS='|' read -r P_ID P_DISPLAY P_ROOT P_CHAIN P_DETECT <<<"$1"
}

detect_platforms() {
  local entry kind value
  for entry in "${PLATFORM_TARGETS[@]}"; do
    split_entry "$entry"
    kind="${P_DETECT%%:*}"
    value="${P_DETECT#*:}"
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
        die "invalid detect rule in sync/manifest.sh for '$P_ID': $P_DETECT"
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

frontmatter_tags_count() {
  awk '
    NR == 1 { if ($0 != "---") exit; fm = 1; next }
    fm && $0 == "---" { exit }
    fm && /^tags:/ { in_tags = 1; next }
    fm && /^[A-Za-z_-]+:/ { in_tags = 0 }
    fm && in_tags && /^[[:space:]]*-[[:space:]]/ { count++ }
    END { print count + 0 }
  ' "$1"
}

validate_skill() {
  local skill="$1"
  local dir="$repo_root/skills/$skill"
  local label="skills/$skill"
  local problem=""
  local zh_tags en_tags
  local parity_ok=1

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
  fi

  # zh-en frontmatter parity: when an English mirror exists, both sides must
  # declare tags, and the entry counts must match (translations, not copies).
  if [[ -f "$dir/SKILL.en.md" ]]; then
    zh_tags="$(frontmatter_tags_count "$dir/SKILL.md")"
    en_tags="$(frontmatter_tags_count "$dir/SKILL.en.md")"
    if [[ "$zh_tags" -eq 0 && "$en_tags" -ne 0 ]]; then
      fail "$label: tags declared in SKILL.en.md but missing in SKILL.md"
      parity_ok=0
    elif [[ "$zh_tags" -ne 0 && "$en_tags" -eq 0 ]]; then
      fail "$label: tags declared in SKILL.md but missing in SKILL.en.md"
      parity_ok=0
    elif [[ "$zh_tags" -ne "$en_tags" ]]; then
      fail "$label: tags count mismatch between SKILL.md ($zh_tags) and SKILL.en.md ($en_tags)"
      parity_ok=0
    fi
  fi

  if [[ -z "$problem" && "$parity_ok" -eq 1 ]]; then
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
  local entry
  local seen

  seen=()

  if [[ ${#PLATFORM_TARGETS[@]} -eq 0 ]]; then
    fail "sync/manifest.sh: PLATFORM_TARGETS is empty"
    return
  fi

  for entry in "${PLATFORM_TARGETS[@]}"; do
    split_entry "$entry"
    if [[ -z "$P_ID" || -z "$P_DISPLAY" || -z "$P_ROOT" || -z "$P_CHAIN" || -z "$P_DETECT" ]]; then
      fail "sync/manifest.sh: malformed platform entry: $entry"
      continue
    fi
    seen+=("$P_ID")
  done

  for entry in "${PLATFORM_TARGETS[@]}"; do
    split_entry "$entry"
    if [[ "$(printf '%s\n' "${seen[@]}" | grep -Fcx "$P_ID")" -gt 1 ]]; then
      fail "sync/manifest.sh: duplicate platform id: $P_ID"
    fi
  done

  log "ok   sync/manifest.sh declares ${#PLATFORM_TARGETS[@]} platform(s)"
}

tracked_files() {
  local file

  if [[ ! -d "$repo_root/.git" ]] && ! git -C "$repo_root" rev-parse --git-dir >/dev/null 2>&1; then
    return
  fi

  while IFS= read -r file; do
    if [[ -z "$file" || ! -f "$repo_root/$file" ]]; then
      continue
    fi
    # The guard's own configuration/tooling is exempt: it has to name the
    # patterns it forbids.
    if [[ "$file" == "sync/manifest.sh" || "$file" == "sync/check.sh" ]]; then
      continue
    fi
    tracked+=("$repo_root/$file")
  done < <(git -C "$repo_root" ls-files)
}

validate_identity() {
  local email entry allowed pattern file
  local clean=1

  tracked=()
  tracked_files

  if [[ ${#tracked[@]} -eq 0 ]]; then
    log "skip identity guard (no tracked files)"
    return
  fi

  while IFS= read -r email; do
    if [[ -z "$email" ]]; then
      continue
    fi
    allowed=0
    for entry in "${SYNC_ALLOWED_EMAILS[@]}"; do
      if [[ "$email" == "$entry" ]]; then
        allowed=1
        break
      fi
    done
    if [[ "$allowed" -eq 0 ]]; then
      fail "identity: '$email' appears in a tracked file but is not in SYNC_ALLOWED_EMAILS"
      clean=0
    fi
  done < <(grep -rIoh -E "[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}" "${tracked[@]}" 2>/dev/null | sort -u)

  for pattern in "${SYNC_FORBIDDEN_PATHS[@]}"; do
    while IFS= read -r file; do
      if [[ -n "$file" ]]; then
        fail "identity: tracked file contains local path pattern $pattern: ${file#"$repo_root"/}"
        clean=0
      fi
    done < <(grep -rIl -F "$pattern" "${tracked[@]}" 2>/dev/null)
  done

  if [[ "$clean" -eq 1 ]]; then
    log "ok   identity guard passed"
  fi
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
  local display="$1"
  local install_root="$2"
  local chain="$3"
  local skill="$4"

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
  local entry id skill

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
    validate_identity
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
        split_entry "$entry"
        for skill in "${skills[@]}"; do
          check_target "$P_DISPLAY" "$P_ROOT" "$P_CHAIN" "$skill"
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

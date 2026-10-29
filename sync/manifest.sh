#!/usr/bin/env bash
# Single source of truth for the "one source -> many platforms" distribution map.
#
# Sourced by sync/apply.sh (writer) and sync/check.sh (verifier), so the map is
# declared exactly once: adding a platform or changing an entrypoint chain is a
# one-line edit here.
#
# Repo convention
#   skills/<skill>/          canonical source: SKILL.md plus resources/ | specs/ |
#                            phases/ | references/ | examples/ | scripts/ | tests/
#   <install-root>/<skill>/  installed target: a symlink to canonical (default) or
#                            a materialized copy (--copy)
#
# Platform entry format: "id|display|install-root|entrypoint-chain|detect"
#   id                short id used by --platform
#   display           human-readable name used in reports
#   install-root      directory that receives one sub-directory per skill
#   entrypoint-chain  comma-separated file names, first existing one wins; this is
#                     the file to point the agent at on that platform
#   detect            "dir:PATH" or "cmd:NAME"; used to auto-detect the platform
#                     when --platform is not passed
#
# This file is sourced, so its arrays are consumed by sync/apply.sh and
# sync/check.sh rather than by this file itself.

# shellcheck disable=SC2034

PLATFORM_TARGETS=(
  "claude|Claude Code|$HOME/.claude/skills|SKILL.md|dir:$HOME/.claude"
  "codex|Codex|$HOME/.codex/skills|SKILL.md|dir:$HOME/.codex"
  "codebuddy|CodeBuddy|$HOME/.codebuddy/skills|CODEBUDDY.md,SKILL.md|dir:$HOME/.codebuddy"
  "hermes|Hermes|$HOME/.hermes/skills|HERMES.md,SKILL.md|dir:$HOME/.hermes"
  "opencode|OpenCode|$HOME/.config/opencode/skills|AGENTS.md,SKILL.md|dir:$HOME/.config/opencode"
  "cursor|Cursor|$HOME/.cursor/skills|AGENTS.md,SKILL.md|dir:$HOME/.cursor"
  "windsurf|Windsurf|$HOME/.windsurf/skills|AGENTS.md,SKILL.md|dir:$HOME/.windsurf"
  "gemini|Gemini CLI|$HOME/.gemini/skills|GEMINI.md,SKILL.md|cmd:gemini"
  "copilot|GitHub Copilot|$HOME/.copilot/skills|COPILOT-INSTRUCTIONS.md,SKILL.md|cmd:copilot"
)

# Local state that must never travel into a distributed copy.
SYNC_COPY_EXCLUDES=(
  ".DS_Store"
  ".omc/"
  "node_modules/"
  "*.log"
  "*.tmp"
  "*.bak"
)

---
name: session-retrospective
slug: yumingtao-session-retrospective
displayName: Session Retrospective
version: 1.0.0
summary: End-of-session review that extracts workflow issues and appends structured entries to a local feedback log.
license: MIT
tags:
  - session review
  - workflow improvement
  - feedback log
  - developer tools
description: >
  Review the current conversation session at its end, extract workflow issues
  — wrong answers that needed correction, skipped gates, wrong routing, MCP
  errors, skill/doc gaps, multi-turn corrections — and append structured
  feedback entries to a local JSONL log. Skips trivial clarifications and
  focuses on systemic signals indicating a skill, doc, or workflow rule needs
  updating. Triggers on "session review", "log session feedback",
  "回顾一下这个会话", "记录会话反馈".
---

# Session Retrospective

Use this skill to review the current session and append structured feedback
entries to the project's workflow feedback log.

## Where feedback goes

Default location: `metrics/workflow-feedback.jsonl` in the current project
root. If the project establishes a different log location (check the project
docs or an existing log file), use that. Create the file on first write; it is
append-only local state and never committed to git.

## When to Use

- Engineer says "review this session", "log session feedback", or "session review"
- End of a working session on any workflow task
- After resolving a problem that took multiple back-and-forth exchanges

## What to Analyze

Review the conversation and identify:

1. **Wrong answers that needed correction** — AI gave incorrect output and the engineer had to correct it
2. **Gate-skipped** — a required workflow phase or confirmation was skipped
3. **Wrong routing** — the AI used the wrong skill, workflow, or approach
4. **MCP errors** — a tool call failed or blocked the workflow
5. **Skill/doc gaps** — repeated clarifications needed because a rule was missing or unclear
6. **Multi-turn corrections** — 2+ exchanges needed to reach a correct answer
7. **Successful completions** — worth recording as positive signal

Write one feedback entry per distinct issue. If nothing went wrong, write one `success` entry.

## How to Write Feedback

Append one JSON object per line to the feedback log:

```json
{"timestamp": "2026-11-13T14:30:00+08:00", "platform": "claude", "area": "review", "result": "corrected", "issue_type": "wrong-routing", "notes": "<what went wrong and what the correct behavior should be>", "ref": "PR-123"}
```

| Field | Values |
|---|---|
| `timestamp` | ISO-8601 local time |
| `platform` | `claude`, `codex`, `codebuddy`, `cursor`, `github-copilot`, `intellij-copilot`, `gemini`, `opencode`, `other` |
| `area` | `planning`, `implementation`, `review`, `git-pr`, `mcp`, `environment`, `docs`, `other` |
| `result` | `success`, `blocked`, `corrected`, `failed` |
| `issue_type` | `none`, `gate-skipped`, `wrong-routing`, `mcp-error`, `skill-sync-missing`, `generated-code-hygiene`, `logging-convention`, `utility-reuse`, `title-format`, `ticket-field`, `auth`, `tool-error`, `other` |
| `notes` | what went wrong and what the correct behavior should be |
| `ref` | optional ticket / PR number |

Infer `platform` from the current AI tool unless the engineer specifies otherwise.

## Rules

- Keep `notes` under 200 characters, focused on what should change in the workflow
- Do NOT log trivial clarifications (e.g., missing parameters the user simply forgot to provide)
- Focus on systemic issues: things indicating a skill, doc, or workflow rule needs updating
- Do NOT commit the feedback log — it is append-only local state

## After Writing Feedback

Print a brief summary table:

| Area | Issue Type | Notes |
|------|-----------|-------|
| ...  | ...       | ...   |

Then suggest which files in the current project likely need updating based on the issues found.

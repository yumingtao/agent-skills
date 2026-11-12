# agent-skills

Original, platform-neutral agent skills — prompt assets that work across Claude Code, Codex, Cursor, OpenCode, Windsurf, Gemini, GitHub Copilot, CodeBuddy, and Hermes.

[English](README.md) | [简体中文](README.zh-CN.md)

[![SkillHub](https://img.shields.io/badge/SkillHub-4%20published-green)](https://skillhub.cn/user/user_95900c57)
[![ClawHub](https://img.shields.io/badge/ClawHub-4%20published-orange)](https://clawhub.ai/@yumingtao)
[![skills.sh](https://skills.sh/b/yumingtao/agent-skills)](https://skills.sh/yumingtao/agent-skills)
[![DSH Index](https://img.shields.io/badge/DSH-market--index-blue)](https://cdn.jsdelivr.net/gh/yumingtao/agent-skills@main/docs/market/index.json)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

No runtime dependencies, no network calls, no build step. Each skill is a self-contained folder of instructions; where a skill supports multiple platforms, the platform files are thin adapters that route every agent to the same shared behavior.

## Skills

| Skill | What it does |
|---|---|
| **[diagram-generator](skills/diagram-generator/)** | Turns architecture briefs and codebase notes into standalone HTML/SVG technical maps: system, implementation, infrastructure, trust, data movement, deployment, and process views. Full package: generation rules, planning IR, HTML template, validation script, per-platform smoke tests. |
| **[clarify-before-acting](skills/clarify-before-acting/)** | A behavior rule for non-trivial requests: do your own homework first, reuse answers already in memory, work a question queue one item at a time until every direction-changing unknown is resolved, and never guess where direction is at stake. |
| **[insight-challenge](skills/insight-challenge/)** | Adversarial verification of code-review findings. Challenges each claim with counter-evidence anchored to actual source code and emits structured verdicts — overturned / weakened / confirmed — instead of trusting findings as-is. |
| **[workflow-skill-designer](skills/workflow-skill-designer/)** | Meta-skill that designs orchestrator + phases workflow skills: a thin `SKILL.md` coordinator plus progressively loaded `phases/` files, with TodoWrite patterns, inter-phase data flow, and validation checklists. |

## Install

Each skill is standalone — copy or symlink only what you need.

### Claude Code

```bash
ln -s /absolute/path/to/agent-skills/skills/<skill-name> ~/.claude/skills/<skill-name>
```

### Codex (skill mode)

```bash
ln -s /absolute/path/to/agent-skills/skills/<skill-name> ~/.codex/skills/<skill-name>
```

### Other agents

- **diagram-generator** ships per-platform adapters: `AGENTS.md` (Cursor / OpenCode / Windsurf), `GEMINI.md`, `COPILOT-INSTRUCTIONS.md`, `CODEBUDDY.md`, `HERMES.md` — see its [README](skills/diagram-generator/README.md#installation).
- The other three skills are Claude-skill-format folders; on platforms without a skills mechanism, point the agent at the skill's `SKILL.md` as an instruction file.

### SkillHub (Community Marketplace)

Install any skill directly from [SkillHub](https://skillhub.cn/user/user_95900c57):

```bash
# Install the CLI once
curl -fsSL https://skillhub.cn/install/install.sh | bash

# Install a skill (namespace: user_95900c57)
skillhub install yumingtao-diagram-generator --namespace user_95900c57
skillhub install yumingtao-clarify-before-acting --namespace user_95900c57
skillhub install yumingtao-insight-challenge --namespace user_95900c57
skillhub install yumingtao-workflow-skill-designer --namespace user_95900c57
```

### ClawHub (OpenClaw official registry)

Install any skill from the [ClawHub](https://clawhub.ai/@yumingtao) global registry:

```bash
# Install the CLI once
npm i -g clawhub

# Install a skill (owner: yumingtao)
clawhub install yumingtao/diagram-generator
clawhub install yumingtao/clarify-before-acting
clawhub install yumingtao/insight-challenge
clawhub install yumingtao/workflow-skill-designer
```

### skills.sh (decentralized GitHub index)

No sign-up required — skills are indexed directly from this public repository. Install via the `skills` CLI:

```bash
# Install all four skills at once
npx skills add yumingtao/agent-skills

# Or install a single skill
npx skills add yumingtao/agent-skills --skill diagram-generator
npx skills add yumingtao/agent-skills --skill clarify-before-acting
npx skills add yumingtao/agent-skills --skill insight-challenge
npx skills add yumingtao/agent-skills --skill workflow-skill-designer
```

### DeepSeek Harness (DSH)

Each skill ships as its own npm bundle, so you can install only what you need. Pick one of the two methods below.

#### Method 1 — npm packages (recommended; per-skill install)

```bash
dsh plugin --profile web add yumingtao-diagram-generator
dsh plugin --profile web add yumingtao-clarify-before-acting
dsh plugin --profile web add yumingtao-insight-challenge
dsh plugin --profile web add yumingtao-workflow-skill-designer
```

On first boot of the web profile each bundle copies its skill directory into
`~/.agents/skills` (the user-global skill root shared by DSH and Codex CLI).

#### Method 2 — market index (add all four at once)

Add the market index, then install any skill. Pick one index URL:

```bash
# Option A — jsDelivr CDN (recommended; may cache `@main` for minutes to hours)
dsh plugin index add https://cdn.jsdelivr.net/gh/yumingtao/agent-skills@main/docs/market/index.json

# Option B — GitHub raw (always fresh, no CDN cache)
dsh plugin index add https://raw.githubusercontent.com/yumingtao/agent-skills/main/docs/market/index.json

# Option C — local file (for offline / development)
dsh plugin index add file:///path/to/agent-skills/docs/market/index.json
```

Install:

```bash
dsh plugin install diagram-generator
dsh plugin install clarify-before-acting
dsh plugin install insight-challenge
dsh plugin install workflow-skill-designer
```

> With the market index, skill content is fetched from `github.com/yumingtao/agent-skills` at the pinned commit recorded in the index, regardless of which index URL you use. The CDN/raw choice only affects how the index file itself is delivered.

## Sync

`sync/` is a generalized "one source → many platforms" distributor for the whole collection. A platform target receives the canonical skill folder as a symlink (default) or as a materialized copy.

```bash
sync/apply.sh --dry-run                                  # preview
sync/apply.sh                                            # link into every detected platform
sync/apply.sh --platform claude --skill insight-challenge # narrow scope
sync/apply.sh --to ./ --platform cursor                  # project-local install
sync/check.sh                                            # verify nothing drifted
```

The distribution map lives in `sync/manifest.sh` — see [sync/README.md](sync/README.md).

## Design principles

- **One source of truth per skill.** Platform files route; they never restate behavior.
- **Markdown-first.** A skill is instructions plus optional specs/resources — nothing to install or run.
- **Progressive loading.** Coordinators stay thin; execution detail lives in `phases/` / `specs/` / `references/` loaded on demand.

## Roadmap

- [ ] `drawio-first` output mode for `diagram-generator` (needs dedicated mxGraphModel rules, a template, and import validation)

## License

[MIT](LICENSE). Skills in this collection are released under the same MIT terms.

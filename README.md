# agent-skills

Original, platform-neutral agent skills — prompt assets that work across Claude Code, Codex, Cursor, OpenCode, Windsurf, Gemini, GitHub Copilot, CodeBuddy, and Hermes.

No runtime dependencies, no network calls, no build step. Each skill is a self-contained folder of instructions; where a skill supports multiple platforms, the platform files are thin adapters that route every agent to the same shared behavior.

## Skills

| Skill | What it does |
|---|---|
| **[diagram-generator](skills/diagram-generator/)** | Turns architecture briefs and codebase notes into standalone HTML/SVG technical maps: system, implementation, infrastructure, trust, data movement, deployment, and process views. Full package: generation rules, planning IR, HTML template, validation script, per-platform smoke tests. |
| **[clarify-before-acting](skills/clarify-before-acting/)** | A behavior rule for non-trivial requests: do your own homework first, ask one targeted question at a time, stop when no remaining unknown would change the direction of the work, and state assumptions explicitly when proceeding anyway. |
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

[MIT](LICENSE). Skills in this collection carry the same MIT terms; see each folder for its license copy.

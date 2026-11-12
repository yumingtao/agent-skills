# yumingtao-dsh-skills

A [DSH](https://www.dsh.so) bundle that installs four production-grade agent
skills into your DSH skill discovery root.

## Skills

| Skill | What it does |
|-------|-------------|
| `diagram-generator` | Generate production-quality standalone HTML/SVG technical diagrams: architecture, infrastructure, topology, deployment, data flow, trust boundary, and process maps. |
| `clarify-before-acting` | Resolve direction-changing ambiguity before acting on complex, ambiguous, or high-cost requests. Skips trivial, mechanical, low-risk tasks. |
| `insight-challenge` | Adversarial review of code-quality findings. Challenges insights with counter-evidence, verifies claims against source code, and produces structured verdicts. |
| `workflow-skill-designer` | Meta-skill for designing orchestrator + phases structured workflow skills with progressive phase loading, task tracking, and inter-phase data flow. |

## Install

```bash
dsh plugin --profile web add yumingtao-dsh-skills
```

Or from the GitHub repository directly:

```bash
dsh plugin --profile web add github:yumingtao/agent-skills#path:/dsh-plugin
```

On first boot of the web profile the bundle copies the four skill directories
into `~/.agents/skills` (the user-global skill root shared by DSH and Codex
CLI). You can then invoke any of them from DSH's skill palette.

## Force update

By default the installer skips a skill when its installed files are
byte-identical to the packaged ones. To force an overwrite, configure the row
with `force: true`:

```yaml
- id: yumingtao-dsh-skills
  name: 'yumingtao-dsh-skills'
  config:
    force: true
```

## License

MIT

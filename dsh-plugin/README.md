# yumingtao agent skills — DSH bundles

Four standalone [DSH](https://www.dsh.so) bundles, one per skill. Each bundle
copies a single agent skill into your DSH skill discovery root on web profile
boot, so each skill can be installed (and tracked) independently.

> The previous all-in-one package `yumingtao-dsh-skills` is deprecated. Install
> the individual packages below instead.

## Packages

| npm package | Skill | What it does |
|-------------|-------|-------------|
| `yumingtao-diagram-generator` | `diagram-generator` | Generate production-quality standalone HTML/SVG technical diagrams: architecture, infrastructure, topology, deployment, data flow, trust boundary, and process maps. |
| `yumingtao-clarify-before-acting` | `clarify-before-acting` | Resolve direction-changing ambiguity before acting on complex, ambiguous, or high-cost requests. Skips trivial, mechanical, low-risk tasks. |
| `yumingtao-insight-challenge` | `insight-challenge` | Adversarial review of code-quality findings. Challenges insights with counter-evidence, verifies claims against source code, and produces structured verdicts. |
| `yumingtao-workflow-skill-designer` | `workflow-skill-designer` | Meta-skill for designing orchestrator + phases structured workflow skills with progressive phase loading, task tracking, and inter-phase data flow. |

## Install

Add any bundle to your DSH web profile:

```bash
dsh plugin --profile web add yumingtao-diagram-generator
dsh plugin --profile web add yumingtao-clarify-before-acting
dsh plugin --profile web add yumingtao-insight-challenge
dsh plugin --profile web add yumingtao-workflow-skill-designer
```

Or from the GitHub repository directly:

```bash
dsh plugin --profile web add github:yumingtao/agent-skills#path:/dsh-plugin/packages/diagram-generator
```

On first boot of the web profile each bundle copies its skill directory into
`~/.agents/skills` (the user-global skill root shared by DSH and Codex CLI).

## Force update

By default a bundle skips its skill when the installed files are byte-identical
to the packaged ones. To force an overwrite, configure the row with
`force: true`:

```yaml
- id: yumingtao-diagram-generator
  name: 'yumingtao-diagram-generator'
  config:
    force: true
```

## Maintainers: sync and publish

Each package under `packages/<skill>/skill/` is a **copy** of the canonical
source at the repo root (`skills/<skill>/`). Keep them in sync and release new
versions with `sync.sh`:

```bash
# Sync copies from canonical source (no version change)
dsh-plugin/sync.sh

# Check for drift between copies and canonical source
dsh-plugin/sync.sh --check

# Bump version (patch|minor|major|x.y.z) of all four packages and publish
dsh-plugin/sync.sh --bump patch --publish
```

The script uses `rsync` with the repo's standard exclude list (`.DS_Store`,
`node_modules/`, etc.) and supports `--dry-run` to preview changes. It operates
on all four packages; `--bump` and `--publish` loop over every package under
`packages/`.

## Layout

```
dsh-plugin/
├── packages/
│   ├── diagram-generator/
│   │   ├── package.json        # yumingtao-diagram-generator
│   │   ├── index.js            # Cordis plugin: copies skill/ -> ~/.agents/skills/
│   │   ├── cordis.patch.yml    # registers one plugin row
│   │   ├── skill/              # materialized copy of skills/diagram-generator/
│   │   ├── README.md
│   │   └── LICENSE
│   ├── clarify-before-acting/
│   ├── insight-challenge/
│   └── workflow-skill-designer/
├── sync.sh                     # sync + bump + publish all packages
└── README.md
```

## License

MIT

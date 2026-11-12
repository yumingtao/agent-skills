# yumingtao-workflow-skill-designer

A [DSH](https://www.dsh.so) bundle that installs the `workflow-skill-designer` agent skill into
your DSH skill discovery root.

Meta-skill for designing orchestrator + phases structured workflow skills with progressive phase loading, task tracking, and inter-phase data flow.

## Install

```bash
dsh plugin --profile web add yumingtao-workflow-skill-designer
```

Or from the GitHub repository directly:

```bash
dsh plugin --profile web add github:yumingtao/agent-skills#path:/dsh-plugin/packages/workflow-skill-designer
```

On first boot of the web profile the bundle copies the skill directory into
`~/.agents/skills` (the user-global skill root shared by DSH and Codex CLI).

## Force update

By default the installer skips the skill when its installed files are
byte-identical to the packaged ones. To force an overwrite, configure the row
with `force: true`:

```yaml
- id: yumingtao-workflow-skill-designer
  name: 'yumingtao-workflow-skill-designer'
  config:
    force: true
```

## License

MIT

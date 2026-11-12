# yumingtao-diagram-generator

A [DSH](https://www.dsh.so) bundle that installs the `diagram-generator` agent skill into
your DSH skill discovery root.

Generate production-quality standalone HTML/SVG technical diagrams: architecture, infrastructure, topology, deployment, data flow, trust boundary, and process maps.

## Install

```bash
dsh plugin --profile web add yumingtao-diagram-generator
```

Or from the GitHub repository directly:

```bash
dsh plugin --profile web add github:yumingtao/agent-skills#path:/dsh-plugin/packages/diagram-generator
```

On first boot of the web profile the bundle copies the skill directory into
`~/.agents/skills` (the user-global skill root shared by DSH and Codex CLI).

## Force update

By default the installer skips the skill when its installed files are
byte-identical to the packaged ones. To force an overwrite, configure the row
with `force: true`:

```yaml
- id: yumingtao-diagram-generator
  name: 'yumingtao-diagram-generator'
  config:
    force: true
```

## License

MIT

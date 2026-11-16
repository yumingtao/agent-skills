# yumingtao-defect-detective

A [DSH](https://www.dsh.so) bundle that installs the `defect-detective` agent skill into
your DSH skill discovery root.

Read-only triage for a defect signal: normalize a fingerprint, search duplicate tickets, correlate recent changes, infer the owning team, then decide whether to file a new ticket.

## Install

```bash
dsh plugin --profile web add yumingtao-defect-detective
```

Or from the GitHub repository directly:

```bash
dsh plugin --profile web add github:yumingtao/agent-skills#path:/dsh-plugin/packages/defect-detective
```

On first boot of the web profile the bundle copies the skill directory into
`~/.agents/skills` (the user-global skill root shared by DSH and Codex CLI).

## Force update

By default the installer skips the skill when its installed files are
byte-identical to the packaged ones. To force an overwrite, configure the row
with `force: true`:

```yaml
- id: yumingtao-defect-detective
  name: 'yumingtao-defect-detective'
  config:
    force: true
```

## License

MIT

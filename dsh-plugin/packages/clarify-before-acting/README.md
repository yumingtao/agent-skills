# yumingtao-clarify-before-acting

A [DSH](https://www.dsh.so) bundle that installs the `clarify-before-acting` agent skill into
your DSH skill discovery root.

Resolve direction-changing ambiguity before acting on complex, ambiguous, or high-cost requests. Skips trivial, mechanical, low-risk tasks.

## Install

```bash
dsh plugin --profile web add yumingtao-clarify-before-acting
```

Or from the GitHub repository directly:

```bash
dsh plugin --profile web add github:yumingtao/agent-skills#path:/dsh-plugin/packages/clarify-before-acting
```

On first boot of the web profile the bundle copies the skill directory into
`~/.agents/skills` (the user-global skill root shared by DSH and Codex CLI).

## Force update

By default the installer skips the skill when its installed files are
byte-identical to the packaged ones. To force an overwrite, configure the row
with `force: true`:

```yaml
- id: yumingtao-clarify-before-acting
  name: 'yumingtao-clarify-before-acting'
  config:
    force: true
```

## License

MIT

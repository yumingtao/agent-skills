# yumingtao-insight-challenge

A [DSH](https://www.dsh.so) bundle that installs the `insight-challenge` agent skill into
your DSH skill discovery root.

Adversarial review of code-quality findings. Challenges insights with counter-evidence, verifies claims against source code, and produces structured verdicts.

## Install

```bash
dsh plugin --profile web add yumingtao-insight-challenge
```

Or from the GitHub repository directly:

```bash
dsh plugin --profile web add github:yumingtao/agent-skills#path:/dsh-plugin/packages/insight-challenge
```

On first boot of the web profile the bundle copies the skill directory into
`~/.agents/skills` (the user-global skill root shared by DSH and Codex CLI).

## Force update

By default the installer skips the skill when its installed files are
byte-identical to the packaged ones. To force an overwrite, configure the row
with `force: true`:

```yaml
- id: yumingtao-insight-challenge
  name: 'yumingtao-insight-challenge'
  config:
    force: true
```

## License

MIT

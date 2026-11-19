# yumingtao-skill-maintainer

A [DSH](https://www.dsh.so) bundle that installs the `skill-maintainer` agent skill into
your DSH skill discovery root.

Edits an existing skill. It does not score one. Scoring belongs to SkillHub's official skillhub-trace-evaluator. Default is one gap and a confirmation.

## Install

```bash
dsh plugin --profile web add yumingtao-skill-maintainer
```

Or from the GitHub repository directly:

```bash
dsh plugin --profile web add github:yumingtao/agent-skills#path:/dsh-plugin/packages/skill-maintainer
```

On first boot of the web profile the bundle copies the skill directory into
`~/.agents/skills` (the user-global skill root shared by DSH and Codex CLI).

## Force update

By default the installer skips the skill when its installed files are
byte-identical to the packaged ones. To force an overwrite, configure the row
with `force: true`:

```yaml
- id: yumingtao-skill-maintainer
  name: 'yumingtao-skill-maintainer'
  config:
    force: true
```

## License

MIT

# yumingtao-session-retrospective

A [DSH](https://www.dsh.so) bundle that installs the `session-retrospective` agent skill into
your DSH skill discovery root.

End-of-session retro that logs workflow issues as structured JSONL signals; recurrence escalates priority, and one phrase enters fix mode to close the loop.

## Install

```bash
dsh plugin --profile web add yumingtao-session-retrospective
```

Or from the GitHub repository directly:

```bash
dsh plugin --profile web add github:yumingtao/agent-skills#path:/dsh-plugin/packages/session-retrospective
```

On first boot of the web profile the bundle copies the skill directory into
`~/.agents/skills` (the user-global skill root shared by DSH and Codex CLI).

## Force update

By default the installer skips the skill when its installed files are
byte-identical to the packaged ones. To force an overwrite, configure the row
with `force: true`:

```yaml
- id: yumingtao-session-retrospective
  name: 'yumingtao-session-retrospective'
  config:
    force: true
```

## License

MIT

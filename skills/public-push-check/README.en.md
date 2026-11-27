# Public Push Check

Checks the commits about to be pushed to a public remote against a fixed list. A pass means those items passed. It is not a safety certification. A `git push` typed in a terminal does not run it. The behavior rules are in [`SKILL.en.md`](SKILL.en.md). The author and the committer must be the person on the repository allowlist. An agent, bot, or model in an identity field fails. This skill's version is `1.0.1`.

Marked `internal`: omitted from default skills.sh CLI discovery, and not published to SkillHub, DSH, ClawHub, or npm. The website listing may lag.

## Where this skill sits

On its own, it checks the range about to be pushed from the current repository. It does not require the other skills in this repo.

It is not a station on the engineering loop. Use it before a push to a public remote. When work on the loop is ready to push, run this list first.

The full loop is in the collection README, [Use one, or run them as a loop](../../README.md#alone-or-together).

## Documentation Guide

| Want to know | Read |
|---|---|
| Iron laws, procedure, when a push may proceed | [SKILL.en.md](SKILL.en.md) |
| The nine judgments and the report format | [references/checklist.en.md](references/checklist.en.md) |

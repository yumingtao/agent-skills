---
name: skill-maintainer
slug: yumingtao-skill-maintainer
displayName: Skill Maintainer
version: 1.0.3
summary: Edits an existing skill. It does not score one. Scoring belongs to SkillHub's skillhub-trace-evaluator. Default is one gap and a confirmation.
license: MIT
tags:
  - developer tools
  - skill maintenance
  - workflow
disable-model-invocation: true
description: >
  Edits a skill that already exists. It does not score one. Scoring belongs to SkillHub's official skillhub-trace-evaluator. Self-check uses only that skill's public TRACE bands (trust.scan is not scored). Any directory with SKILL.md can be maintained. A signal may come from a TRACE pass, one version's evaluation comments, a recurring session-retrospective entry, or a zh/en and install-tree structure check. By default, propose one gap and do not write before confirmation. "自动补到阈值" edits one sub-item per round until each scored sub-item meets the threshold, default 4.8, for at most 5 rounds, and stops on items that documents cannot raise. This repo's sync scripts run only when the target is under skills/ and the scripts are present. They do not publish. Triggers on "维护这个技能", "按 TRACE 过一遍", "按评测改技能", "自动补到阈值", "skill maintainer".
---

# Skill Maintainer

This skill edits a skill that already exists. It does not score one. Scoring belongs to SkillHub's official `skillhub-trace-evaluator`. It finds one gap with the public bands, writes a proposal, and edits files only after confirmation.

This skill's version is `1.0.3`. The version line inside a proposal belongs to the **target skill**, not to this skill.

## Iron laws

1. **Self-check uses only the public TRACE bands.** The bands are in [`references/trace-items.en.md`](references/trace-items.en.md). `trust.scan` is not scored. This skill does not carry Keen Lab or YunDing Lab detection rules.
2. **No signal, no rule change.** A signal comes from a TRACE pass, an evaluation comment, a recurring retro entry, or a structure check. An item that matches none of the 15 sub-items and none of the repo invariants is deferred.
3. **One gap at a time.** Every other gap goes under "Not in this change".
4. **By default, do not write before confirmation.** When behavior changes, bump the target skill's `version` patch in both languages together. A README-navigation-only edit does not bump that skill. Only "自动补到阈值" writes across rounds, still one item per round.

## When to use

- "维护这个技能", "按 TRACE 过一遍", "按评测改技能", "自动补到阈值", "skill maintainer"
- You have an evaluation comment, a retro entry, or a zh/en mismatch
- Example: "维护 example-skill，先给提案。" Do not edit before confirmation. After the caller says "确认", edit only the item in the proposal.

## When not to use

- Designing a new skill from scratch → `workflow-skill-designer`
- Logging this session → `session-retrospective`
- Asked to rerun a security scan locally → stop and say `trust.scan` is out of scope (SM-E05)

## Procedure

1. **Name the target skill.** If it is unclear, ask one question: which skill? Any directory with `SKILL.md` qualifies. It does not have to live in this repo.
2. **Read the signal you were given.** Do not wait until all four source types are present:
   - "按 TRACE 过一遍": read `SKILL.md` and the references it names against the bands. A sub-item below the 4-point band is a gap.
   - An evaluation comment or API result: map the named sentence onto one sub-item. If the API cannot be read, use the pasted report and say so in the proposal (SM-E08).
   - A retro log: default `metrics/workflow-feedback.jsonl`. Use only a recurring gap on the same skill.
   - A structure check: zh/en `version`, `tags` count, and whether the English install tree contains scripts the README names.
3. **Keep one gap.** Priority: a security comment that names an item → an evaluation comment → a recurring retro entry → a TRACE pass → a structure mismatch. A security comment contributes only the sentence it names. Do not add lab rules from it.
4. **Write the proposal and stop.** Template: [`references/proposal-template.en.md`](references/proposal-template.en.md).
5. **Write only after confirmation.** Edit the matching Chinese and English passages together. The main path ends there. Only when the target is under this repo's `skills/<name>/` and the scripts are beside it, optionally run `sync/check.sh --collection-only`, then run `dsh-plugin/sync.sh` without `--publish` if that script exists too. When the scripts are absent, or the target is elsewhere, skip them and say so under "Not in this change". If a script fails, fix the reported error and run it once more. A second failure stops the run and is not recorded as a pass. Do not publish to SkillHub and do not run `npm publish`.

Priority, the threshold loop, and deferral: [`references/signal-rules.en.md`](references/signal-rules.en.md).

## Raise to a threshold

The entry is "自动补到阈值". Without that phrase, use the proposal and confirmation above.

- The threshold applies to each scored sub-item, default `4.8`. The caller may set another number in `(0, 5.0]`. Do not use the five-dimension average.
- `trust.scan` is not in the loop.
- Each round scores the sub-items with the same bands, edits one item that is below the threshold and that a document change can raise, edits both languages, then scores again with the same bands.
- Stop when every scored sub-item meets the threshold, when the remaining low items need a real run, or when 5 rounds are done.
- On stop, list the sub-items still below the threshold and why. Do not write an unrun result as verified (SM-E09).

## Repo invariants

A gap may land on one of these instead of a TRACE sub-item:

- Same patch in both languages: a behavior change in `SKILL.md` has a matching change in `SKILL.en.md`, and the version moves with both
- One source of truth: platform copies sync from `skills/<name>/`
- A read-only skill stays read-only
- Logs do not store secrets

## Exceptions

| Code | Situation | What to do |
|---|---|---|
| SM-E01 | No target skill | Ask one question. Do not start the pass |
| SM-E02 | The gap matches no sub-item and no repo invariant | Defer it. Do not write |
| SM-E03 | Several gaps arrive at once | Keep the highest-priority one. List the rest under "Not in this change" |
| SM-E04 | Only the Chinese file changed | Stop. Add the English passage and the version first |
| SM-E05 | Asked to run a local security scan | Say `trust.scan` is not scored. Do not invent a scan score |
| SM-E06 | The request is for a new skill | Hand off to `workflow-skill-designer` |
| SM-E07 | The request is to log this session | Hand off to `session-retrospective` |
| SM-E08 | The evaluation API cannot be read | Use the pasted report. Say the API was not read. Do not retry a scan |
| SM-E09 | The threshold loop stops with sub-items still below the bar | List the sub-items and why, then stop. Do not mark them as passed |

## The target skill's version

The version in the proposal belongs to the target skill. Behavior change: add one to the patch number in both frontmatters. README navigation only: write "no version bump". A minor or major bump happens only when confirmation says so.

This skill's own `version` stays at its current value unless the target of this run is `skill-maintainer` itself.

## FAQ

**Q: Does the threshold use the five-dimension average?**
A: No. Each scored sub-item is compared with the threshold, default 4.8.

**Q: Will the loop edit until everything is 5?**
A: No. It stops at 5 rounds, or when every remaining low item needs a real run, and it lists what is still below the threshold.

**Q: Does a normal request edit files immediately?**
A: No. Only "自动补到阈值" writes across rounds. Every other entry starts with a proposal.

**Q: Does this skill score a skill?**
A: No. Scoring belongs to SkillHub's official `skillhub-trace-evaluator`. This skill only edits.

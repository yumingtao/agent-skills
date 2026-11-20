---
name: skill-maintainer
slug: yumingtao-skill-maintainer
displayName: Skill Maintainer
version: 1.0.6
summary: Edits an existing skill. It does not score one. Default is one gap and a confirmation.
license: MIT
tags:
  - developer tools
  - skill maintenance
  - workflow
disable-model-invocation: true
description: >
  Edits a skill that already exists. It does not score one. Self-check uses only the scoring bands shipped with this skill (trust.scan is not scored). Any directory with SKILL.md can be maintained. A signal may come from a pass over those bands, one version's evaluation comments, a recurring session-retrospective entry, or a zh/en and install-tree structure check. By default, propose one gap and do not write before confirmation. "自动补到阈值" edits one item per round, and stops to list items a document change cannot raise. This repo's sync scripts run only when the target is under skills/ and the scripts are present. They do not publish. Triggers on "维护这个技能", "按 TRACE 过一遍", "按评测改技能", "自动补到阈值", "skill maintainer".
---

# Skill Maintainer

This skill edits a skill that already exists. It does not score one. It finds one gap with the bundled scoring bands, writes a proposal, and edits files only after confirmation.

This skill's version is `1.0.6`. The version line inside a proposal belongs to the **target skill**, not to this skill.

## Iron laws

1. **Self-check uses only the bundled scoring bands.** The bands are in [`references/trace-items.en.md`](references/trace-items.en.md). `trust.scan` is not scored. This skill does not carry Keen Lab or YunDing Lab detection rules. A local self-check writes two lines: the document band, and whether a real run backs it. Without the second line, do not claim the threshold is met. When a platform sub-item score exists, trust that score.
2. **No signal, no rule change.** A signal comes from a TRACE pass, an evaluation comment, a recurring retro entry, or a structure check. An item that matches none of the 15 sub-items and none of the repo invariants is deferred.
3. **One gap at a time.** Every other gap goes under "Not in this change".
4. **By default, do not write before confirmation.** When behavior changes, bump the target skill's `version` patch in both languages together. A README-navigation-only edit, or a reference-only edit with no behavior change, does not bump that skill. Only "自动补到阈值" writes across rounds, still one item per round.
5. **A gap already fully in the target is left as it is.** When the target files already contain **all** of the text that gap asks for, do not propose it and do not write it. When only part of that text is present, it is still a gap (SM-E17). Running again only reports that a complete item is already there. This skill makes no network call and sets no timeout.

## When to use

- "维护这个技能", "按 TRACE 过一遍", "按评测改技能", "自动补到阈值", "skill maintainer"
- You have an evaluation comment, a retro entry, or a zh/en mismatch
- Example: "维护 example-skill，先给提案。" Do not edit before confirmation. After the caller says "确认", edit only the item in the proposal.

## When not to use

- Designing a new skill from scratch → `workflow-skill-designer`
- Logging this session → `session-retrospective`
- Asked to rerun a security scan locally → stop and say `trust.scan` is out of scope (SM-E05)

## Procedure

1. **Name the target skill.** If it is unclear, ask one question: which skill? Any directory with `SKILL.md` qualifies. It does not have to live in this repo. If the target directory was moved or `SKILL.md` is gone, stop and ask once for the new path (SM-E16).
2. **Read the signal you were given.** Do not wait until all four source types are present. Minimum fields for external material and the one-conclusion rules for uncommon combinations are in [`references/signal-rules.en.md`](references/signal-rules.en.md).
   - "按 TRACE 过一遍": read `SKILL.md` and the references it names against the bands. A sub-item that is not yet reliable to use is a gap. What counts as reliable is defined in the bands file.
   - An evaluation comment or API result: map the named sentence onto one sub-item. A pasted report needs at least the sub-item name and score; if a field is missing, ask once (SM-E14). If the API cannot be read, use the pasted report and say so in the proposal (SM-E08).
   - A retro log: default `metrics/workflow-feedback.jsonl`. One line needs at least the skill name and the gap; if a field is missing, ask once (SM-E14). Use only a recurring gap on the same skill.
   - A structure check: zh/en `version`, `tags` count, and whether the English install tree contains scripts the README names.
3. **Keep one gap.** Priority: a security comment that names an item → an evaluation comment → a recurring retro entry → a TRACE pass → a structure mismatch. A security comment contributes only the sentence it names. Do not add lab rules from it. If the target already contains **all** of the text that gap asks for, skip it, report that it is already there (SM-E10), and take the next gap. If only part of that text is present, keep this gap (SM-E17). If every gap is already complete, stop and do not write.
4. **Write the proposal and stop.** Template: [`references/proposal-template.en.md`](references/proposal-template.en.md).
5. **Write only after confirmation.** When both language files exist, edit the matching passages together. When only one language file exists, edit that file, do not create the other language, and name the file that is absent (SM-E11). If a write fails midway: leave what was already edited, do not continue the unfinished parts, and report where it stopped (SM-E15). When both languages exist but only one was edited, follow SM-E04: finish the other language and the version first, and do not open an unrelated gap. The main path ends there. Only when the target is under this repo's `skills/<name>/` and the scripts are beside it, optionally run `sync/check.sh --collection-only`, then run `dsh-plugin/sync.sh` without `--publish` if that script exists too. When the scripts are absent, or the target is elsewhere, skip them and say so under "Not in this change". If a script fails, fix the reported error and run it once more. A second failure stops the run and is not recorded as a pass; start a new run after the error is fixed (SM-E12). Do not publish to SkillHub and do not run `npm publish`.

Priority, threshold conversion, external-material fields, uncommon combinations, and deferral: [`references/signal-rules.en.md`](references/signal-rules.en.md).

## Raise to a threshold

The entry is "自动补到阈值". Without that phrase, use the proposal and confirmation above.

- Each round edits one sub-item a document change can raise. When both language files exist, edit both. When only one exists, follow SM-E11. Then compare again with the conversion in signal-rules.
- `trust.scan` is not in the loop.
- The threshold, the conversion, the allowed range, and the stop conditions are in [`references/signal-rules.en.md`](references/signal-rules.en.md). A number outside that range does not start the loop. Ask once (SM-E13).
- On stop, list the sub-items that still fall short and why. Do not write an unrun result as verified (SM-E09).

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
| SM-E04 | Both language files exist, but only one was edited | Stop. Add the other language and the version first |
| SM-E05 | Asked to run a local security scan | Say `trust.scan` is not scored. Do not invent a scan score |
| SM-E06 | The request is for a new skill | Hand off to `workflow-skill-designer` |
| SM-E07 | The request is to log this session | Hand off to `session-retrospective` |
| SM-E08 | The evaluation API cannot be read | Use the pasted report. Say the API was not read. Do not retry a scan |
| SM-E09 | The threshold loop stops with sub-items still below the bar | List the sub-items and why, then stop. Do not mark them as passed |
| SM-E10 | The target already contains all of the text the gap asks for | Report that it is already there. Do not propose it and do not write it. Take the next gap if one remains |
| SM-E11 | The target has only one language file | Edit the file that exists. Do not create the missing language. Name the file that is absent |
| SM-E12 | A sync script fails a second time | Stop and report the error. Do not record the failure as a pass. Start a new run after the error is fixed |
| SM-E13 | The given threshold is outside the range in signal-rules | Do not start the loop. Ask once. Do not replace the out-of-range number with the default |
| SM-E14 | A retro line or pasted report is missing a required field | Ask once. Do not start the pass |
| SM-E15 | A confirmed write fails midway | Leave what was already edited. Do not continue the unfinished parts. Report where it stopped |
| SM-E16 | The target directory was moved or `SKILL.md` is gone | Stop. Ask once for the new path |
| SM-E17 | The target has only part of the text the gap asks for | It is still a gap. Fill the missing part. Do not skip it |

## The target skill's version

The version in the proposal belongs to the target skill. Behavior change: add one to the patch number in both frontmatters. README navigation only, or a reference-only edit with no behavior change: write "no version bump". A minor or major bump happens only when confirmation says so.

This skill's own `version` stays at its current value unless the target of this run is `skill-maintainer` itself.

## FAQ

**Q: Does the threshold use an average across items?**
A: No. Each scored sub-item is compared with the threshold on its own. The conversion is in [`references/signal-rules.en.md`](references/signal-rules.en.md).

**Q: If a local band pass reaches 5, has the threshold been met?**
A: When a platform sub-item score exists, trust that score. When it does not, score with the conversion in signal-rules. A local self-check still states whether a real run backs it.

**Q: Can a local self-check score stand in for a SkillHub score?**
A: No. Locally, report the document band and whether a real run backs it. Do not report that a platform threshold has already been met.

**Q: Will the loop keep editing without a stop?**
A: No. It stops when a stop condition in signal-rules is met, and it lists the sub-items that still fall short.

**Q: Does a normal request edit files immediately?**
A: No. Only "自动补到阈值" writes across rounds. Every other entry starts with a proposal.

**Q: Does this skill score a skill?**
A: No. This skill only edits. It does not produce a score.

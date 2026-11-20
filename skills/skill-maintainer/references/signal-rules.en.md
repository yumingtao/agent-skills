# Signal rules

Any one of the four signals can open a maintenance item: a TRACE pass, an evaluation comment, a recurring retro entry, or a structure check. A retro log is not required first. A named security comment is a kind of evaluation comment, and it ranks first.

| Order | Signal | It counts when |
|---|---|---|
| 1 | A named security comment | A platform report names one sentence. Use that sentence only. Do not copy lab rules into the skill |
| 2 | An evaluation comment | One version's comment names a phenomenon and it maps to one TRACE sub-item |
| 3 | A recurring retro entry | The same skill and the same gap appear again in `metrics/workflow-feedback.jsonl` |
| 4 | A TRACE pass | On "按 TRACE 过一遍", a sub-item is not yet reliable to use in the bands. What counts as reliable is defined in [`trace-items.en.md`](trace-items.en.md) |
| 5 | A structure check | zh/en `version` differs, `tags` counts differ, or the English install tree lacks a script the README names |

Propose only the highest item. Put the rest under "Not in this change".

## Minimum fields for external material

- One retro log line: at least the skill name and the gap. If a field is missing, ask once and do not start the pass (SM-E14).
- A pasted evaluation report: at least the sub-item name and that sub-item's score. If a field is missing, ask once and do not start the pass (SM-E14).
- When the API can be read, use the sub-item scores from it. When it cannot, use the pasted report and say so in the proposal (SM-E08).

## Uncommon combinations (one conclusion each)

- Two or more signals arrive together: keep only the highest item in the table above. Put the rest under "Not in this change" (SM-E03).
- The target already has only part of the text the gap asks for: it is still a gap. Fill the missing part. Do not skip it because a half sentence is present (SM-E17).
- Only a reference file changes and behavior passages do not: write "no version bump" on the version line.
- A local band pass reaches the 5-band while the platform score for the same sub-item is lower: trust the platform score. A document pass is only a gap candidate. It does not override the platform score.

## Raise to a threshold

Enter only when the caller says "自动补到阈值". Each round still changes one item, then compares again.

- The threshold is the minimum for each scored sub-item, default `4.8`, or another number in `(0, 5.0]`. Do not use the five-dimension average. A number outside that range does not start the loop. Ask once (SM-E13). Do not replace an out-of-range number with the default.
- `trust.scan` stays out of the loop.
- **How to get the score used for comparison (conversion)**:
  1. The sub-item already has a platform score (API or pasted report) → compare that score with the threshold. Local bands do not override it.
  2. There is no platform score → a body that meets the sub-item's 5-band counts as `5.0`; a body that only meets the 4-band counts as `4.0`; a lower band counts as `N.0` for that integer band.
  3. A sub-item that needs a real run to rise → keep the current comparison score. It does not enter "met", and the loop does not rewrite it as passed.
- A local self-check writes two lines: the document band, and whether a real run backs it. Without the second line, do not claim the threshold is met.
- Pick a sub-item a document edit can raise, such as a missing case, a recovery step, or an error code.
- Stop when every scored sub-item's comparison score meets the threshold, when every remaining low item needs a real run, or after 5 rounds.
- On stop, list the sub-items still below the threshold and why (SM-E09).

## Defer

- An item that appears only on a third-party TRACE list and matches none of these 15 sub-items
- A sub-item that is not yet reliable to use, when this run is not a TRACE pass and no comment or retro entry names it
- A request to perform `trust.scan` locally

## Any directory

A directory with `SKILL.md` is enough. That is the main path.

Sync in this repo is optional. Run it only when the target is under `skills/<name>/` and the scripts are beside it:

- `sync/check.sh --collection-only`
- `dsh-plugin/sync.sh`, without `--publish`

When the scripts are absent, or the target is elsewhere, skip them and say in "Not in this change" that repo sync was not run.

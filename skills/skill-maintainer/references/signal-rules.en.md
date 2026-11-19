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

## Raise to a threshold

Enter only when the caller says "自动补到阈值". Each round still changes one item, then scores again with the same bands.

- The threshold is the minimum for each scored sub-item, default `4.8`, or another number in `(0, 5.0]`. Do not use the five-dimension average.
- `trust.scan` stays out of the loop.
- Pick a sub-item a document edit can raise, such as a missing case, a recovery step, or an error code. A sub-item that needs a real run is not rewritten as passed.
- Stop when every scored sub-item meets the threshold, when every remaining low item needs a real run, or after 5 rounds.
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

# Proposal template

By default, output only this block before confirmation and do not edit files. "自动补到阈值" is the exception: that entry writes one item per round. The version line belongs to the target skill. This skill's own version is not on that line unless the target is `skill-maintainer`.

```text
Target skill:
Gap:
Signal: TRACE pass | evaluation comment | retro | structure check
Sub-item: for example convention.docQuality; a structure gap is "same patch in both languages"
Band missed:
This change:
Not in this change:
Version: target skill x.y.z → x.y.(z+1), both languages; or "no version bump"
Do not write before confirmation.
```

## Filled example

The target is `clarify-before-acting`. The comment says the Chinese and English versions differ. This change aligns the version number and does not change behavior.

```text
Target skill: clarify-before-acting
Gap: the English frontmatter version is behind the Chinese one
Signal: structure check
Sub-item: same patch in both languages
Band missed: the repo invariant says behavior and version move together; behavior already matches, and only the version number differs
This change: set version in SKILL.en.md to the same value as SKILL.md
Not in this change: other sub-items below the 4-point band that nothing named
Version: set the English patch number equal to the Chinese one; do not add another patch for the alignment itself
Do not write before confirmation.
```

## Two more filled examples

A TRACE pass. The target `SKILL.md` states no misuse, so `antiPatternFaq` sits on the 1-point band.

```text
Target skill: example-skill
Gap: it never states what not to do
Signal: TRACE pass
Sub-item: convention.antiPatternFaq
Band missed: 1 means no anti-pattern guidance; 4 requires the main misuses
This change: add a "When not to use" section to SKILL.md and SKILL.en.md with two misuses
Not in this change: sub-items already at 4.8 or above
Version: 1.2.0 → 1.2.1, both languages
Do not write before confirmation.
```

A recurring retro entry. The log shows the same skill twice turning a read-only procedure into file edits.

```text
Target skill: example-skill
Gap: the read-only statement does not stop writes
Signal: retro
Sub-item: repo invariant "a read-only skill stays read-only"
Band missed: the same skill and the same gap recurred
This change: state that read-only steps must not create, edit, or commit files, and add an exception code
Not in this change: other sub-items that did not recur in the log
Version: 1.2.1 → 1.2.2, both languages
Do not write before confirmation.
```

## One run that already happened

The target was the temporary skill `note-stub` at `tmp/skill-maintainer-fixture/note-stub/`. Nothing was edited before confirmation. After confirmation, only the English `version` changed from `1.0.0` to `1.0.1`. That run still executed `dsh-plugin/sync.sh` under the old rule. The script refreshed collection packages and did not check `note-stub`. From `1.0.2` on, a target outside `skills/` does not run that step.

```text
Target skill: note-stub
Gap: the English frontmatter version lagged the Chinese one
Signal: structure check
Sub-item: same patch in both languages
Band missed: behavior and version move together; the behavior already matched and only the version differed
This change: set SKILL.en.md version to 1.0.1
Not in this change: unnamed anti-pattern and example gaps. The target stays in tmp/, is not added to the README, and is not published
Version: set the English version to 1.0.1; do not add another patch for the alignment
Do not write before confirmation.
```

Result of that confirmation: both `version` fields were `1.0.1`, and the behavior text was not edited. A later edit added the anti-patterns, FAQ, and examples, and both languages moved to `1.0.2`.

## Three more paths that already ran

The target was still `note-stub`. It is not under `skills/`, so none of these runs used repo sync. The caller had asked to continue, so confirmation was already given and the run did not stop again.

TRACE pass. An empty note had no error code, so `errorHandling` sat on the 1-point band. The only edit added NS-E01. Version `1.0.2` → `1.0.3`.

Recurring retro. Two lines in `metrics/workflow-feedback.jsonl` named the same gap: no trigger phrase. The second line says `recurring(第2次)`. `validate-feedback.mjs` passed. The only edit added the trigger phrases. Version `1.0.3` → `1.0.4`.

Raise to a threshold. The threshold was 4.8, one item per round, for 5 rounds: same input stays the same, one note at a time, a contents list, an empty-note example, and an empty-note FAQ. The version ended at `1.0.9`. On stop, `creativity` was still 3: the skill has no judgment outside the bands, and more wording would not make that item pass (SM-E09).

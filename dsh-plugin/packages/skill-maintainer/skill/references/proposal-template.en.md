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
Not in this change: other sub-items that are not yet reliable to use and that nothing named
Version: set the English patch number equal to the Chinese one; do not add another patch for the alignment itself
Do not write before confirmation.
```

## Two more filled examples

A pass over the bands. The target `SKILL.md` never states what not to do, so that sub-item is not yet reliable to use.

```text
Target skill: example-skill
Gap: it never states what not to do
Signal: TRACE pass
Sub-item: convention.antiPatternFaq
Band missed: the bands say a skill that never states what not to do is not yet reliable to use
This change: add a "When not to use" section to SKILL.md and SKILL.en.md with two misuses
Not in this change: the other sub-items left for another pass
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

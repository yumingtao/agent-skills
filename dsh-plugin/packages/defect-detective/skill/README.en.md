# Defect Detective

Read-only triage before a bug fix: normalize a fingerprint, search for duplicate tickets across stacks, correlate recent changes when the implicated layer is known, infer the owning team, and return a ticket draft ready to paste. The behavior rules are in [`SKILL.en.md`](SKILL.en.md).

## Where this skill sits

On its own, it finishes the read-only triage and returns a ticket draft. This skill is an execution station.

When the environment, the reproduction path, or the version is missing, fill the gap with [clarify-before-acting](../clarify-before-acting/). A new ticket goes to your own write path, and the fix goes to the implementation flow. A mis-triage goes to [session-retrospective](../session-retrospective/). Turning this pipeline into a skill goes to [workflow-skill-designer](../workflow-skill-designer/). The "Recommended Companions" section in `SKILL.en.md` is the operating note for the agent.

The full loop is in the collection README, [Use one, or run them as a loop](../../README.md#alone-or-together).

## Documentation Guide

| Want to know | Read |
|---|---|
| Triage flow, output format, and guardrails | [SKILL.en.md](SKILL.en.md) |
| Three worked triage examples | [references/triage-examples.en.md](references/triage-examples.en.md) |
| Smoke record against a real tracker | [references/verification-record.en.md](references/verification-record.en.md) |
| Where this skill sits in the collection | This file |

# Session Retrospective

At session end, write the systemic workflow issues that actually happened as enum-checked JSONL. A recurring issue rises in priority. After "start fixing", confirm and write back one item at a time, ordered by recurrence and priority. The behavior rules are in [`SKILL.en.md`](SKILL.en.md).

## Where this skill sits

On its own, it writes this session to JSONL and can enter Fix Mode. It closes this engineering loop.

A working session of any skill above can be logged. A recurring process gap goes to [workflow-skill-designer](../workflow-skill-designer/). A rule gap goes back to the skill it belongs to.

The full loop is in the collection README, [Use one, or run them as a loop](../../README.md#alone-or-together).

## Documentation Guide

| Want to know | Read |
|---|---|
| Review rules, field enums, and Fix Mode | [SKILL.en.md](SKILL.en.md) |
| One complete log example | [references/retrospective-example.en.md](references/retrospective-example.en.md) |
| Log validation | `node scripts/validate-feedback.mjs <log.jsonl>` |
| Where this skill sits in the collection | This file |

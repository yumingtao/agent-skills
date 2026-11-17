# Workflow Skill Designer

Design a workflow skill in the orchestrator + phases pattern: a thin `SKILL.md` coordinates, and the execution detail lives in `phases/` files loaded when that phase runs. The behavior rules are in [`SKILL.en.md`](SKILL.en.md).

## Where this skill sits

On its own, it produces an orchestrator + phases skill package. It is the meta-skill, and it stands outside the engineering loop.

A process gap that keeps recurring in [`session-retrospective`](../session-retrospective/) is the typical input. The generated skill runs its own phases.

The full loop is in the collection README, [Use one, or run them as a loop](../../README.md#alone-or-together).

## Documentation Guide

| Want to know | Read |
|---|---|
| Orchestrator template and design patterns | [SKILL.en.md](SKILL.en.md) |
| The four phase files | [phases/](phases/) |
| Where this skill sits in the collection | This file |

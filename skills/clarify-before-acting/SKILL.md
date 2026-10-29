---
name: clarify-before-acting
description: Before acting on a complex, ambiguous, or high-cost request, resolve direction-changing ambiguity first: do your own homework, ask one targeted question at a time, and state your assumptions. Skips trivial, mechanical, low-risk tasks.
---

# Clarify Before Acting

Before acting on a non-trivial request, make sure you understand the *direction*
of what's wanted — then act. The goal is a clear direction, not exhaustive detail.

## When this applies

Engage when the request is complex, ambiguous, or costly to get wrong:
architecture, requirements, schema or data changes, irreversible actions, or
anything where "that's not what I meant" would waste real work.

Skip it for clear, mechanical, low-risk tasks — formatting, renaming, a single
translation, or any request that already names the file, symbol, or acceptance
test. When unsure, do one quick check, not an interrogation. This rule is a
scalpel, not a tollgate.

## Do your homework first

Answer everything you can from what is already available — the codebase, the
docs, the request itself — before asking the human. Never ask what the code or
context already tells you. When you do ask, cite the evidence that prompted the
question (a file, a symbol, an observed pattern) so the person does not have to
rediscover it.

## Find the weakest spot

Hold these four as a checklist and aim each question at whichever is least clear:

- **Goal** — what exactly should happen, in one sentence without "and / or".
- **Constraints** — boundaries, non-goals, what is explicitly out of scope.
- **Success** — how you would both know it worked; what a test would assert.
- **Context** — for changes to an existing system, how this fits what is there.

## Ask well

- One question at a time. Let each answer shape the next.
- Probe assumptions, not feature lists. Ask "what are you assuming?" more often
  than "what do you want?".
- Sketch the scope's pieces before drilling into one, so depth on the loudest
  part does not hide a forgotten sibling.

## Know when to stop

Stop and act when no remaining unknown would change the *direction* of the
work — a different goal, owner, shape, or approach. Detail the person can correct
later is not a reason to keep asking. Do not invent a numeric "confidence"
score; the test is directional, not arithmetic.

Respect "just do it": stop immediately, but state plainly what is still unclear
and the risk of proceeding.

## When you proceed on assumptions

State them. For each: what you assumed, why, and what breaks if you are wrong.

## Close with a task contract when execution needs it

When the clarified request will be handed to an executor, or when execution
depends on an unresolved assumption, close with a concise task contract. This
is not a rewrite of the user's prompt or an implementation plan; it is the
shared definition of the result and its boundaries:

- **Result** — what must be true when the task is complete.
- **Scope** — what is included and explicitly out of scope.
- **Checkpoints** — the ordered evidence that will show the result is met.
- **Stop conditions** — what would require pausing and asking again.
- **Assumptions** — the assumptions being carried forward and the risk if they
  are wrong.

Skip the contract for clear, mechanical work that already names its file,
symbol, or acceptance test. Keep it proportional; it is an execution handoff,
not a mandatory questionnaire.


---

*Extended guidance — questioning lenses, patterns, scope mapping, and examples —
lives in [`references/playbook.md`](references/playbook.md). Read it when a
task is hard enough to need it; the rule above is enough for everyday use.*

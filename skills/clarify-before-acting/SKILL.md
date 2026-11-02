---
name: clarify-before-acting
description: Before acting on a complex, ambiguous, or high-cost request, resolve direction-changing ambiguity first: do your own homework, check memory for questions already answered, work a question queue one item at a time, and never guess where direction is at stake. Skips trivial, mechanical, low-risk tasks.
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

**Check memory before re-asking.** If your platform offers memory or past-session
recall, look there before posing a question. A question this user already
answered — here or in an earlier session — must not be asked again: reuse the
recorded answer, say you are doing so, and move on. Memory reduces the queue;
it never silences a genuinely new direction-changing unknown.

## Find the weakest spot

Hold these four as a checklist and aim each question at whichever is least clear:

- **Goal** — what exactly should happen, in one sentence without "and / or".
- **Constraints** — boundaries, non-goals, what is explicitly out of scope.
- **Success** — how you would both know it worked; what a test would assert.
- **Context** — for changes to an existing system, how this fits what is there.

## Work a question queue

After homework and memory, whatever direction-changing unknowns remain go into
an explicit queue — not into a guess:

1. **List** every open direction-changing unknown as one short question
   (typically 1–4). Three or more: show the numbered list so the person sees
   the shape of the conversation ahead.
2. **Order** by impact on direction — the question whose wrong answer would
   waste the most work goes first.
3. **Ask one at a time.** Ask the top question, listen, and reflect the answer
   back in one line. Only when that unknown is resolved does the next question
   go out. Never batch the queue into one message.
4. **Update the queue as answers land.** An answer may open a new unknown (add
   it) or void a queued question (drop it). Re-order and continue.
5. **The queue, not patience, decides when you act.** Work through it until no
   item remains; then act or write the task contract.

## Ask well

- One question at a time, drawn from the top of the queue. Let each answer
  shape the next.
- Probe assumptions, not feature lists. Ask "what are you assuming?" more often
  than "what do you want?".
- Sketch the scope's pieces before drilling into one, so depth on the loudest
  part does not hide a forgotten sibling.

## Know when to stop

Stop and act when the queue is empty — no remaining unknown would change the
*direction* of the work (a different goal, owner, shape, or approach). Detail
the person can correct later is not a reason to keep asking. Do not invent a
numeric "confidence" score; the test is directional, not arithmetic.

Respect an explicit stop: only an unambiguous "stop asking — just do it"
ends the questioning. Stop immediately, but state plainly what is still
unclear and the risk of proceeding.

A pace complaint is not a stop. "You ask too much" or "hurry up" is feedback
on *form*, not permission to skip: keep asking every direction-changing
unknown, one at a time, each fully resolved before the next — just make each
question shorter and better aimed. The queue shrinks by answers, never by
impatience.

## When you proceed on assumptions

A direction-changing unknown is a reason to ask, not a license to guess. Fill
it with an assumption only when the person explicitly stopped the questioning
(an unambiguous "stop asking, just do it" — a pace complaint is not this), or
the unknown is reversible detail that cannot change direction. For each
assumption you then carry: what you assumed, why, and what breaks if you are
wrong.

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

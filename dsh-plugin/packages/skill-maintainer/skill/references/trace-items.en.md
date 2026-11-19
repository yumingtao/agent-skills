# TRACE self-check bands

This file is a rewrite of the public scoring references in SkillHub's official skill `skillhub-trace-evaluator`, not the original text. The rewrite keeps the 1–5 bands a maintainer needs. The originals are at <https://github.com/Tencent/skillhub/tree/main/skills/skillhub-trace-evaluator/references>.

The copyright notice and MIT permission text below are kept from that repository:

```text
Tencent is pleased to support the open source community by making skillhub available.

Copyright (C) 2026 Tencent. All rights reserved.

skillhub is licensed under MIT. skillhub does not impose any additional restrictions beyond those specified in the license.

Terms of the MIT License:
--------------------------------------------------------------------
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice (including the next paragraph) shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
```

`trust.scan` is not scored. This skill does not run a security scan, does not invent a scan score, and does not carry Keen Lab or YunDing Lab detection rules.

A sub-item below the 4-point band can be one maintenance gap. These bands locate gaps. They are not an outward TRACE total.

## Trust

### domestic — scored

| Score | Band |
|---|---|
| 5 | Full Chinese interaction; dependencies can be reached directly; the declared toolchain fits |
| 4 | Chinese works, with a few strings in another language; the skill can be used |
| 3 | Partial Chinese; the core works; some dependencies are hard to reach |
| 2 | Incomplete Chinese; many dependencies are hard to reach |
| 1 | One language only, or a key dependency cannot be used |

### scan — not scored

Always skipped. A sentence named in a platform report can be an external signal. Do not add scan rules from it.

## Reliability

### stability

| Score | Band |
|---|---|
| 5 | Retry, timeout, or an explicit recovery step; a repeat does not change a confirmed result |
| 4 | Mostly stable, with a way out on failure |
| 3 | Usually finishes, missing some fault handling |
| 2 | Unhandled failures are likely |
| 1 | No fault handling |

### func

| Score | Band |
|---|---|
| 5 | Every declared behavior has steps; inputs are checked; defaults are written down |
| 4 | The core is complete; a few edges are unwritten |
| 3 | The main path works; an important behavior is missing |
| 2 | Only part of the core exists |
| 1 | A skeleton |

### errorHandling

| Score | Band |
|---|---|
| 5 | Error codes, and the message tells you the next step |
| 4 | Failures are handled; messages are readable |
| 3 | Basic handling; messages are vague |
| 2 | Some failures have no message |
| 1 | Failure is silent |

## Adaptability

### boundary

| Score | Band |
|---|---|
| 5 | States what it does and does not do, where it applies, and the input/output limits |
| 4 | Most limits are stated |
| 3 | Only some limits are stated |
| 2 | Limits are thin; the skill is easy to misuse |
| 1 | No limits |

### trigger

| Score | Band |
|---|---|
| 5 | How to invoke it, with examples, and the conditions are unambiguous |
| 4 | Invocation is mostly clear; examples are few |
| 3 | Some guidance; some cases stay vague |
| 2 | The reader has to guess how to start |
| 1 | No usage guidance |

## Convention

### progressive

| Score | Band |
|---|---|
| 5 | The coordinator stays thin; detail opens when needed |
| 4 | The layers are mostly clear |
| 3 | Layers exist; some order is awkward |
| 2 | Layers are unclear |
| 1 | Everything is piled in one place |

### structure

| Score | Band |
|---|---|
| 5 | Directories, modules, and names agree; the entry is findable |
| 4 | Structure is mostly clear |
| 3 | Some modules are split awkwardly |
| 2 | The important part is hard to find |
| 1 | Files are disorganized |

### docQuality

| Score | Band |
|---|---|
| 5 | Several worked cases and output samples |
| 4 | Cases and samples cover the main path |
| 3 | Only a few examples |
| 2 | One line of example, no situation |
| 1 | No case and no output sample |

### antiPatternFaq

| Score | Band |
|---|---|
| 5 | States what not to do; the FAQ covers the frequent questions |
| 4 | Anti-patterns and an FAQ cover the main questions |
| 3 | A few hints |
| 2 | One warning |
| 1 | No anti-pattern and no FAQ |

## Effectiveness

For a document skill, judge whether the procedure can be followed and whether the output template is clear. Do not write an unrun result as if it had been verified.

### accuracy

| Score | Band |
|---|---|
| 5 | Proposal fields are fixed and match the rules in the skill |
| 4 | Usable, with a small slip |
| 3 | Usable; some cases are vague |
| 2 | Output often misses the rules |
| 1 | The format is chaotic |

### completeness

| Score | Band |
|---|---|
| 5 | One-gap maintenance, a full-dimension pass, write-after-confirm, and the version rule all have steps |
| 4 | The main path is complete; extreme combinations are unwritten |
| 3 | The simple path works; the complex path is thin |
| 2 | Only the simple path |
| 1 | Only a goal sentence |

### usability

| Score | Band |
|---|---|
| 5 | A trigger leads to a proposal; the line before and after confirmation is clear |
| 4 | The path can be finished; a few spots require a guess |
| 3 | It can be finished; the flow is unclear |
| 2 | The flow breaks |
| 1 | It cannot be started |

### creativity

| Score | Band |
|---|---|
| 5 | Adds a reusable judgment and still stays inside the bands |
| 4 | Adds a priority or a handoff |
| 3 | Covers the bands themselves |
| 2 | Repeats the dimension names |
| 1 | Nothing can be executed |

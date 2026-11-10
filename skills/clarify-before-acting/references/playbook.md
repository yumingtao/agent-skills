# 先澄清再行动 — 行动手册 / Clarify Before Acting — Playbook

[`../SKILL.md`](../SKILL.md) 中核心规则的扩展指引。当任务足够困难、值得时再读本文件。日常使用核心规则即可；本手册面向真正困难、模糊或高风险的场景。

Extended guidance for the core rule in [`../SKILL.md`](../SKILL.md). Read this when a task is hard enough to warrant it. The core rule is enough for everyday use; this playbook is for the genuinely hard, ambiguous, or high-stakes ones.

这里的技巧提炼自实践以及成熟需求访谈工作流的运作方式，但刻意重新表述为*判断启发式*而非机械流程。没有评分模型、没有状态文件、没有流水线——只是一个有能力的智能体在任何平台上用自身推理可以做的事。

The techniques here are distilled from practice and from how mature requirements-interview workflows behave, but deliberately re-expressed as *judgment heuristics* rather than machinery. There is no scoring model, no state file, no pipeline — just things a capable agent can do with its own reasoning on any platform.

---

## 1. 思维模式：暴露假设，而非收集功能 / The mindset: expose assumptions, don't collect features

模糊请求的失败模式不是"缺少功能"——而是你和请求方各自持有的*隐藏假设*不同。功能清单回答"你想要什么？"；它抓不到你想象的是批处理任务而对方想象的是实时 API 的那一刻。

The failure mode of a vague request is not "missing features" — it is *hidden assumptions* that you and the requester hold differently. A feature list answers "what do you want?"; it does not catch the moment where you pictured a batch job and they pictured a real-time API.

所以让你的问题倾向于揭示假设：

So bias your questions toward surfacing assumptions:

- "I'm reading this as X — is that right?" beats "tell me more." / "我把它理解为 X——对吗？"胜过"再多说点。"
- "What happens when X fails / is empty / arrives twice?" surfaces edge assumptions the happy-path description hides. / "当 X 失败/为空/重复到达时会怎样？"揭示了快乐路径描述所隐藏的边界假设。
- "What's deliberately *not* part of this?" surfaces scope assumptions. / "什么是刻意*不*包含在内的？"揭示范围假设。

## 2. 提问前先做功课 / Do your homework before you ask

一个你本可以自己回答的问题是摩擦，它会侵蚀信任。向人提问前：

A question you could have answered yourself is friction, and it erodes trust. Before asking a human:

1. 重读请求，看它已经隐含了什么。
   Read the request again for what it already implies.
2. 检查你有权访问的代码库、文档、工单或数据。
   Inspect the codebase, docs, tickets, or data you have access to.
3. 只有这时才提问——且只问人才能决定的事（意图、范围、优先级、权衡、业务规则）。
   Only then ask — and only about what a human alone can decide (intent, scope, priorities, trade-offs, business rules).

提问时，**引用促使你提问的证据**：

When you ask, **cite the evidence** that prompted it:

> "I found JWT auth in `src/auth/` using the passport pattern. Should this feature extend that, or intentionally diverge?" / "我在 `src/auth/` 中发现了使用 passport 模式的 JWT 鉴权。这个功能应该扩展它，还是有意另起炉灶？"

远好于"这里的鉴权是怎么工作的？"——它表明你看过了，让对方可以确认而不是重新解释。

is far better than "How does auth work here?" — it shows you looked, and it lets the person confirm instead of re-explain.

功课包括**记忆**。在提供记忆或历史会话回顾的平台上，搜索该用户已经回答过的问题——偏好、之前的决定、已定的权衡。一个已记录的答案可以省去一次往返；说明你复用了哪条记忆，以便对方在其过时时纠正。记忆缩短队列；它不授权对一个未回答的方向性未知进行猜测。

Homework includes **memory**. On platforms that offer memory or past-session recall, search it for questions this user has already answered — preferences, prior decisions, settled trade-offs. A recorded answer retires a queued question without a round-trip; say which memory you reused so the person can correct it if it is stale. Memory shrinks the queue; it does not authorize guessing past an unanswered direction-changing unknown.

## 3. 清晰度检查表——找到最薄弱环节 / The clarity checklist — find the weakest spot

把这些当作"我理解这个吗？"的维度。每个问题瞄准当前最弱的维度，而非最容易问的。

Treat these as the dimensions of "do I understand this?" Aim each question at whichever is currently weakest, not at whatever is easiest to ask.

| 维度 Dimension | 背后的问题 The question behind it | 好的提问 A good probe |
|-----------|------------------------|--------------|
| **目标 Goal** | 我能用一句话、不带"和/或"地陈述目标吗？ Can I state the objective in one sentence, no "and/or"? | "When you say 'manage X', what's the very first action a user takes?" |
| **约束 Constraints** | 我知道边界和非目标吗？ Do I know the boundaries and non-goals? | "Does this need to work offline, or is connectivity assumed?" |
| **成功 Success** | 我能写出一个证明它工作的测试吗？ Could I write a test that proves it works? | "If I showed you the finished thing, what would make you say 'yes, that's it'?" |
| **上下文 Context** | （现有系统）我是否足够理解要改的东西，能安全地改？ (Existing systems) Do I understand what I'm changing well enough to change it safely? | "This touches the existing order flow — should it reuse that path or stand alone?" |

当有帮助时，用一句话大声说出瞄准点：*"目标清晰，但成功标准是最薄弱的部分，所以："*——这让对话清晰可读，并阻止你在已经理解的部分原地打转。

State the targeting out loud in one line when it helps: *"The goal is clear, but success criteria are the weakest part, so:"* — it keeps the conversation legible and stops you from circling the part you already understand.

## 4. 问题队列——逐个按序进行 / The question queue — one at a time, in order

核心规则说要处理队列；这里讲如何防止它退化。

The core rule says work a queue; this is how to keep it from degrading.

**为什么要用队列。** 把所有问题塞进一条消息会把对话变成问卷——人们会略读、只回答一半，你每轮学到的更少。想到什么问什么会失去排序：你在一个依赖于它的目标尚未确定前，就把耐心消耗在一个细节上。队列把这两种失败模式分开：一切可见，但一次只处理一个问题。

**Why a queue at all.** Dumping every question in one message turns a conversation into a questionnaire — people skim, half-answer, and you learn less per round. Asking whatever comes to mind next loses ordering: you burn patience on a detail before settling the goal it depends on. The queue holds both failure modes apart: everything is visible, but only one question is live at a time.

**每项的循环 / The loop, per item:**

1. 问最上面的问题——只问那一个。
   Ask the top question — just that one.
2. 倾听。如果答案本身在一个方向性点上模糊，*先*追问再往下走（"你说 X，是总是如此，还是只在冷启动时？"）。
   Listen. If the answer is itself ambiguous on a direction-changing point, probe it *before* moving on ("when you say X, always, or only on cold start?").
3. 用一行复述答案，让误读现在暴露，而不是在评审时。
   Reflect the answer back in one line so a misread surfaces now, not in review.
4. 标记为已解决，应用到队列（新未知加入，已死问题移出），只有这时才问下一个。
   Mark it resolved, apply it to the queue (new unknowns in, dead questions out), and only then ask the next.

**队列卫生 / Queue hygiene.**

- 每项必须是方向性的；可逆细节属于假设清单，不属于队列。如果队列持续增长超过约 5 项，真正的问题通常是范围形态未确认——继续前先去映射范围（§5）。
  Every item must be direction-changing; reversible detail belongs to the assumptions list, not the queue. If the queue keeps growing past ~5 items, the real problem is usually an unconfirmed scope shape — go map the scope (§5) before continuing.
- 三个或更多未决项：提问时展示编号列表，让对方看到剩余形态并可以重排（"先回答第 3 个，我对那里有想法"）。
  Three or more open items: show the numbered list when you ask, so the person sees the remaining shape and can reorder it ("answer 3 first, I have opinions there").
- 一个答案同时解决多项是常见且好的——显式折叠队列，而不是问现在已经多余的问题。
  An answer that resolves several items at once is common and good — collapse the queue explicitly rather than asking now-redundant questions.

## 5. 深入前先映射范围 / Map the scope before you drill

在对描述最多的部分深入之前，先列出工作的顶层组成部分——那些各自可以独立成功或失败的部分。深度优先提问往往过度拟合于请求方描述最生动的组件，而一个较安静的兄弟部分却处于危险的模糊状态。

Before going deep on the most-described piece, list the top-level pieces of the work — the parts that can each succeed or fail independently. Depth-first questioning tends to overfit to whichever component the requester described most vividly, while a quieter sibling stays dangerously vague.

> "I'm reading this as three pieces: (1) ingest, (2) normalize, (3) a reviewer UI. The UI is clear; the other two aren't. Right framing? Anything missing?" / "我把它理解为三部分：(1) 摄入，(2) 规范化，(3) 审核者 UI。UI 清晰；另两个不清晰。框架对吗？有遗漏吗？"

先确认形态，然后逐个澄清每个部分，直到没有方向性模糊。

Confirm the shape first, then clarify each piece until none is direction-vague.

## 6. 提问视角——卡住时使用 / Questioning lenses — for when you're stuck

如果几轮还没收敛，轮换你提问的视角。每个用一次，然后回到正常提问：

If a few rounds haven't converged, rotate the lens you question through. Use each once, then return to normal questioning:

- **唱反调者 Contrarian** — 挑战一个核心假设。"你说 1 万并发用户。如果是 100 呢——设计会变吗，还是 1 万是个假设而非实测需求？" 往往能瓦解想象中的复杂度。
  challenge a core assumption. "You said 10k concurrent users. What if it were 100 — does the design change, or is 10k an assumption rather than a measured need?" Often collapses imagined complexity.
- **简化者 Simplifier** — 寻找最小有价值版本。"最小还值得交付的东西是什么？" 区分必要与假设。
  hunt for the minimal valuable version. "What's the smallest thing that would still be worth shipping?" Separates needed from assumed.
- **本质 Essence** — 当核心名词不断变化（先后被称为工作流、收件箱、规划器）时，停止讨论功能，先问*这个东西根本上是什么*，再继续。核心名词飘移是你在澄清症状而非本体的信号。
  when the core noun keeps shifting (it's been called a workflow, an inbox, and a planner), stop on features and ask *what the thing fundamentally is* before going further. A moving core noun is a signal you're clarifying symptoms, not the thing.

### 未知-未知扫描 / Unknown-unknowns sweep

当任务高风险、异常新颖，或在正常视角后仍感觉方向模糊时，寻找请求方可能不知道该提出来的决策。选择最便宜且有用的行动；不要默认四个都跑：

When the task is high-stakes, unusually novel, or still feels direction-vague after the normal lenses, look for decisions the requester may not know to name. Choose the cheapest useful action; do not run all four by default:

- **盲点扫描 Blind-spot scan** — 列出可能改变实现但未被提及的决策，然后只问方向性的那些。
  list decisions that could change the implementation but were not mentioned, then ask about only the direction-changing ones.
- **短暂发散 Diverge briefly** — 勾勒两到三个实质不同的方案，在选择前暴露隐藏的权衡。
  sketch two or three materially different approaches to expose a hidden trade-off before choosing one.
- **廉价证伪 Cheap falsification** — 当一个低成本测试可以证伪关键假设时，用小原型、测量或查询。
  use a small prototype, measurement, or lookup when a low-cost test can disprove a key assumption.
- **行动后反向检查 Reverse-check after acting** — 把实现笔记与原始目标对比，问可能遗漏了什么默认标准或期望。
  compare the implementation notes with the original goal and ask what default standard or expectation may have been missed.

这些行动是揭示未知的方式，不是无限推迟行动的理由。一旦没有剩余未知会改变目标、范围、负责人、数据模型或方法，就停止扫描。

These actions are ways to reveal unknowns, not reasons to postpone action indefinitely. Stop the sweep once no remaining unknown would change the goal, scope, owner, data model, or approach.

## 7. 知道何时停止——方向性测试 / Knowing when to stop — the directional test

不要追求一个数字。测试是定性的：

Do not chase a number. The test is qualitative:

> **任何剩余未知会改变工作的*方向*吗？**——不同的目标、负责人、形态、数据模型或方法？
> **Would any remaining unknown change the *direction* of the work** — a different goal, owner, shape, data model, or approach?

用循环边界作为实际锚点：可能改变目标、范围、负责人或整体方法的问题属于人/产品决策循环；实现细节可以带着显式假设留在执行循环中。行动后的反馈若揭示澄清的方向错了，可能重新打开决策循环。

Use the loop boundary as a practical anchor: questions that could change the goal, scope, owner, or overall approach belong in the human/product decision loop; implementation details can stay in the execution loop with an explicit assumption. Feedback after acting may reopen the decision loop when it reveals that the clarified direction was wrong.

- 如果**是**：说出那个未知，用一个更有针对性的问题解决它。
  If **yes**: name that unknown and resolve it with one more targeted question.
- 如果**否**：停止并行动。对方可以在评审时纠正的细节不是继续提问的理由。
  If **no**: stop and act. Detail the person can correct on review is not a reason to keep asking.

你*还没*准备好的信号（任一即可）：

Signals you are *not* ready (any one is enough):

- 核心动作或其目标仍是"TBD"。
  The core action or its target is still "TBD".
- 两种实质不同的方法仍悬而未决，你无法选择。
  Two genuinely different approaches are still live and you can't pick.
- 成功标准按当前表述无法测试。
  A success criterion would be impossible to test as currently stated.
- 请求方在某个方向性问题上说"我查一下"或"不确定"。
  The requester said "I'll check" or "not sure" on something direction-changing.

你*已经*准备好的信号：你现在就能写出目标、约束和至少一条可测试的成功标准，而无需编造任何实质内容。

Signals you *are* ready: you could write the goal, the constraints, and at least one testable success criterion right now without inventing anything material.

### 尊重"直接做"——并把它与"你问太多了"区分开 / Respecting "just do it" — and telling it apart from "you ask too much"

两种不同的信息常以相似的话出现：

Two different messages often arrive in similar words:

- **明确叫停 An explicit stop** — "don't ask, just do it", "stop asking and start"。结束队列。把每个剩余项转为带风险的陈述假设（§8），并清楚说明：
  End the queue. Convert each remaining item into a stated assumption with its risk (§8), and say so plainly:
  > "Proceeding now. Still unclear: the retry behavior on partial failure. I'll assume fail-fast and surface it; flag me if that's wrong." / "现在继续。仍不清楚：部分失败时的重试行为。我假设快速失败并提示；如果错了请告诉我。"
- **节奏抱怨 A pace complaint** — "you ask too much", "can we go faster"。不是停止。队列的成员不变：每个方向性未知仍要逐个提问，每个完全解决后再问下一个。变化的只是形式——更短的问题、更紧凑的证据，不再追问答案已覆盖的内容。
  Not a stop. The membership of the queue is unchanged: every direction-changing unknown still gets asked, one at a time, each fully resolved before the next. What changes is form — shorter questions, tighter evidence, no re-asking what an answer already covered.

把节奏抱怨当作停止，会默默丢掉对方仍期望你解决的未知；队列靠答案缩减，不靠不耐烦。当真心不确定听到的是哪一种时，廉价地问一次："澄清一下——是跳过剩余问题用假设，还是继续逐个进行？"

Reading a pace complaint as a stop silently drops unknowns the person still expects you to resolve; the queue shrinks by answers, not by impatience. When genuinely unsure which one you heard, ask once, cheaply: "To be clear — skip the remaining questions and assume, or keep going one at a time?"

## 8. 基于假设推进时，记录它们 / When you proceed on assumptions, record them

队列是方向性未知的去向；假设清单是*非方向性*未知的去处。绝不要因为提问感觉慢就把一项从第一个挪到第二个——那正是本技能要防止的默默猜测。唯一合法的转移：对方明确停止了提问（无歧义的"别问了"——节奏抱怨不算，见§7），或者一个新答案（或记忆）揭示该未知其实一直是细节。

The queue is where direction-changing unknowns go; the assumptions list is where *non-directional* ones go. Never move an item from the first to the second because asking felt slow — that is the silent guess this skill exists to prevent. The only legitimate transfers: the person explicitly stopped the questioning (an unambiguous "stop asking" — a pace complaint is not one, see §7), or a fresh answer (or memory) revealed the unknown was detail all along.

每当你越过一个未解决点行动时，让假设可见，以便它能被廉价捕获：

Whenever you act past an unresolved point, make the assumption visible so it can be caught cheaply:

```
- Assumed: {what you took to be true}
  Basis:   {why — the evidence or default you relied on}
  Risk if wrong: {what breaks / what rework it causes}
```

这把默默猜测变成可评审的决策。它是本手册中杠杆最高的单个习惯：它让你在不假装确定的情况下继续前进。

This turns a silent guess into a reviewable decision. It is the single highest-leverage habit in this playbook: it lets you keep moving without pretending you were certain.

## 9. 任务契约——让澄清后的工作可执行 / Task contracts — make clarified work executable

当另一个智能体将执行工作，或一个未解决的假设实质影响执行时，在澄清结束时使用任务契约。它是从意图到行动的桥梁，不是第二份需求文档，也不是实现方案。

Use a task contract at the end of clarification when another agent will execute the work, or when an unresolved assumption materially affects execution. It is the bridge from intent to action, not a second requirements document and not a prescription for the implementation.

```text
Result:      {the outcome that must be true}
Scope:       {what is included; what is explicitly out of scope}
Checkpoints: {the ordered evidence used to verify the result}
Stop if:     {a change in goal, scope, owner, data, or approach requires review}
Assumptions: {what is being assumed, why, and the risk if it is wrong}
```

例如，"提高登录端点性能"还不是任务契约。一个澄清后的契约可能是：

For example, "improve the login endpoint's performance" is not yet a task contract. A clarified contract might be:

```text
Result:      Reduce average login response time under the agreed load.
Scope:       Change the login path and direct dependencies; keep the token
             semantics and response shape unchanged.
Checkpoints: Record a baseline; make the change; compare latency and error rate
             under the same load; run the affected tests.
Stop if:     The change requires a token, schema, or external API contract change.
Assumptions: The repeated lookup is the main bottleneck, based on the profile;
             if wrong, the optimization target must be revisited.
```

不要编造未澄清的值。留空一个字段、陈述假设，或者当填充它会改变工作方向时停下来提问。

Do not invent values that were not clarified. Leave a field open, state the assumption, or stop and ask when filling it would change the direction of work.

## 验证对本技能的改动 / Validating changes to this skill

打包冒烟测试证明规则正确安装并投影；它不能证明智能体如何行为。此处的改动往往是增量的，它们带来的漂移倾向于问太多——退回到本技能要改进的生硬"总是先问"规则。

The packaging smoke test proves the rule installs and projects correctly; it proves nothing about how an agent behaves. Changes here tend to be additive, and the drift they invite is toward asking too much — back into the blunt "always ask first" rule this skill exists to improve on.

所以在改动本技能后，在一个新会话中运行机械用例：给出一个清晰、低风险、已指定文件/符号/命令的任务——重命名一个符号、运行一个现有测试。智能体应该直接做，不提问也不写任务契约。对一个一行重命名提问或写完整契约，意味着规则变成了它本该避免的摩擦。

So after changing this skill, run the mechanical case in a fresh session: give a clear, low-risk task that already names its file, symbol, or command — rename a symbol, run an existing test. The agent should just do it, with no clarifying question and no task contract. A question or a full contract on a one-line rename means the rule has become the friction it was meant to avoid.

一个模糊请求引出好问题本身不能作为证据；一个问一切的规则也会通过这个测试。机械用例才是区分两者的那个。记录你的观察，不要把打包测试当作行为证据。

A vague request that draws good questions is not evidence on its own; a rule that asked about everything would pass that too. The mechanical case is the one that can tell the two apart. Record what you observed, and do not treat the packaging test as behavioral evidence.

---

## 本手册刻意不包含的内容 / What this playbook deliberately leaves out

为了对范围诚实，并保持其跨智能体可移植，本技能**不**包含：

For honesty about scope, and to keep it portable across agents, this skill does **not** include:

- **数值歧义评分/阈值。** 伪精确。§7 的方向性测试取代它。
  **Numeric ambiguity scoring / thresholds.** Pseudo-precision. The directional test in §7 replaces it.
- **状态文件、恢复或持久化。** 平台相关；一个可移植规则不在范围内。（这是关于技能不保留*自身*状态——检查你的平台已经提供的记忆，如§2所说，恰恰相反。）
  **State files, resume, or persistence.** Platform-specific; out of scope for a portable rule. (This is about the skill not keeping *its own* state — checking memory your platform already provides, as §2 says, is the opposite of that.)
- **流水线交接/编排。** 本技能塑造*你行动前的思考方式*；它不决定*谁执行*。
  **Pipeline handoffs / orchestration.** This skill shapes *how you think before acting*; it does not decide *who executes*.

如果你的平台提供重量级、带仪器的访谈系统（带评分、持久状态和编排），需要时优先用那个。本技能是可在任何地方运行的、仅判断的精简提炼。

If your platform offers a heavyweight, instrumented interview system (with scoring, persisted state, and orchestration), prefer that when you need it. This skill is the portable, judgment-only distillation that runs anywhere.

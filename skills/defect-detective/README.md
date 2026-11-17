# 缺陷侦探

修 bug 之前的只读分诊：归一化指纹，跨栈查重复工单，在涉及层已知时关联近期变更，推断归属团队，并给出可直接复制的建票草稿。行为规则在 [`SKILL.md`](SKILL.md)。

## 在这套技能里的位置

单独使用时，它完成只读分诊并给出建票草稿。它是执行站。

环境、复现路径或版本缺失时，按 [clarify-before-acting](../clarify-before-acting/) 补问。新工单交给你自己的写流程，修复交给实现流程。分诊误判交给 [session-retrospective](../session-retrospective/)。要把这条流水线做成技能时，交给 [workflow-skill-designer](../workflow-skill-designer/)。`SKILL.md` 里的「推荐搭配」是给 agent 的操作说明。

整条环见仓库 README 的[「单独使用，也可以串起来」](../../README.zh-CN.md#alone-or-together)。

## 文档导读

| 想了解 | 看这里 |
|---|---|
| 分诊流程、输出格式与护栏 | [SKILL.md](SKILL.md) |
| 三例分诊演示 | [references/triage-examples.md](references/triage-examples.md) |
| 真实工单冒烟记录 | [references/verification-record.md](references/verification-record.md) |
| 在集合中的位置 | 本文件 |

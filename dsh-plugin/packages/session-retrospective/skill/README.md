# 会话回顾

会话结束时，把真实发生的系统性工作流问题写成字段枚举校验的 JSONL。同一问题复发就升优先级。说「开始修复」后，按复发和优先级逐项确认并回写。行为规则在 [`SKILL.md`](SKILL.md)。

## 在这套技能里的位置

单独使用时，它把本次会话写入 JSONL，并可以进入修复模式。它是这条工程环的收口。

上面任一技能的工作会话都可以记。复发的流程缺口交给 [workflow-skill-designer](../workflow-skill-designer/)，规则缺口回到对应技能。

整条环见仓库 README 的[「单独使用，也可以串起来」](../../README.zh-CN.md#alone-or-together)。

## 文档导读

| 想了解 | 看这里 |
|---|---|
| 回顾规则、字段枚举与修复模式 | [SKILL.md](SKILL.md) |
| 一条完整记录示例 | [references/retrospective-example.md](references/retrospective-example.md) |
| 日志校验 | `node scripts/validate-feedback.mjs <log.jsonl>` |
| 在集合中的位置 | 本文件 |

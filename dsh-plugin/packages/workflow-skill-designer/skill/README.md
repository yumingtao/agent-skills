# 工作流技能设计器

按 orchestrator + phases 模式设计一个工作流技能：薄的 `SKILL.md` 做协调，执行细节放在按需加载的 `phases/` 里。行为规则在 [`SKILL.md`](SKILL.md)。

## 在这套技能里的位置

单独使用时，它产出一个 orchestrator + phases 技能包。它是元技能，站在工程环外面。

[`session-retrospective`](../session-retrospective/) 里反复出现的流程缺口是典型输入。生成的技能自己运行其中的阶段。

整条环见仓库 README 的[「单独使用，也可以串起来」](../../README.zh-CN.md#alone-or-together)。

## 文档导读

| 想了解 | 看这里 |
|---|---|
| 编排器模板与设计模式 | [SKILL.md](SKILL.md) |
| 四阶段执行细节 | [phases/](phases/) |
| 在集合中的位置 | 本文件 |

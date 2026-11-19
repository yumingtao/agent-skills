# 技能维护

维护已经存在的技能：用 SkillHub 公开的 TRACE 评分档找出一处缺口，写出提案，确认后才写入。说「自动补到阈值」时按每个可评子项连续改，默认 4.8，最多 5 轮。行为规则在 [`SKILL.md`](SKILL.md)。本技能版本是 `1.0.2`。

## 在这套技能里的位置

单独使用时，它维护你指定的那只技能，不依赖本仓库的其他技能。

它站在工程环的维护位。复盘日志、评测评语、TRACE 对照和结构检查都可以把工作交给它。要新技能时交给 [`workflow-skill-designer`](../workflow-skill-designer/)。要记这次会话时交给 [`session-retrospective`](../session-retrospective/)。

整条环见仓库 README 的[「单独使用，也可以串起来」](../../README.zh-CN.md#alone-or-together)。

## 文档导读

| 想了解 | 看这里 |
|---|---|
| 铁律、流程、异常码 | [SKILL.md](SKILL.md) |
| 15 个子项评分档 | [references/trace-items.md](references/trace-items.md) |
| 信号优先级 | [references/signal-rules.md](references/signal-rules.md) |
| 提案模板与例子 | [references/proposal-template.md](references/proposal-template.md) |

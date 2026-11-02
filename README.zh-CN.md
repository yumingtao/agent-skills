# agent-skills

原创、平台中立的 agent skills —— 可在 Claude Code、Codex、Cursor、OpenCode、Windsurf、Gemini、GitHub Copilot、CodeBuddy、Hermes 上工作的提示词资产。

[English](README.md) | [简体中文](README.zh-CN.md)

零运行时依赖、零网络调用、零构建步骤。每个 skill 都是一个自包含的指令文件夹；当一个 skill 支持多平台时，平台文件只是薄适配层，把所有 agent 引向同一份共享行为。

## Skills

| Skill | 功能 |
|---|---|
| **[diagram-generator](skills/diagram-generator/)** | 将架构简介（architecture brief）与代码库笔记转化为独立 HTML/SVG 技术图：系统图、实现图、基础设施图、信任边界图、数据流转图、部署图、流程图。完整包：生成规则、规划 IR、HTML 模板、校验脚本、逐平台冒烟测试。 |
| **[clarify-before-acting](skills/clarify-before-acting/)** | 面对非平凡请求的行为规则：先自行调研、复用记忆中已有的答案、按问题队列逐个提问直到所有影响方向的未知项全部澄清、方向上绝不靠猜。 |
| **[insight-challenge](skills/insight-challenge/)** | 对代码审查发现的对抗式验证。用锚定到实际源码的反证逐条质询每个发现，输出结构化裁决 —— overturned（推翻）/ weakened（削弱）/ confirmed（确认）—— 而不是照单全收。 |
| **[workflow-skill-designer](skills/workflow-skill-designer/)** | 设计 orchestrator + phases 结构化 workflow skill 的元技能：薄 `SKILL.md` 协调器 + 渐进加载的 `phases/` 文件，含 TodoWrite 模式、跨阶段数据流与校验清单。 |

## 安装

每个 skill 独立可用 —— 只复制或软链你需要的。

### Claude Code

```bash
ln -s /absolute/path/to/agent-skills/skills/<skill-name> ~/.claude/skills/<skill-name>
```

### Codex（skill 模式）

```bash
ln -s /absolute/path/to/agent-skills/skills/<skill-name> ~/.codex/skills/<skill-name>
```

### 其他 agent

- **diagram-generator** 自带逐平台适配层：`AGENTS.md`（Cursor / OpenCode / Windsurf）、`GEMINI.md`、`COPILOT-INSTRUCTIONS.md`、`CODEBUDDY.md`、`HERMES.md` —— 见其 [README](skills/diagram-generator/README.md#installation)。
- 其余三个 skill 是 Claude skill 格式文件夹；在没有 skill 机制的平台，把 agent 指向该 skill 的 `SKILL.md` 作为指令文件即可。

## Sync

`sync/` 是面向整个集合的通用「单一源 → 多平台」分发器。平台目标以软链（默认）或实体副本形式接收规范 skill 文件夹。

```bash
sync/apply.sh --dry-run                                  # 预览
sync/apply.sh                                            # 链接进所有已检测到的平台
sync/apply.sh --platform claude --skill insight-challenge # 限定范围
sync/apply.sh --to ./ --platform cursor                  # 项目本地安装
sync/check.sh                                            # 校验有无漂移
```

分发地图位于 `sync/manifest.sh` —— 见 [sync/README.md](sync/README.md)。

## 设计原则

- **每个 skill 单一事实源。** 平台文件只做路由，不复述行为。
- **Markdown 优先。** Skill 就是指令加可选的 specs/resources —— 无需安装或运行任何东西。
- **渐进加载。** 协调器保持薄；执行细节放在按需加载的 `phases/` / `specs/` / `references/` 里。

## Roadmap

- [ ] `diagram-generator` 的 `drawio-first` 输出模式（需要专门的 mxGraphModel 规则、模板与导入校验）

## License

[MIT](LICENSE)。本集合中的 skills 依相同 MIT 条款发布。

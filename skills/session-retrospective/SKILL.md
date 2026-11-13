---
name: session-retrospective
slug: yumingtao-session-retrospective
displayName: Session Retrospective
version: 1.0.0
summary: 会话结束时回顾当前对话，提取工作流问题并写入结构化反馈日志，沉淀系统性改进信号。
license: MIT
tags:
  - 会话回顾
  - 工作流改进
  - 反馈日志
  - 开发工具
description: >
  会话结束时回顾当前对话，提取工作流问题——需纠正的错误答案、跳过的闸门、错误路由、MCP 错误、skill/文档缺口、多轮纠正——并把结构化反馈条目追加到本地 JSONL 日志。跳过琐碎澄清，聚焦表明 skill、文档或工作流规则需要更新的系统性信号。触发词："回顾一下这个会话"、"记录会话反馈"、"session review"、"log session feedback"。
---

# 会话回顾

用本技能回顾当前会话，并把结构化反馈条目追加到项目的工作流反馈日志。

## 反馈存到哪里

默认位置：当前项目根目录下的 `metrics/workflow-feedback.jsonl`。如果项目设定了其他日志位置（查看项目文档或已有日志文件），用那个。首次写入时创建文件；它是只追加的本地状态，绝不提交到 git。

## 何时使用

- 工程师说"回顾一下这个会话"、"记录会话反馈"或"session review"
- 任何工作流任务的工作会话结束时
- 解决了一个需要多轮来回的问题之后

## 分析什么

回顾对话并识别：

1. **需纠正的错误答案** — AI 给出了错误输出，工程师不得不纠正
2. **跳过闸门** — 跳过了必需的工作流阶段或确认
3. **错误路由** — AI 使用了错误的技能、工作流或方法
4. **MCP 错误** — 工具调用失败或阻塞了工作流
5. **技能/文档缺口** — 因为规则缺失或不清晰而需要反复澄清
6. **多轮纠正** — 需要 2+ 轮交流才能得到正确答案
7. **成功完成** — 值得作为正面信号记录

每个独立问题写一条反馈条目。如果没有出错，写一条 `success` 条目。

## 如何写反馈

向反馈日志每行追加一个 JSON 对象：

```json
{"timestamp": "2026-11-13T14:30:00+08:00", "platform": "claude", "area": "review", "result": "corrected", "issue_type": "wrong-routing", "notes": "<出了什么问题，正确行为应该是什么>", "ref": "PR-123"}
```

| 字段 | 取值 |
|---|---|
| `timestamp` | ISO-8601 本地时间 |
| `platform` | `claude`, `codex`, `codebuddy`, `cursor`, `github-copilot`, `intellij-copilot`, `gemini`, `opencode`, `other` |
| `area` | `planning`, `implementation`, `review`, `git-pr`, `mcp`, `environment`, `docs`, `other` |
| `result` | `success`, `blocked`, `corrected`, `failed` |
| `issue_type` | `none`, `gate-skipped`, `wrong-routing`, `mcp-error`, `skill-sync-missing`, `generated-code-hygiene`, `logging-convention`, `utility-reuse`, `title-format`, `ticket-field`, `auth`, `tool-error`, `other` |
| `notes` | 出了什么问题，正确行为应该是什么 |
| `ref` | 可选的工单 / PR 编号 |

从当前 AI 工具推断 `platform`，除非工程师另行指定。

## 规则

- `notes` 控制在 200 字符以内，聚焦工作流中应该改变什么
- **不要**记录琐碎澄清（例如用户只是忘了提供的缺失参数）
- 聚焦系统性问题：表明 skill、文档或工作流规则需要更新的事情
- **不要**提交反馈日志——它是只追加的本地状态

## 写完反馈之后

打印一张简要汇总表：

| 区域 | 问题类型 | 备注 |
|------|---------|------|
| ...  | ...     | ...  |

然后根据发现的问题，建议当前项目中哪些文件可能需要更新。

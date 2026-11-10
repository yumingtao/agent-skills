# 结论 Schema 规范 / Verdict Schema Specification

## 概述 / Overview

本文档定义洞察挑战结论的结构化输出格式。该 schema 确保结果一致、机器可读，可供下游系统消费。

This document defines the structured output format for insight challenge verdicts. The schema ensures consistent, machine-readable results that can be consumed by downstream systems.

## 结论 JSON Schema / Verdict JSON Schema

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "required": ["finding_id", "challenge_result", "confidence", "reasoning"],
  "properties": {
    "finding_id": {
      "type": "string",
      "description": "Original finding identifier"
    },
    "challenge_result": {
      "type": "string",
      "enum": ["overturned", "weakened", "confirmed"],
      "description": "Verdict of the challenge"
    },
    "confidence": {
      "type": "integer",
      "minimum": 0,
      "maximum": 100,
      "description": "Confidence score (0-100)"
    },
    "reasoning": {
      "type": "string",
      "description": "Detailed explanation of the verdict"
    },
    "counter_evidence": {
      "type": "array",
      "items": { "type": "string" },
      "description": "Evidence that contradicts the finding"
    },
    "supporting_evidence": {
      "type": "array",
      "items": { "type": "string" },
      "description": "Evidence that supports the finding"
    },
    "adjusted_severity": {
      "type": "string",
      "enum": ["none", "critical", "high", "medium", "low"],
      "description": "Recommended severity after challenge"
    },
    "recommendation": {
      "type": "string",
      "description": "Recommended action"
    },
    "metadata": {
      "type": "object",
      "properties": {
        "challenge_duration_ms": { "type": "integer" },
        "files_reviewed": { "type": "array", "items": { "type": "string" } },
        "design_docs_checked": { "type": "array", "items": { "type": "string" } },
        "challenge_strategies_applied": { "type": "array", "items": { "type": "string" } }
      }
    }
  }
}
```

## 字段定义 / Field Definitions

### finding_id
- **类型 Type**: string
- **必填 Required**: 是 / yes
- **描述 Description**: 原始发现标识符（如 "HIGH-01"、"CRIT-03"）/ The original finding identifier (e.g., "HIGH-01", "CRIT-03")
- **示例 Example**: "HIGH-01"

### challenge_result
- **类型 Type**: string (enum)
- **必填 Required**: 是 / yes
- **取值 Values**:
  - `overturned`: 发现事实错误；源代码直接反驳主张 / Finding is factually incorrect; source code directly contradicts claims
  - `weakened`: 发现部分正确但被夸大、范围错误或缺少上下文 / Finding is partially correct but overstated, misscoped, or missing context
  - `confirmed`: 发现准确；源代码支持所有主张 / Finding is accurate; source code supports all claims

### confidence
- **类型 Type**: integer (0-100)
- **必填 Required**: 是 / yes
- **描述 Description**: 挑战者对结论的置信度 / How confident the challenger is in the verdict
- **分级 Scale**:
  - 90-100: 清晰、无歧义的证据 / Clear, unambiguous evidence
  - 70-89: 证据充分，有轻微不确定性 / Strong evidence with minor uncertainty
  - 50-69: 证据混合；需要判断 / Mixed evidence; judgment call
  - 低于 50 Below 50: 证据不足 / Insufficient evidence

### reasoning
- **类型 Type**: string
- **必填 Required**: 是 / yes
- **描述 Description**: 为何得出该结论的详细说明 / Detailed explanation of why the verdict was reached
- **应包含 Should include**:
  - 原始主张摘要 / Summary of the original claim
  - 发现了什么证据 / What evidence was found
  - 证据为何支持该结论 / Why the evidence supports the verdict
  - 任何注意事项或限制 / Any caveats or limitations

### counter_evidence
- **类型 Type**: array of strings
- **必填 Required**: 否（但 overturned/weakened 期望有）/ no (but expected for overturned/weakened)
- **描述 Description**: 反驳发现的具体证据 / Specific evidence that contradicts the finding
- **格式 Format**: 每项应引用具体文件和行 / Each item should reference a specific file and line
- **示例 Example**: ["src/types.ts line 64: 'resolves' IS declared in KnowledgeEdgeKind"]

### supporting_evidence
- **类型 Type**: array of strings
- **必填 Required**: 否（但 confirmed 期望有）/ no (but expected for confirmed)
- **描述 Description**: 支持发现的具体证据 / Specific evidence that supports the finding
- **格式 Format**: 与 counter_evidence 相同 / Same as counter_evidence

### adjusted_severity
- **类型 Type**: string (enum)
- **必填 Required**: 否 / no
- **取值 Values**:
  - `none`: 发现应完全驳回 / Finding should be dismissed entirely
  - `critical`, `high`, `medium`, `low`: 调整后的严重度级别 / Adjusted severity level
- **描述 Description**: 考虑挑战证据后建议的严重度 / Recommended severity after considering challenge evidence
- **默认 Default**: 未指定时为原始严重度 / Original severity if not specified

### recommendation
- **类型 Type**: string
- **必填 Required**: 否 / no
- **描述 Description**: 建议的下一步行动 / Recommended next action
- **示例 Examples**:
  - "驳回此发现；声称的缺失不存在" / "Dismiss this finding; the claimed gap does not exist"
  - "降级为中严重度；问题存在但不如声称严重" / "Downgrade to medium severity; the issue exists but is less critical than claimed"
  - "确认并优先处理；发现准确且重要" / "Confirm and prioritize; the finding is accurate and important"

### metadata
- **类型 Type**: object
- **必填 Required**: 否 / no
- **描述 Description**: 挑战过程的额外上下文 / Additional context about the challenge process
- **字段 Fields**:
  - `challenge_duration_ms`: 挑战耗时 / Time spent on the challenge
  - `files_reviewed`: 检查的文件列表 / List of files examined
  - `design_docs_checked`: 查阅的设计文档 / Design documents consulted
  - `challenge_strategies_applied`: 使用了哪些挑战策略 / Which challenge strategies were used

## 示例结论 / Example Verdicts

### 被推翻的发现 / Overturned Finding

```json
{
  "finding_id": "HIGH-01",
  "challenge_result": "overturned",
  "confidence": 97,
  "reasoning": "The finding's central claim is factually incorrect. Exponential backoff IS implemented in src/http/retry.ts (lines 42-49), not in the middleware file the finding searched. The 'no backoff logic found' claim comes from inspecting only src/http/middleware.ts.",
  "counter_evidence": [
    "src/http/retry.ts lines 42-49: delay computed as base * 2^attempt with ±20% jitter",
    "src/http/middleware.ts line 18: delegates all retries to retryWithBackoff(); no delay logic belongs there",
    "config/default.yaml line 12: retry.baseDelayMs is loaded and passed into the client factory"
  ],
  "supporting_evidence": [],
  "adjusted_severity": "none",
  "recommendation": "Dismiss this finding; the claimed missing backoff logic does not exist"
}
```

### 被削弱的发现 / Weakened Finding

```json
{
  "finding_id": "MED-02",
  "challenge_result": "weakened",
  "confidence": 75,
  "reasoning": "The finding correctly identifies that function X lacks input validation, but overstates the severity. The function is only called internally with pre-validated data, reducing the actual risk.",
  "counter_evidence": [
    "src/service.ts: Function X is only called from Y() which validates inputs",
    "No external API exposes this function directly"
  ],
  "supporting_evidence": [
    "src/utils.ts line 45: Function X indeed lacks input validation"
  ],
  "adjusted_severity": "low",
  "recommendation": "Add defensive validation as a best practice, but do not prioritize as high severity"
}
```

### 已确认的发现 / Confirmed Finding

```json
{
  "finding_id": "CRIT-03",
  "challenge_result": "confirmed",
  "confidence": 95,
  "reasoning": "The finding accurately identifies a SQL injection vulnerability. User input is directly concatenated into the query string without parameterization.",
  "counter_evidence": [],
  "supporting_evidence": [
    "src/db.ts line 78: query = 'SELECT * FROM users WHERE id = ' + userId",
    "userId comes directly from req.params.id without sanitization"
  ],
  "adjusted_severity": "critical",
  "recommendation": "Immediate fix required; use parameterized queries"
}
```

## 批量处理 / Batch Processing

处理多个发现时：

When processing multiple findings:

```json
{
  "batch_id": "review-2026-06-12",
  "total_findings": 5,
  "verdicts": [
    { "finding_id": "HIGH-01", "challenge_result": "overturned", ... },
    { "finding_id": "HIGH-02", "challenge_result": "confirmed", ... },
    { "finding_id": "MED-01", "challenge_result": "weakened", ... }
  ],
  "summary": {
    "overturned": 1,
    "weakened": 1,
    "confirmed": 3,
    "adjusted_effort_savings": "40% of original findings dismissed or downgraded"
  }
}
```

## 与下游系统的集成 / Integration with Downstream Systems

### 质量仪表盘 / Quality Dashboard
- 结论更新质量跟踪中的发现状态 / Verdicts update finding status in quality tracking
- 置信度评分影响发现优先级 / Confidence scores affect finding priority
- 调整后的严重度触发相应工作流 / Adjusted severities trigger appropriate workflows

### 知识系统 / Knowledge System
- 已确认的发现成为 knowhow 候选 / Confirmed findings become knowhow candidates
- 挑战模式成为评审规范 / Challenge patterns become review specs
- 被推翻的发现改进未来检测 / Overturned findings improve future detection

### 团队技能 / Team Skills
- 结论馈入团队评分算法 / Verdicts feed into team scoring algorithms
- 挑战结果为收敛标准提供信息 / Challenge results inform convergence criteria
- 对抗模式提升团队评审质量 / Adversarial patterns enhance team review quality

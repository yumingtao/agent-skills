---
name: insight-challenge
slug: yumingtao-insight-challenge
displayName: Insight Challenge
version: 1.2.0
summary: 对代码质量发现进行对抗性审查，用源代码锚定的反向证据产出结构化结论 / Adversarial review of code quality findings with source-anchored counter-evidence and structured verdicts.
license: MIT
disable-model-invocation: true
description: >
  对代码质量发现进行对抗性审查：用反向证据挑战发现、对照源代码验证主张、产出结构化结论。适用于代码审查、质量分析、架构评估中的发现验证。触发词："审查发现"、"挑战发现"、"insight-challenge"、"challenge finding"。
  Adversarial review of code quality findings: challenge insights with counter-evidence, verify claims against source code, and produce structured verdicts. Use for findings from code review, quality analysis, or architecture assessment. Triggers on 'insight-challenge', 'challenge finding', '审查发现'.
allowed-tools: Read(*), Glob(*), Grep(*), Bash(*), Write(*)
session-mode: none
---

# 洞察挑战 / Insight Challenge

对代码质量发现进行对抗性审查：用反向证据挑战发现、对照源代码验证主张、产出结构化结论。

Adversarial review of code quality findings: challenge insights with counter-evidence, verify claims against source code, and produce structured verdicts.

## 架构 / Architecture

```
┌─────────────────────────────────────────────────────────────┐
│  Insight Challenge (SKILL.md) — Adversarial Review          │
│  → Parse finding → Read source → Challenge → Verdict        │
└─────────────────────────────────────────────────────────────┘
                           │
    ┌──────────┬───────────┼───────────┬──────────┐
    ↓          ↓           ↓           ↓          │
┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐      │
│Phase 1 │ │Phase 2 │ │Phase 3 │ │Phase 4 │      │
│ Parse  │ │ Source │ │Challenge│ │Verdict │      │
│Finding │ │ Review │ │Analysis │ │Report  │      │
└───┬────┘ └───┬────┘ └───┬────┘ └───┬────┘      │
    │          │          │          │             │
 finding    source     counter-   structured      │
 parsed     code       evidence   verdict         │
```

## 核心设计原则 / Key Design Principles

1. **默认对抗 / Adversarial by Default**: 假设发现可能有误，优先寻找反向证据 / Assume findings may be incorrect; seek counter-evidence first
2. **源代码锚定 / Source-Code Anchored**: 所有主张必须对照实际代码验证，而非假设 / All claims must be verified against actual code, not assumptions
3. **结构化输出 / Structured Output**: 结论遵循固定 schema 供下游消费 / Verdicts follow a fixed schema for downstream consumption
4. **公正挑战 / Fair Challenge**: 若证据支持发现则确认，不制造怀疑 / If evidence supports the finding, confirm it; don't manufacture doubt
5. **透明推理 / Transparent Reasoning**: 展示证据链和推理过程 / Show the chain of evidence and reasoning

## 发现输入格式 / Finding Input Format

发现可以 JSON 或结构化文本形式提供。

Findings can be provided as JSON or structured text:

```json
{
  "id": "HIGH-01",
  "title": "知识边类型 resolves/documents 未在 types.ts 声明",
  "severity": "high",
  "file": "src/graph/kg/db/types.ts",
  "line": 58,
  "description": "issue-extractor 使用 'resolves' 边类型...",
  "evidence": "types.ts KnowledgeEdgeKind: defines, constrains...",
  "suggestion": "补齐缺失的边类型声明",
  "design_ref": "Gap 2 — 12 CodeEdgeKind + 9 KnowledgeEdgeKind"
}
```

Or structured text:
```
HIGH-01: 知识边类型 resolves/documents 未在 types.ts 声明
Severity: high
File: src/graph/kg/db/types.ts:58
Claim: issue-extractor 使用 'resolves' 边类型但未在类型系统中声明
Evidence: types.ts KnowledgeEdgeKind 列表中缺少 'resolves'
```

## 执行流程 / Execution Flow

按四个阶段依次执行：解析发现 → 源代码审查 → 挑战分析 → 结论报告。

Execute in four phases: Parse Finding → Source Review → Challenge Analysis → Verdict Report.

### 阶段 1：解析发现 / Phase 1: Parse Finding

1. 提取发现 ID、标题、严重度、文件引用和主张。
   Extract finding ID, title, severity, file reference, and claims
2. 识别所有可验证的断言：
   Identify all verifiable assertions:
   - 文件存在性主张 / File existence claims
   - 代码结构主张（类型、函数、变量）/ Code structure claims (types, functions, variables)
   - 行为主张（用法模式、依赖）/ Behavioral claims (usage patterns, dependencies)
   - 设计符合性主张 / Design conformance claims
3. 创建验证清单。
   Create verification checklist

### 阶段 2：源代码审查 / Phase 2: Source Review

1. 读取指定行的引用文件。
   Read the referenced file(s) at the specified lines
2. 使用 Grep/Glob 搜索相关代码。
   Search for related code using Grep/Glob
3. 记录代码的实际状态：
   Document actual state of the code:
   - 实际存在哪些类型/函数 / What types/functions actually exist
   - 实际声明了哪些值 / What values are actually declared
   - 实际实现是什么样 / What the actual implementation looks like
4. 将主张与现实对比。
   Compare claims against reality

### 阶段 3：挑战分析 / Phase 3: Challenge Analysis

对发现中的每个主张：

For each claim in the finding:

1. **寻找确认证据**：源代码是否支持该主张？
   **Seek confirming evidence**: Does the source code support this claim?
2. **寻找反证**：源代码是否反驳该主张？
   **Seek disconfirming evidence**: Does the source code contradict this claim?
3. **检查误读**：该主张是否基于过时代码或误解？
   **Check for misinterpretation**: Could the claim be based on outdated code or misunderstanding?
4. **验证设计引用**：引用的设计文档是否准确？
   **Verify design references**: Are cited design docs accurate?

挑战策略：
Challenge strategies:
- **直接矛盾 Direct contradiction**：源代码明确显示相反
- **上下文缺失 Context omission**：发现遗漏了会改变解释的相关上下文
- **过时引用 Stale reference**：发现引用了已更新的代码
- **计数错误 Miscounted**：数字主张（缺少 N 个类型）不正确
- **范围错误 Scope error**：发现应用了错误范围（如混淆边类型与语言类型）

### 阶段 4：结论报告 / Phase 4: Verdict Report

产出结构化输出：

Produce structured output:

```json
{
  "finding_id": "HIGH-01",
  "challenge_result": "overturned|weakened|confirmed",
  "confidence": 95,
  "reasoning": "Detailed explanation of why the finding was challenged or confirmed",
  "counter_evidence": [
    "Source file line 64: 'resolves' IS declared in KnowledgeEdgeKind",
    "Design doc specifies 20 edge types, not 28"
  ],
  "supporting_evidence": [],
  "adjusted_severity": "none|critical|high|medium|low",
  "recommendation": "Dismiss this finding; the claimed gap does not exist"
}
```

## 结论定义 / Verdict Definitions

| 结论 Verdict | 含义 Meaning | 适用场景 When to Use |
|---------|---------|-------------|
| **overturned** | 发现事实错误 / Finding is factually incorrect | 源代码直接反驳主张 / Source code directly contradicts the claim |
| **weakened** | 发现部分正确但被夸大 / Finding is partially correct but overstated | 部分证据支持，但严重度或范围有误 / Some evidence supports it, but severity/scope is wrong |
| **confirmed** | 发现准确 / Finding is accurate | 源代码支持所有主张 / Source code supports all claims |

## 挑战模式 / Challenge Patterns

### 模式 1：类型声明检查 / Pattern 1: Type Declaration Check
```
Claim: "Type X is not declared"
Challenge: Read the type file → check if X exists in type union/enum
Counter: "Line N shows X IS declared in the type definition"
```

### 模式 2：设计引用验证 / Pattern 2: Design Reference Verification
```
Claim: "Design requires N items, implementation has M"
Challenge: Read design doc → verify the claimed requirement
Counter: "Design doc actually specifies K items, not N"
```

### 模式 3：用法验证 / Pattern 3: Usage Verification
```
Claim: "Code uses type X but X is not defined"
Challenge: Check both usage site AND definition site
Counter: "X is defined at line N in file Y"
```

### 模式 4：范围混淆 / Pattern 4: Scope Confusion
```
Claim: "Missing 7 edge types (total should be 28)"
Challenge: Check what the "28" actually refers to
Counter: "The 28 refers to language types, not edge types; edge types are 21"
```

## 输出格式 / Output Format

挑战产出 markdown 报告：

The challenge produces a markdown report:

```markdown
## Challenge Report: <finding_id>

**Verdict**: <overturned|weakened|confirmed>
**Confidence**: <0-100>%
**Adjusted Severity**: <none|critical|high|medium|low>

### Original Finding
<finding summary>

### Counter-Evidence
- <evidence point 1>
- <evidence point 2>

### Supporting Evidence
- <evidence point 1> (if any)

### Reasoning
<detailed explanation>

### Recommendation
<action recommendation>
```

## 错误处理 / Error Handling

| 场景 Scenario | 处理 Resolution |
|----------|------------|
| 引用文件不存在 / Referenced file not found | 报告文件缺失；结论 = weakened（可能已过时） / Report file missing; verdict = weakened (potentially stale) |
| 行号超出范围 / Line number out of range | 搜索主张内容；调整行引用 / Search for the claimed content; adjust line reference |
| 设计文档未找到 / Design doc not found | 跳过设计验证；在报告中注明 / Skip design verification; note in report |
| 证据模糊 / Ambiguous evidence | 呈现双方观点；降低置信度 / Present both sides; lower confidence score |
| 批量多个发现 / Multiple findings batch | 逐个独立处理；产出每个发现的结论 / Process each independently; produce per-finding verdicts |

## 使用示例 / Usage Examples

### 单个发现挑战 / Single Finding Challenge
```
Invoke the insight-challenge skill with:
{"id":"HIGH-01","title":"...","file":"src/types.ts","line":58,...}
```

### 批量挑战 / Batch Challenge
```
Invoke the insight-challenge skill with: findings.json
```

### 内联挑战 / Inline Challenge
```
Challenge this finding:
Claim: Function X is not exported
File: src/utils.ts:45
Evidence: grep shows no export keyword
```

## 相关技能 / Related Skills

- **team-adversarial-swarm**：多智能体对抗分析 / Multi-agent adversarial analysis
- **team-quality-assurance**：带问题发现的 QA 流水线 / QA pipeline with issue discovery
- **codify-to-knowhow**：沉淀已验证知识 / Capturing verified knowledge

## 范围与限制 / Scope & Limitations

本技能用于**对照源代码对代码质量发现进行对抗性审查**。**不适用**于：

This skill is for **adversarial review of code-quality findings against source code**. It is **not** suitable for:

- 纯安全审计或漏洞扫描（使用专用安全审查工具）/ Security-only audits or vulnerability scanning (use a dedicated security review tool).
- 没有具体发现可挑战的完整 MR/PR 通用代码审查 / Generic code review of a full MR/PR without specific findings to challenge.
- 无法对照可访问的源代码、设计文档或运行时证据验证的发现——此时输出 `weakened` 并注明证据不可用 / Findings that cannot be verified against accessible source code, design docs, or runtime evidence — in that case output `weakened` with a note that evidence is unavailable.
- 无可验证事实主张的纯风格或偏好类发现 / Style-only or preference-based findings with no factual claim to verify.

## 常见问题 / FAQ

**Q: 源文件不存在怎么办？ / What if the source file doesn't exist?**  
A: 输出 `weakened` 并降低置信度。注明文件缺失为原因；不要猜测发现是错的。  
A: Output `weakened` with confidence lowered. Note the missing file as the reason; do not guess the finding is wrong.

**Q: 多个发现互相矛盾怎么办？ / What if multiple findings contradict each other?**  
A: 逐个独立挑战。若一个发现的证据推翻另一个，在 `reasoning` 字段中注明冲突。  
A: Challenge each independently. If one finding's evidence overturns another, note the conflict in the `reasoning` field.

**Q: 可以不读源代码就确认发现吗？ / Can I confirm a finding without reading the source?**  
A: 不行。始终对照源代码验证。若源代码不可访问，降低置信度并说明。  
A: No. Always verify against the source. If the source is inaccessible, lower confidence and say so.

**Q: `confidence` 如何决定？ / How is `confidence` decided?**  
A: 90–100 = 源代码直接证明结论；70–89 = 证据充分但有小缺口；低于 70 = 证据部分或模糊。绝不编造置信度——用收集到的证据证明。  
A: 90–100 = source directly proves the verdict; 70–89 = strong evidence with minor gaps; below 70 = evidence is partial or ambiguous. Never fabricate confidence — justify it with the evidence collected.

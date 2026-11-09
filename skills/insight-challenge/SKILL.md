---
name: insight-challenge
slug: yumingtao-insight-challenge
displayName: Insight Challenge
version: 1.1.1
summary: Adversarial review of code quality findings with source-anchored counter-evidence and structured verdicts.
license: MIT
disable-model-invocation: true
description: "Adversarial review of code quality findings. Challenges insights with counter-evidence, verifies claims against source code, and produces structured verdicts. Triggers on 'insight-challenge', 'challenge finding', '审查发现'."
allowed-tools: Read(*), Glob(*), Grep(*), Bash(*), Write(*)
session-mode: none
---

# Insight Challenge

Adversarial review of code quality findings. Challenges insights with counter-evidence, verifies claims against source code, and produces structured verdicts.

**适用场景**: 当需要对代码审查、质量分析、或架构评估中的发现进行对抗性验证时使用。

## Architecture

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

## Key Design Principles

1. **Adversarial by Default**: Assume findings may be incorrect; seek counter-evidence first
2. **Source-Code Anchored**: All claims must be verified against actual code, not assumptions
3. **Structured Output**: Verdicts follow a fixed schema for downstream consumption
4. **Fair Challenge**: If evidence supports the finding, confirm it; don't manufacture doubt
5. **Transparent Reasoning**: Show the chain of evidence and reasoning

## Finding Input Format

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

## Execution Flow

### Phase 1: Parse Finding

1. Extract finding ID, title, severity, file reference, and claims
2. Identify all verifiable assertions:
   - File existence claims
   - Code structure claims (types, functions, variables)
   - Behavioral claims (usage patterns, dependencies)
   - Design conformance claims
3. Create verification checklist

### Phase 2: Source Review

1. Read the referenced file(s) at the specified lines
2. Search for related code using Grep/Glob
3. Document actual state of the code:
   - What types/functions actually exist
   - What values are actually declared
   - What the actual implementation looks like
4. Compare claims against reality

### Phase 3: Challenge Analysis

For each claim in the finding:

1. **Seek confirming evidence**: Does the source code support this claim?
2. **Seek disconfirming evidence**: Does the source code contradict this claim?
3. **Check for misinterpretation**: Could the claim be based on outdated code or misunderstanding?
4. **Verify design references**: Are cited design docs accurate?

Challenge strategies:
- **Direct contradiction**: Source code explicitly shows the opposite
- **Context omission**: Finding omits relevant context that changes the interpretation
- **Stale reference**: Finding references code that has been updated
- **Miscounted**: Numeric claims (missing N types) are incorrect
- **Scope error**: Finding applies wrong scope (e.g., confuses edge types with language types)

### Phase 4: Verdict Report

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

## Verdict Definitions

| Verdict | Meaning | When to Use |
|---------|---------|-------------|
| **overturned** | Finding is factually incorrect | Source code directly contradicts the claim |
| **weakened** | Finding is partially correct but overstated | Some evidence supports it, but severity/scope is wrong |
| **confirmed** | Finding is accurate | Source code supports all claims |

## Challenge Patterns

### Pattern 1: Type Declaration Check
```
Claim: "Type X is not declared"
Challenge: Read the type file → check if X exists in type union/enum
Counter: "Line N shows X IS declared in the type definition"
```

### Pattern 2: Design Reference Verification
```
Claim: "Design requires N items, implementation has M"
Challenge: Read design doc → verify the claimed requirement
Counter: "Design doc actually specifies K items, not N"
```

### Pattern 3: Usage Verification
```
Claim: "Code uses type X but X is not defined"
Challenge: Check both usage site AND definition site
Counter: "X is defined at line N in file Y"
```

### Pattern 4: Scope Confusion
```
Claim: "Missing 7 edge types (total should be 28)"
Challenge: Check what the "28" actually refers to
Counter: "The 28 refers to language types, not edge types; edge types are 21"
```

## Output Format

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

## Error Handling

| Scenario | Resolution |
|----------|------------|
| Referenced file not found | Report file missing; verdict = weakened (potentially stale) |
| Line number out of range | Search for the claimed content; adjust line reference |
| Design doc not found | Skip design verification; note in report |
| Ambiguous evidence | Present both sides; lower confidence score |
| Multiple findings batch | Process each independently; produce per-finding verdicts |

## Usage Examples

### Single Finding Challenge
```
Invoke the insight-challenge skill with:
{"id":"HIGH-01","title":"...","file":"src/types.ts","line":58,...}
```

### Batch Challenge
```
Invoke the insight-challenge skill with: findings.json
```

### Inline Challenge
```
Challenge this finding:
Claim: Function X is not exported
File: src/utils.ts:45
Evidence: grep shows no export keyword
```

## Related Skills

- **team-adversarial-swarm**: Multi-agent adversarial analysis
- **team-quality-assurance**: QA pipeline with issue discovery
- **codify-to-knowhow**: Capturing verified knowledge

## Scope & Limitations

This skill is for **adversarial review of code-quality findings against
source code**. It is **not** suitable for:

- Security-only audits or vulnerability scanning (use a dedicated security
  review tool).
- Generic code review of a full MR/PR without specific findings to challenge.
- Findings that cannot be verified against accessible source code, design docs,
  or runtime evidence — in that case output `weakened` with a note that
  evidence is unavailable.
- Style-only or preference-based findings with no factual claim to verify.

## FAQ

**Q: What if the source file doesn't exist?**
A: Output `weakened` with confidence lowered. Note the missing file as the
reason; do not guess the finding is wrong.

**Q: What if multiple findings contradict each other?**
A: Challenge each independently. If one finding's evidence overturns another,
note the conflict in the `reasoning` field.

**Q: Can I confirm a finding without reading the source?**
A: No. Always verify against the source. If the source is inaccessible, lower
confidence and say so.

**Q: How is `confidence` decided?**
A: 90–100 = source directly proves the verdict; 70–89 = strong evidence with
minor gaps; below 70 = evidence is partial or ambiguous. Never fabricate
confidence — justify it with the evidence collected.

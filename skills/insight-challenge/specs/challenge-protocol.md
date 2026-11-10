# 挑战协议规范 / Challenge Protocol Specification

## 概述 / Overview

本协议定义了挑战代码质量发现的系统方法。目标是在采取行动前确保发现准确，减少误报和浪费的努力。

This protocol defines the systematic approach to challenging code quality findings. The goal is to ensure findings are accurate before action is taken, reducing false positives and wasted effort.

## 挑战方法论 / Challenge Methodology

### 步骤 1：主张分解 / Step 1: Claim Decomposition

把发现拆成原子的、可验证的主张：

Break the finding into atomic, verifiable claims:

1. **存在性主张 Existence claims**: "X exists/does not exist in file Y" / "X 在文件 Y 中存在/不存在"
2. **行为主张 Behavior claims**: "Function X does Y when Z" / "函数 X 在 Z 时执行 Y"
3. **结构主张 Structure claims**: "Type X has N members" / "类型 X 有 N 个成员"
4. **符合性主张 Conformance claims**: "Implementation deviates from design by X" / "实现因 X 偏离设计"
5. **数值主张 Numeric claims**: "Missing N items (expected M, found K)" / "缺少 N 项（期望 M，找到 K）"

每个主张必须可独立验证。

Each claim must be independently verifiable.

### 步骤 2：证据收集 / Step 2: Evidence Collection

对每个主张，收集：

For each claim, collect:

1. **主要证据 Primary evidence**: 直接读取源代码 / Direct source code reading
2. **次要证据 Secondary evidence**: 相关文件、导入、类型定义 / Related files, imports, type definitions
3. **设计证据 Design evidence**: 引用的设计文档 / Referenced design documents
4. **用法证据 Usage evidence**: 代码实际如何被使用 / How the code is actually used

证据层级：
Evidence hierarchy:
- Source code > Design docs > Comments > Assumptions
- 源代码 > 设计文档 > 注释 > 假设

### 步骤 3：对抗性分析 / Step 3: Adversarial Analysis

应用以下挑战策略：

Apply these challenge strategies:

#### 策略 A：直接验证 / Strategy A: Direct Verification
读取引用的确切文件和行。主张与现实相符吗？
Read the exact file and line referenced. Does the claim match reality?

```
Claim: "Line 58: type X is missing"
Action: Read line 58 of the file
Result: Line 58 shows type X IS present → claim overturned
```

#### 策略 B：上下文扩展 / Strategy B: Context Expansion
主张可能技术上正确但因脱离上下文而误导。
The claim may be technically correct but misleadingly decontextualized.

```
Claim: "Function X has no error handling"
Action: Read the full function and its callers
Result: Error handling is done by callers → claim weakened
```

#### 策略 C：范围纠正 / Strategy C: Scope Correction
主张可能混淆了不同的范围或命名空间。
The claim may confuse different scopes or namespaces.

```
Claim: "28 edge types required, only 21 found"
Action: Check what "28" refers to in design docs
Result: 28 = language types, not edge types → claim overturned
```

#### 策略 D：时间检查 / Strategy D: Temporal Check
主张可能引用了过时的代码。
The claim may reference outdated code.

```
Claim: "File X uses deprecated API Y"
Action: Check git history and current code
Result: API was updated last week → claim overturned
```

#### 策略 E：完整性检查 / Strategy E: Completeness Check
主张可能部分正确但不完整。
The claim may be partially correct but incomplete.

```
Claim: "Type X is missing from union"
Action: Check all union members
Result: X is present but Y is actually missing → claim weakened
```

### 步骤 4：结论判定 / Step 4: Verdict Determination

使用此决策树：

Use this decision tree:

```
Is the primary claim factually incorrect?
  ├─ Yes → verdict = "overturned"
  └─ No → Is the severity/scope overstated?
       ├─ Yes → verdict = "weakened"
       └─ No → Is the claim accurate?
            ├─ Yes → verdict = "confirmed"
            └─ Uncertain → verdict = "weakened" (lower confidence)
```

### 步骤 5：置信度评分 / Step 5: Confidence Scoring

| 置信度 Confidence | 含义 Meaning |
|------------|---------|
| 90-100% | 清晰、无歧义的证据 / Clear, unambiguous evidence |
| 70-89% | 证据充分，有轻微不确定性 / Strong evidence with minor uncertainty |
| 50-69% | 证据混合；需要判断 / Mixed evidence; judgment call |
| 低于 50% Below 50% | 证据不足；建议进一步调查 / Insufficient evidence; recommend further investigation |

影响置信度的因素：
Factors affecting confidence:
- Source code clarity / 源代码清晰度
- Design doc availability / 设计文档可用性
- Claim specificity / 主张具体性
- Evidence completeness / 证据完整性

## 反模式 / Anti-Patterns

### 1. 确认偏差 / Confirmation Bias
**错误 Wrong**: 只寻找支持发现的证据 / Looking only for evidence that supports the finding
**正确 Right**: 先主动寻找反证 / Actively seeking counter-evidence first

### 2. 制造怀疑 / Manufactured Doubt
**错误 Wrong**: 没有真实反证却挑战发现 / Challenging findings without real counter-evidence
**正确 Right**: 只在证据真正矛盾时挑战 / Only challenge when evidence genuinely contradicts

### 3. 吹毛求疵 / Nitpicking
**错误 Wrong**: 挑战琐碎细节而忽视核心问题 / Challenging trivial details while ignoring core issues
**正确 Right**: 聚焦影响发现有效性的主张 / Focus on claims that affect the finding's validity

### 4. 范围蔓延 / Scope Creep
**错误 Wrong**: 把挑战扩展到发现主张之外 / Expanding the challenge beyond the finding's claims
**正确 Right**: 只处理发现所断言的内容 / Address only what the finding asserts

## 输出质量标准 / Output Quality Criteria

一份好的挑战报告：

A good challenge report:

1. **具体 Specific**: 引用确切的文件路径和行号 / References exact file paths and line numbers
2. **可验证 Verifiable**: 反证可被独立核对 / Counter-evidence can be independently checked
3. **公正 Fair**: 存在支持证据时予以承认 / Acknowledges supporting evidence when present
4. **可执行 Actionable**: 提供清晰建议 / Provides clear recommendation
5. **相称 Proportional**: 置信度与证据强度匹配 / Confidence matches evidence strength

## 集成点 / Integration Points

### 与质量流水线 / With Quality Pipeline
- 高严重度发现可自动触发挑战 / Challenge can be triggered automatically for high-severity findings
- 结果反馈到发现置信度评分 / Results feed back into finding confidence scores
- 被推翻的发现标记用于改进模板 / Overturned findings are flagged for template improvement

### 与知识系统 / With Knowledge System
- 已确认的发现可捕获为 knowhow / Confirmed findings can be captured as knowhow
- 挑战模式可编码为评审规范 / Challenge patterns can be codified as review specs
- 常见误报模式成为学习材料 / Common false-positive patterns become learning material

### 与团队技能 / With Team Skills
- 挑战可委派给专门智能体 / Challenge can be delegated to specialized agents
- 结果为团队评分和收敛提供信息 / Results inform team scoring and convergence
- 对抗模式与 team-adversarial-swarm 对齐 / Adversarial patterns align with team-adversarial-swarm

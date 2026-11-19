# TRACE 自检档

本文件是 SkillHub 官方技能 `skillhub-trace-evaluator` 公开评分参考的改写，不是原文。改写只保留维护时要用的 1–5 分档。原文在 <https://github.com/Tencent/skillhub/tree/main/skills/skillhub-trace-evaluator/references>。

以下版权声明和 MIT 许可正文来自该仓库，按原许可证保留：

```text
Tencent is pleased to support the open source community by making skillhub available.

Copyright (C) 2026 Tencent. All rights reserved.

skillhub is licensed under MIT. skillhub does not impose any additional restrictions beyond those specified in the license.

Terms of the MIT License:
--------------------------------------------------------------------
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice (including the next paragraph) shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
```

`trust.scan` 不评。本技能不做安全扫描，不编造扫描分，也不收录科恩实验室或云鼎实验室的检测规则。

某一子项达不到 4 分档，就可以成为一条维护缺口。维护技能用这些档位找缺口，不发布一份对外的 TRACE 总分。

## Trust

### domestic（本地化适配）— 要评

| 分 | 标准 |
|---|---|
| 5 | 完全支持中文交互；依赖可直接访问；适配所声明的工具链 |
| 4 | 基本支持中文，少量提示为另一种语言；可正常使用 |
| 3 | 部分支持中文，核心可用，部分依赖不易直接访问 |
| 2 | 中文不完整，较多依赖不易直接访问 |
| 1 | 只支持一种语言，或关键依赖难以直接使用 |

### scan（安全扫描）— 不评

固定跳过。平台报告里点名的那一句可以作为外部信号，技能正文不据此补写扫描规则。

## Reliability

### stability（运行稳定性）

| 分 | 标准 |
|---|---|
| 5 | 有重试、超时或明确的恢复步骤；重复执行不改变已确认的结果 |
| 4 | 基本稳定，异常时有退路 |
| 3 | 大部分情况可完成，缺少一部分容错 |
| 2 | 容易出现未处理的异常 |
| 1 | 没有容错 |

### func（功能完善性）

| 分 | 标准 |
|---|---|
| 5 | 声明的功能都有步骤；输入有校验；缺省行为已写明 |
| 4 | 核心功能完整，少量边缘未写 |
| 3 | 主要路径可用，有重要功能未写 |
| 2 | 只实现了部分核心功能 |
| 1 | 只有骨架 |

### errorHandling（异常处理）

| 分 | 标准 |
|---|---|
| 5 | 有错误码，提示能引导下一步 |
| 4 | 异常有处理，提示基本可读 |
| 3 | 有基本处理，提示不够明确 |
| 2 | 一部分错误没有提示 |
| 1 | 失败时没有提示 |

## Adaptability

### boundary（能力边界）

| 分 | 标准 |
|---|---|
| 5 | 写明能做与不能做、适用场景、输入输出约束 |
| 4 | 大部分边界已写，少量限制未写 |
| 3 | 只写了一部分边界 |
| 2 | 边界很少，容易用错 |
| 1 | 没有边界说明 |

### trigger（触发方式）

| 分 | 标准 |
|---|---|
| 5 | 写明如何触发、有示例、条件无歧义 |
| 4 | 触发基本明确，示例较少 |
| 3 | 有说明，部分场景仍含糊 |
| 2 | 需要猜测如何使用 |
| 1 | 没有使用说明 |

## Convention

### progressive（渐进式披露）

| 分 | 标准 |
|---|---|
| 5 | 协调器保持薄，细节按需打开，不一次堆满 |
| 4 | 层次较清楚 |
| 3 | 有层次，部分顺序不合理 |
| 2 | 层次不清楚 |
| 1 | 信息堆在一处 |

### structure（结构清晰）

| 分 | 标准 |
|---|---|
| 5 | 目录、模块、命名一致，找得到入口 |
| 4 | 结构基本清楚 |
| 3 | 部分模块划分不合理 |
| 2 | 难找关键内容 |
| 1 | 文件杂乱 |

### docQuality（文档质量）

| 分 | 标准 |
|---|---|
| 5 | 有多个典型用例和输出样例 |
| 4 | 有用例和样例，覆盖主要路径 |
| 3 | 只有少量例子 |
| 2 | 只有一句示例，没有场景 |
| 1 | 没有用例或输出样例 |

### antiPatternFaq（反模式与 FAQ）

| 分 | 标准 |
|---|---|
| 5 | 写明不该怎么用，FAQ 覆盖高频问题 |
| 4 | 有反模式和 FAQ，覆盖主要问题 |
| 3 | 只有少量提示 |
| 2 | 只有一句警告 |
| 1 | 没有反模式或 FAQ |

## Effectiveness

文档型技能按流程是否可执行、输出模板是否清楚来判断。没有跑过的结果不要写成已经验证。

### accuracy（输出准确性）

| 分 | 标准 |
|---|---|
| 5 | 提案字段固定，且与技能里的规则一致 |
| 4 | 整体可用，偶有小瑕疵 |
| 3 | 基本可用，部分场景含糊 |
| 2 | 输出经常对不上规则 |
| 1 | 格式混乱 |

### completeness（内容完整度）

| 分 | 标准 |
|---|---|
| 5 | 单条维护、整维对照、确认后写入、版本规则都有步骤 |
| 4 | 主要路径完整，极端组合未写 |
| 3 | 简单路径可以走，复杂路径不足 |
| 2 | 只有简单路径 |
| 1 | 只有一句目标 |

### usability（开箱即用度）

| 分 | 标准 |
|---|---|
| 5 | 按触发词可直接走到提案；确认前后的界限清楚 |
| 4 | 基本可走完，少量地方要猜 |
| 3 | 能走通，流程不够清楚 |
| 2 | 流程有明显断点 |
| 1 | 无法开始 |

### creativity（创造力与增值）

| 分 | 标准 |
|---|---|
| 5 | 在评分档之外给出可复用的判断，并仍然守住档位 |
| 4 | 有额外的优先级或交接 |
| 3 | 覆盖档位本身 |
| 2 | 只重复维度名字 |
| 1 | 没有可执行内容 |

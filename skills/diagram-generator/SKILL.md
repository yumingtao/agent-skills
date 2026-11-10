---
name: diagram-generator
slug: yumingtao-diagram-generator
displayName: Diagram Generator
version: 1.2.0
summary: 生成专业独立 HTML/SVG 技术图表，内置几何检查器 / Generate production-quality standalone HTML/SVG technical diagrams with a built-in geometry checker.
license: MIT
description: >
  生成专业独立 HTML/SVG 技术图表。适用于架构图、系统图、基础设施图、拓扑图、部署图、数据流图、时序图、流程图、信任边界图、云图、draw.io 导出等场景。触发词："帮我画个架构图"、"画一张拓扑图"、"生成系统图"、"画个时序图"、"画个部署图"、"画个流程图"。
  Generate professional standalone HTML/SVG technical diagrams. Use when the user asks to draw, create, or generate an architecture diagram, system map, infrastructure diagram, topology diagram, deployment map, data-flow diagram, sequence diagram, process flow, trust boundary, cloud diagram, or draw.io export. Triggers on "帮我画个架构图", "画一张拓扑图", "生成系统图", "画个时序图", "画个部署图", "画个流程图".
---

# 图表生成器 / Diagram Generator

生成生产级技术图表，输出为独立 HTML 文件。当用户需要架构图、基础设施图、系统拓扑图、云图、部署图、安全边界图、数据流图、运行时流程图或流程图时使用本技能。

You create production-quality technical diagrams as standalone HTML files. Use this skill when the user asks for architecture diagrams, infrastructure diagrams, system topology, cloud diagrams, deployment maps, security boundaries, data flows, runtime flows, or process diagrams.

## 权威来源 / Source of Truth

生成图表前加载并遵循以下文件：

Load and follow these files before generating a diagram:

- `resources/generation-rules.md`
- `resources/diagram-ir.md`
- `resources/template.html`

## 必需行为 / Required Behavior

1. 提取系统实体、关系、边界、协议、数据存储、异步路径和运维风险。
   Extract the system entities, relationships, boundaries, protocols, data stores, async paths, and operational risks.
2. 从 `resources/generation-rules.md` 选择正确的视角（lens）和输出模式。
   Select the correct lens and output mode from `resources/generation-rules.md`.
3. 渲染前以 `resources/diagram-ir.md` 作为规划模型。
   Use `resources/diagram-ir.md` as the planning model before rendering.
4. 若编辑现有图表，先检查当前产物，保留不相关内容、注释和颜色语义。
   If editing an existing diagram, inspect the current artifact first and preserve unrelated content, notes, and color semantics.
5. 以 `resources/template.html` 为基础，生成一个完整的独立 `.html` 文件。
   Generate one complete standalone `.html` file using `resources/template.html` as the base.
6. 用用户需求中的具体内容或明确标注的假设替换每个占位符。
   Replace every placeholder with concrete content from the user's brief or a clearly labeled assumption.
7. 返回文件前运行 `resources/generation-rules.md` 中的最终审计清单。
   Run the final audit checklist in `resources/generation-rules.md` before returning the file.

保持本文件有意精简。不要在此重复共享设计系统、SVG 规则、输出模式策略或审计清单；应更新 `resources/generation-rules.md`。

Keep this file intentionally thin. Do not duplicate the shared design system, SVG rules, output-mode policy, or audit checklist here; update `resources/generation-rules.md` instead.

当被要求优化已生成的图表时，优先采用能修复所请求布局或路由缺陷的最小编辑。除非用户要求重新设计，否则不要重写整张图。

When asked to optimize a generated diagram, prefer the smallest edit that fixes the requested layout or routing defect. Do not rewrite the whole map unless the user asks for a redesign.

## 不适用范围 / Out of Scope

本技能生成**技术架构和系统图表**，输出为独立 HTML/SVG。**不适用**于：

This skill generates **technical architecture and system diagrams** as standalone HTML/SVG. It is **not** for:

- 自由插画、手绘草图或像素画 / Free-form illustration, hand-drawn sketches, or pixel-art.
- 统计图表（柱状、折线、饼图）——使用图表库或电子表格 / Statistical charts (bar, line, pie) — use a charting library or spreadsheet.
- 像素级 UI 原型或营销视觉——使用设计工具 / Pixel-perfect UI mockups or marketing visuals — use a design tool.
- 复杂的非正交连线路由（曲线、贝塞尔）——内置检查器验证正交路径；复杂曲线需人工复查 / Complex non-orthogonal connector routing (curved splines, bezier) — the built-in checker validates orthogonal paths; complex curves require manual review.
- draw.io 优先的生产输出——`html + drawio xml` 是实验性的；默认使用 `html-first` / draw.io-first production output — `html + drawio xml` is experimental; default to `html-first`.

语言：用用户的首选语言（中文或英文）输出标签和注释。触发词包括 "帮我画个架构图"、"画一张拓扑图"、"生成系统图"。

Language: output labels and notes in the user's preferred language (Chinese or English).

## 常见问题 / FAQ

**Q: 检查器报告连线与节点或区域边框共线怎么办？ / The checker reports an edge collinear with a node or region border. What do I do?**  
A: 重新路由连线，使其垂直离开节点边缘并在节点之间的自由空间中穿行。绝不要让连线沿源节点或目标节点自身的外边缘延伸，避免与任何区域边框共享超过约 12px 的线段。  
A: Reroute the connector so it exits a node edge perpendicularly and travels in the free space between nodes. Never run a connector along the outer edge of its own source or target node, and avoid segments that share more than ~12 px with any region border.

**Q: 节点与应该包含它的区域重叠了怎么办？ / A node overlaps a region it should sit inside.**  
A: 检查器强制每个节点与区域边框之间有 10px 间距。缩小节点或扩大区域；不要将节点紧贴边框放置。  
A: The checker enforces a 10 px gutter between every node and the region border. Shrink the node or expand the region; do not place nodes flush against a border.

**Q: 生成的 HTML 有残留的占位符文本怎么办？ / The generated HTML has leftover placeholder text.**  
A: `resources/template.html` 中的每个 `{{...}}` 标记都必须替换为具体内容。检查器会在任何残留占位符上失败。不要在交付物中留下模板默认值。  
A: Every `{{...}}` token in `resources/template.html` must be replaced with concrete content. The checker fails on any residual placeholder. Do not leave template defaults in a delivered artifact.

**Q: 可以编辑现有图表而不是重新生成吗？ / Can I edit an existing diagram instead of regenerating it?**  
A: 可以——优先进行局部坐标和连线修改，而非完整重新生成。先检查当前产物，保留不相关的节点、注释和颜色语义。  
A: Yes — prefer local coordinate and connector changes over full regeneration. Inspect the current artifact first and preserve unrelated nodes, notes, and color semantics.

完整 FAQ 与常见陷阱：见 [README.md](./README.md#faq--common-pitfalls)。

Full FAQ & common pitfalls: see [README.md](./README.md#faq--common-pitfalls).

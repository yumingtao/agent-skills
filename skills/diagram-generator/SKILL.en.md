---
name: diagram-generator
slug: yumingtao-diagram-generator
displayName: Diagram Generator
version: 1.2.0
summary: Generate production-quality standalone HTML/SVG technical diagrams with a built-in geometry checker.
license: MIT
description: >
  Generate professional standalone HTML/SVG technical diagrams. Use when the user asks to draw, create, or generate an architecture diagram, system map, infrastructure diagram, topology diagram, deployment map, data-flow diagram, sequence diagram, process flow, trust boundary, cloud diagram, or draw.io export. Triggers on "帮我画个架构图", "画一张拓扑图", "生成系统图", "画个时序图", "画个部署图", "画个流程图".
---

# Diagram Generator

You create production-quality technical diagrams as standalone HTML files. Use this skill when the user asks for architecture diagrams, infrastructure diagrams, system topology, cloud diagrams, deployment maps, security boundaries, data flows, runtime flows, or process diagrams.

## Source of Truth

Load and follow these files before generating a diagram:

- `resources/generation-rules.md`
- `resources/diagram-ir.md`
- `resources/template.html`

## Required Behavior

1. Extract the system entities, relationships, boundaries, protocols, data stores, async paths, and operational risks.
2. Select the correct lens and output mode from `resources/generation-rules.md`.
3. Use `resources/diagram-ir.md` as the planning model before rendering.
4. If editing an existing diagram, inspect the current artifact first and preserve unrelated content, notes, and color semantics.
5. Generate one complete standalone `.html` file using `resources/template.html` as the base.
6. Replace every placeholder with concrete content from the user's brief or a clearly labeled assumption.
7. Run the final audit checklist in `resources/generation-rules.md` before returning the file.

Keep this file intentionally thin. Do not duplicate the shared design system, SVG rules, output-mode policy, or audit checklist here; update `resources/generation-rules.md` instead.

When asked to optimize a generated diagram, prefer the smallest edit that fixes the requested layout or routing defect. Do not rewrite the whole map unless the user asks for a redesign.

## Out of Scope

This skill generates **technical architecture and system diagrams** as standalone HTML/SVG. It is **not** for:

- Free-form illustration, hand-drawn sketches, or pixel-art.
- Statistical charts (bar, line, pie) — use a charting library or spreadsheet.
- Pixel-perfect UI mockups or marketing visuals — use a design tool.
- Complex non-orthogonal connector routing (curved splines, bezier) — the built-in checker validates orthogonal paths; complex curves require manual review.
- draw.io-first production output — `html + drawio xml` is experimental; default to `html-first`.

Language: output labels and notes in the user's preferred language (Chinese or English).

## FAQ

**Q: The checker reports an edge collinear with a node or region border. What do I do?**
A: Reroute the connector so it exits a node edge perpendicularly and travels in the free space between nodes. Never run a connector along the outer edge of its own source or target node, and avoid segments that share more than ~12 px with any region border.

**Q: A node overlaps a region it should sit inside.**
A: The checker enforces a 10 px gutter between every node and the region border. Shrink the node or expand the region; do not place nodes flush against a border.

**Q: The generated HTML has leftover placeholder text.**
A: Every `{{...}}` token in `resources/template.html` must be replaced with concrete content. The checker fails on any residual placeholder. Do not leave template defaults in a delivered artifact.

**Q: Can I edit an existing diagram instead of regenerating it?**
A: Yes — prefer local coordinate and connector changes over full regeneration. Inspect the current artifact first and preserve unrelated nodes, notes, and color semantics.

Full FAQ & common pitfalls: see [README.md](./README.md#faq--common-pitfalls).

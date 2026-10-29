# Release Checklist

Use this checklist before publishing the package.

## Package Hygiene

- [ ] No local smoke-test HTML files are present.
- [ ] `LICENSE` is present.
- [ ] `.gitignore` excludes generated diagram artifacts.
- [ ] README describes the package as a platform-neutral system map generator.
- [ ] README does not mention external source projects.
- [ ] Platform entrypoints stay thin and route to `resources/`.

## Resource Integrity

- [ ] `resources/generation-rules.md` is the source of behavior rules.
- [ ] `resources/template.html` is the source of HTML/SVG/CSS structure.
- [ ] `resources/diagram-ir.md` describes the shared planning model.
- [ ] No duplicated design principles are copied into platform entrypoints.
- [ ] Default mode remains `html-first`.
- [ ] draw.io remains experimental and opt-in; `drawio-first` is not advertised as stable.

## Smoke Tests

- [ ] Claude Desktop generates atlas-style output.
- [ ] Codex generates atlas-style output.
- [ ] Gemini follows the shared rules when resources are attached.
- [ ] Copilot follows the repository instruction source.
- [ ] CodeBuddy follows the workspace rule file.
- [ ] Cursor, OpenCode, or Windsurf follows `AGENTS.md`.

## Generated Artifact Checks

### Machine-checked (run `node scripts/check-diagram.mjs <output.html>` and paste the result)

```
node scripts/check-diagram.mjs <output.html>
```

The checker exits 0 (PASSED) when all of the following hold — **do not ship if it exits 1**:

- No placeholder text remains (`System Map Title`, `One sentence that states...`, etc.).
- Notes rail (`<aside class="notes">`) is present.
- No external asset references — artifact is self-contained.
- Every `marker-end` URL resolves to a matching `<marker id="...">` in `<defs>`.
- IR nodes are inside the viewBox (no coordinate overflow).
- No two IR nodes overlap (pairwise bounds intersection).
- IR edge endpoints reference known node IDs.

### Human-judgment checks (visual inspection required)

- [ ] SVG ID is `system-map` or an intentional replacement.
- [ ] Export buttons are present and functional.
- [ ] No draw.io UI is visible in `html-first` mode.
- [ ] Map key fits inside the viewBox.
- [ ] Artifact was rendered to a raster image and visually inspected.
- [ ] No label overflows its pill or node, and no box covers a label or region title.
- [ ] No arrowhead ends in empty space; every connector touches its target edge.
- [ ] Connector arrowhead colors match connector stroke colors.
- [ ] Control/dependency edges form real chains, not parallel fans at one target.
- [ ] Existing-diagram edit flow preserves unrelated content and notes unless a redesign was requested.
- [ ] Sibling spacing and multi-target fan-out are visually balanced.
- [ ] Vertical gutters between adjacent rows or stacked regions are intentionally consistent.

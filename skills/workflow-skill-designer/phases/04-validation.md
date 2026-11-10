# 阶段 4：校验与集成

校验生成的技能包的结构完整性、引用完整性和内容质量。产出校验报告和集成摘要。

## 目标

- 验证所有必需文件存在
- 校验 SKILL.md 引用与实际阶段文件匹配
- 检查内容保留（针对命令提取源）
- 验证跨阶段数据流一致性
- 向用户报告校验结果

## 步骤 4.1：结构校验

```javascript
function validateStructure(config) {
  const skillDir = `.claude/skills/${config.skillName}`;
  const results = { errors: [], warnings: [], info: [] };

  // Check SKILL.md exists
  const skillMdExists = fileExists(`${skillDir}/SKILL.md`);
  if (!skillMdExists) {
    results.errors.push('SKILL.md not found');
  }

  // Check all phase files exist
  for (const phase of config.phases) {
    const filename = `${String(phase.number).padStart(2, '0')}-${phase.slug}.md`;
    const filepath = `${skillDir}/phases/${filename}`;
    if (!fileExists(filepath)) {
      results.errors.push(`Phase file missing: ${filepath}`);
    }
  }

  // Check SKILL.md frontmatter
  if (skillMdExists) {
    const skillMd = Read(`${skillDir}/SKILL.md`);
    // extractYAMLFrontmatter() is reference pseudocode — use the host's real frontmatter parser
    const fm = extractYAMLFrontmatter(skillMd);

    if (!fm.name) results.errors.push('Frontmatter missing: name');
    if (!fm.description) results.errors.push('Frontmatter missing: description');
    if (!fm['allowed-tools']) results.errors.push('Frontmatter missing: allowed-tools');

    // Check description has trigger phrase
    if (fm.description && !fm.description.includes('Triggers on')) {
      results.warnings.push('Description missing trigger phrase (Triggers on "...")');
    }
  }

  return results;
}
```

## 步骤 4.2：引用完整性

```javascript
function validateReferences(config) {
  const skillDir = `.claude/skills/${config.skillName}`;
  const results = { errors: [], warnings: [], info: [] };
  const skillMd = Read(`${skillDir}/SKILL.md`);

  // Extract all Ref: markers from SKILL.md
  const refMarkers = skillMd.match(/Ref: phases\/\S+\.md/g) || [];
  const linkedFiles = skillMd.match(/\[phases\/\S+\.md\]\(phases\/\S+\.md\)/g) || [];

  // Collect all referenced phase files
  const referencedFiles = new Set();
  for (const ref of refMarkers) {
    referencedFiles.add(ref.replace('Ref: ', ''));
  }
  for (const link of linkedFiles) {
    const match = link.match(/\(phases\/\S+\.md\)/);
    if (match) referencedFiles.add(match[0].replace(/[()]/g, ''));
  }

  // Check each referenced file exists
  for (const refFile of referencedFiles) {
    if (!fileExists(`${skillDir}/${refFile}`)) {
      results.errors.push(`Referenced file not found: ${refFile}`);
    }
  }

  // Check each phase file is referenced in SKILL.md
  for (const phase of config.phases) {
    const filename = `phases/${String(phase.number).padStart(2, '0')}-${phase.slug}.md`;
    if (!referencedFiles.has(filename)) {
      results.warnings.push(`Phase file not referenced in SKILL.md: ${filename}`);
    }
  }

  // Check Phase Reference Documents table exists
  if (!skillMd.includes('Phase Reference Documents')) {
    results.errors.push('SKILL.md missing Phase Reference Documents table');
  }

  // Check Phase Reference Documents table has entries for all phases
  for (const phase of config.phases) {
    const filename = `${String(phase.number).padStart(2, '0')}-${phase.slug}.md`;
    if (!skillMd.includes(filename)) {
      results.errors.push(`Phase Reference table missing entry for: ${filename}`);
    }
  }

  return results;
}
```

## 步骤 4.3：内容质量（仅命令提取）

```javascript
function validateContentQuality(config) {
  const skillDir = `.claude/skills/${config.skillName}`;
  const results = { errors: [], warnings: [], info: [] };

  if (config.source.type !== 'command_set') {
    results.info.push('Content quality check skipped (not command extraction)');
    return results;
  }

  for (const phase of config.phases) {
    if (!phase.sourcePath) continue;

    const sourceContent = Read(phase.sourcePath);
    const sourceBody = removeYAMLFrontmatter(sourceContent);
    const filename = `${String(phase.number).padStart(2, '0')}-${phase.slug}.md`;
    const phaseContent = Read(`${skillDir}/phases/${filename}`);

    // Line count comparison
    const sourceLines = sourceBody.split('\n').length;
    const phaseLines = phaseContent.split('\n').length;
    const ratio = phaseLines / sourceLines;

    if (ratio < 0.7) {
      results.errors.push(
        `Phase ${phase.number} content loss: source=${sourceLines} lines, phase=${phaseLines} lines (${Math.round(ratio * 100)}%)`
      );
    } else if (ratio < 0.9) {
      results.warnings.push(
        `Phase ${phase.number} possible content reduction: source=${sourceLines}, phase=${phaseLines} (${Math.round(ratio * 100)}%)`
      );
    } else {
      results.info.push(
        `Phase ${phase.number} content preserved: source=${sourceLines}, phase=${phaseLines} (${Math.round(ratio * 100)}%)`
      );
    }

    // Code block count comparison
    const sourceBlocks = (sourceBody.match(/```/g) || []).length / 2;
    const phaseBlocks = (phaseContent.match(/```/g) || []).length / 2;
    if (phaseBlocks < sourceBlocks) {
      results.warnings.push(
        `Phase ${phase.number} missing code blocks: source=${sourceBlocks}, phase=${phaseBlocks}`
      );
    }

    // Agent prompt preservation
    const sourceAgents = (sourceBody.match(/Task\(|subagent_type/g) || []).length;
    const phaseAgents = (phaseContent.match(/Task\(|subagent_type/g) || []).length;
    if (phaseAgents < sourceAgents) {
      results.errors.push(
        `Phase ${phase.number} missing agent calls: source=${sourceAgents}, phase=${phaseAgents}`
      );
    }
  }

  return results;
}
```

## 步骤 4.4：数据流一致性

```javascript
function validateDataFlow(config) {
  const skillDir = `.claude/skills/${config.skillName}`;
  const results = { errors: [], warnings: [], info: [] };
  const skillMd = Read(`${skillDir}/SKILL.md`);

  // Check all data flow variables are mentioned in SKILL.md
  for (const flow of config.dataFlow) {
    for (const variable of flow.variables) {
      if (!skillMd.includes(variable)) {
        results.warnings.push(
          `Data flow variable '${variable}' (${flow.from} → ${flow.to}) not found in SKILL.md`
        );
      }
    }
  }

  // Check conditional phases have their condition in SKILL.md
  for (const phase of config.phases) {
    if (phase.isConditional && phase.condition) {
      // Extract the key variable from condition
      const condVar = phase.condition.match(/\w+/)?.[0];
      if (condVar && !skillMd.includes(condVar)) {
        results.errors.push(
          `Conditional Phase ${phase.number} condition variable '${condVar}' not found in SKILL.md`
        );
      }
    }
  }

  return results;
}
```

## 步骤 4.5：SKILL.md 章节完整性

```javascript
function validateSkillMdSections(config) {
  const skillDir = `.claude/skills/${config.skillName}`;
  const results = { errors: [], warnings: [], info: [] };
  const skillMd = Read(`${skillDir}/SKILL.md`);

  // Required sections
  const requiredSections = [
    { name: 'Architecture Overview', pattern: /## Architecture Overview/ },
    { name: 'Execution Flow', pattern: /## Execution Flow/ },
    { name: 'Core Rules', pattern: /## Core Rules/ },
    { name: 'Data Flow', pattern: /## Data Flow/ },
    { name: 'Error Handling', pattern: /## Error Handling/ }
  ];

  // Recommended sections
  const recommendedSections = [
    { name: 'Key Design Principles', pattern: /## Key Design Principles/ },
    { name: 'Input Processing', pattern: /## Input Processing/ },
    { name: 'TodoWrite Pattern', pattern: /## TodoWrite Pattern/ },
    { name: 'Coordinator Checklist', pattern: /## Coordinator Checklist/ },
    { name: 'Related Commands', pattern: /## Related Commands/ }
  ];

  // Conditional sections
  const conditionalSections = [
    { name: 'Interactive Preference Collection', pattern: /## Interactive Preference Collection/, condition: config.features.hasAutoMode },
    { name: 'Auto Mode Defaults', pattern: /## Auto Mode Defaults/, condition: config.features.hasAutoMode },
    { name: 'Post-Phase Updates', pattern: /## Post-Phase Updates/, condition: config.features.hasPostPhaseUpdates }
  ];

  for (const section of requiredSections) {
    if (!section.pattern.test(skillMd)) {
      results.errors.push(`Missing required section: ${section.name}`);
    }
  }

  for (const section of recommendedSections) {
    if (!section.pattern.test(skillMd)) {
      results.warnings.push(`Missing recommended section: ${section.name}`);
    }
  }

  for (const section of conditionalSections) {
    if (section.condition && !section.pattern.test(skillMd)) {
      results.warnings.push(`Missing conditional section: ${section.name} (feature enabled but section absent)`);
    }
  }

  return results;
}
```

## 步骤 4.6：阶段文件卫生

```javascript
function validatePhaseFileHygiene(config) {
  const skillDir = `.claude/skills/${config.skillName}`;
  const results = { errors: [], warnings: [], info: [] };

  const prohibitedPatterns = [
    {
      name: 'Flag parsing ($ARGUMENTS)',
      regex: /\$ARGUMENTS\.includes/g,
      severity: 'error',
      fix: 'Replace with workflowPreferences.{key} reference'
    },
    {
      name: 'Invocation syntax (/skill-name)',
      regex: /\/\w+[\-:]\w+\s+["']/g,
      severity: 'warning',
      fix: 'Remove (phase files are not user-facing docs)'
    },
    {
      name: 'Conversion provenance (Source: Converted from)',
      regex: /Source:.*Converted from/g,
      severity: 'warning',
      fix: 'Remove (implementation detail)'
    },
    {
      name: 'Skill routing for inter-phase (Skill(skill=...)',
      regex: /Skill\(skill=/g,
      severity: 'error',
      fix: 'Replace with direct Read("phases/0N-xxx.md")'
    },
    {
      name: 'CLI flag definitions (--flag)',
      regex: /^\s*-\w,\s+--\w+\s+/gm,
      severity: 'warning',
      fix: 'Move flag definitions to SKILL.md Interactive Preference Collection'
    }
  ];

  for (const phase of config.phases) {
    const filename = `${String(phase.number).padStart(2, '0')}-${phase.slug}.md`;
    const filepath = `${skillDir}/phases/${filename}`;
    if (!fileExists(filepath)) continue;

    const content = Read(filepath);

    for (const pattern of prohibitedPatterns) {
      const matches = content.match(pattern.regex);
      if (matches && matches.length > 0) {
        const msg = `Phase ${phase.number} (${filename}): ${pattern.name} found (${matches.length} occurrence(s)). Fix: ${pattern.fix}`;
        if (pattern.severity === 'error') {
          results.errors.push(msg);
        } else {
          results.warnings.push(msg);
        }
      }
    }
  }

  if (results.errors.length === 0 && results.warnings.length === 0) {
    results.info.push('Phase file hygiene: All phase files clean ✓');
  }

  return results;
}
```

## 步骤 4.7：汇总结果并报告

```javascript
function generateValidationReport(config) {
  const structural = validateStructure(config);
  const references = validateReferences(config);
  const content = validateContentQuality(config);
  const dataFlow = validateDataFlow(config);
  const sections = validateSkillMdSections(config);
  const hygiene = validatePhaseFileHygiene(config);

  // Aggregate
  const allErrors = [
    ...structural.errors,
    ...references.errors,
    ...content.errors,
    ...dataFlow.errors,
    ...sections.errors,
    ...hygiene.errors
  ];
  const allWarnings = [
    ...structural.warnings,
    ...references.warnings,
    ...content.warnings,
    ...dataFlow.warnings,
    ...sections.warnings,
    ...hygiene.warnings
  ];
  const allInfo = [
    ...structural.info,
    ...references.info,
    ...content.info,
    ...dataFlow.info,
    ...sections.info,
    ...hygiene.info
  ];

  // Quality gate
  const gate = allErrors.length === 0 ? 'PASS' :
               allErrors.length <= 2 ? 'REVIEW' : 'FAIL';

  // Display report
  const skillDir = `.claude/skills/${config.skillName}`;

  console.log(`
╔══════════════════════════════════════╗
║   Workflow Skill Validation Report   ║
╠══════════════════════════════════════╣
║  Skill: ${config.skillName.padEnd(28)}║
║  Gate:  ${gate.padEnd(28)}║
╚══════════════════════════════════════╝

Structure:
  ${skillDir}/
  ├── SKILL.md                    ${fileExists(`${skillDir}/SKILL.md`) ? '✓' : '✗'}
  └── phases/
${config.phases.map(p => {
  const fn = `${String(p.number).padStart(2, '0')}-${p.slug}.md`;
  return `      ├── ${fn.padEnd(30)} ${fileExists(`${skillDir}/phases/${fn}`) ? '✓' : '✗'}`;
}).join('\n')}

${allErrors.length > 0 ? `Errors (${allErrors.length}):\n${allErrors.map(e => `  ✗ ${e}`).join('\n')}` : 'Errors: None ✓'}

${allWarnings.length > 0 ? `Warnings (${allWarnings.length}):\n${allWarnings.map(w => `  ⚠ ${w}`).join('\n')}` : 'Warnings: None ✓'}

${allInfo.length > 0 ? `Info:\n${allInfo.map(i => `  ℹ ${i}`).join('\n')}` : ''}
  `);

  return { gate, errors: allErrors, warnings: allWarnings, info: allInfo };
}
```

## 步骤 4.8：错误恢复

```javascript
if (report.gate === 'FAIL') {
  const recovery = AskUserQuestion({
    questions: [{
      question: `Validation found ${report.errors.length} errors. How to proceed?`,
      header: "Recovery",
      multiSelect: false,
      options: [
        { label: "Auto-fix", description: "Attempt automatic fixes for common issues" },
        { label: "Regenerate phases", description: "Re-run Phase 3 with stricter preservation" },
        { label: "Accept as-is", description: "Proceed despite errors (manual fix later)" }
      ]
    }]
  });

  if (recovery === 'Auto-fix') {
    // Common auto-fixes:
    // 1. Missing Next Phase links → add them
    // 2. Missing Output sections → add from config
    // 3. Missing Phase Reference table → generate from config
    autoFixCommonIssues(config, report.errors);
    // Re-validate
    return generateValidationReport(config);
  }
}
```

## 步骤 4.9：集成摘要

```javascript
function displayIntegrationSummary(config) {
  console.log(`
Integration Complete:
  Location: .claude/skills/${config.skillName}/
  Files: ${config.phases.length + 1} (SKILL.md + ${config.phases.length} phases)

Usage:
  Trigger: ${config.triggers.map(t => `"${t}"`).join(', ')}
Design Patterns Applied:
  ✓ Progressive phase loading (Ref: markers)
  ✓ Phase Reference Documents table
  ✓ Phase file hygiene (no flag parsing, no invocation syntax)
  ${config.features.hasTodoWriteSubTasks ? '✓' : '○'} TodoWrite attachment/collapse
  ${config.features.hasConditionalPhases ? '✓' : '○'} Conditional phase execution
  ${config.features.hasAutoMode ? '✓' : '○'} Interactive preference collection (AskUserQuestion)
  ${config.features.hasPostPhaseUpdates ? '✓' : '○'} Post-phase state updates
  ${config.features.hasPlanningNotes ? '✓' : '○'} Accumulated planning notes

Next Steps:
  1. Review SKILL.md orchestrator logic
  2. Review each phase file for completeness
  3. Test skill invocation with trigger phrase
  4. Iterate based on execution results
  `);
}
```

## 输出

- **报告**: 含质量关卡（PASS/REVIEW/FAIL）的校验结果
- **TodoWrite**: 标记阶段 4 已完成（所有任务完成）

## 完成

工作流技能设计器已完成。生成的技能包位于 `.claude/skills/{skillName}/`。

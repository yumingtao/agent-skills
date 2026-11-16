#!/usr/bin/env node
// session-retrospective 反馈日志校验器 —— 零依赖，Node >= 18
// 用法: node validate-feedback.mjs <log-path>
// 退出码: 0 = 日志健康; 1 = 存在校验错误或损坏行; 2 = 无法读取/参数缺失
import { readFileSync } from 'node:fs';

const ENUMS = {
  platform: ['claude', 'codex', 'codebuddy', 'cursor', 'trae', 'github-copilot', 'intellij-copilot', 'gemini', 'opencode', 'other'],
  area: ['planning', 'implementation', 'review', 'git-pr', 'mcp', 'environment', 'docs', 'other'],
  result: ['success', 'blocked', 'corrected', 'failed'],
  issue_type: ['none', 'gate-skipped', 'wrong-routing', 'mcp-error', 'skill-sync-missing', 'generated-code-hygiene', 'logging-convention', 'utility-reuse', 'title-format', 'ticket-field', 'auth', 'tool-error', 'other'],
  priority: ['low', 'medium', 'high'],
};
const REQUIRED = ['timestamp', 'platform', 'area', 'result', 'issue_type', 'notes'];

const path = process.argv[2];
if (!path) {
  console.error('用法: node validate-feedback.mjs <log-path>');
  process.exit(2);
}

let raw;
try {
  raw = readFileSync(path, 'utf8');
} catch (e) {
  console.error(`无法读取日志: ${e.message}`);
  process.exit(2);
}

const errors = [];
const corrupted = [];
const entries = [];

raw.split('\n').forEach((line, i) => {
  const no = i + 1;
  const s = line.trim();
  if (!s) return;
  let obj;
  try {
    obj = JSON.parse(s);
  } catch {
    corrupted.push(no); // SR-E04: 跳过损坏行，不重写
    return;
  }
  const errs = [];
  for (const f of REQUIRED) if (!(f in obj)) errs.push(`缺字段 ${f}`);
  for (const [f, values] of Object.entries(ENUMS)) {
    if (f in obj && obj[f] !== undefined && !values.includes(obj[f])) errs.push(`${f}="${obj[f]}" 不在枚举内`);
  }
  if (typeof obj.notes === 'string' && obj.notes.length > 200) errs.push(`notes ${obj.notes.length} 字符 > 200`);
  if (obj.timestamp !== undefined && !/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}/.test(String(obj.timestamp))) errs.push('timestamp 非 ISO-8601');
  if (errs.length) {
    errors.push({ no, errs });
    return;
  }
  obj.__line = no;
  entries.push(obj);
});

// 复发候选统计（success / issue_type=none 不参与）：按枚举配对计数，
// 配对相同 ≠ 问题实质相同 —— 是否复发由执行者确认后再标 recurring
const groups = new Map();
for (const e of entries) {
  if (e.result === 'success' || e.issue_type === 'none') continue;
  const key = `${e.area}+${e.issue_type}`;
  const g = groups.get(key) ?? { count: 0, missing: [] };
  g.count += 1;
  if (g.count >= 2 && !/recurring/i.test(String(e.notes))) g.missing.push(e.__line);
  groups.set(key, g);
}

console.log(`条目 ${entries.length} 条；损坏行 ${corrupted.length} 条${corrupted.length ? `（行号: ${corrupted.join(', ')}）` : ''}`);
if (errors.length) {
  console.log('校验错误:');
  for (const { no, errs } of errors) console.log(`  行 ${no}: ${errs.join('; ')}`);
}
const recurring = [...groups.entries()].filter(([, v]) => v.count >= 2).sort((a, b) => b[1].count - a[1].count);
if (recurring.length) {
  console.log('复发候选分组（按枚举配对统计、次数排序；是否「问题实质相同」由执行者确认后再标 recurring，修复模式从次数最多的候选组开始）:');
  for (const [key, v] of recurring) {
    console.log(`  ${key} × ${v.count}${v.missing.length ? `（第2次及以后未标 recurring 的行: ${v.missing.join(', ')}）` : ''}`);
  }
}

process.exit(errors.length || corrupted.length ? 1 : 0);

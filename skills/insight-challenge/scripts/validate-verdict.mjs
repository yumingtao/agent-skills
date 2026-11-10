#!/usr/bin/env node
// validate-verdict.mjs — validate an insight-challenge verdict (single or batch)
// against specs/verdict-schema.md. Zero dependencies; fail-closed.
import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';

const RESULTS = new Set(['overturned', 'weakened', 'confirmed']);
const SEVERITIES = new Set(['none', 'critical', 'high', 'medium', 'low']);

function validateVerdict(v, path, errors, warnings) {
  const p = (s) => `${path}${s}`;
  if (typeof v !== 'object' || v === null || Array.isArray(v)) {
    errors.push(`${p('')}: verdict must be a JSON object [IC-V00]`);
    return;
  }
  if (typeof v.finding_id !== 'string' || v.finding_id.length === 0)
    errors.push(`${p('.finding_id')}: required non-empty string [IC-V01]`);
  if (!RESULTS.has(v.challenge_result))
    errors.push(`${p('.challenge_result')}: must be one of overturned|weakened|confirmed [IC-V02]`);
  if (!Number.isInteger(v.confidence) || v.confidence < 0 || v.confidence > 100)
    errors.push(`${p('.confidence')}: required integer 0-100 [IC-V03]`);
  if (typeof v.reasoning !== 'string' || v.reasoning.length === 0)
    errors.push(`${p('.reasoning')}: required non-empty string [IC-V04]`);
  for (const key of ['counter_evidence', 'supporting_evidence']) {
    if (v[key] !== undefined && (!Array.isArray(v[key]) || v[key].some((e) => typeof e !== 'string')))
      errors.push(`${p('.' + key)}: must be an array of strings [IC-V05]`);
  }
  if (v.adjusted_severity !== undefined && !SEVERITIES.has(v.adjusted_severity))
    errors.push(`${p('.adjusted_severity')}: must be one of none|critical|high|medium|low [IC-V06]`);
  if (v.challenge_result === 'overturned' && (!Array.isArray(v.counter_evidence) || v.counter_evidence.length === 0))
    warnings.push(`${p('.counter_evidence')}: expected non-empty for an overturned verdict [IC-W01]`);
  if (v.challenge_result === 'confirmed' && (!Array.isArray(v.supporting_evidence) || v.supporting_evidence.length === 0))
    warnings.push(`${p('.supporting_evidence')}: expected non-empty for a confirmed verdict [IC-W02]`);
}

const [inputPath] = process.argv.slice(2);
if (!inputPath) {
  console.error('Usage: node scripts/validate-verdict.mjs <path-to-verdict.json>');
  process.exit(1);
}
let raw;
try {
  raw = readFileSync(resolve(inputPath), 'utf8');
} catch (err) {
  console.error(`Cannot read input file: ${inputPath} (${err.code || err.message})`);
  console.error('Usage: node scripts/validate-verdict.mjs <path-to-verdict.json>');
  process.exit(1);
}
let doc;
try {
  doc = JSON.parse(raw);
} catch (err) {
  console.error(`[IC-V07] Invalid JSON: ${err.message}`);
  process.exit(1);
}

const errors = [];
const warnings = [];
const isBatch = Array.isArray(doc.verdicts);
if (isBatch) {
  if (doc.verdicts.length === 0) errors.push('.verdicts: batch must contain at least one verdict [IC-V08]');
  doc.verdicts.forEach((v, i) => validateVerdict(v, `.verdicts[${i}]`, errors, warnings));
} else {
  validateVerdict(doc, '', errors, warnings);
}

if (errors.length > 0) {
  console.error(`validate-verdict: FAILED (${errors.length} error${errors.length > 1 ? 's' : ''})`);
  for (const e of errors) console.error(`  - ${e}`);
  process.exit(1);
}
const count = isBatch ? doc.verdicts.length : 1;
console.log(`validate-verdict: PASSED (${isBatch ? 'batch, ' : ''}${count} verdict${count > 1 ? 's' : ''})`);
for (const w of warnings) console.log(`  warning: ${w}`);

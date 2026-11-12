/**
 * yumingtao-dsh-skills host plugin: installs four agent skills into the DSH
 * skill discovery root when the web profile boots.
 *
 * The four skills are:
 *   - diagram-generator       production HTML/SVG diagram generation
 *   - clarify-before-acting   direction-changing ambiguity resolution
 *   - insight-challenge       adversarial review of code-quality findings
 *   - workflow-skill-designer meta-skill for orchestrator+phases workflow skills
 *
 * Skills are copied from the packaged `skills/` directory into the user-global
 * skill root (~/.agents/skills), which DSH and Codex CLI both discover at tier
 * 500.
 *
 * Installation is idempotent: a skill directory that already exists with
 * byte-identical files is left untouched. Set force: true in the plugin config
 * to always overwrite.
 */
import { cpSync, existsSync, mkdirSync, readdirSync, readFileSync, statSync } from 'node:fs'
import { join } from 'node:path'
import { homedir } from 'node:os'
import { fileURLToPath } from 'node:url'

/** Cordis plugin name used by loader diagnostics. */
export const name = 'yumingtao-dsh-skills'

/** The four skill directory names shipped in this bundle. */
const SKILL_IDS = [
  'diagram-generator',
  'clarify-before-acting',
  'insight-challenge',
  'workflow-skill-designer',
]

/** Package-local skill source directory. */
const SOURCE_DIR = fileURLToPath(new URL('./skills/', import.meta.url))

/**
 * The user-global skill root. DSH and Codex CLI both discover skills here at
 * tier 500 (~/.agents/skills). Honour DSH_USER_ROOT / DSH_HOME if set so the
 * install lands in the same tree DSH actually scans.
 */
function skillRoot() {
  const candidates = []
  if (process.env.DSH_USER_ROOT) candidates.push(join(process.env.DSH_USER_ROOT, '.agents', 'skills'))
  if (process.env.DSH_HOME) candidates.push(join(process.env.DSH_HOME, '.agents', 'skills'))
  candidates.push(join(homedir(), '.agents', 'skills'))
  return candidates[0]
}

/** Recursively collect relative file paths under a directory. */
function listFiles(dir) {
  const out = []
  for (const entry of readdirSync(dir, { withFileTypes: true })) {
    const full = join(dir, entry.name)
    if (entry.isDirectory()) {
      out.push(...listFiles(full).map((f) => join(entry.name, f)))
    } else {
      out.push(entry.name)
    }
  }
  return out
}

/** True when every packaged file of a skill is byte-identical to the installed copy. */
function skillUpToDate(skillId, targetDir) {
  const srcDir = join(SOURCE_DIR, skillId)
  if (!existsSync(targetDir)) return false
  const files = listFiles(srcDir)
  return files.every((file) => {
    const src = join(srcDir, file)
    const tgt = join(targetDir, file)
    if (!existsSync(tgt)) return false
    if (statSync(src).size !== statSync(tgt).size) return false
    return readFileSync(src).equals(readFileSync(tgt))
  })
}

/** Install (or skip) a single packaged skill. */
function installSkill(skillId, force) {
  const targetDir = join(skillRoot(), skillId)
  const srcDir = join(SOURCE_DIR, skillId)
  if (!force && skillUpToDate(skillId, targetDir)) {
    console.log(`[${name}] skill "${skillId}" already up to date at ${targetDir}`)
    return false
  }
  mkdirSync(targetDir, { recursive: true })
  cpSync(srcDir, targetDir, { recursive: true, force: true })
  console.log(`[${name}] installed skill "${skillId}" -> ${targetDir}`)
  return true
}

/**
 * Cordis bundle entry point. Called on profile boot with the host context and
 * the row config (which may carry force: true).
 */
export function apply(ctx, config = {}) {
  const force = config.force === true
  const root = skillRoot()
  mkdirSync(root, { recursive: true })
  let installed = 0
  for (const id of SKILL_IDS) {
    if (installSkill(id, force)) installed++
  }
  console.log(`[${name}] done: ${installed} skill(s) installed into ${root}`)
}

/**
 * @yumingtao/agent-skills: installs all seven bundled agent skills into the DSH
 * skill discovery root when the web profile boots.
 *
 * Each skill is copied from dsh-plugin/packages/<name>/skill/ into the
 * user-global skill root (~/.agents/skills/<name>), which DSH and Codex CLI
 * both discover at tier 500.
 *
 * Installation is idempotent: a skill directory that already exists with
 * byte-identical files is left untouched. Set force: true in the plugin config
 * to always overwrite.
 */
import { cpSync, existsSync, mkdirSync, readdirSync, readFileSync, statSync } from 'node:fs'
import { join } from 'node:path'
import { homedir } from 'node:os'
import { fileURLToPath } from 'node:url'

export const name = '@yumingtao/agent-skills'

const SKILL_IDS = [
  'diagram-generator',
  'clarify-before-acting',
  'insight-challenge',
  'workflow-skill-designer',
  'defect-detective',
  'session-retrospective',
  'skill-maintainer',
]

const PACKAGES_BASE = fileURLToPath(new URL('./dsh-plugin/packages/', import.meta.url))

function skillRoot() {
  const candidates = []
  if (process.env.DSH_USER_ROOT) candidates.push(join(process.env.DSH_USER_ROOT, '.agents', 'skills'))
  if (process.env.DSH_HOME) candidates.push(join(process.env.DSH_HOME, '.agents', 'skills'))
  candidates.push(join(homedir(), '.agents', 'skills'))
  return candidates[0]
}

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

function skillUpToDate(sourceDir, targetDir) {
  if (!existsSync(targetDir)) return false
  const files = listFiles(sourceDir)
  return files.every((file) => {
    const src = join(sourceDir, file)
    const tgt = join(targetDir, file)
    if (!existsSync(tgt)) return false
    if (statSync(src).size !== statSync(tgt).size) return false
    return readFileSync(src).equals(readFileSync(tgt))
  })
}

export function apply(ctx, config = {}) {
  const force = config.force === true
  const root = skillRoot()
  mkdirSync(root, { recursive: true })

  for (const skillId of SKILL_IDS) {
    const sourceDir = join(PACKAGES_BASE, skillId, 'skill')
    if (!existsSync(sourceDir)) {
      console.warn(`[${name}] skill "${skillId}" source not found at ${sourceDir}, skipping`)
      continue
    }
    const targetDir = join(root, skillId)
    if (!force && skillUpToDate(sourceDir, targetDir)) {
      console.log(`[${name}] skill "${skillId}" already up to date at ${targetDir}`)
      continue
    }
    mkdirSync(targetDir, { recursive: true })
    cpSync(sourceDir, targetDir, { recursive: true, force: true })
    console.log(`[${name}] installed skill "${skillId}" -> ${targetDir}`)
  }
}

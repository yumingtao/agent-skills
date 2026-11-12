/**
 * yumingtao-workflow-skill-designer: installs the workflow-skill-designer agent skill into the DSH skill discovery
 * root when the web profile boots.
 *
 * The skill is copied from the packaged `skill/` directory into the
 * user-global skill root (~/.agents/skills), which DSH and Codex CLI both
 * discover at tier 500.
 *
 * Installation is idempotent: a skill directory that already exists with
 * byte-identical files is left untouched. Set force: true in the plugin config
 * to always overwrite.
 */
import { cpSync, existsSync, mkdirSync, readdirSync, readFileSync, statSync } from 'node:fs'
import { join } from 'node:path'
import { homedir } from 'node:os'
import { fileURLToPath } from 'node:url'

export const name = 'yumingtao-workflow-skill-designer'

const SKILL_ID = 'workflow-skill-designer'
const SOURCE_DIR = fileURLToPath(new URL('./skill/', import.meta.url))

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

function skillUpToDate(targetDir) {
  if (!existsSync(targetDir)) return false
  const files = listFiles(SOURCE_DIR)
  return files.every((file) => {
    const src = join(SOURCE_DIR, file)
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
  const targetDir = join(root, SKILL_ID)
  if (!force && skillUpToDate(targetDir)) {
    console.log(`[${name}] skill "${SKILL_ID}" already up to date at ${targetDir}`)
    return
  }
  mkdirSync(targetDir, { recursive: true })
  cpSync(SOURCE_DIR, targetDir, { recursive: true, force: true })
  console.log(`[${name}] installed skill "${SKILL_ID}" -> ${targetDir}`)
}

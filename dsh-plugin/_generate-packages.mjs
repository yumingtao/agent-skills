// One-off generator: creates the four standalone npm packages under packages/.
// Run from dsh-plugin/: node _generate-packages.mjs
import { cpSync, mkdirSync, readFileSync, writeFileSync } from 'node:fs'
import { join } from 'node:path'

const repoRoot = new URL('../', import.meta.url).pathname
const skillsRoot = join(repoRoot, 'skills')
const packagesRoot = join(repoRoot, 'dsh-plugin', 'packages')

const skills = [
  {
    id: 'diagram-generator',
    description: 'Generate production-quality standalone HTML/SVG technical diagrams: architecture, infrastructure, topology, deployment, data flow, trust boundary, and process maps.',
    keywords: ['dsh', 'dsh-plugin', 'diagram', 'architecture', 'svg', 'agent-skill'],
  },
  {
    id: 'clarify-before-acting',
    description: 'Resolve direction-changing ambiguity before acting on complex, ambiguous, or high-cost requests. Skips trivial, mechanical, low-risk tasks.',
    keywords: ['dsh', 'dsh-plugin', 'clarify', 'requirements', 'agent-skill'],
  },
  {
    id: 'insight-challenge',
    description: 'Adversarial review of code-quality findings. Challenges insights with counter-evidence, verifies claims against source code, and produces structured verdicts.',
    keywords: ['dsh', 'dsh-plugin', 'code-review', 'adversarial', 'agent-skill'],
  },
  {
    id: 'workflow-skill-designer',
    description: 'Meta-skill for designing orchestrator + phases structured workflow skills with progressive phase loading, task tracking, and inter-phase data flow.',
    keywords: ['dsh', 'dsh-plugin', 'workflow', 'meta-skill', 'agent-skill'],
  },
]

for (const s of skills) {
  const pkgDir = join(packagesRoot, s.id)
  const skillSrc = join(skillsRoot, s.id)
  const pkgName = `yumingtao-${s.id}`

  // Copy skill content into skill/ subdirectory (preserve mtimes so
  // sync.sh --check stays clean on regenerated copies).
  cpSync(skillSrc, join(pkgDir, 'skill'), { recursive: true, preserveTimestamps: true })

  // package.json
  const pkg = {
    name: pkgName,
    version: '1.0.0',
    description: s.description,
    type: 'module',
    main: 'index.js',
    files: ['cordis.patch.yml', 'index.js', 'skill/', 'README.md', 'LICENSE'],
    dsh: { bundle: { patch: './cordis.patch.yml' } },
    keywords: s.keywords,
    license: 'MIT',
    author: 'yumingtao',
    homepage: `https://github.com/yumingtao/agent-skills/tree/main/skills/${s.id}`,
    repository: {
      type: 'git',
      url: 'git+https://github.com/yumingtao/agent-skills.git',
      directory: `dsh-plugin/packages/${s.id}`,
    },
    bugs: { url: 'https://github.com/yumingtao/agent-skills/issues' },
  }
  writeFileSync(join(pkgDir, 'package.json'), JSON.stringify(pkg, null, 2) + '\n')

  // cordis.patch.yml
  const patch = `# ${pkgName} bundle: installs the ${s.id} agent skill into the DSH
# skill discovery root on web profile boot.
#
# Activate with:
#   dsh plugin --profile web add ${pkgName}
#
# On boot the row copies the packaged skill directory into the user-global
# skill root (~/.agents/skills). Installation is idempotent.
- insert:
  - id: ${pkgName}
    name: '${pkgName}'
`
  writeFileSync(join(pkgDir, 'cordis.patch.yml'), patch)

  // index.js
  const index = `/**
 * ${pkgName}: installs the ${s.id} agent skill into the DSH skill discovery
 * root when the web profile boots.
 *
 * The skill is copied from the packaged \`skill/\` directory into the
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

export const name = '${pkgName}'

const SKILL_ID = '${s.id}'
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
    console.log(\`[\${name}] skill "\${SKILL_ID}" already up to date at \${targetDir}\`)
    return
  }
  mkdirSync(targetDir, { recursive: true })
  cpSync(SOURCE_DIR, targetDir, { recursive: true, force: true })
  console.log(\`[\${name}] installed skill "\${SKILL_ID}" -> \${targetDir}\`)
}
`
  writeFileSync(join(pkgDir, 'index.js'), index)

  // README.md
  const readme = `# ${pkgName}

A [DSH](https://www.dsh.so) bundle that installs the \`${s.id}\` agent skill into
your DSH skill discovery root.

${s.description}

## Install

\`\`\`bash
dsh plugin --profile web add ${pkgName}
\`\`\`

Or from the GitHub repository directly:

\`\`\`bash
dsh plugin --profile web add github:yumingtao/agent-skills#path:/dsh-plugin/packages/${s.id}
\`\`\`

On first boot of the web profile the bundle copies the skill directory into
\`~/.agents/skills\` (the user-global skill root shared by DSH and Codex CLI).

## Force update

By default the installer skips the skill when its installed files are
byte-identical to the packaged ones. To force an overwrite, configure the row
with \`force: true\`:

\`\`\`yaml
- id: ${pkgName}
  name: '${pkgName}'
  config:
    force: true
\`\`\`

## License

MIT
`
  writeFileSync(join(pkgDir, 'README.md'), readme)

  // LICENSE (copy from repo root)
  cpSync(join(repoRoot, 'LICENSE'), join(pkgDir, 'LICENSE'))

  console.log(`created ${pkgName}@1.0.0`)
}

console.log('done')

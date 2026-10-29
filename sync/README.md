# sync

A generalized "one source → many platforms" distributor for this collection.

The canonical source is the collection itself: `skills/<skill>/`. A platform
target is any directory that receives one sub-directory per skill. There is no
build step, no package manager, and no runtime — just a declared map plus two
shell scripts.

## Layout

```text
sync/
├── README.md     this file
├── manifest.sh   the distribution map (declared exactly once)
├── apply.sh      writer: canonical -> platform targets
└── check.sh      verifier: targets vs canonical (CI-safe with --collection-only)
```

## Usage

```bash
# Link every skill into every detected platform (default: symlinks)
sync/apply.sh

# Preview without writing
sync/apply.sh --dry-run

# Materialize real copies instead of symlinks
sync/apply.sh --copy

# Restrict scope
sync/apply.sh --platform claude --skill insight-challenge

# Project-local install (folder ships every adapter; entrypoint is per platform)
sync/apply.sh --to /path/to/project/.agents --platform cursor

# Verify nothing drifted
sync/check.sh
sync/check.sh --collection-only   # repository only, safe for CI
```

`apply.sh` refuses to touch a target that already exists unless `--force` is
passed, and `--dry-run` prints the exact command it would run.

## Distribution modes

| Mode | Command | When |
|---|---|---|
| `link` | `sync/apply.sh` | Default. Keeps exactly one source of truth; edits in the repo are live everywhere. |
| `copy` | `sync/apply.sh --copy` | For platforms or sync tools that cannot follow symlinks. Re-run to refresh; `--force` overwrites. |

Copy mode skips local state declared in `SYNC_COPY_EXCLUDES`
(`.DS_Store`, `.omc/`, `node_modules/`, `*.log`, `*.tmp`, `*.bak`).

## Adding to the map

Everything is declared in `sync/manifest.sh`:

- **A new platform** — append one `PLATFORM_TARGETS` entry:
  `"<id>|<display>|<install-root>|<entrypoint-chain>|<detect>"`.
  - `entrypoint-chain` is a comma-separated list, first existing file wins. It
    names the file to point the agent at on that platform, so a skill that ships
    its own adapter (`AGENTS.md`, `GEMINI.md`, …) is picked up automatically.
  - `detect` is `dir:PATH` or `cmd:NAME` and decides whether the platform is
    auto-detected when `--platform` is omitted.
- **A new skill** — create `skills/<skill>/SKILL.md`. It is discovered
  automatically; no manifest edit needed.

`sync/check.sh` enforces the contract: every skill folder must expose
`SKILL.md`, its frontmatter `name` must equal the folder name, a
`description` must be present, and `README.md` must list exactly the skills on
disk.

## CI

`.github/workflows/ci.yml` runs `bash -n`, `shellcheck`, and
`sync/check.sh --collection-only` on pushes to `main` and on pull requests.

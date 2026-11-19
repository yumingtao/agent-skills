# Public push checklist

Finish the remote and the range in `SKILL.en.md` before filling this in. Every item needs a result.

There are six results:

| Result | Meaning |
|---|---|
| pass | This item has no problem in the current range |
| fail | This item blocks the push |
| not applicable | The repository lacks the files this item depends on, or the range has no change of this kind |
| unread | A binary or unreadable file. This is not a pass |
| skipped | The remote is not public, so the public list does not run |
| unconfirmed | Publicity cannot be determined. This blocks the push |

When the user asked to push, push only if every item is pass or not applicable. Unread, fail, and unconfirmed all stop the push. Skipped is only for a remote confirmed to be private.

## Items

### PP-01 Remote publicity

- Pass: there is evidence the remote is public, or evidence it is not public. When it is not public, mark PP-02 through PP-09 as skipped.
- Unconfirmed: visibility cannot be read. Do not record unconfirmed as pass.
- Report: the remote URL, and public or not public. Do not guess from the repository name.

### PP-02 Secrets

Look only at this range: the diff of commits in range, plus the index and working tree when the same message asks for a commit.

Types that count: private key, API token, bearer credential, password assignment, cloud credential, connection string with a password, environment file that holds a secret.

- Pass: none of these types appear in the range.
- Fail: write the path and the type. Do not write the secret body, and do not write the characters around it.
- A secret already on the remote: when the parent commit is already contained in the remote, mark fail, say "already on the remote", and stop. A new commit does not unpublish it, and history is not rewritten. The file has to leave the commits that are not on the remote yet before the next check. This skill does not rewrite that history.

### PP-03 Email and author identity

The only author is the allowlisted person. Compare these identity fields. Do not compare a product name that merely appears in the commit subject or body:

- Author name, author email, committer name, and committer email of every commit in range
- Trailers that assign authorship, including `Co-authored-by`, `Signed-off-by`, and any other trailer that names a person or an agent as author, sign-off, or generator
- Email addresses in lines the diff adds

A host address that contains noreply counts as author identity.

Allowlist:

- When the repository has `sync/manifest.sh`, read only `SYNC_ALLOWED_EMAILS` from that file. That list stands for the repository owner.
- Without that file, read only an allowlist the repository already declares. If none is declared, this item fails, and the skill asks once where the allowlist should live.
- Do not invent a company-domain list, and do not copy an address into the report or into this skill.

AI author: a name or address in an identity field refers to a coding agent, a chat model, or a bot rather than the allowlisted person. A name of Cursor, Claude, Copilot, ChatGPT, Codex, Gemini, Devin, or a name that presents itself as an agent or a bot, counts as an AI author. That identity still fails after it has been written into the allowlist. Mentioning one of these product names only in the commit subject or body does not count.

- Pass: every name and address belongs to the allowlisted person, and there is no AI author.
- Fail: write the commit or file path, and the field name (author, committer, trailer, file text). For an AI author, write "AI author" in the note. Do not write the address, and do not write the agent's address.

### PP-04 README

A user-visible change includes: a command, an install step, external behavior, a public interface, or a summary in the collection skill table.

- Pass: the range has no user-visible change, and the report says why.
- Pass: there is a user-visible change, and the matching README is updated in the same range. Judge the skill's own README and the collection README against the surface that actually changed.
- Fail: there is a user-visible change and the matching README did not change.
- Not applicable: the repository has no README, and this change adds no user-visible instructions.

### PP-05 Security issues in the diff

Look only at problems this diff introduces. Do not search a vulnerability database, and do not store an outside lab's detection rules.

Kinds to look for: secret material, authentication or authorization turned off in the changed lines, a command built from unsanitized input, a dependency added from an unexpected source.

- Pass: none of these kinds appear in this diff. A pass does not mean the code is secure.
- Fail: write the path and the kind. Do not paste a secret or a ready-to-run payload.

### PP-06 The repository's own public surface

Check a surface only when the repository has the matching files, and only the part this diff touches:

- When a skill has both language files, a behavior change updates both, and the version moves with them
- The collection README skill table, install commands, and badge counts agree with the publication state this diff claims
- A skill already listed in a market index has that index updated in the same range when its version changes

- Not applicable: the repository has none of these files, or the diff touches none of them.
- Pass: the surfaces that were touched agree.
- Fail: language behavior diverges in the same range, a badge or install-command count disagrees with what is actually published, or an index version was left behind.
- A skill kept out of a market index on purpose is consistent by being absent. Do not fail it for that. This list does not require a publish on the side.

### PP-07 Third-party license notice

- Not applicable: this change adds no substantial text written by someone else.
- Pass: the added text keeps that author's copyright line and permission notice in the file.
- Fail: a substantial copy has no copyright line and permission notice. Write the path.

### PP-08 Files that should not be tracked

Use `git ls-files -ci --exclude-standard` for tracked files that also match ignore rules. Also look for logs, temporary fixtures, comparison reports, build output, and local-machine traces added in this range.

Local-machine paths are compared only with prefixes the repository declares. When `sync/manifest.sh` exists, read `SYNC_FORBIDDEN_PATHS` from it. Do not copy those prefixes into this skill.

- Pass: no such file.
- Fail: write the path and the kind (ignore rule, log, temporary fixture, comparison report, build output, local path).

### PP-09 Binaries and unreadable files

Files whose `git diff --numstat` columns are both `-`, and any other object that cannot be read as text.

- Unread: write the path. The result is fixed as "unread, needs a person to confirm". Unread is not a pass, and it blocks an automatic push.
- Pass: the range has no such file.
- Pass: the report already listed the path, and the user then explicitly says that file may be pushed. Write "person confirmed" in the note. Until that sentence, the item stays unread.

## Report

```text
Public push check
Remote: <url> · public / not public / unconfirmed
Range: <revision>..HEAD · <n> commits
Uncommitted changes: outside the range / included in this check

| Item | Result | Note |
|---|---|---|
| PP-01 Remote publicity |  |  |
| PP-02 Secrets |  | path and type |
| PP-03 Email and author identity |  | commit or path, field name; an AI author is marked "AI author" |
| PP-04 README |  | why it changed, or why it can stay |
| PP-05 Security issues in the diff |  | path and kind |
| PP-06 Public surface |  |  |
| PP-07 Third-party license |  |  |
| PP-08 Files that should not be tracked |  | path and kind |
| PP-09 Binaries and unreadable files |  |  |

Conclusion: list passed / stopped, push not done
Note: a passed list is not a safety certification.
```

When stopping, do not include steps that rewrite history. If a file must leave a range that is not on the remote yet, say that it has to be removed, then wait for the next check.

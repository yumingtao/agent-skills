---
name: public-push-check
displayName: Public Push Check
version: 1.0.1
summary: Checks the commits about to be pushed to a public remote against a fixed list. The only author is the allowlisted person. It does not rewrite history. Marked internal — not published to any skill marketplace, and omitted from default skills.sh CLI discovery.
license: MIT
tags:
  - push check
  - public repository
  - workflow
metadata:
  internal: true
description: >
  Runs before commits are pushed to a public remote. Checks the whole unpushed range: secrets, author identity, README updates when a change is user-visible, security issues in the diff, the repository's own public surface, third-party license notices, files that should not be tracked, and unread binaries. The author and the committer must be the person on the repository allowlist. An agent, bot, or model in an identity field fails even if that identity is later added to the allowlist. A remote that is not public skips the list and says so. A failed list blocks the push and does not rewrite history. A git push typed in a terminal does not trigger this skill. Triggers on "推送到公开仓库", "push 前检查", "帮我 push", "before you push".
---

# Public Push Check

This skill runs a fixed list against the range about to be pushed to a public remote. A pass means those items passed. It does not certify the repository as safe.

This skill's version is `1.0.1`. It stays in the repository for maintainers of this repo. Frontmatter sets `metadata.internal: true`: it is omitted from default skills.sh CLI discovery and bulk install; the website listing may lag. It is not published to SkillHub, DSH, ClawHub, or npm. A knowing install (for example an explicit `--skill` or `INSTALL_INTERNAL_SKILLS=1`) may still succeed.

A `git push` typed in a terminal does not invoke this skill. The skill runs only when an agent is asked to push or to check before a push.

## Iron laws

1. **Check first, then push.** When the same message asks for a push, print the list first. Any failure, unconfirmed publicity, or unread file blocks the push.
2. **Do not rewrite history.** Do not force-push, skip hooks, or change git config. A secret already on the remote is reported as already public. A new commit does not unpublish it, and history is not rewritten.
3. **Secrets are reported by path and type.** Do not copy a key, token, password, or private-key body into the report or into a later commit message.
4. **The only author is the allowlisted person.** The author, the committer, and any co-author or sign-off in the commit message must be that same person. An agent, bot, or model in an identity field fails, including when that identity has been written into the allowlist. Do not guess company domains, and do not write any address into this skill. When no allowlist exists, this item fails, and the skill asks once where the allowlist should live.
5. **A push is not a release.** This list does not require a marketplace publish on every git push.

## When to use

- "推送到公开仓库", "push 前检查", "帮我 push", "before you push"
- The same message asks to commit and then push to a public remote

## When not to use

- Commit only, with no push
- The remote is already known to be private. Skip the public list, say so, and do not record the skip as a pass

## Procedure

1. **Name the remote.** Use the remote the user named, otherwise `origin`. Read the URL with `git remote get-url`. For a GitHub repository, read publicity with `gh repo view <owner/repo> --json visibility,isPrivate`. If the lookup fails, or the host is not GitHub and there is no equivalent evidence, mark publicity unconfirmed, stop, and do not push.
2. **Name the range.** With an upstream, use `upstream..HEAD`. With no upstream but `remote/branch` present, use that. For a new branch, use the commits this push would send relative to the remote's default branch, and write down the range actually used. Uncommitted work is outside the push. When the same message asks to commit and then push, include the index and the working tree in the same check before creating the commit. This skill does not create a commit on its own.
3. **Judge the list.** Read [`references/checklist.en.md`](references/checklist.en.md) first. All nine items need a result. An item whose files the repository does not have is not applicable.
4. **Report.** Use the report format in the checklist. Results are only: pass, fail, not applicable, unread, skipped, unconfirmed.
5. **Then decide whether to push.** If the user did not ask to push, stop at the report. If the user asked to push and every item is pass or not applicable, push without `--force`, without `--no-verify`, and without writing git config, for example `git push <remote> HEAD:<branch>`. When the remote is not public, mark the public list skipped; a requested push may proceed. Any other result stops the push.

If the repository has `.githooks/pre-commit`, that hook is a separate check at commit time. It does not replace this list. This skill does not enable the hook and does not change git config.

## Out of scope

- Calling a passed list a safety certification
- Searching a vulnerability database, or storing Keen Lab or YunDing Lab detection rules
- Reviewing whether code outside this diff is correct
- Requiring a publish to SkillHub, DSH, ClawHub, or any other marketplace
- Rewriting history or force-pushing

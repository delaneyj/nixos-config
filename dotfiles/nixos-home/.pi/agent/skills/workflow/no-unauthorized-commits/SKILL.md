---
name: no-unauthorized-commits
description: Controls commit authorization. Use before git commit and after commit, pull-request publication, or parallel tracked-issue requests.
---

# Commit authorization

No commit without one explicit authorization mode.

## Direct commit authorization
A request for exactly one direct commit must satisfy:

1. The user clearly requested a commit.
2. This is the first commit after that request.
3. The commit contains only work completed before the request.
4. The request is explicit (not just `next`, `done`, `finish`, `ship`, `complete`, `verify`).

If any check fails, do not commit. Report uncommitted work.

## Pull-request publication authorization
A request to create, open, or publish a PR authorizes the issue commits needed for that PR, including same-turn implementation changes.

- Keep draft PR rules where supported.
- Treat PR draft state and `WIP: ` title separately.

## WIP title rule
During agent PR work:

- PR title must start with `WIP: `.
- Before revision, read title JSON:
  `tea pr <number> --output json`
- If missing, apply one non-duplicated prefix:
  `tea pr edit <number> --title "WIP: <title>"`
- Remove only the leading `WIP: ` after implementation, tests, and independent review are complete.

## Parallel draft workflow
Pull-request publication authorization does not permit:
- commit,
- amend,
- push,
- force-push,
- PR ready-state changes,
- merge.

Use the primary repository for confirmation. Keep other draft branches in isolated worktrees until selected.

## One-commit limits
For multiple tracked issues, authorize at most one integration commit per requested issue branch.
During any one commit request, authorize at most one commit.

## Compound direct requests
For `commit and continue` or equivalent:
1. Make one commit.
2. Stop direct authorization.
3. Continue only as uncommitted work.

## Completion checks
If another skill requires a commit without authorization:
1. test slice,
2. confirm it works,
3. report as uncommitted,
4. wait for authorization.

## Required report for commit
After a direct commit: end with
`Uncommitted: <short summary>. Say "commit" if you want this committed.`
After pull-request publication: report each commit and PR, then list all residual uncommitted work.

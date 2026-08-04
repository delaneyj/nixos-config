---
name: no-unauthorized-commits
description: Controls commit authorization. Use before git commit and after commit, pull-request publication, or parallel tracked-issue requests.
---

# Commit authorization

No commit without one explicit authorization mode.
Issue-work and non-issue tasks use separate authorization checks.

## Issue-work authorization
A direct request to work on a specific open tracker issue authorizes one implementation pass that includes:

1. Reading issue + comments first.
2. Verifying issue state is `open`.
3. Issue-number branch creation.
4. One branch push.
5. Immediate PR opening for that issue branch with:
   - one `WIP: ` prefix only,
   - planned behavior in the body,
   - `Tests: pending` until results are known.
6. Try a no-diff PR first when the tracker supports it.
7. If a no-diff PR is rejected, create exactly one empty bootstrap commit named `chore: start issue N` and push it to open the WIP PR.
8. Keep exactly one leading `WIP: ` through implementation, validation, correction, and required independent review.
9. Exactly one coherent verified implementation commit.
10. Exactly one normal push of that implementation commit.
11. Update PR body with exact `Tests:` commands from implementation.

A request such as `continue`, `next`, or `finish` does not authorize issue-work.

If the repo has no base commit, stop and ask for separate base-initialization authorization.

After this set, any later issue-related action (additional commits, pushes, PR revisions, metadata edits, ready-state changes, merges, or closes) requires explicit authorization under existing rules.

## Direct commit authorization
A request for exactly one direct commit must satisfy:

1. The user clearly requested a commit.
2. This is the first commit after that request.
3. The commit contains only work completed before the request.
4. The request is explicit (not just `next`, `done`, `finish`, `ship`, `complete`, `verify`).

If any check fails, do not commit. Report uncommitted work.

## Pull-request publication authorization
A request to create, open, or publish a PR does not by itself authorize issue-work branch creation, implementation commits, or push.

Keep draft PR rules where supported.
Treat PR draft state and `WIP: ` title separately.

## WIP title rule
During agent PR work:

- PR title must start with `WIP: `.
- Before revision, read title JSON:
  `tea pr <number> --output json`
- If missing, apply one non-duplicated prefix:
  `tea pr edit <number> --title "WIP: <title>"`
- Remove only the leading `WIP: ` after implementation, required checks, required user-experienced-layer verification for user-visible work, and independent review are complete.

## Parallel draft workflow
Pull-request publication authorization does not permit:
- commit,
- amend,
- push,
- force-push,
- PR ready-state changes,
- merge.

Use the primary repository for confirmation. Keep other draft branches in isolated worktrees until selected.
- Do not change ready/draft state for WIP lifecycle completion unless explicitly authorized.

## One-commit limits
Issue-work allows exactly one implementation commit per requested issue branch.
A bootstrap commit is allowed once when no-diff PR is rejected and only if it is named `chore: start issue N`.
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

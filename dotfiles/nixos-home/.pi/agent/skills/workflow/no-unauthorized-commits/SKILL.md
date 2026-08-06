---
name: no-unauthorized-commits
description: Controls commit authorization. Use before git commit and after commit, pull-request publication, or parallel tracked-issue requests.
---

# Commit authorization

No commit without one explicit authorization mode.
Issue-work and non-issue tasks use separate authorization checks.

## Issue-work authorization
A direct request to work on a specific open tracker issue or PR authorizes one active progress session that includes:

1. Read the issue or PR and comments first.
2. Verify that the issue or PR is open.
3. Create or switch to the issue branch when needed.
4. Open a PR with one `WIP: ` prefix when no PR exists.
5. Put the issue work plan in the PR as an unchecked task checklist before implementation.
6. Keep `Tests: pending` until validation gives exact commands.
7. Make the smallest coherent commit for each task or tightly coupled task slice.
8. Push each logical commit so the WIP PR shows current progress.
9. Update the PR checklist after each pushed commit.
10. Check only tasks completed and verified by commits already in the PR.
11. Add newly discovered work as unchecked tasks before implementation.
12. Keep exactly one leading `WIP: ` through implementation, validation, correction, and independent review.
13. Remove `WIP: ` immediately before handoff when the change is ready for human review.
14. Report the human-review-ready PR URL after removing `WIP: `.

A request to `continue`, `next`, or `finish` a specific open issue or PR starts an active progress session.

If the repository has no base commit, stop and ask for separate base-initialization authorization.

Merging, closing, deleting, force-pushing, and changing draft state always require explicit current-turn authorization.

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

- Treat `WIP: ` as the agent progress state.
- Use multiple logical commits while the title has `WIP: `.
- Push completed logical commits so the PR shows current progress.
- Before revision, read title JSON:
  `tea pr <number> --output json`
- If active agent work lacks the prefix, apply one non-duplicated prefix:
  `tea pr edit <number> --title "WIP: <title>"`
- Remove only the leading `WIP: ` when implementation, checks, user verification, and independent review are complete.
- Remove the prefix before reporting that the PR is ready for human review.
- Do not wait for a separate user request to remove the prefix at handoff.

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

## Commit boundaries
During an active issue or PR progress session:

- Prefer the smallest coherent commit that completes one checklist task or one tightly coupled task slice.
- Keep commits logically small and bounded for human review.
- Do not hold several completed tasks for one large commit.
- Do not split a required atomic change only to reduce commit size.
- Keep each commit coherent and verified for its completed scope.
- Push each completed logical commit to the WIP PR.
- Update the PR checklist after each pushed commit.
- Check only work present and verified in the remote PR.
- Add discovered follow-up work to the checklist before starting it.
- Do not combine unrelated corrections in one commit.

For direct work without an issue or PR, one explicit commit request authorizes one commit.

## Completion checks
If another skill requires a commit without authorization:
1. test slice,
2. confirm it works,
3. report as uncommitted,
4. wait for authorization.

## Required report for commit
After a direct commit outside active issue or PR work, end with:
`Uncommitted: <short summary>. Say "commit" if you want this committed.`

During active issue or PR work, report logical commits, pushes, checklist changes, and residual tasks.
At human-review handoff, remove `WIP: ` and report the PR URL.

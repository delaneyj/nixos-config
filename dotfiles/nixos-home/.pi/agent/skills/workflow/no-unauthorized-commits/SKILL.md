---
name: no-unauthorized-commits
description: Controls commit authorization. Use before git commit and after commit, pull-request publication, or parallel tracked-issue requests.
---

# Commit Authorization

Use one of two authorization modes before `git commit`.

## Direct commit authorization

A direct commit request authorizes exactly one commit.

Before the commit, make sure that all answers are yes:

1. Does the current user message clearly request a commit?
2. Is this the first commit after that request?
3. Does the commit contain only work completed before that request?
4. Is the request more explicit than `next`, `done`, `finish`, `ship`, `complete`, or `verify`?

If an answer is no or not clear, do not commit. Report the uncommitted changes.

## Pull-request publication authorization

A request to create, open, or publish a pull request authorizes its necessary commit. A request to update an existing pull request with code changes gives the same authorization.

This mode applies to draft pull requests and normal pull requests. It can include implementation requested in the same turn.

During agent PR implementation or revision, require the title `WIP: <title>`. Create agent-work PRs with one `WIP: ` prefix.

Before an authorized revision, inspect the PR title with Tea JSON output. Add one `WIP: ` prefix if it is absent. Do not duplicate the prefix.

The required WIP title edit is authorized during authorized PR implementation or revision. Other metadata and ready-state edits remain unauthorized unless existing rules permit them.

Treat Gitea draft state and WIP title state separately. Keep draft rules where supported. The WIP title is mandatory without draft API support.

Remove only the leading `WIP: ` when all requested implementation, tests, and independent review are complete. Do this only when the PR is ready for human review.

A request to fix multiple tracked issues in parallel automatically includes one draft pull request for each issue. The user does not need to repeat the pull-request instruction. An explicit prohibition against commits, pushes, or pull requests disables this automatic authorization.

For each parallel issue:

1. Create an integration worktree and branch from one verified base.
2. Finish the shared dependency spine before leaf work.
3. Give each independent leaf slice an isolated temporary worktree and branch from that base.
4. Do not let two agents edit one worktree concurrently.
5. Do not let a slice worker commit. Require a reviewed patch or diff and targeted test evidence.
6. Have one integration worker apply slices and resolve shared-file overlap.
7. Rebase or integrate current `main` once at this boundary.
8. Run full repository verification after integration and after review fixes.
9. Make at most one authorized issue commit in the integration worktree.
10. Push the issue branch and open a draft pull request with title `WIP: <title>`.
11. Run one independent final review of the integrated pull request.

Use stacked draft pull requests when an issue has an implementation dependency. Set the dependent pull request base to the dependency branch.

Before the integration commit, make sure that all answers are yes:

1. Does the current user message authorize this issue commit?
2. Does the commit contain only the integrated issue work?
3. Did the integrated branch pass required verification?
4. Has no earlier authorized issue commit been made on this branch?

A request for multiple pull requests authorizes at most one integration commit for each requested issue branch. This limit applies to single, parallel, and stacked pull requests.

Stop this authorization when the requested pull requests exist or receive the requested update. Do not merge a pull request without separate authorization.

## Parallel draft confirmation

Pull-request publication authorization ends when the requested draft PRs exist.

A request to load, activate, or confirm the next draft authorizes local post-merge cleanup, rebase, and checkout. It does not authorize:

- A new commit or commit amendment.
- A push or force-push.
- A PR edit or ready-state change.
- A merge.

A local rebase must retain one issue commit and must not add a commit. After user confirmation, require explicit approval to update the existing PR before you push the rebased branch.

Use the primary repository folder for serial user confirmation. Keep other draft branches in isolated worktrees until selected.

The following requests do not authorize a commit:

- Prepare a branch or pull request.
- Stage changes.
- Push a branch without pull-request publication authorization.
- Review or inspect a pull request.
- Work on one issue without a pull-request publication request.
- Work on parallel tasks that are not tracked issues without a pull-request publication request.

## Compound direct requests

For `commit and continue`, `commit then next`, or an equivalent request:

1. Make one commit of completed work.
2. End direct commit authorization after that commit.
3. Continue work without a new commit.
4. Report subsequent work as uncommitted.

Do not include subsequent work in the authorized direct commit.

## Conflicting instructions

If a different skill requires commits without either authorization mode, use this procedure:

1. Test the slice.
2. Make sure that the slice works.
3. Report the slice as uncommitted.
4. Wait for authorization.

## Required report text

After a direct commit, end the report with:

`Uncommitted: <short summary>. Say "commit" if you want this committed.`

After pull-request publication, report each commit and pull request. Report all residual uncommitted work.

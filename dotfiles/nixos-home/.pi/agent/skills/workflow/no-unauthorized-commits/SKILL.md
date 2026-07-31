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

A request to fix multiple tracked issues in parallel automatically includes one draft pull request for each issue. The user does not need to repeat the pull-request instruction. An explicit prohibition against commits, pushes, or pull requests disables this automatic authorization.

For each parallel issue:

1. Use an isolated worktree branch.
2. Implement and review only that issue's work.
3. Complete the required verification.
4. Make at most one commit under the current authorization.
5. Push the issue branch.
6. Open a draft pull request for review.

Use stacked draft pull requests when an issue has an implementation dependency. Set the dependent pull request's base to the dependency branch.

Before each commit, make sure that all answers are yes:

1. Does the current user message request pull-request publication, an existing pull-request code update, or parallel tracked-issue fixes?
2. Is the commit necessary for one authorized pull-request branch?
3. Does the commit contain only that pull request's work?
4. Did the branch pass its required verification?
5. Has no earlier commit been made on this branch under the current authorization?

A request for multiple pull requests authorizes at most one commit on each requested branch. This limit applies to single, parallel, and stacked pull requests.

Stop this authorization when the requested pull requests exist or receive the requested update. Do not merge a pull request without separate authorization.

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

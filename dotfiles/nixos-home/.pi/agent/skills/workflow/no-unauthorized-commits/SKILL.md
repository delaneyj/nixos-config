---
name: no-unauthorized-commits
description: Enforces commit authorization. Use before git commit and after user messages that contain commit, done, next, continue, finish, ship, or complete.
---

# Commit Authorization

Do not run `git commit` without a clear instruction in the current user message.

Issue, branch, PR, stage, push, and preparation instructions do not give commit authorization.

## Gate

Before `git commit`, make sure all answers are yes:

1. Does the current user message contain a clear commit instruction?
2. Has no commit occurred since that request?
3. Does the commit contain only work completed before that request?
4. Is the request more explicit than `next`, `done`, `finish`, `ship`, `complete`, or `verify`?

If one answer is no or unclear, do not commit. Report the uncommitted changes.

## Compound requests

For `commit and continue`, `commit then next`, or requests with the same meaning:

1. Make one commit of completed work.
2. Spend the authorization after that commit.
3. Continue work after the commit without a new commit.
4. Report work after the commit as uncommitted.

Do not include work done after the commit in the commit with authorization.

## Conflicting instructions

If a different skill requires a commit for each slice, use this replacement:

1. Test the slice.
2. Make sure the slice works.
3. Report it as uncommitted.
4. Wait for a new clear commit instruction.

## Required report text

End each report of work done after the commit with:

`Uncommitted: <short summary>. Say "commit" if you want this committed.`

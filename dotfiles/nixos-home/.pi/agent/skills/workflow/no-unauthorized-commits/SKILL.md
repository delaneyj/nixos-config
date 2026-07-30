---
name: no-unauthorized-commits
description: Controls commit authorization. Use before git commit and after user messages with commit, done, next, continue, finish, ship, or complete.
---

# Commit Authorization

Do not run `git commit` without a clear instruction in the current user message.

Issue, branch, PR, stage, push, and preparation instructions do not authorize a commit.

## Gate

Before `git commit`, make sure that all answers are yes:

1. Does the current user message contain a clear commit instruction?
2. Is this the first commit after that request?
3. Does the commit contain only work completed before that request?
4. Is the request more explicit than `next`, `done`, `finish`, `ship`, `complete`, or `verify`?

If an answer is no or not clear, do not commit. Report the uncommitted changes.

## Compound requests

For `commit and continue`, `commit then next`, or equivalent requests:

1. Make one commit of completed work.
2. End authorization after that commit.
3. Continue work without a new commit.
4. Report subsequent work as uncommitted.

Do not include subsequent work in the authorized commit.

## Conflicting instructions

If a different skill requires a commit for each slice, use this procedure:

1. Test the slice.
2. Make sure that the slice works.
3. Report the slice as uncommitted.
4. Wait for a new clear commit instruction.

## Required report text

End each report of work after the commit with:

`Uncommitted: <short summary>. Say "commit" if you want this committed.`

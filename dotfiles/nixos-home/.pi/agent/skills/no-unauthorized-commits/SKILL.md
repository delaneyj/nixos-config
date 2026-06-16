---
name: no-unauthorized-commits
description: Mandatory commit safety gate. Use before any git commit, after any user message containing commit/done/next/continue/finish/ship/complete, and when working with incremental-implementation or git-workflow-and-versioning.
---

# No Unauthorized Commits

Hard rule: never run `git commit` unless the human explicitly asks for a commit in the current turn.

Requests to create/update an issue, create/switch a branch, open a PR, stage files, push a branch, or prepare work are not commit authorization.

## Gate before `git commit`

All must be true:

1. The current user message explicitly asks to commit.
2. No `git commit` has already run since that request.
3. The commit includes only work completed before that request.
4. The request is not merely `next`, `continue`, `finish`, `done`, `ship`, `complete`, `verify`, or similar.

If any answer is no/unclear: do not commit. Report uncommitted changes.

## Compound requests

`commit and next step`, `commit and continue`, `commit then keep going` mean:

1. Commit already-completed work exactly once.
2. Permission is spent immediately after that one commit.
3. Do later work uncommitted.
4. Report later work as uncommitted.

Never commit the later work from the same authorization.

## Replacement for misleading skill text

If another skill says to commit each slice, interpret it as:

- test the slice
- verify the slice
- report uncommitted changes
- wait for explicit current-turn commit authorization

## Required final wording after uncommitted work

End with:

`Uncommitted: <short summary>. Say "commit" if you want this committed.`

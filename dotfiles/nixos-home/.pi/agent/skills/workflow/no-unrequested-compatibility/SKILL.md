---
name: no-unrequested-compatibility
description: Blocks compatibility, migration, and legacy behavior unless the user explicitly requests it in the current task.
---

# No Unrequested Compatibility

## Gate

Before you add compatibility behavior, make sure that all answers are yes:

1. Did the user explicitly request compatibility in the current task?
2. Did the user name the old interface, format, behavior, or data that must continue to work?
3. Is the compatibility scope no larger than the explicit request?

If one answer is no or unclear, do not add compatibility behavior.

## Hard Ban Without Authorization

Do not add any of these items without explicit authorization:

- legacy readers or decoders
- adapters or translation layers
- fallback behavior
- dual reads or dual writes
- data migrations
- old-format retention
- version bridges
- deprecated aliases
- silent upgrades
- compatibility tests or fixtures

Do not infer authorization from existing data, tests, releases, version numbers, backup formats, or common engineering practice.

## Replacement Rule

When the user requests a replacement, remove the replaced representation and its tests, documentation, and storage path in the same change.

If removal can destroy user data, stop and ask one direct question. Do not implement a migration or compatibility layer as a precaution.

## Review

Before reporting completion:

1. Search the diff for `compat`, `legacy`, `fallback`, `migration`, `deprecated`, `old`, `v1`, and dual-path logic.
2. Remove each unrequested compatibility path.
3. Report any destructive data effect clearly.

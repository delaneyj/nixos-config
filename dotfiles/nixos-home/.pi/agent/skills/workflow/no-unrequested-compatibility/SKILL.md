---
name: no-unrequested-compatibility
description: Blocks compatibility, migration, and legacy behavior unless the user explicitly requests it in the current task.
---

# No Unrequested Compatibility

## Gate

Before you add compatibility behavior, make sure that all answers are yes:

1. Did the user explicitly request compatibility in the current task?
2. Did the user identify the old interface, format, behavior, or data that must continue to work?
3. Is the compatibility scope no larger than the explicit request?

If an answer is no or not clear, do not add compatibility behavior.

## Hard Ban Without Authorization

Do not add these items without explicit authorization:

- Do not add legacy readers or decoders.
- Do not add adapters or translation layers.
- Do not add fallback behavior.
- Do not add dual reads or dual writes.
- Do not add data migrations.
- Do not keep previous formats.
- Do not add version bridges.
- Do not add deprecated aliases.
- Do not add silent upgrades.
- Do not add compatibility tests or fixtures.

Do not infer authorization from existing data, tests, releases, version numbers, backup formats, or common engineering practice.

## Replacement Rule

When the user requests a replacement, remove the replaced representation, tests, documentation, and storage path in the same change.

If removal can destroy user data, stop and ask one direct question. Do not add a migration or compatibility layer as a precaution.

## Review

Before you report completion:

1. Search the diff for `compat`, `legacy`, `fallback`, `migration`, `deprecated`, `old`, `v1`, and dual-path logic.
2. Remove each unrequested compatibility path.
3. Report each destructive data effect clearly.

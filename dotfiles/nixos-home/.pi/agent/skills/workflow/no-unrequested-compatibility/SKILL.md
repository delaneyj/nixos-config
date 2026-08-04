---
name: no-unrequested-compatibility
description: Blocks compatibility, migration, and legacy behavior unless the user explicitly requests it in the current task.
---

# No unrequested compatibility

## Gate
Before adding compatibility, migration, or legacy behavior, all must be yes:

1. User explicitly requested this behavior.
2. The old interface/format/behavior/data is explicitly named.
3. Scope is limited to that request.

If any answer is no, do not add compatibility behavior.

## Hard ban
Do not add without explicit authorization:
- legacy readers or decoders
- adapters/translation layers
- fallback paths
- dual reads or dual writes
- version bridges
- deprecated aliases
- silent upgrades
- compatibility tests or fixtures
- migrations and compatibility flags

Do not infer approval from tests, backups, releases, version numbers, or common practice.

## Replacement requests
When user requests replacement:
- remove old representation, tests, docs, and storage path in the same change.
- if removal could destroy data, ask one direct question first.
- do not add migration or compatibility as a precaution.

## Final review
Before completion, search the diff for:
`compat`, `legacy`, `migration`, `fallback`, `deprecated`, `old`, `v1`, `dual path`, `dual-path`.
Remove any unrequested paths. State any destructive data impact clearly.

---
name: domain-modeling
description: Builds and refines project domain language. Use for real terminology conflicts, maintain CONTEXT.md, and to support Wayfinder and grilling.
license: MIT. See ../../references/mattpocock-skills/LICENSE
---

# Domain Modeling

Use this skill when naming is unclear or terms conflict.

## Process

1. Read `CONTEXT-MAP.md` or `CONTEXT.md` when present.
2. Challenge terms that conflict with the glossary.
3. Split overloaded terms. Keep one canonical term per concept.
4. Test relationships with concrete edge cases.
5. Compare user statements with code. Report contradictions.
6. Update `CONTEXT.md` with resolved language.

## Decision records

Use an ADR only when a term decision is hard to reverse and alternatives were considered.
The project does not show the reason. Use [ADR-FORMAT.md](ADR-FORMAT.md).
Use [CONTEXT-FORMAT.md](CONTEXT-FORMAT.md) for glossary edits.

`CONTEXT.md` stores language only. Store design/implementation decisions elsewhere.

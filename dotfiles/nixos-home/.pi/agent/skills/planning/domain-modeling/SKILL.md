---
name: domain-modeling
description: Builds and refines project domain language. Use to resolve terms that are not clear, maintain CONTEXT.md, record costly decisions, or support Wayfinder and grilling.
license: MIT. See ../../references/mattpocock-skills/LICENSE
---

# Domain Modeling

Use accurate project language during planning.

## Process

1. Read `CONTEXT-MAP.md` or `CONTEXT.md` when present.
2. Challenge terms that conflict with the glossary.
3. Divide overloaded terms. Propose one canonical term for each concept.
4. Test relationships with concrete edge cases.
5. Compare user statements with code. Report contradictions.
6. Update the applicable `CONTEXT.md` when you resolve a term.

Use [CONTEXT-FORMAT.md](CONTEXT-FORMAT.md) for glossary changes.

`CONTEXT.md` contains domain language only. Store implementation decisions elsewhere.

## Decision records

Give the option of an ADR only when a decision is costly to reverse. The decision must have available alternatives. The project does not show the reason. Use [ADR-FORMAT.md](ADR-FORMAT.md).

---
name: domain-modeling
description: Builds and sharpens project domain language. Use to resolve ambiguous terms, maintain CONTEXT.md, record hard-to-reverse decisions, or support Wayfinder and grilling.
license: MIT; see ../../references/mattpocock-skills/LICENSE
---

# Domain Modeling

Use precise project language while planning.

## Process

1. Read `CONTEXT-MAP.md` or `CONTEXT.md` when present.
2. Challenge a term that conflicts with the glossary.
3. Separate overloaded terms and propose one canonical term for each concept.
4. Test relationships with concrete edge cases.
5. Compare user statements with the code and report contradictions.
6. Update the applicable `CONTEXT.md` when a term is resolved.

Use [CONTEXT-FORMAT.md](CONTEXT-FORMAT.md) for glossary changes.

`CONTEXT.md` contains domain language only. Put implementation decisions elsewhere.

## Decision records

Offer an ADR only when the decision is hard to reverse, surprising without context, and based on a real trade-off. Use [ADR-FORMAT.md](ADR-FORMAT.md).

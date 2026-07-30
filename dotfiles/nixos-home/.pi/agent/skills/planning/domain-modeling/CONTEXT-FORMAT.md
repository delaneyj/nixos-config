# CONTEXT.md format

```md
# {Context Name}

{One or two sentences that identify this context.}

## Language

**Order**:
{One or two sentences that define the term.}
_Avoid_: Purchase, transaction

**Customer**:
{One or two sentences that define the term.}
_Avoid_: Client, buyer, account
```

Rules:

- Select one canonical term for each concept.
- Keep each definition to one or two sentences.
- Define what the concept is.
- Include only project-specific domain concepts.
- Group terms when clear groups exist.

Use one root `CONTEXT.md` for a single context. For multiple contexts, use a root `CONTEXT-MAP.md` that links each context file and states relationships between contexts.

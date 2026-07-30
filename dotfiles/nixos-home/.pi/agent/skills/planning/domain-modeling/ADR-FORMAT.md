# ADR format

ADRs use sequential names under `docs/adr/`, such as `0001-event-sourced-orders.md`.

```md
# {Short decision title}

{One to three sentences that state the context, decision, and reason.}
```

Add status, options, or consequences only when they preserve useful information.

Create an ADR only when all conditions apply:

1. The decision is costly to reverse.
2. A future reader cannot infer the reason.
3. The decision selected between real alternatives.

---
name: datastar-cqrs
description: Defines CQRS Datastar interactions. Use for commands, queries, mutation routes, update streams, event buses, and server-pushed UI state.
---

# Datastar CQRS

Commands change state. Queries and streams render current state.

## Page flow

1. Render the initial page and current state.
2. Use same-route Datastar requests for route fragments and refreshes.
3. Start one SSE stream from `data-init` on the page root.
4. Use `Accept: text/event-stream` and `Datastar-Request` on the product route by default.
5. Use `/updates` only when the product route needs a different stream route.
6. Change state in command routes and emit an internal event.
7. Return `204 No Content` from commands by default.
8. Patch the current read model from the update stream.
9. Store per-user or per-tab UI state in a server-readable cookie when it must continue between requests.

Do not store canonical state in `localStorage` or client signals.

## Commands

- Use `POST` to create or submit.
- Use `PATCH` to change part of a resource or do an action.
- Use `PUT` to replace or select settings.
- Use `DELETE` to delete or reset.
- Decode typed signals with `datastar.ReadSignals(r, &input)`.
- Validate all input on the server.
- Use the applicable lock or transaction.
- Emit an event only after a change has no error.
- Patch immediately only for an intentional one-shot action.

## Update stream

Use content negotiation on the same route:

```go
if r.Header.Get("Datastar-Request") != "" &&
    strings.Contains(r.Header.Get("Accept"), "text/event-stream") {
    sse := datastar.NewSSE(w, r, datastar.WithCompression())
    // Patch state, subscribe, and wait for context cancellation.
    return
}
```

For each stream:

1. Create one compressed SSE writer.
2. Patch current state immediately for safe reconnection.
3. Subscribe with `r.Context()` and defer unsubscribe.
4. Load the current read model after each event.
5. Patch with `sse.PatchElementTempl(featureApp(model))`.
6. Stop when `r.Context().Done()` closes.

## Event bus

Use the typed pattern in `~/repos/datastar-dev/site/shared/eventbus.go`:

- Create local fanout with `NewEventBusAsync[T]()`.
- Subscribe with `Subscribe(ctx, fn)` and defer the returned unsubscribe function.
- Emit from commands with `Emit(r.Context(), event)`.
- Keep payloads small. Load current state. Do not trust event deltas.
- Debounce fast event groups to prevent too many browser patches.
- Use `DebounceWithMaxWait` for frequent counters and statistics.

```go
patch := toolbelt.DebounceWithMaxWait(
    100*time.Millisecond,
    time.Second,
    func(ctx context.Context) error {
        return sse.PatchElementTempl(featureStats(loadStats(ctx)))
    },
)

unsub := events.Subscribe(r.Context(), func(struct{}) error {
    return patch(r.Context())
})
defer unsub()
```

## Do not use

- Small command-response deltas as the primary update path.
- Client-owned canonical state.
- Append-only streams for important state.
- Long inline Datastar expressions for business logic.
- Stale event payloads as the read model.

## Verification

Use different tests for command validation, state changes, and rendering.

Make sure the stream patches current state before it waits for new events.

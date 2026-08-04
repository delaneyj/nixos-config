---
name: datastar-cqrs
description: Defines CQRS Datastar interactions. Use for commands, queries, mutation routes, update streams, event buses, and server-pushed UI state.
---

# Datastar CQRS

Commands mutate. Queries render. SSE pushes current read model.

## Flow
1. Render initial page and current state.
2. Detect Datastar with `Datastar-Request`.
3. Serve same-route fragments and refreshes.
4. Start SSE from `data-init` on the page root.
5. Use `Accept: text/event-stream` + `Datastar-Request` first.
6. Add `/updates` only when a separate stream route is required.
7. Command routes mutate state, emit events, and return `204` by default.
8. Stream handlers patch full current read model, not deltas.

Do not keep canonical state in `localStorage` or signals.

## Commands
- `POST`: create/submit.
- `PATCH`: partial update or action.
- `PUT`: replace settings.
- `DELETE`: remove/reset.
- Decode inputs with `datastar.ReadSignals(r, &input)`.
- Validate on server and apply required locks or tx.
- Emit event only after successful mutation.
- Use one-shot patches only when immediate feedback is required.

## Stream handler
Use content negotiation before branching.

```go
if r.Header.Get("Datastar-Request") != "" &&
	strings.Contains(r.Header.Get("Accept"), "text/event-stream") {
	sse := datastar.NewSSE(w, r, datastar.WithCompression())
	// patch state, subscribe, wait for cancel
	return
}
```

For each stream:
1. Create one compressed SSE writer.
2. Patch current state immediately for reconnect safety.
3. Subscribe with `r.Context()` and defer unsubscribe.
4. Reload read model after every event.
5. Patch with `sse.PatchElementTempl(featureApp(model))`.
6. Return when context cancels.

## Event bus
- Use typed `NewEventBusAsync[T]()` from `site/shared/eventbus.go`.
- Subscribe via `Subscribe(ctx, fn)` and defer unsubscribe.
- Emit from commands with `Emit(r.Context(), event)`.
- Keep event payload small and avoid trusting deltas.
- Debounce high-rate events.
- Use `DebounceWithMaxWait` for counters/stats.

```go
patch := toolbelt.DebounceWithMaxWait(
	100*time.Millisecond,
	time.Second,
	func(ctx context.Context) error {
		return sse.PatchElementTempl(featureStats(loadStats(ctx)))
	},
)
unsub := events.Subscribe(r.Context(), func(struct{}) error { return patch(r.Context()) })
defer unsub()
```

## Do not
- Use inline Datastar deltas as canonical update path.
- Use append-only streams for critical state.
- Trust stale event payloads.
- Place business logic in long client expressions.

## Verification
- Test command validation, state changes, and rendering separately.
- Ensure each stream patches current state before waiting for events.

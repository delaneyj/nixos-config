---
name: datastar-cqrs
description: CQRS-style Datastar interactions. Use when building command/query boundaries, mutation routes, page update streams, event buses, or server-pushed UI state.
---

# Datastar CQRS

Use CQRS for interactive Datastar pages: commands mutate; queries/streams render current state.

## Core pattern

1. Initial page route renders skeleton/current state.
2. Same-route Datastar requests (`Datastar-Request` header) patch current route content/signals for ordinary partial refresh/navigation.
3. Most interactive pages own an SSE stream via `data-init` on `body`, `main`, or the feature root. Prefer same-route `GET /feature` with `Accept: text/event-stream` plus `Datastar-Request` over a separate `/updates` route unless the product route shape needs a dedicated stream.
4. Command routes mutate state and emit an internal event.
5. Command routes usually return `204 No Content`.
6. The update stream subscribes to the event bus and patches the current read model as HTML for long-lived live updates.
7. Per-person/per-tab UI state that must outlive a request belongs in a server-readable cookie, not localStorage or client-owned canonical state.

## Command routes

- Use HTTP verbs by intent:
  - `POST` create/submit.
  - `PATCH` partial mutation/action.
  - `PUT` replace/select mode/settings.
  - `DELETE` delete/reset.
- Decode signals with typed structs via `datastar.ReadSignals(r, &input)`.
- Validate server-side; never trust client signals.
- Mutate under appropriate locking/transaction boundaries.
- Emit domain/read-model event after successful mutation.
- Return `w.WriteHeader(http.StatusNoContent)` / `204` unless the action is intentionally one-shot and must patch immediately.

## Query/update stream

- Require the Datastar request header for stream mode; reject or fall back for ordinary browser navigation.
- Prefer content negotiation on the same route for streams:
  ```go
  if r.Header.Get("Datastar-Request") != "" && strings.Contains(r.Header.Get("Accept"), "text/event-stream") {
      sse := datastar.NewSSE(w, r, datastar.WithCompression())
      // patch current state, subscribe, wait for ctx done
      return
  }
  ```
- Create once per page load:
  ```go
  sse := datastar.NewSSE(w, r, datastar.WithCompression())
  ```
- Immediately patch current state so reconnects/self-heal work.
- Subscribe to an internal bus using `r.Context()`; defer unsubscribe.
- On event, load/build the current read model, then `PatchElementTempl(featureApp(model))`.
- End when `r.Context().Done()` closes.

## Event bus

Use a small typed in-process event bus for local features, modeled after `~/repos/datastar-dev/site/shared/eventbus.go`:

- `NewEventBusAsync[T]()` for fanout to stream subscribers.
- `Subscribe(ctx, func(T) error { ... })` returns unsubscribe; always `defer` it.
- `Emit(r.Context(), event)` from commands.
- Event payload can be tiny (`struct{}`, ID, count); subscribers should render from current state, not trust stale deltas.
- For stats/dashboard/live-summary streams, subscribe on page load and auto-patch from the event bus.
- Debounce/coalesce subscriber rendering so bursts do not flood the browser. Use `toolbelt.Debounce` or `toolbelt.DebounceWithMaxWait` around the patch function when events can arrive quickly.
- Prefer `DebounceWithMaxWait(wait, maxWait, fn)` for live UI counters/stats: it waits for quiet but guarantees periodic updates under sustained writes.

Example debounced subscriber:

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

## Skeleton

```go
func setupFeature(parent chi.Router) {
    events := shared.NewEventBusAsync[struct{}]()

    parent.Route("/feature", func(r chi.Router) {
        r.Get("/", func(w http.ResponseWriter, req *http.Request) {
            RenderPage(featurePage(loadFeature(req.Context())), w, req)
        })

        r.Patch("/thing", func(w http.ResponseWriter, req *http.Request) {
            // decode, validate, mutate
            _ = events.Emit(req.Context(), struct{}{})
            w.WriteHeader(http.StatusNoContent)
        })

        r.Get("/", func(w http.ResponseWriter, req *http.Request) {
            if req.Header.Get("Datastar-Request") != "" && strings.Contains(req.Header.Get("Accept"), "text/event-stream") {
                sse := datastar.NewSSE(w, req, datastar.WithCompression())
                _ = sse.PatchElementTempl(featureApp(loadFeature(req.Context())))

                unsub := events.Subscribe(req.Context(), func(struct{}) error {
                    return sse.PatchElementTempl(featureApp(loadFeature(req.Context())))
                })
                defer unsub()

                <-req.Context().Done()
                return
            }

            RenderPage(featurePage(loadFeature(req.Context())), w, req)
        })
    })
}
```

## Avoid

- Command endpoints that return tiny deltas as the main update path.
- Client-held canonical state.
- Append/remove-only streams for critical state; missed events break correctness.
- Long inline Datastar expressions that implement business logic.

## Verification

Test command validation/mutation separately from rendering. Ensure update streams render current state on connect before waiting for new events.

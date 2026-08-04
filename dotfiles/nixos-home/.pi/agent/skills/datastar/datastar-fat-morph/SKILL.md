---
name: datastar-fat-morph
description: Defines coarse Datastar morphing. Use for patch boundaries, reconnect-safe updates, and Datastar SSE payloads.
---

# Datastar Fat Morph

Patch one meaningful owner with current state. Let Datastar compute DOM diff.

## Patch boundary
- Prefer owner by stability and responsibility.
  - `body` for app-wide shell state.
  - `main` for main page content.
  - Feature root for isolated feature state.
  - Child only for local owner, slow sections, or high-frequency updates.
- Give each target a stable ID.
- Render from current read model after each event.

```go
sse.PatchElementTempl(featureApp(model))
```

- Use `datastar.WithCompression()` for coarse or long-lived streams.
- Send full current state immediately on connect.
- Use `WithSelector` only if response omits the target element (for `title`, etc.).
- Keep third-party client-owned islands in `data-ignore-morph`.

## Editor-safe islands
For `stellar-code-editor`, canvas, charts, media, always:
1. Find every possible patch target that can include the editor host.
2. Set `data-ignore-morph` in the first editor response.
3. Drive value/language/diagnostics/results via signals/properties.
4. Keep host mounted while values change.
5. Do not swap editor DOM for read-only snippets.

- In browser, run each action twice.
- Host reference must remain equal.
- Shadow root should contain one `.cm-editor`.
- Root dark class and colors must stay stable.

## Do not
- Use row/button/counter micro-patches as primary sync path when feature patch is cheap.
- Patch one slow card for many unrelated dashboard cards.
- Use append-only events for canonical state.
- Duplicate server read model with client reconciliation.
- Add too many `data-ignore-morph` regions.

## Exceptions
- Use append for infinite scroll or stream chunks.
- Use narrower patches for third-party widgets only.
- Serialize SSE writes through one writer goroutine/channel.
- Use per-feature cards on high-frequency dashboards when measured.

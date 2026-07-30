---
name: datastar-fat-morph
description: Defines coarse Datastar morphing. Use for patch boundaries, reconnect-safe updates, and Datastar SSE payloads.
---

# Datastar Fat Morph

Send complete current state for one meaningful region. Let Datastar calculate the DOM changes.

## Patch boundary

Patch the largest stable semantic owner that gives correct state:

- Use `body` for app shell or page state.
- Use `main` for most page content.
- Use a feature root for feature state.
- Use a child only when it has its own owner, slow loading, or high update frequency.

## Reasons

- The next event corrects state after a reconnect or interruption.
- The client needs less state logic.
- Datastar changes only necessary DOM nodes.
- Stream compression reduces HTML size.
- CQRS can render the current read model without UI deltas.

## Rules

- Give each morph target a stable ID.
- Render it from the current read model after each event.
- Use `sse.PatchElementTempl(featureApp(model))` for templ components.
- Use `datastar.WithCompression()` for long-lived or coarse streams.
- Send current state immediately when the stream connects.
- Use `data-ignore-morph` only for a necessary client-owned island.

Keep rich custom elements stable. Examples include CodeMirror, canvas, charts, media players, and `stellar-code-editor`.

Before each `stellar-code-editor` change, find all patch targets that can contain the editor. Do not limit this check to the direct parent.

If a patch target can contain the editor, apply these rules:

- Set `data-ignore-morph` on the editor in its first response.
- Update each value, language, diagnostic, and result through a signal or property.
- Keep the editor host in the DOM while those values change.
- Do not patch the editor to change a read-only command snippet.
- Do not add CSS theme overrides as a correction for repeated editor initialization.

An editor that appears after the first command is stateful. The same rule applies to an editor in the initial page HTML.

Repeat each applicable action two times in a browser. Make sure that the host reference stays equal and the shadow root has one `.cm-editor`.

## Selectors

Let patch content identify its target by root ID:

```go
sse.PatchElementTempl(featureApp(model))
```

Use `WithSelector` only when content omits the target element. It is also applicable to special targets such as `title`.

## Do not use

- Row, button, or counter patches as primary state synchronization when a feature patch is inexpensive.
- One slow card as a block for other dashboard cards.
- Append-only events for important state.
- Client reconciliation that duplicates the server read model.
- Too many `data-ignore-morph` regions.

## Exceptions

- Infinite scroll can append items.
- Streams can append each complete part.
- Dashboards can patch cards with different owners at the same time.
- Serialize all SSE writes through one writer goroutine or channel.
- Third-party widgets can use narrow patches and stable client-owned DOM.
- Measured high-frequency paths can use smaller roots.

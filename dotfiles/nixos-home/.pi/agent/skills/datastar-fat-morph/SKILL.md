---
name: datastar-fat-morph
description: Coarse-grained Datastar morphing strategy. Use when deciding what fragments to patch, handling reconnect-safe UI updates, or optimizing Datastar SSE payloads.
---

# Datastar Fat Morph

Prefer coarse-grained/fat morphs. Send the complete desired state for a meaningful region and let Datastar's morphing compute/apply the DOM delta.

## Rule

Patch the largest stable semantic owner that makes the state correct:

- Whole `body` for app shell/page-level state when appropriate.
- `main` for most page content changes.
- Feature root (`section#feature`, `div#app`) for feature state.
- Smaller child only when it is independently owned, independently slow/loading, or genuinely high-frequency.

## Why

- Reconnect/interruption safe: next event contains full current state.
- Less client bookkeeping.
- Morphing preserves DOM intelligently and only changes needed nodes.
- Streaming compression (Brotli/Zstd/gzip via Datastar/infra) handles repeated coarse HTML well.
- Simpler CQRS: render read model; don't maintain UI deltas.

## Implementation

- Give coarse morph target a stable ID.
- Render target from current read model each time.
- Use `sse.PatchElementTempl(featureApp(model))` for templ components.
- Use `datastar.WithCompression()` for long-lived streams/coarse payloads.
- Send initial state immediately when `/updates` connects.
- Use `data-ignore-morph` inside coarse targets only for client-owned islands that must not be touched.
- Before patching a region containing a mounted rich custom element (`stellar-code-editor`, CodeMirror, canvas, charts, media players), ask whether the change can be represented as signal/prop updates instead. Prefer stable DOM + prop/signal updates for value/language/diagnostics/results; patch only surrounding status or metadata.

## Selector guidance

Prefer default element matching by ID/root in the patch. Use explicit selectors sparingly:

```go
sse.PatchElementTempl(featureApp(model))
```

Use `WithSelector` only when patching a specific target with content that does not naturally include the target element, or for special targets like `title`.

## Good

```templ
templ featureApp(model FeatureModel) {
    <main id="feature" data-init="@get('/feature/updates')">
        <section aria-labelledby="feature-title">
            <h1 id="feature-title">{ model.Title }</h1>
            // complete desired state
        </section>
    </main>
}
```

```go
return sse.PatchElementTempl(featureApp(loadFeature(ctx)))
```

## Avoid

- Patching individual rows/buttons/counters as primary state sync when a feature root is cheap enough.
- Letting one slow card/stat block a whole dashboard when independent skeleton targets can be patched as they become ready.
- Append-only event streams for important state; missed append means corrupt UI.
- Client-side reconciliation logic duplicating server read model logic.
- Overusing `data-ignore-morph`; it blocks correctness.

## Exceptions

- Infinite scroll/load-more can append by design.
- Progressively streamed content can append when each chunk is independent.
- Dashboard/ops skeletons may patch independent cards/sections concurrently; serialize SSE writes through one writer goroutine/channel.
- Canvas/WebGL/third-party widgets and rich editors may use narrow patches plus `data-ignore-morph`, or preferably stable DOM updated through props/signals.
- Extremely hot paths may patch smaller roots after measuring.

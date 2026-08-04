---
name: datastar-templ
description: Defines Datastar-first Go and templ development. Use for web UIs, routes, templ components, server-rendered interactions, Datastar attributes, and SSE.
---

# Datastar and templ

Use server-rendered templ HTML with Datastar attributes and SSE. Do not create SPA state unless required.

## Source data
Read before nontrivial work:
- `~/repos/datastar-dev/site/reference/attributes.templ`
- `~/repos/datastar-dev/site/reference/sse_events.templ`
- `~/repos/datastar-dev/site/reference/sdks.templ`
- `~/repos/datastar-dev/site/examples/*`

Use `datastar-bootstrap` for layout, routes, shared files, assets, and hot reload.

## Required stack
Use these skills as needed:
1. `datastar-bootstrap` for setup.
2. `datastar-templ` for views and interactions.
3. `datastar-cqrs` for commands/streams/bus.
4. `datastar-fat-morph` for boundaries.
5. `datastar-css` for semantic HTML and tokens.
6. `datastar-debugging` for runtime faults.
7. `go-style` for Go implementation.

## Components
- Use `feature(...)` page wrapper.
- Use `featureApp(...)` coarse morph target with stable ID.
- Add small components only for reuse or clarity.
- Do not use `<form>` in Datastar app pages.
- Use signal-bound controls and explicit `data-on:*` actions.
- Use semantic elements and accessible names/labels.
- Put `data-init` on `body`, `main`, or app root.
- Use typed structs and `templ.JSONString` for signals. Do not build JSON by string concat.
- Use SDK actions: `GetSSE`, `PostSSE`, `PatchSSE`, `PutSSE`, `DeleteSSE`.

## Datastar attributes
- Use camelCase signal names in expressions.
- Kebab-case attribute keys map to camelCase signals.
- Put `data-signals` before any dependent `data-init`.
- Use `data-bind` for control state.
- Use colon event names (`data-on:click`, `data-on:input`).
- Do not use `data-on-click` or `data-on-input`.
- Handler values are expressions, not JS statement blocks.
- Use comma expressions for multiple actions.
- Keep expressions short. Move complexity to server or named browser functions.
- Use same indicator signal per request family and set `data-indicator:*` on each initiator.
- An ancestor indicator does not reliably track child requests.
- Create init indicator before request starts.
- Use `data-ignore-morph` only for needed client-owned islands.

## Same-route first
- Detect Datastar with `Datastar-Request`.
- Use `Accept` for routes serving HTML, JSON, or SSE.
- Render browser navigation via `RenderPage(...)`.
- For Datastar requests: create SSE and patch coarse target or signals.
- Put shared HTTP helpers in `shared.go`, shared templ in `shared.templ`.
- Add `/updates` only when stream must be on another route.

## CQRS behavior
- Queries can stream HTML.
- Commands emit events and return `204`.
- Use same-route SSE or page stream for live updates.
- Use coarse morph targets where correctness matters.
- Compress stream fragments where possible.

## Concurrent skeleton loading
1. Add placeholders with `aria-busy="true"` and target IDs.
2. Start loading from coarse owner.
3. Use `filterSignals: {include: /^$/}` when no signals are needed.
4. Load each model in goroutine.
5. Send cards/sections through one SSE writer.
6. Never write SSE from multiple goroutines.
7. Patch full card/section by target ID.
8. Patch local error component on failure.
- If all data is cheap, render full page synchronously.

## `stellar-code-editor` hard gate
Apply before adding/changing editor helpers:
1. Check every SSE patch that can include any editor parent.
2. If parent can patch, set `data-ignore-morph` in first response.
3. Use signals/properties for value, language, format, diagnostics, results.
4. Keep one editor node for all visible edits.
5. Do not alternate editor instances with `data-show`.
6. Patch result signals before status/metadata HTML.
7. For read-only editors use CodeMirror `readOnly` and keep focusable/selectable.
8. Do not disable `EditorView.editable` or `contenteditable` unless disabled.
9. `drawSelection` can hide token contrast; use native `::selection` when invert required.
10. Keep `.cm-content` transparent.

For each action that can patch a parent of the editor in browser:
- capture host reference and colors once.
- run action twice.
- verify host unchanged.
- verify one `.cm-editor` in shadow root.
- verify colors and dark class remain stable.
- verify signals updated editor properties.
- server HTML tests do not satisfy this gate.

Read-only editors:
- use `readOnly`.
- keep focusable/selectable.
- avoid local editor theme overrides before stability.

## StellarUI color mode
Use root signals only.

```templ
<html
    data-signals:color-mode="'system'"
    data-match-media:system-dark="prefers-color-scheme: dark"
    data-persist:app-ui="{ colorMode: $colorMode }"
    data-class:dark="$colorMode === 'dark' || ($colorMode === 'system' && $systemDark)"
>
    <stellar-button-color-mode
        data-bind:color-mode__prop.mode__event.input.change
    ></stellar-button-color-mode>
```

- Do not persist `$systemDark`.
- Do not bind `data-bind:is-dark`.
- Do not use static `mode` or manual sync handlers.
- Clear stale persisted signals/local storage when debugging.

## Verification
For non-debugging Datastar + templ work run:

```bash
templ generate
go test ./...
```

For runtime debugging, follow `datastar-debugging` and avoid app/test commands.

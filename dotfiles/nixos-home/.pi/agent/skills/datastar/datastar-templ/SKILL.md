---
name: datastar-templ
description: Defines Datastar-first Go and templ development. Use for web UIs, routes, templ components, server-rendered interactions, Datastar attributes, and SSE.
---

# Datastar and templ

Use server-rendered templ HTML, Datastar attributes, and SSE. Do not create SPA state without a product requirement.

## Source data

Examine these official `~/repos/datastar-dev` files before nontrivial work:

- `site/reference/attributes.templ`: Contains names, capitalization, and modifiers.
- `site/reference/sse_events.templ`: Contains SSE event behavior.
- `site/reference/sdks.templ`: Contains SDK helpers.
- `site/examples/*.templ` and `*.go`: Show component and interaction patterns.

Use `datastar-bootstrap` for layouts, route trees, shared files, assets, and hot reload.

## Applicable skills

Use the applicable skills for UI work:

1. Use `datastar-bootstrap` for app and route setup.
2. Use `datastar-templ` for templ and Datastar interactions.
3. Use `datastar-cqrs` for commands, streams, and the event bus.
4. Use `datastar-fat-morph` for patch boundaries.
5. Use `datastar-css` for semantic HTML and nested CSS.
6. Use `datastar-debugging` for user-run runtime debugging.
7. Use `go-style` for Go implementation.

Name these skills in UI plans. Use project tests for behavior changes that are not Datastar debugging.

## CSS gate

Use `datastar-css` before each CSS change and during the last examination.

- Use CSS custom properties for all project design values.
- Examine `stellar.css` and `stellarui.css` first.
- Add a scoped variable only when no applicable Stellar token exists.
- Do not keep literal project colors, spacing, sizes, radii, shadows, timing, or layout measures.

## Components

- Keep `feature(...)` as the page wrapper.
- Keep `featureApp(...)` as the coarse morph target.
- Add small components only for reuse or clarity.
- Do not use `<form>` in Datastar app pages.
- Use signal-bound controls and explicit `data-on:*` actions.
- Use semantic HTML. Give controls names and labels for accessibility.
- Give coarse morph targets stable IDs.
- Put `data-init` on `body`, `main`, or the app root.
- Use typed structs and `templ.JSONString` for signals.
- Do not construct JSON with strings.
- Use SDK helpers such as `GetSSE`, `PostSSE`, `PatchSSE`, `PutSSE`, and `DeleteSSE`.

## Attributes

- Use camelCase signal names in expressions.
- Kebab-case attribute keys map to camelCase signals.
- Put `data-signals` before a dependent `data-init`.
- Use `data-bind` for control state.
- Use colon event names, such as `data-on:input` and `data-on:click`.
- Do not use `data-on-input` or `data-on-click`.
- Handler values are expressions, not JavaScript statement blocks.
- Use comma expressions for multiple actions.
- Move longer logic to a named browser function or the server.
- Copy upstream custom-element binding patterns before you add workarounds.
- Keep inline expressions short.
- Use indicators only when their feedback helps the user.
- Put the same `data-indicator:*` key on each element that starts the request.
- An ancestor indicator does not reliably track requests from child elements.
- Create an init indicator signal before its fetch starts.
- Use one camelCase indicator signal for controls in one request family.
- Use `data-ignore-morph` only for necessary client-owned islands.

## `stellar-code-editor` hard gate

Apply this gate before you add or change `stellar-code-editor` or a helper that renders it.

1. Find each SSE patch that can include a parent of the editor.
2. If a parent can be patched, set `data-ignore-morph` on the editor in its first response.
3. Use signals or properties for each value that can change.
4. Keep one editor in the DOM for value, language, format, visibility, diagnostic, and result changes.
5. Do not use `data-show` to alternate between editor instances.
6. Patch result signals before you patch status or metadata HTML.

Apply these rules to read-only editors and command snippets. An editor in initial page HTML is stateful after mount.

Do not use local `--code-*` or `--code-editor-*` overrides to correct a morph fault. Make the editor stable first.

For each action that can patch a parent of the editor, do these browser checks:

1. Keep the initial editor host reference and its computed foreground and background colors.
2. Do the action two times.
3. Make sure the host reference did not change.
4. Make sure the shadow root contains one `.cm-editor`.
5. Make sure the root dark class and initial colors did not change.
6. Make sure signals changed the editor value and other applicable properties.

A server HTML test does not complete this gate. Test mode switches in a browser.

For read-only CodeMirror controls:

- Use CodeMirror `readOnly` for write protection.
- Keep the editor focusable and selectable.
- Do not disable `EditorView.editable` or `contenteditable` unless the control is disabled.
- `drawSelection` paints a background behind content and cannot invert token colors.
- Use native `::selection` when selected text must invert colors.
- Keep `.cm-content` transparent so it does not hide selection.

## StellarUI color mode

Let the page root calculate the dark class. Persist only the user choice.

```templ
<html
    data-signals:color-mode="'system'"
    data-match-media:system-dark="prefers-color-scheme: dark"
    data-persist:app-ui="{ colorMode: $colorMode }"
    data-class:dark="$colorMode === 'dark' || ($colorMode === 'system' && $systemDark)"
>
...
<stellar-button-color-mode
    data-bind:color-mode__prop.mode__event.input.change
></stellar-button-color-mode>
```

- Do not bind `data-bind:is-dark` for the app theme class.
- Do not add `$mode`, a static `mode` attribute, `scope="shell"`, or manual synchronization handlers.
- Do not persist `$systemDark`.
- Slotted controls use the same root calculation and mode-property binding.
- For debugging, clear stale persisted signals and local storage.
- Log `$colorMode`, `$systemDark`, the root class, and the system media query.
- Copy event values before asynchronous debug callbacks.

## Same-route requests

Use same-route requests before you add an `/updates` route.

- Detect Datastar with the `Datastar-Request` header.
- Use `Accept` when one route serves HTML, JSON, or SSE.
- Render browser navigation with `RenderPage(...)`.
- For Datastar requests, create SSE and patch coarse content or signals.
- Keep shared HTTP helpers in `shared.go`.
- Keep shared templ components in `shared.templ`.
- Add `/updates` only when live push needs its own product route.

## Concurrent skeleton loading

Use a fast skeleton when cards have different latency.

1. Render placeholders with target IDs and `aria-busy="true"`.
2. Start same-route loading from the coarse owner.
3. Use `filterSignals: {include: /^$/}` when the request needs no app signals.
4. Load each model in a goroutine.
5. Send components through a channel to one SSE writer.
6. Do not write SSE from worker goroutines at the same time.
7. Patch the full card or section with its target ID.
8. Patch a local error component when one card fails.

Render the full page synchronously when all data is inexpensive.

## Guided flows

Use inline step panels for complex write flows:

- Use one primary action in each step.
- Show progress.
- Use server-confirmed validation before save.
- Show inline errors and contextual help.
- Show a success panel with applicable subsequent actions.
- Do not use a modal unless inline review cannot clearly show destructive risk.

## Defaults

- Queries can stream HTML.
- Commands change state, emit an event, and return `204 No Content`.
- Use same-route SSE or a page stream for live updates.
- Use coarse morphs when correctness is important.
- Use compression for coarse stream fragments.

## Verification

For Go and templ work that is not runtime debugging, use the project task runner. Typical commands:

```bash
templ generate
go test ./...
```

For Datastar runtime debugging, follow `datastar-debugging`. Do not run the app or tests in that workflow.

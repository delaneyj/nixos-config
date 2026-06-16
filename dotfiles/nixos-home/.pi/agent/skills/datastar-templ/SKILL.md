---
name: datastar-templ
description: Datastar-first Go/templ web development. Use for any web UI, route, templ component, server-rendered interaction, or Datastar attribute/SSE work.
---

# Datastar + templ

Datastar first for web. Prefer server-rendered HTML with templ, Datastar attributes, and SSE over SPA/client state.

## Source of truth

Before non-trivial Datastar work, inspect official repo/docs/examples in `~/repos/datastar-dev`:

- `site/reference/attributes.templ` — attribute names, casing, modifiers.
- `site/reference/sse_events.templ` — SSE event semantics.
- `site/reference/sdks.templ` — SDK helpers.
- `site/examples/*.templ` and `site/examples/*.go` — component and interaction patterns.

Use `datastar-bootstrap` for base layout, route tree, `shared.templ`, `RenderPage`, static assets, hot reload, and feature organization.

## Skill stack for UI work

When planning or implementing web UI, explicitly load/apply:

1. `datastar-bootstrap` — new app/route tree/base layout/static/hotreload/shared setup.
2. `datastar-templ` — templ components and Datastar attributes/interactions.
3. `datastar-cqrs` — command routes, `/updates` streams, and event bus fanout.
4. `datastar-fat-morph` — coarse morph target strategy.
5. `datastar-css` — semantic HTML and modern nested CSS.
6. `datastar-debugging` — Datastar/Rocket/StellarUI runtime debugging; user-run hot reload only, add logs, do not run/test yourself.
7. `go-style` — Go implementation style.
8. `test-driven-development` when behavior/logic changes outside datastar-dev debugging.

UI plans should name these applicable skills instead of only saying “use Datastar”.

## templ component shape

- Keep page wrapper and app fragment separate:
  - `templ feature(u *auth.User, model *FeatureModel)` for page/demo wrapper.
  - `templ featureApp(model *FeatureModel)` for coarse morph target.
  - Small repeated components allowed when reused or clarity warrants it.
- Prefer semantic HTML: `main`, `section`, `article`, `header`, `footer`, `nav`, `form`, `fieldset`, `label`, `button`, `table` as appropriate.
- Put stable IDs on coarse morph targets.
- Put Datastar setup (`data-init`) on the coarse owner element (`body`, `main`, or app `<section>`), not random leaves.
- Use `templ.JSONString`/typed structs for signal payloads. Avoid string-building JSON.
- Use SDK helpers like `datastar.GetSSE`, `PostSSE`, `PatchSSE`, `PutSSE`, `DeleteSSE` when composing templ attributes.

## Datastar attributes

- Signals use camelCase internally; kebab-case attribute keys map to camelCase. When referencing a signal in an expression, use camelCase (`$queryLoading`), not kebab-case (`$query-loading`). This also applies to indicator signals from `data-indicator:query-loading`: the generated signal is `$queryLoading`.
- Put `data-signals` before `data-init` when init depends on signal existence.
- Use `data-bind` for form state; use `data-on:*` for event logic.
- Event attributes must use the colon form: `data-on:input`, `data-on:click`,
  `data-on:submit__prevent`. Do **not** write `data-on-input` or
  `data-on-click`; Datastar will not register those as event handlers.
- Datastar handler values are expressions, not arbitrary JS statement blocks.
  Avoid statement syntax such as `if (...) ...` after a semicolon. Use an
  expression form instead, e.g.
  `console.log('x', $foo), ($foo ? location.href = '/path?q=' + encodeURIComponent($foo) : null)`.
- If a handler needs multiple actions, use comma expressions or move logic into
  a small named browser function; do not rely on `; if (...)` inline.
- For custom elements/web components, copy proven upstream binding patterns exactly before adding event handlers or workarounds.
- Keep inline expressions short. If logic grows, move it server-side.
- Use indicators only when useful. Put `data-indicator:*` on every element that initiates the backend request (`data-on:*`/`data-init` with `@get`/`@post`), not only on an ancestor, sibling, result panel, or unrelated display element. An ancestor indicator can initialize the signal but does not reliably track child-initiated requests. If several controls trigger the same request family, repeat the same indicator key on each triggering element and read one camelCase signal (e.g. `data-indicator:query-loading` on the editor, switch, and init owner; spinner uses `data-show="$queryLoading"`). For `data-init` fetches, ensure the indicator signal is created before the fetch request is initialized.
- Use `data-ignore-morph` only for genuinely client-owned islands/canvas/third-party widgets.

## Stateful custom elements and code editors

Treat rich web components as stateful client-owned islands unless proven otherwise. In particular, `stellar-code-editor`/CodeMirror instances derive internal DOM, language extensions, measurements, scroll, focus, and theme CSS variables at runtime.

Rules:

- Do not patch/replace a mounted code editor just to change format, language, value, visibility, or result text. Keep one stable editor DOM node mounted and update props/signals (`value`, `languageSrc`, diagnostics) instead.
- Do not render separate RON and JSON code editors and toggle them with `data-show`; switching can initialize a different editor and cause theme/measurement/focus flicker. Use one editor with a mode signal and a value expression.
- If a switch updates results plus editor mode, patch signals first (`resultJSON`, `resultRON`, `format`, diagnostics) and patch only status/metadata HTML. Avoid `PatchElementTempl` for the editor/result region unless the editor is first created or intentionally removed.
- If replacing a surrounding region is unavoidable, put the editor in a stable child with `data-ignore-morph` and update it via bound signals/props, not HTML replacement.
- After adding a RON/JSON or light/dark-adjacent control, verify in the browser that switching does not change app color mode, code-editor theme, focus, scroll, or text selection.
- For CodeMirror-backed readonly viewers, keep the editor focusable/selectable: use CodeMirror `readOnly` state for write protection, but do not set `EditorView.editable`/`contenteditable` false unless the control is truly disabled. CodeMirror `drawSelection` hides native selection and paints only a background layer behind content; it cannot invert selected token foreground colors. If selected text must invert foreground/background, prefer native selection (`::selection`) instead of `drawSelection`, set selected `background: var(--code-editor-fg)` and `color: var(--code-editor-bg)`, and keep `.cm-content` background transparent so any selection layer/native highlight is not hidden.

## StellarUI color mode

For app shells using `stellar-button-color-mode`, let the page root own the resolved dark class. Bind the control only to the persisted user choice (`light`/`dark`/`system`) and use `data-match-media` on `<html>` for OS/browser system changes:

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

Rules:

- Do not bind `data-bind:is-dark` for the app-level theme class. Component `value` can miss external system preference transitions; root `data-match-media` is the reliable page-level source.
- Do not introduce a separate `$mode` signal, static `mode="dark"` attr, `scope="shell"`, or manual `data-on:input/change` sync handlers.
- Keep `data-persist` scoped to `colorMode` only; do not persist the derived system-dark boolean.
- If the control is slotted inside another Rocket/StellarUI custom element such as `stellar-toolbar`, keep the same page-level root computation; only the control's `mode` prop needs binding.
- If debugging, clear stale persisted Datastar signals/localStorage and log `$colorMode`, `$systemDark`, `document.documentElement.className`, and `matchMedia('(prefers-color-scheme: dark)').matches`.
- Debug click logs must not read `evt.currentTarget` inside `setTimeout`; Datastar/browser event objects may be cleared. Copy values first or log synchronously.

## Same-route Datastar requests

Prefer same-route progressive enhancement before adding dedicated `/updates` endpoints:

- Detect Datastar requests with `r.Header.Get("Datastar-Request") != ""`.
- Use `Accept` for route mode when one path serves HTML, JSON, and/or SSE. Example: default/no `Accept` renders HTML, `Accept: application/json` returns JSON API, and `Accept: text/event-stream` opens the Datastar stream.
- On normal navigation, render the full page with `RenderPage(...)`.
- On Datastar requests for the same route, create `datastar.NewSSE(w, r)` and patch the route's coarse content target/signals.
- Factor shared HTTP helpers (`RenderPage`, Datastar request detection, `Accept` parsing/content negotiation helpers) into `shared.go`; shared templ components stay in `shared.templ`.
- Use dedicated long-lived `/updates` streams only when the page needs a separate product route for push updates; most pages should use same-route `Accept: text/event-stream` streams initialized with `data-init`.

## Skeleton + concurrent patch loading

For dashboards/ops pages where independent cards have different latency, prefer a fast skeleton page plus same-route Datastar SSE patches:

- Initial HTML renders stable placeholder elements/cards with final target IDs and `aria-busy="true"`.
- Put `data-init="@get('/route', {filterSignals: {include: /^$/}})"` on the coarse owner so the skeleton self-loads without sending app signals.
- Datastar request handler starts independent read/model calls in goroutines and streams each completed card/section with `sse.PatchElementTempl(...)`.
- Never write SSE concurrently from goroutines. Send rendered components/results over a channel and have one goroutine serialize all `PatchElementTempl` calls.
- Patch the complete card/section containing the target ID, not just inner text; replacement should clear busy/loading state and be reconnect-safe for that section.
- On per-card failures, patch that card's target with an inline error component; keep the rest of the skeleton/page usable.
- Use this pattern when it improves perceived latency or avoids one slow stat blocking unrelated cards. If all data is cheap, render the full page synchronously.

## Guided flows

For complex write/save/manage flows, prefer TurboTax-style inline wizard panels over modals:

- one primary task/action per step
- visible milestones/progress
- backend-confirmed validation/preview before commit/save
- inline errors in the current page frame
- right sidebar for contextual help/properties/raw details
- success panels with next useful actions
- no modals unless inline review cannot make destructive risk clear enough

## Defaults

- Query/read endpoints may stream HTML directly.
- Commands mutate, publish an internal event bus message, and return `204 No Content`; updates arrive through same-route Datastar responses or a page stream when live push is required.
- Prefer coarse/fat morph updates over fine-grained append/remove when correctness matters.
- Prefer compression (`datastar.WithCompression()`) for streams that send repeated or coarse fragments.

## Verification

For ordinary Go/templ changes, run project validation. Typical:

```bash
templ generate
go test ./...
```

Use the repository's task runner if present.

Exception: when debugging Datastar/datastar-dev runtime behavior, use `datastar-debugging`: do not run/build/test/start/kill yourself; rely on the user's hot-reload session and pasted logs.

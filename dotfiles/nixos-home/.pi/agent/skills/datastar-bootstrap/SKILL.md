---
name: datastar-bootstrap
description: Bootstraps and organizes Datastar/templ Go sites. Use when creating a new Datastar app, base layout, route tree, shared.templ/shared.go, hot reload, static asset loading, or feature folder/route organization.
---

# Datastar Bootstrap + Organization

Use this when starting or reorganizing a Datastar/templ site. Datastar is the default web stack.

## Source of truth

Inspect official repo/docs/examples in `~/repos/datastar-dev` before bootstrapping:

- `site/shared/shared.templ` — base layout, shared components, Datastar script loading, dev inspector, hotreload element.
- `site/shared/shared.go` — `RenderPage` shape and shared helpers.
- `site/web/web.go` — route setup, static serving, `/hotreload` handler.
- `site/examples/examples.templ` — route registration and page wrapper conventions.
- `site/examples/*.templ` and `site/examples/*.go` — feature route + component patterns.
- `site/shared/eventbus.go` — typed in-process event bus for CQRS/SSE fanout.

Repo examples are authoritative for naming/style.

## Base layout

Create a shared base component, usually in `shared.templ`:

- `<!DOCTYPE html>` and `<html lang="en">`.
- `title`, `description`, `charset`, `viewport`, canonical URL as appropriate.
- CSS links before Datastar script.
- Datastar script/import map loaded once in `<head>`.
- Dev-only Datastar inspector if the project uses it.
- `<body>{ children... }</body>` with app shell/layout components around children when needed.
- For StellarUI color mode shells, use the upstream pattern from `../stellarui/web/shared.templ`: no static `class="dark"`; `data-signals:color-mode="'system'"`, `data-persist:*="{ colorMode: $colorMode }"`, and `data-class:dark="$isDark"` on `<html>`; then bind `stellar-button-color-mode` with only `data-bind:is-dark` and `data-bind:color-mode__prop.mode__event.input.change`. If the button is slotted inside another Rocket/StellarUI component such as `stellar-toolbar`, keep those ordinary page-level binds; authored/slotted light DOM uses page signals by default. Do not invent a separate `$mode` signal, static `mode` attr, `scope="shell"`, or manual event sync handlers.

Keep one shared `RenderPage` helper, usually in `shared.go`:

```go
func RenderPage(c templ.Component, w http.ResponseWriter, r *http.Request) {
    w.Header().Set("Content-Type", "text/html")
    c.Render(r.Context(), w)
}
```

## Route organization

Follow `datastar-dev` naming and keep route trees explicit:

- Put each major nested route tree in its own `routes_<feature>.go` file.
- Setup function: `setupFeatureRoutes(parent chi.Router, deps...)` (or the existing project naming), called from the central server/router constructor.
- Route group: `parent.Route("/feature", func(featureRouter chi.Router) { ... })`.
- Dynamic/multi-method resources must get their own nested `Route`, not repeated verb registrations with the dynamic path:
  ```go
  featureRouter.Route("/{featureID}", func(featureItemRouter chi.Router) {
      featureItemRouter.Get("/", handleGet)
      featureItemRouter.Patch("/", handlePatch)
      featureItemRouter.Delete("/", handleDelete)
  })
  ```
- Apply the same grouping recursively for nested dynamic routes such as `/{schemaID}/entities/{entityID}`.
- Exception: chi wildcard catch-all routes like `/*` may need direct verb registration because wildcard mounts must be terminal.
- Initial page: `GET /` renders a full page with `RenderPage(featurePage(...), w, r)`.
- Most interactive pages initialize an SSE update stream from the page root with `data-init`; prefer same-route `GET /feature` with `Accept: text/event-stream` plus `Datastar-Request` over a separate `/updates` route unless the product route shape needs a dedicated stream.
- Commands: `POST`/`PATCH`/`PUT`/`DELETE` mutate state, publish an internal event bus message, and usually return `204`; update streams render the resulting state.

Register feature setup functions from a central package route setup file, mirroring `site/examples/examples.templ`.

For UI PRDs, the first implementation task should enable the canonical product route in dashboard/workflow/sidebar navigation once the feature is user-visible; do not leave `/ui/*` prototype links as the primary entry point.

## File/component organization

- Keep shared app shell/components in `shared.templ`; keep route-specific components next to their setup route.
- Keep page wrapper and app fragment separate:
  - `templ feature(u *auth.User, model *FeatureModel)` for page wrapper.
  - `templ featureApp(model *FeatureModel)` for the coarse morph target.
  - Additional components only when reused or materially clearer.
- Coarse morph target owns `data-init` for `/updates` (`body`, `main`, or feature root).
- Put stable IDs on coarse morph targets.
- Prefer typed structs for page/read models and signals.

## Static assets

- Serve static assets with `github.com/benbjohnson/hashfs`, mirroring `~/repos/datastar-dev/site/shared/shared.go` and `site/web/web.go`.
- Use an embedded FS, wrap it with `hashfs.NewFS`, and expose `StaticPath(...)` helpers that return hashed names for CSS/JS/images.
- Serve with `hashfs.FileServer(...)` and long immutable cache headers for hashed files.
- Keep Datastar and app CSS loaded from the shared base layout, not per-feature copies.
- Prefer project-local assets over ad hoc CDN dependencies unless already a project convention.

## Dev hot reload

Mirror `~/repos/datastar-dev/site/shared/shared.templ` + `site/web/web.go`:

- In the dev-only base layout, add a stable hidden element:
  ```templ
  <div id="hotreload" data-init="@get('/hotreload', {retryMaxCount: 1000,retryInterval:20, retryMaxWait:200})"></div>
  ```
- Register `/hotreload` only in dev or behind trusted local access.
- Handler shape:
  ```go
  var hotReloadOnlyOnce sync.Once
  router.Get("/hotreload", func(w http.ResponseWriter, r *http.Request) {
      sse := datastar.NewSSE(w, r)
      hotReloadOnlyOnce.Do(func() {
          sse.ExecuteScript("window.location.reload()")
      })
      <-r.Context().Done()
  })
  ```
- Why it works: browsers keep retrying the SSE request while the dev server rebuilds/restarts; after the new process starts, the first `/hotreload` connection executes `window.location.reload()` once, causing clients to fetch fresh HTML/assets.
- Keep `id="hotreload"` so tests/fetch-event observers can ignore the dev stream.
- Do not use hotreload as app state sync; it is dev-only full-page reload plumbing.

## Default stack decisions

- Server owns canonical state and renders HTML.
- Datastar attributes express interactions.
- CQRS pages use command routes + `/updates` stream + event bus.
- Fat morph coarse targets by default.
- CSS is semantic, scoped, and modern-nested when possible.

## Verification

For new/changed bootstraps, run:

```bash
templ generate
go test ./...
```

Use the repository's task runner if present.

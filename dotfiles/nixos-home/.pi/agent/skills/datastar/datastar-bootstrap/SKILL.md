---
name: datastar-bootstrap
description: Creates and organizes Datastar/templ Go sites. Use for new apps, layouts, routes, shared files, assets, hot reload, and feature folders.
---

# Datastar Bootstrap

Use Datastar as the default web stack.

## Source data

Examine these official `~/repos/datastar-dev` files before setup:

- `site/shared/shared.templ`: base layout, scripts, inspector, and hot reload.
- `site/shared/shared.go`: `RenderPage` and shared helpers.
- `site/web/web.go`: routes, static files, and `/hotreload`.
- `site/examples/examples.templ`: route registration and page wrappers.
- `site/examples/*.templ` and `*.go`: feature patterns.
- `site/shared/eventbus.go`: typed event bus.

Use repository names and style.

## Base layout

Create one shared base component in `shared.templ`:

- Add `<!DOCTYPE html>` and `<html lang="en">`.
- Add title, description, charset, viewport, and canonical URL when applicable.
- Put CSS links before the Datastar script.
- Load the Datastar script or import map one time in `<head>`.
- Add the Datastar inspector only in development.
- Put the app shell around `{ children... }`.
- Use the `datastar-templ` color-mode pattern for StellarUI shells.

Keep one `RenderPage` helper in `shared.go`:

```go
func RenderPage(c templ.Component, w http.ResponseWriter, r *http.Request) {
    w.Header().Set("Content-Type", "text/html")
    c.Render(r.Context(), w)
}
```

## Routes

Keep route trees explicit:

- Put each important route tree in `routes_<feature>.go`.
- Call `setupFeatureRoutes(parent chi.Router, deps...)` from the central router.
- Use `parent.Route("/feature", func(featureRouter chi.Router) { ... })`.
- Give dynamic resources a nested `Route`:

```go
featureRouter.Route("/{featureID}", func(item chi.Router) {
    item.Get("/", handleGet)
    item.Patch("/", handlePatch)
    item.Delete("/", handleDelete)
})
```

- Use the same structure for nested dynamic routes.
- Register terminal chi wildcards, such as `/*`, directly when necessary.
- Render the initial `GET /` with `RenderPage`.
- Use same-route SSE with `Accept: text/event-stream` and `Datastar-Request` by default.
- Add `/updates` only when the product route needs a stream on a different route.
- Mutation routes change state, emit an event, and usually return `204`.
- Register product routes in browser navigation. Do not keep `/ui/*` as the primary entry.

## Components

- Keep shared shell components in `shared.templ`.
- Keep route components next to the route setup.
- Use `feature(...)` for the page wrapper.
- Use `featureApp(...)` for the coarse morph target.
- Add more components only for reuse or clarity.
- Put `data-init` and a stable ID on the coarse morph target.
- Use typed page models and signal structs.

## Static files

- Use `github.com/benbjohnson/hashfs` with an embedded file system.
- Use `hashfs.NewFS`, `StaticPath(...)`, and `hashfs.FileServer(...)`.
- Add long immutable cache headers for hashed files.
- Load Datastar and app CSS from the base layout.
- Use project files. Do not add new CDN dependencies.

## Hot reload

Copy the pattern from `site/shared/shared.templ` and `site/web/web.go`.

```templ
<div id="hotreload" data-init="@get('/hotreload', {retryMaxCount: 1000,retryInterval:20,retryMaxWait:200})"></div>
```

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

- Register `/hotreload` only for development or trusted local access.
- Keep `id="hotreload"` for test and observer filters.
- Do not use hot reload to synchronize app state.

## Defaults

- The server owns state and renders HTML.
- Datastar attributes define interactions.
- CQRS uses mutation routes, event bus messages, and an update stream.
- Use coarse morph targets and semantic CSS.

## Verification

If the repository has a task runner, use it. If not, run:

```bash
templ generate
go test ./...
```

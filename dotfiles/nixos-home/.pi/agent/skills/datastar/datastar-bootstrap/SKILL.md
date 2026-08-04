---
name: datastar-bootstrap
description: Creates and organizes Datastar and templ Go sites. Use for apps, layouts, routes, shared files, assets, hot reload, and feature folders.
---

# Datastar Bootstrap

Use Datastar + templ as the default stack.

## Source data
- Read before changes: `~/repos/datastar-dev/site/shared/shared.templ`, `site/shared/shared.go`, `site/web/web.go`, `site/examples/examples.templ`, `site/examples/*.templ`, `site/examples/*.go`, `site/shared/eventbus.go`.
- Match repository names, package names, and style.

## Base layout
- Keep one shared base in `shared.templ`.
- Add `<!DOCTYPE html>`, `<html lang="en">`, title, description, charset, viewport, and canonical when available.
- Put CSS links before Datastar script/import map.
- Load Datastar only once in `<head>`.
- Add Datastar inspector only for development.
- Wrap app shell around `{ children... }`.
- Use the datastar-templ color-mode pattern in StellarUI shells.
- Keep one `RenderPage` helper in `shared.go`:

```go
func RenderPage(c templ.Component, w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "text/html")
	c.Render(r.Context(), w)
}
```

## Route structure
- Create `routes_<feature>.go` files with explicit trees.
- Central router calls `setupFeatureRoutes(parent chi.Router, deps...)`.
- Register routes with `parent.Route("/feature", ... )`.
- Use nested route blocks for dynamic IDs.

```go
featureRouter.Route("/{featureID}", func(item chi.Router) {
	item.Get("/", handleGet)
	item.Patch("/", handlePatch)
	item.Delete("/", handleDelete)
})
```

- Render initial GET via `RenderPage`.
- Use same-route SSE on the same route using `Accept: text/event-stream` and `Datastar-Request`.
- Add `/updates` only when stream must be on a separate route.
- Mutation routes should mutate state, emit events, and usually return `204`.
- Use terminal chi wildcards (`/*`) only when required.
- Register product routes for browser navigation; avoid primary `/ui/*` entry.

## Components and ownership
- Keep shared shell in `shared.templ`.
- Keep route components next to route setup.
- Use `feature(...)` for page wrapper.
- Use `featureApp(...)` as coarse morph target.
- Add components only for clarity or reuse.
- Set `data-init` and stable IDs on coarse morph targets.
- Use typed page models and signal structs.

## Static assets and cache
- Use embedded `github.com/benbjohnson/hashfs`.
- Use `hashfs.NewFS`, `StaticPath(...)`, and `hashfs.FileServer(...)`.
- Set long immutable cache headers for hashed assets.
- Load Datastar and app CSS from base layout.
- Avoid adding new CDN dependencies.

## Hot reload pattern
- Copy from `site/shared/shared.templ` and `site/web/web.go`.

```templ
<div id="hotreload" data-init="@get('/hotreload', {retryMaxCount: 1000, retryInterval: 20, retryMaxWait: 200})"></div>
```

```go
var hotReloadOnlyOnce sync.Once
router.Get("/hotreload", func(w http.ResponseWriter, r *http.Request) {
	sse := datastar.NewSSE(w, r)
	hotReloadOnlyOnce.Do(func() { sse.ExecuteScript("window.location.reload()") })
	<-r.Context().Done()
})
```

- Register `/hotreload` only in development or trusted local access.
- Keep `id="hotreload"` for filtering.
- Do not use hot reload to sync app state.

## Verification
- Server owns HTML state and Datastar drives interactions.
- Use CQRS for commands, event bus, and update streams.
- Prefer semantic coarse morph targets and tokenized CSS.
- Run if available:

```bash
templ generate
go test ./...
```

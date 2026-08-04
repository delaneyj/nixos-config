---
name: go-style
description: Defines Go code style for domain types, encoding, serialization, composite literals, helpers, variables, control flow, and file organization.
---

# Go Style

Apply these rules to all Go changes.

## Files
- One file per concrete type, domain concept, or wire kind.
- Use names like `matrix2.go`, `matrix3.go`, `matrix4.go` for type groups.
- Keep type-specific encoding with the owning type.
- Keep shared dispatch, interfaces, and low-level helpers in central files.

## Names
- Use standard Go initialisms.
- Do not keep all-caps acronyms in domain names.

## Domain methods
- Put logic on concrete owners.
- Avoid adapters when method can be on owned type.
- Use wrappers only for primitives, external types, boundaries, or explicit public API needs.

## Serialization
- Keep serialization on owning type.
- Do not centralize behavior that belongs to one type.
- Use shared helpers only when at least two distinct types need mechanics.
- Do not pipe JSON into `ron.FromJSON` or `ron.FromJSONCompact`.
- Use `ron.Marshal`, `ron.MarshalCompact`, `ron.MarshalInto`, `ron.NewEncoder` directly.
- Use `ron.FromJSON` only for true JSON bytes.
- Remove avoidable JSON-to-RON chains.

## Variadics
- Use variadic params for homogeneous values when callers do not need a slice.
- Use slices when ownership, capacity, nil, or allocation matters.
- Pass slice values with `values...`.

For repeated primitive append logic use typed generic helper:

```go
func appendRawInt64[T ~int64](dst []byte, values ...T) []byte
```

For fixed arrays use expansion:

```go
appendRawInt64(dst, v[:]...)
appendRawFloat64s(dst, v[:]...)
```

## Composite literals
- Use multiline keyed literals by default for structs, configs, decoded values, returns.

```go
var Line3Meta = Meta{
	WireName: "line3",
	Label:    "Line 3",
	Icon:     "material-symbols:process-chart",
	Group:    GroupGeometry,
}
```

- Use one-line only for tiny local fixtures.
- Break long calls over lines.

```go
return appendRawFloat64s(
	appendHeader(dst, sphereKind),
	v.Center[0], v.Center[1], v.Center[2],
	v.Radius,
)
```

## Control flow
- Add blank line between logical phases.
- Add blank line after early-return guard.
- Add blank line before final fallback after nontrivial conditionals.

## Variables
- Group zero-values with same scope:

```go
var (
	resumedBytes int64
	file         *os.File
)
```

- Use explicit conversion for sentinel values.

## Package-level declarations
- Never add one-use package-level function/var/const/type with production use.
- Exceptions: interfaces, API boundaries, routes, recursion, generics, or two+ production call sites.
- Before finish: list new package-level declarations, then remove one-use ones.

## Context
- `context.Background()` is allowed only inside a production `main` function that creates the process root context.
- All other production functions should accept a caller context (`ctx context.Context`) and pass or derive from it.
- Do not use `context.Background()` in helpers, servers, packages, examples, benchmarks, tests, test `main` functions, or any non-root process code.
- In tests, use `t.Context()` and derive cancellation/deadline contexts from it.
- Test subprocesses use `exec.CommandContext(t.Context(), ...)`.

## Ignored returns
- Call a function directly when all return values are intentionally ignored.
- Do not write `_ = f()` when Go permits `f()` as an expression statement.

```go
hash.Write([]byte("sqlite\x00"))
t.Cleanup(func() { store.Close() })
```

- Use `_` only when Go syntax requires discarding one value from a multi-value assignment or declaration. Do not use it to silence an ignored single return value.

## Tests
- For test subprocesses, use `exec.CommandContext(t.Context(), ...)`.

## Validation
- Run `gopls` for changed non-generated Go files.
- Run project-local `gopls` if available.

```bash
go tool gopls check ./path/to/changed.go
```

- In Nix, run `nix develop --command gopls check ...` when needed.
- Avoid `gopls check ./...`.
- Then run project build/test task:

```bash
go test ./...
go build ./cmd/...
```

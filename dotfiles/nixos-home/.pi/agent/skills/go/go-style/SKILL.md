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
- Put reusable logic on concrete owners.
- Do not create an unexported method for one production call site.
- Receiver ownership does not override the single-use private logic rule.
- Avoid adapters when a reused method can be on an owned type.
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
- Use a variadic parameter when callers supply zero or more same-type values independently.
- Prefer a variadic parameter when it removes a slice literal from a call.
- Keep a slice parameter when the slice is one owned collection value.
- Keep a slice parameter when the function can mutate the collection.
- Keep a slice parameter when capacity, nil, or allocation behavior is important.
- Keep a required external interface signature unchanged.
- Pass a slice to a variadic parameter with `values...`.

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

## Map creation
- Use `map[K]V{}` when an empty map has no capacity estimate.
- Do not use `make(map[K]V)` without a capacity.
- Use `make(map[K]V, capacity)` only when the code has a good capacity estimate.
- Add a capacity when the expected size is available at map creation.
- Use a nonempty composite literal when the map has initial entries.
- Use a nil map when the code does not write to the map.

```go
empty := map[string]int{}
known := map[string]int{"answer": 42}
indexed := make(map[string]int, len(items))
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

## Single-use private logic

Inline every private function-like declaration that has exactly one production call site.

This rule includes:
- unexported package functions,
- unexported methods,
- named local functions,
- local function variables and closures that are invoked once.

Count production call sites, not declaration references. Tests do not count as production use.

Do not keep single-use private logic for:
- receiver ownership,
- file organization,
- readability,
- function length,
- type-specific parsing or encoding,
- possible future reuse.

For example, if only one branch calls `value.setUTC(raw)`, inline the `setUTC` body into that branch.

Inline a one-use closure directly into the API call that receives it. Do not assign it to a local variable first.

Exceptions are limited to:
- recursion,
- language-required functions such as `main` and `init`,
- methods required by an interface,
- framework-required declarations,
- generated code.

An exception must be structurally required. A conceptual boundary alone is not an exception.

## Package-level declarations
- Never add a private package-level variable, constant, or type with one production use.
- Export does not justify a declaration that has only one internal production use unless it is an explicit API boundary.
- Tests do not count as production use.

## Required single-use audit

Before completion:
1. List every private function and method added or changed.
2. Count its non-test production call sites.
3. Inline each declaration with exactly one call site.
4. Repeat the search after inlining.
5. Report any remaining exception and its structural requirement.

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

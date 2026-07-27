---
name: go-style
description: Defines Go code style. Use for domain types, encoding, serialization, composite literals, helpers, variables, control flow, and file organization.
---

# Go Style

Use these rules for all Go changes.

## Files

- Use one file for each concrete type, domain concept, or wire kind.
- Examples: `matrix2.go`, `matrix3.go`, and `matrix4.go`.
- Keep type-specific encoding and serialization with its type.
- Keep central files only for shared dispatch, interfaces, and reused low-level helpers.

## Names

Use standard Go initialisms only. Do not use all-capital domain acronyms. Use `OwlSource`, `RonValue`, and `RdfTerm`.

## Domain types

- Put applicable interface methods directly on owned concrete types.
- Do not add an adapter when the owned type can have the method.
- Use wrappers only for primitives, external types, interface boundaries, or necessary public API behavior.

## Serialization

- Let each type own its serialization methods.
- Do not use a central type switch for behavior that belongs to a type.
- Use shared helpers only for mechanics with more than one use.
- Do not use JSON between a Go value and RON.
- Use `ron.Marshal`, `ron.MarshalCompact`, `ron.MarshalInto`, or `ron.NewEncoder` directly.
- Do not send `json.Marshal` output to `ron.FromJSON` or `ron.FromJSONCompact`.
- Use `ron.FromJSON` only for bytes that originate as JSON.
- Before completion, find and remove avoidable JSON-to-RON chains.

## Variadic parameters

- Use variadic parameters for homogeneous values when callers do not need a slice.
- Use a slice when ownership, capacity, nil meaning, or allocation is important.
- Use `values...` when you send a slice to a variadic function.

For primitive encoding with more than one use, add generic variadic append helpers:

```go
func appendRawInt64[T ~int64](dst []byte, values ...T) []byte
func appendRawUint64[T ~uint64](dst []byte, values ...T) []byte
```

Use slice expansion for fixed arrays:

```go
appendRawInt64(dst, v[:]...)
appendRawFloat64s(dst, v[:]...)
```

## Composite literals

Use multiline keyed literals by default. This includes variables, returns, configurations, constructors, and decoded values.

```go
var Line3Meta = Meta{
    WireName: "line3",
    Label:    "Line 3",
    Icon:     "material-symbols:process-chart",
    Group:    GroupGeometry,
}
```

Use a single line only for a very small local test fixture when it is clearer.

Use multiline nested literals:

```go
return Box2{
    Min: Float64V2{
        math.Inf(1), math.Inf(1),
    },
    Max: Float64V2{
        math.Inf(-1), math.Inf(-1),
    },
}
```

Break long calls across lines:

```go
return appendRawFloat64s(
    appendHeader(dst, sphereKind),
    v.Center[0], v.Center[1], v.Center[2],
    v.Radius,
)
```

## Control flow

- Put a blank line between logical phases.
- Put a blank line after an early-return guard.
- Put a blank line before the last fallback after a nontrivial conditional block.

## Variables

Group related zero-value variables that have the same scope:

```go
var (
    resumedBytes int64
    file         *os.File
)
expectedSize := int64(-1)
```

Use `:=` with explicit conversion for nonzero sentinel values.

## Package-level declarations

Do not add a single-use package-level function, variable, constant, or type.

- Tests do not count as production uses.
- Export does not justify one production use.
- Inline one-off logic or use a local closure.
- Exceptions: required interfaces, API boundaries, routes, recursion, generic reuse, or two production call sites.

Before completion:

1. Examine each new package-level declaration in `git diff`.
2. Find each production use.
3. Remove or localize declarations with fewer than two production call sites.
4. Keep an exception only when it matches the list above.

## Ignored returns

Call a function directly when all returned values can be safely discarded.

```go
hash.Write([]byte("sqlite\x00"))
```

Do not write:

```go
_, _ = hash.Write([]byte("sqlite\x00"))
```

Use explicit ignored assignments only for error-producing APIs or interface and control-flow requirements.

## Validation

After an important Go change, run gopls, usual Go validation, and a binary build.

Use project-local gopls when available:

```bash
go tool gopls check ./path/to/changed.go
```

If not, use `gopls check`. In Nix projects, add `gopls` to the development shell when necessary.

```bash
nix develop --command gopls check ./path/to/changed.go
```

Do not use `gopls check ./...`. Give gopls explicit non-generated Go file paths.

```bash
nix develop --command gopls check $(find cmd internal web -name '*.go' -not -name '*_templ.go' -print)
```

If the project has test and build tasks, use them. If not, run:

```bash
go test ./...
go build ./cmd/...
```

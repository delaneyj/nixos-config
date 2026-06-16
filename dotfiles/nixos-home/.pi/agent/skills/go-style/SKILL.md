---
name: go-style
description: Go code style preferences. Use when editing Go code, especially value/domain types, encoding/decoding, key serialization, composite literals, helper functions, and file organization.
---

# Go Style

Apply these style choices when writing or refactoring Go code.

## File organization

- Prefer one file per concrete type, domain concept, or wire kind.
  - Example: `matrix2.go`, `matrix3.go`, `matrix4.go` rather than a combined `matrix.go`.
- Put type-specific encode/decode/append/marshal helpers in the file for that type.
- Keep central files for shared dispatch, interfaces, or low-level reusable helpers only.

## Domain types and interfaces

- Owned concrete domain types should implement relevant interfaces directly.
- Avoid adapter/wrapper structs for owned concrete types when methods can be placed on the type itself.
- Wrapper types are acceptable when Go requires them for primitives, external types, interface boundaries, or when they preserve public API behavior intentionally.

## Serialization and key encoding

- Prefer each type owning its own serialization methods.
- Avoid central type-switches for behavior that naturally belongs on the type, such as ordered key encoding.
- Shared helpers are fine for repeated mechanics, e.g. ordered numeric sequences or raw binary append loops.

## Variadics

- Prefer variadic parameters for helper APIs that consume homogeneous values and do not need callers to pre-build or retain a slice; actively check new and touched helpers for this shape.
- Keep explicit slice parameters when the input is naturally a collection, caller ownership/capacity matters, nil-vs-empty is semantically meaningful, or avoiding allocation is important.
- When forwarding a slice to a variadic helper, use slice expansion (`values...`) instead of rebuilding the slice.

## Raw append helpers

- Prefer generic variadic append helpers for repeated homogeneous primitive encoding.
  - Example shape:
    ```go
    func appendRawInt64[T ~int64](dst []byte, values ...T) []byte
    func appendRawUint64[T ~uint64](dst []byte, values ...T) []byte
    ```
- Use slice expansion for fixed numeric arrays where possible:
  ```go
  appendRawInt64(dst, v[:]...)
  appendRawFloat64s(dst, v[:]...)
  ```

## Composite literal formatting

- Prefer multiline keyed composite literals by default, including `var`, `const`-adjacent config values, returns, and nested fields.
- Avoid single-line keyed composite literals except tiny local test fixtures where readability is clearly better.
- Align keyed fields with `gofmt`:
  ```go
  var Line3Meta = Meta{
      WireName: "line3",
      Label:    "Line 3",
      Icon:     "material-symbols:process-chart",
      Group:    GroupGeometry,
      Example:  "start → end",
  }
  ```
- Format keyed returns as multiline literals:
  ```go
  return Sphere{
      Center: center,
      Radius: math.Sqrt(maxRadiusSq),
  }
  ```
- Format nested keyed literals as multiline/nested blocks:
  ```go
  return Box2{
      Min: Float64V2{
          math.Inf(1), math.Inf(1),
      },
      Max: Float64V2{
          math.Inf(-1),
          math.Inf(-1),
      },
  }
  ```
- Apply this consistently to decode/unmarshal/constructor returns too.

## Long argument lists

- Break long helper calls across lines, especially serialization calls with many values:
  ```go
  return appendRawFloat64s(
      appendHeader(dst, sphereKind),
      v.Center[0], v.Center[1], v.Center[2],
      v.Radius,
  )
  ```

## Control-flow spacing

- Separate logical phases with blank lines.
- Add a blank line after early-return guard blocks before starting the next phase.
- Add a blank line before final fallback/default return when it follows a non-trivial conditional block.

## Variable declarations

- Group related zero-value declarations in a var block when they share a scope and are assigned later:
  ```go
  var (
      resumedBytes int64
      file         *os.File
  )
  expectedSize := int64(-1)
  ```
- Prefer `:=` with explicit conversion for non-zero sentinel initializers over typed `var` initializers:
  ```go
  expectedSize := int64(-1)
  ```

## Helpers

- Do not add single-use package-level funcs, vars, consts, or types.
- Inline single-use helpers unless they are needed for tests, interfaces, recursion, generic reuse, or materially clearer repeated structure.

## Ignored return values

- Do not write blank assignments for returns that can be safely discarded. Call the function directly instead.
  - Prefer: `hash.Write([]byte("sqlite\x00"))`
  - Avoid: `_, _ = hash.Write([]byte("sqlite\x00"))`
- Keep explicit ignored assignments only when they add signal for real error-producing APIs or satisfy an interface/control-flow need.

## Validation

After major Go changes, run gopls, the repository's normal Go validation command, and a Go binary build; all must pass cleanly before reporting completion.

Prefer project-local gopls if available:

```bash
go tool gopls check ./path/to/changed.go
```

If gopls is not installed as a tool, use `gopls check` when available in PATH.

For Nix flake projects without gopls, add `gopls` to the dev shell packages in `flake.nix`, then run gopls through the shell:

```nix
packages = with pkgs; [
  go_1_25
  gopls
];
```

```bash
nix develop --command gopls check ./path/to/changed.go
```

Do not use `gopls check ./...`; gopls treats `./...` as a file path in some versions. To check all non-generated Go files, pass explicit file paths, for example:

```bash
nix develop --command gopls check $(find cmd internal web -name '*.go' -not -name '*_templ.go' -print)
```

Prefer the project-specific test task if one exists; otherwise use:

```bash
go test ./...
```

Also verify the application binary builds before finishing Go work. Prefer the project build task if one exists:

```bash
task build
```

If there is no project build task, build changed main packages explicitly, for example:

```bash
go build ./cmd/...
```

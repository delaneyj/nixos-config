---
name: sqlc-zombiezen-sqlite
description: sqlc + sqlc-gen-zombiezen setup for Go services using zombiezen.com/go/sqlite. Use when adding SQLite-backed services, SQL migrations/queries, sqlc.yaml configs, generated zz packages, or Taskfile codegen tasks.
---

# sqlc + zombiezen SQLite

Use the `ria-pulse` pattern for SQLite services that generate typed `zombiezen.com/go/sqlite` accessors with `github.com/delaneyj/toolbelt/sqlc-gen-zombiezen`.

## Source example

Reference `~/repos/ria-pulse`:

- `Taskfile.yml` — `tools`, `sqlc`, `templ`, `build` task wiring.
- `go.mod` — `tool (...)` entries for `sqlc`, `templ`, `buf`, `sqlc-gen-zombiezen`.
- `services/*/sql/sqlc.yaml` — per-service sqlc config.
- `services/*/sql/migrations/*.sql` — embedded migrations.
- `services/*/sql/queries/*.sql` — named sqlc queries.
- `services/*/server.go` — embedded migrations + `db.NewDatabase` setup.
- `services/*/service.go` / `db.go` — `ReadTX`/`WriteTX` with generated `zz` calls.

## Directory layout

Per SQLite-backed service:

```text
services/<service>/
  server.go
  service.go
  sql/
    sqlc.yaml
    migrations/
      0000_schema.sql
      0001_next_change.sql
    queries/
      <domain>.sql
    zz/              # generated, gitignored
```

Keep each service's schema and queries local. Do not centralize unrelated service SQL.

## sqlc config

Use a per-service `sql/sqlc.yaml`:

```yaml
version: "2"

plugins:
  - name: zz
    process:
      cmd: sqlc-gen-zombiezen

sql:
  - engine: sqlite
    schema: ./migrations
    queries: ./queries
    codegen:
      - out: zz
        plugin: zz
```

Run `sqlc generate` from the `sql/` directory so relative paths resolve.

## Taskfile wiring

Root task pattern:

```yaml
tasks:
  tools:
    deps/source inputs: go.mod/go.sum
    cmds:
      - mkdir -p bin
      - GOBIN={{.ROOT_DIR}}/bin go install github.com/delaneyj/toolbelt/sqlc-gen-zombiezen@latest

  sqlc:
    deps: [tools]
    env:
      PATH: "{{.ROOT_DIR}}/bin:{{.PATH}}"
    vars:
      SQLC_CONFIGS:
        sh: find . -name sqlc.yaml
    sources:
      - "**/*.sql"
      - "**/sqlc.yaml"
    generates:
      - "**/zz/*.go"
    cmds:
      - |
        {{- $root := .ROOT_DIR -}}
        {{- range $config := (splitLines .SQLC_CONFIGS) }}
          dir=$(dirname "{{$config}}")
          echo ">> go tool sqlc generate ($dir)"
          (cd "$dir" && PATH="{{$root}}/bin:$PATH" go tool sqlc generate)
        {{- end }}
```

Build tasks should depend on `sqlc` before `go build`.

## Gitignore

Generated DB accessors are build artifacts:

```gitignore
zz
```

Also ignore local tool bins if using the root `bin/` pattern.

## Migrations

- Store ordered migrations in `sql/migrations` with `0000_schema.sql`, `0001_*.sql`, etc.
- In `server.go`:
  ```go
  //go:embed sql/migrations/*.sql
  var migrationsFS embed.FS
  ```
- Load/apply via toolbelt DB helpers:
  ```go
  migrations, err := db.MigrationsFromFS(migrationsFS, "sql/migrations")
  if err != nil { return fmt.Errorf("<service>: load migrations: %w", err) }

  database, err := db.NewDatabase(ctx,
      db.DatabaseWithFilename("data/<service>.db"),
      db.DatabaseWithMigrations(migrations),
      db.DatabaseWithShouldClear(env.ResetDatabase),
  )
  ```

## Query files

Prefer generated CRUD before writing custom named queries:

- Use generated `Create*`, `Upsert*`, `ReadAll*`, `ReadByID*`, `Update*`, `Delete*` when they express the operation.
- Add custom `-- name:` queries only for filters, joins, projections, aggregates, `RETURNING`, bulk operations, or domain-specific SQL not covered by CRUD.
- Do not duplicate generated CRUD with hand-written named queries unless the custom query has different semantics.
- Before adding or keeping any `INSERT`, `UPDATE`, `DELETE`, `SELECT ... WHERE id = ?`, `SELECT COUNT(*)`, or `SELECT * FROM <single_table>` query, inspect generated `zz/crud_main_<table>.go` and remove the custom query if CRUD already covers it.
- Keep custom named queries only when the SQL cannot be expressed by generated CRUD, e.g. FTS `MATCH`, lookup by non-ID unique key, joins, projections, aggregates not generated, bulk `IN`, or `RETURNING` that intentionally omits caller-supplied IDs.

Use sqlc comments:

```sql
-- name: ListThings :many
SELECT id, name
FROM things
WHERE owner_id = ?
ORDER BY name;

-- name: InsertThingReturning :one
INSERT INTO things (id, owner_id, name)
VALUES (?, ?, ?)
RETURNING id, owner_id, name;

-- name: DeleteThings :exec
DELETE FROM things
WHERE id IN (sqlc.slice('ids'));
```

Guidelines:

- Use `?`/`?1` SQLite parameters.
- Use `sqlc.slice('name')` for `IN` lists.
- Prefer explicit column lists over `SELECT *`.
- Add `RETURNING` when the caller needs generated/defaulted fields.
- Keep domain query files cohesive (`users.sql`, `firm_views.sql`, `metrics.sql`).

## Generated `zz` API

The plugin generates:

- Model types from tables: `<TableSingular>Model` in `crud_main_<table>.go`.
- CRUD helpers for tables: `Create*`, `Upsert*`, `ReadAll*`, `ReadByID*`, `Update*`, `Delete*` where applicable.
- Named query statement types: `<QueryName>Stmt` with `Run(...)`.
- Convenience one-shot functions: `Once<QueryName>(tx, ...)`.
- Param structs for multi-param named queries: `<QueryName>Params`.
- Result structs for ad hoc result sets: `<QueryName>Res`.

Use `Once*` only for one-off calls per transaction. Do not call `zz.Once*` inside loops; it prepares a statement each call. In loops/batches, create the statement once and reuse/reset it via `Run`:

```go
return db.WriteTX(ctx, func(tx *sqlite.Conn) error {
    insertThing := zz.InsertThing(tx)
    for _, thing := range things {
        if err := insertThing.Run(thing); err != nil {
            return err
        }
    }
    return nil
})
```

Generated `Run` methods reset/clear bindings after each call; the reusable stmt owns the prepared SQLite statement for the transaction.

## Service usage

Always call generated `zz` functions inside explicit DB transactions:

```go
if err := s.db.ReadTX(ctx, func(tx *sqlite.Conn) error {
    rows, err := zz.OnceListThings(tx, zz.ListThingsParams{
        OwnerId: ownerID,
        Limit:   int64(limit),
    })
    if err != nil {
        return err
    }
    // map zz rows to service/domain types here
    return nil
}); err != nil {
    return nil, err
}
```

Use `WriteTX` for mutations. Keep `zz` models at the storage boundary; map to API/domain/view types in service code.

Avoid `sqlitex.Execute`/`ExecuteTransient` for application queries unless absolutely necessary. Prefer generated `zz` statements. If raw SQL is unavoidable, prepare a `sqlite.Stmt`, bind explicitly, call `stmt.Step`, and reset/clear bindings in the standard statement pattern.

## Types

Project preference:

- Use `INTEGER PRIMARY KEY` / `INTEGER` `int64` IDs for all entity IDs and foreign keys. Do not use text IDs unless explicitly required by an external system.
- Store xxh3 hashes as binary `BLOB` values, not hex/base64 `TEXT`, unless an external API explicitly needs encoded text.

Observed mappings:

- SQLite `INTEGER` -> `int64` or `bool` for boolean-ish columns.
- Nullable text -> `*string`.
- Julian day `REAL` timestamps -> `time.Time` via `toolbelt/db` conversions in generated code.
- JSON columns remain strings unless mapped manually at the service boundary.

## Verification

After schema/query changes:

```bash
task sqlc
go test ./...
```

If the repo has a full build/codegen task, run that instead or after `task sqlc`.

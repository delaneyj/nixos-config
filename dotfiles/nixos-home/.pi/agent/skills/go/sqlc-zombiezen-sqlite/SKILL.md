---
name: sqlc-zombiezen-sqlite
description: Defines sqlc and sqlc-gen-zombiezen configuration for Go SQLite services.
---

# sqlc and zombiezen SQLite

Use the `ria-pulse` pattern with `zombiezen.com/go/sqlite` and `github.com/delaneyj/toolbelt/sqlc-gen-zombiezen`.

## Source data

Examine `~/repos/ria-pulse`:

- Examine `Taskfile.yml` for tool, sqlc, templ, and build tasks.
- Examine `go.mod` for tool entries.
- Examine `services/*/sql/sqlc.yaml` for service configurations.
- Examine `services/*/sql/migrations/*.sql` for embedded migrations.
- Examine `services/*/sql/queries/*.sql` for named queries.
- Examine `services/*/server.go` for migration and database setup.
- Examine `services/*/service.go` and `db.go` for transactions and generated calls.

## Service files

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
    zz/              # generated and ignored by git
```

Keep each schema and its queries in the service. Do not combine unrelated service SQL.

## sqlc configuration

Put this configuration in each `sql/sqlc.yaml`:

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

Run `sqlc generate` from the `sql` directory. Relative paths depend on this directory.

## Taskfile

- Add `sqlc-gen-zombiezen` to the tool installation task.
- Install it in the repository `bin` directory.
- Make the `sqlc` task depend on tools.
- Add repository `bin` to `PATH`.
- Find all `sqlc.yaml` files.
- Track SQL and sqlc configuration files as sources.
- Track `zz/*.go` as generated files.
- Run `go tool sqlc generate` in each configuration directory.
- Make build tasks depend on `sqlc`.

Use this core command:

```bash
dir=$(dirname "$config")
(cd "$dir" && PATH="$root/bin:$PATH" go tool sqlc generate)
```

Ignore generated accessors and local tools:

```gitignore
zz
bin
```

Use the repository convention when the repository tracks `bin`.

## Migrations

- Use ordered names such as `0000_schema.sql` and `0001_next_change.sql`.
- Embed `sql/migrations/*.sql` in `server.go`.
- Load migrations with `db.MigrationsFromFS`.
- Create the database with `db.NewDatabase` and applicable options.

```go
//go:embed sql/migrations/*.sql
var migrationsFS embed.FS

migrations, err := db.MigrationsFromFS(migrationsFS, "sql/migrations")
if err != nil {
    return fmt.Errorf("<service>: load migrations: %w", err)
}

database, err := db.NewDatabase(
    ctx,
    db.DatabaseWithFilename("data/<service>.db"),
    db.DatabaseWithMigrations(migrations),
    db.DatabaseWithShouldClear(env.ResetDatabase),
)
```

## Queries

Use generated CRUD before custom named queries.

- Use generated create, upsert, read, update, and delete functions when applicable.
- Add named queries only for different SQL behavior.
- Examples include joins, filters, projections, aggregates, FTS, bulk operations, and special `RETURNING` clauses.
- Before custom CRUD, examine `zz/crud_main_<table>.go`.
- Remove a custom query when generated CRUD has the same behavior.
- Keep query files cohesive by domain.
- Use explicit columns. Do not use `SELECT *`.
- Use `?` or `?1` parameters.
- Use `sqlc.slice('name')` for `IN` lists.
- Add `RETURNING` when the caller needs database-generated values.

```sql
-- name: ListThings :many
SELECT id, name
FROM things
WHERE owner_id = ?
ORDER BY name;

-- name: DeleteThings :exec
DELETE FROM things
WHERE id IN (sqlc.slice('ids'));
```

## Generated API

The plugin generates these items:

- `<TableSingular>Model` table models.
- CRUD functions where applicable.
- `<QueryName>Stmt` with `Run(...)`.
- `Once<QueryName>(tx, ...)` functions.
- `<QueryName>Params` for multiple parameters.
- `<QueryName>Res` for ad hoc results.

Use `Once*` only for one call in a transaction. It prepares a statement for each call.

For loops and batches, prepare before the loop. Reuse `Run`:

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

Generated `Run` methods reset and clear bindings after each call.

## Service boundary

- Call generated functions only from `ReadTX` or `WriteTX`.
- Use `WriteTX` for state changes.
- Keep generated models at the storage boundary.
- Map them to domain, API, or view types in service code.
- Do not use `sqlitex.Execute` or `ExecuteTransient` for usual application queries.
- If raw SQL is necessary, prepare, bind, step, reset, and clear a `sqlite.Stmt`.

```go
if err := s.db.ReadTX(ctx, func(tx *sqlite.Conn) error {
    rows, err := zz.OnceListThings(tx, zz.ListThingsParams{
        OwnerId: ownerID,
        Limit:   int64(limit),
    })
    if err != nil {
        return err
    }
    // Map rows to service types.
    return nil
}); err != nil {
    return nil, err
}
```

## Types

- Use `INTEGER PRIMARY KEY` and `int64` for entity and foreign-key IDs.
- Use text IDs only when an external system requires them.
- Store xxh3 hashes as binary `BLOB` values.
- Use encoded text only for an external API requirement.
- Map nullable text to `*string`.
- Map Julian day `REAL` timestamps through `toolbelt/db` time conversions.
- Keep JSON columns as strings until the service boundary maps them.

## Verification

After schema or query changes, run:

```bash
task sqlc
go test ./...
```

Use the full repository build or code-generation task when the repository has one.

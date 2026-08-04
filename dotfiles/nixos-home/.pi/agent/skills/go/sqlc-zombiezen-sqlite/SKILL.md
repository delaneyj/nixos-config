---
name: sqlc-zombiezen-sqlite
description: Defines sqlc and sqlc-gen-zombiezen configuration for Go SQLite services.
---

# sqlc and zombiezen SQLite

Use the `ria-pulse` pattern with `zombiezen.com/go/sqlite` and `github.com/delaneyj/toolbelt/sqlc-gen-zombiezen`.

## Source and references
Check these in `~/repos/ria-pulse`:
- `Taskfile.yml` for tool/build/test wiring.
- `go.mod` for tool dependencies.
- `services/*/sql/sqlc.yaml`.
- `services/*/sql/migrations/*.sql`.
- `services/*/sql/queries/*.sql`.
- `services/*/server.go` for DB setup and migrations.
- `services/*/service.go` and `db.go` for transaction boundaries.

## Service shape
Each service keeps SQL separate:

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
    zz/
```

- Keep each domain and schema inside its service.
- Do not mix unrelated schemas/queries.

## sqlc.yaml
Use this exact config in each `sql/sqlc.yaml`:

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

## Taskfile and tooling
- Add `sqlc-gen-zombiezen` to tool install task.
- Install in repo `bin`.
- Make `sqlc` task depend on tools.
- Add `bin` to `PATH` for generation.
- Track SQL config and source files as sources.
- Track `zz/*.go` as generated.

Run generation per config directory:

```bash
dir=$(dirname "$config")
(cd "$dir" && PATH="$root/bin:$PATH" go tool sqlc generate)
```

- Ignore generated accessors and local tools:

```gitignore
zz
bin
```

- Respect repo conventions for checked-in `bin`.

## Migrations and DB setup
- Name migrations sequentially (`0000_schema.sql`, `0001_...`).
- Embed migrations in `server.go` and load with `db.MigrationsFromFS`.

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
- Use generated CRUD functions first (`create`, `upsert`, `read`, `update`, `delete`).
- Add named queries only for distinct SQL behavior.
- Domain examples: joins, filters, projections, aggregates, FTS, bulk ops, special `RETURNING`.
- Check `zz/crud_main_<table>.go` before adding custom CRUD.
- Remove custom query when CRUD matches behavior.
- Keep query files coherent by domain.
- Use explicit column lists.
- Use `?`/`?1` positional parameters.
- Use `sqlc.slice('name')` for `IN` lists.

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

## Generated API usage
Generated names include:
- `<TableSingular>Model`
- CRUD functions
- `<QueryName>Stmt` with `Run(...)`
- `Once<QueryName>(tx, ...)`
- `<QueryName>Params`
- `<QueryName>Res`

Use `Once*` for one-time transactional calls.
Use `Run` for loops and batches.

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
- Call generated code only inside `ReadTX` or `WriteTX`.
- Use `WriteTX` for mutation.
- Keep generated models at storage boundary.
- Map to domain/API/view types in service layer.
- Do not use `sqlitex.Execute` / `ExecuteTransient` for normal queries.
- For raw SQL, prepare/bind/step/reset/clear explicitly.

```go
if err := s.db.ReadTX(ctx, func(tx *sqlite.Conn) error {
	rows, err := zz.OnceListThings(tx, zz.ListThingsParams{
		OwnerId: ownerID,
		Limit:   int64(limit),
	})
	if err != nil {
		return err
	}
	// map rows
	return nil
}); err != nil {
	return nil, err
}
```

## Types and storage
- Use `INTEGER PRIMARY KEY` and `int64` IDs.
- Use text IDs only for external systems.
- Store xxh3 as binary `BLOB`.
- Keep encoded text only at external API boundary.
- Map nullable text to `*string`.
- Convert Julian day `REAL` via `toolbelt/db` time helpers.
- Keep JSON columns as strings until boundary mapping.

## Verification
After schema/query changes run:

```bash
task sqlc
go test ./...
```

Use repo full build/task when available.

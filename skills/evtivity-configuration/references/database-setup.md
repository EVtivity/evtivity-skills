Generated from https://www.evtivity.com/docs/configuration/database-setup (website commit 257c8b8). Do not edit.

# Database Setup

PostgreSQL, Redis, Drizzle ORM configuration, and migration workflow.

## PostgreSQL

EVtivity requires PostgreSQL 17.

### Default Connection

```bash
postgres://evtivity:evtivity@localhost:5433/evtivity
```

Set via the `DATABASE_URL` environment variable.

### Using Docker

The included `docker-compose.yml` runs PostgreSQL on port 5433 (external) mapped to 5432 (internal):

```bash
docker compose up postgres
```

pgAdmin is available on port 7109 when you start with the tools profile:

```bash
docker compose --profile tools up
```

## Drizzle ORM

EVtivity uses Drizzle ORM for schema definition, migrations, and queries.

### Schema Organization

Schema files live in `packages/database/src/schema/` with 33 files organized by domain (stations, sessions, drivers, billing, notifications, etc.).

### Key Conventions

- **Primary keys**: Nanoid text PKs for user-facing entities with domain prefixes (`sta_`, `ses_`, `drv_`). Serial integers for internal tables.
- **Timestamps**: All timestamp columns use `timestamp with time zone`.
- **Money**: Monetary values stored in cents as integers.
- **Energy**: Energy values stored in watt-hours (Wh) as integers.

### Migration Commands

Run these from the repository root:

| Command | Description |
|---|---|
| `npm run check:migrations` | Check the migrations journal: every SQL file has an entry, indexes are sequential, and timestamps increase |
| `npm run db:migrate` | Apply pending migrations to the database |
| `npm run db:seed` | Seed the database with initial data. Re-running adds only missing settings, roles, and users and keeps existing values, including the admin password. `npm run db:seed -- --apply-config` writes the values from `packages/database/seed.config.json` over existing settings. |

Write each migration by hand. A schema change in `packages/database/src/schema/` needs a migration in the same change: the next numbered, idempotent SQL file in `packages/database/src/migrations/` (guarded statements such as `CREATE TABLE IF NOT EXISTS` and `ADD COLUMN IF NOT EXISTS`) and its entry in `packages/database/src/migrations/meta/_journal.json`. Do not use `npm run generate`: the Drizzle snapshot baseline is frozen, so it cannot diff the schema correctly. Run `npm run check:migrations`, then `npm run db:migrate`.

### Rules

- Never create new `postgres()` connections. Use the shared database client from `@evtivity/database`.
- Never import from another package's schema files directly. Use the re-exports from the database package.

## Redis

Redis is required for three purposes:

1. **Pub/sub**: Inter-service communication between API and OCPP servers, and server-sent events (SSE) to frontends.
2. **Job queues**: BullMQ handles background jobs (notifications, billing, certificate management).
3. **Caching**: Session data, rate limiting, and connection registry.

Default connection:

```bash
redis://localhost:6379
```

Set via the `REDIS_URL` environment variable.

Each service connects as its own Redis ACL user (`api`, `ocpp`, `ocpi`, `worker`, `css`) with only the keys, pub/sub channels, and commands it needs. Docker Compose creates the users from `docker/redis/acl-rules.conf` and gives each service its own `REDIS_URL`. The Redis `default` user stays open for tools on the host, so Compose publishes port 6379 on `127.0.0.1` only. Set `REDIS_API_PASSWORD`, `REDIS_OCPP_PASSWORD`, `REDIS_OCPI_PASSWORD`, `REDIS_WORKER_PASSWORD`, and `REDIS_CSS_PASSWORD` to replace the development passwords when the stack runs on a shared host.

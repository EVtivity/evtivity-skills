Generated from https://www.evtivity.com/docs/deployment/docker-compose. Do not edit.

# Docker Compose

Run all EVtivity services locally with Docker Compose, including optional tools and monitoring.

## Core Services

The default `docker compose up` starts the core services needed to run EVtivity:

| Service   | Host Port | Container Port | Description                          |
|-----------|-----------|----------------|--------------------------------------|
| postgres  | 5433      | 5432           | PostgreSQL 17 database               |
| redis     | 6379      | 6379           | Redis 8 cache and job queue          |
| migrate   | -         | -              | Runs Drizzle migrations, then exits  |
| api       | 7102      | 7102           | Fastify REST API                     |
| ocpp      | 7103      | 7103, 8443     | OCPP WebSocket server                |
| csms      | 7100      | 8080           | Management dashboard (nginx)         |
| portal    | 7101      | 8080           | Driver portal (nginx)                |
| worker    | -         | -              | BullMQ job processors: cron jobs, load management, guest session linking, reservation activation, OCTT runs |
| simulator | -         | -              | Charging station simulator           |

All services include health checks. The `migrate` service runs first, and dependent services wait for it to complete.

```bash
docker compose up
```

## Secrets

`docker compose up` needs `JWT_SECRET` and `SETTINGS_ENCRYPTION_KEY` in `.env`: `docker-compose.yml` has no defaults for them and stops with an error without them. `scripts/docker-build.sh` writes random values (`openssl rand -hex 32`) into `.env` when a value is missing or a published example value. It keeps the built-in `SETTINGS_ENCRYPTION_KEY` of a stack whose database volume already exists and prints a warning, because a new key cannot decrypt the credentials stored with it.

The script also writes a random `REDIS_ADMIN_PASSWORD` and random passwords for the service Redis users (`REDIS_API_PASSWORD`, `REDIS_OCPP_PASSWORD`, `REDIS_OCPI_PASSWORD`, `REDIS_WORKER_PASSWORD`, `REDIS_CSS_PASSWORD`) when one is missing or the published default. Redis loads them when its container is recreated.

## Redis Users

Each service signs in to Redis as its own user. The Redis `default` user is off, so nothing reaches Redis without a password. Host tools (`npm run dev:*`, `redis-cli`, the integration tests) sign in as the development-only `admin` user with `REDIS_ADMIN_PASSWORD`:

```bash
redis-cli --user admin --pass "$REDIS_ADMIN_PASSWORD" ping
```

## Port Binding

User-facing ports (csms, portal, api, ocpp including 8443, ocpi) bind to `BIND_IP` (default `0.0.0.0`). Infrastructure and tool ports (postgres 5433, pgadmin 7109, mailpit 7108 and SMTP 1025, ftp 21 and 30000-30009, prometheus 9090, grafana 7107, loki 3100) bind to `INFRA_BIND_IP` (default `127.0.0.1`), because these services use default logins. Redis (6379) and the OCPP server's Node inspector (9229) always bind to `127.0.0.1`. The inspector also listens on `127.0.0.1` inside the container; set `NODE_INSPECT=--inspect=0.0.0.0:9229` in `.env` to attach a debugger from the host.

To expose the infrastructure ports, set `INFRA_BIND_IP=0.0.0.0` (or a LAN IP) in `.env`. Do this only on a trusted network. Before you expose PostgreSQL, change its default `evtivity` / `evtivity` login. Otherwise reach them from another machine through an SSH tunnel, for example for Grafana:

```bash
ssh -N -L 7107:localhost:7107 user@your-host
```

## Profiles

Optional services are grouped into profiles. Add the `--profile` flag to include them.

### Tools

```bash
docker compose --profile tools up
```

| Service  | Host Port | Description                    |
|----------|-----------|--------------------------------|
| pgadmin  | 7109      | PostgreSQL admin UI            |
| mailpit  | 7108, 1025 | Local email testing (SMTP)     |
| ftp      | 21, 30000-30009 | FTP server for firmware files  |

### Monitoring

```bash
docker compose --profile monitoring up
```

| Service    | Host Port | Description                       |
|------------|-----------|-----------------------------------|
| prometheus | 9090      | Metrics collection                |
| grafana    | 7107      | Dashboards and alerting           |
| loki       | 3100      | Log aggregation                   |
| alloy      | -         | Grafana Alloy log/metric shipper  |

### OCPI

```bash
docker compose --profile ocpi up
```

| Service      | Host Port | Description                   |
|--------------|-----------|-------------------------------|
| ocpi         | 7104      | OCPI roaming server           |
| ocpi-simulator | -         | OCPI eMSP simulator           |
| ocpi-cpo-sim | -         | OCPI CPO simulator            |

## Development Infrastructure Only

To start only the infrastructure services (useful for local development where you run application services directly):

```bash
npm run dev:infra
```

This starts postgres, redis, migrate, mailpit, prometheus, grafana, loki, and alloy.

## Volumes

Persistent data is stored in named Docker volumes:

- `pgdata` - PostgreSQL data. It grows with the number of connected stations, most of all in `ocpp_message_logs` and `meter_values`. Chaos mode with many simulated stations can fill tens of gigabytes. See [Data Retention](https://www.evtivity.com/docs/configuration/data-retention).
- `redisdata` - Redis data
- `ftpdata` - FTP server files
- `pgadmindata` - pgAdmin configuration
- `prometheusdata` - Prometheus metrics
- `grafanadata` - Grafana dashboards and config
- `lokidata` - Loki log data

## Environment Variables

All environment variables except the secrets above have shell defaults defined in `docker-compose.yml`. Override them by setting values in your shell or a `.env` file before running `docker compose up`.

```bash
# Example: override the database password
DATABASE_URL=postgres://user:pass@localhost:5433/evtivity docker compose up
```

## Storage Image Origins

The CSMS and portal containers allow images from Amazon S3 (`https://*.amazonaws.com`). With an S3-compatible storage provider (MinIO or Wasabi), set `STORAGE_IMG_SRC` in `.env` to the origins stored images load from. Docker Compose passes it to the `csms` and `portal` services. At startup, each container adds the origins to the `img-src` of its Content Security Policy.

- Space-separated origins, each `scheme://host[:port]`, with an optional `*.` wildcard, for example `https://s3.example.com http://minio.local:9000`.
- Any other value, such as a path, a quote, or a semicolon, stops the container.
- With path-style requests off, images load from `<bucket>.<endpoint host>`, so list that origin.
- Empty by default. Amazon S3 needs nothing here.

```bash
STORAGE_IMG_SRC=https://s3.example.com
```

See [S3 Bucket](https://www.evtivity.com/docs/csms/settings#s3-bucket).

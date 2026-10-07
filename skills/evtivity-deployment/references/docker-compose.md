Generated from https://www.evtivity.com/docs/deployment/docker-compose (website commit ffa3c26). Do not edit.

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

## Port Binding

User-facing ports (csms, portal, api, ocpp including 8443, ocpi) bind to `BIND_IP` (default `0.0.0.0`). Infrastructure and tool ports (postgres 5433, pgadmin 7109, mailpit 7108 and SMTP 1025, ftp 21 and 30000-30009, prometheus 9090, grafana 7107, loki 3100) bind to `INFRA_BIND_IP` (default `127.0.0.1`), because these services use default logins. Redis (6379) and the OCPP server's Node inspector (9229) always bind to `127.0.0.1`.

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

- `pgdata` - PostgreSQL data
- `redisdata` - Redis data
- `ftpdata` - FTP server files
- `pgadmindata` - pgAdmin configuration
- `prometheusdata` - Prometheus metrics
- `grafanadata` - Grafana dashboards and config
- `lokidata` - Loki log data

## Environment Variables

All environment variables have shell defaults defined in `docker-compose.yml`. Override them by setting values in your shell or a `.env` file before running `docker compose up`.

```bash
# Example: override the database password
DATABASE_URL=postgres://user:pass@localhost:5433/evtivity docker compose up
```

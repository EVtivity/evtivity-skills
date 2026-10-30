Generated from https://www.evtivity.com/docs/deployment/docker. Do not edit.

# Docker

Docker images for each EVtivity service, registry details, and resource recommendations.

## Image Registry

All images are published to `ghcr.io/evtivity/evtivity-csms`. Each service has its own image built from a multi-stage Dockerfile.

| Service   | Image                          | Ports         |
|-----------|--------------------------------|---------------|
| API       | `ghcr.io/evtivity/evtivity-csms/api` | 7102          |
| OCPP      | `ghcr.io/evtivity/evtivity-csms/ocpp` | 7103, 8443    |
| CSMS      | `ghcr.io/evtivity/evtivity-csms/csms` | 8080          |
| Portal    | `ghcr.io/evtivity/evtivity-csms/portal` | 8080          |
| Worker    | `ghcr.io/evtivity/evtivity-csms/worker` | -             |
| CSS       | `ghcr.io/evtivity/evtivity-csms/css` | -             |
| OCPI      | `ghcr.io/evtivity/evtivity-csms/ocpi` | 7104          |
| Migrate   | `ghcr.io/evtivity/evtivity-csms/migrate` | -             |

## Build Context

Each image uses a multi-stage Dockerfile. The first stage installs dependencies and builds. The final stage copies only the production output, keeping images small.

```bash
docker build -f packages/api/Dockerfile -t ghcr.io/evtivity/evtivity-csms/api .
```

Run builds from the monorepo root so the build context includes shared packages.

## Production Mode

The API, OCPP, OCPI and worker images set `NODE_ENV=production`. In production mode the simulated payment provider is off unless `PAYMENTS_ALLOW_SIMULATED=true` is set, and the API refuses a short or published `JWT_SECRET`. For a test install outside Docker Compose, Helm or CDK, set `NODE_ENV=development` and `PAYMENTS_ALLOW_SIMULATED=true` on the containers, or configure a real payment provider. See [Environment Variables](https://www.evtivity.com/docs/configuration/environment-variables).

## Frontend Images (CSMS and Portal)

CSMS and Portal are static React builds served by nginx. Both support runtime configuration through a `/runtime-config.js` file that injects the API URL without rebuilding the image.

```js
// /runtime-config.js (injected at container startup)
window.__RUNTIME_CONFIG__ = {
  API_URL: "https://api.example.com",
};
```

Set the `API_URL` environment variable on the container. The entrypoint script generates `/runtime-config.js` before nginx starts.

The entrypoint also renders the security headers into `/tmp`, so the containers run with a read-only root filesystem. Set `STORAGE_IMG_SRC` to add the origins of an S3-compatible storage provider to the `img-src` of the Content Security Policy. It takes space-separated origins, each `scheme://host[:port]`, with an optional `*.` wildcard. Any other value stops the container. See [Environment Variables](https://www.evtivity.com/docs/configuration/environment-variables#frontend).

## OCPP Image

The OCPP image exposes two ports:

- **7103** for WebSocket (ws://) connections
- **8443** for secure WebSocket (wss://) connections with TLS

Both ports accept OCPP 1.6, 2.0.1 and 2.1 connections. Configure TLS certificates via environment variables for port 8443.

## Worker Image

The Worker image runs BullMQ job processors for background tasks: session finalization, billing calculations, notification dispatch, scheduled reports, and OCPI sync jobs. It connects to Redis for the job queue and PostgreSQL for data access.

## Migrate Image

The Migrate image runs Drizzle migrations on startup and exits. Use it as an init container or a dependency that other services wait on before starting. It ensures the database schema is up to date before the API or OCPP services accept connections.

## Resource Recommendations

| Service       | Memory | CPU   | Notes                                    |
|---------------|--------|-------|------------------------------------------|
| API           | 1 GB   | 1 CPU | Stateless. Scale horizontally.           |
| OCPP          | 4 GB   | 2 CPU | Holds WebSocket connections in memory.   |
| CSMS          | 1 GB   | 0.5 CPU | Static files served by nginx.          |
| Portal        | 1 GB   | 0.5 CPU | Static files served by nginx.          |
| Worker        | 1 GB   | 0.5 CPU | Scales with job volume.                |

These are starting points. Monitor actual usage and adjust based on your station count and traffic patterns.

### Database Storage

PostgreSQL storage grows with the number of connected stations. Every OCPP message is a row in `ocpp_message_logs`, heartbeats included, and every meter reading is a row in `meter_values`. On a test network of about 2,000 simulated stations that stayed connected, the database reached 90 GB: `ocpp_message_logs` held about 100 million rows (57 GB) and `meter_values` about 61 million rows (32 GB). Plan the disk for your station count, and lower the retention of these tables in **Settings > Data Retention** for a large network or chaos mode. See [Data Retention](https://www.evtivity.com/docs/configuration/data-retention).

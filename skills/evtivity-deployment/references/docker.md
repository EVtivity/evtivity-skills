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

## Frontend Images (CSMS and Portal)

CSMS and Portal are static React builds served by nginx. Both support runtime configuration through a `/runtime-config.js` file that injects the API URL without rebuilding the image.

```js
// /runtime-config.js (injected at container startup)
window.__RUNTIME_CONFIG__ = {
  API_URL: "https://api.example.com",
};
```

Set the `API_URL` environment variable on the container. The entrypoint script generates `/runtime-config.js` before nginx starts.

## OCPP Image

The OCPP image exposes two ports:

- **7103** for WebSocket (ws://) connections
- **8443** for secure WebSocket (wss://) connections with TLS

Both ports accept OCPP 1.6 and 2.1 connections. Configure TLS certificates via environment variables for port 8443.

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

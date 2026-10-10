Generated from https://www.evtivity.com/docs/configuration/ocpp-settings. Do not edit.

# OCPP Settings

OCPP protocol configuration, security profiles, TLS, and horizontal scaling.

## Protocol Support

EVtivity supports OCPP 1.6 and OCPP 2.1. Both subprotocols are accepted on the same WebSocket server. The server detects the protocol version from the subprotocol header during the WebSocket handshake.

## Connection URL

Charging stations connect using the station identifier as the URL path:

```bash
ws://host:7103/{stationId}
wss://host:8443/{stationId}
```

The `stationId` in the URL must match the station ID configured in the CSMS. Create the station in the CSMS before the charger connects.

## Security Profiles

| Profile | Auth Method | Port | Description |
|---|---|---|---|
| No Auth | None | 7103 | No authentication. Development only. |
| Basic Auth | Basic Auth | 7103 | Username is stationId, password is a hash stored in the station record. |
| TLS + Basic Auth | TLS | 8443 | Server-side TLS. Station validates the server certificate. |
| Mutual TLS | Mutual TLS | 8443 | Client certificate required. Both sides validate certificates. |

TLS + Basic Auth and Mutual TLS share the same TLS port. The server is configured with `requestCert: true` and `rejectUnauthorized: false`, allowing it to accept both TLS + Basic Auth (no client cert) and Mutual TLS (with client cert) connections on a single port.

### TLS Configuration

Set these environment variables to enable the TLS listener:

```bash
OCPP_TLS_PORT=8443
OCPP_TLS_CERT=/path/to/server.crt
OCPP_TLS_KEY=/path/to/server.key
OCPP_TLS_CA=/path/to/ca.crt
```

## Connection Limits

| Variable | Default | Description |
|---|---|---|
| `OCPP_MAX_CONNECTIONS_PER_IP` | `2500` | Max concurrent WebSocket connections from a single IP |
| `OCPP_MAX_MESSAGES_PER_IP_PER_SECOND` | `5000` | Message rate limit per IP |
| `OCPP_AUTH_MAX_CONCURRENT` | Half of `DB_POOL_MAX` | Station connections authenticated at once |
| `OCPP_AUTH_MAX_QUEUED` | `1000` | Station connections waiting for authentication. `0` turns the queue off. |
| `OCPP_AUTH_MAX_WAIT_MS` | `10000` | Longest wait in the queue, in milliseconds |

Connections from one IP that are still authenticating count toward `OCPP_MAX_CONNECTIONS_PER_IP`. Over the limit, the server answers 429 before it looks up the station.

### Connection admission

The OCPP server admits a reconnect wave, such as one after a restart, without starving the stations already connected:

- Station connections wait in a queue for authentication. When the queue is full or the wait is too long, the server answers 503 with a `Retry-After` header, and the station retries after its back-off.
- A successful password check is cached for 15 minutes in each OCPP server process. A password change clears it, and so does a security profile change saved for an offline station.
- Password checks run on a limited number of CPU threads, so DNS, compression, and other work keep a thread.
- When a stored password hash uses older hash parameters, the server admits the station first and updates the hash in the background.

To admit more stations at once, raise `DB_POOL_MAX` rather than `OCPP_AUTH_MAX_CONCURRENT`. The rest of the pool serves the messages of connected stations.

### Failed login throttling

After 5 wrong passwords for one station within 60 seconds, the server refuses that station for 60 seconds with HTTP 429 and a `Retry-After` header, without checking the password. See [Stations](https://www.evtivity.com/docs/csms/stations#failed-login-throttling).

## Configurable Settings

These are configured through the CSMS settings UI, not environment variables:

- **Heartbeat interval**: Default 300 seconds. Sent to stations in BootNotification response.
- **Offline command queue TTL**: Default 24 hours. Commands queued for offline stations expire after this duration.

## Message Pipeline

Inbound OCPP messages pass through a middleware pipeline:

1. **Rate limit** - enforces per-IP message rate
2. **Log** - records the raw message
3. **Validate** - validates against the OCPP JSON schema
4. **Route** - dispatches to the appropriate handler

## Command Flow

OCPP commands from the API to a station follow this path:

```bash
API -> Redis pub/sub (ocpp_commands channel) -> CommandListener -> WebSocket -> Station
```

The API publishes the command to Redis. The OCPP server instance holding the station connection picks it up via the CommandListener and sends it over the WebSocket.

## Event Projections

Inbound OCPP messages trigger domain event projections that update database state: station status, connector status, active sessions, meter values, and running costs.

## Horizontal Scaling

To run multiple OCPP server instances:

1. Set `OCPP_INSTANCE_ID` on each instance. In Kubernetes, use the pod name.
2. The `RedisConnectionRegistry` tracks which station is connected to which instance.
3. Commands are routed through Redis pub/sub. The instance holding the target station connection receives and forwards the command.

Each instance subscribes to both the global `ocpp_commands` channel and its own instance-specific channel.

### Per-process health

Each OCPP server process reports its own health: its connected stations and its ping figures. The dashboard **OCPP and Infrastructure** cards add up all processes, so the connected station count covers every OCPP server. A process that stops drops out of the totals.

The API exports these values to Prometheus on its metrics port:

| Metric | Description |
|---|---|
| `ocpp_connected_stations` | Stations connected to all OCPP servers |
| `ocpp_instances` | OCPP server processes reporting health |
| `ocpp_instance_connected_stations{ocpp_instance}` | Stations connected to one OCPP server process |
| `ocpp_ping_latency_avg_ms`, `ocpp_ping_latency_max_ms` | Average and highest ping latency |
| `ocpp_ping_success_rate` | Share of successful pings |

Every API process exports the same values. Aggregate them across API processes with `max()`, or `max by (ocpp_instance)` for the per-process series, never with `sum()`.

The Grafana "System Metrics" dashboard shows them in its "OCPP Health" row: "Connected Stations", "Avg Ping Latency", "Max Ping Latency", "Ping Success Rate", "Connected Stations Over Time", and "Ping Latency Over Time". "Connected Stations Over Time" has an "All" series plus one series per OCPP server (pod name or ECS task). The dashboard also has the "Overview", "HTTP", "Node.js Runtime", and "Process" rows.

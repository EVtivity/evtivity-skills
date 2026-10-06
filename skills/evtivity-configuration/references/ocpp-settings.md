Generated from https://www.evtivity.com/docs/configuration/ocpp-settings (website commit 257c8b8). Do not edit.

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

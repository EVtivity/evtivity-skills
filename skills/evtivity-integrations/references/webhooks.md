Generated from https://www.evtivity.com/docs/integrations/webhooks. Do not edit.

# Webhooks and Events

Outgoing webhooks, incoming Stripe and Adyen payment webhooks, SSE real-time streams, and internal pub/sub channels.

EVtivity supports outgoing webhooks for OCPP event notifications, incoming webhooks from Stripe and Adyen, Server-Sent Events for real-time updates, and Redis pub/sub for internal event routing.

## Outgoing Webhooks

OCPP event notifications can be sent to external URLs via the webhook channel. Configure this in the Notifications page under the OCPP Events tab.

For each event type, enable the webhook channel and set a recipient URL. When the event fires, EVtivity sends a JSON POST request to the configured URL.

### Payload Format

```json
{
  "eventType": "StatusNotification",
  "timestamp": "2026-04-05T14:30:00Z",
  "stationId": "STATION-001",
  "connectorId": 1,
  "status": "Available"
}
```

The payload includes `eventType`, `timestamp`, `stationId`, and event-specific fields that vary by event type.

## Incoming Webhooks

Payment providers send events to one endpoint per provider. Both answer 200 only after the request is verified, and each event ID is processed once.

| Provider | Endpoint | Verification | Answer |
|---|---|---|---|
| Stripe | `POST /v1/webhooks/payments/stripe` | `Stripe-Signature` header against the platform secret (`stripe.webhookSecretEnc`) and the Connect secret (`stripe.connectWebhookSecretEnc`) | `{"received":true}` |
| Adyen | `POST /v1/webhooks/payments/adyen` | Basic auth (`adyen.webhookUsername`, `adyen.webhookPasswordEnc`) and the HMAC signature of every event (`adyen.hmacKeyEnc`, or `adyen.hmacKeyPreviousEnc` during a rotation) | `[accepted]` |

| Status | Code | Meaning |
|---|---|---|
| 400 | `WEBHOOK_SIGNATURE_MISSING` | No signature (Stripe) |
| 400 | `WEBHOOK_SIGNATURE_INVALID` | Wrong signature, or an Adyen event for another merchant account or environment |
| 401 | `WEBHOOK_SIGNATURE_MISSING`, `WEBHOOK_SIGNATURE_INVALID` | Adyen Basic auth credentials missing or wrong |
| 500 | `WEBHOOK_NOT_CONFIGURED` | The secrets are not stored yet. The provider retries later. |

Settings > Payment can create both webhooks in the provider for you. The URL must be public HTTPS. The old Stripe path `/v1/webhooks/stripe` was removed in v0.1.38. See [Stripe](https://www.evtivity.com/docs/integrations/stripe#2-webhooks) and [Adyen](https://www.evtivity.com/docs/integrations/adyen#5-webhook) for the setup, the events, and local testing.

The [test payment provider](https://www.evtivity.com/docs/integrations/test-payment-provider#events) has no HTTP endpoint. The worker delivers its events into the same pipeline.

## Server-Sent Events (SSE)

EVtivity provides real-time event streams over SSE for both operators and drivers.

### Operator Stream

```bash
GET /v1/events/stream
```

Event types:

| Event | Description |
|---|---|
| `station.statusChanged` | Station or connector status update |
| `session.started` | New charging session began |
| `session.updated` | Session metrics updated (energy, power, SoC) |
| `session.ended` | Charging session completed |
| `supportCase.created` | New support case opened |
| `supportCase.updated` | Support case status changed |
| `supportCase.newMessage` | New message on a support case |
| `certificate.*` | Certificate lifecycle events (created, expiring, revoked) |
| `octt.progress` | OCPP conformance test progress updates |

### Driver Portal Stream

```bash
GET /v1/portal/events
```

| Event | Description |
|---|---|
| `notification.created` | New notification for the driver (triggers bell icon update) |

## Redis Pub/Sub Channels

Internal event routing uses Redis pub/sub. These channels are not exposed externally.

| Channel | Purpose |
|---|---|
| `csms_events` | Feeds the operator SSE stream |
| `portal_events` | Feeds the driver portal SSE stream |
| `ocpp_commands` | Routes OCPP commands from API to the OCPP server |
| `ocpp_command_results` | Returns OCPP command responses from the OCPP server to API |
| `ocpi_push` | Triggers OCPI data push to roaming partners |
| `ocpi_register` | Handles OCPI registration handshakes |
| `ocpi_sync` | Triggers bulk OCPI data synchronization |
| `payment_webhook_deliveries` | Carries signed test payment provider events to the worker |

## OCPI Push Notifications

When EVtivity is connected to roaming partners via OCPI, it pushes real-time updates automatically:

- **Station status changes**: connector availability updates sent to all registered eMSPs
- **Session updates**: active session data pushed during charging
- **CDR generation**: Charge Detail Records sent to the eMSP when a roaming session ends

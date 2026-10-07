Generated from https://www.evtivity.com/docs/guides/audit-logs (website commit ffa3c26). Do not edit.

# Audit Logs

Per-entity history of every operator-initiated change across sites, stations, drivers, fleets, users, support cases, certificates, settings, and more.

## Overview

EVtivity records every operator-initiated mutation across the major management entities into per-entity audit tables. Operators view per-entity history on each detail page (the new History tab) and search across all entities from the global Audit Log page.

## What gets audited

Seventeen entity types have dedicated audit tables. Each row records who acted, what changed (full before/after JSON snapshot), when, and any contextual notes.

| Category | Entities |
| --- | --- |
| Operations | sites, stations, drivers, fleets, vehicles, support cases |
| Configuration | settings, smart-charging templates, config templates, firmware campaigns, station images, local auth list |
| Identity | users, roles, API keys |
| Roaming and certs | OCPI partners, PnC certificates |

Every audit table uses the same shape. Tokens, reservations, and pricing (split into pricing groups, tariffs, holidays, and pricing assignments) follow the same schema and the same endpoint as every other audited entity.

## Where to find it

- **Per-entity History tab.** Open any Site, Station, Driver, Fleet, User, Support Case, Roaming Partner, Smart Charging Template, Config Template, or Firmware Campaign detail page. Click the History tab to see every change ever made to that entity, newest first.
- **Global Audit Log page.** From the operator dashboard nav, choose Audit Log. Filter by entity type, actor, action, entity id, or date range.

Both views require the `audit:read` permission. Admins receive it by default; operators do too.

## Reading an audit row

Each row shows:

- **When.** Timestamp in your local time zone.
- **Action.** The verb that fired (`created`, `updated`, `deleted`, plus entity-specific actions like `pushed`, `assigned`, `password_reset`, `simulator_toggled`).
- **Actor.** Who made the change.
  - `operator` &mdash; a logged-in CSMS user. The `actorUserId` column shows which one.
  - `driver` &mdash; rare, only on entities a driver self-services through the portal.
  - `api_key` &mdash; an automated integration. The `actorApiKeyId` shows which key.
  - `system` &mdash; a worker job (cron, scheduler).
  - `ocpp` &mdash; a station-initiated OCPP message that triggered the change.
- **Notes.** Free-text context like "Pushed to 4 station(s)" or "cascade from pricing_group pgr_x".
- **Before / after.** Full JSON snapshots of the entity before and after the change. For `created` actions `before` is null. For `deleted`, `after` is null.

## Sensitive data

Audit rows never persist password hashes, encrypted secrets, certificate private keys, or API key hashes. The redactor replaces those fields with the literal string `<redacted>` before writing. Setting values whose key ends in `Enc` or `SecretKey` are also redacted.

If you ever query audit JSONB directly in SQL, the redaction is already applied:

```sql
-- Find every site whose carbon region was changed in the last 7 days
SELECT entity_id_snapshot,
       before->>'carbonRegionCode' AS old_region,
       after->>'carbonRegionCode' AS new_region,
       actor_user_id, created_at
FROM site_audit_log
WHERE action = 'updated'
  AND created_at > NOW() - INTERVAL '7 days'
  AND before->>'carbonRegionCode' IS DISTINCT FROM after->>'carbonRegionCode'
ORDER BY created_at DESC;
```

## Retention

Audit rows older than 3 years (1095 days) are pruned automatically by a daily cron job. The retention period is configurable via the `audit.retentionDays` setting. Set the value to 0 to disable automatic pruning entirely.

## API access

Two endpoints under `/v1/audit`. Both require the `audit:read` permission.

- `GET /v1/audit/{entityType}/{entityId}` &mdash; paginated history for one entity.
- `GET /v1/audit` &mdash; cross-entity search with filters: `entityType`, `entityId`, `action`, `actor`, `actorUserId`, `actorDriverId`, `from`, `to`.

See the [API reference](https://www.evtivity.com/api-reference/audit) for the full schemas.

## When something looks missing

A few changes intentionally do NOT appear in the audit log:

- Driver self-service actions through the portal (the audit feature scopes to operator-initiated mutations).
- Internal OCPP event projections that don't change operator-managed fields (status updates from heartbeats, meter values, etc).
- Read operations.

If an operator action is missing from the audit log when you expect it, file a bug with the route name and timestamp.

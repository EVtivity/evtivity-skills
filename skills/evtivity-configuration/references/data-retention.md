Generated from https://www.evtivity.com/docs/configuration/data-retention. Do not edit.

# Data Retention

How long EVtivity keeps logs, meter values, audit history and AI data, where you change it, and how to plan database storage.

## Overview

EVtivity deletes old rows from its high-volume tables on a schedule. Each group of data has a retention setting in days. This page lists every retention setting, its default, the data it covers, and where you change it.

> **Warning:**
>
> **Chaos mode and large networks need large storage**
>
> Every OCPP message a station sends or receives is a row in `ocpp_message_logs`, heartbeats included. Every meter reading is a row in `meter_values`. Both tables grow with the number of connected stations, even while no one charges. Chaos mode in the [Charging Station Simulator](https://www.evtivity.com/docs/simulator/overview) also starts charging sessions on the simulated stations, which adds meter values.
>
> On a test network of about 2,000 simulated stations that stayed connected, the database reached 90 GB. `ocpp_message_logs` held about 100 million rows (57 GB) at its default retention of 30 days. `meter_values` held about 61 million rows (32 GB).
>
> Plan the database disk for your station count before you turn on chaos mode or connect a large network. Lower `logs.ocppMessage.retentionDays` and `logs.meterValues.retentionDays` to keep these tables smaller.

## Log Retention Settings

The daily `log-retention-prune` job deletes rows older than these settings. A value of 0 keeps the rows forever.

| Setting | Default (days) | Data deleted |
|---|---|---|
| `logs.ocppMessage.retentionDays` | 30 | OCPP message log (`ocpp_message_logs`): every OCPP message in both directions |
| `logs.meterValues.retentionDays` | 90 | Meter readings (`meter_values`) |
| `logs.domainEvents.retentionDays` | 30 | Domain events (`domain_events`) |
| `logs.access.retentionDays` | 30 | Access logs (`access_logs`): the CSMS, Portal and API tabs of [Access Logs](https://www.evtivity.com/docs/csms/access-logs) |
| `logs.workerJob.retentionDays` | 30 | Worker job logs (`worker_job_logs`): the Workers tab of Access Logs. Rows count from the job end, so a running job is never deleted. |
| `logs.portStatus.retentionDays` | 30 | Connector status history (`port_status_log`) |
| `logs.connection.retentionDays` | 90 | Station connection log (`connection_logs`) |
| `logs.notifications.retentionDays` | 90 | Notification history (`notifications`) |
| `logs.loadAllocation.retentionDays` | 90 | Allocations list of [Load Management](https://www.evtivity.com/docs/csms/load-management) (`load_allocation_log`) |
| `logs.loginAudit.retentionDays` | 90 | Sign-in rows (`login_succeeded`, `login_failed`) of the user and driver audit logs |
| `logs.securityEvents.retentionDays` | 365 | Station security events (`security_events`) |
| `sim.sessions.retentionDays` | 90 | SIM sessions, SIM alerts and fetched periods (`sim_sessions`, `sim_alerts`, `sim_fetch_coverage`). Range 7 to 730. |

## Other Retention Settings

| Setting | Default (days) | Data deleted | Job |
|---|---|---|---|
| `audit.retentionDays` | 1095 | Entity history of the [Audit Logs](https://www.evtivity.com/docs/guides/audit-logs) (History tabs and the Audit page) and OCPP authorization attempts (`authorize_attempts`) | `audit-retention-prune` |
| `refreshTokens.retentionDays` | 30 | Revoked and expired sign-in refresh tokens (`refresh_tokens`) | `refresh-token-prune` |
| `ai.conversationRetentionDays` | 30 | [AI Assistant](https://www.evtivity.com/docs/csms/ai-assistant) conversations without activity for this period, with their attachments, and MCP call logs. Range 1 to 3,650. | `ai-retention-prune` |
| `aiInsights.retentionDays` | 90 | [Automatic insights](https://www.evtivity.com/docs/csms/ai-insights) and background AI worker runs. Range 1 to 3,650. | `ai-retention-prune` |

A value of 0 for `audit.retentionDays` or `refreshTokens.retentionDays` keeps the rows forever.

## Where to Change Them

Three settings have a field in the CSMS:

| Setting | Field |
|---|---|
| `ai.conversationRetentionDays` | **Settings > AI > Usage and Limits > Keep conversations for (days)** |
| `aiInsights.retentionDays` | **Settings > AI > Automatic Insights > Keep insights (days)** |
| `sim.sessions.retentionDays` | **Settings > Integrations & Features > SIM Providers > Keep Sessions and Alerts (Days)** |

The `logs.*` settings, `audit.retentionDays` and `refreshTokens.retentionDays` have no field in the CSMS. Set them in your deployment:

- **Helm chart:** `appSettings.logs.<name>RetentionDays` (for example `appSettings.logs.ocppMessageRetentionDays`), `appSettings.audit.retentionDays` and `appSettings.refreshTokens.retentionDays`. The chart writes these values on every install and upgrade, so a value set another way returns to the chart value at the next upgrade. See [Helm Chart](https://www.evtivity.com/docs/deployment/helm-chart).
- **AWS CDK:** add the key to `appSettings` in the environment config, for example `appSettings['logs.ocppMessage.retentionDays']: 14`. Each deploy writes it. See [AWS](https://www.evtivity.com/docs/deployment/aws).
- **Docker Compose and source installs:** set the key in `packages/database/seed.config.json` and run `npm run db:seed -- --apply-config`.
- **API:** `PUT /v1/settings/<key>` with a body such as `{ "value": 14 }`. It needs the `settings.system:write` permission. Send a whole number: the prune job uses the default for any other value.

## Prune Jobs

| Job | Schedule (UTC) | Settings |
|---|---|---|
| `audit-retention-prune` | Daily at 03:00 | `audit.retentionDays` |
| `log-retention-prune` | Daily at 03:30 | Every `logs.*` setting and `sim.sessions.retentionDays` |
| `refresh-token-prune` | Daily at 04:45 | `refreshTokens.retentionDays` |
| `ai-retention-prune` | Every hour at minute 40 | `ai.conversationRetentionDays`, `aiInsights.retentionDays` |

Each job reads its settings at every run, so a change applies at the next run. The log and audit jobs delete in batches of 1,000 rows. Each batch is its own statement, so a large prune does not lock a table for the whole run. When one table fails, the job logs a warning and goes on with the next table.

PostgreSQL reuses the space of deleted rows for new rows. The database files do not shrink after a prune. The first run after you lower a retention can delete many rows.

## Sessions After Their Meter Values Are Deleted

Each charging session keeps its energy totals, its peak power and its last state of charge on the session itself. Deleting meter values does not change them. Reports such as the [NEVI report](https://www.evtivity.com/docs/csms/nevi-compliance) keep a session's peak power after its meter values are deleted.

## Checking Table Sizes

Run this query on the database to list the largest tables:

```sql
SELECT relname AS table_name,
       pg_size_pretty(pg_total_relation_size(relid)) AS total_size,
       n_live_tup AS approximate_rows
FROM pg_stat_user_tables
ORDER BY pg_total_relation_size(relid) DESC
LIMIT 10;
```

When `ocpp_message_logs` or `meter_values` fill the disk, lower their retention, run fewer simulated stations, or add disk. Every enabled simulated station stays connected and sends heartbeats, also in standby mode. `CSS_STATION_LIMIT` limits only the stations chaos mode drives. To stop a simulated station, clear **Simulator station** on its station (see [Managing Simulated Stations](https://www.evtivity.com/docs/simulator/stations)).

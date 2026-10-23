Generated from https://www.evtivity.com/docs/configuration/data-retention. Do not edit.

# Data Retention

How long EVtivity keeps logs, meter values, audit history and AI data, where you change it, and how to plan database storage.

## Overview

EVtivity deletes old rows from its high-volume tables on a schedule. Each group of data has a retention setting in days. You change every one of them in **Settings > Data Retention** in the CSMS. This page lists every retention setting, its default and range, and the data it covers.

> **Warning:**
>
> **Chaos mode and large networks need large storage**
>
> Every OCPP message a station sends or receives is a row in `ocpp_message_logs`, heartbeats included. Every meter reading is a row in `meter_values`. Both tables grow with the number of connected stations, even while no one charges. Chaos mode in the [Charging Station Simulator](https://www.evtivity.com/docs/simulator/overview) also starts charging sessions on the simulated stations, which adds meter values.
>
> On a test network of about 2,000 simulated stations that stayed connected, the database reached 90 GB. `ocpp_message_logs` held about 100 million rows (57 GB) at its default retention of 30 days. `meter_values` held about 61 million rows (32 GB).
>
> Plan the database disk for your station count before you turn on chaos mode or connect a large network. Lower **OCPP Messages** and **Meter Values** in **Settings > Data Retention** (`logs.ocppMessage.retentionDays` and `logs.meterValues.retentionDays`) to keep these tables smaller.

## Station Data Use

The OCPP messages that fill `ocpp_message_logs` and `meter_values` are the same messages that use a station's data. Their number depends on the station's data plan. Estimated data use of one station in a 30-day month (byte model, not a measurement: 1 EVSE on OCPP 1.6 and 2 EVSEs on OCPP 2.0.1 and 2.1, AC charging with 4 one-hour sessions a day, TLS, firmware not included):

| Plan | OCPP | Idle uplink | Idle downlink | Charging adds | Total per month | Total with compression |
|---|---|---|---|---|---|---|
| Wi-Fi or wired | 1.6 | 3.8 MB | 3.1 MB | 7.0 MB | 13.9 MB | 10.4 MB |
| Wi-Fi or wired | 2.0.1 | 5.0 MB | 3.5 MB | 9.0 MB | 17.4 MB | 11.1 MB |
| Wi-Fi or wired | 2.1 | 5.0 MB | 3.5 MB | 9.0 MB | 17.4 MB | 11.1 MB |
| Cellular | 1.6 | 1.6 MB | 0.9 MB | 1.3 MB | 3.8 MB | 3.4 MB |
| Cellular | 2.0.1 | 1.6 MB | 0.9 MB | 1.7 MB | 4.2 MB | 3.3 MB |
| Cellular | 2.1 | 1.6 MB | 0.9 MB | 1.7 MB | 4.2 MB | 3.3 MB |

See [Data Usage Defaults](https://www.evtivity.com/docs/configuration/data-usage-defaults) for the settings and message sizes behind these numbers, and [Cellular Stations](https://www.evtivity.com/docs/configuration/cellular-stations) for stations on cellular data plans.

## Log Retention Settings

The daily `log-retention-prune` job deletes rows older than these settings. Each `logs.*` value is a whole number from 0 to 3,650. A value of 0 keeps the rows forever. `logs.loginAudit.retentionDays` and `logs.securityEvents.retentionDays` take 0 or 30 to 3,650.

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
| `logs.loginAudit.retentionDays` | 90 | Sign-in rows (`login_succeeded`, `login_failed`) of the user and driver audit logs. Range 0 or 30 to 3,650. |
| `logs.securityEvents.retentionDays` | 365 | Station security events (`security_events`). Range 0 or 30 to 3,650. |
| `sim.sessions.retentionDays` | 90 | SIM sessions, SIM alerts and fetched periods (`sim_sessions`, `sim_alerts`, `sim_fetch_coverage`). Range 7 to 730. |

## Other Retention Settings

| Setting | Default (days) | Data deleted | Job |
|---|---|---|---|
| `audit.retentionDays` | 1095 | Entity history of the [Audit Logs](https://www.evtivity.com/docs/guides/audit-logs) (History tabs and the Audit page) and OCPP authorization attempts (`authorize_attempts`). Range 0 or 30 to 3,650. | `audit-retention-prune` |
| `refreshTokens.retentionDays` | 30 | Revoked and expired sign-in refresh tokens (`refresh_tokens`) | `refresh-token-prune` |
| `ai.conversationRetentionDays` | 30 | [AI Assistant](https://www.evtivity.com/docs/csms/ai-assistant) conversations without activity for this period, with their attachments, and MCP call logs. Range 1 to 3,650. | `ai-retention-prune` |
| `aiInsights.retentionDays` | 90 | [Automatic insights](https://www.evtivity.com/docs/csms/ai-insights) and background AI worker runs. Range 1 to 3,650. | `ai-retention-prune` |

`refreshTokens.retentionDays` takes a whole number from 0 to 3,650, `audit.retentionDays` 0 or 30 to 3,650. A value of 0 keeps the rows forever.

## Where to Change Them

Open **Settings > Data Retention** in the CSMS. The tab groups the settings into **Operational Logs**, **Security and Audit**, **Sign-In Sessions and Tokens**, **AI** and **SIM Data**, and shows the range and the default of each one. Click **Save** to store the changed values. The tab needs access to every site. Without the `settings.system:write` permission the fields are read-only. See [Settings](https://www.evtivity.com/docs/csms/settings#data-retention).

The API offers the same settings at `GET` and `PUT /v1/settings/data-retention`, with a body such as `{ "logs.ocppMessage.retentionDays": 14 }`. Each value is a whole number of days in its range. See the [API reference](https://www.evtivity.com/api-reference).

The Helm chart and the AWS CDK config do not set data retention. Retention of AWS resources stays in the CDK config: CloudWatch log groups (`logs.retentionDays`), Aurora backups (`aurora.backupRetentionDays`) and Valkey snapshots (`valkey.snapshotRetentionDays`). See [AWS](https://www.evtivity.com/docs/deployment/aws).

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

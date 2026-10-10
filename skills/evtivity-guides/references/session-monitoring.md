Generated from https://www.evtivity.com/docs/guides/session-monitoring. Do not edit.

# Session Monitoring

Session lifecycle, idle detection, cost calculation, and real-time dashboard in EVtivity CSMS.

## Session Statuses

| Status | Description |
|---|---|
| active | Charging in progress |
| completed | Charging finished normally |
| failed | Session ended with an error |
| pending | Session authorized but not yet started |

## Session Lifecycle

Sessions follow the OCPP `TransactionEvent` flow:

1. **Started** - The station sends a `TransactionEvent` with `eventType: Started`. The CSMS creates the session record.
2. **Updated** - Periodic `TransactionEvent` messages with `eventType: Updated` deliver meter values (energy, power, SoC). The CSMS updates the session in real time.
3. **Ended** - A final `TransactionEvent` with `eventType: Ended` closes the session. The CSMS calculates the final cost and marks the session complete.

## Idle Detection

When the vehicle pauses charging itself but remains plugged in, the session enters an idle state. Only an EV-side pause counts: a pause by the station (`SuspendedEVSE`), a fault, or a plugged-in vehicle that is not charging (`Idle`, `EVConnected`, 1.6 `Finishing`) is not idle time and bills no idle fee. EVtivity uses a priority-based detection strategy:

1. **chargingState** (OCPP 2.1) - The `TransactionEvent` includes a `chargingState` field. If it reports `SuspendedEV`, the session is idle. Any other state ends the idle period.
2. **Power.Active.Import** - If power drops to zero, the session is idle, unless the connector is faulted or paused by the station.
3. **StatusNotification** (OCPP 1.6) - A `SuspendedEV` status indicates idle. `SuspendedEVSE`, `Faulted`, `Finishing` and `Charging` end the idle period.
4. **Flat energy** - If energy delivered has not increased across multiple meter updates, the session is idle.

The idle grace period is configurable in settings. The first idle minutes of the session are free, and idle fees apply to the idle time after them.

## Cost Calculation

Each session is billed against a tariff with these components:

| Component | Description |
|---|---|
| `sessionFee` | Flat fee charged once per session |
| `pricePerKwh` | Energy cost per kilowatt-hour |
| `pricePerMinute` | Time cost per minute of the session, charging or idle |
| `idleFeePricePerMinute` | Fee per minute while idle (after grace period) |
| `taxRate` | Tax rate as a decimal fraction (`0.19` for 19%). Tariff prices exclude or include tax, as the company tax calculation method sets. |

### Split Billing

Split billing is on by default. When a tariff changes mid-session (e.g., time-of-use pricing), the CSMS tracks costs per segment. A cron job runs every minute to check for tariff transitions and close the current billing segment.

Each segment is taxed at its own tariff tax rate. The driver's invoice shows the net amount and tax per rate, and the total matches the amount charged.

## Dashboard

The session dashboard operates in three modes:

- **Live** - Real-time view of active sessions with current power, energy, and duration.
- **Historical** - Completed sessions with filters for date range, station, status, and driver.
- **Trend** - Aggregated metrics over time with charts for energy delivered, revenue, and session count.

Day-over-day indicators compare current metrics to the previous day using daily snapshots.

## Real-Time Updates

The CSMS streams session updates to the frontend via Server-Sent Events (SSE). When a `TransactionEvent` arrives from a station, the update propagates to every connected browser session viewing that station or session. No polling required.

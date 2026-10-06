Generated from https://www.evtivity.com/docs/simulator/overview (website commit 0f3462e). Do not edit.

# Simulator Overview

How the EVtivity charging station simulator works, its architecture, and configuration options.

## Overview

The EVtivity Charging Station Simulator (CSS) is an internal tool that simulates OCPP 1.6 and 2.1 charging stations. It connects to the CSMS over WebSocket and behaves like a real station, sending boot notifications, status updates, meter values, and transaction events.

The simulator is useful for:

- Testing the CSMS without physical hardware
- Demonstrating the system to stakeholders
- Running automated conformance tests
- Load testing with multiple simulated stations

## Architecture

The simulator has four layers:

1. **OcppClient** - Low-level WebSocket connection to the OCPP server. Handles connect/disconnect, message send/receive, and OCPP subprotocol negotiation. Reconnects indefinitely with exponential backoff capped at 5 minutes, matching real charging station behavior.

2. **StationSimulator** - Simulates a single station. Manages the boot sequence (BootNotification, StatusNotification), heartbeat timer, transaction lifecycle (authorize, start, meter values, stop), internal state (configuration, charging profiles, local auth list, certificates, display messages, reservations), and responses to 51 CSMS-initiated commands.

3. **SimulatorManager** - Manages the fleet of StationSimulator instances. Subscribes to Redis commands from the API. Creates, destroys, and dispatches actions to individual simulators.

4. **ChaosOrchestrator** - Drives autonomous behavior. Reads stations from the CSMS via the API, creates corresponding CSS station records, and triggers random actions at configurable intervals. Only active in `chaos` mode.

## Communication Flow

The simulator does not write to the database directly. All communication flows through Redis pub/sub:

```bash
API -> Redis css_commands -> SimulatorManager -> StationSimulator -> OCPP WebSocket
```

The CSMS API exposes endpoints for managing simulated stations and triggering actions. Commands flow through Redis to the SimulatorManager, which dispatches them to the correct StationSimulator.

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `CSS_MODE` | `standby` | Operating mode: `standby` or `chaos` |
| `CSS_ACTION_INTERVAL_MS` | `1000` | Interval between chaos mode actions (ms) |
| `CSS_STATION_LIMIT` | `0` | Max stations in chaos mode (0 = all) |
| `OCPP_SERVER_URL` | `ws://localhost:7103` | Plain WebSocket OCPP endpoint |
| `OCPP_TLS_SERVER_URL` | `wss://localhost:8443` | TLS WebSocket OCPP endpoint |
| `DATABASE_URL` | (PostgreSQL connection) | Database for reading CSS station config |
| `REDIS_URL` | `redis://localhost:6379` | Redis for pub/sub command channel |
| `CSS_API_URL` | `http://localhost:7102` | API server URL (chaos mode only) |
| `CSS_API_TOKEN` | (empty) | API auth token (chaos mode only) |
| `CSS_HEALTH_PORT` | `8082` | Health endpoint port for probes |
| `CSS_STATION_PASSWORD` | `password` | Default password for Basic Auth and TLS + Basic Auth stations |

## Operating Modes

### Standby Mode

Stations connect to the OCPP server and idle. They respond to CSMS commands and station actions triggered via the API. No autonomous behavior.

Use standby mode for manual testing and development.

### Chaos Mode

The ChaosOrchestrator reads real stations from the CSMS and creates corresponding simulator records, then runs autonomously: every `CSS_ACTION_INTERVAL_MS` (default 1 s) it picks **one** random action that's valid for the current station and connector state. There is no scripted sequence — no fixed plug-in → start → stop → unplug recipe. Realistic traffic emerges over many ticks because the state-aware filter keeps each pick consistent with the wire.

Action pool (defined in `packages/css/src/chaos-orchestrator.ts`):

| Action | When the filter allows it |
|---|---|
| `plugIn` | State=available, no cable |
| `authorize` | State=available, no cable |
| `startCharging` | State=available with a cable plugged in (connector in Preparing / Occupied / EVConnected / SuspendedEV / SuspendedEVSE) |
| `stopCharging` | State=charging |
| `unplug` | State=charging, connector plugged-but-not-charging, or Finishing |
| `injectFault` | State=available, charging, or Finishing |
| `clearFault` | State=faulted |
| `goOffline` | Most states |
| `comeOnline` | State=disconnected, unavailable |
| `sendStatusNotification` | State=available, unavailable |
| `sendHeartbeat`, `sendMeterValues`, `sendNotifyEvent`, `sendDataTransfer` | All states (notifications, do not mutate connector state) |

When a connector is in `Finishing`, the filter restricts the chaos pool to `{unplug, goOffline, injectFault}` — the only spec-plausible actions on a post-stop cable-still-connected connector. This prevents a brief `charging → preparing → finishing` UI flash that would otherwise happen if chaos picked `authorize` while the post-stop StatusNotification was still in flight.

A typical end-to-end session emerges as: an early tick picks `plugIn` → some later tick picks `authorize` → another tick picks `startCharging` → much later a tick picks `stopCharging` → eventually a tick picks `unplug`. The intervals between these are random — driven by `CSS_ACTION_INTERVAL_MS` and the state filter, not by a coordinated script.

Use chaos mode for load testing and demos.

## Meter Value Generation

Once a transaction is active, the simulator emits realistic meter values on a periodic timer. The same formula runs in both standby and chaos modes — chaos only differs by triggering transactions automatically. The values are deterministic physics, not random walks; the only stochastic element is a small per-tick jitter on the power level.

### Tick interval

The meter loop fires every `MeterValueSampleInterval` (1.6) or `SampledDataCtrlr.TxUpdatedInterval` (2.1) seconds, default **10 s**. Each tick advances internal simulation state and emits `MeterValues` (1.6) or `TransactionEvent(Updated, triggerReason=MeterValuePeriodic)` (2.1) carrying the configured measurands.

### Power formula

**AC connectors** (Type1, Type2):

```
power = maxPowerW × 0.95 × (0.90 + random × 0.10)
```

Power hovers around 85.5–95% of the connector's `maxPowerW`. The ±5% randomness models normal grid jitter, not energy uncertainty.

**DC connectors** (CCS1, CCS2, CHAdeMO):

```
if soc < 80:
  fraction = 0.95
else:
  fraction = 0.95 - ((soc - 80) / 20) × 0.75   // tapers 0.95 -> 0.20

power = maxPowerW × fraction × (0.95 + random × 0.10)
```

Constant ~95% up to 80% SoC, then linear taper from 95% down to 20% as SoC climbs from 80% to 100%. This mimics how real batteries reduce DC fast-charge power at high SoC to protect cell health.

**Idle** (no current flow during a transaction): `power = 0`. Energy does not accumulate that tick.

### Power capping

If a charging profile (`SetChargingProfile`) or a site-level load-management limit is in effect, the computed power is clipped:

```
power = min(power, powerLimitW)
```

This is how the simulator participates in smart charging and site-level load management.

### Energy integration

Energy is the integral of power over time. With a 10-second tick:

```
meterWh += power × 10 / 3600          // Wh = W × hours
```

A 7 kW charger adds ~19.4 Wh per tick. The energy register is cumulative across the session and reported as `Energy.Active.Import.Register` on each meter value message.

### Other simulated state

The same generator computes voltage, current, SoC, temperature, and frequency on each tick using the formulas below. None of these affect the energy register directly; they exist so the meter value report carries a realistic full set of measurands.

**Voltage** (V):

```
// AC: nominal ±2 V grid jitter
voltage = profile.voltage - 2 + random × 4

// DC CCS1 / CCS2: 350-500 V random per tick
voltage = 350 + random × 150

// DC CHAdeMO: 300-450 V random per tick
voltage = 300 + random × 150
```

The DC range models the EV-controlled CCDS pack voltage as it shifts during the charge.

**Current** (A): derived from power, not random.

```
// AC (split across phases)
currentA = power / voltage / phases

// DC (single phase)
currentA = power / voltage
```

**SoC** (%): starts at a random 15-30% on session start, ramps up each tick, caps at 100%.

```
// On session start
soc = 15 + random × 15

// AC tick
soc = min(100, soc + (power > 0 ? 0.3 : 0))     // +0.3%/tick while drawing power

// DC tick
soc = min(100, soc + (power / maxPowerW) × 0.8) // up to +0.8%/tick at max power
```

DC ramps faster because real DC fast-chargers deliver more energy per minute. The ramp scales with power, so it slows during the high-SoC taper.

**Temperature** (°C): warms while charging, cools while idle. Bounded 25–45 °C.

```
// Charging tick
temperature = min(45, 25 + tickCount × 0.5)     // climbs 0.5 °C/tick

// Idle tick
temperature = max(25, temperature - 0.2)        // cools 0.2 °C/tick
```

Reported as `Temperature` (1.6 only — not in the OCPP 2.1 measurand enum).

**Frequency** (Hz): random grid frequency around 50 Hz.

```
frequency = 49.9 + random × 0.2                 // 49.9-50.1 Hz
```

Hz is not in the OCPP 1.6 `unit` enum, so the unit is omitted on 1.6 messages even when `Frequency` is requested as a measurand.

**Reactive power** (var): a fixed fraction of active power.

```
reactiveImport = floor(power × 0.1)             // 10% of active power
```

Only emitted if `Power.Reactive.Import` is in the configured measurand list.

**Energy.Active.Export.Register / Power.Active.Export / Current.Export**: always `0`. The simulator does not currently model V2G export. Discharging events are reported via OCPP 2.1 `chargingState=Discharging` for status display only.

**Power.Offered**: always reported as `maxPowerW` (the connector's nameplate ceiling), regardless of any active charging profile cap. This matches real station behavior — `Power.Offered` is what the connector *can* deliver, not what it is currently delivering.

### Standby vs chaos behavior

| Mode | When meter values flow | What starts a transaction |
|---|---|---|
| `standby` | While a transaction is active | Operator clicks Start in the dashboard or portal, or the CSMS sends RemoteStart |
| `chaos` | While a transaction is active | Operator/CSMS commands, plus the ChaosOrchestrator's random action picks (see [Chaos Mode](#chaos-mode) above for the full action list and state filter) |

In both modes, once a transaction is running, the same loop produces the same physics-shaped curve. Chaos mode does not add randomness to the meter values themselves — only to when sessions start and stop.

## Mutual TLS (mTLS) Support

The simulator supports Mutual TLS for stations that authenticate with client certificates instead of passwords.

Mutual TLS stations require three certificate files:

- **CA certificate** (`ca.pem`) - The certificate authority that signed the server cert
- **Client certificate** (`client.pem`) - The station's identity certificate
- **Client key** (`client-key.pem`) - The private key for the client certificate

The simulator loads test certificates from `packages/css/test-certs/` for Mutual TLS stations. When connecting, it passes these as TLS options to the WebSocket connection and skips the Basic Auth header.

Mutual TLS stations connect to the TLS endpoint (`OCPP_TLS_SERVER_URL`) while No Auth through TLS + Basic Auth stations connect to the plain endpoint (`OCPP_SERVER_URL`).

## Password and Security Profile Changes

Simulated stations accept password and security profile changes from the CSMS the way real stations do. A new password (`SetVariables(SecurityCtrlr.BasicAuthPassword)` for OCPP 2.1, `ChangeConfiguration(AuthorizationKey)` for OCPP 1.6) is used on the next connection. A security profile upgrade (a new network connection profile for OCPP 2.1, `SecurityProfile` for OCPP 1.6) takes effect at the reset that follows. The station reconnects with the new profile and falls back to the previous connection after three failed attempts. The simulator saves the new URL and password, so a restart keeps them.

## Health Endpoint

An HTTP server on the health port (default 8082) responds with `{"status":"ok"}`. This is used for Kubernetes liveness and readiness probes and Docker Compose health checks.

## Running the Simulator

Start the simulator in development mode:

```bash
npm run dev:css
```

The simulator reads station configuration from the database and connects to the OCPP server based on the configured mode.

## Reconnection Behavior

Simulated stations reconnect indefinitely when the OCPP server goes down, matching real charging station behavior. The backoff schedule:

| Attempt | Delay |
|---|---|
| 1 | 2s |
| 2 | 4s |
| 3 | 8s |
| 4 | 16s |
| 5 | 32s |
| 6 | 64s |
| 7 | 128s |
| 8 | 256s |
| 9+ | 300s (5 min cap) |

Each delay includes 20% random jitter to avoid thundering herd when all stations reconnect at once. The backoff resets to 2s after a successful connection. Stations only stop reconnecting when explicitly destroyed (container shutdown).

## Notes

- The simulator supports all 51 CSMS-initiated OCPP commands for both protocol versions.
- Meter values are computed by the MeterValueGenerator with support for 12 measurands.
- Clock-aligned meter values use a global scheduler with random jitter to avoid thundering herd effects.
- In Kubernetes deployments, the simulator runs as a separate pod managed by the Helm chart.

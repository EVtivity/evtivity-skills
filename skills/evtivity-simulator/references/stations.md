Generated from https://www.evtivity.com/docs/simulator/stations (website commit 257c8b8). Do not edit.

# Managing Simulated Stations

Create, enable, and disable simulated charging stations through the CSMS dashboard.

## Overview

Simulated stations are paired with a real `charging_stations` record in the CSMS database. The pair always exists together: the `charging_stations` row carries identity (vendor, model, OCPP version, security profile), and the `css_stations` row carries simulator runtime config (target URL, credentials, enabled flag).

## How Simulated Stations Work

1. Every simulated station has a row in `charging_stations` with `is_simulator = true` and a paired row in `css_stations` keyed by station ID.
2. The two rows are linked by a foreign key with cascade delete. Removing the `charging_stations` row removes its `css_stations` row automatically.
3. When the `css_stations` row has `enabled = true`, the SimulatorManager creates a StationSimulator instance that connects to the OCPP server.
4. The station sends a BootNotification, receives its configuration, and begins sending heartbeats and status notifications.
5. The CSMS treats the simulated station exactly like a physical station.

## Create a Simulated Station

There are two paths. Both result in the same paired-row state.

### Toggle an existing station

In the CSMS dashboard, open any station detail page, click **Edit** on the **Details** tab, check **Simulator station**, and click **Save**. The PATCH on `/v1/stations/:id` creates a `css_stations` row (or re-enables an existing one) with sensible defaults pulled from the `charging_stations` row. The simulator connects within five seconds.

Unchecking **Simulator station** sets `enabled = false` on the `css_stations` row. The SimulatorManager reaps the running simulator on its next sync cycle. The `css_stations` row is preserved so a re-enable keeps the previous targetUrl, password, and certs.

### Create directly via the simulator API

Use `POST /v1/css/stations` to create both rows in a single request. If the station ID is new, the endpoint inserts a `charging_stations` row with `is_simulator = true`. If a non-simulator row already exists, the endpoint flips the flag instead. The body accepts:

- **stationId** - The OCPP station ID (required)
- **ocppProtocol** - `ocpp1.6` or `ocpp2.1`
- **securityProfile** - 0, 1, 2, or 3
- **targetUrl** - WebSocket endpoint the simulator connects to
- **password** - For Basic Auth and TLS + Basic Auth stations
- **clientCert / clientKey / caCert** - For Mutual TLS stations
- **model**, **serialNumber**, **firmwareVersion** - Identity fields stored on `charging_stations`
- **evses** - Array of EVSE definitions for `css_evses`

All multi-table writes are wrapped in a transaction so partial state cannot persist on failure.

## Enable a Station

When a CSS station is enabled (toggle on, or `enabled = true` on the row):

1. The SimulatorManager's sync cycle (every 5 seconds) sees the new enabled row.
2. It creates a StationSimulator instance and registers it with the clock-aligned scheduler.
3. The simulator opens a WebSocket connection to the OCPP server at the row's targetUrl.
4. The station sends BootNotification and waits for the CSMS to accept it.
5. After acceptance, StatusNotification messages are sent for all connectors.
6. The heartbeat timer starts at the interval specified by the CSMS.

The Redis `css_commands` channel is used for action commands (plug in, start charging, inject fault) on already-running simulators, not for connect/disconnect.

## Disable a Station

When a CSS station is disabled (toggle off, or `enabled = false` on the row):

1. The SimulatorManager's sync cycle (every 5 seconds) detects the row is no longer in the active set.
2. The manager calls `stop()` on the StationSimulator, which closes the WebSocket gracefully.
3. The CSMS detects the disconnection and marks the station as offline.
4. The `css_stations` row is preserved with `enabled = false`. Re-enabling reuses the existing config.

## Delete a Simulated Station

Deleting the `charging_stations` row cascades to remove the paired `css_stations` row, all `css_evses`, `css_config_variables`, and any related simulator state. Use the dashboard's Delete Station action or DELETE the charging_stations row directly. There is no separate delete for the simulator side.

## Real Stations on a Simulator Row

A real charging station can connect with the station ID of a station marked as a simulator, for example after you replace a simulated station with hardware. Both pass the same credentials, so the real station and the simulator would keep taking the connection from each other. To tell them apart, the simulator sends the header `x-evtivity-simulator: css` on every connection. The header is not a credential: a station that sends it only keeps the simulator flag.

On every successful connection to a station marked as a simulator, the OCPP server decides:

| Simulator header | Security profile | Paired simulator | Result |
|------------------|------------------|------------------|--------|
| Yes | Any | Any | Simulator. The first connection with the header records that the simulator owns this station ID. |
| No | 1, 2, or 3 | None, disabled, or already seen with the header | Automatic fix |
| No | 1, 2, or 3 | Enabled and never seen with the header | Conflict |
| No | 0 | Any | Conflict |

The OCPP server accepts the connection in every case. The check never changes the authentication result.

### Automatic Fix

A station that authenticated with a password or a certificate, sent no header, and could not have come from a current simulator is a real station. The CSMS then:

1. Clears the simulator flag on the station.
2. Disables the paired simulator. The SimulatorManager stops it at its next sync cycle.
3. Writes the event `simulator_self_healed` to the connection log on the station **Security** tab, and a `simulator_toggled` audit row (actor `ocpp`) to the **History** tab.

### Conflict

The CSMS does not clear the flag on its own in two cases:

- Security profile 0 (`unauthenticated_profile`): the connection has no credentials, so any device can claim the station ID.
- An enabled simulator that never connected with the header (`simulator_not_verified`): a simulator from an older release sends no header. During an upgrade it can reconnect before it is updated, and an automatic fix would disable the whole simulated fleet.

The CSMS records the time of the conflict and writes the event `simulator_conflict` with the reason to the connection log. The simulator flag stays. When the simulator next connects with the header, the CSMS clears a conflict recorded before that.

### Confirm a Real Station

A station with a conflict shows a warning on its detail page: "On *time* a connection that did not come from the simulator reached this station." If a real charging station uses this station ID:

1. Click **This is a real station**.
2. Confirm in the **Confirm a real station** dialog.

The CSMS clears the simulator flag and the conflict, disables the paired simulator, and writes a `simulator_toggled` audit row with your user. The button needs the `stations:write` permission. To use the simulator again later, edit the station and turn the simulator back on. Changing the simulator setting on the station also clears a conflict.

## OCPP 1.6 and 2.1 Support

The simulator supports both OCPP protocol versions. The version is determined by the `ocppProtocol` field on the charging station record.

| Feature | OCPP 1.6 | OCPP 2.1 |
|---------|----------|----------|
| BootNotification | Supported | Supported |
| StatusNotification | 9 statuses | 5 statuses |
| Transactions | StartTransaction / StopTransaction | TransactionEvent |
| Configuration | ChangeConfiguration / GetConfiguration | SetVariables / GetVariables |
| Meter values | MeterValues action | TransactionEvent Updated |
| Heartbeat | Supported | Supported |
| Reset | Hard / Soft | Immediate / OnIdle |

## Internal State

Each simulated station maintains internal state that mirrors what a real station would track. Identity fields (vendor, model, OCPP protocol, security profile, serial number, firmware version) live on the paired `charging_stations` row. Simulator runtime tables hold the rest:

- **Configuration variables** - Stored in `css_config_variables`, updated via SetVariables/ChangeConfiguration
- **Charging profiles** - Stored in `css_charging_profiles`, set via SetChargingProfile
- **Local auth list** - Stored in `css_local_auth_entries`, managed via SendLocalList
- **Installed certificates** - Stored in `css_installed_certificates`
- **Display messages** - Stored in `css_display_messages`
- **Reservations** - Stored in `css_reservations`
- **Active transactions** - Stored in `css_transactions`

The SimulatorManager joins `charging_stations` and `vendors` when it loads station config so the simulator's BootNotification carries the right vendor and model values without duplicating them on the simulator side.

## API Endpoints

| Method | Path | Purpose |
|--------|------|---------|
| GET | `/v1/css/stations` | List all CSS station records |
| POST | `/v1/css/stations` | Create both rows. Auto-creates the `charging_stations` row when missing or flips `is_simulator` on an existing row. |
| PATCH | `/v1/css/stations/:stationId` | Update simulator runtime fields. Identity changes (model, ocppProtocol, securityProfile, serialNumber, firmwareVersion) route to `charging_stations`. |
| DELETE | `/v1/css/stations/:stationId` | Remove the simulator row. The paired `charging_stations` row is preserved. |
| PATCH | `/v1/stations/:id` | Toggling `isSimulator` true/false syncs the `css_stations` row (create + enable, or disable). |
| POST | `/v1/stations/:id/confirm-real-station` | Confirm a real station: clears the simulator flag and the conflict, and disables the paired simulator. Requires `stations:write`. |

## Notes

- CSS stations do not require physical hardware. They exist entirely in software.
- The SimulatorManager subscribes to Redis pub/sub for action commands and polls the database every 5 seconds to detect new, removed, or disabled stations.
- A TLS reachability check runs each cycle. If the OCPP TLS server is unreachable, the SimulatorManager retries on the next cycle so a server coming online is picked up without restarting CSS.
- In chaos mode, the ChaosOrchestrator reads the stations with `is_simulator = true` that have an enabled `css_stations` row. It creates no rows. The seed, the dashboard toggle, and the simulator API pair stations.
- Security Profile 3 stations connect to the TLS OCPP endpoint with client certificates.

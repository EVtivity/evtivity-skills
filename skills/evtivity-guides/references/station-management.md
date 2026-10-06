Generated from https://www.evtivity.com/docs/guides/station-management (website commit 257c8b8). Do not edit.

# Station Management

How stations connect, report status, and are configured in EVtivity CSMS.

## Station Lifecycle

A station goes through four phases:

1. **Create** - Add the station in the CSMS with an identifier, site assignment, and connector configuration.
2. **Connect** - The station opens a WebSocket connection and sends a `BootNotification`. The CSMS registers the station and returns a heartbeat interval. A reboot does not change the station's availability, so a disable or a failed firmware install stays in place.
3. **Heartbeat** - The station sends periodic `Heartbeat` messages to confirm it is online. If heartbeats stop, the CSMS marks the station offline.
4. **Status Updates** - The station sends `StatusNotification` messages whenever a connector state changes (plug inserted, charging started, fault detected). OCPP 1.6 connector 0 and OCPP 2.x EVSE 0 report the status of the station itself, not a connector.

## Connector Status Model

Each connector reports one of 13 distinct status values across the two protocols. OCPP 1.6 sends fine-grained statuses directly via `StatusNotification`. OCPP 2.1 sends only five coarse `StatusNotification` values (Available, Occupied, Reserved, Unavailable, Faulted) and conveys finer-grained activity through `chargingState` on `TransactionEvent` (Charging, EVConnected, SuspendedEV, SuspendedEVSE, Idle, Discharging), which the CSMS writes back into the same connector status field.

### OCPP 1.6 statuses

All 9 values come directly from `StatusNotification`.

| Status | Description |
|---|---|
| available | No vehicle connected, ready for a session |
| preparing | Cable connected, vehicle identified, energy not yet flowing |
| charging | Actively delivering energy to the vehicle |
| suspended_ev | Charging paused by the vehicle (e.g., battery full) |
| suspended_evse | Charging paused by the station (e.g., load management) |
| finishing | Charging session ended, cable still connected. Cleared when the driver unplugs. |
| reserved | Held for a specific driver via ReserveNow |
| unavailable | Taken out of service |
| faulted | Hardware or software error |

### OCPP 2.1 statuses

Five coarse values come from `StatusNotification`. Six fine-grained values come from `chargingState` enrichment on `TransactionEvent`.

| Status | Source | Description |
|---|---|---|
| available | StatusNotification | No vehicle connected, ready for a session |
| occupied | StatusNotification | Cable connected; the connector is in use. `chargingState` carries the actual activity (charging, idle, etc.). On its own, `occupied` does not mean energy is flowing. |
| reserved | StatusNotification | Held for a specific driver via ReserveNow |
| unavailable | StatusNotification | Taken out of service |
| faulted | StatusNotification | Hardware or software error |
| charging | chargingState=Charging | Actively delivering energy to the vehicle |
| ev_connected | chargingState=EVConnected | Charging session ended, cable still connected. Cleared when the driver unplugs. |
| suspended_ev | chargingState=SuspendedEV | Charging paused by the vehicle (e.g., battery full) |
| suspended_evse | chargingState=SuspendedEVSE | Charging paused by the station (e.g., load management) |
| idle | chargingState=Idle | Transaction active, vehicle not drawing power |
| discharging | chargingState=Discharging | Vehicle-to-grid (V2G) discharge in progress |

After a session stops, OCPP 2.1 connectors stay at `occupied` (with `chargingState=EVConnected`) until the driver unplugs. The OCPP 1.6 equivalent of that post-stop state is `finishing`.

## Station-Level Availability

Each station has one availability: available, unavailable, or faulted. The CSMS computes it from separate inputs. The first matching rule wins:

1. **Unavailable** - An operator disabled the station, or the CSMS disabled it after a critical security event.
2. **Faulted** - The last firmware install failed, the station reports a fault for itself, or any connector is faulted.
3. **Unavailable** - A firmware install is in progress, or the station reports itself unavailable.
4. **Available** - None of the above apply.

A failed firmware install clears on the next install or when an operator enables the station. See [Station Status](https://www.evtivity.com/docs/csms/stations#station-status) for the reasons shown in the dashboard and the **Enable Station** and **Disable Station** actions.

## EVSE and Connector Management

Each station has one or more EVSEs, and each EVSE has one or more connectors. You can add, update, or delete EVSEs and connectors from the station detail page. EVSE numbers are unique per station, and connector numbers are unique per EVSE.

An OCPP 1.6 station has no EVSEs. The CSMS stores connector N as EVSE N with exactly one connector N. The **Create EVSE** dialog locks the connector number to the EVSE number, and you cannot add a second connector to a 1.6 EVSE.

Supported connector types:

- CCS2
- CHAdeMO
- Type2
- Type1
- GBT
- Tesla
- NACS

Set the power rating (kW) and voltage for each connector.

Connectors the CSMS creates from a station status report start without a max power. OCPP 2.1 stations fill it in from their configuration report, and never replace a value you set. For OCPP 1.6 stations, set it yourself. Until then the Connectors tab shows a **Max power unknown** badge. See [Max power](https://www.evtivity.com/docs/csms/stations#connectors).

## Station Images

Upload images from the station detail page. Each image supports:

- **Caption** - Short description shown to drivers.
- **Tags** - Categorize images (e.g., entrance, station, signage).
- **Driver-visible flag** - Controls whether the image appears in the driver portal.
- **Main image** - One image per station is designated as the primary display image.

Images are stored in S3.

## Security Profiles

EVtivity supports four OCPP security profiles:

| Profile | Description |
|---|---|
| No Auth | No security. Plain WebSocket (`ws://`). |
| Basic Auth | Basic authentication. Station sends a password in the WebSocket handshake. |
| TLS + Basic Auth | TLS with server certificate. Encrypted connection (`wss://`). |
| Mutual TLS | Both server and station present certificates. |

Configure the security profile per station. TLS + Basic Auth and Mutual TLS require certificate management.

## Free Vend

Free vend allows a site to dispense energy without payment or authorization. Enable it at the site level. Three enforcement layers ensure it works end-to-end:

1. **Authorize handler** - Skips ID tag validation and accepts all authorization requests.
2. **Payment gate skip** - Bypasses Stripe payment intent creation for sessions at free vend sites.
3. **Autostart config push** - Sends OCPP configuration to the station enabling automatic transaction start on plug-in.

## Station Configuration

The CSMS maintains a read-only view of each station's OCPP configuration variables. To refresh the configuration:

- **OCPP 2.1** - Sends a `GetBaseReport` request. The station responds with `NotifyReport` messages containing all variables.
- **OCPP 1.6** - Sends `GetConfiguration` requests. The station returns its key-value configuration.

Configuration values are displayed on the station detail page but cannot be edited directly from the CSMS UI. Use `ChangeConfiguration` (1.6) or `SetVariables` (2.1) OCPP commands to modify station settings.

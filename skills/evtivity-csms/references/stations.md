Generated from https://www.evtivity.com/docs/csms/stations. Do not edit.

# Stations

Register charging stations, manage connectors, and configure OCPP settings.

## Overview

Stations represent physical charging hardware that communicates with the CSMS over OCPP 1.6 or 2.1. Each station has one or more EVSEs (Electric Vehicle Supply Equipment), and each EVSE has one or more connectors. The CSMS manages the full lifecycle: registration, real-time monitoring, configuration, security, and certificate management.

![Stations list](https://www.evtivity.com/screenshots/csms/stations-list.png)

## Create a Station

1. Navigate to **Stations** in the sidebar.
2. Click **Create Station**.
3. Enter the station ID (must match the identity the station uses when connecting via OCPP).
4. Select the OCPP protocol version (1.6 or 2.1).
5. Assign a site, vendor, and model.
6. Set the security profile (No Auth through Mutual TLS).
7. Add EVSEs and connectors with their power ratings and connector types.
8. Click **Create**.

![Create station](https://www.evtivity.com/screenshots/csms/stations-create.png)

## Onboarding Status

New stations start with a **pending** onboarding status. Operators can approve or block stations from the station detail page.

| Status | Description |
|--------|-------------|
| pending | Awaiting operator approval. Station can connect via OCPP but cannot start charging sessions. |
| accepted | Approved and fully operational. |
| blocked | Rejected or suspended by operator. Station cannot connect via OCPP at all. |

### Connection behavior

- **Pending** stations are allowed to connect over OCPP so operators can send configuration commands during onboarding. Charging is blocked at the API level (remote start requests are refused).
- **Blocked** stations are rejected at the WebSocket connection level. The station cannot connect, send messages, or receive commands.
- **Accepted** stations connect and operate normally.

### Approving and blocking

- To approve a pending station, click **Approve** on the station detail page.
- To block a pending station, click **Reject**. The station's OCPP connection is terminated immediately.
- To unblock a blocked station, click **Unblock**. This sets the status back to pending. The station can reconnect but still requires approval before it can start charging sessions.

### Deleting a station

Stations cannot be permanently deleted. The **Delete** button blocks the station instead of deleting it from the database. This preserves all historical data (sessions, meter values, logs). You can unblock it later to restore it to pending status.

## Station Status

The station list, the station detail page, the site **Stations** and **Layout** tabs, and the fleet **Stations** tab show one status per station. Station-level conditions come first. Otherwise the status summarizes the connectors in this order: charging, reserved, faulted, unknown, available, unavailable.

Hover the status badge to see why a station is unavailable or faulted. The **Status** row on the **Details** tab shows the same reason.

| Reason | Status | Cause |
|--------|--------|-------|
| Disabled by an operator | unavailable | An operator clicked **Disable Station** |
| Disabled after a critical security event | unavailable | The station sent a critical `SecurityEventNotification` |
| Firmware install failed | faulted | The last firmware install failed |
| The station reports a fault | faulted | The station reported `Faulted` for itself |
| A connector reports a fault | faulted | At least one connector is faulted |
| Installing firmware | unavailable | A firmware install is in progress |
| The station reports itself unavailable | unavailable | The station reported `Unavailable` for itself |

### How availability is computed

The CSMS computes each station's availability (available, unavailable, or faulted) from separate inputs: an operator disable, a security disable, the firmware install state, the status the station reports for itself, and the connector statuses. The first matching rule wins:

1. Disabled by an operator or after a critical security event: **unavailable**.
2. Failed firmware install, a station-reported fault, or any faulted connector: **faulted**.
3. Firmware install in progress, or the station reports itself unavailable: **unavailable**.
4. Otherwise: **available**.

The station reports its own status on OCPP 1.6 connector 0, on OCPP 2.x EVSE 0, or through `NotifyEvent` with the `ChargingStation` component and the `AvailabilityState` variable. Connector 0 and EVSE 0 describe the station itself. They never appear as a connector or port.

A reboot (`BootNotification`) does not reset availability. A disable or a failed firmware install stays in place until it is cleared.

### Enable and disable a station

Operators with the `stations:write` permission see an **Enable Station** or **Disable Station** button in the station detail header.

1. Open the station detail page.
2. Click **Disable Station**. A confirmation dialog explains the effect.
3. Confirm. The CSMS marks the station unavailable and sends OCPP `ChangeAvailability` (Inoperative) to the station.

Drivers cannot start charging at a disabled station until you enable it. Sessions in progress are not stopped.

The header shows **Enable Station** when the station is disabled or its last firmware install failed. Enabling sends `ChangeAvailability` (Operative) and clears a failed firmware install.

To take a whole site out of service for a planned window, use a [maintenance window](https://www.evtivity.com/docs/csms/maintenance) instead.

### Security auto-disable

When a station reports a critical security event, the CSMS disables the station and sends OCPP `ChangeAvailability` (Inoperative), as it does for an operator disable. The `security.autoDisableOnCritical` setting controls this and is on by default. The **History** tab records the change with the triggering event. Click **Enable Station** to put the station back in service.

### Effect on drivers

When the whole station is unavailable (disabled, installing firmware, failed firmware install, or a station-reported fault), the driver portal shows "This station is unavailable right now. Try another station." and no connector can be selected. Portal and guest start requests return `409 STATION_UNAVAILABLE`. OCPI `START_SESSION` commands from roaming partners return `REJECTED`. A single faulted connector blocks only that connector.

### API

`PATCH /v1/stations/:id` accepts `availability` set to `available` or `unavailable`. The CSMS computes `faulted`, so the API rejects it with `400`. Station list and detail responses include `statusReason` and `reportedStatus`. Portal station and EVSE endpoints include `stationUnavailable`.

## Security Profiles

| Profile | Authentication | Transport |
|---------|---------------|-----------|
| No Auth | None | ws:// (unencrypted) |
| Basic Auth | Basic Auth (password) | ws:// |
| TLS + Basic Auth | Basic Auth (password) | wss:// (TLS) |
| Mutual TLS | Client certificate | wss:// (mutual TLS) |

Mutual TLS stations do not require a password. The station presents a client certificate for authentication.

### Station passwords

Basic Auth passwords are 16 to 40 characters for OCPP 2.1 and 16 to 20 characters for OCPP 1.6. Allowed characters are letters, digits, and `* - _ = : + | @ .`. **Rotate Credentials** on the **Security** tab sets a new random 20-character password that works for both versions.

When the station is online on Basic Auth or TLS + Basic Auth, the CSMS sends the new password to the station: `SetVariables(SecurityCtrlr.BasicAuthPassword)` for OCPP 2.1, `ChangeConfiguration(AuthorizationKey)` with the hex-encoded password for OCPP 1.6. The CSMS saves the new password only after the station accepts it. If the station rejects it or does not answer, the old password stays valid. When the station is offline, the CSMS saves the password and you configure the station to match on site.

### Changing the security profile

For an offline station, the new profile is saved directly. Configure the station to match on site.

For an online station, the CSMS upgrades the station over OCPP:

- **OCPP 2.1:** the CSMS writes a new network connection profile with the higher profile (`SetNetworkProfile`), puts it first in `NetworkConfigurationPriority`, and resets the station when idle. Moving from `ws://` to TLS uses the CSMS TLS address in `OCPP_STATION_TLS_URL`. The station must already trust the CSMS server certificate, and for Mutual TLS it must hold a client certificate, or it rejects the change.
- **OCPP 1.6:** the CSMS sets `SecurityProfile` with `ChangeConfiguration` and resets the station.

The new profile shows as pending until the station reconnects with it. Until then the station can still connect with its current profile, so a failed upgrade does not lock it out. After the station connects with the new profile, the CSMS rejects the old one. Select the current profile to cancel a pending upgrade.

OCPP does not allow lowering the security profile of a connected station. Lower profiles are disabled while the station is online. To downgrade, take the station offline, change the profile, and reconfigure the station on site.

## Connector Types

| Type | Description |
|------|-------------|
| CCS2 | Combined Charging System (common in North America and Europe) |
| CHAdeMO | DC fast charging (common in Japan) |
| Type2 | AC charging (European standard) |
| Type1 | AC charging (North American standard) |
| GBT | AC/DC charging (Chinese standard) |
| Tesla | Tesla proprietary connector |
| NACS | North American Charging Standard |

## Station Detail

Click any station in the list to open the detail page. The detail page has the following tabs.

![Station detail](https://www.evtivity.com/screenshots/csms/station-detail.png)

The header shows the online badge, the station status badge, and the **Enable Station** or **Disable Station** action. See [Enable and disable a station](#enable-and-disable-a-station).

### Details

Edit station metadata: name, vendor, model, site assignment, security profile, and password. The station's OCPP connection URL is displayed for configuration reference.

### Images

Upload and manage station photos. Set a main image that displays in the station header. Tag images and mark them as driver-visible for display in the driver portal. Images are stored in S3 with presigned URLs for upload and download.

![Station images tab](https://www.evtivity.com/screenshots/csms/station-images-tab.png)

### Metrics

Station performance metrics including uptime percentage, utilization, total sessions, session success rate, energy delivered, average session duration, disconnect count, and average downtime, plus **Total Revenue (incl. tax)**, **Revenue (excl. tax)**, **Tax Collected**, electricity cost, and **Profit**. Revenue follows the [dashboard definition](https://www.evtivity.com/docs/csms/dashboard).

![Station metrics tab](https://www.evtivity.com/screenshots/csms/station-metrics-tab.png)

### Sessions

Paginated list of all charging sessions for this station. Filterable by status and date range.

![Station sessions tab](https://www.evtivity.com/screenshots/csms/station-sessions-tab.png)

### Connectors

View and manage EVSEs and connectors. Each connector shows its current status with a color-coded badge. Add new EVSEs and connectors, edit connector types and power ratings, or delete unused ones (blocked if in use).

EVSE numbers are unique per station, and connector numbers are unique per EVSE.

#### OCPP 1.6 stations

An OCPP 1.6 station has no EVSEs. The CSMS stores connector N as EVSE N with a single connector N.

- In the **Create EVSE** dialog, the connector number follows the EVSE number and cannot be edited.
- The **Create Connector** button is hidden, because a 1.6 EVSE holds exactly one connector.
- `POST /v1/stations/:id/evses` and `POST /v1/stations/:id/evses/:evseId/connectors` return `400 CONNECTOR_ID_MISMATCH` when the request breaks this rule.

#### Max power

A connector the CSMS creates automatically, because the station reported a connector it did not know, starts without a max power. OCPP 2.1 stations fill it in from their configuration report (`NotifyReport`, the `maxLimit` of the `EVSE` component's `Power` variable). The report never replaces a value an operator set. OCPP 1.6 has no equivalent report.

A connector without a max power shows a **Max power unknown** badge. Load management cannot cap the connector at its rating until you set it, so it caps the connector at its equal share of the circuit. Click **Edit EVSE** to set the max power.

| Status | Color | Description |
|--------|-------|-------------|
| available | Green | Ready for use |
| charging | Blue | Actively charging |
| occupied | Blue | In use (OCPP 2.1) |
| preparing | Cyan | Cable plugged in, not yet charging |
| ev_connected | Cyan | EV connected (OCPP 2.1) |
| reserved | Orange | Reserved for a driver |
| suspended_ev | Yellow | Paused by vehicle |
| suspended_evse | Yellow | Paused by station |
| idle | Yellow | Transaction active, no energy demand |
| finishing | Violet | Session ending |
| discharging | Blue | V2G energy flow |
| faulted | Red | Hardware fault |
| unavailable | Red | Out of service |

![Station connectors tab](https://www.evtivity.com/screenshots/csms/station-connectors-tab.png)

### Commands

Send OCPP commands to the station and view the real-time OCPP message log. Available commands include Reset, UnlockConnector, ChangeAvailability, TriggerMessage, GetBaseReport (2.1), GetConfiguration (1.6), and more. The message log shows all OCPP messages exchanged between the station and the CSMS.

**Destructive commands require confirmation.** Reset, ChangeAvailability, and ClearCache each open a confirmation dialog before dispatching, since a misclick can wipe runtime state, disable a revenue-generating EVSE, or force every cached idToken to re-authorize.

**Offline stations queue the command.** When the target station is not connected to any OCPP pod, the API returns `202 Accepted` with code `COMMAND_QUEUED` and the UI shows a yellow **Queued** badge on the response card. The command is held in the offline queue and dispatched on the next reconnect.

**Every dispatch is audited.** Each command dispatched through the OCPP Commands tab writes a row to the per-station audit log with `action: 'command_dispatched'`, the actor, the OCPP action name, the outcome (`accepted`, `queued (station offline)`, `timeout`, or `error: <msg>`), and a payload snapshot. Payloads are capped at 16 KB to keep audit rows lean — oversized payloads are replaced with a `_truncated` marker referencing the original size. View the audit trail under the **History** tab on the station detail page or globally at `/audit`.

![Station OCPP commands tab](https://www.evtivity.com/screenshots/csms/station-commands.png)

### Simulate

Available for simulator stations only. Trigger physical actions on the simulated station: plug in, authorize, start charging, stop charging, unplug, inject fault, and power cycle. See [Simulator Actions](https://www.evtivity.com/docs/simulator/actions) for details.

![Station simulate tab](https://www.evtivity.com/screenshots/csms/station-simulate-tab.png)

### Security

Manage the station's authentication credentials. Change the security profile, set or rotate the Basic Auth password (Basic Auth and TLS + Basic Auth), and cancel a pending profile upgrade. View security event logs (connection attempts, password changes, profile changes). For Mutual TLS stations, the password section is hidden and a note directs to the Certificates tab. See [Security Profiles](#security-profiles) for how changes reach the station.

![Station security tab](https://www.evtivity.com/screenshots/csms/station-security-tab.png)

### Certificates

Available for OCPP 2.1 stations when Plug and Charge is enabled. View installed certificates, install new CA certificates, query the station for its certificate inventory, and delete certificates. See [Certificates](https://www.evtivity.com/docs/csms/certificates) for details.

![Station certificates tab](https://www.evtivity.com/screenshots/csms/station-certificates-tab.png)

### Display Messages

Available for OCPP 2.1 stations. Send display messages to the station screen via OCPP SetDisplayMessage. View active messages, clear them, and refresh the list from the station via GetDisplayMessages.

![Station display messages tab](https://www.evtivity.com/screenshots/csms/station-messages-tab.png)

### Meter Values

View standalone meter value readings from the station outside of transaction context.

![Station meter values tab](https://www.evtivity.com/screenshots/csms/station-meter-values.png)

### Events

Available for OCPP 2.1 stations. View station-generated events such as security events, component status changes, and monitoring alerts.

![Station events tab](https://www.evtivity.com/screenshots/csms/station-events-tab.png)

### Configurations

View the station's current OCPP configuration as a read-only table. Click **Refresh from Station** to pull the latest configuration from the station via GetConfiguration (1.6) or GetBaseReport (2.1). Push a configuration template to update station settings.

![Station configurations tab](https://www.evtivity.com/screenshots/csms/station-configurations-tab.png)

### Firmware History

View the history of firmware update operations for this station, including status (downloading, downloaded, installing, installed, failed) and timestamps. A station that is installing firmware is unavailable. A failed install marks the station faulted until the next install or until an operator enables the station.

![Station firmware history tab](https://www.evtivity.com/screenshots/csms/station-firmware-history-tab.png)

### Charging Profiles

View and manage OCPP charging profiles on the station. Refresh profiles from the station, push new profiles from templates, clear existing ones, and view the composite schedule. See [Smart Charging](https://www.evtivity.com/docs/csms/smart-charging) for template management.

![Station charging profiles tab](https://www.evtivity.com/screenshots/csms/station-charging-profiles.png)

### QR Codes

Generate and download QR codes for each EVSE on the station. QR codes link to the driver portal charging flow at `/charge/:stationId/:evseId`.

![Station QR codes tab](https://www.evtivity.com/screenshots/csms/station-qr-tab.png)

### Pricing

View the active tariff resolved for this station, the pricing formula breakdown, and the full schedule of tariffs that apply at different times. Assign or remove a pricing group.

![Station pricing tab](https://www.evtivity.com/screenshots/csms/station-pricing.png)

### Local Auth List

Manage the station's local authorization list. Add driver tokens, remove entries, and push the curated list to the station via OCPP SendLocalList. Changes are database-only until you explicitly push. See [Tokens](https://www.evtivity.com/docs/csms/tokens) for token management.

![Station local auth list tab](https://www.evtivity.com/screenshots/csms/station-local-auth-tab.png)

### Authorize Log

Visible to operators with the `drivers:read` permission. Cross-token forensic view filtered to this station: every Authorize attempt (and OCPP 1.6 StartTransaction without prior Authorize) the station has produced, with the matched token, matched driver, outcome (accepted / blocked / expired / concurrent_tx / no_credit / db_error), OCPP version, and a reason tag. Useful for diagnosing why a card was rejected at a specific station.

![Station authorize log tab](https://www.evtivity.com/screenshots/csms/station-authorize-log-tab.png)

### Reservations

Available when reservations are enabled in settings. View reservations for this station, create new ones, and cancel existing reservations.

![Station reservations tab](https://www.evtivity.com/screenshots/csms/station-reservations-tab.png)

### History

Per-station audit trail. Every operator-initiated change to the station (edits, command dispatches, approval changes) is recorded with the actor, the before/after state, and a timestamp.

![Station history tab](https://www.evtivity.com/screenshots/csms/station-history-tab.png)

Generated from https://www.evtivity.com/docs/csms/station-connectivity. Do not edit.

# Station Connectivity

See a cellular station's SIM status, data sessions, SIM alerts and modem signal, and reset its cellular connection.

## Overview

The **Connectivity** tab on the Station Detail page shows how a cellular station connects: what the SIM provider reports about its SIM, what the station's modem reports about its signal, and a timeline of the station's OCPP connects and disconnects beside its cellular data sessions and SIM alerts.

![Station Connectivity tab](https://www.evtivity.com/screenshots/csms/station-connectivity.png)

The tab and the ICCID field on the **Details** tab show only while a SIM provider or **Read Signal from Stations** is on. Both are off by default. See [SIM Providers](https://www.evtivity.com/docs/integrations/sim-providers) for the settings.

Opening the tab fetches nothing: it shows what was stored by the last **Refresh**.

## Permissions

| Action | Needs |
|---|---|
| Open the tab, **Refresh**, **Look Up Again** | `stations:read` and access to the station's site |
| **Confirm SIM** | `stations:write` and access to every site |
| **Reset Network**, **Clear Match**, **Read Device Model**, editing the ICCID | `stations:write` and access to the station's site |

## SIM matching

The CSMS finds a station's SIM from its ICCID. The station reports it when it boots, or you enter it on the **Details** tab (19 or 20 digits, a 19-digit ICCID may end in F, with an optional IMSI of up to 15 digits). A station that reports another ICCID when it boots replaces the entered one.

On the first **Refresh**, the CSMS asks each enabled provider for the ICCID and stores the first match. When no provider knows the ICCID, the tab says so and the CSMS does not ask again for an hour. **Look Up Again** asks at once.

Changing the ICCID, on the **Details** tab or by the station at boot, removes the match. **Clear Match** removes it by hand. The next **Refresh** looks the SIM up again. The station **History** tab records each match, confirmation and removal with the provider name, never the ICCID.

### Confirm SIM

Nothing is fetched for a match until it is confirmed: no SIM status, sessions or alerts, and no network reset. A match is confirmed when:

- a user with access to every site entered the ICCID on the **Details** tab, or
- a user with `stations:write` and access to every site clicks **Confirm SIM**.

A match made from the ICCID the station reported, or from an ICCID a user with access to some sites only entered, stays unconfirmed until **Confirm SIM**. So a station that reports a SIM it does not hold, or a user limited to some sites, cannot make a SIM a reset target.

![Confirm SIM dialog](https://www.evtivity.com/screenshots/csms/station-sim-confirm.png)

The dialog shows the ICCID, the provider and where the ICCID came from: reported by the station, or entered by a named user. Confirm SIM is refused when:

- another station already holds a confirmed match for the same SIM (`409 SIM_CONFIRMED_ELSEWHERE`). A SIM serves one station only.
- the match changed after the dialog opened, for example the station reported another ICCID (`409 SIM_MATCH_CHANGED`). Nothing is confirmed and the tab reloads, so you can check the new match first.

A lookup that finds a SIM another station holds as confirmed shows that the SIM is matched to another station, and this station shows no SIM data.

## Refresh

The **SIM and Signal Data** card has one **Refresh** control. One click reads the SIM provider and, while **Read Signal from Stations** is on, the station. Each part reports its own result line, such as the number of sessions and alerts stored or why it was skipped.

1. Pick a **Period**: the last 1, 3, 7, 14 or 31 days, or the default period from the settings (7 days unless changed). Periods longer than the provider keeps data (Hologram: 90 days) or than the CSMS keeps it are disabled, with the reason below the select.
2. Or click **Custom Range** and pick up to 31 days within that window. Days count in the time zone of the station's site, else the system time zone, and the range cannot end in the future. The dialog shows what is already stored for the chosen days.
3. Click **Refresh**.

The provider part reads the SIM status, then the data sessions and SIM alerts of the period. A period overlapping one fetched before stores each session and alert once. The station part sends one OCPP request: `GetVariables` of the modem (`DataLink`) variables for OCPP 2.0.1 and 2.1, `GetConfiguration` of the configured keys for OCPP 1.6. It runs at most once a minute per station and is skipped for an offline station. The station read uses a small amount of the station's cellular data when the station connects over cellular.

A station can be refreshed 6 times a minute. More answers `429 SIM_PROVIDER_RATE_LIMITED` and the tab shows how long to wait.

## From the Provider

The card shows the SIM as the provider reported it at the last **Refresh**:

- **Provider**, **State** (**Active**, **Pending**, **Suspended**, **Inactive**, **Deactivated**, **Test** or **Unknown**, with the provider's own state name)
- **In Session**: whether a data session is open, and since when
- **Network** with its radio access technology (for example LTE), **Cell ID**, **APN**, **Profile**
- **Last Session** and **Data This Period**, with the end of the billing period
- a warning when the SIM used more than 80 percent of the data limit the provider reports. The provider may pause it at the limit.
- **Recent SIM Alerts**: the five newest stored alerts

Fields the provider does not report are named under the card. SIM alerts arrive only with a **Refresh**: a data limit pause shows after the next Refresh.

## From the Station

While **Read Signal from Stations** is on, the card shows what the station's modem reported at the last **Refresh**, per modem:

- **Signal Strength** with its unit and grade. A value in ASU is shown with its dBm value.
- **In Use**, **Enabled**, **Fallback Link**, **Problem Reported**, **Network Address**, **ICCID**, **IMSI** and **Network Profile Slot**, when the station reports them.

An OCPP 2.0.1 or 2.1 station that has not reported its modem yet shows **Read Device Model**. It asks the station for its full device model (`GetBaseReport`). Click **Refresh** a minute later. For an OCPP 1.6 station the card lists the configuration keys named in the settings as the station reported them.

### Signal grade

The grade is **Good** at or above the good threshold (default -65 dBm), **Fair** at or above the fair threshold (default -85 dBm) and **Poor** below. These are RSSI thresholds. OCPP does not say which measure a modem reports, so an LTE modem that reports RSRP reads 20 to 30 dB lower and grades lower than its link. The info icon next to the grade says the same.

## Timeline

![Station Connectivity timeline](https://www.evtivity.com/screenshots/csms/station-connectivity-timeline.png)

Pick a **Range** (**Last Hour**, **Last 24 Hours**, **Last 7 Days**, **Last 31 Days** or a custom range). The timeline lists, newest first:

- OCPP **Connected** and **Disconnected**
- SIM **Data Session** with its end, data, network and cell
- SIM alerts: **Data Limit Reached**, **Data Warning**, **Moved to Another Device**, **Device Model Changed**, **First Device**
- **Low Signal** and **Signal Restored**, from the low signal alert

The note above the timeline says when SIM data was last fetched and that the provider reports a data session only after it closes (Hologram: up to 6 hours later).

### Data coverage

A strip of days shows what is stored for each day:

| Label | Meaning |
|---|---|
| **Has Data** | Fetched, with sessions |
| **No Sessions** | Fetched, without sessions |
| **Partly Fetched** | Part of the day was fetched |
| **Pending** | Within the provider's reporting delay |
| **Not Fetched** | No Refresh covered the day |
| **No Longer Available** | Older than the provider's history or the CSMS retention |

Click a **Not Fetched** or **Partly Fetched** day to open the custom range for it. Runs of days that were not fetched show as one timeline row with **Fetch**.

### Likely cause of a disconnect

Each **Disconnected** row shows a likely cause, worked out from stored data when the timeline is read. A disconnect never calls the provider.

| Label | When | What to check |
|---|---|---|
| **Likely Cause: CSMS** | The CSMS restarted, or one of its processes stopped | The station reconnects on its own. Check the CSMS if it did not. |
| **Likely Cause: SIM Account** | A data limit alert was stored for the SIM from 24 hours before to 1 hour after the disconnect | The SIM's data plan at the provider |
| **Likely Cause: Station** | The cellular data session was open across the disconnect | The station and its connection to the CSMS |
| **Likely Cause: Cellular Network** | Within a fetched period, the SIM had no data session at that time | The cellular coverage at the site and the station's antenna |
| **Cause Pending** | The provider has not reported that time yet | Click **Refresh** after the reporting delay |
| **Cause Unknown** | No SIM data is stored for that time | A **Refresh** that covers that day may tell more |

## Reset Network

**Reset Network** asks the provider to end the station's data session, and the station reconnects to the cellular network. The station can be offline until it reconnects. Click **Refresh** after a few minutes to see the new session.

- It needs a confirmed match. Before **Confirm SIM** the button is disabled (`409 SIM_MATCH_NOT_CONFIRMED` through the API).
- It shows only when the provider supports a network reset.
- One reset per station a minute. A second one answers `429 SIM_PROVIDER_RATE_LIMITED` with the time to wait.
- The station **History** tab records each reset (command `SimNetworkReset`) with its outcome.

## Error codes

The SIM routes answer with the `SIM_*` codes listed under [Sites & Stations](https://www.evtivity.com/api-reference/error-codes#sites-stations) in the error code reference.

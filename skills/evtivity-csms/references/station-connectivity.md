Generated from https://www.evtivity.com/docs/csms/station-connectivity. Do not edit.

# Station Connectivity

See a cellular station's SIM status, data sessions, SIM alerts and modem signal, and reset its cellular connection.

## Overview

The **Connectivity** tab on the Station Detail page shows how a cellular station connects: what the SIM provider reports about its SIM, what the station's modem reports about its signal, and a timeline of the station's OCPP connects and disconnects beside its cellular data sessions and SIM alerts.

![Station Connectivity tab](https://www.evtivity.com/screenshots/csms/station-connectivity.png)

The tab and the ICCID field on the **Details** tab show only while a SIM provider or **Read Signal from Stations** is on, as does the [SIMs](https://www.evtivity.com/docs/csms/sims) page. Both are off by default. See [SIM Providers](https://www.evtivity.com/docs/integrations/sim-providers) for the settings.

Opening the tab fetches nothing: it shows what was stored by the last **Refresh**.

## Permissions

| Action | Needs |
|---|---|
| Open the tab, **Refresh**, **Look Up Again** | `stations:read` and access to the station's site |
| **Confirm SIM** | `stations:write` and access to every site |
| **Reset Network**, **Detach SIM**, **Read Device Model**, editing the ICCID | `stations:write` and access to the station's site |
| **View SIM** | `sims:read`, and a confirmed attachment or access to every site |

## SIM attachment

The CSMS keeps one record per SIM card on the [SIMs](https://www.evtivity.com/docs/csms/sims) page. The tab shows the SIM attached to the station. A SIM is attached to one station at a time, and a station has one SIM at a time.

The CSMS finds the SIM from the station's ICCID. The station reports it when it boots, or you enter it on the **Details** tab (19 or 20 digits, a 19-digit ICCID may end in F, with an optional IMSI of up to 15 digits).

- **An ICCID you enter.** Saving it creates the SIM when it is new and attaches it to the station. It replaces the station's attachment of another SIM. When the SIM is attached to another station, it is not attached here and the **Details** tab says why. A user with access to every site moves the SIM here only when its other attachment is unconfirmed and was reported by that station. An inactive SIM is not attached either.
- **An ICCID the station reports.** When a station boots with another ICCID, its attachment ends. The next **Refresh** creates the SIM when it is new and attaches it unconfirmed, unless the SIM is attached to another station. A reported ICCID never moves a SIM from another station.
- **An ICCID entered while the SIM features were off** is stored on the station only. The first **Refresh** after a SIM provider or **Read Signal from Stations** is turned on attaches it as entered by that user.

On the first **Refresh**, the CSMS asks each enabled provider for the ICCID and stores the first match on the SIM. When no provider knows the ICCID, the tab says so and the CSMS does not ask again for an hour. **Look Up Again** asks at once.

**View SIM** opens the SIM's page. **Detach SIM** ends the station's attachment after a confirmation. The SIM, its attachment history and its stored sessions and alerts stay. While the station keeps the same ICCID, the next **Refresh** attaches the SIM again, unconfirmed, so it needs **Confirm SIM** again before anything is fetched or reset. To take a SIM out of a station for good, remove its ICCID on the **Details** tab or deactivate the SIM on its page.

The station **History** tab records each attachment, confirmation and detach with the provider name, never the ICCID.

### Confirm SIM

Nothing is fetched for an attachment until it is confirmed: no SIM status, sessions or alerts, and no network reset. An attachment is confirmed when:

- a user with access to every site entered the ICCID on the **Details** tab, attached the SIM on its page, or imported it with the station, or
- a user with `stations:write` and access to every site clicks **Confirm SIM**.

An attachment made from the ICCID the station reported, or from an ICCID a user with access to some sites only entered, stays unconfirmed until **Confirm SIM**. So a station that reports a SIM it does not hold, or a user limited to some sites, cannot make a SIM a reset target or read its data.

![Confirm SIM dialog](https://www.evtivity.com/screenshots/csms/station-sim-confirm.png)

The dialog shows the ICCID, the provider and where the ICCID came from: reported by the station, entered on the station by a named user, attached on the SIM page by a named user, or imported from a CSV file by a named user. Confirm SIM is refused when:

- the attachment changed after the dialog opened, for example the station reported another ICCID (`409 SIM_ATTACHMENT_CHANGED`). Nothing is confirmed and the tab reloads, so you can check the new attachment first.
- the SIM is inactive (`409 SIM_INACTIVE`). Reactivate it on its page first.

While a confirmed attachment is open, the station uses the **Cellular** data plan, unless a plan is set on the station itself on the **Configurations** tab. After a detach the station goes back to its site's plan or the default. See [Cellular Stations](https://www.evtivity.com/docs/configuration/cellular-stations#pick-the-cellular-plan).

When the station's SIM is attached to another station or is inactive, the tab says so and shows no SIM data.

### Data from earlier attachments

The tab shows the SIM's status, sessions, alerts and fetched days only from the last time an attachment of the SIM ended: detached, replaced, moved, deactivated, or ended because the station reported another ICCID. So a SIM that comes from another station shows none of its time there. A SIM never attached elsewhere shows everything stored for it, also the days the first **Refresh** fetched before **Confirm SIM**. The SIM page shows the full history to users with access to every site.

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

- It needs a confirmed attachment. Before **Confirm SIM** the button is disabled (`409 SIM_ATTACHMENT_NOT_CONFIRMED` through the API).
- It shows only when the provider supports a network reset.
- One reset per SIM a minute, counted together with the SIM page. A second one answers `429 SIM_PROVIDER_RATE_LIMITED` with the time to wait.
- An inactive SIM cannot be reset (`409 SIM_INACTIVE`).
- The station **History** tab records each reset (command `SimNetworkReset`) with its outcome.

## Error codes

The SIM routes answer with the `SIM_*` and `STATION_HAS_SIM` codes listed under [Sites & Stations](https://www.evtivity.com/api-reference/error-codes#sites-stations) in the error code reference.

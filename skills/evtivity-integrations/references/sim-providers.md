Generated from https://www.evtivity.com/docs/integrations/sim-providers. Do not edit.

# SIM Providers

Connect the SIM provider of your cellular stations to see their SIM status, data sessions and SIM alerts.

## Overview

A SIM provider account lets the CSMS show the SIM status, the cellular data sessions and the SIM alerts of each cellular station on the station's **Connectivity** tab, beside the station's own OCPP connects and disconnects, and of each SIM on the [SIMs](https://www.evtivity.com/docs/csms/sims) page. Hologram is the supported provider.

Configure it under **Settings > Integrations & Features > SIM Providers**.

![SIM Providers settings](https://www.evtivity.com/screenshots/csms/settings-sim-providers.png)

The feature is off by default. While Hologram and **Read Signal from Stations** are both off, the CSMS calls no SIM provider and sends no SIM related OCPP request, the station pages show no **Connectivity** tab and no ICCID field, and the **SIMs** page is hidden. Turning either one on shows them.

For the station side (Refresh, Confirm SIM, the timeline and the network reset), see [Station Connectivity](https://www.evtivity.com/docs/csms/station-connectivity). For the SIM records (import, export, attach, detach and deactivate), see [SIMs](https://www.evtivity.com/docs/csms/sims).

## Permissions

| Action | Needs |
|---|---|
| View the SIM Providers settings | `settings.integrations:read` and access to every site |
| Save the settings, Test Connection | `settings.integrations:write` and access to every site |
| See the stored API key | `settings.system:read` (other users see only that a key is stored) |

The settings apply to every site. A user with access to some sites only sees a note instead of the settings, and the API answers `404` to that user.

## Hologram

### 1. Create an API key

In the Hologram Dashboard, open the API page of your account settings and create an API key. The key needs the Editor role or higher.

### 2. Enter the account

1. Turn on **Enable Hologram**.
2. Enter the **Organization ID**: the numeric ID of your Hologram organization, 1 to 15 digits.
3. Enter the **API Key**.
4. Click **Save**.

The CSMS stores the API key encrypted. It never appears in logs, and the settings audit log records it as `<redacted>`.

### 3. Test the connection

Click **Test Connection**. It uses the saved values, so save your changes first. On success it shows the number of SIMs in the organization. When the stored organization has no SIMs but the API key also reaches other organizations that have SIMs, it lists them so you can check the organization ID.

Test Connection runs at most 6 times a minute. While Hologram asks the CSMS to slow down, the test answers `429 SIM_PROVIDER_RATE_LIMITED` with the time to wait.

### Hologram data

- Hologram reports a data session only after it closes, up to 6 hours later. The newest hours show as **Pending** until then.
- Hologram keeps 90 days of data. A Refresh cannot fetch older periods.
- A SIM alert (data limit reached, data warning, the SIM moved to another device, device model changed, first device) reaches the CSMS only with a Refresh.
- When Hologram answers `429`, the CSMS calls Hologram again only after the wait it gives, at most one hour (60 seconds when it gives none).

## Session History

| Setting | Default | Range | Effect |
|---|---|---|---|
| **Default Refresh Period (Days)** | 7 | 1 to 31 | The period preselected next to **Refresh** on a station's **Connectivity** tab and on a SIM page. A person can pick another period or a custom date range there. |
| **Keep Sessions and Alerts (Days)** | 90 | 7 to 730 | Sessions and SIM alerts older than this are deleted. Sessions include cell IDs, which show roughly where a station was online. |

The CSMS keeps sessions and SIM alerts only for SIMs someone refreshed, on a station's **Connectivity** tab or on the SIM page. It never fetches them on its own.

## Station Signal

| Setting | Default | Effect |
|---|---|---|
| **Read Signal from Stations** | Off | Each **Refresh** on a station's **Connectivity** tab also reads the signal from the station's modem: one `GetVariables` request for OCPP 2.0.1 and 2.1, one `GetConfiguration` request for OCPP 1.6. |
| **Low Signal Alert (dBm)** | Empty (off) | OCPP 2.0.1 and 2.1 stations whose modem supports monitoring report when their signal drops below this value. |
| **OCPP 1.6 Signal Keys** | Empty | The configuration keys read from OCPP 1.6 stations, one per line (for example `RSSI`). Each vendor names them differently. At most 20 keys of at most 50 characters. Without keys, a Refresh reads nothing from OCPP 1.6 stations. |
| **Good Signal From (dBm)** | -65 | A signal at or above this value is graded good. |
| **Fair Signal From (dBm)** | -85 | A signal at or above this value is graded fair, below it poor. |

The thresholds range from -140 to -40 dBm, and the good threshold must be above the fair one. **Low Signal Alert** and the OCPP 1.6 keys apply only while **Read Signal from Stations** is on.

### Low signal alert

When you save a **Low Signal Alert** value, the CSMS sets a low threshold monitor on the modem signal of each connected OCPP 2.0.1 and 2.1 station that reports monitoring support for it. A station that connects later gets it when it connects. When the signal drops below the value, the station reports it, and the station's **Connectivity** timeline shows **Low Signal**, then **Signal Restored** when it recovers. Conformance test stations and OCPP 1.6 stations get no monitor.

Clearing the value or turning **Read Signal from Stations** off removes the monitors: at once on connected stations, and on the others when they next connect.

## Data use

- The CSMS calls the SIM provider only when a person clicks **Refresh**, **Test Connection** or **Reset Network**. No schedule, background job, station event or incoming webhook calls it. Opening a station's **Connectivity** tab, the **SIMs** list or a SIM page fetches nothing, and a CSV import calls no provider.
- While **Read Signal from Stations** is on, each **Refresh** sends one OCPP request to the station, at most once a minute per station. It uses a small amount of the station's cellular data when the station connects over cellular. Nothing reads a station when it connects or when the tab opens.
- The low signal monitors are configuration, sent when the alert is saved and when a station connects. They read nothing.

## Error codes

The SIM routes answer with the `SIM_*` and `STATION_HAS_SIM` codes listed under [Sites & Stations](https://www.evtivity.com/api-reference/error-codes#sites-stations) in the error code reference.

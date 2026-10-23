Generated from https://www.evtivity.com/docs/csms/sims. Do not edit.

# SIMs

Keep one record per SIM card, import and export SIMs as CSV, attach them to stations, and see each SIM's status, data sessions and attachment history.

## Overview

The **SIMs** page lists the SIM cards of your cellular stations and the SIMs not attached to a station. Each SIM has one record with its ICCID, IMSI, label, notes, provider, status and the history of the stations it was attached to. Its data sessions, SIM alerts and fetched days belong to the SIM, so they stay with it when it moves to another station.

Open it from **SIMs** in the navigation, below **Stations**.

![SIMs list](https://www.evtivity.com/screenshots/csms/sims-list.png)

The page and its navigation entry show only while a SIM provider or **Read Signal from Stations** is on. Both are off by default. While both are off, the CSMS keeps no SIM records, and every `/v1/sims` route answers `400 SIM_FEATURE_DISABLED`. See [SIM Providers](https://www.evtivity.com/docs/integrations/sim-providers) for the settings.

The CSMS calls the SIM provider only when a person clicks **Refresh** or **Reset Network**. Opening the list or a SIM page fetches nothing, and importing, attaching, confirming, detaching, deactivating or deleting a SIM calls no provider.

## How SIMs get into the list

- **Import CSV** on the list page.
- An ICCID entered on a station's **Details** tab. The CSMS creates the SIM when it is new and attaches it to the station.
- An ICCID the station reports when it boots. The CSMS stores it on the station, and the next **Refresh** on the station's **Connectivity** tab creates the SIM when it is new and attaches it to the station, unconfirmed.

The API also adds one SIM without a station with `POST /v1/sims`.

## Permissions

| Action | Needs |
|---|---|
| See the list and a SIM page, **Export CSV**, **Refresh** | `sims:read` |
| Edit the label, notes and IMSI, **Reset Network**, **Detach SIM** | `sims:write` |
| **Import CSV**, **Download Template**, **Delete SIM**, **Deactivate SIM**, **Reactivate SIM** | `sims:write` and access to every site |
| **Attach to Station**, **Confirm SIM** | `sims:write`, `stations:write` and access to every site |
| The **History** tab | `audit:read` |

The operator role has `sims:read` and `sims:write` by default, the viewer role `sims:read`.

### What a site-restricted user sees

A user with access to some sites only sees a SIM while it has a confirmed attachment to a station of those sites. SIMs without a station, SIMs with an unconfirmed attachment and SIMs at a station without a site are visible only to users with access to every site. Any other SIM answers `404 SIM_NOT_FOUND`.

On the page of a visible SIM, this user sees the status, sessions, alerts and fetched days only from the periods in which the SIM was confirmed-attached to stations of their sites. The list and **Export CSV** leave out the status fetched outside those periods. Users of other sites and users with access to every site are not named.

This user can detach a SIM from a station of their sites. The SIM then leaves their list.

## SIM list

Each row shows:

| Column | Meaning |
|---|---|
| **ICCID** | The SIM's ICCID |
| **Label** | Your own name for the SIM |
| **Provider** | The SIM provider that knows the SIM. Empty until a **Refresh** looks it up |
| **CSMS Status** | **Active** or **Inactive**, set in the CSMS with **Deactivate SIM** and **Reactivate SIM** |
| **Provider Status** | The state the SIM provider reported at the last **Refresh**, such as **Active** or **Suspended**. **Not fetched** before the first Refresh |
| **Station** | The station the SIM is attached to, or **Not attached** |
| **Confirmed** | Whether the attachment is confirmed |
| **Last Fetched** | When the provider data was last fetched |
| **Created** | When the SIM was added |

The CSMS status and the provider status are separate. Deactivating a SIM in the CSMS does not change it at the provider, and a **Refresh** never changes the CSMS status.

Search by ICCID, IMSI or label. The filters are **Provider**, **Attachment** (**Attached**, **Not Attached**, **Attached, Not Confirmed**), **CSMS Status**, **Provider Status** and **Station**. The search and filters stay in the page address, so a reload or a shared link keeps them. Click a row to open the SIM page.

## Import and export

![Import SIMs dialog](https://www.evtivity.com/screenshots/csms/sims-import.png)

**Download Template** downloads an example file. Its columns are:

`iccid,imsi,label,notes,stationId,status,provider,providerState,attachedStationId,attachmentConfirmed`

**Import CSV** reads the first five columns and ignores the others, so an exported file imports again:

| Column | Rule |
|---|---|
| `iccid` | Required. 19 digits, which may end in F, or 20 digits |
| `imsi` | Up to 15 digits |
| `label` | Up to 100 characters |
| `notes` | Up to 2000 characters |
| `stationId` | The OCPP station ID. When set, the SIM is attached to that station and confirmed |

1. Click **Import CSV** and pick the file. A file holds at most 10,000 rows.
2. Turn on **Update existing records** to change the IMSI, label and notes of SIMs that already exist. An empty cell keeps the stored value. Without it, a SIM that already exists is skipped.
3. Click **Import CSV** in the dialog.

The result lists the SIMs created, updated and attached, and each refused row as `Row N: <reason>`. A row is refused for an invalid ICCID or IMSI, a label or notes that are too long, an ICCID that appears twice in the file, an unknown station, a station that already has a SIM, a SIM attached to another station, or an inactive SIM. A refused row changes nothing, and the other rows are still imported. The import never detaches or moves a SIM, and it calls no SIM provider.

**Export CSV** downloads the SIMs that match the search and filters on screen. With no search or filter it downloads every SIM you can see. The export adds the CSMS status, the provider, the provider status, the attached station and whether the attachment is confirmed.

## SIM page

The header shows the label, or the ICCID when the SIM has no label, with **Prev** and **Next** to move through the list.

![SIM detail](https://www.evtivity.com/screenshots/csms/sim-detail.png)

### Details

- The ICCID, IMSI, provider, **Provider SIM ID** and when the SIM was added.
- **CSMS Status** with who deactivated the SIM and when.
- **Provider Status**: what the provider reported at the last **Refresh**, the same card as on a station's **Connectivity** tab ([Station Connectivity](https://www.evtivity.com/docs/csms/station-connectivity#from-the-provider)).
- **Refresh** with the period select and **Custom Range**. A Refresh on the SIM page reads the SIM provider only and sends nothing to a station. A user with access to every site can refresh any SIM, attached or not, confirmed or not. Each SIM can be refreshed 6 times a minute.
- **Reset Network**, when the provider supports it. The provider ends the SIM's data session and the device reconnects to the cellular network. One reset per SIM a minute, counted together with the station **Connectivity** tab.
- **Edit SIM** for the label, notes and IMSI.
- **Deactivate SIM** or **Reactivate SIM**, and **Delete SIM**.

### Sessions

The SIM's timeline of data sessions and SIM alerts with the strip of fetched days, as described under [Timeline](https://www.evtivity.com/docs/csms/station-connectivity#timeline). It has no OCPP connects and disconnects, because the SIM may have been in several stations.

### Attachments

![SIM attachments](https://www.evtivity.com/screenshots/csms/sim-detail-attachments.png)

**Current Attachment** shows the station, its site, the source, who attached the SIM and whether the attachment is confirmed. The source is one of:

- **Reported by the station**: the station reported the ICCID at boot, and a **Refresh** attached it.
- **Entered on the station**: a user entered the ICCID on the station's **Details** tab.
- **Attached on the SIM page**: a user clicked **Attach to Station**.
- **Imported from a CSV file**: a row of an import named the station.

**Attachment History** lists each earlier attachment with its station, site, source, start, end and reason:

| Reason | Meaning |
|---|---|
| **Detached** | A user clicked **Detach SIM**, or removed the ICCID from the station |
| **The station reported another ICCID** | The station booted with another SIM |
| **Another SIM was entered on the station** | A user entered another ICCID on the station |
| **Moved to another station** | A user with access to every site entered this ICCID on another station while this attachment was unconfirmed and reported by the station |
| **The SIM was deactivated** | A user clicked **Deactivate SIM** |

## Attach, confirm and detach

A SIM is attached to one station at a time, and a station has one SIM at a time.

**Attach to Station** attaches an unattached SIM to the station you pick and confirms it at once. It is refused when the station already has a SIM (`409 STATION_HAS_SIM`), the SIM is attached to another station (`409 SIM_ATTACHED_ELSEWHERE`) or the SIM is inactive (`409 SIM_INACTIVE`). To move a SIM, detach it first.

**Confirm SIM** confirms an unconfirmed attachment, after you checked that this SIM is in that station. Until then nothing is fetched from the provider for the station and no network reset is possible from the station's **Connectivity** tab. An attachment is confirmed at once when a user with access to every site entered the ICCID on the station, attached the SIM on this page or imported it with the station. See [Confirm SIM](https://www.evtivity.com/docs/csms/station-connectivity#confirm-sim).

**Detach SIM** ends the attachment. The SIM, its attachment history and its stored sessions and alerts stay. While the station keeps the same ICCID, the next **Refresh** on its **Connectivity** tab attaches the SIM again, unconfirmed.

When an attachment ends for any reason, the station's **Connectivity** tab shows the SIM's data only from that moment on, wherever the SIM goes next. The SIM page keeps the full history for users with access to every site.

## Deactivate and reactivate

**Deactivate SIM** marks the SIM **Inactive** in the CSMS, for example for a SIM taken out of service. It ends the SIM's attachment to its station, keeps the SIM and its data, and calls no SIM provider: the SIM keeps its state at the provider. While a SIM is inactive it cannot be attached, refreshed or reset (`409 SIM_INACTIVE`), and an ICCID entered on a station for it attaches nothing.

**Reactivate SIM** makes the SIM **Active** again. It attaches the SIM to no station and calls no SIM provider.

## Delete

**Delete SIM** deletes the SIM with its attachment history and its stored sessions, alerts and fetched days. It cannot be undone. Detach the SIM first: a SIM with an attachment cannot be deleted (`409 SIM_ATTACHED`). The audit log keeps a record of the deleted SIM.

## History

The **History** tab lists each change to the SIM: created, updated, attached, attachment confirmed, detached with the reason, deactivated, reactivated, network reset and deleted. No row stores the ICCID, the IMSI or the provider's SIM ID. An IMSI change shows only that the IMSI changed.

## Error codes

The SIM routes answer with the `SIM_*` and `STATION_HAS_SIM` codes listed under [Sites & Stations](https://www.evtivity.com/api-reference/error-codes#sites-stations) in the error code reference.

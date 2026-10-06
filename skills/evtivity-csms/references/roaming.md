Generated from https://www.evtivity.com/docs/csms/roaming (website commit 900fb20). Do not edit.

# Roaming

Connect your charging network to roaming partners using OCPI 2.2.1 and 2.3.0 for cross-network EV charging.

## Overview

Roaming enables interoperability between charging networks using the Open Charge Point Interface (OCPI) protocol. EVtivity supports both OCPI 2.2.1 and 2.3.0 and can act as a CPO (Charge Point Operator) serving your stations to partner networks, or as an eMSP (e-Mobility Service Provider) accepting partner tokens for authorization.

The OCPI server runs as a standalone service on port 7104, separate from the main API, because OCPI uses token-based authentication rather than JWT.

## Partner Registration

### Register a New Partner

1. Navigate to **Roaming > Partners**.
2. Click **Create Partner**.
3. Enter partner details: name, country code, party ID, and optionally the versions URL and partner registration token. Click **Create**.
4. The system generates a registration token. Share this token with your partner.

![Roaming partners](https://www.evtivity.com/screenshots/csms/roaming-partners.png)

### Complete Registration

Registration uses the OCPI credentials handshake:

1. Your partner calls your OCPI versions endpoint with the registration token.
2. Both systems exchange permanent credentials tokens.
3. Module endpoints are discovered and stored.

You can also initiate outbound registration by clicking **Register** on a partner record and providing their versions URL.

### Private Network

By default the CSMS sends OCPI requests and command results to a partner only on public addresses. A partner URL that is, or resolves to, a private or internal address is blocked, so a partner cannot use your CSMS to reach your internal network.

Select **Allow private network** when you create the partner, or on the partner detail page, to let requests to that partner reach loopback and private addresses. Use it for private peering on your own network or for a local OCPI simulator. Cloud metadata and other link-local addresses stay blocked. Changes are recorded in the partner history.

### Partner Status

| Status | Description |
|--------|-------------|
| Pending | Partner created, awaiting registration |
| Connected | Registration complete, actively exchanging data |
| Disconnected | Partner disconnected or credentials revoked |

## Location Publishing

Control which sites are visible to roaming partners.

1. Navigate to **Roaming > Locations**.
2. Toggle the **Published** switch for each site you want to share.
3. Optionally restrict visibility to specific partners.

![Roaming locations](https://www.evtivity.com/screenshots/csms/roaming-locations.png)

Published locations include all EVSE and connector details, transformed to OCPI format. Location data updates are pushed to partners automatically when station status changes. When you delete a station or an EVSE, unpublish a site, or remove a partner from its visibility, the partners that saw it receive the affected EVSEs with status `REMOVED`, as OCPI requires (OCPI has no delete). Moving a station to another site does the same at the site it left, and the EVSEs appear at the new site. Pulls also return these EVSEs as `REMOVED` for 90 days.

### EVSE Identifiers

| Field | Format | Example |
|-------|--------|---------|
| `uid` | The EVSE's internal id: `evs_` plus 12 characters. Unique across your network. | `evs_a1b2c3d4e5f6` |
| `evse_id` | `{stationId}-EVSE-{n}`, where `stationId` is the OCPP station id | `CS-001-EVSE-1` |

Partners address an EVSE by its `uid` in commands and in the EVSE and connector endpoints. The EVSE must belong to the location in the request.

Earlier versions used `{siteId}-{evseNumber}` as the `uid`. That value repeated across stations at one site, so a partner command could reach the wrong charger. After the upgrade, every connected partner with a locations receiver gets each published location once with the new `uid` values, and each old `uid` with status `REMOVED`, so partners do not need a full pull.

## Roaming Sessions

When a roaming partner's driver charges at your station, a roaming session is created.

1. Navigate to **Roaming > Sessions** to view all roaming sessions.
2. Each session shows: partner name, token used, station, status, energy delivered, and **Cost (excl. tax)**.

![Roaming sessions](https://www.evtivity.com/screenshots/csms/roaming-sessions.png)

Partners can also pull the sessions of their drivers at your stations from `GET /ocpi/{version}/cpo/sessions`. Each session is rendered live from the charging session, with its cost split into the net amount and tax. Sessions you received from a partner as eMSP are never served back.

### Authorization Flow

When a driver presents a token that is not found in your local driver database, the system falls back to the OCPI external tokens table. If the token matches a partner-provided token, authorization is granted and a roaming session is created.

## Charge Detail Records (CDRs)

CDRs are immutable billing records. A CDR is generated once for each completed roaming session, about a minute after the session ends, and pushed to the partner whose driver charged when the partner has a CDRs receiver endpoint. A failed push is retried. Partners without a receiver pull CDRs from `GET /ocpi/{version}/cpo/cdrs`. Sessions that end faulted or failed are not billed (OCPI status `INVALID`) and get no CDR. After the upgrade to v0.1.38, CDRs are also generated once for completed roaming sessions of the 30 days before the upgrade, about 50 every 5 minutes.

1. Navigate to **Roaming > CDRs**.
2. View CDR details including location snapshot, energy, duration, and **Cost (excl. tax)**.
3. Check push status to confirm the CDR was delivered to the partner.

![Roaming CDRs](https://www.evtivity.com/screenshots/csms/roaming-cdrs.png)

### Credit CDRs

To issue a refund for a roaming session:

1. Find the ID of the original CDR.
2. Call `POST /v1/ocpi/cdrs/credit` with the `originalCdrId` and a `reason` for the credit. The CSMS has no button for this.
3. The system generates a credit CDR and pushes it to the partner.

As OCPI requires, only the `total_cost` of a credit CDR is negative: both its amount excluding tax and its amount including tax (2.2.1) or its amount before taxes and its taxes (2.3.0). Every other field keeps the original values. Only your own CDRs can be credited, a credit CDR cannot be credited again, and crediting a CDR twice returns the existing credit.

## Tariff Mapping

Publish your tariffs and pricing groups to roaming partners as OCPI tariffs. A mapping selects what a partner receives. The OCPI tariff itself is generated from your pricing, so you never edit OCPI tariff JSON.

1. Navigate to **Roaming > Tariffs**.
2. Click **Create Mapping**.
3. Enter the **OCPI Tariff ID**.
4. Choose the **Partner**, or **All Partners**. A mapping for one partner replaces a mapping for all partners with the same OCPI tariff ID.
5. Under **Published From**, choose the source:
   - **Tariff** publishes the prices of one tariff at all times, without its restrictions.
   - **Pricing group** publishes every active tariff of the group with its time, day, date, holiday, and energy restrictions.
6. Click **Create**.

![Roaming tariffs](https://www.evtivity.com/screenshots/csms/roaming-tariffs.png)

### Generated tariffs

Partners receive each tariff generated from your pricing:

- **Prices excluding tax.** Published prices are always net. When tariff prices are entered including tax, they are converted to net with 4 decimals. Each price component carries the tariff tax rate as `vat`, a percentage (`19` for a rate of `0.19`). A rate of 0 omits `vat`.
- **Time per hour.** OCPI defines time prices per hour, so TIME is the per-minute price times 60. PARKING_TIME is the time price plus the idle fee, times 60. The idle grace period has no OCPI equivalent.
- **Exact steps.** `step_size` is 1 for every dimension, as the CSMS bills exact energy and time.
- **Reservation fees** become an element with a TIME component and the `RESERVATION` restriction.
- **OCPI 2.3.0** adds `tax_included`: `NO` when any tariff is taxed, `N/A` otherwise.
- **Company currency.** Tariffs carry the company currency.

Partners pull tariffs from `GET /ocpi/{version}/cpo/tariffs`. A pricing change, and every mapping create, update, or delete, is pushed to partners automatically. Deleting a tariff or pricing group removes its mappings, and partners drop them on their next pull.

### Connector tariffs

Each connector lists the OCPI tariff ID that applies to it in `tariff_ids`, per partner. The station's pricing group is resolved as for a driver without an assignment (station, then site, then the default group). A mapping of that pricing group is used first, otherwise the mapping of the group's tariff that applies at that moment. Connectors at free-vend sites, and stations without a published tariff, carry no `tariff_ids`.

### Costs and tax

Session and CDR costs use the OCPI price type of the partner's version:

| Version | Price fields |
|---------|--------------|
| 2.2.1 | `excl_vat` (net amount) and `incl_vat` (amount charged) |
| 2.3.0 | `before_taxes` (net amount) and `taxes`, one entry per tax rate with its percentage and amount |

A session billed across tariffs with different tax rates is split per rate. The **Cost (excl. tax)** columns on the Sessions and CDRs pages show the net amount, for your sessions and for those received from partners.

> **Warning:**
>
> `excl_vat` now holds the net amount. If a partner integration read `excl_vat` as the amount charged, check it with the partner.

## CPO Commands

When acting as CPO, your system receives remote commands from eMSP partners:

| Command | Description |
|---------|-------------|
| START_SESSION | Partner requests a charging session start at your station |
| STOP_SESSION | Partner requests to stop an active roaming session |
| RESERVE_NOW | Partner reserves a connector at your station |
| CANCEL_RESERVATION | Partner cancels a reservation |
| UNLOCK_CONNECTOR | Partner requests connector unlock |

Commands are translated to OCPP messages (`RequestStartTransaction`, `RequestStopTransaction`, etc.) and dispatched to the station that holds the EVSE `uid`. Results are sent back to the partner asynchronously.

`START_SESSION` returns `REJECTED` when the station is disabled, is installing firmware, has a failed firmware install, or reports a fault for itself. See [Station Status](https://www.evtivity.com/docs/csms/stations#station-status).

## Data Synchronization

### Push (Real-Time)

Location status changes, removed EVSEs, session updates, tariff changes, and CDRs are pushed to partner receiver endpoints automatically via the OCPI push service.

### Pull (On-Demand)

Trigger a manual sync to pull data from a partner:

1. Find the partner ID on the partner detail page.
2. Call `POST /v1/ocpi/partners/{id}/sync/{module}` with the module (`locations`, `tariffs`, `cdrs`, or `tokens`). The CSMS has no sync button.
3. The system fetches all pages from the partner's sender endpoints using OCPI pagination.

## OCPI Settings

Configure your OCPI identity in **Settings > Integrations & Features > Roaming**:

- Country code (e.g., US)
- Party ID (e.g., EVT)
- Business name

These values identify your system in the OCPI protocol and appear in partner credentials exchanges.

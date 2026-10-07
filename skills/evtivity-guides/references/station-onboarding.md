Generated from https://www.evtivity.com/docs/guides/station-onboarding. Do not edit.

# Station Onboarding

Register a new charging station in EVtivity CSMS and bring it online for the first time.

This guide walks through onboarding a brand-new charging station: creating its record in the CSMS, configuring credentials, pointing the station at the CSMS endpoint, and verifying it goes online.

EVtivity does not auto-create station records when an unknown station tries to connect. Every station must be registered first; otherwise the WebSocket upgrade request is rejected with HTTP 404. This is intentional — it prevents random hardware from joining your network.

## What you need before you start

- The station's **identifier** (the OCPP charge point ID, often printed on a label, e.g. `CS-001`).
- The station's **OCPP version**: 1.6 or 2.1.
- The **security profile** the station is configured for:
  - No Auth: no auth (lab/dev only)
  - Basic Auth: HTTP Basic auth over plain WebSocket
  - TLS + Basic Auth: HTTP Basic auth over WSS (TLS)
  - Mutual TLS: client certificate
- For Basic Auth and TLS + Basic Auth: a **password** for the station to authenticate with.
- For Mutual TLS: a **client certificate** signed by the CSMS's trusted CA.
- The site you want the station assigned to (optional but recommended for site-level pricing, load management, and reports).

## Step 1: Create the station record

The only fields you must provide are **Station Name**, **OCPP Version**, and **Security Profile** (plus credentials for Basic Auth through Mutual TLS, set in Step 2). Everything else is optional: vendor/model/firmware metadata fills in from the first BootNotification, and EVSE/connector rows are auto-created from the first StatusNotification. Pre-defining hardware just gives the dashboard something to render before the station first reports.

Three ways to do this:

### Dashboard

1. Go to **Stations** in the CSMS dashboard.
2. Click **Create Station**.
3. Fill in:
   - **Station Name** (required): must match what the station will report at the WebSocket URL path (e.g. `/CS-001`).
   - **OCPP Version** (required): 1.6 or 2.1 (defaults to 1.6 — most field hardware is still 1.6).
   - **Security Profile** (required): No Auth, Basic Auth, or TLS + Basic Auth.
   - **Password** (Basic Auth and TLS + Basic Auth): the password the station authenticates with.
   - **Model** (optional, auto-populated from BootNotification).
   - **Site** (optional): assign to a site for grouping and policy inheritance.
   - **Latitude** and **Longitude** (optional).
   EVSEs and connectors are auto-created from the first StatusNotification. To pre-define them (type, max power), open the station's **Connectors** tab and click **Create EVSE**. Do this when you want the dashboard populated immediately or when the firmware doesn't emit a StatusNotification per connector at boot.
4. Click **Create**.

The station now exists in `charging_stations` with `onboarding_status = pending` (or `accepted`, depending on the registration policy — see Step 4).

### REST API

```bash
POST /v1/stations
Authorization: Bearer <operator-jwt-or-api-key>
Content-Type: application/json

{
  "stationId": "CS-001",
  "ocppProtocol": "ocpp1.6",
  "securityProfile": 1,
  "model": "DCFC-150",
  "vendor": "ACME Charging",
  "siteId": "sit_abc123",
  "evses": [
    {
      "evseId": 1,
      "connectors": [
        { "connectorId": 1, "connectorType": "CCS2", "maxPowerKw": 150 }
      ]
    }
  ]
}
```

Returns 201 with the new station's UUID and full record. Returns 409 `STATION_ID_EXISTS` if the `stationId` is already taken.

### CSV bulk import

For onboarding many stations at once:

1. Download the template: `GET /v1/sites/import/template` (or the **Template** button on the Sites page).
2. Fill the CSV with one row per connector (sites, stations, EVSEs, and connectors are denormalized into one sheet).
3. Upload via the **Import CSV** button on the Sites page, or `POST /v1/sites/import` with parsed rows.

The importer matches existing rows by `(siteName, stationId, evseId, connectorId)` and either creates or updates as needed (controlled by an `updateExisting` flag). All writes happen in a single transaction — if any row fails validation, the whole import rolls back.

## Step 2: Set the station's credentials

For No Auth — skip this step. The station connects with no credentials. **Lab use only.** Do not run No Auth in production.

For Basic Auth and TLS + Basic Auth:

Open the **Security** tab on the station detail page, click **Change Password**, enter the password, and click **Save Password**. Passwords are 16 to 40 characters for OCPP 2.1 and 16 to 20 for OCPP 1.6, using letters, digits, and `* - _ = : + | @ .`. The password is hashed with argon2 before being stored.

You can also click **Rotate Credentials** on the same tab while the station is online. The CSMS generates a fresh 20-character random password and sends it to the station: `SetVariables(SecurityCtrlr.BasicAuthPassword)` for OCPP 2.1, `ChangeConfiguration(AuthorizationKey)` for OCPP 1.6. It waits up to 35 seconds for the station to accept and saves the new hash only on success. The Security Event Log on the same tab records the rotation.

To move a connected station to a higher security profile later, see [Changing the security profile](https://www.evtivity.com/docs/csms/stations#changing-the-security-profile).

For Mutual TLS:

1. Issue a client certificate signed by the CSMS's trusted CA.
2. Install the cert and private key on the station.
3. The station presents the certificate at the WSS handshake.
4. The CSMS's auth middleware validates the cert against the configured CA chain.

The station record needs `securityProfile: 3` and the cert info appears under **Certificates** on the station detail page after the first successful connection.

## Step 3: Point the station at the CSMS

In the station's configuration UI (varies by vendor, but every OCPP station has one), set the central system URL:

| Profile | URL pattern |
|---|---|
| No Auth / Basic Auth | `ws://<csms-host>/<stationId>` |
| TLS + Basic Auth / Mutual TLS | `wss://<csms-host>:8443/<stationId>` |

The trailing `/<stationId>` is critical — that's how the auth middleware identifies the station. It must match exactly (case-sensitive) what you registered in Step 1.

For Basic Auth and TLS + Basic Auth, the station also needs the username and password. Convention is `username = stationId`, password = the value from Step 2. Some firmwares ask for them as a separate Basic Auth pair; others bake them into the URL like `wss://CS-001:password@host/CS-001`.

In Kubernetes deployments the OCPP service exposes:
- `ocpp.<your-domain>` for plain WS (port 80, upgraded to 443 if TLS terminates at the gateway)
- A separate LoadBalancer on port 8443 for direct TLS (when `ocpp.tls.enabled=true`)

## Step 4: Approve the station (default behavior)

The CSMS has an `ocpp.registrationPolicy` setting with two values:

- `approval-required` **(default)**: new stations land in `pending`. The first BootNotification returns `Pending` and the station polls (per OCPP spec) until you approve it. Recommended for production so unfamiliar hardware doesn't auto-onboard itself.
- `open`: new stations go straight to `onboarding_status = accepted` on creation. The first BootNotification gets `Accepted` and the station is online without operator approval. Convenient for dev/lab; use cautiously in production.

You can change the policy via the dashboard (Settings > Integrations & Features > OCPP), the API (`PUT /v1/settings/ocpp.registrationPolicy`), the Helm chart (`appSettings.ocpp.registrationPolicy` in `values.yaml`), or — at first install — the `REGISTRATION_POLICY` environment variable read by the seed step.

To approve a pending station:

1. Go to **Stations**, filter by **Pending** status.
2. Click the station, review the BootNotification metadata (vendor, model, serial, firmware) reported by the station.
3. Click **Approve**. The CSMS sets `onboarding_status = accepted` and triggers an immediate `BootNotification` cycle so the station goes online without waiting for its next poll.

You can also click **Reject** to set `onboarding_status = blocked` — a stronger reject than denying credentials. A blocked station cannot connect at all: its WebSocket upgrade request is rejected with HTTP 403, even with valid credentials.

## Step 5: Verify it's online

1. **Dashboard**: the station's row should show **Online** (green dot) within seconds of the first successful boot.
2. **OCPP Commands tab**: `BootNotification`, `Heartbeat`, and `StatusNotification` rows should appear in the inbound message log.
3. **Connectors tab**: connector rows reflect the actual hardware (auto-created from the first `StatusNotification` if you didn't pre-define them). Auto-created connectors have no max power. OCPP 2.1 stations fill it in from their configuration report. For OCPP 1.6 stations, edit the EVSE to set it, or load management cannot cap the connector at its rating.
4. **Send a test command**: real stations support the `TriggerMessage` OCPP command. On the station detail page, open the **OCPP Commands** tab, pick `TriggerMessage` from the command list, set the requested message to `StatusNotification`, and click **Send**. The station re-emits a `StatusNotification` immediately so you can confirm round-trip CSMS-to-station messaging works.

## Common issues

**Station retries forever, never connects.** The auth middleware is rejecting it. Check the **Security Event Log** on the station's **Security** tab (after creation) for `auth_failed` events. The most common causes:

- Station ID mismatch — the URL path doesn't match what you registered. The path is case-sensitive.
- Wrong password — for Basic Auth and TLS + Basic Auth.
- Wrong security profile — station configured for Basic Auth but DB record says TLS + Basic Auth (or vice versa).
- TLS handshake failure — for TLS + Basic Auth and Mutual TLS, missing or invalid certificate chain.

**Station connection fails with HTTP 403.** `onboarding_status = blocked`. Unblock from the dashboard.

**Station connects but BootNotification returns `Pending` and stays there.** Registration policy is `approval-required` and you haven't approved yet. Approve from the **Stations** list filtered by Pending.

**Station goes online briefly, then offline.** Heartbeat watchdog is timing out. Check the configured `HeartbeatInterval` value (returned in the BootNotification response) — defaults to 300 seconds. If the station's firmware doesn't honor that interval, set it explicitly via OCPP `ChangeConfiguration` (1.6) or `SetVariables` (2.1).

**Connectors don't appear after the station is online.** Some 1.6 firmware doesn't emit `StatusNotification` for every connector at boot. Either pre-define EVSEs and connectors with **Create EVSE** on the station's **Connectors** tab, or send a `TriggerMessage(StatusNotification)` for each connector ID to force the station to report.

## Next steps

- [Station Management](https://www.evtivity.com/docs/guides/station-management) for the connector status model and operational state.
- [Security profiles](https://www.evtivity.com/docs/configuration/authentication) for choosing between No Auth through Mutual TLS.
- [Load management](https://www.evtivity.com/docs/csms/load-management) and [Pricing](https://www.evtivity.com/docs/csms/pricing) for site-level configuration that applies once the station is online.

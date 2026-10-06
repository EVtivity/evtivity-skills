---
name: evtivity-csms
description: Operate the EVtivity CSMS operator dashboard. Covers every CSMS docs page - dashboard, sites, stations (approval, connectors, availability, security profiles), station images, station configurations (OCPP 1.6 keys, OCPP 2.1 variables, templates), firmware updates, smart charging, load management, free vend, local auth list, display messages, maintenance mode, sessions, drivers, tokens (RFID, authorize log), fleets, pricing (tariffs, tax, split billing), reservations, roaming (OCPI), certificates (Plug and Charge, Mutual TLS), notifications, reports, NEVI compliance, support cases, users (roles, permissions, site access), settings and API keys, access logs, conformance testing and the AI assistant. Use when someone wants to run a charging network in EVtivity, find the dashboard page or permission a task needs, or do an operator task through the dashboard or the API.
license: MIT
metadata:
  evtivity-version: "0.1.39"
  evtivity-release: "v0.1.39-beta.1"
  evtivity-commit: "bd06577f1cf17f235971d9652327b04b768cee81"
  evtivity-docs-section: csms
---

# EVtivity CSMS operator dashboard

The CSMS is the operator dashboard of EVtivity. Operators use it to run sites, stations, drivers, pricing, sessions and settings. Every dashboard action calls the REST API, so each workflow below also works with curl.

The website docs are the source of truth. Each page is named by its id (`csms/<page>`) with its live URL. Read the page before you act on a detail this guide does not cover. Do not guess field names, defaults or behavior.

Related skills:

- evtivity-getting-started: local setup and first sign-in.
- evtivity-configuration: env vars, authentication, database, OCPP server settings.
- evtivity-deployment: Docker, Compose, Helm, AWS, minikube.
- evtivity-api: API keys, sign-in tokens, the route catalog with permissions, error codes.
- evtivity-portal: the driver portal. evtivity-mobile-app: the driver app.
- evtivity-integrations: Stripe, Adyen, the test payment provider, webhooks, energy management.
- evtivity-simulator: simulated charging stations. evtivity-conformance: OCTT and OCPP message testing.
- evtivity-guides: how-to guides (station onboarding, lifecycle, RFID, reservations, smart charging, white-labeling, troubleshooting).
- evtivity-troubleshoot: diagnose a broken stack. evtivity-report-issue: file a bug.

## Confirm before you act

Ask the user before any destructive or customer-visible action, and say what it affects:

- Deletes of any kind (sites, tokens, tariffs, pricing groups, CA certificates, partners, templates, API keys). A station delete blocks the station.
- Deactivating a driver or token, rejecting or blocking a station, disabling a station.
- Maintenance windows, above all with the Stop gracefully policy (it stops live sessions and cancels reservations).
- OCPP Reset, ChangeAvailability, ClearCache, UnlockConnector, remote stop.
- Starting a firmware campaign. Pushing configuration templates, charging profiles or a local auth list.
- Turning free vend on or off at a site.
- Publishing a site or tariff to OCPI partners, registering a partner, issuing a credit CDR.
- Role, permission and site access changes. Revoking an API key (permanent).
- Refunds, cancellation fees, and changes to currency, tax basis or price display.
- Notification template, SMTP, Twilio or webhook changes that reach drivers.

Never print secrets (API keys, station passwords, SMTP or provider credentials) back to the user unless they ask for that value.

## API basics

Get an API key or sign-in token with the evtivity-api skill. The examples use:

```bash
export EVTIVITY_API=http://localhost:7102     # API base URL
export EVTIVITY_TOKEN=<api key or JWT>
auth=(-H "Authorization: Bearer $EVTIVITY_TOKEN" -H 'Content-Type: application/json')
```

- Path `{id}` values are internal ids from list responses (for a station, `id`, not the OCPP `stationId`).
- Lists return `{ data, total }` with `page` and `limit` query parameters.
- A `write` permission includes `read` for the same resource.
- Errors return `{ error, code }`. Look up codes in the evtivity-api skill.

## Router

| Task | Page id and docs | Dashboard page | Permission |
|---|---|---|---|
| Network overview, revenue, profit | csms/dashboard, https://www.evtivity.com/docs/csms/dashboard | Dashboard | `dashboard:read` |
| Create and edit sites, rates, QR codes | csms/sites, https://www.evtivity.com/docs/csms/sites | Sites > site | `sites:write` |
| Register, approve, enable stations | csms/stations, https://www.evtivity.com/docs/csms/stations | Stations > station | `stations:write` |
| Station photos | csms/station-images, https://www.evtivity.com/docs/csms/station-images | Station > Images | `stations:write` |
| Configuration templates and drift | csms/station-configurations, https://www.evtivity.com/docs/csms/station-configurations | Settings > Station Configurations | `settings.stationConfig:write` |
| OCPP 1.6 key reference | csms/station-configurations-ocpp16, https://www.evtivity.com/docs/csms/station-configurations-ocpp16 | Station > Configurations | `stations:read` |
| OCPP 2.1 variable reference | csms/station-configurations-ocpp21, https://www.evtivity.com/docs/csms/station-configurations-ocpp21 | Station > Configurations | `stations:read` |
| Firmware campaigns, signed firmware | csms/firmware-updates, https://www.evtivity.com/docs/csms/firmware-updates | Settings > Firmware Campaign | `settings.firmware:write` |
| Charging profile templates | csms/smart-charging, https://www.evtivity.com/docs/csms/smart-charging | Settings > Smart Charging | `smartCharging:write` (tab: `settings.smartCharging:read`) |
| Panels, circuits, power allocation | csms/load-management, https://www.evtivity.com/docs/csms/load-management | Site > Load Mgmt | `loadManagement:write` |
| Charge without ID or payment | csms/free-vend, https://www.evtivity.com/docs/csms/free-vend | Site > Free Vend | `sites:write` |
| Offline token list on a station | csms/local-auth-list, https://www.evtivity.com/docs/csms/local-auth-list | Station > Local Auth List | `stations:write` |
| Station screen messages | csms/display-messages, https://www.evtivity.com/docs/csms/display-messages | Station > Display Messages | `stations:write` |
| Planned maintenance windows | csms/maintenance, https://www.evtivity.com/docs/csms/maintenance | Site > Maintenance | `maintenance:write` |
| Session status, cost, refunds | csms/sessions, https://www.evtivity.com/docs/csms/sessions | Sessions > session | `sessions:read`, refunds `payments:write` |
| Driver accounts, portal invite, invoices | csms/drivers, https://www.evtivity.com/docs/csms/drivers | Drivers > driver | `drivers:write` |
| RFID cards and app tokens | csms/tokens, https://www.evtivity.com/docs/csms/tokens | Tokens | `drivers:write` |
| Fleets and bulk reservations | csms/fleets, https://www.evtivity.com/docs/csms/fleets | Fleets > fleet | `fleets:write`, `reservations:write` |
| Pricing groups, tariffs, holidays | csms/pricing, https://www.evtivity.com/docs/csms/pricing | Pricing | `pricing:write` |
| Reservations and fees | csms/reservations, https://www.evtivity.com/docs/csms/reservations | Reservations | `reservations:write` |
| OCPI partners, locations, CDRs | csms/roaming, https://www.evtivity.com/docs/csms/roaming | Roaming | `roaming:write` |
| Plug and Charge and Mutual TLS PKI | csms/certificates, https://www.evtivity.com/docs/csms/certificates | Certificates | `certificates:write` |
| Notification templates and history | csms/notifications, https://www.evtivity.com/docs/csms/notifications | Notifications | `notifications:write` |
| Financial, energy, sustainability reports | csms/reports, https://www.evtivity.com/docs/csms/reports | Reports | `reports:read`, generate `reports:write` |
| NEVI uptime and excluded downtime | csms/nevi-compliance, https://www.evtivity.com/docs/csms/nevi-compliance | Reports | `reports:write` |
| Driver support tickets | csms/support-cases, https://www.evtivity.com/docs/csms/support-cases | Support Cases | `support:write` |
| Operator users, roles, site access | csms/users, https://www.evtivity.com/docs/csms/users | Users | `users:write` |
| System configuration, API keys | csms/settings, https://www.evtivity.com/docs/csms/settings | Settings > tab | `settings.<tab>:write` |
| Request and worker logs | csms/access-logs, https://www.evtivity.com/docs/csms/access-logs | Access Logs | `logs:read` |
| OCTT conformance runs | csms/conformance-testing, https://www.evtivity.com/docs/csms/conformance-testing | Settings > Conformance | `conformance:write` |
| Natural-language questions | csms/ai-assistant, https://www.evtivity.com/docs/csms/ai-assistant | Chatbot AI button | `settings.ai:write` to configure |

Permission names come from the CSMS code. Default roles: admin has all, operator has operational read and write without settings or `users:write`, viewer is read only.

## Core workflows

### Create a site and a station

Docs: csms/sites (https://www.evtivity.com/docs/csms/sites), csms/stations (https://www.evtivity.com/docs/csms/stations).

1. Sites > Create Site. Enter name and address, optionally coordinates, contact info and hours.
2. On the site: set the carbon region (CO2 tracking), the Electricity Rates periods (cost and profit), and the Pricing tab.
3. Stations > Create Station. The station ID must equal the identity the charger uses on its OCPP connection. Pick OCPP 1.6 or 2.1, site, vendor, model and security profile. Add EVSEs and connectors with power ratings.
4. Configure the charger with the OCPP URL shown on the station Details tab (and the password for Basic Auth profiles).

```bash
curl -s "$EVTIVITY_API/v1/sites" "${auth[@]}" -d '{"name":"Main Garage","address":"1 Main St","city":"Austin","timezone":"America/Chicago"}'
curl -s "$EVTIVITY_API/v1/stations" "${auth[@]}" \
  -d '{"stationId":"CS-001","ocppProtocol":"ocpp2.1","siteId":"<site id>","securityProfile":1,"password":"<16-40 chars>"}'
```

Confirm: the station list shows the station online after the charger connects. On OCPP 1.6, each connector is EVSE N with connector N (`CONNECTOR_ID_MISMATCH` otherwise). Set a max power on every connector. A **Max power unknown** badge means load management cannot cap it at its rating.

### Approve a station

New stations start `pending`: they connect but cannot charge. When **Require approval for new stations** is off (Settings > Integrations & Features > OCPP), stations are auto-accepted.

- Station detail > **Approve** sets `accepted`. **Reject** sets `blocked` and drops the connection. **Unblock** returns it to `pending`.
- Delete never removes a station. It blocks it and keeps history.

```bash
curl -s "$EVTIVITY_API/v1/stations?onboardingStatus=pending" "${auth[@]}"
curl -s -X POST "$EVTIVITY_API/v1/stations/<id>/approve" "${auth[@]}"
```

Confirm: `onboardingStatus` is `accepted` in `GET /v1/stations/<id>`.

### Connectors and availability

Docs: csms/stations (https://www.evtivity.com/docs/csms/stations).

- **Disable Station** sends ChangeAvailability(Inoperative). Running sessions continue. It survives reboots until **Enable Station**.
- Enable also clears a failed firmware install.
- API: `PATCH /v1/stations/<id>` with `{"availability":"unavailable"}` or `"available"`. `faulted` is computed and rejected with 400.
- Read `statusReason` and `reportedStatus` to learn why a station is unavailable or faulted.
- A critical security event auto-disables a station when `security.autoDisableOnCritical` is on (default).
- Commands to an offline station return `202 COMMAND_QUEUED` and run on reconnect.
- Security tab: rotate the password or raise the security profile. Lowering the profile of an online station is refused.

Confirm: the status badge and its hover reason, and the station History tab (it records each command dispatch).

### Maintenance windows

Docs: csms/maintenance (https://www.evtivity.com/docs/csms/maintenance).

1. Site > Maintenance > **Schedule maintenance**. Choose Now or Scheduled, the end time, stations (all or a subset), message, reason and the session policy.
2. The worker sends ChangeAvailability(Inoperative), shows the maintenance message, cancels overlapping reservations without a fee, and with **Stop gracefully** stops sessions. At the end it restores the stations.

```bash
curl -s "$EVTIVITY_API/v1/sites/<siteId>/maintenance/events" "${auth[@]}" \
  -d '{"eventType":"one_off","plannedStartAt":"2026-10-10T02:00:00Z","plannedEndAt":"2026-10-10T04:00:00Z","activeSessionPolicy":"ignore","reason":"Panel work"}'
```

Confirm: the Maintenance History columns Taken Offline, Re-asserted and Restored (green means every station accepted). Open the row for per-station results. A yellow badge or `failed` result needs a look at Current Status. Reservations in the window fail with `409 RESERVATION_DURING_MAINTENANCE`. For one station with no end time, use Disable Station instead.

### Drivers

Docs: csms/drivers (https://www.evtivity.com/docs/csms/drivers).

- Drivers > Create Driver (name, email, phone, language). Emails are unique, case-insensitive (`409 DUPLICATE_EMAIL`).
- Portal access: **Invite to Driver Portal** sends a one-time link valid for 7 days. `POST /v1/drivers/<id>/portal-invite`. The card then shows Invited, then Active.
- Deactivating or deleting a driver deactivates all its tokens. Reactivation does not reactivate tokens.
- Invoices: **Generate Invoice** groups completed, uninvoiced sessions for a date range.
- The Authorize Log tab explains rejected cards (blocked, expired, concurrent_tx, no_credit).

Confirm: `GET /v1/drivers/<id>` shows `portalAccess.status`.

### Tokens and fleets

Docs: csms/tokens (https://www.evtivity.com/docs/csms/tokens), csms/fleets (https://www.evtivity.com/docs/csms/fleets), csms/local-auth-list (https://www.evtivity.com/docs/csms/local-auth-list).

- Tokens > Create Token: driver, type, value (RFID UID, 4 to 20 alphanumeric characters).
- Toggle inactive to block a card. Delete is a hard delete and fails with `409 TOKEN_IN_USE` during an active session.
- One token cannot run two sessions at once (`ConcurrentTx`).
- Fleets > Create Fleet, then add drivers and a pricing group. A driver in several fleets gets the oldest membership's pricing.
- Bulk Reservations on a fleet reserve one connector per station. Failed slots do not roll back the rest.
- Local auth list: add and remove tokens (database only), then push. Every push sends the full list (SendLocalList Full). Deactivated tokens go as `Blocked`.

Confirm: the token Authorize Log tab or `/tokens/authorize-log` shows the outcome of the next tap. The local auth list banner clears after a push.

### Pricing groups and tariffs

Docs: csms/pricing (https://www.evtivity.com/docs/csms/pricing).

1. Pricing > Create Pricing Group. Mark one group as default.
2. Create Tariff: per kWh, per minute, per session, idle fee per minute, reservation fee per minute, tax rate.
3. Assign the group on a driver, fleet, station or site Pricing tab. Priority: driver, fleet, station, site, default group.

Rules that trip agents:

- Tax rate is a fraction from 0 to 1. Enter `0.0825` for 8.25%.
- Whether prices include tax depends on Settings > Company Info > **Tariff prices are entered** (`company.taxBasis`). Changing it does not convert existing prices.
- Restriction priorities: default 0, time 10, day and time 20, date range 30, holiday 40, energy threshold 50. Same-level overlaps are rejected.
- Energy-threshold tariffs bill only with split billing (`pricing.splitBillingEnabled`).
- A tariff referenced by any session cannot be deleted (`409 TARIFF_IN_USE`).
- Tariffs have no currency. The company currency applies.

Confirm: the group Schedule tab, and the station Pricing tab or `GET /v1/stations/<id>/active-tariff`.

### Reservations

Docs: csms/reservations (https://www.evtivity.com/docs/csms/reservations).

- Reservations > Create Reservation: station, EVSE, driver, start and expiry. A future start is `scheduled` and sent at start time. Otherwise ReserveNow goes out now.
- Enablement is global (`reservation.enabled`), per site and per station. Any off returns `403 RESERVATION_DISABLED`.
- A driver reservation needs a default card (`400 PAYMENT_METHOD_REQUIRED`).
- Window errors: `RESERVATION_WINDOW_TOO_SHORT`, `RESERVATION_EXPIRES_TOO_SOON`, `RESERVATION_STARTS_IN_PAST`, `RESERVATION_TOO_LONG` (`reservation.maxHours`, default 3), `RESERVATION_CONFLICT`.
- Operator cancels charge a fee only when **Charge cancellation fee** is ticked and the cancel falls inside the window.

Confirm: status `active` and the OCPP Logs tab of the reservation.

### Smart charging and load management

Docs: csms/smart-charging (https://www.evtivity.com/docs/csms/smart-charging), csms/load-management (https://www.evtivity.com/docs/csms/load-management).

- Smart charging: Settings > Smart Charging > Create. Pick a purpose (ChargingStationMaxProfile, TxDefaultProfile, PriorityCharging, LocalGeneration), Absolute or Recurring, stack level, periods and a target filter. Check **Matching Stations**, then **Push to Stations**.
- Load management: Site > Load Mgmt. Add panels and circuits, assign stations to circuits, add unmanaged loads. Toggle **Enable Load Management** and pick Equal Share or Priority Based (priority 1 to 10, default 5).
- Load management uses ChargingStationExternalConstraints every 10 seconds. The station applies the lowest limit of all profiles.
- Stations without a circuit are not managed.

Confirm: push history per station (Accepted, Rejected, Failed). Load Mgmt power bar and allocation history. Station > Charging Profiles > View Composite Schedule.

### Notifications and display messages

Docs: csms/notifications (https://www.evtivity.com/docs/csms/notifications), csms/display-messages (https://www.evtivity.com/docs/csms/display-messages).

- Set up SMTP and Twilio first (Settings > Notification). Use **Send Test**.
- Notifications page: edit Driver and System event templates (Handlebars). OCPP events are off until you set a channel (email or webhook) and recipient.
- Webhooks to private addresses are blocked unless listed in **Allowed private webhook hosts**.
- History tab: a `failed` row shows the reason (for example SMTP not configured).
- Display messages (OCPP 2.1 only): Station > Display Messages to send, clear or refresh. Automatic per-state screens: **Enable Station Messages** under Settings > Integrations & Features > Messages.

Confirm: History rows show `sent`. A display message moves from `pending` to `accepted`.

### Roaming (OCPI)

Docs: csms/roaming (https://www.evtivity.com/docs/csms/roaming).

1. Enable Roaming and set country code, party ID and business name in Settings > Integrations & Features.
2. Roaming > Partners > Create Partner. Share the generated registration token, or click **Register** with their versions URL.
3. Roaming > Locations: toggle **Published** per site. Roaming > Tariffs: Create Mapping from a tariff or pricing group.

API only: credit a CDR with `POST /v1/ocpi/cdrs/credit` (`originalCdrId`, `reason`). Pull a module with `POST /v1/ocpi/partners/<id>/sync/<locations|tariffs|cdrs|tokens>`.

Confirm: partner status `Connected`. CDR push status in Roaming > CDRs.

### Certificates and Plug and Charge

Docs: csms/certificates (https://www.evtivity.com/docs/csms/certificates).

- Enable Plug & Charge in Settings > Integrations & Features > Plug & Charge. Pick Hubject, Manual or Local and click **Test Connection**. While off, the Certificates page is hidden and its routes return 403.
- CA Certificates: upload PEM. CSR Requests: sign pending CSRs (Manual) by pasting the signed PEM.
- Local contract CA: set eMAID country and provider, **Create contract CA**, upload each OEM root as `OEMRootCertificate`, then create a Plug & Charge contract on the driver.
- Mutual TLS renewal (`SignCertificate` with `ChargingStationCertificate`) works without the toggle.

Confirm: CSR status `Signed`, the station Certificates tab inventory.

### Reports and NEVI

Docs: csms/reports (https://www.evtivity.com/docs/csms/reports), csms/nevi-compliance (https://www.evtivity.com/docs/csms/nevi-compliance).

- Reports > Generate: Revenue, Utilization, Energy, Station Health, Sessions, Sustainability, Driver Activity or NEVI Compliance as CSV, PDF or XLSX. Schedules email them daily, weekly or monthly.
- CO2 needs a carbon region on each site.
- NEVI requires 97% uptime. Record excluded downtime per station so approved outages do not count. API under `/v1/nevi/`.

```bash
curl -s "$EVTIVITY_API/v1/nevi/excluded-downtime" "${auth[@]}"
```

Confirm: the run appears on the History tab and downloads.

### Users and roles

Docs: csms/users (https://www.evtivity.com/docs/csms/users).

- Users > Create User: name, email, mobile, password, role. Role defaults are copied, then edit on the Permissions tab. Users cannot edit their own permissions.
- New users see nothing until you grant **All sites** or specific sites under Site Access.
- Drivers, tokens, fleets, pricing, settings and roaming are not filtered by site access.

Confirm: `GET /v1/users/<id>/permissions`.

### Settings tabs

Docs: csms/settings (https://www.evtivity.com/docs/csms/settings).

Tabs and permissions: Company Info, Marketing, Content and Sustainability (`settings.system`). Notification (`settings.notification`). Payment (`settings.payment`, plus `payments:write` for provider actions). Integrations & Features (`settings.integrations`): OCPP, Roaming, Plug & Charge, Reservation, Support, Fleet, Guest Charging, Idling, Session, Pricing, Messages, S3, FTP, Google Maps, Sentry. Security (`settings.security`): reCAPTCHA, MFA, SSO. API Keys (`settings.apiKeys`). Firmware Campaign, Station Configurations, Smart Charging, AI, Conformance.

- Company currency is one value for the platform. Changing it does not relabel past records.
- API keys show the token once. Revoking is permanent.
- Payment provider setup: evtivity-integrations.

Confirm: reload the tab. Test buttons exist for SMTP, Twilio, Stripe, Adyen, S3 and PnC providers.

### Firmware and station configurations

Docs: csms/firmware-updates (https://www.evtivity.com/docs/csms/firmware-updates), csms/station-configurations (https://www.evtivity.com/docs/csms/station-configurations), csms/station-configurations-ocpp16 (https://www.evtivity.com/docs/csms/station-configurations-ocpp16), csms/station-configurations-ocpp21 (https://www.evtivity.com/docs/csms/station-configurations-ocpp21).

- Firmware: Settings > Firmware Campaign > Create (name, HTTPS firmware URL, version, optional signing certificate and signature, set both or neither). Filter by site, vendor, model. Start Campaign sends UpdateFirmware to online stations. Many OCPP 2.1 stations reject unsigned updates.
- Single station: Station > OCPP Commands > Update Firmware.
- A failed install marks the station faulted until the next install or **Enable Station**.
- Configuration templates are bound to one OCPP version. 1.6 uses keys (ChangeConfiguration), 2.1 uses component and variable (SetVariables). Push, then the CSMS refreshes and checks drift.
- Station > Configurations > **Refresh from Station** reads the live values. Vendor keys are not validated, so a typo returns `Rejected`.

Confirm: campaign station statuses reach Installed. Template push history shows Accepted per station.

### Free vend

Docs: csms/free-vend (https://www.evtivity.com/docs/csms/free-vend).

Site > Free Vend toggle. Any token is accepted, payment is skipped, and config templates (AuthCtrlr.Enabled false, TxStartPoint EVConnected, or 1.6 best-effort keys) go to online stations. No pricing group is needed. Turning it off does not revert station configuration: edit or remove the generated templates.

Confirm: Free Vend badge on station cards and the Free Vend label on sessions.

### Sessions and refunds

Docs: csms/sessions (https://www.evtivity.com/docs/csms/sessions).

- Sessions list filters by status, station, site, driver and date. The detail page has Details, Meter Values and Payment tabs.
- Refund from the Payment tab (full or partial) on captured payments: `POST /v1/sessions/<id>/refund`. Adyen refunds stay pending until the provider confirms.

```bash
curl -s "$EVTIVITY_API/v1/sessions?status=active" "${auth[@]}"
```

### Audit and access logs

Docs: csms/access-logs (https://www.evtivity.com/docs/csms/access-logs).

- Access Logs tabs: CSMS, Portal, API, Workers. `GET /v1/access-logs`, `GET /v1/worker-logs`.
- Each entity has a History tab. The global audit page is `/audit` (`GET /v1/audit`, `audit:read`).
- Retention: `logs.*.retentionDays` settings, pruned daily at 03:30 UTC. 0 disables pruning.

### Station images

Docs: csms/station-images (https://www.evtivity.com/docs/csms/station-images).

Station > Images: upload (10 MB max, needs S3 configured in Settings), set the main image, tag, caption, reorder, and mark driver-visible for the portal.

### Support cases and the AI assistant

Docs: csms/support-cases (https://www.evtivity.com/docs/csms/support-cases), csms/ai-assistant (https://www.evtivity.com/docs/csms/ai-assistant).

- Support Cases > Create Case: category, priority, subject, description, linked sessions. Public messages reach the driver. Internal notes do not.
- Refund a linked session from the case (`captured` or `partially_refunded` only). `POST /v1/support-cases/<id>/refund`.
- AI Draft writes a reply for review and never sends it.
- AI assistant: enable in Settings > AI (Anthropic, OpenAI or Gemini). Personal keys in Profile override it. It acts with the user's permissions and asks before changes. Limit 10 requests per minute per user.

### Conformance testing

Docs: csms/conformance-testing (https://www.evtivity.com/docs/csms/conformance-testing).

Settings > Conformance: choose OCPP 2.1, OCPP 1.6 or Run All Tests, then **Run Tests**. Results stream per module (passed, failed, skipped, error). API: `POST /v1/octt/runs`, `GET /v1/octt/runs/<id>/summary`. For the command line runner, use evtivity-conformance.

## Reference pages

Every docs page this skill covers is in `references/`, generated from the website docs. Never edit those files. Read the reference for details, and link the live page when you answer.

| Page id | Reference | Live page |
|---|---|---|
| `csms/access-logs` | `references/access-logs.md` | https://www.evtivity.com/docs/csms/access-logs |
| `csms/ai-assistant` | `references/ai-assistant.md` | https://www.evtivity.com/docs/csms/ai-assistant |
| `csms/certificates` | `references/certificates.md` | https://www.evtivity.com/docs/csms/certificates |
| `csms/conformance-testing` | `references/conformance-testing.md` | https://www.evtivity.com/docs/csms/conformance-testing |
| `csms/dashboard` | `references/dashboard.md` | https://www.evtivity.com/docs/csms/dashboard |
| `csms/display-messages` | `references/display-messages.md` | https://www.evtivity.com/docs/csms/display-messages |
| `csms/drivers` | `references/drivers.md` | https://www.evtivity.com/docs/csms/drivers |
| `csms/firmware-updates` | `references/firmware-updates.md` | https://www.evtivity.com/docs/csms/firmware-updates |
| `csms/fleets` | `references/fleets.md` | https://www.evtivity.com/docs/csms/fleets |
| `csms/free-vend` | `references/free-vend.md` | https://www.evtivity.com/docs/csms/free-vend |
| `csms/load-management` | `references/load-management.md` | https://www.evtivity.com/docs/csms/load-management |
| `csms/local-auth-list` | `references/local-auth-list.md` | https://www.evtivity.com/docs/csms/local-auth-list |
| `csms/maintenance` | `references/maintenance.md` | https://www.evtivity.com/docs/csms/maintenance |
| `csms/nevi-compliance` | `references/nevi-compliance.md` | https://www.evtivity.com/docs/csms/nevi-compliance |
| `csms/notifications` | `references/notifications.md` | https://www.evtivity.com/docs/csms/notifications |
| `csms/pricing` | `references/pricing.md` | https://www.evtivity.com/docs/csms/pricing |
| `csms/reports` | `references/reports.md` | https://www.evtivity.com/docs/csms/reports |
| `csms/reservations` | `references/reservations.md` | https://www.evtivity.com/docs/csms/reservations |
| `csms/roaming` | `references/roaming.md` | https://www.evtivity.com/docs/csms/roaming |
| `csms/sessions` | `references/sessions.md` | https://www.evtivity.com/docs/csms/sessions |
| `csms/settings` | `references/settings.md` | https://www.evtivity.com/docs/csms/settings |
| `csms/sites` | `references/sites.md` | https://www.evtivity.com/docs/csms/sites |
| `csms/smart-charging` | `references/smart-charging.md` | https://www.evtivity.com/docs/csms/smart-charging |
| `csms/station-configurations-ocpp16` | `references/station-configurations-ocpp16.md` | https://www.evtivity.com/docs/csms/station-configurations-ocpp16 |
| `csms/station-configurations-ocpp21` | `references/station-configurations-ocpp21.md` | https://www.evtivity.com/docs/csms/station-configurations-ocpp21 |
| `csms/station-configurations` | `references/station-configurations.md` | https://www.evtivity.com/docs/csms/station-configurations |
| `csms/station-images` | `references/station-images.md` | https://www.evtivity.com/docs/csms/station-images |
| `csms/stations` | `references/stations.md` | https://www.evtivity.com/docs/csms/stations |
| `csms/support-cases` | `references/support-cases.md` | https://www.evtivity.com/docs/csms/support-cases |
| `csms/tokens` | `references/tokens.md` | https://www.evtivity.com/docs/csms/tokens |
| `csms/users` | `references/users.md` | https://www.evtivity.com/docs/csms/users |

---
name: evtivity-csms
description: "Operate the EVtivity operator dashboard: sites, stations, sessions, drivers, RFID tokens, fleets, pricing groups and tariffs, reservations, smart charging, load management, roaming, reports, users, roles, settings. Use for daily operator tasks in the dashboard. Not for payment provider setup (evtivity-integrations) or scripts (evtivity-api)."
license: MIT
metadata:
  evtivity-version: "0.1.39"
  evtivity-release: "v0.1.39-beta.2"
  evtivity-commit: "f3bd9ac5d1e82239328452b703111a5dabba6b3c"
  evtivity-docs-section: csms
---

# EVtivity CSMS operator dashboard

Not for: Stripe, Adyen or payment webhooks (use evtivity-integrations), scripts and the route catalog (use evtivity-api), end-to-end procedures such as onboarding a station (use evtivity-guides), a broken stack (use evtivity-troubleshoot).

The CSMS is the operator dashboard of EVtivity. Every dashboard action calls the REST API, so each workflow below also works with curl. The website docs are the source of truth: read the reference before you act on a detail this guide does not cover. Do not guess field names, defaults or behavior.

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

Never print secrets (API keys, station passwords, SMTP or provider credentials) unless the user asks for that value.

## API basics

Get an API key with the evtivity-api skill. The examples use:

```bash
export EVTIVITY_API=http://localhost:7102     # API base URL
export EVTIVITY_TOKEN=<api key or JWT>
auth=(-H "Authorization: Bearer $EVTIVITY_TOKEN" -H 'Content-Type: application/json')
```

Path `{id}` values are internal ids from list responses (for a station, `id`, not the OCPP `stationId`). Lists return `{ data, total }` with `page` and `limit`. A `write` permission includes `read`. Errors return `{ error, code }`.

## Router

Each row names the reference file for the page (page id `csms/<name>`).

| Task | Reference | Dashboard page | Permission |
|---|---|---|---|
| Network overview, revenue, profit | `references/dashboard.md` | Dashboard | `dashboard:read` |
| Create and edit sites, rates, QR codes | `references/sites.md` | Sites > site | `sites:write` |
| Register, approve, enable stations | `references/stations.md` | Stations > station | `stations:write` |
| Station photos | `references/station-images.md` | Station > Images | `stations:write` |
| Configuration templates and drift | `references/station-configurations.md` | Settings > Station Configurations | `settings.stationConfig:write` |
| OCPP 1.6 key reference | `references/station-configurations-ocpp16.md` | Station > Configurations | `stations:read` |
| OCPP 2.1 variable reference | `references/station-configurations-ocpp21.md` | Station > Configurations | `stations:read` |
| Firmware campaigns, signed firmware | `references/firmware-updates.md` | Settings > Firmware Campaign | `settings.firmware:write` |
| Charging profile templates | `references/smart-charging.md` | Settings > Smart Charging | `smartCharging:write` (tab: `settings.smartCharging:read`) |
| Panels, circuits, power allocation | `references/load-management.md` | Site > Load Mgmt | `loadManagement:write` |
| Charge without ID or payment | `references/free-vend.md` | Site > Free Vend | `sites:write` |
| Offline token list on a station | `references/local-auth-list.md` | Station > Local Auth List | `stations:write` |
| Station screen messages | `references/display-messages.md` | Station > Display Messages | `stations:write` |
| Planned maintenance windows | `references/maintenance.md` | Site > Maintenance | `maintenance:write` |
| Session status, cost, refunds | `references/sessions.md` | Sessions > session | `sessions:read`, refunds `payments:write` |
| Driver accounts, portal invite, invoices | `references/drivers.md` | Drivers > driver | `drivers:write` |
| RFID cards and app tokens | `references/tokens.md` | Tokens | `drivers:write` |
| Fleets and bulk reservations | `references/fleets.md` | Fleets > fleet | `fleets:write`, `reservations:write` |
| Pricing groups, tariffs, holidays | `references/pricing.md` | Pricing | `pricing:write` |
| Reservations and fees | `references/reservations.md` | Reservations | `reservations:write` |
| OCPI partners, locations, CDRs | `references/roaming.md` | Roaming | `roaming:write` |
| Plug and Charge and Mutual TLS PKI | `references/certificates.md` | Certificates | `certificates:write` |
| Notification templates and history | `references/notifications.md` | Notifications | `notifications:write` |
| Financial, energy, sustainability reports | `references/reports.md` | Reports | `reports:read`, generate `reports:write` |
| NEVI uptime and excluded downtime | `references/nevi-compliance.md` | Reports | `reports:write` |
| Driver support tickets | `references/support-cases.md` | Support Cases | `support:write` |
| Operator users, roles, site access | `references/users.md` | Users | `users:write` |
| System configuration, API keys | `references/settings.md` | Settings > tab | `settings.<tab>:write` |
| Request and worker logs | `references/access-logs.md` | Access Logs | `logs:read` |
| OCTT conformance runs | `references/conformance-testing.md` | Settings > Conformance | `conformance:write` |
| Natural-language questions | `references/ai-assistant.md` | Chatbot AI button | `settings.ai:write` to configure |

Default roles: admin has all permissions, operator has operational read and write without settings or `users:write`, viewer is read only. `references/settings.md` is long: grep it for the tab or setting key.

## Core workflows

### Create a site and a station (`references/sites.md`, `references/stations.md`)

1. Sites > Create Site. Enter name and address, optionally coordinates, contact info and hours.
2. On the site: set the carbon region (CO2 tracking), the Electricity Rates periods (cost and profit), and the Pricing tab.
3. Stations > Create Station. The station ID must equal the identity the charger uses on its OCPP connection. Pick OCPP 1.6 or 2.1, site, vendor, model and security profile. Add EVSEs and connectors with power ratings.
4. Configure the charger with the OCPP URL shown on the station Details tab (and the password for Basic Auth profiles).

```bash
curl -s "$EVTIVITY_API/v1/sites" "${auth[@]}" -d '{"name":"Main Garage","address":"1 Main St","city":"Austin","timezone":"America/Chicago"}'
curl -s "$EVTIVITY_API/v1/stations" "${auth[@]}" \
  -d '{"stationId":"CS-001","ocppProtocol":"ocpp2.1","siteId":"<site id>","securityProfile":1,"password":"<16-40 chars>"}'
```

Confirm: the station list shows the station online after the charger connects. On OCPP 1.6, each connector is EVSE N with connector N (`CONNECTOR_ID_MISMATCH` otherwise). Set a max power on every connector: a **Max power unknown** badge means load management cannot cap it at its rating.

### Approve, connectors and availability (`references/stations.md`)

- New stations start `pending`: they connect but cannot charge. When **Require approval for new stations** is off (Settings > Integrations & Features > OCPP), stations are auto-accepted.
- **Approve** sets `accepted`. **Reject** sets `blocked` and drops the connection. **Unblock** returns it to `pending`. Delete never removes a station: it blocks it and keeps history.
- **Disable Station** sends ChangeAvailability(Inoperative). Running sessions continue. It survives reboots until **Enable Station**, which also clears a failed firmware install.
- API: `POST /v1/stations/<id>/approve`, `PATCH /v1/stations/<id>` with `{"availability":"unavailable"}` or `"available"` (`faulted` is computed and rejected with 400). Read `statusReason` and `reportedStatus` to learn why a station is unavailable or faulted.
- A critical security event auto-disables a station when `security.autoDisableOnCritical` is on (default). Commands to an offline station return `202 COMMAND_QUEUED` and run on reconnect.
- Security tab: rotate the password or raise the security profile. Lowering the profile of an online station is refused.

```bash
curl -s "$EVTIVITY_API/v1/stations?onboardingStatus=pending" "${auth[@]}"
curl -s -X POST "$EVTIVITY_API/v1/stations/<id>/approve" "${auth[@]}"
```

Confirm: `onboardingStatus` is `accepted` in `GET /v1/stations/<id>`, the status badge and its hover reason, the station History tab.

### Maintenance windows (`references/maintenance.md`)

1. Site > Maintenance > **Schedule maintenance**. Choose Now or Scheduled, the end time, stations, message, reason and the session policy.
2. The worker sends ChangeAvailability(Inoperative), shows the message, cancels overlapping reservations without a fee, and with **Stop gracefully** stops sessions. At the end it restores the stations.

```bash
curl -s "$EVTIVITY_API/v1/sites/<siteId>/maintenance/events" "${auth[@]}" \
  -d '{"eventType":"one_off","plannedStartAt":"2026-10-10T02:00:00Z","plannedEndAt":"2026-10-10T04:00:00Z","activeSessionPolicy":"ignore","reason":"Panel work"}'
```

Confirm: the Maintenance History columns Taken Offline, Re-asserted and Restored (green means every station accepted). Reservations in the window fail with `409 RESERVATION_DURING_MAINTENANCE`. For one station with no end time, use Disable Station instead.

### Drivers, tokens and fleets (`references/drivers.md`, `references/tokens.md`, `references/fleets.md`, `references/local-auth-list.md`)

- Drivers > Create Driver (name, email, phone, language). Emails are unique, case-insensitive (`409 DUPLICATE_EMAIL`).
- **Invite to Driver Portal** sends a one-time link valid for 7 days (`POST /v1/drivers/<id>/portal-invite`). `GET /v1/drivers/<id>` shows `portalAccess.status`.
- Deactivating or deleting a driver deactivates all its tokens. Reactivation does not reactivate tokens. **Generate Invoice** groups completed, uninvoiced sessions for a date range.
- Tokens > Create Token: driver, type, value (RFID UID, 4 to 20 alphanumeric characters). Toggle inactive to block a card. Delete is a hard delete and fails with `409 TOKEN_IN_USE` during a session. One token cannot run two sessions at once (`ConcurrentTx`).
- The Authorize Log tab explains rejected cards (blocked, expired, concurrent_tx, no_credit).
- Fleets > Create Fleet, then add drivers and a pricing group. A driver in several fleets gets the oldest membership's pricing. Bulk Reservations reserve one connector per station. Failed slots do not roll back the rest.
- Local auth list: add and remove tokens (database only), then push. Every push sends the full list. Deactivated tokens go as `Blocked`.

### Pricing groups and tariffs (`references/pricing.md`)

1. Pricing > Create Pricing Group. Mark one group as default.
2. Create Tariff: per kWh, per minute, per session, idle fee per minute, reservation fee per minute, tax rate.
3. Assign the group on a driver, fleet, station or site Pricing tab. Priority: driver, fleet, station, site, default group.

Rules that trip agents:

- Tax rate is a fraction from 0 to 1. Enter `0.0825` for 8.25%.
- Whether prices include tax depends on Settings > Company Info > **Tariff prices are entered** (`company.taxBasis`). Changing it does not convert existing prices.
- Restriction priorities: default 0, time 10, day and time 20, date range 30, holiday 40, energy threshold 50. Same-level overlaps are rejected.
- Energy-threshold tariffs bill only with split billing (`pricing.splitBillingEnabled`).
- A tariff referenced by any session cannot be deleted (`409 TARIFF_IN_USE`). Tariffs have no currency: the company currency applies.

Confirm: the group Schedule tab, and the station Pricing tab or `GET /v1/stations/<id>/active-tariff`. A curl example of a tariff is in the evtivity-api skill.

### Reservations (`references/reservations.md`)

- Reservations > Create Reservation: station, EVSE, driver, start and expiry. A future start is `scheduled` and sent at start time. Otherwise ReserveNow goes out now.
- Enablement is global (`reservation.enabled`), per site and per station. Any off returns `403 RESERVATION_DISABLED`. A driver reservation needs a default card (`400 PAYMENT_METHOD_REQUIRED`).
- Window errors: `RESERVATION_WINDOW_TOO_SHORT`, `RESERVATION_EXPIRES_TOO_SOON`, `RESERVATION_STARTS_IN_PAST`, `RESERVATION_TOO_LONG` (`reservation.maxHours`, default 3), `RESERVATION_CONFLICT`.
- Operator cancels charge a fee only when **Charge cancellation fee** is ticked and the cancel falls inside the window.

### Smart charging and load management (`references/smart-charging.md`, `references/load-management.md`)

- Smart charging: Settings > Smart Charging > Create. Pick a purpose (ChargingStationMaxProfile, TxDefaultProfile, PriorityCharging, LocalGeneration), Absolute or Recurring, stack level, periods and a target filter. Check **Matching Stations**, then **Push to Stations**.
- Load management: Site > Load Mgmt. Add panels and circuits, assign stations to circuits, add unmanaged loads. Toggle **Enable Load Management** and pick Equal Share or Priority Based (priority 1 to 10, default 5). Stations without a circuit are not managed.
- Load management uses ChargingStationExternalConstraints every 10 seconds. The station applies the lowest limit of all profiles.

Confirm: push history per station (Accepted, Rejected, Failed), the Load Mgmt power bar and allocation history, Station > Charging Profiles > View Composite Schedule.

### Notifications and display messages (`references/notifications.md`, `references/display-messages.md`)

- Set up SMTP and Twilio first (Settings > Notification) and use **Send Test**.
- Notifications page: edit Driver and System event templates (Handlebars). OCPP events are off until you set a channel (email or webhook) and recipient. Webhooks to private addresses are blocked unless listed in **Allowed private webhook hosts**.
- History tab: a `failed` row shows the reason (for example SMTP not configured).
- Display messages (OCPP 2.1 only): Station > Display Messages to send, clear or refresh. Automatic per-state screens: **Enable Station Messages** under Settings > Integrations & Features > Messages.

### Roaming, certificates, reports (`references/roaming.md`, `references/certificates.md`, `references/reports.md`, `references/nevi-compliance.md`)

- Roaming: enable it and set country code, party ID and business name in Settings > Integrations & Features. Roaming > Partners > Create Partner, share the registration token or click **Register**. Roaming > Locations: toggle **Published** per site. API only: credit a CDR with `POST /v1/ocpi/cdrs/credit`, pull a module with `POST /v1/ocpi/partners/<id>/sync/<locations|tariffs|cdrs|tokens>`. Confirm: partner status `Connected`.
- Plug and Charge: enable it in Settings > Integrations & Features > Plug & Charge, pick Hubject, Manual or Local and click **Test Connection**. While off, the Certificates page is hidden and its routes return 403. Mutual TLS renewal (`SignCertificate` with `ChargingStationCertificate`) works without the toggle.
- Reports > Generate: Revenue, Utilization, Energy, Station Health, Sessions, Sustainability, Driver Activity or NEVI Compliance as CSV, PDF or XLSX, or on a schedule. CO2 needs a carbon region on each site. NEVI requires 97% uptime. Record excluded downtime per station (`GET /v1/nevi/excluded-downtime`).

### Users and settings (`references/users.md`, `references/settings.md`)

- Users > Create User: first and last name, email, mobile, role. There is no password field: the user gets an invitation email with a setup link. Role defaults are copied, then edit on the Permissions tab. Users cannot edit their own permissions.
- New users see nothing until you grant **All sites** or specific sites under Site Access. Drivers, tokens, fleets, pricing, settings and roaming are not filtered by site access.
- Settings tabs and permissions: Company Info, Marketing, Content and Sustainability (`settings.system`), Notification (`settings.notification`), Payment (`settings.payment`, plus `payments:write` for provider actions), Integrations & Features (`settings.integrations`), Security (`settings.security`), API Keys (`settings.apiKeys`), Firmware Campaign, Station Configurations, Smart Charging, AI, Conformance.
- Company currency is one value for the platform. Changing it does not relabel past records. API keys show the token once. Revoking is permanent.

### Firmware and station configurations (`references/firmware-updates.md`, `references/station-configurations.md`)

- Firmware: Settings > Firmware Campaign > Create (name, HTTPS firmware URL, version, optional signing certificate and signature, set both or neither). Start Campaign sends UpdateFirmware to online stations. Many OCPP 2.1 stations reject unsigned updates. A failed install marks the station faulted until the next install or **Enable Station**.
- Configuration templates are bound to one OCPP version: 1.6 keys (ChangeConfiguration), 2.1 component and variable (SetVariables). Push, then the CSMS refreshes and checks drift. Station > Configurations > **Refresh from Station** reads the live values. The 1.6 and 2.1 reference files are long: grep them for the key or variable.

### More pages

- Free vend (`references/free-vend.md`): Site > Free Vend toggle. Any token is accepted, payment is skipped, and config templates go to online stations. Turning it off does not revert station configuration: edit or remove the generated templates.
- Sessions and refunds (`references/sessions.md`): filters by status, station, site, driver and date. Refund from the Payment tab on captured payments (`POST /v1/sessions/<id>/refund`). Payment provider detail: evtivity-integrations.
- Access logs (`references/access-logs.md`): tabs CSMS, Portal, API, Workers. Each entity has a History tab, the global audit page is `/audit` (`GET /v1/audit`, `audit:read`). Retention: `logs.*.retentionDays`.
- Station images (`references/station-images.md`): upload (10 MB max, needs S3 configured), set the main image, tag, caption, mark driver-visible.
- Support cases (`references/support-cases.md`): public messages reach the driver, internal notes do not. Refund a linked session from the case (`POST /v1/support-cases/<id>/refund`). AI Draft never sends.
- AI assistant (`references/ai-assistant.md`): enable in Settings > AI (Anthropic, OpenAI or Gemini). It acts with the user's permissions and asks before changes.
- Conformance testing (`references/conformance-testing.md`): Settings > Conformance > **Run Tests**. Command line runner and results: evtivity-conformance.

## References

Generated from the website docs. Never edit them. The first line of each file is the live page URL: link it when you answer. Every page of this section is listed once in the Router table above.

---
name: evtivity-guides
description: Operator workflows from the EVtivity CSMS Guides docs. Covers onboarding a charging station (registration, security profile, password, approval), station management and the connector status model, the charging session lifecycle on OCPP 1.6 and 2.1, session monitoring (idle detection, cost, split billing, live updates), RFID tokens and the local auth list, reservations (scheduled and immediate, fees, cancellation), smart charging profiles (batch push, clear, composite schedule), notifications (OCPP, driver and system events, channels, templates), station display messages (OCPP 2.1 SetDisplayMessage, 1.6 DataTransfer), users, roles, permissions and site access, audit logs, driver portal setup and QR charging, white labeling (branding, domains, SMTP, Twilio, legal pages), field troubleshooting (stuck sessions, stale connector status, SuspendedEV), EV-specific charging behaviors, and OCPP testing. Use when an operator asks how to run, configure or debug daily EVtivity operations.
license: MIT
metadata:
  evtivity-version: "0.1.39"
  evtivity-docs-section: guides
---

# EVtivity operator guides

This skill routes an operator task to the right page of the Guides section of the EVtivity docs and gives the workflow around it: steps, decision points, API calls, checks and safety stops. The website docs are the source of truth. Read the linked page before you act on details this file does not state.

Pages in this section (id and live URL):

| Page id | Topic | URL |
|---|---|---|
| guides/station-onboarding | Register a station and bring it online | https://www.evtivity.com/docs/guides/station-onboarding |
| guides/station-management | Lifecycle, connector status model, availability, configuration view | https://www.evtivity.com/docs/guides/station-management |
| guides/station-lifecycle | Connector states from plug-in to unplug, 1.6 vs 2.1 | https://www.evtivity.com/docs/guides/station-lifecycle |
| guides/session-monitoring | Session statuses, idle detection, cost, split billing, live view | https://www.evtivity.com/docs/guides/session-monitoring |
| guides/using-rfid-tokens | Capture, register and pre-push RFID cards | https://www.evtivity.com/docs/guides/using-rfid-tokens |
| guides/reservations | Reservation model, scheduler, fees, roaming | https://www.evtivity.com/docs/guides/reservations |
| guides/smart-charging | Charging profile push, delete, clear, scheduling paths | https://www.evtivity.com/docs/guides/smart-charging |
| guides/notifications | Event categories, channels, templates, preferences | https://www.evtivity.com/docs/guides/notifications |
| guides/station-display-messages | On-charger screen pipeline, slots, templates | https://www.evtivity.com/docs/guides/station-display-messages |
| guides/user-management | Roles, permissions, site access, API keys | https://www.evtivity.com/docs/guides/user-management |
| guides/audit-logs | Per-entity history and global audit search | https://www.evtivity.com/docs/guides/audit-logs |
| guides/portal-setup | Driver portal, QR charging, guest flow | https://www.evtivity.com/docs/guides/portal-setup |
| guides/white-labeling | Branding, domains, email, SMS, legal content | https://www.evtivity.com/docs/guides/white-labeling |
| guides/troubleshooting | Field fixes for stuck sessions, stale status, SuspendedEV | https://www.evtivity.com/docs/guides/troubleshooting |
| guides/ev-charging-behaviors | Vehicle quirks behind SuspendedEV and odd stops | https://www.evtivity.com/docs/guides/ev-charging-behaviors |
| guides/ocpp-testing | Conformance runs, manual OCPP commands, config checks | https://www.evtivity.com/docs/guides/ocpp-testing |

Sibling skills:

- evtivity-csms: every dashboard page in detail (sites, stations, pricing, drivers, tokens, fleets, load management, roaming, reports, users, settings, firmware, station configurations, maintenance). Use it for field-by-field page detail.
- evtivity-api: authentication (API keys, sign-in tokens), pagination, error codes, the full route catalog with permissions.
- evtivity-getting-started (local setup), evtivity-configuration (settings, env vars, security profiles), evtivity-deployment (Docker, Helm, AWS).
- evtivity-portal and evtivity-mobile-app (driver side), evtivity-integrations (payment providers, webhooks).
- evtivity-simulator (simulated stations), evtivity-conformance (OCPP command testing, OCTT).
- evtivity-troubleshoot (the stack itself fails: containers, migrations, Redis, sign-in), evtivity-report-issue (file a bug).

## Conventions for API calls

Set `EVTIVITY_API` (Docker Compose: `http://localhost:7102`) and `EVTIVITY_TOKEN` (an API key or sign-in token, see evtivity-api). Every call below sends:

```bash
-H "Authorization: Bearer $EVTIVITY_TOKEN" -H 'Content-Type: application/json'
```

- Detail routes take prefixed IDs (`sta_...`, `sit_...`). OCPP command routes (`/v1/ocpp/commands/v16/...`, `/v1/ocpp/commands/v21/...`) take the station's OCPP identity (`CS-001`) and need `stations:write`.
- Errors are `{ "error", "code" }`. Branch on `code`.
- A command to an offline station is queued: the API answers 202 with `code: COMMAND_QUEUED` and delivers it on reconnect.

## Safety stops

Ask the user before any of these, and say what drivers will notice:

- Rejecting, blocking or deleting a station (delete blocks it, the station can no longer connect), deleting an EVSE or connector.
- Disabling a station, stopping an active session, clearing all charging profiles, pushing a smart charging profile to many stations.
- Deactivating or deleting a token, deactivating a driver (cascades to all of the driver's tokens).
- Cancelling a reservation with a fee (`chargeCancellationFee: true`).
- Pushing a configuration template, enabling OCPP event webhooks to external URLs.
- Changing a user's role, permissions or site access, creating or revoking API keys.
- Changing branding, domains, SMTP, Twilio, currency or tax settings on a live network.

## 1. Onboard a station

Page: guides/station-onboarding. Connector meaning after it is online: guides/station-management.

1. Collect: OCPP identity, OCPP version (1.6 or 2.1), security profile (No Auth, Basic Auth, TLS + Basic Auth, Mutual TLS), password or client certificate, target site.
2. Create the record. Dashboard: Stations > Create Station. API (`stations:write`):

   ```bash
   curl -s "$EVTIVITY_API/v1/stations" ... \
     -d '{"stationId":"CS-001","ocppProtocol":"ocpp2.1","securityProfile":1,"password":"<16-40 chars>","siteId":"sit_..."}'
   ```

   409 `STATION_ID_EXISTS` means the identity is taken. Add EVSEs only to pre-populate the dashboard: `POST /v1/stations/{id}/evses` with `evseId` and `connectors` (`connectorId`, `connectorType`, `maxPowerKw`). Bulk: Sites page CSV import (`GET /v1/sites/export/template`, `POST /v1/sites/import`, `sites:write`).
3. Decision: password length. 2.1 allows 16 to 40 characters, 1.6 allows 16 to 20. Rotate Credentials creates 20 characters, valid for both.
4. Configure the station URL: `ws://<host>/<stationId>` for No Auth and Basic Auth, `wss://<host>:8443/<stationId>` for TLS profiles. The path is case-sensitive.
5. Decision: registration policy (`ocpp.registrationPolicy`). Default `approval-required` leaves the station `pending`. Approve it: `POST /v1/stations/{id}/approve`. `open` accepts on creation (lab only).
6. Confirm it worked: the station shows Online, the OCPP log has `BootNotification`, `Heartbeat` and `StatusNotification`, and a round trip works:

   ```bash
   curl -s "$EVTIVITY_API/v1/ocpp/commands/v21/TriggerMessage" ... \
     -d '{"stationId":"CS-001","requestedMessage":"StatusNotification"}'
   ```

7. Set max power on 1.6 connectors (Connectors tab, Edit EVSE). Without it, load management caps the connector at an equal share.

When it does not connect, use the Common issues table of guides/station-onboarding: `auth_failed` in the Security Event Log (identity, password, profile, TLS chain), HTTP 403 (blocked), BootNotification stuck `Pending` (not approved), drops after connecting (heartbeat interval, default 300 s), missing connectors (pre-define or trigger StatusNotification per connector). For stack-level failures use evtivity-troubleshoot.

## 2. Run stations day to day

Pages: guides/station-management for the status model and availability rules, guides/station-lifecycle for the connector state sequence per protocol.

- Read status: `GET /v1/stations/{id}` (`stations:read`) returns `statusReason` and `reportedStatus`. `GET /v1/stations/{id}/connectors` lists EVSEs and connectors.
- Availability rules, first match wins: operator or security disable (unavailable), failed firmware or any fault (faulted), firmware installing or station-reported unavailable (unavailable), else available. A reboot does not clear a disable or a failed install.
- Take one station out of service with no end time: `PATCH /v1/stations/{id}` with `{"availability":"unavailable"}` (sends ChangeAvailability Inoperative). Running sessions continue. Back in service: `"available"`. Planned windows for a site belong to maintenance (evtivity-csms).
- Read configuration: `POST /v1/stations/{id}/configurations/refresh` (GetBaseReport on 2.1, GetConfiguration on 1.6). Values are read-only in the UI. Change them with SetVariables or ChangeConfiguration, or a configuration template (evtivity-csms).
- Interpret a state: 2.1 `occupied` alone does not mean energy flows. Read the chargingState-derived value (`charging`, `ev_connected`, `suspended_ev`, `idle`). After a stop, 2.1 stays `occupied`/`ev_connected` and 1.6 stays `finishing` until unplug.

## 3. Monitor sessions

Page: guides/session-monitoring.

- List: `GET /v1/sessions?status=active&stationId=...&siteId=...` (`sessions:read`). Detail: `GET /v1/sessions/{id}`, events: `/transaction-events`, meter values: `/meter-values`.
- Status values in the API: `active`, `completed`, `invalid`, `faulted`, `failed`, plus the `idling` filter. The page table also lists `pending` and omits `faulted` and `invalid`. Follow the API.
- Idle detection order: 2.1 chargingState (`Idle` or `EVConnected`), zero `Power.Active.Import`, 1.6 `SuspendedEV` or `Finishing`, flat energy. Idle fees start after the grace period in settings.
- Cost: `sessionFee`, `pricePerKwh`, `pricePerMinute`, `idleFeePricePerMinute`, `taxRate` (decimal fraction). With split billing, a cron job closes a segment each time the tariff changes, and each segment is taxed at its tariff rate.
- Live updates reach the dashboard by Server-Sent Events. No polling needed in the UI.

## 4. Register RFID cards

Page: guides/using-rfid-tokens.

1. Capture the value the card sends. Tap it on an online station, then read the rejected attempt in the station's Authorize Log tab (needs `drivers:read`) or `GET /v1/authorize-attempts` (`drivers:read`). Copy the `idToken` exactly (case, length, leading zeros).
2. Register it on the driver (`drivers:write`):

   ```bash
   curl -s "$EVTIVITY_API/v1/drivers/$DRIVER/tokens" ... -d '{"idToken":"04A1B2C3D4E5F6","tokenType":"ISO14443"}'
   ```

   `tokenType` is an OCPP IdToken type: `ISO14443` (default for MIFARE cards), `ISO15693`, `Central`, `eMAID`, `KeyCode`, `Local`, `MacAddress`, `NoAuthorization`. Drivers can also add cards in the portal (Account > RFID Cards). Bulk: Tokens page Import CSV (`idToken`, `tokenType`, `driverId`, `isActive`) or `POST /v1/tokens/import`.
3. Confirm: tap again. The station gets `Accepted` and the session appears on the dashboard. An `Invalid` result usually means a format mismatch in the stored value.
4. Offline coverage: add the tokens to the station's local list, then push it. Adding and removing is database-only until the push:

   ```bash
   curl -s "$EVTIVITY_API/v1/stations/$STA/local-auth-list/add" ... -d '{"tokenIds":["<token id>"]}'
   curl -s -X POST "$EVTIVITY_API/v1/stations/$STA/local-auth-list/push" -H "Authorization: Bearer $EVTIVITY_TOKEN"
   ```

5. Lost card: deactivate rather than delete (`PATCH /v1/tokens/{id}` with `{"isActive":false}`) so past sessions keep the link. The next tap answers `Blocked`. Confirm first.

Decision points: free-vend sites accept any card and attribute no driver. 1.6 sends `idTag`, 2.1 sends `idToken` with a type. Registration is the same.

## 5. Reservations

Page: guides/reservations (model and fees). Dashboard detail and settings: evtivity-csms.

1. Check that reservations are on at all three levels: `reservation.enabled` setting, the site toggle, the station toggle (`PATCH /v1/stations/{id}` with `reservationsEnabled`). Any level off answers 403 `RESERVATION_DISABLED`.
2. Create (`reservations:write`):

   ```bash
   curl -s "$EVTIVITY_API/v1/reservations" ... \
     -d '{"stationId":"sta_...","evseId":1,"driverId":"<driver id>","startsAt":"2026-10-07T15:00:00Z","expiresAt":"2026-10-07T16:00:00Z"}'
   ```

   A future `startsAt` creates a `scheduled` row and a worker job sends ReserveNow at the start. A start of now sends ReserveNow at once. A driver-attached reservation needs a default card (400 `PAYMENT_METHOD_REQUIRED`).
3. Window errors: `RESERVATION_WINDOW_TOO_SHORT`, `RESERVATION_EXPIRES_TOO_SOON`, `RESERVATION_STARTS_IN_PAST`, `RESERVATION_TOO_LONG`, `RESERVATION_CONFLICT`, `RESERVATION_DURING_MAINTENANCE`.
4. Confirm: `GET /v1/reservations/{id}` shows `active` after the station accepts. `GET /v1/reservations/{id}/commands` shows the ReserveNow result. `/audit` shows the history.
5. Cancel: `DELETE /v1/reservations/{id}`. Optional JSON body `{"chargeCancellationFee":true,"reason":"..."}`. The fee is operator opt-in and still needs the window and fee settings above 0. Confirm before charging a fee. A failed charge returns `feeChargeFailed: true` and the cancel still succeeds. Fee refunds are a payments task (evtivity-integrations).
6. Move a reservation: `POST /v1/reservations/{id}/reassign` with `newStationOcppId` and optional `newEvseId`.

Statuses in the code: `scheduled`, `active`, `in_use`, `used`, `cancelled`, `expired`. The page's mention of a `failed` reservation status does not match the code. A failed activation ends `cancelled` with a reason such as `station_offline_at_activation`.

## 6. Smart charging

Page: guides/smart-charging. Interaction with load management: evtivity-csms.

Decision: who owns the schedule?

| Situation | Path |
|---|---|
| Driver schedules in the car (residential) | No profile. Optional time-of-use pricing |
| Operator enforces a window (fleet) | `TxDefaultProfile` template |
| Utility cap or demand response | `ChargingStationMaxProfile` at a high stack level |
| Emergency or test block | A 0 W profile at stack level 7 (demo data seeds `Test: Block All Charging`) |

Batch push (`smartCharging:write`; the Settings > Smart Charging tab needs `settings.smartCharging`):

```bash
curl -s "$EVTIVITY_API/v1/smart-charging/templates" ... -d '{
  "name":"Fleet night window","ocppVersion":"2.1","profilePurpose":"TxDefaultProfile",
  "profileKind":"Recurring","recurrencyKind":"Daily","stackLevel":0,"chargingRateUnit":"A",
  "startSchedule":"2026-10-07T00:00:00Z",
  "schedulePeriods":[{"startPeriod":0,"limit":32},{"startPeriod":10800,"limit":0},{"startPeriod":82800,"limit":32}],
  "targetFilter":{"siteId":"sit_..."}}'
curl -s "$EVTIVITY_API/v1/smart-charging/templates/$TPL/matching-stations" -H "Authorization: Bearer $EVTIVITY_TOKEN"
curl -s -X POST "$EVTIVITY_API/v1/smart-charging/templates/$TPL/push" -H "Authorization: Bearer $EVTIVITY_TOKEN"
```

- Check the matching stations before the push and confirm with the user. Each matching online station gets ClearChargingProfile (same purpose, stack level, EVSE) then SetChargingProfile.
- Confirm: `GET /v1/smart-charging/templates/{id}/pushes` and `GET /v1/smart-charging/pushes/{pushId}` (Accepted, Rejected, Failed per station). On 2.1 the station's Charging Profiles tab shows a `Source: Station` row after the background GetChargingProfiles. 1.6 shows only the CSMS row, so check the composite schedule: `POST /v1/stations/{id}/charging-profiles/composite`.
- One station: `POST /v1/stations/{id}/charging-profiles/push` with `templateId`. Clear all: `POST /v1/stations/{id}/charging-profiles/clear` (removes factory and local profiles too, confirm first).
- Caveats with operator windows: the session stays open while `SuspendedEVSE`, so time and idle fees can accrue. Some EVs sleep and never resume. Check the station's `EVConnectionTimeOut`.

## 7. Notifications

Page: guides/notifications. Template editor and history detail: evtivity-csms.

1. Channels first: SMTP (Settings > Notification > SMTP Email) and Twilio (Twilio SMS). Without them, deliveries fail with "SMTP not configured" or "Twilio not configured" in history. Test: `POST /v1/notifications/test` with `channel` (`email` or `sms`) and `recipient` (`notifications:write`).
2. Choose the category:
   - OCPP events (email or webhook, off until configured): `PUT /v1/ocpp-event-settings` with `eventType`, `channel`, `recipient`. Bad email or non-http(s) URL answers 400 `VALIDATION_ERROR`. Private-network webhook hosts must be allowed in Settings > Notifications > Webhooks.
   - Driver events and system events (email and SMS): edit templates with `PUT /v1/notification-templates` (`eventType`, `channel`, `language`, `subject`, `bodyHtml`). The API also exposes `isEnabled` per event type on `PUT /v1/driver-event-settings` and `PUT /v1/system-event-settings`.
3. Templates resolve: settings HTML override, then database template, then the shipped file template, with English fallback. Languages: `en`, `de`, `es`, `ko`, `zh`, `zh-TW`.
4. Confirm: `GET /v1/notifications` (history) shows each attempt with its status and failure reason.

Drivers toggle email and SMS per event in the portal. Operators can opt out of SMS on their profile, but MFA codes still go out by SMS.

## 8. Station display messages

Page: guides/station-display-messages. Manual per-station messages: evtivity-csms.

1. Turn on `stationMessage.enabled` (Settings > Integrations & Features > Messages, `settings.integrations:write`). Set `stationMessage.language`, `stationMessage.brandLine`, `stationMessage.pricingFormat`, `stationMessage.charging.refreshSeconds`. A site can override the language on its Details tab.
2. Edit the eight state templates per language (`available`, `occupied`, `reserved`, `charging`, `suspended`, `discharging`, `faulted`, `unavailable`):

   ```bash
   curl -s "$EVTIVITY_API/v1/station-message-templates" -H "Authorization: Bearer $EVTIVITY_TOKEN"
   curl -s -X PUT "$EVTIVITY_API/v1/station-message-templates/available?language=en" ... -d '{"body":"{{brandLine}}\n{{pricingDisplay}}"}'
   ```

   Preview with `POST /v1/station-message-templates/preview`. Reset with `DELETE /v1/station-message-templates/{state}`. The tax note is template text you word for your jurisdiction.
3. Confirm: saving queues a re-render of online stations within seconds. Unchanged content is skipped by hash. On a 2.1 station, refresh its list: `POST /v1/stations/{stationId}/display-messages/refresh` and read `GET /v1/stations/{stationId}/display-messages`.

Decision by protocol: 2.1 uses slots 9000 (Idle, rewritten for available, occupied, reserved) to 9005. 1.6 gets only the Idle text as `DataTransfer` (`vendorId com.evtivity`, `messageId PricingDisplay`). A 1.6 station without that extension answers `UnknownVendorId`. For vendor config keys, use a configuration template (evtivity-csms).

## 9. Users, roles and audit

Pages: guides/user-management, guides/audit-logs.

- Create a user (`users:write`): `POST /v1/users` with `email`, `roleId` (list roles with `GET /v1/roles`), optional `hasAllSiteAccess` or `siteIds`. The API sends an invitation email with a setup link. There is no password field. Resend: `POST /v1/users/{id}/resend-invite`.
- Roles in the code: `admin` (all permissions), `operator` (operations, no settings, `users:read` only), `viewer` (read only). The pages describe two roles and 58 permissions. The code has three roles and 66 permissions (44 page, 22 settings). Get the live catalog with `GET /v1/permissions`.
- Customize: `PUT /v1/users/{id}/permissions` with the full list. Users cannot edit their own permissions. Confirm role and permission changes with the user.
- Site access is default-deny. A new user sees nothing until you set `hasAllSiteAccess` or `siteIds` (`PATCH /v1/users/{id}`). Drivers, tokens, fleets, pricing, notification settings, system settings and roaming are not filtered by site.
- API keys inherit the creator's permissions and site access. Creation and revocation: evtivity-api.
- Audit (`audit:read`): `GET /v1/audit/{entityType}/{entityId}` for one entity, `GET /v1/audit?entityType=station&actor=api_key&from=...&to=...` across entities. Actors: `operator`, `driver`, `api_key`, `system`, `ocpp`. Secrets are stored as `<redacted>`. Driver self-service in the portal, projections without operator fields and reads are not audited. Retention: `audit.retentionDays` (default 1095, 0 disables pruning).

## 10. White labeling and portal setup

Pages: guides/white-labeling (order and checklist), guides/portal-setup (driver features). Driver-side detail: evtivity-portal and evtivity-mobile-app.

Follow the order on guides/white-labeling:

1. Domains and TLS. Station QR codes and email links use the deployment's portal host (`PORTAL_URL`), not the Driver Portal URL setting. Fix domains before printing signage. Helm hostnames: evtivity-deployment.
2. Settings > Company Info: name, logo, QR icon (SVG), favicon, OG image, theme color, currency, price display, support contacts. Uploads up to 512 KB.
3. SMTP and From address (SPF, DKIM, DMARC), then Send Test.
4. Twilio, if SMS is in scope.
5. Settings > Content: Privacy Policy and Terms of Service per language.
6. Settings > Notification > Email Layout with `{{{content}}}` and `{{companyName}}`.
7. Station display messages (section 8).
8. Settings > Marketing: GA4 IDs for portal and dashboard.
9. Test end to end: register a driver, check the welcome email, run a guest session, request a password reset.

Portal facts to rely on: each EVSE has a QR code to `/charge/:stationId/:evseId`. Signed-in drivers get the authenticated flow, guests stay on the public page. Guest charging is free at free-vend sites and otherwise takes a card through the active payment provider (evtivity-integrations).

Note: the white-labeling page says templates exist in 7 languages. The code ships 6 (`en`, `de`, `es`, `ko`, `zh`, `zh-TW`).

## 11. Field troubleshooting

Pages: guides/troubleshooting (fixes), guides/ev-charging-behaviors (vehicle causes). If the platform itself is down, use evtivity-troubleshoot.

| Symptom | Action | API |
|---|---|---|
| Session stays active after unplug, new starts get 409 `EVSE_IN_USE` | Connectors tab > Stop active session on the EVSE. Confirm first | `POST /v1/stations/{id}/evses/{evseId}/stop-active-session` (`stations:write`, `evseId` is the OCPP EVSE number) |
| Connector badge stale | Connectors tab > Refresh connector status (TriggerMessage, waits about 10 s) | `POST /v1/stations/{id}/evses/{evseId}/refresh-status` |
| Session starts, no power, `SuspendedEV` | Refresh profiles, inspect limits, view composite schedule, delete or clear the low profile, then ask the driver to replug | `POST /v1/stations/{id}/charging-profiles/refresh`, `.../composite`, `.../clear` |

Decision path for `SuspendedEV`:

1. Any charging profile or load management allocation below about 6 A (or 0)? Fix it (section 6, load management in evtivity-csms).
2. No restriction? Check the vehicle with the diagnostic checklist on guides/ev-charging-behaviors: car-side schedule or departure timer, SoC limit, cold battery without preconditioning, Tesla stop below about 6 kW without auto-resume, Leaf 12 V battery, cable not latched.
3. A station offline cannot receive the stop or the trigger. Bring it online first. A station that rejects the stop usually recovers after a power cycle.

## 12. OCPP testing

Page: guides/ocpp-testing. Deep command testing and OCTT: evtivity-conformance. Simulated stations: evtivity-simulator.

- Conformance run: Settings > Conformance > pick Run All Tests, OCPP 2.1 or OCPP 1.6 > Run Tests. Read results per module. A failure under 1 s is usually a field or status mismatch. A 10 s error means an expected message never came. 30 s or more points to timer, power cycle or offline queue features.
- Manual commands: station OCPP Commands tab, or `/v1/ocpp/commands/v16/<Action>` and `/v1/ocpp/commands/v21/<Action>` with `stationId` (OCPP identity). Reset, ChangeAvailability and ClearCache ask for confirmation in the UI. Ask the user before sending them by API.
- Configuration check after a change: refresh the station configuration (section 2) and compare, or use the drift check `GET /v1/stations/{id}/config-drift` (`settings.stationConfig:read`).

The OCPP testing page says the Send button is disabled for offline stations. The API queues commands for offline stations (202 `COMMAND_QUEUED`), as the Stations dashboard page describes.

## Reference pages

Every docs page this skill covers is in `references/`, generated from the website docs. Never edit those files. Read the reference for details, and link the live page when you answer.

| Page id | Reference | Live page |
|---|---|---|
| `guides/audit-logs` | `references/audit-logs.md` | https://www.evtivity.com/docs/guides/audit-logs |
| `guides/ev-charging-behaviors` | `references/ev-charging-behaviors.md` | https://www.evtivity.com/docs/guides/ev-charging-behaviors |
| `guides/notifications` | `references/notifications.md` | https://www.evtivity.com/docs/guides/notifications |
| `guides/ocpp-testing` | `references/ocpp-testing.md` | https://www.evtivity.com/docs/guides/ocpp-testing |
| `guides/portal-setup` | `references/portal-setup.md` | https://www.evtivity.com/docs/guides/portal-setup |
| `guides/reservations` | `references/reservations.md` | https://www.evtivity.com/docs/guides/reservations |
| `guides/session-monitoring` | `references/session-monitoring.md` | https://www.evtivity.com/docs/guides/session-monitoring |
| `guides/smart-charging` | `references/smart-charging.md` | https://www.evtivity.com/docs/guides/smart-charging |
| `guides/station-display-messages` | `references/station-display-messages.md` | https://www.evtivity.com/docs/guides/station-display-messages |
| `guides/station-lifecycle` | `references/station-lifecycle.md` | https://www.evtivity.com/docs/guides/station-lifecycle |
| `guides/station-management` | `references/station-management.md` | https://www.evtivity.com/docs/guides/station-management |
| `guides/station-onboarding` | `references/station-onboarding.md` | https://www.evtivity.com/docs/guides/station-onboarding |
| `guides/troubleshooting` | `references/troubleshooting.md` | https://www.evtivity.com/docs/guides/troubleshooting |
| `guides/user-management` | `references/user-management.md` | https://www.evtivity.com/docs/guides/user-management |
| `guides/using-rfid-tokens` | `references/using-rfid-tokens.md` | https://www.evtivity.com/docs/guides/using-rfid-tokens |
| `guides/white-labeling` | `references/white-labeling.md` | https://www.evtivity.com/docs/guides/white-labeling |

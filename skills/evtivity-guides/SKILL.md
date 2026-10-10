---
name: evtivity-guides
description: "Step-by-step EVtivity how-to guides: onboard a station, station lifecycle, session monitoring, RFID cards, reservations, charging profiles, notifications, display messages, users and audit, white-labeling, fix stuck sessions and SuspendedEV. Use for an end-to-end procedure or walkthrough. Not for one dashboard page in detail (evtivity-csms)."
license: MIT
metadata:
  evtivity-version: "0.1.43"
  evtivity-release: "v0.1.43"
  evtivity-commit: "94253c800a6609399b9a1af6625a252e01d259a7"
  evtivity-docs-section: guides
---

# EVtivity operator guides

Not for: field-by-field detail of one dashboard page (use evtivity-csms), payment providers (use evtivity-integrations), a stack that fails or a station that cannot connect at all (use evtivity-troubleshoot), OCTT and raw OCPP command testing (use evtivity-conformance).

This skill routes an operator procedure to the right Guides page and gives the workflow around it: steps, decision points, API calls, checks and safety stops. The website docs are the source of truth: read the reference before you act on details this file does not state.

## Conventions for API calls

Set `EVTIVITY_API` (Docker Compose: `http://localhost:7102`) and `EVTIVITY_TOKEN` (an API key, see evtivity-api). Every call below sends `-H "Authorization: Bearer $EVTIVITY_TOKEN" -H 'Content-Type: application/json'` (shown as `...`).

- Detail routes take prefixed IDs (`sta_...`, `sit_...`). OCPP command routes (`/v1/ocpp/commands/v16/`, `/v1/ocpp/commands/v21/`) take the station's OCPP identity (`CS-001`) and need `stations:write`.
- Errors are `{ "error", "code" }`. Branch on `code`. A command to an offline station is queued: 202 with `code: COMMAND_QUEUED`, delivered on reconnect.

## Safety stops

Ask the user before any of these, and say what drivers will notice:

- Rejecting, blocking or deleting a station (delete blocks it), deleting an EVSE or connector.
- Disabling a station, stopping an active session, clearing all charging profiles, pushing a smart charging profile to many stations.
- Deactivating or deleting a token, deactivating a driver (cascades to all of the driver's tokens).
- Cancelling a reservation with a fee (`chargeCancellationFee: true`).
- Pushing a configuration template, enabling OCPP event webhooks to external URLs.
- Changing a user's role, permissions or site access, creating or revoking API keys.
- Changing branding, domains, SMTP, Twilio, currency or tax settings on a live network.

## 1. Onboard a station (`references/station-onboarding.md`)

1. Collect: OCPP identity, OCPP version (1.6 or 2.1), security profile (No Auth, Basic Auth, TLS + Basic Auth, Mutual TLS), password or client certificate, target site.
2. Create the record. Dashboard: Stations > Create Station. API (`stations:write`):

   ```bash
   curl -s "$EVTIVITY_API/v1/stations" ... \
     -d '{"stationId":"CS-001","ocppProtocol":"ocpp2.1","securityProfile":1,"password":"<16-40 chars>","siteId":"sit_..."}'
   ```

   409 `STATION_ID_EXISTS` means the identity is taken. Pre-populate EVSEs with `POST /v1/stations/{id}/evses` (`evseId`, `connectors` with `connectorId`, `connectorType`, `maxPowerKw`). Bulk: Sites page CSV import (`GET /v1/sites/export/template`, `POST /v1/sites/import`).
3. Password length: 2.1 allows 16 to 40 characters, 1.6 allows 16 to 20. Rotate Credentials creates 20 characters, valid for both.
4. Station URL: `ws://<host>/<stationId>` for No Auth and Basic Auth, `wss://<host>:8443/<stationId>` for TLS profiles. The path is case-sensitive.
5. Registration policy (`ocpp.registrationPolicy`): the default `approval-required` leaves the station `pending`. Approve it with `POST /v1/stations/{id}/approve`. `open` accepts on creation (lab only).
6. Confirm: the station shows Online, the OCPP log has `BootNotification`, `Heartbeat` and `StatusNotification`, and a round trip works:

   ```bash
   curl -s "$EVTIVITY_API/v1/ocpp/commands/v21/TriggerMessage" ... \
     -d '{"stationId":"CS-001","requestedMessage":"StatusNotification"}'
   ```

7. Set max power on 1.6 connectors (Connectors tab, Edit EVSE). Without it, load management caps the connector at an equal share.

When it does not connect, use the Common issues table of the page: `auth_failed` in the Security Event Log, HTTP 403 (blocked), BootNotification stuck `Pending` (not approved), drops after connecting (heartbeat interval), missing connectors. Stack-level failures: evtivity-troubleshoot.

## 2. Run stations day to day (`references/station-management.md`, `references/station-lifecycle.md`)

- Read status: `GET /v1/stations/{id}` returns `statusReason` and `reportedStatus`. `GET /v1/stations/{id}/connectors` lists EVSEs and connectors.
- Availability, first match wins: operator or security disable (unavailable), failed firmware or any fault (faulted), firmware installing or station-reported unavailable (unavailable), else available. A reboot does not clear a disable or a failed install.
- One station out of service with no end time: `PATCH /v1/stations/{id}` with `{"availability":"unavailable"}` (ChangeAvailability Inoperative). Running sessions continue. Back: `"available"`. Planned site windows: maintenance (evtivity-csms).
- Read configuration: `POST /v1/stations/{id}/configurations/refresh` (GetBaseReport on 2.1, GetConfiguration on 1.6).
- Interpret a state: 2.1 `occupied` alone does not mean energy flows. Read the chargingState-derived value (`charging`, `ev_connected`, `suspended_ev`, `idle`). After a stop, 2.1 stays `occupied`/`ev_connected` and 1.6 stays `finishing` until unplug.

## 3. Monitor sessions (`references/session-monitoring.md`)

- List: `GET /v1/sessions?status=active&stationId=...&siteId=...` (`sessions:read`). Detail: `GET /v1/sessions/{id}`, events: `/transaction-events`, meter values: `/meter-values`.
- Idle detection order: 2.1 chargingState (`Idle` or `EVConnected`), zero `Power.Active.Import`, 1.6 `SuspendedEV` or `Finishing`, flat energy. Idle fees start after the grace period in settings.
- Cost: `sessionFee`, `pricePerKwh`, `pricePerMinute`, `idleFeePricePerMinute`, `taxRate` (decimal fraction). With split billing, a segment closes each time the tariff changes, and each segment is taxed at its tariff rate.
- Live updates reach the dashboard by Server-Sent Events.

## 4. Register RFID cards (`references/using-rfid-tokens.md`)

1. Capture the value the card sends: tap it on an online station, then read the rejected attempt in the station's Authorize Log tab or `GET /v1/authorize-attempts` (`drivers:read`). Copy the `idToken` exactly (case, length, leading zeros).
2. Register it on the driver (`drivers:write`):

   ```bash
   curl -s "$EVTIVITY_API/v1/drivers/$DRIVER/tokens" ... -d '{"idToken":"04A1B2C3D4E5F6","tokenType":"ISO14443"}'
   ```

   `tokenType`: `ISO14443` (default for MIFARE cards), `ISO15693`, `Central`, `eMAID`, `KeyCode`, `Local`, `MacAddress`, `NoAuthorization`. Bulk: Tokens page Import CSV or `POST /v1/tokens/import`.
3. Confirm: tap again. The station gets `Accepted`. `Invalid` usually means a format mismatch in the stored value.
4. Offline coverage: add tokens to the station's local list (database only), then push:

   ```bash
   curl -s "$EVTIVITY_API/v1/stations/$STA/local-auth-list/add" ... -d '{"tokenIds":["<token id>"]}'
   curl -s -X POST "$EVTIVITY_API/v1/stations/$STA/local-auth-list/push" -H "Authorization: Bearer $EVTIVITY_TOKEN"
   ```

5. Lost card: deactivate rather than delete (`PATCH /v1/tokens/{id}` with `{"isActive":false}`) so past sessions keep the link. Confirm first.

Free-vend sites accept any card and attribute no driver. 1.6 sends `idTag`, 2.1 sends `idToken` with a type. Registration is the same.

## 5. Reservations (`references/reservations.md`)

1. Reservations must be on at all three levels: `reservation.enabled`, the site toggle, the station toggle (`PATCH /v1/stations/{id}` with `reservationsEnabled`). Any level off answers 403 `RESERVATION_DISABLED`.
2. Create (`reservations:write`):

   ```bash
   curl -s "$EVTIVITY_API/v1/reservations" ... \
     -d '{"stationId":"sta_...","evseId":1,"driverId":"<driver id>","startsAt":"2026-10-07T15:00:00Z","expiresAt":"2026-10-07T16:00:00Z"}'
   ```

   A future `startsAt` creates a `scheduled` row and a worker job sends ReserveNow at the start. A driver-attached reservation needs a default card (400 `PAYMENT_METHOD_REQUIRED`).
3. Window errors: `RESERVATION_WINDOW_TOO_SHORT`, `RESERVATION_EXPIRES_TOO_SOON`, `RESERVATION_STARTS_IN_PAST`, `RESERVATION_TOO_LONG`, `RESERVATION_CONFLICT`, `RESERVATION_DURING_MAINTENANCE`.
4. Confirm: `GET /v1/reservations/{id}` shows `active` after the station accepts. `GET /v1/reservations/{id}/commands` shows the ReserveNow result.
5. Cancel: `DELETE /v1/reservations/{id}` with optional `{"chargeCancellationFee":true,"reason":"..."}`. Confirm before charging a fee. A failed charge returns `feeChargeFailed: true` and the cancel still succeeds.
6. Move: `POST /v1/reservations/{id}/reassign` with `newStationOcppId` and optional `newEvseId`.

## 6. Smart charging (`references/smart-charging.md`)

| Situation | Path |
|---|---|
| Driver schedules in the car (residential) | No profile. Optional time-of-use pricing |
| Operator enforces a window (fleet) | `TxDefaultProfile` template |
| Utility cap or demand response | `ChargingStationMaxProfile` at a high stack level |
| Emergency or test block | A 0 W profile at stack level 7 |

Batch push (`smartCharging:write`):

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

- Show the matching stations and confirm before the push. Each matching online station gets ClearChargingProfile (same purpose, stack level, EVSE) then SetChargingProfile.
- Confirm: `GET /v1/smart-charging/templates/{id}/pushes` (Accepted, Rejected, Failed per station). 1.6 shows only the CSMS row, so check the composite schedule: `POST /v1/stations/{id}/charging-profiles/composite`.
- One station: `POST /v1/stations/{id}/charging-profiles/push` with `templateId`. Clear all: `POST /v1/stations/{id}/charging-profiles/clear` (removes factory and local profiles too, confirm first).
- With operator windows the session stays open while `SuspendedEVSE`, so time and idle fees can accrue. Some EVs sleep and never resume.

## 7. Notifications (`references/notifications.md`)

1. Channels first: SMTP and Twilio (Settings > Notification). Test with `POST /v1/notifications/test` (`channel` `email` or `sms`, `recipient`).
2. OCPP events (email or webhook, every event off until configured, `ocpp.MessageLog` only for short investigations): `PUT /v1/ocpp-event-settings` with `eventType`, `channel`, `recipient`. Private-network webhook hosts must be allowed in Settings.
3. Driver events: turn a type on or off with `PUT /v1/driver-event-settings` (`eventType`, `isEnabled`). The four access-critical types refuse `false` with 400 `NOTIFICATION_EVENT_REQUIRED`. System events are always on and have no setting.
4. Templates for driver and system events (email and SMS): `PUT /v1/notification-templates` (`eventType`, `channel`, `language`, `subject`, `bodyHtml`). Languages: `en`, `de`, `es`, `ko`, `zh`, `zh-TW`, with English fallback.
5. Confirm: `GET /v1/notifications` (history) shows each attempt with its status and failure reason.

## 8. Station display messages (`references/station-display-messages.md`)

1. Turn on `stationMessage.enabled` (Settings > Integrations & Features > Messages). Set language, brand line, pricing format and refresh interval. A site can override the language.
2. Edit the eight state templates per language (`available`, `occupied`, `reserved`, `charging`, `suspended`, `discharging`, `faulted`, `unavailable`): `GET /v1/station-message-templates`, `PUT /v1/station-message-templates/{state}?language=en` with `{"body":"..."}`, preview with `POST /v1/station-message-templates/preview`, reset with `DELETE`.
3. Confirm: saving re-renders online stations within seconds. On a 2.1 station: `POST /v1/stations/{stationId}/display-messages/refresh`, then `GET /v1/stations/{stationId}/display-messages`.

2.1 uses slots 9000 to 9005. 1.6 gets only the Idle text as `DataTransfer` (`vendorId com.evtivity`, `messageId PricingDisplay`). A 1.6 station without that extension answers `UnknownVendorId`.

## 9. Users, roles and audit (`references/user-management.md`, `references/audit-logs.md`)

- Create a user (`users:write`): `POST /v1/users` with `email`, `roleId` (`GET /v1/roles`), optional `hasAllSiteAccess` or `siteIds`. The API sends an invitation email with a setup link. Resend: `POST /v1/users/{id}/resend-invite`.
- Live permission catalog: `GET /v1/permissions` returns `{ resource, kind, labelKey, permissions }` per group. Customize: `PUT /v1/users/{id}/permissions` with the full list. Users cannot edit their own permissions. Confirm changes with the user.
- Site access is default-deny: set `hasAllSiteAccess` or `siteIds` (`PATCH /v1/users/{id}`).
- Audit (`audit:read`): `GET /v1/audit/{entityType}/{entityId}` for one entity, `GET /v1/audit?entityType=station&actor=api_key&from=...&to=...` across entities. Retention: `audit.retentionDays` (default 1095, 0 disables pruning).

## 10. White labeling and portal setup (`references/white-labeling.md`, `references/portal-setup.md`)

Follow the order on the white-labeling page: domains and TLS (station QR codes and email links use the deployment's portal host, so fix domains before printing signage), Company Info branding, SMTP and From address (SPF, DKIM, DMARC), Twilio, legal content per language, email layout, station display messages, marketing IDs, then an end-to-end test (register a driver, guest session, password reset).

Each EVSE has a QR code to `/charge/:stationId/:evseId`. Guest charging is free at free-vend sites and otherwise takes a card through the active payment provider (evtivity-integrations). Driver-side detail: evtivity-portal and evtivity-mobile-app.

## 11. Field troubleshooting (`references/troubleshooting.md`, `references/ev-charging-behaviors.md`)

If the platform itself is down, use evtivity-troubleshoot.

| Symptom | Action | API |
|---|---|---|
| Session stays active after unplug, new starts get 409 `EVSE_IN_USE` | Connectors tab > Stop active session (confirm first) | `POST /v1/stations/{id}/evses/{evseId}/stop-active-session` |
| Session `faulted` with stopped reason `EndRequestFailed`, operators got a Session End Failed alert, driver not charged | Session detail > Billing > Bill session (confirm first). Manual billing if it cannot be charged | `POST /v1/sessions/{id}/rebill` |
| Connector badge stale | Connectors tab > Refresh connector status | `POST /v1/stations/{id}/evses/{evseId}/refresh-status` |
| Session starts, no power, `SuspendedEV` | Refresh profiles, view composite schedule, clear the low profile, ask the driver to replug | `POST /v1/stations/{id}/charging-profiles/refresh`, `.../composite`, `.../clear` |

For `SuspendedEV`: first look for a charging profile or load allocation below about 6 A. With none, check the vehicle with the checklist in `references/ev-charging-behaviors.md` (car-side schedule, SoC limit, cold battery, 12 V battery, cable not latched).

## 12. OCPP testing (`references/ocpp-testing.md`)

- Conformance run: Settings > Conformance > Run Tests. A failure under 1 s is usually a field or status mismatch, a 10 s error a message that never came, 30 s or more a timer, power cycle or offline queue feature. Deeper testing: evtivity-conformance.
- Manual commands: the station OCPP Commands tab, or `/v1/ocpp/commands/{v16|v21}/<Action>`. Ask the user before Reset, ChangeAvailability or ClearCache.
- After a configuration change: refresh the station configuration, or `GET /v1/stations/{id}/config-drift`.

## References

Generated from the website docs. Never edit them. The first line of each file is the live page URL: link it when you answer. Every page of this section is named once in the section headings above.

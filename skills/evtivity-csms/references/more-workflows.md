# More operator workflows

Hand-written part of the evtivity-csms skill (not generated from the website). The page references in this folder are the source of truth: open the one each section names. The confirm-before-you-act rules and API basics of `SKILL.md` apply here too.

## Notifications and display messages (`references/notifications.md`, `references/display-messages.md`)

- Set up SMTP and Twilio first (Settings > Notification) and use **Send Test**.
- Notifications page: edit Driver and System event templates (Handlebars). Driver events have an **Active** switch per type; four access types are locked on (400 `NOTIFICATION_EVENT_REQUIRED`). System events are always on. OCPP events are off until you set a channel (email or webhook) and recipient. Webhooks to private addresses are blocked unless listed in **Allowed private webhook hosts**.
- History tab: a `failed` row shows the reason.
- Display messages (OCPP 2.0.1 and 2.1): Station > Display Messages. Per-state screens: **Enable Station Messages** (Settings > Integrations & Features > Messages).

## Roaming, certificates, reports (`references/roaming.md`, `references/certificates.md`, `references/reports.md`, `references/nevi-compliance.md`)

- Roaming: enable it and set country code, party ID and business name in Settings > Integrations & Features. Roaming > Partners > Create Partner, share the registration token or click **Register**. Roaming > Locations: toggle **Published** per site. API only: credit a CDR with `POST /v1/ocpi/cdrs/credit`, pull a module with `POST /v1/ocpi/partners/<id>/sync/<locations|tariffs|cdrs>`. Confirm: partner status `Connected`.
- Plug and Charge: Settings > Integrations & Features > Plug & Charge, pick Hubject, Manual or Local, **Test Connection**. While off, Certificates is hidden (routes 403).
- Reports > Generate: Revenue, Utilization, Energy, Station Health, Sessions, Sustainability, Driver Activity or NEVI Compliance as CSV, PDF or XLSX, or on a schedule. CO2 needs a carbon region per site. NEVI needs 97% uptime, is always XLSX, excluded downtime per station: `GET /v1/nevi/excluded-downtime`.

## Firmware and station configurations (`references/firmware-updates.md`, `references/station-configurations.md`)

- Firmware: Settings > Firmware Campaign > Create (name, HTTPS firmware URL, version, optional signing certificate and signature, set both or neither). Start Campaign sends UpdateFirmware to online stations. A failed install marks the station faulted until the next install or **Enable Station**.
- Configuration templates are bound to one OCPP version: 1.6 keys (ChangeConfiguration), 2.1 component and variable (SetVariables, also pushed to OCPP 2.0.1 stations). Push, then the CSMS refreshes and checks drift. Station > Configurations > **Refresh from Station** reads the live values.

## More pages

- Free vend (`references/free-vend.md`): any token is accepted and payment is skipped. Turning it off does not revert station configuration: edit or remove its templates.
- Sessions and refunds (`references/sessions.md`): Refund from the Payment tab on captured payments (`POST /v1/sessions/<id>/refund`). A `faulted` session with stopped reason `EndRequestFailed` (Session End Failed alert) is not billed: Details > Billing > **Bill session** (`POST /v1/sessions/<id>/rebill`). Uncharged ones become **Manual billing** (collect outside the platform). Payment provider detail: evtivity-integrations.
- Access logs (`references/access-logs.md`): tabs CSMS, Portal, API, Workers. Each entity has a History tab, the global audit page is `/audit` (`GET /v1/audit`, `audit:read`). Retention: Settings > Data Retention.
- Support cases (`references/support-cases.md`): public messages reach the driver, internal notes do not. Refund a linked session from the case (`POST /v1/support-cases/<id>/refund`). AI Draft never sends.
- AI: off until turned on in Settings > AI. A change runs only after a signed-in user confirms it (API keys get `AI_CONFIRMATION_REQUIRES_SESSION`).
- Conformance testing (`references/conformance-testing.md`): Settings > Conformance > **Run Tests**. Command line runner and results: evtivity-conformance.
- SIMs (`references/sims.md`): shown while a SIM provider or station signal reads are on. Nothing is fetched before Confirm SIM. Deactivate SIM never changes the provider. Site-restricted users see only SIMs confirmed at their stations.

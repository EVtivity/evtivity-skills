---
name: evtivity-portal
description: Use the EVtivity driver portal (web app for EV drivers) and its /v1/portal/ API. Covers registration, operator invitations, email verification, sign-in, password reset and MFA, account settings (personal info, show prices gross or net, security, notification preferences, notification bell, sign out), finding a station by search or QR code, the station detail page, location detail (hours, images, map, popular times), starting and stopping a charge, guest charging by QR with card checkout and 3D Secure, payment methods (Stripe, Adyen, test provider), RFID cards, activity and the monthly dashboard, sessions, session receipts and monthly statements, vehicles and mileage estimates, favorites, station watches, and support cases. Use when someone asks how a driver does something in the portal, needs to script driver actions against the portal API, or is debugging what a driver sees.
license: MIT
metadata:
  evtivity-version: "0.1.39"
  evtivity-docs-section: portal
---

# EVtivity Driver Portal

The driver portal is the web app EV drivers use to charge on an EVtivity network. It talks to the CSMS through the driver API under `/v1/portal/`. The docs pages listed below are the source of truth. Open the page for the exact steps, labels and field rules. This file tells you which page to open and how the pieces fit.

Use this skill to:

- Walk a driver through a portal task.
- Reproduce a driver flow against a running stack.
- Script driver actions with the portal API.

For the operator side (creating drivers, sending invites, tokens, pricing, settings) use `evtivity-csms`. For the native app use `evtivity-mobile-app`.

## Where things run

| What | Local Docker Compose (see `evtivity-getting-started`) |
|---|---|
| Driver portal | http://localhost:7101 |
| REST API | http://localhost:7102 (driver routes under `/v1/portal/`) |
| Seeded demo driver | `driver@evtivity.local` / `driver123` |

On Helm or AWS the hosts come from the deployment (see `evtivity-deployment`). Use placeholders such as `https://portal.example.com` and `https://api.example.com` when writing instructions for someone else.

## Page map

Every page of the portal docs section, by id. Open the URL for the full text.

| Page id | URL | Use it for |
|---|---|---|
| portal/registration | https://www.evtivity.com/docs/portal/registration | Create an account, accept an operator invitation, verify email, sign in, forgot password, MFA (email, authenticator app, SMS) |
| portal/account | https://www.evtivity.com/docs/portal/account | Personal Info (name, email, phone, language, timezone, theme, distance unit, Show prices), Security, Notification preferences, the notification bell, sign out |
| portal/charging | https://www.evtivity.com/docs/portal/charging | Search or QR entry, station detail page, pricing display, EVSE grid and connector colors, pre-start status check, payment method choice, start, live session, stop, ghost transaction recovery |
| portal/location-detail | https://www.evtivity.com/docs/portal/location-detail | Site page opened from the address line: hours, charger count, images, Google Map and directions, popular times, public contact |
| portal/guest-charging | https://www.evtivity.com/docs/portal/guest-charging | Charging without an account: QR landing pages, free stations, card checkout, 3D Secure, test mode, session tracking page, 15-minute token, receipt |
| portal/payment-methods | https://www.evtivity.com/docs/portal/payment-methods | Add a card (Stripe, Adyen, test provider), 3D Secure, set default, remove |
| portal/rfid-cards | https://www.evtivity.com/docs/portal/rfid-cards | Add an RFID card, activate or deactivate, how tap-to-charge works |
| portal/activity | https://www.evtivity.com/docs/portal/activity | Activity tab layout: month selector, donut chart, Cost / Energy / Distance, session list, status dots, monthly statement |
| portal/sessions | https://www.evtivity.com/docs/portal/sessions | Monthly dashboard, carbon impact, session detail receipt, cost and tax rows, data formats |
| portal/vehicles | https://www.evtivity.com/docs/portal/vehicles | Add or delete a vehicle, efficiency lookup, how miles are calculated |
| portal/favorites | https://www.evtivity.com/docs/portal/favorites | Add, view and remove favorite stations |
| portal/station-watches | https://www.evtivity.com/docs/portal/station-watches | Notify me when free, the Watching page, watch limits and expiry |
| portal/support-cases | https://www.evtivity.com/docs/portal/support-cases | Report an issue from a session or the support page, case messages, statuses, notifications |

## Workflow 1: get a driver into the portal

1. Decide how the driver gets an account.
   - Self-registration: follow portal/registration ("Create an Account").
   - The form shows a "contact your operator" message, or the API answers `PORTAL_REGISTRATION_DISABLED`: the operator turned off self-registration. The operator must create the driver and send an invitation (see `evtivity-csms`). The driver then follows "Accept an Invitation" in portal/registration.
2. Make sure the email is verified. A driver cannot start an authenticated charge until it is. Accepting an invitation also verifies the email.
3. Sign in. If the account has MFA, the driver enters a code after the password.
4. Optional: set up MFA under Account > Security (portal/registration). To switch methods, disable MFA first. Setting up while MFA is on returns `MFA_ALREADY_ENABLED`.

Check it worked: after the verification link the portal shows the login page with a confirmation message, and the driver can sign in. Through the API, `GET /v1/portal/auth/me` returns the driver (Workflow 2).

Gotchas from the pages:

- Passwords need at least 12 characters with upper, lower, digit and symbol.
- An invitation link works once and expires after 7 days. A reset link is valid for 1 hour and single use.
- Completing a password reset signs the driver out on every device.

## Workflow 2: sign in through the API

Full auth rules are in `evtivity-api`. Driver tokens work only on `/v1/portal/` routes.

```bash
EVTIVITY_API=http://localhost:7102
DRIVER_TOKEN=$(curl -s "$EVTIVITY_API/v1/portal/auth/login" \
  -H 'Content-Type: application/json' -H 'X-Client: mobile' \
  -d '{"email":"driver@evtivity.local","password":"driver123"}' | jq -r .token)

curl -s "$EVTIVITY_API/v1/portal/auth/me" -H "Authorization: Bearer $DRIVER_TOKEN"
```

- `X-Client: mobile` makes the API return `token` and `refreshToken` in the body. Without it the API sets browser cookies instead, which is the web portal path (mobile-app/api-reference on https://www.evtivity.com/docs/mobile-app/api-reference describes these headers).
- When the operator has device attestation enabled, this header without an attestation token is refused with `ATTESTATION_FAILED`.
- When the response has `mfaRequired: true` there is no token yet. Complete the code step with `POST /v1/portal/auth/mfa/verify` (see `evtivity-api`).
- The access token lasts one hour. Rotate it with `POST /v1/portal/auth/refresh`.

## Workflow 3: find a station and start a charge

Page: portal/charging. Location details: portal/location-detail.

1. Entry point:
   - QR code on the station: `/charge/:stationId/:evseId` or `/charge/:stationId`. A signed-in driver is sent to `/start/:stationId` with the connector preselected. A signed-out driver sees the guest landing page (go to Workflow 4 or sign in).
   - Search: Charge tab. Nearby stations within 10 miles appear when location access is allowed. Search works by name, ID or address without location.
2. On the station detail page check:
   - The station is online and not unavailable. A fully unavailable station shows "This station is unavailable right now. Try another station." and nothing can be selected.
   - Pricing, shown gross or net per the driver's Show prices choice (portal/account), or a **Free charging** badge.
3. Select a connector tile with a startable status (available, occupied, preparing, ev_connected).
4. The portal runs a status check (TriggerMessage). If the connector reports available (no cable), a warning asks the driver to plug in. The driver can dismiss it and start anyway.
5. Confirm the payment method. A paid tariff needs a saved card (Workflow 5).
6. Tap **Start Charging**. The session detail page opens with energy, estimated cost and duration.
7. Stop with **Stop Charging**, or the session ends when the vehicle stops drawing power.

Preconditions to verify before blaming the system: verified email, a payment method unless the tariff is free, a station that is not unavailable.

API equivalents (driver token):

```bash
curl -s "$EVTIVITY_API/v1/portal/chargers/search?q=CS-001"
curl -s -X POST "$EVTIVITY_API/v1/portal/chargers/CS-001/evse/1/start" \
  -H "Authorization: Bearer $DRIVER_TOKEN" -H 'Content-Type: application/json' \
  -d '{"paymentMethodId": 1}'
curl -s "$EVTIVITY_API/v1/portal/chargers/sessions/active" -H "Authorization: Bearer $DRIVER_TOKEN"
```

Starting a charge sends a real command to a station. Confirm with the user before you start or stop a session on a live network. Use `evtivity-simulator` for test stations.

Errors: a start at an unavailable station returns `409 STATION_UNAVAILABLE`. If the station rejects the start because of a transaction the CSMS does not know, the system stops it and retries once (ghost transaction recovery).

## Workflow 4: guest charging by QR

Page: portal/guest-charging. Payment provider setup: `evtivity-integrations`.

1. The driver scans the QR code and lands on `/charge/:stationId/:evseId` (one connector) or `/charge/:stationId` (pick a connector).
2. Decision:
   - Free tariff: **Start Charging** starts at once, no card.
   - Paid tariff: **Pay with card** opens Guest checkout with the provider's card form. The page shows the hold amount. An optional email gets the receipt.
3. Card verification:
   - Adyen can send the driver to the bank. The browser returns to `/payments/return`, which starts the session.
   - Stripe guest checkout has no verification step. A card that requires 3D Secure is declined.
   - Test provider: a **Test card** list replaces the card fields.
4. The driver tracks the session at `/guest-session/:sessionToken`. Anyone with the URL can view it. The driver should keep it open or bookmark it.

Gotchas: if the station does not begin the transaction within 15 minutes the guest session expires and the hold is cancelled. A guest has no saved card, so a cost above the hold is not charged. Guest sessions never appear in Activity.

## Workflow 5: payment methods

Page: portal/payment-methods.

1. Account > Payment Methods > **Create Payment Method**.
2. Enter the card in the provider form and tap **Add Card**. The first card becomes the default.
3. Handle 3D Secure as the page describes for Stripe (overlay) or Adyen (bank page, then `/payments/return`).
4. "Payment processing is not available at this time." means the operator has not selected a payment provider. Fix it on the operator side (`evtivity-integrations`).

After removing the default card, the driver must set a new default before a paid session.

## Workflow 6: RFID cards

Page: portal/rfid-cards. Operator view of the same tokens: `evtivity-csms`. RFID setup guide: `evtivity-guides`.

1. Account > RFID Cards (or the Home card) > **Add RFID Card**.
2. Enter the printed number (alphanumeric, 4 to 20 characters). The card is active at once.
3. Toggle off and confirm **Deactivate** to block a card. The portal never deletes cards.

A number already linked to another account is rejected. A tap with a deactivated card fails authorization at the station.

## Workflow 7: history, receipts and statements

Pages: portal/activity (layout and statement columns) and portal/sessions (dashboard metrics, carbon impact, session receipt, cost and tax rows, formats).

- Activity tab: pick the month, switch Cost, Energy or Distance, tap a session for its receipt.
- Monthly statement: `/activity/statement?month=YYYY-MM`.
- Report Issue on a receipt opens a support case with the session attached.

API: `GET /v1/portal/sessions?month=YYYY-MM`, `GET /v1/portal/sessions/monthly-summary?month=YYYY-MM`, `GET /v1/portal/sessions/monthly-statement?month=YYYY-MM`, `GET /v1/portal/sessions/{id}`.

## Workflow 8: vehicles, favorites and station watches

- Vehicles (portal/vehicles): add make, model and optional year. The efficiency comes from a built-in table, else 3.5 mi/kWh. Distance = energy (kWh) x efficiency (mi/kWh).
- Favorites (portal/favorites): star on the station detail page. The header star opens the list. Favorites persist across devices.
- Station watches (portal/station-watches): **Notify me when free** appears only when no connector is available. A watch fires once, expires after 24 hours, and is cleared when the driver starts a charge there. Limit: 25 watches. The operator can turn the notification off globally.

## Workflow 9: support cases

Page: portal/support-cases.

1. Best path: Activity > session > **Report Issue**, so the session is attached.
2. Otherwise `/support` > **New Case**.
3. Pick a category, enter Subject and Description, tap **Submit Case**. The case gets a number such as CASE-00001.
4. Reply in the thread with **Send**. The operator is notified by email. Operator-side case handling: `evtivity-csms`.

Drivers never see internal operator notes. Notifications follow the driver's preferences in portal/account.

## When the pages disagree

Some pages state the same fact differently. Tell the user which page you used.

- Distance vehicle: portal/sessions says the first registered vehicle drives the estimate. portal/vehicles says the most recently added vehicle does.
- Support status label: portal/support-cases lists "Awaiting Your Reply" on the case cards and "Waiting on Driver" in the status table.
- Pending session dot: portal/activity says yellow, portal/sessions says amber.

## Related skills

- `evtivity-getting-started`: run the stack locally with the demo driver.
- `evtivity-configuration`: settings such as portal self-registration and MFA methods.
- `evtivity-deployment`: portal and API hosts on Helm or AWS.
- `evtivity-csms`: drivers, invitations, tokens, pricing and support from the operator side.
- `evtivity-mobile-app`: the native driver app on the same API.
- `evtivity-integrations`: Stripe, Adyen and the test payment provider.
- `evtivity-simulator`: simulated stations to charge against.
- `evtivity-conformance`: OCPP conformance testing.
- `evtivity-guides`: portal setup, white-labeling and RFID guides.
- `evtivity-api`: full route catalog, auth and error codes.
- `evtivity-troubleshoot`: a start fails, a card is refused, a page is empty.
- `evtivity-report-issue`: file a bug with the right details.

## Reference pages

Every docs page this skill covers is in `references/`, generated from the website docs. Never edit those files. Read the reference for details, and link the live page when you answer.

| Page id | Reference | Live page |
|---|---|---|
| `portal/account` | `references/account.md` | https://www.evtivity.com/docs/portal/account |
| `portal/activity` | `references/activity.md` | https://www.evtivity.com/docs/portal/activity |
| `portal/charging` | `references/charging.md` | https://www.evtivity.com/docs/portal/charging |
| `portal/favorites` | `references/favorites.md` | https://www.evtivity.com/docs/portal/favorites |
| `portal/guest-charging` | `references/guest-charging.md` | https://www.evtivity.com/docs/portal/guest-charging |
| `portal/location-detail` | `references/location-detail.md` | https://www.evtivity.com/docs/portal/location-detail |
| `portal/payment-methods` | `references/payment-methods.md` | https://www.evtivity.com/docs/portal/payment-methods |
| `portal/registration` | `references/registration.md` | https://www.evtivity.com/docs/portal/registration |
| `portal/rfid-cards` | `references/rfid-cards.md` | https://www.evtivity.com/docs/portal/rfid-cards |
| `portal/sessions` | `references/sessions.md` | https://www.evtivity.com/docs/portal/sessions |
| `portal/station-watches` | `references/station-watches.md` | https://www.evtivity.com/docs/portal/station-watches |
| `portal/support-cases` | `references/support-cases.md` | https://www.evtivity.com/docs/portal/support-cases |
| `portal/vehicles` | `references/vehicles.md` | https://www.evtivity.com/docs/portal/vehicles |

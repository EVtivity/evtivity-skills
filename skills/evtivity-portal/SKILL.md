---
name: evtivity-portal
description: "Use the EVtivity driver portal web app and its API: driver registration, sign-in, find a station, start and stop charging, guest charging by QR code, saved cards, RFID cards, sessions and receipts, vehicles, favorites, station watches, support cases. Use when a driver works in the portal. Not for the native app (evtivity-mobile-app)."
license: MIT
metadata:
  evtivity-version: "0.1.39"
  evtivity-release: "v0.1.39"
  evtivity-commit: "85333dc7da57a2e0b9d74d1d09d448dee313a29b"
  evtivity-docs-section: portal
---

# EVtivity Driver Portal

Not for: the native driver app (use evtivity-mobile-app), the operator side such as creating drivers, invitations, tokens and pricing (use evtivity-csms), payment provider setup (use evtivity-integrations).

The driver portal is the web app EV drivers use to charge on an EVtivity network. It talks to the CSMS through the driver API under `/v1/portal/`. The docs pages are the source of truth: open the reference for exact steps, labels and field rules.

| What | Local Docker Compose (evtivity-getting-started) |
|---|---|
| Driver portal | http://localhost:7101 |
| REST API | http://localhost:7102 (driver routes under `/v1/portal/`) |
| Seeded demo driver | `driver@evtivity.local` / `driver123` |

On Helm or AWS the hosts come from the deployment. Use placeholders such as `https://portal.example.com` when writing instructions for someone else.

## Workflow 1: get a driver into the portal (`references/registration.md`)

1. Self-registration: "Create an Account". If the form shows a "contact your operator" message, or the API answers `PORTAL_REGISTRATION_DISABLED`, the operator must create the driver and send an invitation (evtivity-csms). The driver then follows "Accept an Invitation".
2. The email must be verified before an authenticated charge. Accepting an invitation also verifies it.
3. Sign in. With MFA, the driver enters a code after the password.
4. Optional MFA under Account > Security. To switch methods, disable MFA first (`MFA_ALREADY_ENABLED` otherwise).

Passwords need at least 12 characters with upper, lower, digit and symbol. An invitation link works once and expires after 7 days. A reset link is valid for 1 hour and signs the driver out on every device.

## Workflow 2: sign in through the API

```bash
EVTIVITY_API=http://localhost:7102
DRIVER_TOKEN=$(curl -s "$EVTIVITY_API/v1/portal/auth/login" \
  -H 'Content-Type: application/json' -H 'X-Client: mobile' \
  -d '{"email":"driver@evtivity.local","password":"driver123"}' | jq -r .token)
curl -s "$EVTIVITY_API/v1/portal/auth/me" -H "Authorization: Bearer $DRIVER_TOKEN"
```

- `X-Client: mobile` makes the API return `token` and `refreshToken` in the body. Without it the API sets browser cookies (the web portal path).
- With device attestation enabled, this header without an attestation token is refused with `ATTESTATION_FAILED`.
- `mfaRequired: true` means no token yet: complete `POST /v1/portal/auth/mfa/verify`. The access token lasts one hour: rotate with `POST /v1/portal/auth/refresh`. Auth rules: evtivity-api.

## Workflow 3: find a station and start a charge (`references/charging.md`, `references/location-detail.md`)

1. Entry: the station QR code (`/charge/:stationId/:evseId` or `/charge/:stationId`; a signed-in driver goes to `/start/:stationId`, a signed-out one to the guest page), or the Charge tab search (nearby within 10 miles with location access, else by name, ID or address).
2. On the station page check: online and not unavailable, and pricing (gross or net per the driver's Show prices choice) or a **Free charging** badge.
3. Select a connector tile with a startable status (available, occupied, preparing, ev_connected). The portal runs a status check: if no cable is detected, it asks the driver to plug in.
4. Confirm the payment method. A paid tariff needs a saved card (Workflow 5).
5. **Start Charging** opens the session page with energy, estimated cost and duration. **Stop Charging** ends it, or it ends when the vehicle stops drawing power.

```bash
curl -s "$EVTIVITY_API/v1/portal/chargers/search?q=CS-001"
curl -s -X POST "$EVTIVITY_API/v1/portal/chargers/CS-001/evse/1/start" \
  -H "Authorization: Bearer $DRIVER_TOKEN" -H 'Content-Type: application/json' -d '{"paymentMethodId": 1}'
curl -s "$EVTIVITY_API/v1/portal/chargers/sessions/active" -H "Authorization: Bearer $DRIVER_TOKEN"
```

Starting sends a real command to a station: confirm with the user on a live network, or use evtivity-simulator stations. A start at an unavailable station returns `409 STATION_UNAVAILABLE`. If the station rejects the start because of a transaction the CSMS does not know, the system stops it and retries once.

## Workflow 4: guest charging by QR (`references/guest-charging.md`)

1. The driver scans the QR code: `/charge/:stationId/:evseId` (one connector) or `/charge/:stationId` (pick one).
2. Free tariff: **Start Charging** starts at once. Paid tariff: **Pay with card** opens guest checkout with the provider's card form and shows the hold amount. An optional email gets the receipt.
3. Card verification: Adyen can send the driver to the bank and back to `/payments/return`. Stripe guest checkout declines a card that requires 3D Secure. The test provider shows a **Test card** list.
4. The driver tracks the session at `/guest-session/:sessionToken`. Anyone with the URL can view it.

If the station does not begin the transaction within 15 minutes the guest session expires and the hold is cancelled. A cost above the hold is not charged. Guest sessions never appear in Activity.

## Workflow 5: payment methods (`references/payment-methods.md`)

Account > Payment Methods > **Create Payment Method**, enter the card, **Add Card**. The first card becomes the default. 3D Secure: an overlay (Stripe) or the bank page then `/payments/return` (Adyen). "Payment processing is not available at this time." means the operator has not selected a provider (evtivity-integrations). After removing the default card, set a new default before a paid session.

## Workflow 6: RFID cards (`references/rfid-cards.md`)

Account > RFID Cards > **Add RFID Card**, enter the printed number (alphanumeric, 4 to 20 characters). It is active at once. Toggle off and confirm **Deactivate** to block a card. The portal never deletes cards. A number linked to another account is rejected.

## Workflow 7: history, receipts and statements (`references/activity.md`, `references/sessions.md`)

- Activity tab: pick the month, switch Cost, Energy or Distance, tap a session for its receipt. Monthly statement: `/activity/statement?month=YYYY-MM`. Report Issue on a receipt opens a support case with the session attached.
- API: `GET /v1/portal/sessions?month=YYYY-MM`, `GET /v1/portal/sessions/monthly-summary?month=YYYY-MM`, `GET /v1/portal/sessions/monthly-statement?month=YYYY-MM`, `GET /v1/portal/sessions/{id}`.

## Workflow 8: vehicles, favorites and station watches (`references/vehicles.md`, `references/favorites.md`, `references/station-watches.md`)

- Vehicles: add make, model and optional year. The efficiency comes from a built-in table, else 3.5 mi/kWh. Distance = energy (kWh) x efficiency (mi/kWh).
- Favorites: the star on the station page. Favorites persist across devices.
- Station watches: **Notify me when free** appears only when no connector is available. A watch fires once, expires after 24 hours, and clears when the driver starts a charge there. Limit: 25 watches.

## Workflow 9: support cases (`references/support-cases.md`)

1. Best path: Activity > session > **Report Issue**, so the session is attached. Otherwise `/support` > **New Case**.
2. Pick a category, enter Subject and Description, **Submit Case**. The case gets a number such as CASE-00001.
3. Reply in the thread with **Send**. Drivers never see internal operator notes.

## Account (`references/account.md`)

Personal Info (name, email, phone, language, timezone, theme, distance unit, Show prices), Security, Notification preferences, the notification bell, sign out.

## References

Generated from the website docs. Never edit them. The first line of each file is the live page URL: link it when you answer. Every portal page is named once in the headings above.

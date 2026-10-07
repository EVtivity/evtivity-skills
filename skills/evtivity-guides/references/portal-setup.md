Generated from https://www.evtivity.com/docs/guides/portal-setup (website commit 4cd1866). Do not edit.

# Portal Setup

Driver-facing portal features, QR code charging, guest flow, and account management.

## Overview

The EVtivity Portal is a mobile-friendly web application for EV drivers. Drivers use it to find stations, start charging sessions, manage payments, and view their charging history.

## Navigation

The portal uses a 4-tab bottom navigation bar:

| Tab | Purpose |
|---|---|
| Home | Station search, favorites, nearby stations |
| Activity | Monthly dashboard, session history, statements |
| Charge | Active session monitoring and control |
| Account | Profile, security, payments, preferences |

## QR Code Charging

Each EVSE has a unique QR code linking to:

```bash
/charge/:stationId/:evseId
```

Scanning the QR code routes drivers based on their authentication state:

- **Logged-in drivers** redirect to the authenticated charging flow with payment method selection.
- **Guests** stay on the public page and can charge without an account.

## Guest Charging

Guests can start a session without creating an account. Two modes:

- **Free** - If the site has free vend enabled, charging starts immediately after plug-in.
- **Paid** - Stripe handles payment. The portal creates a `PaymentIntent`, collects card details, and starts the session after payment authorization.

## Authenticated Charging

Logged-in drivers follow this flow:

1. Search for a station or select from favorites.
2. Select an available EVSE and connector.
3. Choose a saved payment method or add a new one.
4. Start the session.
5. Monitor progress on the Charge tab with real-time energy, power, and cost updates.
6. Stop the session from the portal or unplug.

## Account Management

The Account tab contains these sections:

| Section | Features |
|---|---|
| Profile | Name, email, phone number |
| Security | Password change, MFA setup (TOTP) |
| Notifications | Email and SMS toggle per event type |
| Payment Methods | Add, remove, set default card through the active payment provider (Stripe or Adyen) |
| RFID Cards | Register and manage RFID tags for tap-to-charge |
| Vehicles | Add vehicles with make, model, and battery capacity |
| Support Cases | Submit and track support requests |

## Activity Page

The Activity tab shows:

- **Monthly dashboard** - Donut chart with total energy, total cost, and session count for the selected month.
- **Session list** - All sessions for the month with status, station, energy, duration, and cost.
- **Monthly statements** - Downloadable PDF statements summarizing monthly charging activity.

## Favorites

Drivers can star stations from the station detail page. Favorited stations appear on the Home tab for quick access.

## Notifications

A notification bell in the header shows an unread badge count. Tapping it opens the notification list with session updates, payment receipts, and system messages.

## Customization

Operators brand the portal from the CSMS Settings page:

- **Company name** - Displayed in the portal header and email templates.
- **Logo** - Shown in the portal header and login page.

The portal inherits the organization's branding automatically.

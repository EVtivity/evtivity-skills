Generated from https://www.evtivity.com/docs/mobile-app/api-reference (website commit 257c8b8). Do not edit.

# API Reference

The EVtivity CSMS APIs the mobile app uses, broken down by functionality, with links to the full API reference.

The mobile app is a client of the EVtivity CSMS REST API. Everything the app does maps to a driver-facing endpoint under the `/v1/portal/` prefix. This page lists the APIs by app area and links to the full reference for request and response shapes.

## Conventions

- **Base URL**: the value of `EXPO_PUBLIC_API_URL`, for example `https://api.evtivity.com`. All driver endpoints live under `/v1/portal/`.
- **Authentication**: a driver bearer token (`Authorization: Bearer <token>`), obtained at login. A few endpoints (branding and features) are public.
- **Format**: JSON request and response bodies.
- **Errors**: a stable `code` field per error. See the [error code reference](https://www.evtivity.com/api-reference/error-codes).

The complete, generated reference lives under [API Reference](https://www.evtivity.com/api-reference). The sections below point at the relevant tag.

## Request headers

The app sends a few custom headers in addition to the bearer token:

- `X-Client: mobile` - marks the request as coming from the native app. The portal auth endpoints use it to return tokens in the response body instead of setting cookies, and to skip reCAPTCHA, which is a browser-only technology. A web request omits the header and behaves identically.
- `X-Device-Id: <id>` - a stable per-install device id. Refresh tokens are device-bound, so a refresh token issued to one device cannot be rotated from another.
- `Authorization: Bearer <token>` - the driver access token on authenticated requests.

During device attestation (on sensitive auth endpoints such as login, register, and forgot-password) the app first calls the challenge endpoint, then attaches:

- `X-Attest-Platform: ios | android`
- `X-Attest-Challenge: <nonce>` - the single-use nonce from the challenge endpoint.
- `X-Device-Attestation: <token>` - the signed Apple App Attest assertion (iOS) or Google Play Integrity token (Android). iOS also sends `X-Attest-KeyId`.

`X-Client: mobile` is client-supplied and therefore spoofable. With attestation enabled, the signed attestation token is the hard control; with it disabled, the login rate limit is the control for every client.

## Authentication and account access

What it powers: the login, registration, MFA, and biometric-unlock flows, plus device attestation.

- Login, register, refresh, and the current-driver profile (`/me`).
- MFA challenge, verify, and resend.
- Device attestation: request a challenge and register the attestation, which the CSMS verifies before sensitive actions.

Reference: [Portal Auth](https://www.evtivity.com/api-reference/portal-auth).

## App configuration and branding

What it powers: the operator's name, logo, and feature flags, fetched at startup so the app reflects the network it points at.

- `GET /v1/portal/branding` - company name, logo, colors, portal URL (public).
- `GET /v1/portal/features` - which features are enabled (reservations, support, roaming) and related settings (public).

Reference: [Settings](https://www.evtivity.com/api-reference/settings).

## Finding and starting a charge

What it powers: the Charge tab, charger search, the QR-scan landing, the station detail screen, and the live charging session.

- Search and nearby chargers, station detail, and resolved pricing.
- Connector status check before starting (triggers a fresh status from the station).
- Start a session, stop a session, and list the driver's active sessions.
- Reservations: create and cancel a reservation for a connector.

Reference: [Portal Chargers](https://www.evtivity.com/api-reference/portal-chargers).

## Sessions and activity

What it powers: the Activity tab, the session detail screen, and the monthly statement.

- Session list (filterable by month), session detail, and live power and energy history.
- Monthly summary and monthly statement totals.
- Set the vehicle on a session for mileage estimates.

Reference: [Portal Sessions](https://www.evtivity.com/api-reference/portal-sessions).

## Payments

What it powers: the Payment Methods screen and the card forms of each payment provider.

- Payment provider descriptor (`GET /v1/portal/payment-provider`): which provider is active and the public values its card form needs. The app picks its Stripe, Adyen, or test provider module from it, or shows that the provider is not supported.
- Card setup session (setup intent, and the Stripe ephemeral key for the payment sheet).
- Card setup steps: `POST /v1/portal/payment-methods/setup/submit` and `setup/details`. A step answers `saved`, `action_required` (3D Secure), or `refused`. For Adyen the app sends its return URL, which must match `mobile.app.urlSchemes` or `mobile.app.androidPackageNames`.
- List, set-default, and remove cards.

Reference: [Portal Payments](https://www.evtivity.com/api-reference/portal-payments).

## Account, preferences, and favorites

What it powers: the Account tab profile, notification preferences, and saved chargers.

- Update profile and language, timezone, and theme preferences.
- Email, SMS, and push notification preferences.
- Favorite stations: list, check, add, and remove.

Reference: [Portal Driver](https://www.evtivity.com/api-reference/portal-driver).

## Vehicles

What it powers: the Vehicles screen and the mileage-estimate vehicle picker.

- List, add, and remove vehicles, and look up efficiency by make and model.

Reference: [Portal Vehicles](https://www.evtivity.com/api-reference/portal-vehicles).

## RFID cards

What it powers: the RFID screen where a driver adds and activates a charging card.

- List tokens, add a card, and toggle a card active or inactive.

Reference: [Portal Tokens](https://www.evtivity.com/api-reference/portal-tokens).

## Support

What it powers: the Support tab and the case chat.

- List and create support cases, post messages, and upload and download attachments.

Reference: [Portal Support](https://www.evtivity.com/api-reference/portal-support).

## Notifications and push

What it powers: the notification bell, the in-app drawer, and native push delivery.

- List notifications, the unread count, and mark-as-read.
- Register and remove the device push token (Expo push). See [Push notifications](https://www.evtivity.com/docs/mobile-app/push).

Reference: [Portal Notifications](https://www.evtivity.com/api-reference/portal-notifications).

## Real-time updates

What it powers: live updates such as an operator reply appearing in a support chat.

- A Server-Sent Events stream of driver-scoped events.

Reference: [Portal Events](https://www.evtivity.com/api-reference/portal-events).

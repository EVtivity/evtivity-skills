---
name: evtivity-mobile-app
description: Build, white-label, ship and support the open-source EVtivity driver mobile app (Expo, React Native, iOS and Android). Covers the app overview, setup and first run, configuring Expo (app.config.ts, brands, env vars, identifiers, plugins), making changes (project structure, conventions, adding a screen), testing (typecheck, lint, on-device checks), running on a real device (Android over USB or Wi-Fi, iOS Simulator, physical iPhone), EAS and local builds, push notifications (EAS project id, APNs, FCM), App Store and Google Play submission, white-labeling and licensing (Adyen return settings mobile.app.urlSchemes and mobile.app.androidPackageNames), and the /v1/portal/ APIs the app uses. Also covers the end user guide (getting started, find a charger, start and stop a charge, payments, reservations, activity and statements, vehicles, RFID cards, favorites, station watch, support, and account and settings). Use when an operator builds or brands the app, or when someone helps a driver use it.
license: MIT
compatibility: Per the docs, needs the latest Node.js LTS, Git, npx expo and npx eas-cli, Android Studio with JDK 17 for Android, macOS with Xcode for iOS, a development build (not Expo Go), and a running EVtivity CSMS API reachable from the device.
metadata:
  evtivity-version: "0.1.39"
  evtivity-docs-section: mobile-app
---

# EVtivity Mobile App

The EVtivity mobile app is the open-source native driver app. It is a thin client: pricing, payments and OCPP all live in the CSMS, and the app calls the driver API under `/v1/portal/`. Source: https://github.com/EVtivity/evtivity-mobile-app (public).

The docs pages listed below are the source of truth. Open the page for exact commands, labels and settings. This file tells you which page to open, in what order, and how to confirm each step.

Two audiences:

- Operators and developers who build, brand and ship the app (Part A).
- People helping a driver use the app (Part B, the end user guide).

The web driver portal has the same features on the same API. See `evtivity-portal`.

## Page map

### Developer pages

| Page id | URL | Use it for |
|---|---|---|
| mobile-app/overview | https://www.evtivity.com/docs/mobile-app/overview | What the app is, stack, how it connects to the CSMS, six languages, repo and license |
| mobile-app/setup | https://www.evtivity.com/docs/mobile-app/setup | Prerequisites, clone and install, `.env`, first development build |
| mobile-app/configure | https://www.evtivity.com/docs/mobile-app/configure | `app.config.ts`, the active brand, environment variables, ATS and cleartext, plugins, identifiers |
| mobile-app/develop | https://www.evtivity.com/docs/mobile-app/develop | Project structure, conventions, adding a screen, when a change needs a relaunch |
| mobile-app/testing | https://www.evtivity.com/docs/mobile-app/testing | Typecheck, lint, on-device checks, what to check after a change |
| mobile-app/real-device | https://www.evtivity.com/docs/mobile-app/real-device | Android over USB and Wi-Fi, iOS Simulator, physical iPhone, standalone |
| mobile-app/build | https://www.evtivity.com/docs/mobile-app/build | EAS profiles (development, preview, production), EAS and local builds |
| mobile-app/push | https://www.evtivity.com/docs/mobile-app/push | EAS project id, APNs key, FCM, test delivery |
| mobile-app/app-store | https://www.evtivity.com/docs/mobile-app/app-store | EAS Submit, App Store and Google Play requirements, versioning |
| mobile-app/white-labeling | https://www.evtivity.com/docs/mobile-app/white-labeling | Brand model, running a network under its own brand, Adyen return settings, theming, licensing, new brand checklist |
| mobile-app/api-reference | https://www.evtivity.com/docs/mobile-app/api-reference | The `/v1/portal/` APIs by app area, custom request headers, device attestation |

### End user guide pages

| Page id | URL | Use it for |
|---|---|---|
| mobile-app/guide/overview | https://www.evtivity.com/docs/mobile-app/guide/overview | What drivers can do, getting the app, the five tabs |
| mobile-app/guide/getting-started | https://www.evtivity.com/docs/mobile-app/guide/getting-started | Create an account, sign in, recover a password, MFA, Face ID or fingerprint |
| mobile-app/guide/find-a-charger | https://www.evtivity.com/docs/mobile-app/guide/find-a-charger | Search, Nearby, Scan QR, the station detail |
| mobile-app/guide/start-and-stop-a-charge | https://www.evtivity.com/docs/mobile-app/guide/start-and-stop-a-charge | Start, one session at a time, the live screen, stop, after charging |
| mobile-app/guide/payments | https://www.evtivity.com/docs/mobile-app/guide/payments | Add a card (Stripe, Adyen, test provider), 3D Secure, older app versions, default, remove |
| mobile-app/guide/reservations | https://www.evtivity.com/docs/mobile-app/guide/reservations | Reserve now or scheduled, Upcoming and Past, cancel, fees |
| mobile-app/guide/activity-and-statements | https://www.evtivity.com/docs/mobile-app/guide/activity-and-statements | Sessions by month, six-month trend chart, monthly statement |
| mobile-app/guide/vehicles | https://www.evtivity.com/docs/mobile-app/guide/vehicles | Add or remove a vehicle, assign a vehicle to a session |
| mobile-app/guide/rfid-cards | https://www.evtivity.com/docs/mobile-app/guide/rfid-cards | Add an RFID card, activate or deactivate it |
| mobile-app/guide/favorites | https://www.evtivity.com/docs/mobile-app/guide/favorites | Save, open and remove favorite stations |
| mobile-app/guide/station-watch | https://www.evtivity.com/docs/mobile-app/guide/station-watch | Notify me when free, the Watching list, limits |
| mobile-app/guide/support | https://www.evtivity.com/docs/mobile-app/guide/support | Notification inbox, open a support case, case chat |
| mobile-app/guide/account-and-settings | https://www.evtivity.com/docs/mobile-app/guide/account-and-settings | Personal info, Show prices, security and biometrics, notification channels, About, sign out |

## Part A: build and ship the app

### A1. Prerequisites and first run

Pages: mobile-app/overview, then mobile-app/setup.

1. Have a running CSMS and its API URL. Local stack: `evtivity-getting-started` (API on port 7102). Hosted: `evtivity-deployment`.
2. Clone the repo, `npm install`, and create `.env` with `EXPO_PUBLIC_API_URL` and `ACTIVE_BRAND`.
3. Run a development build: `npx expo run:ios` or, with JDK 17 as `JAVA_HOME`, `npx expo run:android`. Start Metro with `npx expo start --dev-client` if it is not running.
4. Sign in with a driver from the CSMS. Local demo driver: `driver@evtivity.local` / `driver123`.

Decision points:

- Expo Go does not work. The app has custom native modules, so it needs a development build.
- `EXPO_PUBLIC_API_URL` is baked into the bundle. On a physical device use a host the device can reach, such as `http://192.168.1.50:7102`, never `localhost`.

Check it worked: the app connects to Metro and shows the login screen, and sign-in succeeds.

### A2. Configure and brand

Pages: mobile-app/configure, then mobile-app/white-labeling.

1. Add or edit a brand under `brands/` (name, slug, scheme, `iosBundleId`, `androidPackage`, `apiUrl`, `easProjectId`, legal URLs, colors, icons, languages). You rarely edit `app.config.ts` itself.
2. Select it with `ACTIVE_BRAND`.
3. Configure branding in the CSMS Settings too (company name, logo, colors, legal pages). See `evtivity-csms` and `evtivity-guides` (white-labeling).
4. With Adyen as the payment provider, add each published brand's `scheme` to `mobile.app.urlSchemes` and its `androidPackage` to `mobile.app.androidPackageNames` on the CSMS. These JSON list settings have no dashboard field. Set them through Helm, CDK or `PUT /v1/settings/:key` (`evtivity-configuration`, `evtivity-integrations`). A missing brand gets 400 `VALIDATION_ERROR` when saving an Adyen card that needs 3D Secure.

Gotchas:

- Brand and `app.config.ts` changes take effect only after restarting Metro or rebuilding. A JavaScript reload is not enough.
- Set the bundle id and package before the first store submission. Changing them later creates a new store listing.
- A plain HTTP API needs the ATS exception (iOS) and the `withAndroidCleartext` plugin (Android). Both apply automatically for a non-local HTTP host. Otherwise every request fails with "Network request failed". Use HTTPS in production.
- License: the app is BSL 1.1. Free production use covers one branded app for one charging network. Branded apps for several independent networks need a commercial license. Read the Licensing section of mobile-app/white-labeling before advising an operator.

### A3. Change, test, run on a device

Pages: mobile-app/develop, mobile-app/testing, mobile-app/real-device.

1. Follow the structure and conventions in mobile-app/develop. Do not use the React Native `Modal` component on this build. Render overlays in-tree.
2. Run the static checks from mobile-app/testing:

   ```bash
   npx tsc --noEmit
   npx eslint <changed-files>
   ```

3. Verify on a simulator or device. i18n and native config changes need a full relaunch, not a Metro reload.
4. Android over USB: `npx expo run:android`, then `adb reverse tcp:8081 tcp:8081`. Re-run `adb reverse` whenever the app shows "No script URL provided".
5. Use a physical device for device attestation and push. Simulators cannot produce attestation tokens or push tokens.

Check it worked: the items under "What to check after a change" in mobile-app/testing pass (light and dark themes, text contrast, lists and details in sync, pull-to-refresh).

When a release build behaves differently from the dev build, suspect native config first: cleartext HTTP, attestation, or a value that needs a rebuild.

### A4. Push notifications

Page: mobile-app/push.

1. `npx eas-cli login` and `npx eas-cli init`. Copy the printed `projectId` into the brand's `easProjectId`.
2. iOS: `npx eas-cli credentials`, set up a Push Notifications key, enable the capability.
3. Android: create a Firebase project, add `google-services.json`, point `android.googleServicesFile` at it, upload the FCM v1 service-account key with `npx eas-cli credentials`.
4. Build again. Credentials take effect only in a new build.
5. Send a test through Expo Push with a token from `driver_push_tokens` (the curl is on the page), then trigger a real event with the driver's push preference on.

Safety: `google-services.json` and service-account keys are secrets. Keep them out of version control. Do not paste them into chat or commit them.

Until all three pieces exist the Push toggle saves a preference but nothing is delivered. The in-app notification drawer works regardless.

### A5. Build and release

Pages: mobile-app/build, then mobile-app/app-store.

1. Pick a profile: `development`, `preview` (internal testers) or `production` (store).
2. EAS: `npx eas-cli build --platform <android|ios> --profile <profile>`. Local: `npx expo run:android --variant release` or `npx expo run:ios --configuration Release`.
3. Submit: `npx eas-cli submit --platform <ios|android> --profile production`. Each brand is its own store listing under the operator's own developer accounts.
4. Meet the store requirements on mobile-app/app-store: App Store capabilities, privacy details, export compliance and review notes, Google Play Data safety and privacy policy URL, a testing track before production.

Build and submit act on the operator's accounts and stores. Confirm with the user before running `eas build` or `eas submit`, and never run them with someone else's credentials.

`app.config.ts` is evaluated at build time. Any brand or environment change needs a new build.

### A6. API surface

Page: mobile-app/api-reference. Full route catalog and auth: `evtivity-api`.

- Base URL is `EXPO_PUBLIC_API_URL`. Driver routes live under `/v1/portal/`. Branding and features are public.
- The app sends `X-Client: mobile` (tokens in the body, no cookies, no reCAPTCHA), `X-Device-Id` (refresh tokens are device-bound) and the Bearer token.
- With device attestation on, login, register and forgot-password also need the attestation headers after a challenge.

Quick check that a CSMS is reachable for the app:

```bash
EVTIVITY_API=http://localhost:7102
curl -s "$EVTIVITY_API/v1/portal/branding"
curl -s "$EVTIVITY_API/v1/portal/features"
DRIVER_TOKEN=$(curl -s "$EVTIVITY_API/v1/portal/auth/login" \
  -H 'Content-Type: application/json' -H 'X-Client: mobile' -H 'X-Device-Id: test-device-1' \
  -d '{"email":"driver@evtivity.local","password":"driver123"}' | jq -r .token)
curl -s "$EVTIVITY_API/v1/portal/payment-provider" -H "Authorization: Bearer $DRIVER_TOKEN"
```

A login refused with `ATTESTATION_FAILED` means the CSMS requires device attestation, which only a real app build on a device can provide.

## Part B: help a driver use the app

Start with mobile-app/guide/overview: five tabs (Home, Charge, Activity, Reserve, Account). Features the operator turned off (reservations, roaming, payments) do not appear.

Map the driver's question to a page:

| Driver says | Page |
|---|---|
| "How do I sign up or sign in?", "I forgot my password", MFA, Face ID | mobile-app/guide/getting-started |
| "Where is a charger?", QR scanning, location permission | mobile-app/guide/find-a-charger |
| "It will not start", "How do I stop?", "Start button is gone" | mobile-app/guide/start-and-stop-a-charge |
| Card form, 3D Secure, "Update the app" message, test mode | mobile-app/guide/payments |
| Booking or cancelling a connector, cancellation fee | mobile-app/guide/reservations |
| History, trend chart, monthly statement | mobile-app/guide/activity-and-statements |
| Distance or range numbers look wrong | mobile-app/guide/vehicles |
| Tap-to-charge card, lost card | mobile-app/guide/rfid-cards |
| Saved stations | mobile-app/guide/favorites |
| "Tell me when a charger frees up" | mobile-app/guide/station-watch |
| Notifications inbox, contacting the operator | mobile-app/guide/support |
| Language, units, Show prices, notification channels, About, sign out | mobile-app/guide/account-and-settings |

Common answers from those pages:

- Start fails: the driver needs a saved card unless the network is free, an **Available** connector, and the cable plugged in. Only one session runs at a time. The station detail shows **View Active Session** while one runs.
- A card form replaced by "Update the app..." means the app version does not support the operator's payment provider. Install the latest version. Saved cards keep working.
- "Payments are not set up for this operator." is an operator-side setup issue (`evtivity-integrations`).
- Lost RFID card: deactivate it at once.
- Accurate distance: assign the right vehicle to each session.
- Push not arriving: check Account > Notifications, then the operator's push setup (Part A4).

## When the pages disagree

Tell the user which source you used.

- Toolchain versions: mobile-app/overview says Expo SDK 52 and React Native 0.76. The public repo's `package.json` on `main` uses Expo `~57.0.25` and React Native `0.86.3`, and its `SETUP.md` names Expo SDK 57. Trust the repo for versions.
- Tests: mobile-app/testing lists only static checks and on-device verification. The repo also has `npm test` (Jest). Run it too.
- Build numbers: mobile-app/build and mobile-app/app-store say production builds auto-increment. The repo's `eas.json` sets `appVersionSource: local` and no auto-increment on the production profile. Check `eas.json` before relying on it.
- MFA methods: mobile-app/guide/getting-started lists authenticator app, email and SMS. mobile-app/guide/account-and-settings lists authenticator app and email.

## Related skills

- `evtivity-getting-started`: run a local CSMS for the app to talk to.
- `evtivity-configuration`: settings such as `mobile.app.urlSchemes` and `mobile.app.androidPackageNames`.
- `evtivity-deployment`: a hosted CSMS API with HTTPS for production builds.
- `evtivity-csms`: drivers, branding, notifications and support on the operator side.
- `evtivity-portal`: the web driver portal with the same features.
- `evtivity-integrations`: Stripe, Adyen (including the mobile return) and the test payment provider.
- `evtivity-simulator`: simulated stations to charge against from the app.
- `evtivity-conformance`: OCPP conformance testing.
- `evtivity-guides`: white-labeling, portal setup and RFID guides.
- `evtivity-api`: the `/v1/portal/` route catalog, auth and error codes.
- `evtivity-troubleshoot`: network errors, failed starts, refused cards.
- `evtivity-report-issue`: file a bug with the right details.

## Reference pages

Every docs page this skill covers is in `references/`, generated from the website docs. Never edit those files. Read the reference for details, and link the live page when you answer.

| Page id | Reference | Live page |
|---|---|---|
| `mobile-app/api-reference` | `references/api-reference.md` | https://www.evtivity.com/docs/mobile-app/api-reference |
| `mobile-app/app-store` | `references/app-store.md` | https://www.evtivity.com/docs/mobile-app/app-store |
| `mobile-app/build` | `references/build.md` | https://www.evtivity.com/docs/mobile-app/build |
| `mobile-app/configure` | `references/configure.md` | https://www.evtivity.com/docs/mobile-app/configure |
| `mobile-app/develop` | `references/develop.md` | https://www.evtivity.com/docs/mobile-app/develop |
| `mobile-app/guide/account-and-settings` | `references/guide-account-and-settings.md` | https://www.evtivity.com/docs/mobile-app/guide/account-and-settings |
| `mobile-app/guide/activity-and-statements` | `references/guide-activity-and-statements.md` | https://www.evtivity.com/docs/mobile-app/guide/activity-and-statements |
| `mobile-app/guide/favorites` | `references/guide-favorites.md` | https://www.evtivity.com/docs/mobile-app/guide/favorites |
| `mobile-app/guide/find-a-charger` | `references/guide-find-a-charger.md` | https://www.evtivity.com/docs/mobile-app/guide/find-a-charger |
| `mobile-app/guide/getting-started` | `references/guide-getting-started.md` | https://www.evtivity.com/docs/mobile-app/guide/getting-started |
| `mobile-app/guide/overview` | `references/guide-overview.md` | https://www.evtivity.com/docs/mobile-app/guide/overview |
| `mobile-app/guide/payments` | `references/guide-payments.md` | https://www.evtivity.com/docs/mobile-app/guide/payments |
| `mobile-app/guide/reservations` | `references/guide-reservations.md` | https://www.evtivity.com/docs/mobile-app/guide/reservations |
| `mobile-app/guide/rfid-cards` | `references/guide-rfid-cards.md` | https://www.evtivity.com/docs/mobile-app/guide/rfid-cards |
| `mobile-app/guide/start-and-stop-a-charge` | `references/guide-start-and-stop-a-charge.md` | https://www.evtivity.com/docs/mobile-app/guide/start-and-stop-a-charge |
| `mobile-app/guide/station-watch` | `references/guide-station-watch.md` | https://www.evtivity.com/docs/mobile-app/guide/station-watch |
| `mobile-app/guide/support` | `references/guide-support.md` | https://www.evtivity.com/docs/mobile-app/guide/support |
| `mobile-app/guide/vehicles` | `references/guide-vehicles.md` | https://www.evtivity.com/docs/mobile-app/guide/vehicles |
| `mobile-app/overview` | `references/overview.md` | https://www.evtivity.com/docs/mobile-app/overview |
| `mobile-app/push` | `references/push.md` | https://www.evtivity.com/docs/mobile-app/push |
| `mobile-app/real-device` | `references/real-device.md` | https://www.evtivity.com/docs/mobile-app/real-device |
| `mobile-app/setup` | `references/setup.md` | https://www.evtivity.com/docs/mobile-app/setup |
| `mobile-app/testing` | `references/testing.md` | https://www.evtivity.com/docs/mobile-app/testing |
| `mobile-app/white-labeling` | `references/white-labeling.md` | https://www.evtivity.com/docs/mobile-app/white-labeling |

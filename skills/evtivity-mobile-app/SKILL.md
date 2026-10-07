---
name: evtivity-mobile-app
description: "Build, white-label and ship the EVtivity driver mobile app (Expo, React Native, iOS, Android): brands, device runs, EAS builds, push notifications, App Store and Google Play release, plus the driver guide for the app. Use to build or brand the mobile app or help a driver with it. Not for the web portal (evtivity-portal)."
license: MIT
compatibility: Per the docs, needs the latest Node.js LTS, Git, npx expo and npx eas-cli, Android Studio with JDK 17 for Android, macOS with Xcode for iOS, a development build (not Expo Go), and a running EVtivity CSMS API reachable from the device.
metadata:
  evtivity-version: "0.1.41"
  evtivity-release: "v0.1.41-alpha.3"
  evtivity-commit: "83e6334e0f0d0359d3e082a2bd34e8c7c144ba2b"
  evtivity-docs-section: mobile-app
---

# EVtivity Mobile App

Not for: the web driver portal (use evtivity-portal), payment provider setup on the CSMS (use evtivity-integrations), CSMS branding settings (use evtivity-csms and evtivity-guides).

The EVtivity mobile app is the open-source native driver app. It is a thin client: pricing, payments and OCPP all live in the CSMS, and the app calls the driver API under `/v1/portal/`. Source: https://github.com/EVtivity/evtivity-mobile-app (public).

The docs pages are the source of truth. Open the reference for exact commands, labels and settings.

Two audiences: operators and developers who build, brand and ship the app (Part A), and people helping a driver use it (Part B).

## Part A: build and ship the app

### A1. Prerequisites and first run (`references/overview.md`, `references/setup.md`)

1. Have a running CSMS and its API URL. Local stack: evtivity-getting-started (API on port 7102). Hosted: evtivity-deployment.
2. Clone the repo, `npm install`, and create `.env` with `EXPO_PUBLIC_API_URL` and `ACTIVE_BRAND`.
3. Run a development build: `npx expo run:ios` or, with JDK 17 as `JAVA_HOME`, `npx expo run:android`. Start Metro with `npx expo start --dev-client` if it is not running.
4. Sign in with a driver from the CSMS. Local demo driver: `driver@evtivity.local` / `driver123`.

- Expo Go does not work. The app has custom native modules, so it needs a development build.
- `EXPO_PUBLIC_API_URL` is baked into the bundle. On a physical device use a host the device can reach, such as `http://192.168.1.50:7102`, never `localhost`.

### A2. Configure and brand (`references/configure.md`, `references/white-labeling.md`)

1. Add or edit a brand under `brands/` (name, slug, scheme, `iosBundleId`, `androidPackage`, `apiUrl`, `easProjectId`, legal URLs, colors, icons, languages). You rarely edit `app.config.ts` itself.
2. Select it with `ACTIVE_BRAND`.
3. Configure branding in the CSMS settings too (company name, logo, colors, legal pages).
4. With Adyen as the payment provider, add each published brand's `scheme` to `mobile.app.urlSchemes` and its `androidPackage` to `mobile.app.androidPackageNames` on the CSMS. These JSON list settings have no dashboard field: set them through Helm, CDK or `PUT /v1/settings/:key`. A missing brand gets 400 `VALIDATION_ERROR` when saving an Adyen card that needs 3D Secure.

- Brand and `app.config.ts` changes take effect only after restarting Metro or rebuilding.
- Set the bundle id and package before the first store submission. Changing them later creates a new store listing.
- A plain HTTP API needs the ATS exception (iOS) and the `withAndroidCleartext` plugin (Android), applied automatically for a non-local HTTP host. Otherwise every request fails with "Network request failed". Use HTTPS in production.
- License: the app is BSL 1.1. Free production use covers one branded app for one charging network. Read the Licensing section of the white-labeling page before advising an operator.

### A3. Change, test, run on a device (`references/develop.md`, `references/testing.md`, `references/real-device.md`)

1. Follow the structure and conventions of the develop page. Do not use the React Native `Modal` component: render overlays in-tree.
2. Static checks: `npx tsc --noEmit` and `npx eslint <changed-files>`. Run the repository's test script too when it has one (`npm test`).
3. Verify on a simulator or device. i18n and native config changes need a full relaunch, not a Metro reload.
4. Android over USB: `npx expo run:android`, then `adb reverse tcp:8081 tcp:8081`. Re-run `adb reverse` when the app shows "No script URL provided".
5. Use a physical device for device attestation and push.

Check it worked: the items under "What to check after a change" on the testing page pass. When a release build behaves differently from the dev build, suspect native config first: cleartext HTTP, attestation, or a value that needs a rebuild.

### A4. Push notifications (`references/push.md`)

1. `npx eas-cli login` and `npx eas-cli init`. Copy the printed `projectId` into the brand's `easProjectId`.
2. iOS: `npx eas-cli credentials`, set up a Push Notifications key, enable the capability.
3. Android: create a Firebase project, add `google-services.json`, point `android.googleServicesFile` at it, upload the FCM v1 service-account key with `npx eas-cli credentials`.
4. Build again. Credentials take effect only in a new build.
5. Send a test through Expo Push with a token from `driver_push_tokens`, then trigger a real event with the driver's push preference on.

`google-services.json` and service-account keys are secrets. Keep them out of version control and chat.

### A5. Build and release (`references/build.md`, `references/app-store.md`)

1. Pick a profile: `development`, `preview` (internal testers) or `production` (store).
2. EAS: `npx eas-cli build --platform <android|ios> --profile <profile>`. Local: `npx expo run:android --variant release` or `npx expo run:ios --configuration Release`.
3. Submit: `npx eas-cli submit --platform <ios|android> --profile production`. Each brand is its own store listing under the operator's developer accounts.
4. Meet the store requirements on the app-store page. Check how `eas.json` numbers builds before a submission.

Build and submit act on the operator's accounts. Confirm with the user before `eas build` or `eas submit`, and never use someone else's credentials. `app.config.ts` is evaluated at build time: any brand or environment change needs a new build.

### A6. API surface (`references/api-reference.md`)

- Base URL is `EXPO_PUBLIC_API_URL`. Driver routes live under `/v1/portal/`. Full route catalog: evtivity-api.
- The app sends `X-Client: mobile` (tokens in the body, no cookies, no reCAPTCHA), `X-Device-Id` (refresh tokens are device-bound) and the Bearer token.
- With device attestation on, login, register and forgot-password also need the attestation headers after a challenge.

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

Start with `references/guide-overview.md`: five tabs (Home, Charge, Activity, Reserve, Account). Features the operator turned off (reservations, roaming, payments) do not appear.

| Driver says | Reference |
|---|---|
| "How do I sign up or sign in?", forgot password, MFA, Face ID | `references/guide-getting-started.md` |
| "Where is a charger?", QR scanning, location permission | `references/guide-find-a-charger.md` |
| "It will not start", "How do I stop?" | `references/guide-start-and-stop-a-charge.md` |
| Card form, 3D Secure, "Update the app" message, test mode | `references/guide-payments.md` |
| Booking or cancelling a connector, cancellation fee | `references/guide-reservations.md` |
| History, trend chart, monthly statement | `references/guide-activity-and-statements.md` |
| Distance or range numbers look wrong | `references/guide-vehicles.md` |
| Tap-to-charge card, lost card | `references/guide-rfid-cards.md` |
| Saved stations | `references/guide-favorites.md` |
| "Tell me when a charger frees up" | `references/guide-station-watch.md` |
| Notifications inbox, contacting the operator | `references/guide-support.md` |
| Language, units, Show prices, notification channels, MFA settings, sign out | `references/guide-account-and-settings.md` |

Common answers:

- Start fails: the driver needs a saved card unless the network is free, an **Available** connector, and the cable plugged in. Only one session runs at a time.
- "Update the app..." instead of a card form: the app version does not support the operator's payment provider. Install the latest version. Saved cards keep working.
- "Payments are not set up for this operator.": operator-side setup (evtivity-integrations).
- Lost RFID card: deactivate it at once. Accurate distance: assign the right vehicle to each session.
- Push not arriving: check Account > Notifications, then the operator's push setup (A4).

## References

Generated from the website docs. Never edit them. The first line of each file is the live page URL: link it when you answer. The developer pages are named in Part A, the driver guide pages in Part B.

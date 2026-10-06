Generated from https://www.evtivity.com/docs/mobile-app/overview (website commit 900fb20). Do not edit.

# Mobile App

The open-source EVtivity driver mobile app built with Expo and React Native on top of the EVtivity CSMS.

The EVtivity mobile app is an open-source driver application built with Expo and React Native. It runs on iOS and Android and talks to the same EVtivity CSMS backend that powers the web driver portal: drivers find chargers, start and stop sessions, manage payment methods and vehicles, view activity, make reservations, and open support cases.

This section has two parts. The [End User Guide](https://www.evtivity.com/docs/mobile-app/guide/overview) is for drivers and walks through using the app: finding chargers, starting sessions, paying, reserving, and getting support. The developer guides that follow cover running the app, changing it, building it, testing it on real devices, and shipping it to the app stores, plus white-labeling so a network operator can publish the app under its own brand.

![EVtivity mobile app architecture](https://www.evtivity.com/images/mobile-app-architecture.png)

## What it is

- Expo SDK 57, React Native 0.86 on the New Architecture (Fabric and Bridgeless).
- File-based routing with `expo-router`.
- Styling with NativeWind (Tailwind classes in React Native).
- Server state with TanStack Query, talking to the CSMS REST API.
- Local native modules for device attestation (Apple App Attest, Google Play Integrity).
- Six languages built in (English, Spanish, Simplified Chinese, German, Korean, Traditional Chinese), driver-selectable in-app.
- A white-label brand system so a single codebase ships under many brands.

The app is a thin client. All business logic, pricing, payments, and OCPP communication live in the CSMS. The app reads and writes through the `/v1/portal/*` API and reflects real-time changes through polling and server events.

## How it connects to the CSMS

The API base URL is baked into the JavaScript bundle at build time from the `EXPO_PUBLIC_API_URL` environment variable (falling back to the active brand's `apiUrl`). Every request carries the driver's bearer token. Sensitive flows are protected by device attestation, which the CSMS verifies server-side.

> **Note:**
>
> The app is the driver-facing counterpart to the web portal. If a feature exists in the portal, it almost always exists in the app and uses the same backend endpoint.

## Languages

The app ships full translations for six languages: English, Spanish, Simplified Chinese (简体中文), German (Deutsch), Korean (한국어), and Traditional Chinese (繁體中文). A driver picks their language in Account, and the choice applies immediately, persists across launches, and syncs to their server profile so emails and SMS use the same language. A white-label brand can narrow the offered set to any subset of the six; see [White-labeling](https://www.evtivity.com/docs/mobile-app/white-labeling).

## The guides

- **Setup and first run** - prerequisites, install, environment, and running the dev client.
- **Configure Expo** - `app.config.ts`, brands, environment variables, identifiers, and plugins.
- **Making changes** - project structure, conventions, and how to add a screen.
- **Testing** - typecheck, lint, and on-device verification.
- **Run on a real device** - Android over USB, iOS Simulator, and a physical iPhone.
- **Build** - development, preview, and production builds with EAS or locally.
- **Push notifications** - wiring APNs and FCM so push actually delivers.
- **Submit to the app stores** - App Store Connect and Google Play.
- **White-labeling** - run a network under your own brand.

## Repository

The app lives in its own open-source repository at [github.com/EVtivity/evtivity-mobile-app](https://github.com/EVtivity/evtivity-mobile-app). It is licensed under the same terms as the rest of the EVtivity platform. Clone it, point it at a CSMS instance, and you have a working driver app in minutes.

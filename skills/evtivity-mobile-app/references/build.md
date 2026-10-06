Generated from https://www.evtivity.com/docs/mobile-app/build (website commit 900fb20). Do not edit.

# Build

Development, preview, and production builds of the EVtivity mobile app with EAS or locally.

There are two ways to build: EAS (Expo's cloud build service) and local builds on your machine. EAS is the path to shareable artifacts and store submission; local builds are fast for testing on a connected device.

## Build profiles

`eas.json` defines the profiles:

- `development` - a development client with the dev menu, for daily work.
- `preview` - an internal-distribution build (an installable APK or an ad-hoc iOS build) for testers.
- `production` - the store build. The build number is not auto-incremented: it comes from `app.config.ts`, which `scripts/release.sh` sets from the release version.

## EAS builds

Sign in once, then build per platform and profile:

```bash
npx eas-cli login
npx eas-cli build --platform android --profile preview
npx eas-cli build --platform ios --profile production
```

EAS resolves credentials (signing keys, push keys) and returns a downloadable artifact, or submits it directly when chained with EAS Submit.

## Local builds

A local build compiles the native project on your machine and installs it on a connected device or simulator.

```bash
# Standalone Android release (bundles JS, runs without Metro)
export JAVA_HOME="$(/usr/libexec/java_home -v 17)"
npx expo run:android --variant release

# iOS
npx expo run:ios --configuration Release
```

A release build embeds the JavaScript bundle, so the resulting app runs untethered. It still needs network access to reach the CSMS API.

> **Warning:**
>
> If the API is plain HTTP, the release build must allow cleartext traffic, or every request fails with "Network request failed". The `withAndroidCleartext` plugin and the iOS ATS exception handle this automatically when the API host is a non-local HTTP remote. For production, use HTTPS.

## What goes into a build

`expo run` and `eas build` evaluate `app.config.ts` at build time, so the active brand, identifiers, icons, environment variables, and the EAS project id are all captured then. A change to a brand or to the environment requires a new build to take effect.

## Next steps

- [Push notifications](https://www.evtivity.com/docs/mobile-app/push) before a production build if you want push to work.
- [Submit to the app stores](https://www.evtivity.com/docs/mobile-app/app-store).

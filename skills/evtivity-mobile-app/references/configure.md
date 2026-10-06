Generated from https://www.evtivity.com/docs/mobile-app/configure (website commit 257c8b8). Do not edit.

# Configure Expo

How app.config.ts, the brand system, environment variables, identifiers, and plugins shape the EVtivity mobile app.

The app uses a dynamic Expo config (`app.config.ts`) driven by the active brand and environment variables. You rarely edit `app.config.ts` directly; instead you add or edit a brand and set environment variables.

## The active brand

`ACTIVE_BRAND` (environment variable, default `default`) selects an entry in `brands/`. The brand supplies the app name, scheme, iOS bundle id, Android package, API URL, languages, legal URLs, EAS project id, and theme colors. See [White-labeling](https://www.evtivity.com/docs/mobile-app/white-labeling) for the full model.

A brand looks like this:

```js
{
  name: 'EVtivity',
  slug: 'evtivity',
  scheme: 'evtivity',
  iosBundleId: 'com.evtivity.driver',
  androidPackage: 'com.evtivity.driver',
  apiUrl: process.env.EXPO_PUBLIC_API_URL || 'https://api.evtivity.com',
  easProjectId: '...',
  termsUrl: 'https://your-portal/terms-of-service',
  privacyUrl: 'https://your-portal/privacy-policy',
  colors: { light: {...}, dark: {...} },
  // icon, splash, adaptiveIcon, languages
}
```

## Environment variables

- `EXPO_PUBLIC_API_URL` - the CSMS API base URL, baked into the bundle. Anything prefixed `EXPO_PUBLIC_` is embedded at build time.
- `ACTIVE_BRAND` - which brand to build.
- `EXPO_PUBLIC_APPATTEST_ENV` - `development` or `production` for Apple App Attest.

## What app.config.ts assembles

- App name, slug, scheme, icons, and splash from the brand.
- iOS `bundleIdentifier` and Android `package` from the brand.
- iOS App Transport Security: when the API URL is a plain HTTP remote, it adds an exception for that host so the app can reach a non-HTTPS backend.
- Android cleartext: the `withAndroidCleartext` plugin sets `usesCleartextTraffic` when the API host is a non-local HTTP remote, mirroring the iOS exception. Without it, release builds block an HTTP backend and every request fails with "Network request failed".
- `extra.eas.projectId` from the brand, required for push tokens.
- Config plugins: `expo-router`, `expo-secure-store`, `expo-local-authentication`, `expo-notifications`, `expo-camera`, Stripe, Adyen (`@adyen/react-native`, which patches the iOS app delegate and the Android main activity for the 3D Secure return), the App Attest plugin, and the cleartext plugin. The Adyen module needs a native build: it does not run in Expo Go.

> **Warning:**
>
> Brand values such as `easProjectId` and the legal URLs are baked into the bundle through `extra`. A change to a brand or to `app.config.ts` is only picked up when the config is re-evaluated, which means restarting Metro or rebuilding, not just a JavaScript reload.

## Identifiers and stores

The iOS bundle id and Android package come from the brand. They must match the identifiers you register in App Store Connect and Google Play. Changing them is a new app in the stores, so set them per brand before the first submission.

## Next steps

- [Making changes](https://www.evtivity.com/docs/mobile-app/develop) for project structure and conventions.
- [Push notifications](https://www.evtivity.com/docs/mobile-app/push) for the EAS project id and credentials.

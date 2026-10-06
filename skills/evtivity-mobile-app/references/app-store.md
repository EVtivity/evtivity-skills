Generated from https://www.evtivity.com/docs/mobile-app/app-store (website commit 0f3462e). Do not edit.

# Submit to the App Stores

Ship the EVtivity mobile app to the Apple App Store and Google Play.

Once you have a production build, EAS Submit uploads it to the stores. Each brand is a separate app listing, keyed by its bundle id and package name.

## Prerequisites

- A production build (see [Build](https://www.evtivity.com/docs/mobile-app/build)).
- An Apple Developer account and App Store Connect access (iOS).
- A Google Play Console account (Android).
- Store listings created with the same identifiers as the brand: iOS bundle id and Android package.

## Submit with EAS

```bash
npx eas-cli submit --platform ios --profile production
npx eas-cli submit --platform android --profile production
```

EAS uploads the latest build (or one you point it at) to App Store Connect and Google Play. From there you manage release tracks and review.

## Apple App Store

- Register the bundle id and enable capabilities the app uses: Push Notifications, App Attest, Sign in flows as applicable.
- Provide privacy details (data collection), an export-compliance answer, and screenshots for each device size.
- In review notes, explain the charging flow and that device attestation is used to protect driver accounts and payments, so reviewers understand the permissions.

## Google Play

- Register the package name and complete the Data safety form.
- Provide a privacy policy URL (the brand's legal URLs).
- Use an internal or closed testing track first, then promote to production.

## Versioning

`eas.json` auto-increments the build number for production builds. Bump the app version in the config when shipping user-facing releases, and keep store metadata in sync with the release.

> **Note:**
>
> Per-brand submission: because each brand has its own bundle id and package, you submit each brand as its own app. Set identifiers in the brand before the first submission, since changing them later creates a new store listing.

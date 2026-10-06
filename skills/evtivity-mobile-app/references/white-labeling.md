Generated from https://www.evtivity.com/docs/mobile-app/white-labeling (website commit 257c8b8). Do not edit.

# White-labeling

Run the EVtivity mobile app as your own branded driver app, and ship many brands from one codebase.

The mobile app is built to be white-labeled. One codebase produces many branded apps: each charging network can publish the driver app under its own name, icon, colors, identifiers, and legal pages, pointing at its own CSMS. Nothing in the screens is hard-coded to "EVtivity"; everything brandable comes from a brand definition.

The app carries the same Business Source License 1.1 as the EVtivity CSMS, so free production use is limited to a single charging network. A single operator may build and publish one branded app for its own network at no cost. The "one codebase, many brands" capability is a build-time feature, not a grant to run apps for multiple independent networks for free: publishing or operating branded apps for more than one independent network as a service requires a commercial license. See [Licensing](#licensing) below.

## The brand model

Every brand is an entry in `brands/`. The active brand is chosen at build time by the `ACTIVE_BRAND` environment variable. A brand supplies:

- **Identity**: `name`, `slug`, `scheme`.
- **Store identifiers**: `iosBundleId`, `androidPackage`.
- **Backend**: `apiUrl` (the CSMS this brand talks to).
- **Push**: `easProjectId`.
- **Legal**: `termsUrl`, `privacyUrl`.
- **Look**: `colors` (light and dark), `icon`, `splash`, `adaptiveIcon`.
- **Locales**: the `languages` offered.

`app.config.ts` reads the active brand and assembles the Expo config from it: app name, icons, bundle id, package, ATS and cleartext exceptions, plugins, and `extra.eas.projectId`. The brand values are baked into the JavaScript bundle through `extra`, so screens read them at runtime through the config helpers.

## How a network runs its own brand

A network operator runs three things: its own CSMS deployment, its own brand entry, and its own store listings. The flow from operator to driver:

1. **Stand up a CSMS.** The operator deploys its own EVtivity CSMS and configures branding in Settings (company name, logo, colors, legal pages). The CSMS serves the operator's drivers, stations, pricing, and payments.

2. **Add a brand entry.** In the app repo, add a brand under `brands/` with the operator's name, identifiers, theme, legal URLs, and `apiUrl` pointing at the operator's CSMS API.

3. **Build the branded app.** Set `ACTIVE_BRAND` to that brand and build. `app.config.ts` produces an app with the operator's name, icon, splash, colors, and bundle id, talking to the operator's backend.

4. **Publish under the operator's accounts.** Submit to the App Store and Google Play under the operator's developer accounts, using the brand's bundle id and package. Push credentials (APNs, FCM) belong to the operator too.

5. **Drivers use their network's app.** A driver installs the operator-branded app, which connects only to that operator's CSMS. Two operators run visually distinct apps, on separate backends, from the same source code.

## Card verification return (Adyen)

With Adyen as the payment provider, 3D Secure sends the driver to the bank's page and back into the app. The CSMS accepts that return only for the app builds it knows. List every brand you publish in two CSMS settings:

| Setting | Brand value | Default |
|---|---|---|
| `mobile.app.urlSchemes` | `scheme`. iOS returns to `<scheme>://payments/adyen`. | `["evtivity"]` |
| `mobile.app.androidPackageNames` | `androidPackage`. Android returns to `adyencheckout://<androidPackage>`. | `["com.evtivity.driver"]` |

Both settings are JSON lists and have no dashboard field. Set them on Helm (`appSettings.mobile.app.urlSchemes` and `appSettings.mobile.app.androidPackageNames`), on CDK (`appSettings['mobile.app.urlSchemes']` and `appSettings['mobile.app.androidPackageNames']`), or with `PUT /v1/settings/:key`. A scheme must be lowercase and cannot be `http`, `https`, or `adyencheckout`. A brand missing from the lists cannot save an Adyen card that needs 3D Secure: the API answers 400 `VALIDATION_ERROR`. See [Adyen](https://www.evtivity.com/docs/integrations/adyen#mobile-app).

Some branding is also served at runtime from the CSMS (`/v1/portal/branding`): the company name and logo can come from the operator's Settings, so a few visual details can change without an app release. Identifiers, icons, and store listings are build-time and per operator.

## Theming

The brand's `colors` feed the design system's light and dark palettes (the same tokens the components reference through NativeWind). Because components never hard-code colors, swapping the palette restyles the whole app. The branded backdrop and surfaces keep text contrast correct in both themes.

## Licensing

The mobile app is licensed under the Business Source License 1.1, the same license as the EVtivity CSMS, so the production grant is the same: free use is limited to a single charging network.

- **Permitted for free**: building, publishing, and operating one branded driver app for your own single charging network, pointing at your own CSMS. Development, testing, demonstration, educational, and non-profit use are always permitted.
- **Requires a commercial license**: publishing or operating branded versions of the app for more than one independent charging network (white-label as a service, resale, or multi-tenant platforms). The "one codebase, many brands" capability is a build-time feature, not a grant to run apps for multiple networks for free.

The license converts to Apache 2.0 four years after each version is released. The full terms live in the app repo at [LICENSE.md](https://github.com/EVtivity/evtivity-mobile-app/blob/main/LICENSE.md). For commercial licensing, contact evtivity@gmail.com.

> **Tip:**
>
> Keep brand-specific secrets (push keys, service accounts, signing) in each operator's own accounts and out of version control. The repository holds brand configuration, not credentials.

## Checklist for a new brand

- Brand entry in `brands/` with identity, identifiers, `apiUrl`, theme, and legal URLs.
- CSMS branding configured in the operator's Settings.
- With Adyen: the brand's `scheme` in `mobile.app.urlSchemes` and its `androidPackage` in `mobile.app.androidPackageNames` on the CSMS.
- EAS project id and push credentials under the operator's accounts.
- App Store and Google Play listings with the brand's identifiers.
- Icons and splash sized for both platforms.

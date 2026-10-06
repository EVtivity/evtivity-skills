Generated from https://www.evtivity.com/docs/mobile-app/push (website commit 0f3462e). Do not edit.

# Push Notifications

Wire APNs and FCM so the EVtivity mobile app delivers native push notifications.

The app code for push is already in place. Live delivery needs three things tied to your accounts: an EAS project id, an Apple APNs key, and a Firebase (FCM) project. Until all three exist, the Push toggle in Account then Notifications saves a preference but no native push is delivered.

## How push works

1. On launch the app requests permission, gets an Expo push token, and registers it with the CSMS at `/v1/portal/notifications/push-token`.
2. When a driver event fires (session, payment, reservation, support reply), the CSMS sends a native push through Expo Push, which relays to APNs on iOS and FCM on Android.
3. Delivery only happens when the driver's `push_enabled` preference is true. The Push toggle sets that flag.
4. The in-app notification drawer is separate and always works, regardless of this setup.

## Step 1: EAS project id

```bash
npx eas-cli login
npx eas-cli init
```

`eas init` prints a `projectId`. Because the config is dynamic, copy it into the active brand's `easProjectId` in `brands/`. Without it, no push token is minted. Simulators cannot get a device token, so test on a physical device.

## Step 2: iOS (APNs)

```bash
npx eas-cli credentials
```

Choose iOS, then set up a Push Notifications key. EAS signs into your Apple Developer account and uploads the key. Enable the Push Notifications capability on the app target as well.

## Step 3: Android (FCM)

1. Create a Firebase project, add an Android app with your package name, and download `google-services.json`.
2. Place it in the repo and point `android.googleServicesFile` at it in `app.config.ts`.
3. Run `npx eas-cli credentials`, choose Android, and upload the FCM v1 service-account key (with the Cloud Messaging API enabled).

> **Warning:**
>
> `google-services.json` and any service-account key are secrets. Keep them out of version control.

## Step 4: Build and test

A new build is required after wiring credentials. Then verify delivery directly through Expo Push using a token from `driver_push_tokens`:

```bash
curl -s -X POST https://exp.host/--/api/v2/push/send \
  -H 'Content-Type: application/json' \
  -d '{"to":"ExponentPushToken[xxxx]","title":"Test","body":"Hello"}'
```

A delivered banner confirms credentials and the project id are correct. Then trigger a real event to confirm the backend path with `push_enabled` true.

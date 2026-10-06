Generated from https://www.evtivity.com/docs/mobile-app/setup (website commit 257c8b8). Do not edit.

# Mobile App Setup

Prerequisites, install, environment, and running the EVtivity mobile app for the first time.

This guide gets the EVtivity mobile app running on your machine against a CSMS instance.

## Prerequisites

- The latest LTS release of Node.js, and Git.
- A running EVtivity CSMS and its API URL.
- For Android: Android Studio with the SDK and platform tools, plus JDK 17 (the Android Gradle Plugin requires Java 17).
- For iOS: macOS with Xcode and the iOS Simulator.
- The Expo CLI is invoked with `npx expo` (no global install needed).

> **Note:**
>
> You cannot use the Expo Go app. EVtivity ships custom native modules (device attestation), so it needs a development build, not Expo Go.

## Install

```bash
git clone https://github.com/EVtivity/evtivity-mobile-app.git
cd evtivity-mobile-app
npm install
```

## Configure the environment

Create a `.env` file with the API URL of the CSMS the app should talk to:

```bash
EXPO_PUBLIC_API_URL=http://192.168.1.50:7102
ACTIVE_BRAND=default
```

- `EXPO_PUBLIC_API_URL` is baked into the bundle. Use a host the device can reach (a LAN IP for a physical device, not `localhost`).
- `ACTIVE_BRAND` selects which entry under `brands/` drives the app name, identifiers, and theme. See [Configure Expo](https://www.evtivity.com/docs/mobile-app/configure).

## Run the development build

The first run compiles the native app and installs it on a simulator or device. After that, only JavaScript reloads through Metro.

On iOS (Simulator):

```bash
npx expo run:ios
```

On Android (note JDK 17):

```bash
export JAVA_HOME="$(/usr/libexec/java_home -v 17)"
npx expo run:android
```

If Metro is not already running, start it in a separate terminal:

```bash
npx expo start --dev-client
```

The app launches, connects to Metro, downloads the JavaScript bundle, and shows the login screen. Sign in with a driver account from your CSMS.

> **Tip:**
>
> A development build loads JavaScript from Metro at launch, so your computer must be reachable. To run the app standalone, make a release build (see [Build](https://www.evtivity.com/docs/mobile-app/build)).

## Next steps

- [Configure Expo](https://www.evtivity.com/docs/mobile-app/configure) to set identifiers, icons, and brands.
- [Run on a real device](https://www.evtivity.com/docs/mobile-app/real-device) for USB and Wi-Fi testing.

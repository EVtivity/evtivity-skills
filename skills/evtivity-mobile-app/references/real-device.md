Generated from https://www.evtivity.com/docs/mobile-app/real-device (website commit 900fb20). Do not edit.

# Run on a Real Device

Load the EVtivity mobile app on a physical Android phone, an iPhone, and the iOS Simulator.

A development build loads JavaScript from Metro on your computer. The device needs a path to Metro, and the app must be a development build, not Expo Go.

## Android over USB

1. Enable Developer options and USB debugging on the phone, then connect it over USB and accept the authorization prompt.
2. Build and install onto the connected device (JDK 17 is required for the Android Gradle Plugin):

   ```bash
   export JAVA_HOME="$(/usr/libexec/java_home -v 17)"
   npx expo run:android
   ```

3. Map the phone's `localhost:8081` to your computer's Metro so the app can reach the bundler:

   ```bash
   adb reverse tcp:8081 tcp:8081
   ```

> **Warning:**
>
> The `adb reverse` mapping is cleared whenever Metro or adb restarts. If the app suddenly stops loading with "No script URL provided", re-run `adb reverse tcp:8081 tcp:8081` and reload.

## Android over Wi-Fi

Instead of USB, the dev client can reach Metro at your computer's LAN address (for example `http://192.168.1.50:8081`) as long as the phone and computer are on the same network. No cable is needed, but your computer must be running Metro.

## iOS Simulator

```bash
npx expo run:ios
```

To target a specific simulator, boot it first and pass its name:

```bash
xcrun simctl boot "iPhone 15 Pro"
npx expo run:ios --device "iPhone 15 Pro"
```

## Physical iPhone

A physical iPhone needs a development build signed with your Apple team and the device registered in your provisioning profile. EAS can manage this for you (see [Build](https://www.evtivity.com/docs/mobile-app/build)).

> **Note:**
>
> Device attestation cannot produce a real token on a simulator, so attestation-gated flows may fail there. Use a physical device to exercise attestation end to end.

## Standalone (no computer)

To run the app untethered, build a release variant. A release build bundles the JavaScript into the app, so it launches without Metro. See [Build](https://www.evtivity.com/docs/mobile-app/build).

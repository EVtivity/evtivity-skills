Generated from https://www.evtivity.com/docs/mobile-app/testing (website commit 4cd1866). Do not edit.

# Testing

Typecheck, lint, and on-device verification for the EVtivity mobile app.

The app relies on static checks and on-device verification.

## Typecheck and lint

Run both after a change. They catch the majority of issues before the app even loads.

```bash
npx tsc --noEmit
npx eslint <changed-files>
```

The TypeScript config is strict (`exactOptionalPropertyTypes`, `noUncheckedIndexedAccess`). Index access returns `T | undefined`, so read array and record values into a local with a fallback before using them.

## On-device verification

Static checks do not catch layout, gesture, or native behavior. Reload the app on a simulator or device and exercise the change.

- Most edits hot-reload through Metro (shake the device or press reload).
- i18n and native config changes require a full relaunch (terminate and launch), not a Metro reload.
- Overlays (dialogs, sheets) must be verified on a real device or simulator, never assumed. The New Architecture has surprising behavior with the React Native `Modal`, which is why the app renders overlays in-tree.

## What to check after a change

- The screen renders on both light and dark themes.
- Text contrast is correct on the branded backdrop and inside cards.
- Lists and details stay in sync after a mutation.
- Pull-to-refresh and any live-updating values behave.

> **Tip:**
>
> When something behaves differently in a release build than in the Metro dev build, suspect native config: cleartext HTTP, attestation, or a value that is only present after a rebuild.

## Next steps

- [Run on a real device](https://www.evtivity.com/docs/mobile-app/real-device) for the device and Metro connection workflow.
- [Build](https://www.evtivity.com/docs/mobile-app/build) to produce a standalone app for end-to-end testing.

Generated from https://www.evtivity.com/docs/mobile-app/develop (website commit 257c8b8). Do not edit.

# Making Changes

Project structure, conventions, and how to add a screen to the EVtivity mobile app.

This guide orients you in the codebase so you can make a change with confidence.

## Project structure

- `app/` - file-based routes (`expo-router`). Route groups in parentheses, such as `(auth)` and `(tabs)`, organize screens under a shared layout without adding a URL segment.
- `src/features/` - data hooks (TanStack Query) per domain: sessions, account, support, payments, favorites, charge.
- `src/components/` - shared components, including `src/components/ui/` for the design system primitives.
- `src/lib/` - utilities: API client, theme, i18n, formatting, status helpers, push.
- `brands/` - the white-label brand definitions.
- `modules/` - local native modules (device attestation).

## Conventions

- **Styling**: NativeWind. Use Tailwind classes via `className`. Prefer responsive classes over JavaScript branching for layout.
- **Text and theme**: use the `Text` component variants and the surface system so text color resolves correctly on the branded backdrop and inside cards.
- **i18n**: every user-facing string goes through `react-i18next` and `src/lib/i18n`. Add keys to `en.json` first.
- **Data**: server state is TanStack Query. Mutations invalidate or write back to the cache; lists and details share keys so one update refreshes both.

> **Warning:**
>
> Do not use the React Native `Modal` component on this build. On the New Architecture (Fabric and Bridgeless) it renders blank and freezes the screen. Render overlays in-tree instead: confirm dialogs as a root absolute view, and sheets through the in-app `Portal` host. See the app's `docs/modal-freeze-newarch.md`.

## Adding a screen

1. Create a file under `app/`. The path becomes the route. For example, `app/(tabs)/account/about.tsx` is `/account/about`.
2. Render with the shared `Screen` and design-system components so the screen inherits the backdrop, safe areas, and theming.
3. Fetch data with a hook in `src/features/` rather than calling the API inline.
4. Add any new strings to the locale files.

## Verifying a change

Most edits hot-reload through Metro. Some changes need a full relaunch:

- i18n and native config changes (terminate and relaunch the app, not just a Metro reload).
- Brand or `app.config.ts` changes (restart Metro or rebuild).

Run a typecheck and lint before you consider a change done. See [Testing](https://www.evtivity.com/docs/mobile-app/testing).

# Expo migration notes

Use this as a checklist when the source app uses `onesignal-expo-plugin`.

## Detect mode

- `package.json`: `expo`, `react-native-onesignal`, `onesignal-expo-plugin`
- `app.json` / `app.config.js` / `app.config.ts`: plugin ordering and props
- `eas.json`: development/preview/production profiles
- generated `ios/` / `android/` folders: whether native diff is checked in

## OneSignal-specific items to preserve during inventory

- `onesignal-expo-plugin` must often be first in the plugin list; do not reorder blindly before removal.
- `mode` controls APNs environment; record development vs production.
- `disableNSE`, `appGroupName`, `nseBundleIdentifier`, icons, sounds may produce native files.
- Expo Go does not support OneSignal push. Treat an Expo-Go-only app as a blocker for native push migration until the Notifly build path is confirmed.

## Migration strategy

1. Move JS identity/tag/event calls behind a small adapter first.
2. Add Notifly JS/native setup through the workflow supported by the project: generated native folders, prebuild, config plugin, or EAS build.
3. In coexist mode, keep `onesignal-expo-plugin` until Notifly device registration, click routing, and any rich-push replacement are verified.
4. In complete mode, remove the plugin and generated OneSignal native artifacts only after a clean native build.

## Verification

```bash
npx expo config --type public
npx expo prebuild --no-install
# or the repository's EAS/dev-client build command
```

Inspect generated native diff before committing. Do not rely on Expo Go for push verification.

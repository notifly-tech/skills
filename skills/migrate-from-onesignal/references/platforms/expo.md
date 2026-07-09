# Expo Migration

Use for Expo apps. Expo is a React Native platform, but native SDK migrations depend on whether the app uses
Expo Go, development builds, prebuild, or EAS native projects.

## Detect Expo + OneSignal mode

Search for:

- `expo` dependency in `package.json`
- `onesignal-expo-plugin` and `react-native-onesignal`
- `app.json`, `app.config.js`, `app.config.ts`
- `eas.json`
- existing `ios/` and `android/` generated folders
- custom config plugins
- `expo prebuild`, `expo-dev-client`, EAS build workflow

Ask one question if unclear:

```text
이 Expo 앱은 Expo Go만 쓰나요, 아니면 prebuild/dev-client/EAS native build를 쓰나요?
OneSignal/Notifly native push SDK 전환은 native project/config가 필요할 수 있습니다.
```

## OneSignal Expo specifics

- OneSignal docs say push notifications do not work in Expo Go; development build/EAS/native build is required.
- `onesignal-expo-plugin` should be first in the `plugins` array.
- Plugin props such as `mode`, `appGroupName`, `disableNSE`, `disableLocation`, icons, sounds may have generated native effects.
- Do not remove the plugin until generated iOS/Android changes and Notifly replacement are verified.

## Strategy

- If the app has generated `ios/` and `android/`, follow `react-native.md` plus native iOS/Android references.
- If the app is managed Expo without native folders, prefer config-plugin/prebuild planning before code mutation.
- Do not assume a native OneSignal/Notifly SDK works inside pure Expo Go. Verify supported workflow and build target first.
- Use `notifly-sdk` JS API where React Native docs apply, but native push/rich push still requires native config.

## Mapping

| Expo/OneSignal area | Notifly path |
| --- | --- |
| JS event/user calls | `notifly-sdk` adapter in app code |
| `onesignal-expo-plugin` native config | Notifly-compatible Expo/prebuild/native config plan |
| iOS push/APNs/rich push | prebuild/native iOS setup, Notification Service Extension/App Groups |
| Android FCM/click handling | prebuild/native Android setup |
| Expo Go only | treat as blocker for native push SDK migration unless Notifly docs explicitly support it |

## Verification

- `npx expo config --type public` or equivalent config inspection
- If using prebuild: inspect generated native diff before committing
- EAS/dev-client build path if native modules are required
- TypeScript/lint/test for JS adapter
- Runtime push permission/click/deeplink test on real device

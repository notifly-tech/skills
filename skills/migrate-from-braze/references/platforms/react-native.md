# React Native Migration

Use for React Native apps with native iOS/Android folders.

## Detect Braze

Search for:

- `@braze/react-native-sdk`, `react-native-appboy-sdk`, `Braze`
- `Braze.changeUser`, `Braze.logCustomEvent`, `Braze.logPurchase`
- `setCustomUserAttribute`, Content Cards, Feature Flags
- iOS `AppDelegate.mm`, Android `MainApplication.kt/java`, push/deeplink handling

## Notifly setup

Notifly React Native docs: `/ko/developer-guide/react-native-sdk`.

Key points from docs:

- Install `notifly-sdk@latest`
- Run `cd ios && pod install`
- iOS uses `.xcworkspace`, iOS deployment target 13.0+, Push Notification/Background Modes
- iOS AppDelegate imports `notifly_sdk-Swift.h` and forwards APNs/UNUserNotificationCenter callbacks
- Initialize in JS entrypoint (`index.js` or `App.js`)
- `password` is a legacy placeholder; pass a non-empty placeholder such as username, not a real password/API secret

Core JS APIs:

```ts
import notifly from 'notifly-sdk';

notifly.initialize({
  projectId: 'PROJECT_ID',
  username: 'USERNAME',
  password: 'USERNAME',
});

notifly.setUserId('user_123');
notifly.setUserId();
notifly.setUserProperties({ $email: 'user@example.com' });
notifly.trackEvent('purchase_completed', { price: 120000 });
```

## Mapping

| Braze React Native | Notifly React Native |
| --- | --- |
| `@braze/react-native-sdk` | `notifly-sdk` |
| `Braze.changeUser(userId)` | `notifly.setUserId(userId)` |
| `Braze.setCustomUserAttribute*` | `notifly.setUserProperties({...})` |
| `Braze.logCustomEvent(name, props)` | `notifly.trackEvent(name, props, segmentationEventParamKeys?)` |
| Braze native push delegates/services | Notifly iOS/Android native setup + JS initialization |
| Content Cards / Feature Flags | product design required |

## Native bridge checklist

- iOS: update `AppDelegate.h` / `AppDelegate.mm` with `UNUserNotificationCenterDelegate` and Notifly forwarding.
- iOS: if rich push is required, add Notification Service Extension/App Groups from `/ko/advanced/rich-push-notification`.
- Android: verify `MainApplication` and manifest/FCM service interactions.
- JS: keep app-level adapter small; avoid scattering direct Notifly calls everywhere during coexist.

## Complete mode removal checklist

- Remove Braze npm package and native pods after verification
- Remove Braze imports/callsite from TS/JS
- Remove Braze native config from iOS/Android folders
- Search for `Braze`, `braze`, `appboy`, `@braze/react-native-sdk`
- Run TypeScript/lint/test and native builds if available

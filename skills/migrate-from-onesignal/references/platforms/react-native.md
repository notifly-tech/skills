# React Native Migration

Use for React Native apps with native iOS/Android folders.

## Detect OneSignal

Search for:

- `react-native-onesignal` package
- `import { OneSignal, LogLevel } from 'react-native-onesignal'`
- `OneSignal.initialize`, `OneSignal.login`, `OneSignal.logout`
- `OneSignal.User.addTag(s)`, `OneSignal.User.trackEvent`, `OneSignal.User.addAlias(es)`
- `OneSignal.Notifications.requestPermission`, `addEventListener('click')`, `foregroundWillDisplay`
- `OneSignal.InAppMessages.addEventListener('click')`
- native iOS `AppDelegate.mm`, Android `MainApplication.kt/java`, push/deeplink handling
- `ONESIGNAL_DISABLE_LOCATION` env usage
- 구형 API names from old wrappers

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

| OneSignal React Native | Notifly React Native |
| --- | --- |
| `react-native-onesignal` | `notifly-sdk` |
| `OneSignal.initialize(appId)` | `notifly.initialize({...})` |
| `OneSignal.login(userId)` | `notifly.setUserId(userId)` |
| `OneSignal.logout()` | `notifly.setUserId()` |
| `OneSignal.User.addTag(s)` | `notifly.setUserProperties({...})` |
| `OneSignal.User.trackEvent(name, props)` | `notifly.trackEvent(name, props, segmentationEventParamKeys?)` |
| `OneSignal.Notifications.addEventListener('click', ...)` | Notifly iOS/Android native setup + JS/router handling |
| OneSignal native NSE/AppGroup/manifest setup | Notifly iOS/Android native setup |
| In-app click/listeners | Notifly in-app events/campaign design |

## Native bridge checklist

- iOS: update `AppDelegate.h` / `AppDelegate.mm` with `UNUserNotificationCenterDelegate` and Notifly forwarding.
- iOS: if rich push is required, add Notification Service Extension/App Groups from `/ko/advanced/rich-push-notification`.
- Android: verify `MainApplication` and manifest/FCM service interactions.
- JS: keep app-level adapter small; avoid scattering direct Notifly calls everywhere during coexist.
- If OneSignal used `ONESIGNAL_DISABLE_LOCATION`, check whether the app had location behavior or merely disabled unused native modules.

## Complete mode removal checklist

- Remove `react-native-onesignal` and native pods/gradle dependencies after verification
- Remove OneSignal imports/callsite from TS/JS
- Remove OneSignal native config from iOS/Android folders
- Search for `OneSignal`, `onesignal`, `react-native-onesignal`, `OSNotification`, `OSInApp`
- Run TypeScript/lint/test and native builds if available

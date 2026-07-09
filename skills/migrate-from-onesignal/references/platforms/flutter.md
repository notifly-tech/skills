# Flutter Migration

Use for Flutter apps using `onesignal_flutter`.

## Detect OneSignal

Search for:

- `onesignal_flutter` in `pubspec.yaml`
- `import 'package:onesignal_flutter/onesignal_flutter.dart'`
- `OneSignal.initialize`, `OneSignal.login`, `OneSignal.logout`
- `OneSignal.User.addTagWithKey`, `OneSignal.User.addTags`, `OneSignal.User.trackEvent`
- `OneSignal.Notifications.requestPermission`, `addClickListener`
- `OneSignal.InAppMessages.addClickListener`, triggers/lifecycle
- native `android/` and `ios/` OneSignal config, NSE/App Groups, notification icons
- `ONESIGNAL_DISABLE_LOCATION` env usage

## Notifly setup

Notifly Flutter docs: `/ko/developer-guide/flutter-sdk`.

Key points:

- Add `notifly_flutter` dependency
- Initialize early in app startup
- Configure iOS/Android native push prerequisites where needed
- `password` is a legacy placeholder; pass a non-empty placeholder such as username, not a real password/API secret

Core APIs:

```dart
import 'package:notifly_flutter/notifly_flutter.dart';

await NotiflyPlugin.initialize(
  projectId: 'PROJECT_ID',
  username: 'USERNAME',
  password: 'USERNAME',
);
await NotiflyPlugin.setUserId('user_123');
await NotiflyPlugin.setUserProperties({'$email': 'user@example.com'});
await NotiflyPlugin.trackEvent(
  eventName: 'purchase_completed',
  eventParams: {'price': 120000},
);
```

## Mapping

| OneSignal Flutter | Notifly Flutter |
| --- | --- |
| `onesignal_flutter` | `notifly_flutter` |
| `OneSignal.initialize(appId)` | `NotiflyPlugin.initialize(...)` |
| `OneSignal.login(userId)` | `NotiflyPlugin.setUserId(userId)` |
| `OneSignal.logout()` | `NotiflyPlugin.setUserId(null)` |
| `OneSignal.User.addTagWithKey` / `addTags` | `NotiflyPlugin.setUserProperties(...)` |
| `OneSignal.User.trackEvent(name, props)` | `NotiflyPlugin.trackEvent(...)` |
| `OneSignal.Notifications.addClickListener` | `NotiflyPlugin.addNotificationClickListener` |
| `OneSignal.InAppMessages.addClickListener` | `NotiflyPlugin.inAppEvents` / campaign event mapping |

## Complete mode removal checklist

- Remove `onesignal_flutter` after Notifly verification
- Remove OneSignal imports/callsite from Dart
- Remove OneSignal native iOS/Android config that is no longer needed
- Remove OneSignal NSE/App Group only after Notifly rich push setup is verified or explicitly out of scope
- Search for `OneSignal`, `onesignal_flutter`, `OSNotification`, `OSInApp`
- Run `flutter pub get`, `flutter analyze`, tests/builds if available

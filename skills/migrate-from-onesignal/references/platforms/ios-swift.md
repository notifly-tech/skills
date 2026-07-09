# iOS Swift Migration

Use for native iOS apps using Swift, SwiftUI, CocoaPods, or Swift Package Manager.

## Detect OneSignal

Search for:

- `OneSignalFramework`, `OneSignalExtension`, `OneSignalInAppMessages`, `OneSignalLocation`
- `import OneSignalFramework`, `import OneSignalExtension`
- `OneSignal.initialize`, `OneSignal.login`, `OneSignal.logout`
- `OneSignal.User.addTag(s)`, `OneSignal.User.trackEvent`, aliases
- `OneSignal.Notifications.requestPermission`, click/foreground listeners
- `OneSignal.InAppMessages.addTrigger(s)`, click/lifecycle listeners
- Notification Service Extension target, `OneSignalNotificationServiceExtension`, App Groups, `OneSignal_app_groups_key`
- 구형 API: `setExternalUserId`, `sendTag`, `setNotificationOpenedHandler`, `setInAppMessageClickHandler`

## Notifly setup

Notifly iOS docs: `/ko/developer-guide/ios-sdk`.

Key points from docs:

- iOS deployment target 13.0+
- Push Notification and Background Modes enabled
- Install via CocoaPods `pod 'notifly_sdk'` or SPM `https://github.com/team-michael/notifly-ios-sdk`
- Initialize in `AppDelegate`
- Forward APNs and notification center callbacks to Notifly
- `password` is a legacy placeholder; pass a non-empty placeholder such as username, not a real password/API secret

Core APIs:

```swift
import notifly_sdk

Notifly.initialize(projectId: "PROJECT_ID", username: "USERNAME", password: "USERNAME")
Notifly.setUserId(userId: "user_123")
Notifly.setUserId(userId: nil)
Notifly.setUserProperties(userProperties: ["$email": "user@example.com"])
Notifly.trackEvent(eventName: "purchase_completed", eventParams: ["price": 120000])
```

Push delegate forwarding:

```swift
func application(_ application: UIApplication,
                 didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    Notifly.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
}

func userNotificationCenter(_ center: UNUserNotificationCenter,
                            didReceive response: UNNotificationResponse,
                            withCompletionHandler completion: @escaping () -> Void) {
    Notifly.userNotificationCenter(center, didReceive: response)
    completion()
}
```

## Mapping

| OneSignal Swift | Notifly Swift |
| --- | --- |
| `OneSignal.initialize(appId, withLaunchOptions:)` | `Notifly.initialize(...)` |
| `OneSignal.login(userId)` | `Notifly.setUserId(userId:)` |
| `OneSignal.logout()` | `Notifly.setUserId(userId: nil)` |
| `OneSignal.User.addTag(s)` | `Notifly.setUserProperties(userProperties:)` |
| `OneSignal.User.trackEvent(name:properties:)` | `Notifly.trackEvent(eventName:eventParams:segmentationEventParamKeys:)` |
| `OneSignal.Notifications.addClickListener` | Notifly APNs/UNUserNotificationCenter forwarding + click handling |
| OneSignal NSE/App Group | Notifly Notification Service Extension/App Groups if rich push is required |
| `OneSignal.InAppMessages.addClickListener` | Notifly in-app popup listener/events |

## Complete mode removal checklist

- Remove OneSignal SPM/CocoaPods packages only after Notifly build/runtime verification
- Remove `OneSignalFramework` imports and initialization
- Remove or replace OneSignal Notification Service Extension code if Notifly rich push is configured
- Remove `OneSignal_app_groups_key` only if no longer needed and Notifly App Group plan is settled
- Search for `OneSignal`, `onesignal`, `OSNotification`, `OSInApp`, `setExternalUserId`, `sendTag`
- Verify Xcode build and push/deeplink behavior

## Coexist mode

Use a small service that receives app-level identity/property/event calls and forwards to both OneSignal and Notifly.
Do not dual-send push/in-app campaigns to production users without an internal segment or holdout plan.

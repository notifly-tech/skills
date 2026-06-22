# iOS Swift Migration

Use for native iOS apps using Swift, SwiftUI, CocoaPods, or Swift Package Manager.

## Detect Braze

Search for:

- `BrazeKit`, `BrazeUI`, `braze`, `Appboy`
- `Braze.Configuration`, `Braze(configuration:)`
- `changeUser`, `logCustomEvent`, `logPurchase`
- custom attributes on `braze.user`
- `UNUserNotificationCenterDelegate`, APNs token forwarding, Notification Service Extension
- Content Cards / Feature Flags calls

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

func application(_ application: UIApplication,
                 didFailToRegisterForRemoteNotificationsWithError error: Error) {
    Notifly.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
}

func userNotificationCenter(_ center: UNUserNotificationCenter,
                            didReceive response: UNNotificationResponse,
                            withCompletionHandler completion: @escaping () -> Void) {
    Notifly.userNotificationCenter(center, didReceive: response)
    completion()
}
```

## Mapping

| Braze Swift | Notifly Swift |
| --- | --- |
| `Braze(configuration:)` | `Notifly.initialize(...)` |
| `changeUser(userId:)` | `Notifly.setUserId(userId:)` |
| custom attributes | `Notifly.setUserProperties(userProperties:)` |
| `logCustomEvent` | `Notifly.trackEvent(eventName:eventParams:segmentationEventParamKeys:)` |
| push delegate handling | Notifly APNs/UNUserNotificationCenter forwarding |
| rich push extension | Notifly Notification Service Extension/App Groups |

## Complete mode removal checklist

- Remove Braze SPM/CocoaPods dependencies only after Notifly build/runtime verification
- Remove `BrazeKit` imports and global Braze instance
- Remove Braze Notification Service Extension code if replaced
- Search for `Braze`, `braze`, `Appboy`, `appboy`
- Verify Xcode build and push/deeplink behavior

## Coexist mode

Use a small service that receives app-level identity/property/event calls and forwards to both Braze and Notifly.
Do not dual-send push/in-app campaigns to production users without an internal segment or holdout plan.

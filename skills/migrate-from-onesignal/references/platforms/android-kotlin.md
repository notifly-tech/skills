# Android Kotlin Migration

Use for native Android apps using Kotlin or Java.

## Detect OneSignal

Search for:

- Gradle dependency: `com.onesignal:OneSignal`, `com.onesignal:OneSignal:[...]`
- imports: `com.onesignal.OneSignal`, `com.onesignal.debug.LogLevel`
- `OneSignal.initWithContext(...)` in `Application.onCreate`
- `OneSignal.login`, `OneSignal.logout`, `OneSignal.User.addTag(s)`, `OneSignal.User.trackEvent`
- `OneSignal.Notifications.requestPermission`, click/foreground listeners
- `OneSignal.InAppMessages.addTrigger(s)`, click/lifecycle listeners
- 구형 API: `setExternalUserId`, `sendTag`, `setNotificationOpenedHandler`, `setNotificationWillShowInForegroundHandler`
- AndroidManifest services/receivers, notification icons/channels, FCM service interactions

## Notifly setup

Notifly Android docs: `/ko/developer-guide/android-sdk`.

Key points from docs:

- Add JitPack repository
- Add `com.github.team-michael:notifly-android-sdk` dependency
- Initialize in the `Application` class, not a single Activity
- Android 11+ is required for in-app popup campaigns
- `password` is a legacy placeholder; pass a non-empty placeholder such as username, not a real password/API secret

Core APIs:

```kotlin
import tech.notifly.Notifly

class MainApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        Notifly.initialize(
            applicationContext,
            BuildConfig.NOTIFLY_PROJECT_ID,
            BuildConfig.NOTIFLY_USERNAME,
            BuildConfig.NOTIFLY_USERNAME,
        )
    }
}

Notifly.setUserId(context, "user_123")
Notifly.setUserId(context, null)
Notifly.setUserProperties(context, mapOf("$email" to "user@example.com"))
Notifly.trackEvent(context, "purchase_completed", mapOf("price" to 120000))
```

Push click listener:

```kotlin
Notifly.addNotificationClickListener(object : INotificationClickListener {
    override fun onClick(event: INotificationClickEvent) {
        val customData = event.notification.customData
        // route using campaign custom data
    }
})
```

In-app listener:

```kotlin
Notifly.addInAppMessageEventListener(object : IInAppMessageEventListener {
    override fun handleEvent(eventName: String, eventParams: Map<String, Any?>?) {
        // handle in-app popup event
    }
})
```

## Mapping

| OneSignal Android | Notifly Android |
| --- | --- |
| Gradle OneSignal dependency | JitPack + Notifly Android SDK dependency |
| `OneSignal.initWithContext(context, appId)` | `Notifly.initialize(context, projectId, username, username)` |
| `OneSignal.login(userId)` | `Notifly.setUserId(context, userId)` |
| `OneSignal.logout()` | `Notifly.setUserId(context, null)` |
| `OneSignal.User.addTag(s)` / `sendTag(s)` | `Notifly.setUserProperties(context, map)` |
| `OneSignal.User.trackEvent(name, props)` / outcomes | `Notifly.trackEvent(context, name, params, segmentationEventParamKeys)` |
| `OneSignal.Notifications.addClickListener` | `Notifly.addNotificationClickListener` |
| `OneSignal.Notifications.addForegroundLifecycleListener` | Notifly foreground/display policy; verify supported callbacks |
| `OneSignal.InAppMessages.addClickListener` | `Notifly.addInAppMessageEventListener` + campaign event mapping |

## Complete mode removal checklist

- Remove OneSignal Gradle dependency after Notifly verification
- Remove `com.onesignal` imports/callsite
- Remove obsolete OneSignal notification icon/channel resources if not reused
- Remove or replace OneSignal FCM/service extension interactions
- Check manifest merge for duplicate FCM services/receivers
- Search for `OneSignal`, `onesignal`, `OSNotification`, `OSInApp`, `setExternalUserId`, `sendTag`
- Run Gradle assemble/test if available

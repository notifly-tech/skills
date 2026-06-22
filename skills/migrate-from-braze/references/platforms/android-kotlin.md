# Android Kotlin Migration

Use for native Android apps using Kotlin or Java.

## Detect Braze

Search for:

- Gradle dependencies: `com.braze:android-sdk-*`, `com.appboy`
- imports: `com.braze.Braze`, `com.braze.configuration.BrazeConfig`
- `Braze.getInstance(context).changeUser(...)`
- `logCustomEvent`, `logPurchase`, custom user attributes
- `BrazeFirebaseMessagingService`, FCM services, manifest metadata/resources `com_braze_*`
- Content Cards / Feature Flags calls

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
Notifly.setUserProperties(context, mapOf("\$email" to "user@example.com"))
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

| Braze Android | Notifly Android |
| --- | --- |
| Gradle Braze dependency | JitPack + Notifly Android SDK dependency |
| `Braze.getInstance(context).changeUser` | `Notifly.setUserId(context, userId)` |
| Braze user attributes | `Notifly.setUserProperties(context, map)` |
| `logCustomEvent` / `logPurchase` | `Notifly.trackEvent(context, name, params, segmentationEventParamKeys)` |
| `BrazeFirebaseMessagingService` / Braze push handling | Notifly initialization + notification click listener / interceptor |
| Braze in-app callbacks | `Notifly.addInAppMessageEventListener` |

## Complete mode removal checklist

- Remove Braze Gradle dependencies after Notifly verification
- Remove `com_braze_*` resources and manifest metadata
- Remove or replace `BrazeFirebaseMessagingService`
- Check manifest merge for duplicate FCM services
- Search for `com.braze`, `Braze`, `Appboy`, `com_braze_`
- Run Gradle assemble/test if available

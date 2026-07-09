# OneSignal SDK Structure

이 문서는 migration 전에 확인해야 하는 OneSignal SDK 구조 요약입니다. 공식 문서와 공개 SDK 저장소 구조를 기준으로 합니다.

## 1. v5 user model 공통 surface

OneSignal v5 계열 SDK는 대체로 아래 namespace를 공유합니다.

| 영역 | 대표 API | Migration 의미 |
| --- | --- | --- |
| 초기화 | `OneSignal.initWithContext(...)`, `OneSignal.initialize(...)`, Web `OneSignal.init(...)` | Notifly initialize로 교체 |
| 식별 | `OneSignal.login(external_id)`, `OneSignal.logout()` | `Notifly.setUserId` / logout null 처리 |
| 유저 상태 | `OneSignal.User.onesignalId`, `OneSignal.User.externalId`, user observer | 운영 검증용. 고객 ID로 사용하지 않음 |
| aliases | `OneSignal.User.addAlias(es)`, `removeAlias(es)` | 대부분 user property 또는 서버 매핑으로 보존 |
| custom events | `OneSignal.User.trackEvent(name, properties)` | `Notifly.trackEvent` |
| tags | `OneSignal.User.addTag(s)`, `removeTag(s)`, `getTags()` | `Notifly.setUserProperties`; string-only 변환 주의 |
| push permission/subscription | `OneSignal.Notifications.requestPermission`, `User.pushSubscription`, opt-in/out | Notifly push 권한/채널 상태 검증 |
| push click/foreground | `OneSignal.Notifications.addClickListener`, RN/Web `addEventListener('click')`, foreground lifecycle | Notifly push click listener/callback |
| in-app | `OneSignal.InAppMessages.addTrigger(s)`, `paused`, `addClickListener`, `addLifecycleListener` | Notifly in-app event/campaign 설계 |

## 2. Platform package and setup structure

### Android

- 공식 setup docs: `https://documentation.onesignal.com/docs/en/android-sdk-setup`
- SDK repo: `https://github.com/OneSignal/OneSignal-Android-SDK`
- dependency 예: `com.onesignal:OneSignal:[5.6.1, 5.9.99]`
- minimum/recommended docs 기준: Android API 23+ minimum, 31+ recommended
- init 위치: `Application.onCreate`, `OneSignal.initWithContext(this, "YOUR_APP_ID")`
- 공개 repo module 구조 확인: `core`, `notifications`, `in-app-messages`, `location`, `otel`, `testhelpers`

Migration 신호:

```kotlin
import com.onesignal.OneSignal
import com.onesignal.debug.LogLevel

OneSignal.Debug.logLevel = LogLevel.VERBOSE
OneSignal.initWithContext(this, ONESIGNAL_APP_ID)
OneSignal.Notifications.requestPermission(false)
OneSignal.login("external_id")
OneSignal.User.addTag("KEY", "VALUE")
OneSignal.User.trackEvent("purchase", mapOf("price" to 12.3))
```

### iOS

- 공식 setup docs: `https://documentation.onesignal.com/docs/en/ios-sdk-setup`
- SDK repo docs 기준: `https://github.com/OneSignal/OneSignal-XCFramework`
- app target packages: `OneSignalFramework` required, `OneSignalInAppMessages` recommended, `OneSignalLocation` optional
- extension package: `OneSignalExtension`
- init: `OneSignal.initialize("YOUR_APP_ID", withLaunchOptions: launchOptions)`
- NSE/App Group: rich push, images, confirmed receipt, badges에 필요

Migration 신호:

```swift
import OneSignalFramework

OneSignal.initialize("ONESIGNAL_APP_ID", withLaunchOptions: launchOptions)
OneSignal.login("external_id")
OneSignal.User.addTag(key: "KEY", value: "VALUE")
OneSignal.User.trackEvent(name: "purchase", properties: ["price": 12.3])
OneSignal.Notifications.addClickListener(self)
OneSignal.InAppMessages.addClickListener(listener)
```

### React Native

- 공식 setup docs: `https://documentation.onesignal.com/docs/en/react-native-sdk-setup`
- package: `react-native-onesignal`
- public repo structure: `src/` TypeScript API, `ios/RCTOneSignal`, `android/src/main/java/...`
- requirements docs 기준: bare RN, RN 0.79+ New Architecture; managed Expo는 Expo setup track 사용
- optional native location module disable: `ONESIGNAL_DISABLE_LOCATION=true`

Migration 신호:

```ts
import { OneSignal, LogLevel } from 'react-native-onesignal';

OneSignal.Debug.setLogLevel(LogLevel.Verbose);
OneSignal.initialize('YOUR_APP_ID');
OneSignal.Notifications.requestPermission(false);
OneSignal.login('external_id');
OneSignal.User.addTags({ plan: 'pro' });
OneSignal.User.trackEvent('purchase', { price: 12.3 });
OneSignal.Notifications.addEventListener('click', listener);
```

### Expo

- 공식 setup docs: `https://documentation.onesignal.com/docs/en/react-native-expo-sdk-setup`
- packages: `onesignal-expo-plugin` + `react-native-onesignal`
- Expo Go limitation: push notifications do not work in Expo Go; development build/EAS/native build required
- plugin ordering: `onesignal-expo-plugin` should be first in the `plugins` array
- plugin props include `mode`, `disableLocation`, `appGroupName`, `disableNSE`, icons/sounds, etc.

Migration 신호:

```json
{
  "expo": {
    "plugins": [
      ["onesignal-expo-plugin", { "mode": "development" }]
    ]
  }
}
```

### Flutter

- 공식 setup docs: `https://documentation.onesignal.com/docs/en/flutter-sdk-setup`
- package: `onesignal_flutter`
- public repo structure: `lib/` Dart API, `android/src/main/java/com/onesignal/flutter`, `ios/onesignal_flutter/Sources`
- docs 기준 Flutter 3.29.0+, iOS/Android native setup 필요
- optional location module disable: `ONESIGNAL_DISABLE_LOCATION=true`

Migration 신호:

```dart
import 'package:onesignal_flutter/onesignal_flutter.dart';

OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
OneSignal.initialize("YOUR_APP_ID");
OneSignal.Notifications.requestPermission(false);
OneSignal.login("external_id");
OneSignal.User.addTags({'plan': 'pro'});
OneSignal.User.trackEvent("purchase", {"price": 12.3});
```

### Web

- official setup docs: `https://documentation.onesignal.com/docs/en/web-sdk-setup`
- Web SDK reference: `https://documentation.onesignal.com/docs/en/web-sdk-reference`
- SDK repo: `https://github.com/OneSignal/OneSignal-Website-SDK`
- script: `https://cdn.onesignal.com/sdks/web/v16/OneSignalSDK.page.js`
- service worker: `OneSignalSDKWorker.js`, must be publicly accessible on the same origin with JavaScript content type
- init options include `appId`, `safari_web_id`, `serviceWorkerPath`, `serviceWorkerParam.scope`, `autoResubscribe`, prompt options

Migration 신호:

```html
<script src="https://cdn.onesignal.com/sdks/web/v16/OneSignalSDK.page.js" defer></script>
<script>
  window.OneSignalDeferred = window.OneSignalDeferred || [];
  OneSignalDeferred.push(async function(OneSignal) {
    await OneSignal.init({ appId: "YOUR_ONESIGNAL_APP_ID" });
    OneSignal.login("external_id");
    OneSignal.User.addTag("plan", "pro");
    OneSignal.User.trackEvent("purchase", { price: 12.3 });
  });
</script>
```

## 3. 구형 API detection

기존 앱에는 v3/v4 또는 wrapper API가 남아 있을 수 있습니다. 아래 이름이 보이면 바로 제거하지 말고 현재 SDK 버전과 wrapper를 확인합니다.

| 구형/legacy API | v5 user model 대응 | Notifly 대응 |
| --- | --- | --- |
| `setExternalUserId(...)` | `login(external_id)` | `setUserId(...)` |
| `removeExternalUserId(...)` | `logout()` | `setUserId(null/nil/undefined)` |
| `sendTag`, `sendTags`, `deleteTag` | `User.addTag(s)`, `User.removeTag(s)` | `setUserProperties`, property 제거 정책 별도 |
| `postNotification` client send | dropped / REST send | SDK migration 범위 아님. server/campaign 설계 필요 |
| `setNotificationOpenedHandler` | `Notifications.addClickListener` | Notifly push click listener |
| `setNotificationWillShowInForegroundHandler` | `Notifications.addForegroundLifecycleListener` / RN `foregroundWillDisplay` | foreground display policy 재검토 |
| `setInAppMessageClickHandler` | `InAppMessages.addClickListener` | Notifly in-app listener/events |
| `addTrigger(s)` | `InAppMessages.addTrigger(s)` | campaign trigger semantics 재설계 |
| `sendOutcome`, `sendUniqueOutcome`, `sendOutcomeWithValue` | Custom Events 또는 analytics/outcomes path | `trackEvent`로 옮길지 운영 metric으로 유지할지 결정 |

## 4. Migration caveats

- OneSignal push subscription/player ID는 Notifly device token이 아닙니다. Notifly SDK가 APNs/FCM/browser subscription을 새로 등록해야 합니다.
- OneSignal APNs/FCM credential을 앱 코드에 넣지 않습니다. Notifly project/channel 설정으로 별도 구성합니다.
- iOS OneSignal NSE/App Group을 제거하기 전 Notifly rich push 요구사항과 extension/App Group 구성을 먼저 검증합니다.
- Web은 service worker scope 충돌이 흔합니다. OneSignal `OneSignalSDKWorker.js`와 Notifly service worker가 같은 scope를 차지하는지 확인합니다.
- Tags are string-only in OneSignal. Notifly type conversion은 segment/campaign contract에 맞게 명시합니다.
- Dashboard-managed Journeys/Segments/Prompts는 SDK code search만으로 복구되지 않습니다. export/API/dashboard inventory가 필요합니다.

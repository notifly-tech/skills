# Flutter Braze → Notifly 매핑 레퍼런스

이 문서는 Flutter 앱에서 Braze SDK를 Notifly Flutter SDK로 옮길 때의 실무 매핑입니다.
최신 API 시그니처는 항상 Notifly Remote MCP의 문서 검색 도구와 프로젝트의 실제 SDK 버전으로
다시 확인하세요.

## 공식 근거 요약

### Braze Flutter SDK

Braze Flutter SDK 공식 README/샘플 기준:

- 설치: `flutter pub add braze_plugin`
- Android 설정:
  - `android/res/values/braze.xml`
  - `com_braze_api_key`
  - `com_braze_custom_endpoint` 또는 server target
  - FCM 자동 등록 옵션과 sender id
  - `com_braze_handle_push_deep_links_automatically`
- Android Manifest:
  - `com.braze.push.BrazeFirebaseMessagingService`
  - `com.google.firebase.MESSAGING_EVENT`
- iOS 설정:
  - `BrazeKit`, `braze_plugin`
  - `Braze.Configuration(apiKey:endpoint:)`
  - `BrazePlugin.initBraze(...)` 또는 `BrazePlugin.configure(...)`
- Dart 사용:
  - `BrazePlugin()`
  - `changeUser(...)`
  - event/user/push/in-app/content-card/feature-flag method는 `braze_plugin.dart`에 노출

### Notifly Flutter SDK

Notifly 공식 Flutter 문서 기준:

- 설치: `flutter pub add notifly_flutter`, iOS는 `cd ios && pod install`
- 초기화:
  - `WidgetsFlutterBinding.ensureInitialized()`
  - `await NotiflyPlugin.initialize(projectId: ..., username: ..., password: ...)`
  - `password`는 과거 호환용 placeholder이므로 실제 비밀번호/API secret을 넣지 말고
    `username`과 같은 비어 있지 않은 dummy 값을 사용
- 유저 식별:
  - `await NotiflyPlugin.setUserId(userId)`
  - 로그아웃/해제: `await NotiflyPlugin.setUserId(null)`
- 유저 속성:
  - `await NotiflyPlugin.setUserProperties(<String, Object>{...})`
  - `$email`, `$phone_number`, `$line_user_id` 등 사전 정의 key와 커스텀 key 지원
- 이벤트:
  - `await NotiflyPlugin.trackEvent(eventName: ..., eventParams: ...)`
  - `segmentationEventParamKeys`는 최대 1개 key
- 푸시 클릭:
  - Flutter SDK 1.4.0+에서 `NotiflyPlugin.addNotificationClickListener(...)`
- 인앱 팝업 이벤트:
  - Flutter SDK 2.1.0+에서 `NotiflyPlugin.inAppEvents.listen(...)`
- iOS rich push:
  - Flutter iOS target도 Notification Service Extension/App Groups 설정 필요
- Flutter Web push:
  - 모바일 앱이 아니라 Flutter Web에서만 `web/notifly-service-worker.js` 필요

## 기능별 매핑

### 1. 초기화

Braze:

```dart
import 'package:braze_plugin/braze_plugin.dart';

final braze = BrazePlugin();
braze.changeUser(userId);
```

Android/iOS native layer에 Braze API key/endpoint가 별도로 들어갑니다.

Notifly:

```dart
import 'package:notifly_flutter/notifly_flutter.dart';

Future<void> initNotifly() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotiflyPlugin.initialize(
    projectId: const String.fromEnvironment('NOTIFLY_PROJECT_ID'),
    username: const String.fromEnvironment('NOTIFLY_USERNAME'),
    password: const String.fromEnvironment('NOTIFLY_USERNAME'),
  );
}
```

주의:

- Notifly `projectId`/`username`은 앱 설정 주입 방식에 맞춰 관리합니다.
- 실제 secret을 모바일 앱에 넣지 않습니다.
- Braze Android resource/iOS config 제거는 complete mode에서만 합니다.

### 2. 유저 식별

| Braze | Notifly |
| --- | --- |
| `braze.changeUser(userId)` | `await NotiflyPlugin.setUserId(userId)` |
| logout 시 별도 anonymous 전환/앱 정책 | `await NotiflyPlugin.setUserId(null)` |

로그아웃 시 기존 Braze 코드가 anonymous user/session을 어떻게 다뤘는지 확인하세요.
Notifly `setUserId(null)`은 현재 기기와 로그인 유저 연결을 해제합니다.

### 3. 유저 속성

Braze는 타입별 method가 많습니다.

```dart
braze.setCustomUserAttributeString('tier', 'vip');
braze.setCustomUserAttributeBool('push_opt_in', true);
braze.setCustomUserAttributeArrayOfStrings('categories', ['bag', 'outer']);
```

Notifly는 map 기반으로 묶어 보냅니다.

```dart
await NotiflyPlugin.setUserProperties({
  'tier': 'vip',
  'push_opt_in': true,
  'categories': ['bag', 'outer'],
});
```

주의:

- Notifly 세그먼트에서 쓸 key 이름을 MCP의 `list_user_properties`와 콘솔 기준으로 맞춥니다.
- Braze reserved/profile fields를 Notifly 사전 정의 key로 옮길 수 있는지 확인합니다.
  예: email은 `$email`, phone은 `$phone_number`.
- 타입이 바뀌면 기존 세그먼트 조건이 깨질 수 있으므로 string/number/bool/list 형태를 유지합니다.

### 4. 이벤트

Braze:

```dart
braze.logCustomEvent('purchase_completed', properties: {
  'price': 120000,
  'brand': 'example',
});
```

Notifly:

```dart
await NotiflyPlugin.trackEvent(
  eventName: 'purchase_completed',
  eventParams: {
    'price': 120000,
    'brand': 'example',
  },
);
```

주의:

- 이벤트 이름은 되도록 유지해야 migration 전후 funnel/trigger 의미가 유지됩니다.
- Notifly에서 세그먼트 분류에 사용할 event param key는 `segmentationEventParamKeys`로 최대 1개만 지정합니다.
- MCP `list_project_events`로 이미 수집되는 이벤트와 naming convention을 먼저 확인합니다.

### 5. 푸시 클릭/deeplink

Braze:

- Android resource의 `com_braze_handle_push_deep_links_automatically=true`
- Dart `subscribeToPushNotificationEvents(...)` 또는 native deep link forwarding

Notifly:

```dart
await NotiflyPlugin.addNotificationClickListener((event) {
  final customData = event.notification.customData;
  final routeId = customData?['routeId'];
  if (routeId is String && routeId.isNotEmpty) {
    router.go('/$routeId');
  }
});
```

주의:

- Braze payload key와 Notifly campaign custom data key가 같다는 보장은 없습니다.
- custom data schema를 캠페인 초안 생성 시 명시하고, 앱 router가 허용하는 route만 처리하세요.
- Android에서 기존 `FirebaseMessagingService`가 있으면 Notifly/Braze/앱 service 간 우선순위와
  중복 표시 여부를 검토합니다.

### 6. 인앱 메시지

Braze:

- `subscribeToInAppMessages(...)`
- iOS custom presenter / Android automatic IAM integration
- HTML in-app message bridge

Notifly:

```dart
StreamSubscription<InAppMessageEvent>? sub;

sub = NotiflyPlugin.inAppEvents.listen((event) {
  switch (event.eventName) {
    case 'in_app_message_show':
      break;
    case 'main_button_click':
      break;
    case 'close_button_click':
      break;
  }
});
```

주의:

- Notifly 인앱 팝업 노출은 campaign/event/foreground 조건과 결합됩니다.
- 단순 code replacement가 아니라 캠페인 초안/타겟팅/트리거 설계가 같이 필요할 수 있습니다.

### 7. Content Cards

Braze Content Cards는 앱 UI surface에 카드 리스트를 내려주는 기능입니다.
Notifly Flutter SDK의 단일 API로 1:1 치환하지 마세요.

대응 옵션:

1. 기존 Content Cards UI를 유지하고 Braze를 공존시킵니다.
2. Notifly 캠페인/인앱 팝업/앱 내부 CMS/API로 surface를 재설계합니다.
3. 카드 노출/클릭 이벤트만 먼저 Notifly `trackEvent`로 dual-write합니다.

사용자/PM에게 어떤 surface로 대체할지 확인한 뒤 작업하세요.

### 8. Feature Flags

Braze Feature Flags는 Notifly CRM SDK와 직접 동등하지 않습니다.
다음 중 하나를 선택해야 합니다.

- 기존 feature flag provider 유지
- 앱 config/remote config/Amplitude Experiment 등 기존 실험 시스템으로 이전
- Notifly 캠페인 타겟팅/인앱 조건으로 충분한 부분만 대체

Feature Flags를 Notifly `setUserProperties`나 campaign으로 억지 변환하지 마세요.

## complete mode 제거 체크리스트

- `pubspec.yaml`에서 `braze_plugin` 제거
- Dart imports/calls 제거 또는 Notifly adapter로 대체
- Android `com_braze_*` resources 제거
- Android Manifest의 Braze service/receiver/activity 제거
- iOS `BrazeKit`, `braze_plugin`, `BrazePlugin.*` 제거
- Podfile/Package refs/lockfile 정리
- deep link/app group/push extension에서 Braze 전용 항목 제거
- 정적 검색으로 `Braze`, `braze`, `com_braze`, `com.braze` 확인

## coexist mode 체크리스트

- Braze 설정과 callsite 유지
- Notifly 초기화 추가
- 유저 ID/속성/이벤트 dual-write
- push/in-app은 중복 메시지 위험 때문에 내부 세그먼트나 초안으로 시작
- parity 확인용 logging/metrics 추가
- 제거 예정 릴리즈/날짜와 owner 기록

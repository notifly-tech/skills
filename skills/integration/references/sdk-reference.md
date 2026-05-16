# Notifly SDK 연동 레퍼런스 (빠른 치트시트)

이 레퍼런스는 의도적으로 간단하게 유지합니다. 최신의 정식(캐노니컬) 절차는 아래
문서를 참고하세요:

- iOS: `https://docs.notifly.tech/ko/developer-guide/ios-sdk.md`
- Android: `https://docs.notifly.tech/ko/developer-guide/android-sdk.md`
- React Native:
  `https://docs.notifly.tech/ko/developer-guide/react-native-sdk.md`
- Flutter: `https://docs.notifly.tech/ko/developer-guide/flutter-sdk.md`
- JavaScript(Web): `https://docs.notifly.tech/ko/developer-guide/javascript-sdk`

## 자격 증명(SDK)

Notifly SDK는 플랫폼 무관하게 같은 credential triple을 사용합니다:

- `NOTIFLY_PROJECT_ID`
- `NOTIFLY_USERNAME`
- `NOTIFLY_PASSWORD`

발급 위치: **Notifly 콘솔** (`https://console.notifly.tech/`) → Project Settings
→ SDK credentials.

Web도 같은 초기화 계약을 따릅니다. 다만 브라우저 번들은 공개될 수 있으므로, 실제
주입/노출 방식은 대상 프로젝트의 public config/server-injected config/빌드타임 config
정책을 따르고 `.env.example` 내용은 필수 판정 기준으로 삼지 않습니다.

## 설치 아티팩트(정식)

- **iOS (CocoaPods)**: `pod 'notifly_sdk'`
- **iOS (SPM)**: `https://github.com/team-michael/notifly-ios-sdk`
- **Android (Gradle + JitPack)**:
  `implementation 'com.github.team-michael:notifly-android-sdk:<latest>'`
- **React Native (npm)**: `notifly-sdk`
- **Flutter (pub.dev)**: `notifly_flutter`
- **JavaScript/Web (npm)**: `notifly-js-sdk`
- **JavaScript/Web (CDN)**:
  `https://cdn.jsdelivr.net/npm/notifly-js-sdk@<SDK_VERSION>/dist/index.global.min.js`

## 초기화(정식)

- **iOS**: `UNUserNotificationCenter.current().requestAuthorization(...)` →
  `FirebaseApp.configure()` → `Notifly.initialize(projectId:username:password)`
- **Android**:
  `Notifly.initialize(applicationContext, NOTIFLY_PROJECT_ID, BuildConfig.NOTIFLY_USERNAME, BuildConfig.NOTIFLY_PASSWORD)`
  (`Application.onCreate()`에서 호출)
- **Flutter**:
  `await NotiflyPlugin.initialize(projectId: ..., username: ..., password: ...)`
- **React Native**: 네이티브 설정을 먼저 완료한 뒤, `notifly-sdk`의 JS API를
  호출하세요.
- **JavaScript/Web SDK 2.5.0+**:
  `notifly.initialize({ projectId, username, password })`.
  `projectId`가 외부 config에서 오면 프로젝트 규칙에 맞게 검증하고 missing/invalid를
  구분합니다. 웹푸시 세부값(VAPID/SW path/권한 팝업/지연시간)은 콘솔 웹사이트 SDK 설정값을
  사용합니다.

## Android: 핵심 API(초기화 이후)

- **User**:
  - `Notifly.setUserId(context, userId)` (로그아웃:
    `Notifly.setUserId(context, null)`)
  - `Notifly.setUserProperties(context, params)`
- **Event**:
  - `Notifly.trackEvent(context, eventName, eventParams, segmentationEventParamKeys)`
  - `segmentationEventParamKeys`: **최대 1개 키**

## JavaScript/Web: 핵심 API(초기화 이후)

- **User**:
  - `notifly.setUserId(userId)`
  - `notifly.setUserId(null)` 또는 `notifly.setUserId()`로 로그아웃/등록 해제
  - `notifly.setUserProperties({...})`
- **Event**:
  - `notifly.trackEvent(eventName, eventParams, segmentationEventParamKeys)`
  - `segmentationEventParamKeys`: **최대 1개 키**
- **Web Push Permission**:
  - `notifly.requestPermission()` 또는 `notifly.requestPermission("en")`
  - SDK 2.7.0+ 및 콘솔 자동 권한 팝업 OFF 조건에서 수동 호출
  - 호출 성공은 prompt 시도일 뿐이며, `Notification.permission`, PushSubscription,
    device logging을 따로 확인해야 합니다.

## MCP-first 규칙

가능한 경우 항상 `notifly-mcp-server`를 사용해 메서드 이름/시그니처를
확인하세요:

- `notifly-mcp-server:search_docs`: 플랫폼 가이드 확인
- `notifly-mcp-server:search_sdk`: iOS + Flutter SDK 소스 스니펫 확인

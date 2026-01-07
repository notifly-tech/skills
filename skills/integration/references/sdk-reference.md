# Notifly SDK 연동 레퍼런스 (빠른 치트시트)

이 레퍼런스는 의도적으로 간단하게 유지합니다. 최신의 정식(캐노니컬) 절차는 아래
문서를 참고하세요:

- iOS: `https://docs.notifly.tech/ko/developer-guide/ios-sdk.md`
- Android: `https://docs.notifly.tech/ko/developer-guide/android-sdk.md`
- React Native:
  `https://docs.notifly.tech/ko/developer-guide/react-native-sdk.md`
- Flutter: `https://docs.notifly.tech/ko/developer-guide/flutter-sdk.md`
- JavaScript(Web):
  `https://docs.notifly.tech/ko/developer-guide/javascript-sdk`

## 자격 증명(SDK)

Notifly 모바일 SDK는 다음 자격 증명을 사용합니다:

- `NOTIFLY_PROJECT_ID`
- `NOTIFLY_USERNAME`
- `NOTIFLY_PASSWORD`

발급 위치: **Notifly 콘솔** (`https://console.notifly.tech/`) → Project Settings
→ SDK credentials.

## 설치 아티팩트(정식)

- **iOS (CocoaPods)**: `pod 'notifly_sdk'`
- **iOS (SPM)**: `https://github.com/team-michael/notifly-ios-sdk`
- **Android (Gradle + JitPack)**:
  `implementation 'com.github.team-michael:notifly-android-sdk:<latest>'`
- **React Native (npm)**: `notifly-sdk`
- **Flutter (pub.dev)**: `notifly_flutter`

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

## Android: 핵심 API(초기화 이후)

- **User**:
  - `Notifly.setUserId(context, userId)` (로그아웃:
    `Notifly.setUserId(context, null)`)
  - `Notifly.setUserProperties(context, params)`
- **Event**:
  - `Notifly.trackEvent(context, eventName, eventParams, segmentationEventParamKeys)`
  - `segmentationEventParamKeys`: **최대 1개 키**

## MCP-first 규칙

가능한 경우 항상 `notifly-mcp-server`를 사용해 메서드 이름/시그니처를
확인하세요:

- `notifly-mcp-server:search_docs`: 플랫폼 가이드 확인
- `notifly-mcp-server:search_sdk`: iOS + Flutter SDK 소스 스니펫 확인

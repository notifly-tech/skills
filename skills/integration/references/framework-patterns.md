# Notifly SDK 연동 패턴 (프레임워크 친화)

이 문서는 그대로 적용할 수 있는 *구현 패턴*을 제공합니다. 다만 최종적인 **단일
기준(Source of Truth)** 은 공식 Notifly 문서입니다:

- `https://docs.notifly.tech/ko/developer-guide/ios-sdk.md`
- `https://docs.notifly.tech/ko/developer-guide/android-sdk.md`
- `https://docs.notifly.tech/ko/developer-guide/react-native-sdk.md`
- `https://docs.notifly.tech/ko/developer-guide/flutter-sdk.md`

## 공통 사전 요구사항

- Notifly 푸시는 **Firebase Cloud Messaging(FCM)** 에 의존합니다.
- iOS는 Firebase에 등록된 APNs 인증 키/인증서가 필요합니다.

## iOS (Swift / SwiftUI)

- 먼저 Firebase가 초기화되어 있는지 확인합니다.
- `application(_:didFinishLaunchingWithOptions:)`에서 Notifly를 초기화합니다.

핵심 호출:

- `UNUserNotificationCenter.current().requestAuthorization(...)`
- `FirebaseApp.configure()`
- `Notifly.initialize(projectId:username:password)`
- `UNUserNotificationCenter.current().delegate = self`
- `Notifly.application(_:didRegisterForRemoteNotificationsWithDeviceToken:)`

## Android (Kotlin)

- JitPack 저장소 추가 + Notifly SDK 의존성 추가
- `Application.onCreate()`에서 초기화

핵심 호출:

- `Notifly.initialize(applicationContext, projectId, username, password)`

## React Native

- `notifly-sdk`를 설치하고 네이티브 설정(iOS + Android)을 완료합니다.
- 초기화 이후 JS API 사용:

- `notifly.setUserId(userId)`
- `notifly.setUserProperties({...})`
- `notifly.trackEvent(name, params)`

## Flutter

- `notifly_flutter` 추가
- 초기화:

- `await NotiflyPlugin.initialize(projectId: ..., username: ..., password: ...)`
- 선택: `NotiflyPlugin.inAppEvents.listen(...)`

# Notifly SDK 연동 패턴 (프레임워크 친화)

이 문서는 그대로 적용할 수 있는 *구현 패턴*을 제공합니다. 다만 최종적인 **단일
기준(Source of Truth)** 은 공식 Notifly 문서입니다:

- `https://docs.notifly.tech/ko/developer-guide/ios-sdk.md`
- `https://docs.notifly.tech/ko/developer-guide/android-sdk.md`
- `https://docs.notifly.tech/ko/developer-guide/react-native-sdk.md`
- `https://docs.notifly.tech/ko/developer-guide/flutter-sdk.md`
- `https://docs.notifly.tech/ko/developer-guide/javascript-sdk`

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

## Web / JavaScript

- SDK는 브라우저 환경에서만 초기화합니다. SSR 중 `window` 접근 금지.
- SDK 2.5.0+에서는 코드에 `projectId`, `username`, `password`만 두고, 웹푸시 세부
  옵션은 Notifly 콘솔 웹사이트 SDK 설정을 기준으로 합니다. 이 credential triple은
  iOS/Android/Flutter/RN/Web 공통 계약이므로 Web 전용으로 password 정책을 바꾸지 않습니다.
- 외부 config의 `projectId`는 프로젝트 규칙에 맞게 검증하고, 기존 config/provider/test
  구조가 있으면 보존합니다.
- 웹 팝업은 `trackEvent`와 유저/프로퍼티 동기화가 핵심입니다.
- 웹 푸시는 Service Worker path/scope, HTTPS secure context, Notification 권한,
  PushSubscription이 핵심입니다. 로컬 검증도 `https://localhost`에서 수행합니다.
- Next.js 로컬 HTTPS: `npm run dev -- --experimental-https` 또는
  `npx next dev --experimental-https`. Next.js가 아니면 `package.json`으로 프레임워크를
  식별한 뒤 해당 프레임워크의 공식 local HTTPS dev-server 방법을 확인해 실행합니다.

React/Next.js 핵심 패턴:

```js
import { useEffect } from "react";
import notifly from "notifly-js-sdk";

let notiflyInitialized = false;

export function useNotifly() {
  useEffect(() => {
    if (notiflyInitialized) return;
    if (typeof window === "undefined") return;

    notifly.initialize({
      projectId: process.env.NEXT_PUBLIC_NOTIFLY_PROJECT_ID,
      username: process.env.NEXT_PUBLIC_NOTIFLY_PROJECT_USERNAME,
      password: process.env.NEXT_PUBLIC_NOTIFLY_PROJECT_PASSWORD,
    });

    notiflyInitialized = true;
  }, []);
}
```

웹 푸시 Service Worker 기본 파일:

```js
self.importScripts(
  "https://cdn.jsdelivr.net/npm/notifly-js-sdk@2/dist/NotiflyServiceWorker.js"
);
```

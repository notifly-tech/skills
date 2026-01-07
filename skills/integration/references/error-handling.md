# Notifly SDK 연동 오류 처리

이 가이드는 연동 과정에서 자주 발생하는 오류와 해결 방법을 정리합니다.

## 1) 자격 증명 누락 / 오류

증상:

- SDK는 초기화되지만 콘솔에 아무 것도 표시되지 않음
- 인증(auth) 관련 로그/오류 발생

해결:

- 다음 **3가지** 값이 모두 있는지 확인:
  - `NOTIFLY_PROJECT_ID`
  - `NOTIFLY_USERNAME`
  - `NOTIFLY_PASSWORD`
- 값이 `https://console.notifly.tech/`에서 발급된 것인지 확인 (Project Settings
  → SDK credentials)

## 2) iOS: Firebase가 초기화되지 않음

증상:

- “FirebaseApp is not initialized. Please initialize FirebaseApp before calling
  Notifly.initialize.” 와 유사한 로그

해결:

- `Notifly.initialize(...)` **이전**에 `FirebaseApp.configure()`를 호출하세요.

## 3) iOS: 푸시가 도착하지 않음

해결 체크리스트:

- **Push Notifications** capability 활성화
- **Background Modes** 활성화: Remote notifications + Background fetch
- Firebase에 APNs 인증 키/인증서 업로드
- `application.registerForRemoteNotifications()` 호출
- APNs 토큰 전달:
  `Notifly.application(...didRegisterForRemoteNotificationsWithDeviceToken: ...)`

## 4) Android: 의존성(dependency) 해결 실패

증상:

- Gradle이 `com.github.team-michael:notifly-android-sdk`를 resolve 하지 못함

해결:

- JitPack 추가:
  - `maven { url 'https://jitpack.io' }`

## 5) React Native: 잘못된 npm 패키지

해결:

- 패키지는 **스코프 없음(unscoped)**: `notifly-sdk`

## 6) Flutter: iOS 빌드 이슈

해결:

- **Runner.xcworkspace**를 여세요 (`.xcodeproj` 아님)
- `cd ios && pod install` 실행

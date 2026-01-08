---
name: notifly-integration
description:
  노티플라이(Notifly) SDK를 Mobile(iOS/Android/Flutter/React Native) 및
  Web(JavaScript/Tag Manager) 프로젝트에 연동합니다. 공식 Notifly 문서와 SDK
  샘플을 단일 기준으로 삼아 설치/초기화/MCP 설정/검증/트러블슈팅을 단계별로
  안내합니다.
user-invocable: true
---

# Notifly SDK 연동 스킬

사용자가 **Notifly SDK**를 설치/설정/연동하려고 할 때 이 스킬을 사용하세요.
대상은:

- 푸시 알림
- 인앱 팝업 메시지 / 웹 팝업
- 유저 식별/유저 프로퍼티
- 이벤트 트래킹(플랫폼 SDK가 지원하는 범위)
- 웹 푸시 (Service Worker 기반)
- 웹 연동 (JavaScript SDK / Google Tag Manager)

## 연동 전략 (MCP 우선)

이 스킬은 항상 **MCP 우선**으로 동작하여, 최신의 검증된 문서/SDK 소스를 기준으로
의사결정합니다.

### 1단계: MCP 사용 가능 여부 확인

- Notifly MCP 도구가 있는지 확인:
  - `notifly-mcp-server:search_docs`
  - `notifly-mcp-server:search_sdk`

### 2단계: 기본 경로 (MCP 사용 가능)

- `notifly-mcp-server:search_docs`로 대상 플랫폼의 **공식 설치/초기화 단계**를
확인
- `notifly-mcp-server:search_sdk`로 **정확한 API 시그니처/공식 샘플 코드**를
확인
- MCP 결과가 존재하면 이를 **단일 기준**으로 취급 (추측 금지)

### 3단계: 대체 경로 (MCP 사용 불가)

- 이 레포의 정적 자료를 사용:
  - `references/`: 체크리스트/설명/문제 해결
  - `examples/`: 공식 문서/샘플에 맞춘 코드 패턴
- MCP가 필요하면 먼저 설치/구성:
  - 참고: `references/mcp-integration.md`
  - 또는 실행: `bash skills/integration/scripts/install-mcp.sh --help`

## 에이전트 작업 가이드라인

Cursor, Claude Code, Codex, Amp 등 AI IDE에서 이 스킬을 사용할 때:

- **사전 탐색부터 시작**
  - 플랫폼(들)과 진입점을 식별 (`AppDelegate.swift`, `Application`, `main.dart`,
  `index.js` 등)
  - 수정할 파일을 미리 선언
- **필요하면 질문**
  - RN/Flutter 같이 iOS/Android가 동시에 있는 경우, 어떤 플랫폼부터 할지 확인
  - “푸시만” vs “푸시 + 인앱 팝업” 범위를 확인
- **공식 소스 우선**
  - 플랫폼별 공식 문서를 기준으로 진행
  - API는 `search_sdk`로 확인해서 추측하지 않기
- **마지막에 검증 요약**
  - 변경 파일/설정 위치/검증 방법(콘솔 확인 포함)을 요약

## 연동 워크플로우

### 0단계: MCP 설정 (선택이지만 권장)

MCP 도구가 없다면 먼저 `notifly-mcp-server`를 구성하세요:

- 공식 가이드: `https://docs.notifly.tech/ko/devtools/notifly-mcp-server.md`
- 이 레포: `references/mcp-integration.md`
- 자동 설치/구성: `bash skills/integration/scripts/install-mcp.sh --help`

### 1단계: 사전 준비(필수 확인)

진행 전 반드시 확인:

- **Mobile**:
  - **Firebase 연동 완료** (Notifly는 FCM 사용)
  - **iOS APNs 인증을 Firebase에 등록** (iOS / Flutter iOS / RN iOS)
  - **Android 인앱 팝업은 Android 11 (API 30)+ 필요**
- **Web (웹 푸시 사용 시)**:
  - **VAPID 키 생성**: 콘솔 **설정 → SDK 설정 → 웹사이트 설정**
  - **HTTPS 환경 권장/필수**: 브라우저 권한 정책 및 Service Worker 요구사항
  - **Service Worker 파일 제공**: 번들러 사용 시 SW 파일이 누락되지 않도록
  public/static assets 복사 설정

공식 가이드:

- Android: `https://docs.notifly.tech/ko/developer-guide/android-sdk.md`
- iOS: `https://docs.notifly.tech/ko/developer-guide/ios-sdk.md`
- Flutter: `https://docs.notifly.tech/ko/developer-guide/flutter-sdk.md`
- React Native:
`https://docs.notifly.tech/ko/developer-guide/react-native-sdk.md`
- JavaScript(Web): `https://docs.notifly.tech/ko/developer-guide/javascript-sdk`

### 2단계: 자격 증명(SDK)

Notifly SDK 자격 증명(Mobile/Web 공통):

- `NOTIFLY_PROJECT_ID`
- `NOTIFLY_USERNAME`
- `NOTIFLY_PASSWORD`

Notifly 콘솔에서 확인: `https://console.notifly.tech/` → Project Settings → SDK
credentials.

**권장 사항**:

- 자격 증명을 소스에 하드코딩/커밋하지 마세요.
- 플랫폼에 맞는 런타임/빌드타임 시크릿 주입 방식을 사용하세요.

### 3단계: 플랫폼 식별(프로젝트 타입)

프로젝트가 어느 플랫폼인지 식별:

- **iOS**: `.xcodeproj` / `.xcworkspace`, `Podfile`, Swift/Obj-C 소스
- **Android**: `build.gradle(.kts)`, `AndroidManifest.xml`, Kotlin/Java 소스
- **Flutter**: `pubspec.yaml`, `lib/main.dart`, `ios/` + `android/`
- **React Native**: RN 의존성이 있는 `package.json`, `ios/` + `android/`
- **Web (JavaScript)**:
  - `package.json`에 `notifly-js-sdk` 의존성, 또는 HTML의 CDN `<script>`
  - `public/notifly-service-worker.js` (또는 동등한 루트 경로 SW 파일)

구조가 애매하면 멈추고 사용자에게 질문하세요.

**우선순위 규칙(중요)**:

- **React Native** 또는 **Flutter**가 확인되면, 네이티브 `ios/`, `android/`가
존재해도 **RN/Flutter를 1차 플랫폼**으로 취급합니다.

### 4단계: SDK 설치 (플랫폼별)

아래 “플랫폼 플레이북”을 기준으로 진행합니다. 가능한 한 공식 문서의 표현을
그대로 따르고, API는 MCP로 확인하세요.

## 플랫폼 플레이북

### iOS (Swift / Objective-C)

**설치(공식)**:

- CocoaPods: `pod 'notifly_sdk'`
- Swift Package Manager: `https://github.com/team-michael/notifly-ios-sdk`

**프로젝트 설정(공식)**:

- **Push Notifications** 활성화
- **Background Modes** 활성화 (Remote notifications, Background fetch)
- 최소 iOS 타겟 **13.0+**

**초기화(공식 패턴)**:

- `AppDelegate`에서 `FirebaseApp.configure()` 및 Notifly 초기화 수행
- 알림 권한 요청 후 원격 알림 등록
- `UNUserNotificationCenter` 델리게이트 설정
- APNs 토큰/푸시 콜백을 Notifly로 전달

공식 가이드: `https://docs.notifly.tech/ko/developer-guide/ios-sdk.md`

예시: `examples/ios-integration.swift`

### Android (Kotlin / Java)

**설치(공식)**:

- JitPack 저장소 추가
- 의존성 추가:
`implementation 'com.github.team-michael:notifly-android-sdk:<latest>'`

**초기화(공식)**:

- `Application.onCreate()`에서 초기화:
  - `Notifly.initialize(applicationContext, NOTIFLY_PROJECT_ID, BuildConfig.NOTIFLY_USERNAME, BuildConfig.NOTIFLY_PASSWORD)`

**유저 식별(초기화 후, 공식)**:

- `Notifly.setUserId(context, userId)` (로그아웃 시:
`Notifly.setUserId(context, null)`)
- `Notifly.setUserProperties(context, params)`

**이벤트 트래킹(초기화 후, 공식)**:

- `Notifly.trackEvent(context, eventName, eventParams, segmentationEventParamKeys)`

예시: `examples/android-integration.kt`

### Flutter

**설치(공식)**:

- `flutter pub add notifly_flutter`
- iOS: `cd ios && pod install`

**초기화(공식)**:

- `Firebase.initializeApp()` 보장
- `await NotiflyPlugin.initialize(projectId: ..., username: ..., password: ...)`
- (선택) 콘솔에서 “자동 권한 요청”이 비활성화된 경우:
`await NotiflyPlugin.requestPermission()`
- (선택) 인앱 팝업 이벤트 구독(공식 예시):
`NotiflyPlugin.inAppEvents.listen(...)`

예시: `examples/flutter-integration.dart`

### React Native

**설치(공식)**:

- npm 패키지: `notifly-sdk`
- iOS: `cd ios && pod install`

**설정(공식)**:

- RN은 iOS/Android 네이티브 연동이 필요(공식 RN 문서 참조)
- 네이티브 연동 후, JS에서 `notifly-sdk` API 사용

**JS API 사용(네이티브 연동 후)**:

- `notifly.setUserId(userId)` (로그아웃: `notifly.setUserId(null)` 또는
`notifly.setUserId()`)
- `notifly.setUserProperties({...})`
- `notifly.setEmail(email)`
- `notifly.setPhoneNumber(phoneNumber)`
- `notifly.setTimezone(timezone)`

예시: `examples/react-native-integration.tsx`

### Web (JavaScript SDK)

**지원 기능(공식)**:

- 웹 푸시(웹 푸시 알림 수신)
- 웹 팝업(인앱 유사 웹 팝업)
- 유저 식별/유저 프로퍼티/이벤트 트래킹

**필수 선행(웹 푸시 사용 시, 공식)**:

- 콘솔에서 VAPID 키 생성: 설정 → SDK 설정 → 웹사이트 설정
- HTTPS 환경에서 서비스(브라우저 정책)
- Service Worker 파일을 **루트 경로**에서 제공(예: `/notifly-service-worker.js`)

**1) Service Worker 등록(공식 패턴)**:

- 루트(public) 경로에 `notifly-service-worker.js` 생성
- 내용(공식 패턴):
  - `self.importScripts("https://cdn.jsdelivr.net/npm/notifly-js-sdk@2/dist/NotiflyServiceWorker.js");`
- 번들러 사용 시 SW 파일이 번들에 흡수/삭제되지 않도록 assets copy 설정

예시: `examples/notifly-service-worker.js`

**2) SDK 설치(선택)**:

- npm/yarn/pnpm: `notifly-js-sdk` 설치
- 또는 CDN으로 로드 후 `window.notifly` 접근

**3) SDK 초기화(공식 패턴)**:

- `projectId`, `username`, `password`는 코드에서 지정
- (참고) SDK 2.5.0+에서는 웹 푸시 세부 옵션(VAPID/SW 경로/권한 팝업 등)이 콘솔
설정값으로 대체될 수 있음(공식 문서 우선)

예시: `examples/web-integration.js`

**4) 권한 요청(공식)**:

- 콘솔에서 자동 권한 팝업을 켜면 방문 시 안내 → 브라우저 권한 요청 순서로 동작
- 특정 타이밍에만 요청하려면(콘솔 자동 노출 OFF)
`notifly.requestPermission(...)`

**5) 유저/이벤트(공식)**:

- `notifly.setUserId(userId | null)`
- `notifly.setUserProperties({...})`
- `notifly.trackEvent(name, params, segmentationEventParamKeys)`

**6) Google Tag Manager(GTM) 옵션(선택)**:

- 코드 수정 없이 초기화/유저/이벤트를 구성 가능(공식 GTM 가이드 참고)
- 단, 웹 푸시를 쓰는 경우 SW 파일 제공은 여전히 필요

### 5단계: SDK 초기화 위치 확정(레포 기준 증빙)

이 단계는 “어디에 코드를 넣는지”와 “레포에서 증명 가능한지”를 점검합니다.

#### iOS 초기화 체크리스트

- **엔트리포인트**: `AppDelegate.swift` (또는 SwiftUI에서
`@UIApplicationDelegateAdaptor(AppDelegate.self)` 사용)
- **필수 포함**:
  - `FirebaseApp.configure()`
  - `Notifly.initialize(projectId:username:password)`
  - `UNUserNotificationCenter.current().delegate = self`
  - 아래 콜백 전달:
    - `application(_:didRegisterForRemoteNotificationsWithDeviceToken:)`
    - `application(_:didFailToRegisterForRemoteNotificationsWithError:)`
    - `userNotificationCenter(_:didReceive:withCompletionHandler:)`
    - `userNotificationCenter(_:willPresent:withCompletionHandler:)`

#### Android 초기화 체크리스트

- **엔트리포인트**: 커스텀 `Application` 클래스 (Kotlin/Java)
- `AndroidManifest.xml`의 `android:name`으로 등록
- **필수 포함**: `Application.onCreate()`에서 `Notifly.initialize(...)`

#### Flutter 초기화 체크리스트

- **엔트리포인트**: `lib/main.dart` (+ iOS 브릿지 파일은 공식 문서대로)
- **필수 포함**: `await NotiflyPlugin.initialize(...)`
- **iOS 참고**: 공식 Flutter 문서는 `ios/Runner/AppDelegate.mm` 작업을 기대함
(`flutter-sdk.md` 참조)

#### React Native 초기화 체크리스트

- **네이티브**: 공식 RN 문서대로 iOS `AppDelegate.mm`, Android `Application`
연동 수행
- **JS**: 공식 RN SDK 샘플 패턴대로 API 사용(예시 파일 참조)

### 6단계: 검증(필수)

1. 스크립트 실행(앱 프로젝트 루트에서):

- `bash skills/integration/scripts/validate-sdk.sh`

> 참고: 위 스크립트는 **모바일 플랫폼(iOS/Android/Flutter/RN)** 검증용입니다.
> Web(JavaScript) 연동은 아래의 수동 검증 체크리스트를 사용하세요.

2. 빌드/실행 후 콘솔에서 확인:

- 초기화 로그/동작 확인
- 푸시 토큰 등록(네이티브) 확인
- Notifly 콘솔에서 이벤트/기기 등록 확인

3. Web 수동 검증(웹 푸시/웹 팝업):

- `/notifly-service-worker.js`가 실제로 200 응답 + 올바른 내용인지 확인
- 브라우저에서 알림 권한 요청/허용 흐름이 의도대로 동작하는지 확인
- `setUserId → setUserProperties → trackEvent` 호출 후 콘솔에서 반영 확인

### 7단계: 플랫폼별 레포 검증 체크리스트

#### iOS

- 의존성 존재 (Pods 또는 SPM)
- Capability 설정 완료 (Push + Background Modes)
- `AppDelegate`에서 APNs 콜백을 Notifly로 전달

#### Android

- JitPack repo 설정
- SDK 의존성 존재
- `Application` 클래스 존재 및 매니페스트 등록
- `Application.onCreate()`에서 `Notifly.initialize(...)`

#### Flutter

- `pubspec.yaml`에 `notifly_flutter` 포함
- `ios/Podfile.lock`이 `pod install` 이후 업데이트됨
- `NotiflyPlugin.initialize(...)` 호출

#### React Native

- `package.json`에 `notifly-sdk` 포함
- `ios/Podfile.lock`이 `pod install` 이후 업데이트됨
- 공식 문서대로 네이티브 연동 완료
- JS 호출이 공식 샘플 패턴과 일치

#### Web (JavaScript)

- `notifly-js-sdk` 설치(npm) 또는 CDN 로드 확인
- 루트 경로에 Service Worker 파일 존재(예: `public/notifly-service-worker.js`)
- SW 파일이 `NotiflyServiceWorker.js`를 importScripts 하는지 확인
- 앱 코드에서 `notifly.initialize({ projectId, username, password, ... })` 호출
확인
- (웹 푸시) 권한 요청 및 구독 흐름이 동작하는지 확인
- `setUserId`, `setUserProperties`, `trackEvent` 호출이 제품 요구사항과 일치

### 8단계: 문서화

연동 후 README/내부 문서에 다음을 기록:

- 필요한 자격 증명과 주입 방법(시크릿은 노출하지 않기)
- iOS/Android 빌드/런 방법
- Notifly 콘솔에서 검증하는 방법

## 문서 사용 노트 (MCP vs 정적 자료)

- MCP 사용 가능: `search_docs` / `search_sdk` 결과를 단일 진실원으로 취급
- MCP 사용 불가: 공식 문서 링크 + 이 스킬 폴더의 `examples/`, `references/` 사용

## 점진적 공개(Progressive Disclosure)

- **레벨 1**: `SKILL.md` / `SKILL.ko.md`
- **레벨 2**: `references/`
- **레벨 3**: `examples/`
- **레벨 4**: `scripts/`

## 참고 자료(References)

- `references/sdk-reference.md`
- `references/error-handling.md`
- `references/framework-patterns.md`
- `references/mcp-integration.md`

## 예시(Examples)

- `examples/ios-integration.swift`
- `examples/android-integration.kt`
- `examples/flutter-integration.dart`
- `examples/react-native-integration.tsx`
- `examples/notifly-service-worker.js`
- `examples/web-integration.js`

## 스크립트(Scripts)

- `scripts/install-mcp.sh` (클라이언트에 MCP 서버 구성)
- `scripts/validate-sdk.sh` (SDK 연동 마커 검증)


# Notifly SDK Integration Reference (Quick Cheatsheet)

This reference is intentionally concise. For the canonical, up-to-date steps,
use:

- iOS: `https://docs.notifly.tech/ko/developer-guide/ios-sdk.md`
- Android: `https://docs.notifly.tech/ko/developer-guide/android-sdk.md`
- React Native:
  `https://docs.notifly.tech/ko/developer-guide/react-native-sdk.md`
- Flutter: `https://docs.notifly.tech/ko/developer-guide/flutter-sdk.md`

## Credentials (SDK)

Notifly Mobile SDK uses these credentials:

- `NOTIFLY_PROJECT_ID`
- `NOTIFLY_USERNAME`
- `NOTIFLY_PASSWORD`

Get them from **Notifly Console** (`https://console.notifly.tech/`) → Project
Settings → SDK credentials.

## Install artifacts (canonical)

- **iOS (CocoaPods)**: `pod 'notifly_sdk'`
- **iOS (SPM)**: `https://github.com/team-michael/notifly-ios-sdk`
- **Android (Gradle + JitPack)**:
  `implementation 'com.github.team-michael:notifly-android-sdk:<latest>'`
- **React Native (npm)**: `notifly-sdk`
- **Flutter (pub.dev)**: `notifly_flutter`

## Initialize (canonical)

- **iOS**: `UNUserNotificationCenter.current().requestAuthorization(...)` then
  `FirebaseApp.configure()` then
  `Notifly.initialize(projectId:username:password)`
- **Android**:
  `Notifly.initialize(applicationContext, NOTIFLY_PROJECT_ID, BuildConfig.NOTIFLY_USERNAME, BuildConfig.NOTIFLY_PASSWORD)`
  (in `Application.onCreate()`)
- **Flutter**:
  `await NotiflyPlugin.initialize(projectId: ..., username: ..., password: ...)`
- **React Native**: follow native setup first, then call JS APIs from
  `notifly-sdk`.

## Android: core APIs (after initialize)

- **User**:
  - `Notifly.setUserId(context, userId)` (logout:
    `Notifly.setUserId(context, null)`)
  - `Notifly.setUserProperties(context, params)`
- **Event**:
  - `Notifly.trackEvent(context, eventName, eventParams, segmentationEventParamKeys)`
  - `segmentationEventParamKeys`: **max 1 key**

## MCP-first rule

When available, always use `notifly-mcp-server` to confirm method
names/signatures:

- `notifly-mcp-server:search_docs` for platform guides
- `notifly-mcp-server:search_sdk` for iOS + Flutter SDK source snippets

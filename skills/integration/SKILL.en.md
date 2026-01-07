---
name: notifly-integration
description:
  Integrates Notifly Mobile SDK into iOS, Android, Flutter, and React Native
  projects. Provides step-by-step guidance for installation, initialization,
  MCP-assisted verification, and troubleshooting using the official Notifly docs
  and SDK samples as the source of truth.
---

# Notifly SDK Integration Skill

**Language / 언어**

- **한국어(기본)**: `SKILL.md`
- **English**: `SKILL.en.md`
- **Rule**: If the user is asking in Korean, follow `SKILL.md`. Otherwise,
  follow this file.

Use this skill when the user asks to install/setup/integrate **Notifly SDK**
for:

- Push notifications
- In-app popup messaging
- User identity and user properties
- Event tracking (where supported by the platform SDK)

## Integration Strategy (MCP-first)

This skill follows an **“MCP-first”** strategy so the agent always uses the
latest verified documentation and SDK sources.

### Step 1: Check for MCP capability

- Check if the Notifly MCP tools are available:
  - `notifly-mcp-server:search_docs`
  - `notifly-mcp-server:search_sdk`

### Step 2: Primary path (MCP available)

- Use `notifly-mcp-server:search_docs` to confirm the **official steps** for the
  target platform(s).
- Use `notifly-mcp-server:search_sdk` to confirm the **exact API signatures**
  and **official sample code** (when available).
- Treat MCP results as the **single source of truth** when they exist.

### Step 3: Fallback path (MCP unavailable)

- Use the static references in this repo:
  - `references/` for checklists and explanations
  - `examples/` for code patterns (kept aligned to official docs/samples)
- If you need MCP, install/configure it first:
  - See: `references/mcp-integration.md`
  - Or run: `bash skills/integration/scripts/install-mcp.sh --help`

## Interaction Guidelines for Agents

When using this skill in an AI IDE (Cursor, Claude Code, Codex, Amp, etc.):

- **Start with reconnaissance**
  - Identify platform(s) and entrypoints (`AppDelegate.swift`, `Application`,
    `main.dart`, `index.js`, etc.).
  - State what you detected and what files you’ll touch.
- **Ask clarifying questions**
  - If multiple platforms exist (RN/Flutter includes both iOS/Android), confirm
    which one(s) to integrate first.
  - Confirm whether the user wants push only vs push + in-app.
- **Prefer official sources**
  - Use the official docs pages per platform as truth.
  - Use `search_sdk` outputs to avoid guessing APIs.
- **End with a verification summary**
  - List files modified, where credentials are stored, and how to validate.

## Integration Workflow

### Phase 0: MCP setup (optional but recommended)

If MCP tools aren’t available, configure `notifly-mcp-server` first:

- Official guide: `https://docs.notifly.tech/ko/devtools/notifly-mcp-server.md`
- This repo: `references/mcp-integration.md`
- Automated setup: `bash skills/integration/scripts/install-mcp.sh --help`

### Phase 1: Prerequisites (must confirm)

Before continuing, confirm:

- **Firebase project integration is completed** (Notifly uses FCM)
- **iOS APNs auth is configured in Firebase** (for iOS / Flutter iOS / RN iOS)
- **Android in-app popups require Android 11 (API 30)+**

Use official platform guides:

- Android: `https://docs.notifly.tech/ko/developer-guide/android-sdk.md`
- iOS: `https://docs.notifly.tech/ko/developer-guide/ios-sdk.md`
- Flutter: `https://docs.notifly.tech/ko/developer-guide/flutter-sdk.md`
- React Native:
  `https://docs.notifly.tech/ko/developer-guide/react-native-sdk.md`

### Phase 2: Credentials (SDK)

Notifly Mobile SDK uses:

- `NOTIFLY_PROJECT_ID`
- `NOTIFLY_USERNAME`
- `NOTIFLY_PASSWORD`

Ask the user to retrieve them from **Notifly Console**:
`https://console.notifly.tech/` → Project Settings → SDK credentials.

**Best practice**:

- Do **not** hardcode credentials in source control.
- Prefer runtime configuration (CI secrets, environment variables, secure
  config) appropriate to the platform.

### Phase 3: Platform detection (project type)

Identify which platform(s) the project is:

- **iOS**: `.xcodeproj` / `.xcworkspace`, `Podfile`, Swift/Obj-C sources
- **Android**: `build.gradle(.kts)`, `AndroidManifest.xml`, Kotlin/Java sources
- **Flutter**: `pubspec.yaml`, `lib/main.dart`, plus `ios/` and `android/`
- **React Native**: `package.json` with RN deps, plus `ios/` and `android/`

If the structure is ambiguous, stop and ask the user.

**Priority rule** (important):

- If **React Native** or **Flutter** is detected, treat it as the primary
  platform even if native `ios/` and `android/` folders exist.

### Phase 4: SDK installation (per platform)

Use the platform playbooks below. When possible, copy steps from official docs
verbatim and confirm API names via MCP.

## Platform Playbooks

### iOS (Swift / Objective-C)

**Install** (official):

- CocoaPods: `pod 'notifly_sdk'`
- Swift Package Manager: `https://github.com/team-michael/notifly-ios-sdk`

**Configure** (official):

- Enable **Push Notifications**
- Enable **Background Modes** (Remote notifications, Background fetch)
- Ensure minimum iOS target is **13.0+**

**Initialize** (official patterns):

- `FirebaseApp.configure()` and Notifly initialization in `AppDelegate`
- Request authorization, register for remote notifications
- Set `UNUserNotificationCenter` delegate
- Forward APNs token + notification callbacks to Notifly

See official guide: `https://docs.notifly.tech/ko/developer-guide/ios-sdk.md`

See example: `examples/ios-integration.swift`

### Android (Kotlin / Java)

**Install** (official):

- Add JitPack repository
- Add dependency:
  `implementation 'com.github.team-michael:notifly-android-sdk:<latest>'`

**Initialize** (official):

- Initialize in `Application.onCreate()`:
  - `Notifly.initialize(applicationContext, NOTIFLY_PROJECT_ID, BuildConfig.NOTIFLY_USERNAME, BuildConfig.NOTIFLY_PASSWORD)`

**User identity (after initialize)** (official):

- `Notifly.setUserId(context, userId)` (logout:
  `Notifly.setUserId(context, null)`)
- `Notifly.setUserProperties(context, params)`

**Event tracking (after initialize)** (official):

- `Notifly.trackEvent(context, eventName, eventParams, segmentationEventParamKeys)`

See example: `examples/android-integration.kt`

### Flutter

**Install** (official):

- `flutter pub add notifly_flutter`
- iOS: `cd ios && pod install`

**Initialize** (official):

- Ensure `Firebase.initializeApp()`
- `await NotiflyPlugin.initialize(projectId: ..., username: ..., password: ...)`
- (Optional) If console “auto permission request” is OFF, call:
  `await NotiflyPlugin.requestPermission()`
- (Optional) Subscribe to in-app popup events (official doc example):
  `NotiflyPlugin.inAppEvents.listen(...)`

See example: `examples/flutter-integration.dart`

### React Native

**Install** (official):

- npm package: `notifly-sdk`
- iOS: `cd ios && pod install`

**Setup** (official):

- React Native requires native integration on iOS/Android (see official doc).
- After native setup, use the JS APIs from `notifly-sdk`.

**Use JS API (after native setup)**:

- `notifly.setUserId(userId)` (logout: `notifly.setUserId(null)` or
  `notifly.setUserId()`)
- `notifly.setUserProperties({...})`
- `notifly.setEmail(email)`
- `notifly.setPhoneNumber(phoneNumber)`
- `notifly.setTimezone(timezone)`

See example: `examples/react-native-integration.tsx`

### Phase 5: SDK initialization (repo-proof steps)

This phase is about “where to put the code” and “how to confirm it’s correct in
the repository”.

#### iOS initialization checklist

- **Entrypoint**: `AppDelegate.swift` (or SwiftUI app using
  `@UIApplicationDelegateAdaptor(AppDelegate.self)`).
- **Must include**:
  - `FirebaseApp.configure()`
  - `Notifly.initialize(projectId:username:password)`
  - `UNUserNotificationCenter.current().delegate = self`
  - Forward:
    - `application(_:didRegisterForRemoteNotificationsWithDeviceToken:)`
    - `application(_:didFailToRegisterForRemoteNotificationsWithError:)`
    - `userNotificationCenter(_:didReceive:withCompletionHandler:)`
    - `userNotificationCenter(_:willPresent:withCompletionHandler:)`

#### Android initialization checklist

- **Entrypoint**: a custom `Application` class (Kotlin/Java) registered in
  `AndroidManifest.xml` via `android:name`.
- **Must include**: `Notifly.initialize(...)` inside `Application.onCreate()`.

#### Flutter initialization checklist

- **Entrypoint**: `lib/main.dart` (and iOS bridge file per docs).
- **Must include**: `await NotiflyPlugin.initialize(...)`
- **iOS note**: the official Flutter guide expects wiring in
  `ios/Runner/AppDelegate.mm` (see `flutter-sdk.md`).

#### React Native initialization checklist

- **Native**: follow the official RN guide for iOS `AppDelegate.mm` and Android
  `Application`.
- **JS**: use JS APIs from the official RN SDK sample patterns (see
  `examples/react-native-integration.tsx`).

### Phase 6: Verification (required)

1. Run the validation script (from your app project root):

- `bash skills/integration/scripts/validate-sdk.sh`

2. Build/run the app and confirm:

- Initialization logs appear
- Push token is registered (native)
- Events show up in Notifly console

### Phase 7: Platform verification checklists (repo verification)

Use these checklists to verify the integration is actually present in the repo,
not just described in chat.

#### iOS checklist

- Dependency present: `Podfile` / `Podfile.lock` or SPM dependency configured
- App capabilities enabled: Push Notifications + Background Modes
- `AppDelegate` forwards APNs callbacks to Notifly

#### Android checklist

- JitPack repo configured (root Gradle)
- Dependency present in app module Gradle
- `Application` subclass exists and is registered in `AndroidManifest.xml`
- `Notifly.initialize(...)` called in `Application.onCreate()`

#### Flutter checklist

- `pubspec.yaml` includes `notifly_flutter`
- `ios/Podfile.lock` updated after `pod install`
- `NotiflyPlugin.initialize(...)` called before app usage
- If using in-app events: `NotiflyPlugin.inAppEvents.listen(...)` is wired

#### React Native checklist

- `package.json` includes `notifly-sdk`
- `ios/Podfile.lock` updated after `pod install`
- Native setup complete per official doc (`AppDelegate.mm` etc.)
- JS calls match the official sample patterns

### Phase 8: Documentation

After integration, update the project docs (README or internal docs) with:

- Required credentials and where they are configured (without leaking secrets)
- Build/run steps for iOS/Android
- How to validate integration in Notifly console

## Docs Usage Note (MCP vs Static)

- If MCP tools are available: treat `search_docs` / `search_sdk` results as the
  source of truth for APIs and exact code.
- If MCP tools are unavailable: follow official docs links and the pinned
  examples in this skill folder.

## Progressive Disclosure

- **Level 1**: `SKILL.md` (this file)
- **Level 2**: `references/` (deeper docs/checklists)
- **Level 3**: `examples/` (code patterns aligned to official docs/samples)
- **Level 4**: `scripts/` (automation + validation)

## References

- `references/sdk-reference.md` (quick cheatsheet)
- `references/error-handling.md` (common failures)
- `references/framework-patterns.md` (framework patterns)
- `references/mcp-integration.md` (MCP setup for multiple clients)

## Examples

- `examples/ios-integration.swift`
- `examples/android-integration.kt`
- `examples/flutter-integration.dart`
- `examples/react-native-integration.tsx`

## Scripts

- `scripts/install-mcp.sh` (configure MCP server in your client)
- `scripts/validate-sdk.sh` (validate SDK integration markers)

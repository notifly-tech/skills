---
name: migrate-from-onesignal
display-name: Migrate from OneSignal to Notifly
short-description: Migrate OneSignal SDK integrations to Notifly across mobile and web
summary: >
  Replace or dual-write OneSignal SDK integrations with Notifly using Remote MCP,
  OneSignal SDK structure checks, and platform-specific SDK references.
description:
  OneSignal SDK 연동을 Notifly SDK와 Notifly Remote MCP 기반 운영 흐름으로 이전합니다.
  iOS(Swift), Android(Kotlin/Java), Flutter, React Native, Expo, Web을 지원하며,
  OneSignal 완전 제거(complete)와 일정 기간 공존(coexist/dual-write)을 모두 다룹니다.
user-invocable: true
---

# Migrate from OneSignal

사용자가 **OneSignal에서 Notifly로 이전**, **OneSignal SDK 제거**, **OneSignal/Notifly 공존**,
**푸시/인앱/유저 태그/이벤트 SDK 교체**, **one-signal migration**을 요청할 때 이 스킬을 사용하세요.

지원 플랫폼:

- iOS Swift / SwiftUI
- Android Kotlin / Java
- Flutter
- React Native
- Expo
- Web JavaScript / TypeScript

## 핵심 원칙

1. **먼저 묻기:** 코드 수정 전에 migration mode를 확인합니다.
   - `complete`: 이번 작업에서 OneSignal SDK/config/import/callsite/service worker/extension을 제거하고 Notifly로 완전 대체합니다.
   - `coexist`: 일정 기간 OneSignal과 Notifly를 dual-write/공존시키고, 검증 후 OneSignal을 제거합니다.
2. **플랫폼을 먼저 판별:** repo 구조를 보고 정확히 하나 이상의 platform track을 선택합니다.
   monorepo나 cross-platform 앱이면 관련 track을 모두 적용합니다.
3. **OneSignal SDK 구조를 먼저 확인:** OneSignal v5는 `OneSignal.User`, `OneSignal.Notifications`,
   `OneSignal.InAppMessages` namespace 중심입니다. 기존 v3/v4 프로젝트는 `setExternalUserId`,
   `sendTag`, `setNotificationOpenedHandler`, `setInAppMessageClickHandler` 같은 구형 API가 남아 있을 수 있습니다.
4. **Provider ID를 고객 ID로 승격하지 않기:** OneSignal `onesignal_id`, `subscription_id`, 과거 `player_id`는
   provider/device 식별자입니다. 사용자 식별은 `login(external_id)`/구형 `setExternalUserId`에서 사용한
   고객의 stable ID를 찾아 `Notifly.setUserId`로 이전합니다.
5. **태그와 이벤트 분리:** OneSignal Tags는 모든 값이 문자열인 장기 user data입니다. Notifly로 옮길 때는
   long-lived 상태는 `setUserProperties`, 행동 로그는 `trackEvent`로 분리합니다. OneSignal Custom Events는
   `trackEvent`로 옮기되, Notifly segmentation에 쓸 event param key는 최대 1개만 고릅니다.
6. **토큰/credential 직접 이전 금지:** OneSignal App ID, REST API Key, APNs/FCM credential, subscription/player ID를
   Notifly SDK 설정값이나 raw push token으로 재사용하지 않습니다. Notifly SDK가 자체 등록하게 합니다.
7. **Remote MCP 우선:** Notifly 설정/프로젝트/캠페인/문서 정보는 Remote MCP에서 확인합니다.
   로컬 `npx notifly-mcp-server`를 기본으로 설치하지 마세요.
8. **Pre-SDK catalog 한계 인지:** Notifly SDK가 아직 연동되지 않은 프로젝트에서는 MCP가 제공하는
   `user_properties`/`events` 카탈로그가 비어 있거나 제한적일 수 있습니다. 이를 "이벤트가 없다"로
   해석하지 말고, OneSignal 코드 인벤토리와 제품 요구사항에서 목표 taxonomy를 먼저 만들고 SDK 연동 후
   MCP/콘솔로 수집 여부를 검증합니다.
9. **기능 동등성 분리:** 유저 식별/태그/이벤트/푸시 클릭은 SDK 코드로 이전할 수 있지만, OneSignal Journeys,
   Segments, Dashboard prompts, Email/SMS, Live Activities, confirmed delivery 리포트는 제품·캠페인 설계가 필요합니다.
10. **초안만 생성:** MCP 쓰기 도구는 캠페인/유저 여정 초안 생성·수정까지만 사용합니다.
    활성화, 발송, 삭제를 자동 수행하지 마세요.
11. **검증 전 제거 금지:** complete mode라도 빌드/정적 검색/런타임 검증 전에는 OneSignal 의존성과 설정을 제거하지 않습니다.

## 0단계: migration mode 확인(필수)

코드 변경 전에 아래 질문을 사용자에게 하세요. 이미 답이 명확히 제공된 경우에만 생략합니다.

```text
OneSignal → Notifly 이전 방식을 먼저 정해야 합니다.
1) complete: 이번 작업에서 OneSignal SDK/config/import/callsite/service worker/extension을 제거하고 Notifly로 완전 대체
2) coexist: 일정 기간 OneSignal과 Notifly를 dual-write/공존시키고, 검증 후 별도 작업에서 OneSignal 제거
어느 방식으로 진행할까요? 공존이면 기간/릴리즈 기준도 알려주세요.
```

- `complete` 선택 전 확인할 것: OneSignal Push/In-App/Journeys/Segments/Tags/Custom Events/Email/SMS가 실제 제품 동작을 담당하는지.
- `coexist` 선택 전 확인할 것: dual-write 범위(유저 ID/태그/이벤트/푸시 클릭), 중복 메시지 방지 정책, 공존 종료 기준.

## 1단계: 플랫폼 판별 gate

프로젝트 루트에서 아래 신호를 확인하고, 해당 platform reference를 읽습니다.

| Platform | 판별 신호 | Reference |
| --- | --- | --- |
| iOS Swift | `*.xcodeproj`, `*.xcworkspace`, `Package.swift`, `Podfile`, `AppDelegate.swift`, `OneSignalFramework`, `OneSignalExtension` | `references/platforms/ios-swift.md` |
| Android Kotlin/Java | `settings.gradle(.kts)`, `build.gradle(.kts)`, `AndroidManifest.xml`, `Application`, `com.onesignal:OneSignal`, Kotlin/Java source | `references/platforms/android-kotlin.md` |
| Flutter | `pubspec.yaml`, `onesignal_flutter`, `lib/`, `android/`, `ios/`, `web/` | `references/platforms/flutter.md` |
| React Native | `package.json` with `react-native-onesignal`, `ios/`, `android/`, `App.tsx`/`index.js` | `references/platforms/react-native.md` |
| Expo | `expo`, `onesignal-expo-plugin`, `app.json`, `app.config.js/ts`, `eas.json`, `expo prebuild` output | `references/platforms/expo.md` |
| Web | `OneSignalSDK.page.js`, `OneSignalDeferred`, `OneSignalSDKWorker.js`, service worker, web bundler/app framework | `references/platforms/web.md` |

판별이 애매하면 코드 변경 전에 한 가지 disambiguation 질문만 합니다. 예:
"Expo Go만 쓰는 앱인가요, 아니면 EAS development/native build를 쓰는 앱인가요?"

## 2단계: OneSignal SDK 구조와 현재 연동 인벤토리

먼저 `references/onesignal-sdk-structure.md`를 읽고 현재 코드가 OneSignal v5 user model인지, 구형 API인지 확인합니다.
그 다음 `references/migration-core.md`의 inventory 표를 사용해 기능별로 나눠 기록합니다.

필수 수집 항목:

- 초기화/config: OneSignal App ID, APNs/FCM credential 의존성, log level, privacy consent, web service worker path/scope
- 유저 식별: `login(external_id)`, `logout`, 구형 `setExternalUserId`/`removeExternalUserId`, aliases
- 유저 데이터: `OneSignal.User.addTag(s)`, 구형 `sendTag(s)`, Tags export/import, 값 타입 문자열화 규칙
- 이벤트: `OneSignal.User.trackEvent`, outcomes, tags-as-behavior, REST/API custom events
- 푸시: permission prompt, subscription/player ID 조회, notification click/foreground listeners, FCM/APNs delegate/service/extension
- 인앱: triggers, click/lifecycle listeners, dashboard in-app behavior
- Web: `OneSignalDeferred`, `OneSignalSDKWorker.js`, `serviceWorkerPath`, slidedown/category prompts, auto-resubscribe
- Dashboard 기능: Journeys, Segments, templates, Email/SMS, Live Activities, confirmed delivery, webhooks/export dependencies

## 3단계: Notifly Remote MCP 연결 확인

Remote MCP의 canonical endpoint는 다음입니다.

```text
https://api.notifly.tech/mcp
```

Claude Code:

```bash
claude mcp add --transport http notifly https://api.notifly.tech/mcp
claude mcp list
claude mcp get notifly
```

Codex:

```bash
codex mcp add notifly --url https://api.notifly.tech/mcp
codex mcp login notifly --scopes mcp:read,mcp:tools
codex mcp get notifly
codex mcp list
```

정상 연결이면 OAuth 로그인 후 Notifly 도구가 보입니다. 자세한 프로토콜/도구 목록은
`references/remote-mcp.md`가 있으면 그 문서를, 없으면 Notifly 공식 MCP 문서를 확인하세요.

## 4단계: MCP로 필요한 Notifly 정보 수집

코드 변경 또는 캠페인 초안 생성 전에 Remote MCP에서 다음을 확인합니다.

1. 접근 가능한 제품/프로젝트:
   - `list_products`
   - `list_projects`
   - 필요 시 `get_project`, `get_product`
2. 프로젝트 SDK/캠페인 설계에 필요한 카탈로그:
   - `list_project_channels`
   - `list_project_events`
   - `list_user_properties`
3. **중요:** SDK 연동 전이거나 아직 해당 앱에서 Notifly 이벤트를 보내지 않았다면
   `list_project_events`/`list_user_properties` 결과가 비어 있거나 일부 서버/API 이벤트만 보일 수 있습니다.
   이 상태는 정상적인 pre-integration 상태일 수 있으므로, migration을 막는 blocker로 보지 않습니다.
4. 기존 캠페인/성과/유저 상태 확인:
   - `list_campaigns`, `get_campaign`, `get_campaign_statistics`
   - `identify_user`, `list_user_channels`, `list_user_events`
   - `get_campaign_user_eligibility`, `list_campaign_user_deliveries`
5. 공식 문서 확인:
   - `search_notifly_docs`
   - `query_docs_filesystem_notifly_docs`

캠페인 초안을 만들거나 바꿀 때는 반드시 먼저 `describe_campaign_payload`를 호출해 해당 channel/type/timing/segment 조합의
`full_example_payload`를 확인한 뒤 `create_campaign` 또는 `replace_campaign`을 사용합니다.

## 5단계: 플랫폼별 매핑 적용

공통 매핑은 아래와 같습니다. 구체적인 파일/코드는 platform reference를 따릅니다.

| OneSignal 개념 | Notifly 개념 | 메모 |
| --- | --- | --- |
| SDK initialize / App ID | Notifly SDK initialize / projectId / username | `password`는 과거 호환 placeholder입니다. 실제 비밀번호/API secret을 넣지 않습니다. |
| `login(external_id)` / 구형 `setExternalUserId` | `setUserId(userId)` | OneSignal ID/subscription ID가 아니라 고객 stable ID를 사용합니다. |
| `logout()` / 구형 `removeExternalUserId` | `setUserId(null/nil/undefined)` | 로그아웃 후 익명 user 처리 정책을 플랫폼별로 확인합니다. |
| Tags / `addTag(s)` / `sendTag(s)` | `setUserProperties(...)` | OneSignal tag는 string-only입니다. Notifly 타입 규칙에 맞게 bool/number/timestamp 변환을 명시합니다. |
| Custom Events / `User.trackEvent` | `trackEvent(...)` | event name 유지 우선, `segmentationEventParamKeys`는 최대 1개. |
| Push click / foreground listener | Notifly push click listener/callback | payload key는 Notifly campaign custom data와 맞춤. |
| In-App triggers/click/lifecycle | Notifly in-app popup listener/events + campaign design | trigger semantics는 1:1 코드 치환이 아닐 수 있습니다. |
| Web service worker / slidedown prompt | Notifly web service worker + browser permission UX | service worker path/scope와 HTTPS origin을 검증합니다. |
| OneSignal Journeys/Segments/Templates/Email/SMS/Live Activities | 제품·캠페인 재설계 필요 | SDK callsite만으로 이전되지 않습니다. |

## 6단계: 구현 전략

### complete mode

1. 선택된 platform reference를 읽고 Notifly SDK를 추가합니다.
2. OneSignal 코드에서 추출한 목표 event/property catalog를 Notifly naming/type 기준으로 정리합니다.
   pre-integration MCP catalog가 비어 있더라도 이 단계는 진행합니다.
3. Notifly 초기화/유저/속성/이벤트/푸시 클릭/인앱 경로를 구현합니다.
4. Notifly 콘솔/MCP로 이벤트·유저 속성·채널 상태가 들어오는지 검증합니다.
5. 검증 후 OneSignal callsite를 제거합니다.
6. 마지막에 OneSignal dependency/resource/manifest/service/extension/service worker/import/config를 제거합니다.
7. 정적 검색으로 OneSignal 흔적이 의도한 문서/마이그레이션 노트 외에 남지 않았는지 확인합니다.

### coexist mode

1. 기존 OneSignal 코드는 유지합니다.
2. 작은 adapter/service를 만들어 유저 식별·유저 속성·이벤트를 OneSignal과 Notifly에 동시에 기록합니다.
3. pre-integration MCP의 `list_project_events`/`list_user_properties`가 비어 있으면 정상으로 보고,
   OneSignal callsite에서 dual-write 대상 catalog를 먼저 만든 뒤 릴리즈 후 재조회합니다.
4. 푸시/인앱은 중복 발송 위험이 있으므로, Notifly 캠페인은 초안 또는 제한된 내부 세그먼트로 시작합니다.
5. 공존 기간 동안 parity 로그/콘솔 지표/MCP 조회로 이벤트 수집과 유저 상태를 비교합니다.
6. 제거 작업은 별도 `complete` 단계로 분리합니다.

예시 adapter:

- `examples/flutter_dual_write_adapter.dart`
- `examples/ios_swift_dual_write_adapter.swift`
- `examples/android_kotlin_dual_write_adapter.kt`
- `examples/react_native_dual_write_adapter.ts`
- `examples/expo_config_notes.md`
- `examples/web_dual_write_adapter.ts`

## 7단계: 검증

공통 정적 검증:

- complete mode: OneSignal package/import/resource/service worker/service/extension/initialization/callsite가 남아 있는지 검색합니다.
- coexist mode: OneSignal 제거가 일어나지 않았고 Notifly dual-write call이 추가됐는지 확인합니다.
- `setUserId → setUserProperties → trackEvent` 순서가 로그인 직후 경로에서 유지되는지 확인합니다.
- `segmentationEventParamKeys`는 최대 1개만 지정합니다.
- OneSignal tag string 값을 Notifly bool/number/string으로 바꾼 경우 변환 규칙을 테스트합니다.

플랫폼별 최소 검증:

| Platform | 최소 명령/검증 |
| --- | --- |
| iOS Swift | Xcode build 또는 `xcodebuild` 가능 시 실행, APNs delegate forwarding, Notification Service Extension/App Groups 확인 |
| Android Kotlin | Gradle assemble/test 가능 시 실행, manifest merge/Application 초기화/FCM service 충돌 확인 |
| Flutter | `flutter pub get`, `flutter analyze`, 가능 시 `flutter test`, `flutter build apk --debug` |
| React Native | package install, `pod install`, TypeScript/lint/test 가능 시 실행, iOS/Android native bridge 설정 확인 |
| Expo | Expo Go 의존 여부 확인, prebuild/dev-client/EAS 경로 확인, generated native project diff 검토 |
| Web | package install/build, service worker가 public root로 배포되는지 확인, HTTPS/browser push permission 확인 |

운영 검증:

- 앱/웹 시작 후 Notifly 초기화 로그 확인
- 로그인/로그아웃 시 `setUserId` 반영 확인
- 대표 tag/property 1~2개 `setUserProperties` 후 콘솔/MCP에서 확인
- 대표 이벤트 1~2개 `trackEvent` 후 콘솔/MCP에서 확인
- push click custom data/deeplink가 앱 router로 전달되는지 확인
- iOS rich push가 필요하면 Notification Service Extension/App Groups 설정 확인
- Web push가 필요하면 service worker path와 browser permission/subscription upload 확인
- MCP로 `identify_user`, `list_user_events`, `list_user_channels`를 조회해 수집 상태 확인

## 8단계: 보고 형식

최종 보고에는 아래를 포함합니다.

- 선택된 migration mode와 이유
- 감지된 platform track과 사용한 reference 파일
- 확인한 OneSignal SDK 구조: v5 user model인지, 구형 API인지, web service worker/native extension 유무
- 변경 파일 목록
- OneSignal 기능별 대응 상태: migrated / coexist / intentionally unchanged / unsupported-needs-design / not used
- MCP로 확인한 Notifly project/channel/event/property 정보 요약
  - 단, SDK 연동 전 `event/property` catalog가 비어 있거나 제한적이면 이를 정상적인 한계로 표시하고,
    OneSignal 코드에서 도출한 목표 catalog와 연동 후 재검증 계획을 별도로 적습니다.
- 실행한 검증 명령과 결과
- 남은 수동 작업: 콘솔 캠페인 활성화, OneSignal 캠페인/Journey stop, 다음 릴리즈 제거 작업 등

## 참고 자료

- `references/onesignal-sdk-structure.md`
- `references/migration-core.md`
- `references/feature-parity.md`
- `references/platforms/ios-swift.md`
- `references/platforms/android-kotlin.md`
- `references/platforms/flutter.md`
- `references/platforms/react-native.md`
- `references/platforms/expo.md`
- `references/platforms/web.md`

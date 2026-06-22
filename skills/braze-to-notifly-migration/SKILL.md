---
name: braze-to-notifly-migration
display-name: Braze to Notifly Migration
short-description: Migrate Flutter Braze integrations to Notifly with Remote MCP
description:
  Flutter 앱의 Braze SDK 연동을 Notifly Flutter SDK와 Notifly Remote MCP 기반
  운영 흐름으로 이전합니다. Braze 완전 제거(churn)와 일정 기간 공존(dual-write)을
  사용자가 선택하게 한 뒤, SDK 코드·푸시 클릭·인앱·이벤트·유저 속성·캠페인 초안을
  안전하게 마이그레이션합니다.
user-invocable: true
---

# Braze → Notifly Migration Skill

사용자가 **Braze에서 Notifly로 이전**, **Braze churn**, **Braze/Notifly 공존**,
**Flutter 앱 CRM SDK 교체**를 요청할 때 이 스킬을 사용하세요.

기본 대상은 Flutter 앱입니다. React Native/iOS/Android 단독 앱이면 이 스킬의 원칙을
따르되, 플랫폼별 실제 SDK API는 Notifly 공식 문서/MCP로 다시 확인하세요.

## 핵심 원칙

1. **먼저 묻기:** 코드 수정 전에 사용자가 원하는 migration mode를 확인합니다.
   - `complete`: Braze를 완전히 제거하고 Notifly로 대체합니다.
   - `coexist`: 일정 기간 Braze와 Notifly를 공존시키고, 나중에 Braze를 제거합니다.
2. **Remote MCP 우선:** Notifly 설정/프로젝트/캠페인/문서 정보는 Remote MCP에서
   확인합니다. 로컬 `npx notifly-mcp-server`를 기본으로 깔지 마세요.
3. **Pre-SDK catalog 한계 인지:** Notifly SDK가 아직 연동되지 않은 프로젝트에서는 MCP가
   제공하는 `user_properties`/`events` 카탈로그가 비어 있거나 제한적일 수 있습니다. 이를
   "이벤트가 없다"로 해석하지 말고, Braze 코드 인벤토리와 제품 요구사항에서 목표 taxonomy를
   먼저 만들고 SDK 연동 후 MCP/콘솔로 수집 여부를 검증합니다.
4. **기능 동등성 분리:** Braze의 모든 기능이 Notifly SDK 1개 API로 1:1 대응하지
   않습니다. 이벤트/유저/푸시는 코드로 이전 가능하지만, Content Cards/Feature Flags는
   제품·캠페인 설계 결정이 필요합니다.
5. **초안만 생성:** MCP 쓰기 도구는 캠페인/유저 여정 초안 생성·수정까지만 사용합니다.
   활성화, 발송, 삭제를 자동 수행하지 마세요.
6. **검증 전 제거 금지:** complete mode라도 빌드/정적 검색/런타임 검증 전에는 Braze
   의존성과 설정을 제거하지 않습니다.

## 0단계: migration mode 확인(필수)

코드 변경 전에 아래 질문을 사용자에게 하세요. 이미 답이 명확히 제공된 경우에만 생략합니다.

```text
Braze → Notifly 이전 방식을 먼저 정해야 합니다.
1) complete: 이번 작업에서 Braze SDK/config/import/callsite를 제거하고 Notifly로 완전 대체
2) coexist: 일정 기간 Braze와 Notifly를 dual-write/공존시키고, 검증 후 별도 작업에서 Braze 제거
어느 방식으로 진행할까요? 공존이면 기간/릴리즈 기준도 알려주세요.
```

- `complete` 선택 전 확인할 것: Braze 캠페인/푸시/인앱/Content Cards/Feature Flags가
  실제로 어떤 제품 동작을 담당하는지.
- `coexist` 선택 전 확인할 것: dual-write 범위(이벤트/유저 속성/푸시 클릭), 중복 메시지
  방지 정책, 공존 종료 기준.

## 1단계: 현재 Braze 연동 인벤토리

프로젝트 루트에서 다음을 확인합니다.

### Flutter/Dart

- `pubspec.yaml`: `braze_plugin`, `notifly_flutter` 존재 여부
- `lib/**/*.dart`:
  - `import 'package:braze_plugin/braze_plugin.dart'`
  - `BrazePlugin()`
  - `changeUser(...)`
  - `logCustomEvent(...)`
  - `logPurchase(...)`
  - `setCustomUserAttribute*`, `unsetCustomUserAttribute(...)`
  - `setPushNotificationSubscriptionType(...)`
  - `subscribeToPushNotificationEvents(...)`
  - `subscribeToInAppMessages(...)`
  - `subscribeToContentCards(...)`, `getCachedContentCards(...)`, `requestContentCardsRefresh(...)`
  - `subscribeToFeatureFlags(...)`, `getFeatureFlagByID(...)`, `getAllFeatureFlags(...)`

### Android

- `android/**/AndroidManifest.xml`:
  - `com.braze.push.BrazeFirebaseMessagingService`
  - `com.google.firebase.MESSAGING_EVENT`
  - custom scheme/app links used by Braze push deep links
- `android/**/res/values/*.xml`:
  - `com_braze_api_key`
  - `com_braze_custom_endpoint` or server target
  - `com_braze_firebase_cloud_messaging_registration_enabled`
  - `com_braze_firebase_cloud_messaging_sender_id`
  - `com_braze_handle_push_deep_links_automatically`
- native Kotlin/Java code: custom Firebase Messaging service or push/deeplink handling

### iOS

- `ios/**/AppDelegate.swift` / `AppDelegate.mm`:
  - `BrazeKit`, `braze_plugin`, `BrazePlugin.initBraze`, `BrazePlugin.configure`
  - push automation, app group, deep link forwarding
- `ios/**/Podfile`, `Podfile.lock`, SPM package refs for Braze
- Notification Service Extension/App Groups used by rich push

인벤토리 결과를 기능별로 나눠 기록합니다: **초기화, 유저 식별, 유저 속성, 이벤트,
푸시 토큰/클릭, 인앱, Content Cards, Feature Flags, Attribution 연동, 분석/실험 연동**.

## 2단계: Notifly Remote MCP 연결 확인

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
`references/remote-mcp.md`를 보세요.

## 3단계: MCP로 필요한 Notifly 정보 수집

코드 변경 또는 캠페인 초안 생성 전에 Remote MCP에서 다음을 확인합니다.

1. 접근 가능한 제품/프로젝트:
   - `list_products`
   - `list_projects`
   - 필요 시 `get_project`, `get_product`
2. 프로젝트 SDK/캠페인 설계에 필요한 카탈로그:
   - `list_project_events`
   - `list_user_properties`
   - `list_project_channels`
3. **중요:** SDK 연동 전이거나 아직 해당 앱에서 Notifly 이벤트를 보내지 않았다면
   `list_project_events`/`list_user_properties` 결과가 비어 있거나 일부 서버/API 이벤트만
   보일 수 있습니다. 이 상태는 정상적인 pre-integration 상태일 수 있으므로, migration을
   막는 blocker로 보지 않습니다. 대신 Braze 코드 인벤토리에서 목표 event/property catalog를
   만들고, SDK 적용 후 같은 MCP 도구로 수집 여부를 재검증합니다.
4. 기존 캠페인/성과/유저 상태 확인:
   - `list_campaigns`, `get_campaign`, `get_campaign_statistics`
   - `identify_user`, `list_user_channels`, `list_user_events`
   - `get_campaign_user_eligibility`, `list_campaign_user_deliveries`
5. 공식 문서 확인:
   - `search_notifly_docs`
   - `query_docs_filesystem_notifly_docs`

캠페인 초안을 만들거나 바꿀 때는 반드시 먼저 `describe_campaign_payload`를 호출해
해당 channel/type/timing/segment 조합의 `full_example_payload`를 확인한 뒤
`create_campaign` 또는 `replace_campaign`을 사용합니다.

## 4단계: SDK 코드 매핑

자세한 매핑은 `references/flutter-migration-mapping.md`를 보세요. 핵심 대응은 다음입니다.

| Braze Flutter | Notifly Flutter | 메모 |
| --- | --- | --- |
| `flutter pub add braze_plugin` | `flutter pub add notifly_flutter` | iOS는 `pod install` 필요 |
| Android `com_braze_*` resource | `NotiflyPlugin.initialize(...)` + native push 설정 | Braze resource 제거는 complete mode에서만 |
| iOS `BrazePlugin.initBraze/configure` | Flutter `NotiflyPlugin.initialize(...)` + iOS AppDelegate 콜백 전달 | Notifly iOS push callback 연결 필요 |
| `changeUser(userId)` | `NotiflyPlugin.setUserId(userId)` | 로그아웃은 `setUserId(null)` |
| `setCustomUserAttribute*` | `NotiflyPlugin.setUserProperties({...})` | 여러 Braze attribute call을 한 map으로 합침 |
| `logCustomEvent(name, properties)` | `NotiflyPlugin.trackEvent(eventName: name, eventParams: properties)` | `segmentationEventParamKeys`는 최대 1개 |
| push click stream | `NotiflyPlugin.addNotificationClickListener(...)` | deeplink payload key를 실제 Notifly campaign custom data에 맞춤 |
| in-app message handlers | Notifly in-app popup + `NotiflyPlugin.inAppEvents.listen(...)` | UI/이벤트명은 캠페인 설계와 같이 검증 |
| Content Cards | 직접 1:1 없음 | Notifly 캠페인/인앱/콘텐츠 surface로 재설계 필요 |
| Feature Flags | 직접 1:1 없음 | 기존 FF 시스템 유지 또는 별도 전환 설계 필요 |

## 5단계: 구현 전략

### complete mode

1. Notifly SDK를 추가하고 초기화/유저/이벤트/푸시 클릭 경로를 구현합니다.
2. Braze 코드에서 추출한 목표 event/property catalog를 Notifly naming/type 기준으로 정리합니다.
   pre-integration MCP catalog가 비어 있더라도 이 단계는 진행합니다.
3. Notifly 콘솔/MCP로 이벤트·유저 속성·채널 상태가 들어오는지 검증합니다.
4. 검증 후 Braze callsite를 제거합니다.
5. 마지막에 Braze dependency/resource/manifest/service/iOS imports/config를 제거합니다.
6. 정적 검색으로 Braze 흔적이 의도한 문서/마이그레이션 노트 외에 남지 않았는지 확인합니다.

### coexist mode

1. 기존 Braze 코드는 유지합니다.
2. 작은 adapter/service를 만들어 이벤트·유저 식별·유저 속성을 Braze와 Notifly에
   동시에 기록합니다.
3. pre-integration MCP의 `list_project_events`/`list_user_properties`가 비어 있으면 정상으로
   보고, Braze callsite에서 dual-write 대상 catalog를 먼저 만든 뒤 릴리즈 후 재조회합니다.
4. 푸시/인앱은 중복 발송 위험이 있으므로, Notifly 캠페인은 초안 또는 제한된 내부 세그먼트로
   시작합니다.
5. 공존 기간 동안 parity 로그/콘솔 지표/MCP 조회로 이벤트 수집과 유저 상태를 비교합니다.
6. 제거 작업은 별도 `complete` 단계로 분리합니다.

예시 adapter는 `examples/flutter_dual_write_adapter.dart`를 참고하세요.

## 6단계: 검증

최소 검증:

```bash
flutter pub get
flutter analyze
```

가능하면 플랫폼별 빌드도 수행합니다.

```bash
flutter test
flutter build apk --debug
# macOS/iOS 환경이면
cd ios && pod install
flutter build ios --debug --no-codesign
```

정적 검증:

- complete mode: `braze_plugin`, `BrazePlugin`, `com_braze_`, `com.braze`, `BrazeFirebaseMessagingService`가
  남아 있는지 검색합니다.
- coexist mode: Braze 제거가 일어나지 않았고 Notifly dual-write call이 추가됐는지 확인합니다.
- 두 mode 모두 `notifly_flutter`, `NotiflyPlugin.initialize`, `setUserId`, `setUserProperties`,
  `trackEvent` 사용 위치를 확인합니다.

런타임/운영 검증:

- 앱 시작 후 Notifly 초기화 로그 확인
- 로그인/로그아웃 시 `setUserId` 반영 확인
- 대표 이벤트 1~2개 `trackEvent` 후 콘솔/MCP에서 확인
- Android push click listener가 custom data/deeplink를 앱 router로 넘기는지 확인
- iOS rich push가 필요하면 Notification Service Extension/App Groups 설정 확인
- MCP로 `identify_user`, `list_user_events`, `list_user_channels`를 조회해 수집 상태 확인

## 7단계: 보고 형식

최종 보고에는 아래를 포함합니다.

- 선택된 migration mode와 이유
- 변경 파일 목록
- Braze 기능별 대응 상태: migrated / coexist / intentionally unchanged / unsupported-needs-design
- MCP로 확인한 Notifly project/channel/event/property 정보 요약
  - 단, SDK 연동 전 `event/property` catalog가 비어 있거나 제한적이면 이를 정상적인 한계로
    표시하고, Braze 코드에서 도출한 목표 catalog와 연동 후 재검증 계획을 별도로 적습니다.
- 실행한 검증 명령과 결과
- 남은 수동 작업: 콘솔 캠페인 활성화, Braze 캠페인 stop, 다음 릴리즈 제거 작업 등

## 참고 자료

- `references/flutter-migration-mapping.md`
- `references/remote-mcp.md`
- `examples/flutter_dual_write_adapter.dart`

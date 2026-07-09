# Migration Core

이 문서는 모든 플랫폼에서 공통으로 적용되는 OneSignal → Notifly migration 절차입니다.
플랫폼별 API surface는 `references/platforms/*.md`에서 확인합니다.

## 1. Inventory table

| 영역 | OneSignal에서 찾을 것 | Notifly에서 설계/검증할 것 |
| --- | --- | --- |
| Init/config | App ID, log level, privacy consent, APNs/FCM credential 의존성, native extension/service worker path | projectId, username, SDK init 위치, log level, placeholder password 정책, Notifly channel 설정 |
| Identity | `login(external_id)`, `logout`, 구형 `setExternalUserId`, `removeExternalUserId`, aliases, `onesignal_id`, `subscription_id`/`player_id` 조회 | `setUserId`, 로그아웃 null/nil/undefined 처리, provider ID를 고객 ID로 쓰지 않는 정책 |
| User properties | Tags, `addTag(s)`, `removeTag(s)`, 구형 `sendTag(s)`, tag value string formatting, tag quota | `setUserProperties`, `$email`, `$phone_number`, `$line_user_id`, boolean/list/number 타입 유지 또는 변환 |
| Events | `OneSignal.User.trackEvent`, Custom Events API, outcomes, tags-as-behavior | `trackEvent`, event name 유지, params 타입 유지, segmentation key 최대 1개 |
| Push | permission prompt, subscription opt-in/out, click listener, foreground listener, APNs/FCM delegate/service, iOS NSE/App Group, Android notification icons | Notifly push setup, click listener/callback, custom data routing, rich push extension |
| In-app | `OneSignal.InAppMessages` triggers, paused state, click/lifecycle listeners, dashboard in-app campaigns | Notifly in-app popup listener/events, trigger semantics 재설계, foreground-only 제약 확인 |
| Web | `OneSignalDeferred`, `OneSignalSDK.page.js`, `OneSignalSDKWorker.js`, `serviceWorkerPath`, `serviceWorkerParam.scope`, slidedown/category prompts, auto-resubscribe | Notifly JS SDK, Notifly service worker path/scope, HTTPS/browser permission, subscription upload |
| Dashboard/Journeys | Segments, Journeys, templates, dashboard permission prompts, message click URLs, webhooks/export | SDK 외 제품·캠페인 설계, Remote MCP draft, activation/send/delete 수동 검토 |
| Non-push channels | Email/SMS/RCS, Live Activities, confirmed delivery reporting, location module | 직접 1:1 SDK 치환 없음. Notifly 지원 범위와 제품 요구사항 재확인 |

## 2. Target event/property catalog

SDK 연동 전에는 Notifly MCP의 `list_project_events`와 `list_user_properties`가 비어 있을 수 있습니다.
따라서 catalog는 아래 순서로 만듭니다.

1. OneSignal callsite에서 현재 event/property/tag 목록을 추출합니다.
2. OneSignal Tags 중 long-lived user 상태와 behavior marker를 분리합니다.
3. 제품/마케팅 관점에서 계속 필요한 항목만 남깁니다.
4. Notifly 예약 키와 타입 규칙에 맞춥니다.
5. 세그먼트에서 event param을 쓸 경우 `segmentationEventParamKeys`는 최대 1개만 고릅니다.
6. SDK 배포 후 MCP/콘솔에서 실제 수집 여부를 재검증합니다.

권장 표:

| Source | OneSignal name | Notifly name | Type | Required for segment/campaign | Notes |
| --- | --- | --- | --- | --- | --- |
| identity | `external_id` from `login()` | `setUserId` value | string | yes | `onesignal_id`/`subscription_id` 아님 |
| user_property | tag `subscription_tier` | `subscription_tier` | string | yes | tag value string 유지 |
| user_property | tag `push_opt_in_source` | `push_opt_in_source` | string | no | web slidedown/category prompt에서 온 값 |
| user_property | tag `is_premium`=`"1"` | `is_premium` | boolean or string | yes | 변환 규칙 명시 |
| event | `purchase` via `User.trackEvent` | `purchase` | event | yes | event name 유지 |
| event_param | `purchase.price` | `price` | number | no | 필요 시 segmentation key 후보 |
| behavior tag | tag `last_cart_update` timestamp | `cart_updated` or `last_cart_update` | event or property | depends | 행동이면 event로 재모델링 권장 |

## 3. OneSignal ID mapping rule

OneSignal user model은 user-level `onesignal_id`와 device/browser-level `subscription_id`를 자동 생성합니다.
이 값들은 운영 검증과 support lookup에는 유용하지만, Notifly의 고객 user ID로 승격하지 않습니다.

- `login(external_id)` 또는 구형 `setExternalUserId`의 인자가 고객 stable ID이면 `Notifly.setUserId`로 이전합니다.
- `OneSignal.User.addAlias`는 `external_id`가 설정된 뒤에 의미가 있습니다. alias를 Notifly로 옮길 때는 보통 user property로 보존하거나 서버 매핑 테이블에 유지합니다.
- OneSignal `logout()`은 current subscription을 익명 user로 전환합니다. Notifly에서는 플랫폼별 `setUserId(null/nil/undefined)` logout semantics를 확인합니다.

## 4. OneSignal Tags conversion rule

OneSignal Tags는 string-only key/value입니다. Notifly user properties는 타입을 보존할 수 있으므로 변환이 필요합니다.

- `"1"`/`"0"`, `"true"`/`"false"`는 boolean으로 바꿀지 string으로 보존할지 segment/campaign 요구사항 기준으로 결정합니다.
- Unix timestamp string은 timestamp string으로 유지할지 number로 바꿀지 결정합니다.
- 배열/객체는 OneSignal tag로 직접 지원되지 않습니다. 코드에서 JSON string을 tag로 쓰고 있다면 Notifly property로 그대로 넣지 말고 schema를 다시 설계합니다.
- 행동성 tag(`last_purchase`, `cart_update`, `level_reached`)는 Notifly `trackEvent`가 더 자연스러운지 검토합니다.

## 5. Complete vs coexist decision

### complete

사용 조건:

- OneSignal 캠페인/Journey stop 일정이 명확함
- 이벤트·유저 속성·푸시 클릭의 Notifly 수집 검증이 가능함
- OneSignal Dashboard prompts/Journeys/Email/SMS/Live Activities 대체 설계가 완료됨

작업 순서:

1. Notifly SDK 추가
2. dual path 없이 Notifly callsite 구현
3. 이벤트/유저/푸시 클릭 검증
4. OneSignal callsite 제거
5. OneSignal dependency/config/native resource/service worker/extension 제거
6. 정적 검색과 빌드 검증

### coexist

사용 조건:

- 운영 리스크를 줄이기 위해 OneSignal과 Notifly를 일정 기간 비교해야 함
- OneSignal 캠페인을 바로 중단할 수 없음
- Notifly catalog가 아직 비어 있어 SDK 배포 후 검증이 필요함

작업 순서:

1. OneSignal callsite는 유지
2. adapter/service에서 user/event/property를 dual-write
3. push/in-app 캠페인은 중복 발송을 피하기 위해 Notifly는 draft/internal segment부터 시작
4. event count/user profile/channel state를 비교
5. 별도 complete 작업에서 OneSignal 제거

## 6. Reporting classification

각 OneSignal 기능은 아래 상태 중 하나로 보고합니다.

- `migrated`: Notifly SDK/MCP 흐름으로 대체됨
- `coexist`: dual-write 또는 병행 운영 중
- `intentionally unchanged`: 현재 유지하기로 결정됨
- `unsupported-needs-design`: 직접 1:1 치환이 없어서 제품/캠페인 설계 필요
- `not used`: 코드/설정에서 사용 흔적 없음

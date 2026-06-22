# Migration Core

이 문서는 모든 플랫폼에서 공통으로 적용되는 Braze → Notifly migration 절차입니다.
플랫폼별 API surface는 `references/platforms/*.md`에서 확인합니다.

## 1. Inventory table

| 영역 | Braze에서 찾을 것 | Notifly에서 설계/검증할 것 |
| --- | --- | --- |
| Init/config | API key, endpoint, data center, debug log, automatic request policy | projectId, username, SDK init 위치, log level, placeholder password 정책 |
| Identity | `changeUser`, anonymous → known user transition, logout handling | `setUserId`, logout null/nil/undefined 처리, 기존 user 데이터 보존 정책 |
| User properties | custom attributes, reserved fields, subscription state | `setUserProperties`, `$email`, `$phone_number`, `$line_user_id`, boolean/list/number 타입 유지 |
| Events | `logCustomEvent`, purchase/revenue, event properties | `trackEvent`, event name 유지, params 타입 유지, segmentation key 최대 1개 |
| Push | APNs/FCM, notification service, click/deeplink, campaign payload keys | Notifly push setup, click listener/callback, custom data routing, rich push extension |
| In-app | listener, display policy, button callbacks, event names | Notifly in-app popup listener/events, foreground-only 제약 확인 |
| Content Cards | card feed, cached cards, refresh, custom card UI | 1:1 SDK 치환 없음. 인앱/캠페인/콘텐츠 surface로 재설계 |
| Feature Flags | flag read/listen, variant/payload | 1:1 SDK 치환 없음. 기존 FF 유지 또는 별도 feature flag system 설계 |
| Attribution | Airbridge/Appsflyer/Amplitude 등 SDK forwarding | `$airbridge_device_id`, `$appsflyer_id` 등 필요한 user property/event forwarding |

## 2. Target event/property catalog

SDK 연동 전에는 Notifly MCP의 `list_project_events`와 `list_user_properties`가 비어 있을 수 있습니다.
따라서 catalog는 아래 순서로 만듭니다.

1. Braze callsite에서 현재 event/property 목록을 추출합니다.
2. 제품/마케팅 관점에서 계속 필요한 항목만 남깁니다.
3. Notifly 예약 키와 타입 규칙에 맞춥니다.
4. 세그먼트에서 event param을 쓸 경우 `segmentationEventParamKeys`는 최대 1개만 고릅니다.
5. SDK 배포 후 MCP/콘솔에서 실제 수집 여부를 재검증합니다.

권장 표:

| Source | Braze name | Notifly name | Type | Required for segment/campaign | Notes |
| --- | --- | --- | --- | --- | --- |
| user_property | `membership_tier` | `membership_tier` | string | yes | 타입 유지 |
| user_property | `phone` | `$phone_number` | string | yes | 예약 키로 이동 |
| event | `purchase_completed` | `purchase_completed` | event | yes | event name 유지 |
| event_param | `purchase_completed.price` | `price` | number | no | 필요 시 segmentation key 후보 |

## 3. Complete vs coexist decision

### complete

사용 조건:

- Braze 캠페인/Canvas stop 일정이 명확함
- 이벤트·유저 속성·푸시 클릭의 Notifly 수집 검증이 가능함
- Content Cards/Feature Flags 대체 설계가 완료됨

작업 순서:

1. Notifly SDK 추가
2. dual path 없이 Notifly callsite 구현
3. 이벤트/유저/푸시 클릭 검증
4. Braze callsite 제거
5. Braze dependency/config/native resource 제거
6. 정적 검색과 빌드 검증

### coexist

사용 조건:

- 운영 리스크를 줄이기 위해 Braze와 Notifly를 일정 기간 비교해야 함
- Braze 캠페인을 바로 중단할 수 없음
- Notifly catalog가 아직 비어 있어 SDK 배포 후 검증이 필요함

작업 순서:

1. Braze callsite는 유지
2. adapter/service에서 user/event/property를 dual-write
3. push/in-app 캠페인은 중복 발송을 피하기 위해 Notifly는 draft/internal segment부터 시작
4. event count/user profile/channel state를 비교
5. 별도 complete 작업에서 Braze 제거

## 4. Reporting classification

각 Braze 기능은 아래 상태 중 하나로 보고합니다.

- `migrated`: Notifly SDK/MCP 흐름으로 대체됨
- `coexist`: dual-write 또는 병행 운영 중
- `intentionally unchanged`: 현재 유지하기로 결정됨
- `unsupported-needs-design`: 직접 1:1 치환이 없어서 제품/캠페인 설계 필요
- `not used`: 코드/설정에서 사용 흔적 없음

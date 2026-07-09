# Feature Parity Notes

OneSignal과 Notifly는 공통으로 유저/이벤트/푸시/인앱 영역을 다루지만, 모든 기능이 SDK API 1개로 1:1 대응하지는 않습니다.

## Direct SDK migration

| OneSignal | Notifly | Migration note |
| --- | --- | --- |
| `login(external_id)` / `setExternalUserId` | `setUserId` | 고객 stable ID만 이전. `onesignal_id`/`subscription_id`는 운영 조회용 |
| `logout()` / `removeExternalUserId` | `setUserId(null/nil/undefined)` | 로그아웃 후 익명 device/user 정책 검증 |
| Tags / `addTag(s)` | `setUserProperties` | string-only tag를 Notifly property 타입으로 변환 또는 보존 |
| Custom Events / `User.trackEvent` | `trackEvent` | event name 유지 우선, segmentationEventParamKeys 최대 1개 |
| Push click listener | notification click listener/callback | launch URL/additional data/custom data routing 설계 필요 |
| Foreground notification listener | Notifly foreground/display policy | OS별 자동 표시/수동 표시 차이 검증 |
| In-app click/lifecycle listener | in-app popup listener/events | action ID/deeplink payload mapping 필요 |

## Needs product/campaign design

### Journeys and Segments

OneSignal Journeys와 Segments는 앱 SDK callsite만으로 이전되지 않습니다. Notifly campaign/user journey 초안을 만들 수 있더라도,
발송 활성화와 운영 전환은 수동 검토 대상입니다.

Agent rule:

- 캠페인/저니 payload 작성 전 `describe_campaign_payload`를 호출합니다.
- `create_campaign`/`replace_campaign`은 draft-only로 사용합니다.
- activation/send/delete는 자동 수행하지 않습니다.

### Dashboard permission prompts and web slidedown

OneSignal Web slidedown/category prompts는 dashboard 설정과 SDK init options가 함께 동작합니다. Notifly로 옮길 때는 다음을 분리합니다.

- browser native permission request timing
- category/preferences UI
- category tag 저장 방식
- service worker scope/path
- welcome notification 여부

### In-app triggers

OneSignal `InAppMessages.addTrigger(s)`는 dashboard in-app message eligibility와 결합됩니다. Notifly에서는 campaign trigger/segment/event 조건으로 재설계해야 할 수 있습니다.
단순히 SDK trigger call을 같은 이름의 event로 바꾸기 전에 캠페인 조건을 확인합니다.

### Email/SMS/RCS

OneSignal Email/SMS/RCS는 SDK migration 범위를 벗어날 수 있습니다. Notifly에서 지원하는 channel과 고객의 운영 요구사항을 확인하고,
서버 API/캠페인/동의 관리 설계를 별도 작업으로 분리합니다.

### Live Activities and confirmed delivery

OneSignal Live Activities, confirmed receipt, dashboard delivery reports는 Notifly SDK callsite로 직접 대체되지 않습니다.
운영 지표와 사용자-facing 기능을 분리해 설계합니다.

### Aliases

OneSignal aliases는 `external_id`가 설정된 뒤 의미가 있습니다. Notifly SDK로 옮길 때는 보통 다음 중 하나를 택합니다.

- 고객 primary ID는 `setUserId`로만 유지
- 보조 ID는 `setUserProperties`로 보존
- 민감하거나 내부 매핑용 ID는 서버 DB에만 유지

### Outcomes

구형 OneSignal outcome API를 쓰는 경우, 해당 값이 캠페인 attribution metric인지 실제 제품 event인지 구분합니다.
제품 event이면 `trackEvent` 후보이고, campaign attribution 전용 metric이면 Notifly campaign analytics 설계와 함께 검토합니다.

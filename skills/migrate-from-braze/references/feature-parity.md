# Feature Parity Notes

Braze와 Notifly는 공통으로 유저/이벤트/푸시/인앱 영역을 다루지만, 모든 기능이 SDK API 1개로
1:1 대응하지는 않습니다.

## Direct SDK migration

| Braze | Notifly | Migration note |
| --- | --- | --- |
| user identity | `setUserId` | 로그인/로그아웃 경로 검증 |
| custom attributes | `setUserProperties` | 예약 키와 타입 유지 |
| custom events | `trackEvent` | event name 유지 우선 |
| push click | notification click listener/callback | custom data key 설계 필요 |
| in-app callbacks | in-app message event listener | 이벤트명과 버튼 동작을 캠페인 설계와 함께 검증 |

## Needs product/campaign design

### Content Cards

Braze Content Cards는 SDK feed/cache/refresh/UI surface를 포함합니다. Notifly SDK에 직접적인
Content Cards 1:1 API가 없다면 다음 중 하나를 결정해야 합니다.

- Notifly in-app popup/campaign으로 재설계
- 앱 자체 콘텐츠 API/surface 유지
- 해당 기능을 migration scope 밖으로 분리

### Feature Flags

Braze Feature Flags는 feature rollout/variant/payload semantics를 가질 수 있습니다.
Notifly SDK의 이벤트/유저 속성 API로 단순 치환하지 마세요.

선택지:

- 기존 feature flag system 유지
- 별도 feature flag provider로 이전
- Notifly campaign/segment 기반으로 대체 가능한지 제품 설계 검토

### Canvas / Journey

Braze Canvas는 앱 SDK callsite만으로 이전되지 않습니다. Remote MCP로 Notifly campaign/user
journey 초안을 만들 수 있더라도, 발송 활성화와 운영 전환은 수동 검토 대상입니다.

Agent rule:

- 캠페인/저니 payload 작성 전 `describe_campaign_payload`를 호출합니다.
- `create_campaign`/`replace_campaign`은 draft-only로 사용합니다.
- activation/send/delete는 자동 수행하지 않습니다.

# Pre-SDK MCP Catalog Limits

Notifly Remote MCP의 `list_project_events`와 `list_user_properties`는 이미 Notifly로 수집된
카탈로그를 보여주는 도구입니다. 따라서 SDK 연동 전, 신규 앱, 또는 아직 해당 앱에서 Notifly
이벤트를 보내지 않은 프로젝트에서는 결과가 비어 있거나 제한적일 수 있습니다.

## Agent rule

빈 catalog를 아래처럼 해석하지 마세요.

- ❌ "이 앱에는 이벤트가 없다"
- ❌ "마이그레이션 대상 user property가 없다"
- ❌ "MCP가 비어 있으니 migration blocker다"

대신 이렇게 처리합니다.

- ✅ "Notifly pre-integration catalog가 아직 비어 있다"
- ✅ "Braze 코드와 제품 요구사항에서 목표 catalog를 도출한다"
- ✅ "SDK 배포 후 같은 MCP 도구로 수집 여부를 재검증한다"

## Workflow

1. Braze SDK callsite에서 `changeUser`, custom attributes, custom events, purchase/revenue,
   push click payload, in-app callbacks를 수집합니다.
2. 목표 Notifly catalog 표를 작성합니다.
3. `setUserId → setUserProperties → trackEvent` 호출 순서를 설계합니다.
4. SDK 적용 후 대표 user/event를 실제로 발생시킵니다.
5. MCP에서 `identify_user`, `list_user_events`, `list_user_channels`, `list_project_events`,
   `list_user_properties`를 다시 확인합니다.

## Report wording

보고할 때는 아래 표현을 사용합니다.

```text
MCP의 pre-SDK event/property catalog는 비어 있거나 제한적입니다. 이는 SDK 미연동 상태에서
정상적인 한계로 보이며, Braze 코드에서 도출한 목표 catalog를 기준으로 Notifly SDK 적용 후
MCP/콘솔에서 재검증해야 합니다.
```

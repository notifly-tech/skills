# Notifly Remote MCP reference

이 스킬에서 사용하는 Notifly MCP는 로컬 stdio 서버가 아니라 운영 Remote MCP입니다.

## Canonical endpoint

```text
https://api.notifly.tech/mcp
```

- Transport: Streamable HTTP
- Auth: OAuth / PKCE
- Token scopes: `mcp:read`, `mcp:tools`
- 권한 범위: 로그인한 Notifly 계정이 접근 가능한 제품/프로젝트
- 쓰기 동작: 캠페인/유저 여정 **초안 생성·수정**까지만. 운영 발송/활성화/삭제는 하지 않음.

## OAuth discovery / protected resource

Unauthenticated `POST /mcp`는 `401 Unauthorized`와 함께 다음 형태의 challenge를 반환해야 합니다.

```http
WWW-Authenticate: Bearer error="invalid_token",
  error_description="Missing Authorization header",
  resource_metadata="https://api.notifly.tech/.well-known/oauth-protected-resource/mcp"
```

Metadata endpoints:

```text
https://api.notifly.tech/.well-known/oauth-protected-resource/mcp
https://api.notifly.tech/.well-known/oauth-authorization-server/mcp
https://api.notifly.tech/.well-known/openid-configuration
```

현재 public metadata의 핵심 필드:

```json
{
  "resource": "https://api.notifly.tech/mcp",
  "authorization_servers": ["https://api.notifly.tech"],
  "bearer_methods_supported": ["header"],
  "resource_name": "Notifly MCP",
  "scopes_supported": ["mcp:read", "mcp:tools"]
}
```

Authorization server metadata 핵심 필드:

```json
{
  "issuer": "https://api.notifly.tech",
  "authorization_endpoint": "https://api.notifly.tech/oauth/authorize",
  "token_endpoint": "https://api.notifly.tech/oauth/token",
  "registration_endpoint": "https://api.notifly.tech/oauth/register",
  "revocation_endpoint": "https://api.notifly.tech/oauth/revoke",
  "response_types_supported": ["code"],
  "grant_types_supported": ["authorization_code", "refresh_token"],
  "token_endpoint_auth_methods_supported": ["none"],
  "code_challenge_methods_supported": ["S256"],
  "scopes_supported": ["mcp:read", "mcp:tools"]
}
```

## Client setup

### Claude Code

```bash
claude mcp add --transport http notifly https://api.notifly.tech/mcp
claude mcp list
claude mcp get notifly
```

인증 전에는 `Needs authentication`으로 보일 수 있습니다. Claude Code 세션에서 Notifly 도구가
필요한 질문을 하거나 MCP 인증을 시작하면 브라우저 OAuth 흐름으로 이어집니다.

`.mcp.json`을 직접 쓰는 경우:

```json
{
  "mcpServers": {
    "notifly": {
      "type": "http",
      "url": "https://api.notifly.tech/mcp"
    }
  }
}
```

### Codex

```bash
codex mcp add notifly --url https://api.notifly.tech/mcp
codex mcp login notifly --scopes mcp:read,mcp:tools
codex mcp get notifly
codex mcp list
```

최근 Codex는 `mcp add` 직후 OAuth flow를 바로 시작할 수 있습니다. `login`은 재인증/수동 인증
fallback으로 사용합니다. 정상 연결이면 `codex mcp list`에서 Auth가 OAuth로 보입니다.

## 현재 도구군

실제 도구 목록은 연결된 클라이언트에서 `tools/list`로 확인하세요. 아래는 현재 구현/문서 기준의
대표 도구입니다.

### 제품/프로젝트

- `list_products`
- `get_product`
- `list_projects`
- `get_project`
- `list_project_events`
- `list_user_properties`
- `list_project_channels`

### 캠페인

- `describe_campaign_payload` — `create_campaign`/`replace_campaign` 전에 필수로 호출
- `list_campaigns`
- `get_campaign`
- `get_campaign_statistics`
- `list_campaign_variants`
- `create_campaign` — 초안 생성
- `replace_campaign` — 기존 draft campaign full replacement
- `get_campaign_user_eligibility`
- `list_campaign_user_deliveries`

### 통계

- `get_statistics_summary`

### 유저

- `identify_user`
- `list_user_channels`
- `list_user_events`

### 유저 여정

- `list_user_journeys`
- `get_user_journey`
- `list_user_journey_statistics`
- `list_user_journey_user_sessions`
- `create_user_journey` — 비활성/초안 생성
- `replace_user_journey` — editable draft replacement

### 문서

- `search_notifly_docs`
- `query_docs_filesystem_notifly_docs`

## Migration 작업에서의 사용 순서

1. `list_products` / `list_projects`로 대상 프로젝트를 식별합니다.
2. `list_project_channels`로 app push/in-app/email/SMS/Kakao 등 활성 채널을 확인합니다.
3. `list_project_events` / `list_user_properties`로 Braze event/property mapping을 검증합니다.
4. Notifly SDK 연동 API는 `search_notifly_docs`와 `query_docs_filesystem_notifly_docs`로 공식 문서를 확인합니다.
5. 캠페인 이전이 필요하면 `list_campaigns`로 기존 Notifly 상태를 확인합니다.
6. 새 초안이 필요하면 `describe_campaign_payload` → `create_campaign` 순서로 진행합니다.
7. 특정 유저 검증은 `identify_user` → `list_user_events` / `list_user_channels` / `get_campaign_user_eligibility` 순서로 진행합니다.

## 주의사항

- OAuth token, bearer token, Notifly API token은 로그/PR/문서에 남기지 마세요.
- MCP token은 Authorization header에만 있어야 하며 tool JSON body에 넣지 않습니다.
- 쓰기 도구가 보이더라도 운영 발송을 의미하지 않습니다. draft/비활성 초안만 다룹니다.
- Claude UI가 “쓰기/삭제 도구”로 묶어 보여도 Notifly MCP는 삭제/발송을 수행하지 않습니다.
- 프로젝트가 보이지 않으면 코드 문제가 아니라 OAuth 로그인 계정의 제품/프로젝트 권한 문제일 수 있습니다.

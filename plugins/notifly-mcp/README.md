# Notifly MCP Plugin

노티플라이 **Remote MCP**(`https://api.notifly.tech/mcp`)를 Claude Code 등 MCP 클라이언트에 연결하는 플러그인입니다. 로컬 MCP 서버를 설치하지 않고, 원격 HTTP MCP 엔드포인트에 OAuth로 로그인해 노티플라이 도구를 사용합니다.

이 플러그인은 MCP 연결만 제공합니다. SDK 연동 스킬, slash command, agent는 포함하지 않습니다.

## 무엇을 할 수 있나요

로그인한 노티플라이 계정 권한 안에서 제품/프로젝트, 캠페인, 유저 여정, 유저 상태를 **조회**하고, 캠페인·유저 여정 **초안**을 생성/수정합니다.

| 범주 | 도구 예 | 하는 일 |
| --- | --- | --- |
| 제품/프로젝트 탐색 | `list_products`, `list_projects` | 접근 가능한 제품과 프로젝트를 찾습니다. |
| 프로젝트 카탈로그 | 이벤트·속성·채널 조회 도구 | 이벤트 이름, 유저 속성, 채널 설정을 확인합니다. |
| 캠페인 | 캠페인 조회·통계·초안 도구 | 목록/상세/성과 조회, 초안 캠페인 생성·수정. |
| 유저 진단 | `identify_user` 등 | 식별자, 채널 상태, 이벤트, 적격성, 발송 이력 점검. |
| 유저 여정 | 여정 조회·초안 도구 | 여정 목록/상세/성과 조회, 비활성 초안 생성·수정. |
| 문서 검색 | 공식 문서 검색 도구 | 노티플라이 공식 문서를 검색하고 페이지를 읽습니다. |

> **읽기와 초안까지만 지원합니다.** 운영 발송, 캠페인 활성화, 삭제는 하지 않습니다. `create_campaign`·`replace_campaign`은 캠페인 초안만 다루고, `create_user_journey`는 비활성 유저 여정 초안만 만듭니다.

## 설치

Claude Code 마켓플레이스에서 이 저장소를 추가한 뒤 `notifly-mcp` 플러그인을 설치합니다.

```bash
claude plugin marketplace add notifly-tech/skills
claude plugin install notifly-mcp@notifly-agent-skills
```

플러그인이 활성화되면 `notifly` MCP 서버가 등록됩니다. Claude Code 세션에서 `Pending approval`로 보일 수 있으니 승인 후 사용합니다.

## OAuth 인증

노티플라이 Remote MCP는 OAuth discovery와 동적 클라이언트 등록(PKCE)을 지원하므로 클라이언트 ID/시크릿을 입력할 필요가 없습니다.

1. 노티플라이 도구가 필요한 요청을 하면 클라이언트가 MCP 인증을 시작합니다.
2. 브라우저에서 노티플라이 로그인 화면이 열립니다.
3. 노티플라이 계정으로 로그인하면 클라이언트가 발급된 토큰으로 `/mcp`를 호출합니다.

인증 후 접근 권한은 로그인한 계정이 가진 제품/프로젝트 범위를 그대로 따릅니다. 스코프는 `mcp:read`, `mcp:tools`입니다.

## 사용 예시

```text
내 노티플라이 프로젝트 목록을 보여줘.
```

```text
user@example.com 이 어제 캠페인 A를 받지 못한 이유를 확인해 줘.
```

```text
회원가입 후 3일이 지난 유저에게 보낼 앱 푸시 초안 캠페인을 만들어 줘. 아직 발송하지 마.
```

## 문제 해결

| 증상 | 확인할 점 |
| --- | --- |
| 로그인 창이 열리지 않음 | 클라이언트가 Remote MCP와 OAuth 로그인을 지원하는 버전인지 확인합니다. |
| 인증 오류가 계속 발생함 | 노티플라이 로그인을 다시 하거나 클라이언트의 Notifly 연결을 삭제한 뒤 재연결합니다. |
| 프로젝트가 보이지 않음 | 로그인한 계정이 해당 제품/프로젝트 권한을 갖는지 확인합니다. |

## 참고 문서

- [노티플라이 Remote MCP 서버](https://docs.notifly.tech/ko/devtools/notifly-remote-mcp)
- [Claude 노티플라이 커넥터 연결하기](https://docs.notifly.tech/ko/devtools/claude-notifly-connector)

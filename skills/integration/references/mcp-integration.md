# Notifly MCP 서버

Notifly MCP 서버는
[Model Context Protocol(MCP)](https://modelcontextprotocol.io/)을 구현하여,
LLM이 Notifly 문서와 SDK 코드를 검색할 수 있게 합니다.

## 연동 가이드

### 설치

일반적으로 전역 설치는 **필요하지 않습니다**. 권장 설정은 MCP 클라이언트
설정에서 `npx`로 서버를 실행하는 방식입니다.

선택적 전역 설치(클라이언트가 PATH에 있는 바이너리를 직접 요구하는 경우에만):

- **npm**:

```bash
npm i -g notifly-mcp-server@latest
```

- **yarn**:

```bash
yarn global add notifly-mcp-server@latest
```

### `.mcp.json` 설정

프로젝트 루트(또는 MCP 클라이언트가 사용하는 설정 위치)에 `.mcp.json`을
생성/수정하세요.

`npx`를 사용하는 권장 설정:

```json
{
  "mcpServers": {
    "notifly-mcp-server": {
      "command": "npx",
      "args": ["-y", "notifly-mcp-server@latest"]
    }
  }
}
```

### 중요: 서버 이름은 툴 네임스페이스에 영향을 줍니다

대부분의 MCP 클라이언트는 **서버 이름**을 prefix로 툴을 노출합니다. 예를 들어
서버 이름을 `notifly-mcp-server`로 지정하면 다음과 같은 툴이 생깁니다:

- `notifly-mcp-server:search_docs`
- `notifly-mcp-server:search_sdk`

서버 이름을 다른 것으로 지정하면(예: `notifly`) 툴이 `notifly:*`로 노출되며,
`notifly-mcp-server:*`를 기대하는 스킬은 서버가 없다고 판단할 수 있습니다.

### 주요 MCP 클라이언트/IDE에서 Notifly MCP 서버 사용

#### Android Studio

**옵션 1: Android Studio용 GitHub Copilot 플러그인**

1. Settings > Tools > GitHub Copilot > Model Context Protocol (MCP) > Configure.
2. `mcp.json` 수정:

```json
{
  "mcpServers": {
    "notifly-mcp-server": {
      "command": "npx",
      "args": ["-y", "notifly-mcp-server@latest"]
    }
  }
}
```

**옵션 2: JetBrains의 MCP Server 플러그인 사용**

1. JetBrains에서 "MCP Server" 플러그인을 설치합니다.
2. 클라이언트 설정:

```json
{
  "mcpServers": {
    "notifly-mcp-server": {
      "command": "npx",
      "args": ["-y", "notifly-mcp-server@latest"]
    },
    "jetbrains": { "command": "npx", "args": ["-y", "@jetbrains/mcp-proxy"] }
  }
}
```

**옵션 3: Android Studio의 Gemini**

1. [Gemini에 MCP 서버 추가하기](https://developer.android.com/studio/gemini/add-mcp-server).
2. 표준 설정을 사용합니다:

```json
{
  "mcpServers": {
    "notifly-mcp-server": {
      "command": "npx",
      "args": ["-y", "notifly-mcp-server@latest"]
    }
  }
}
```

#### Xcode

**옵션 1: Xcode용 GitHub Copilot**

1. Settings > MCP Configuration > Edit Config.
2. 추가:

```json
{
  "servers": {
    "notifly-mcp-server": {
      "command": "npx",
      "args": ["-y", "notifly-mcp-server@latest"]
    }
  }
}
```

**옵션 2: XcodeBuildMCP**

1. MCP 클라이언트에 추가:

```json
{
  "mcpServers": {
    "notifly-mcp-server": {
      "command": "npx",
      "args": ["-y", "notifly-mcp-server@latest"]
    },
    "XcodeBuildMCP": {
      "command": "npx",
      "args": ["-y", "xcodebuildmcp@latest"]
    }
  }
}
```

#### Cursor

**수동 설정**

1. Cursor Settings > Tool & MCP > New MCP Server.
2. JSON을 붙여넣고 재시작:

```json
{
  "mcpServers": {
    "notifly-mcp-server": {
      "command": "npx",
      "args": ["-y", "notifly-mcp-server@latest"]
    }
  }
}
```

#### Amazon Q

**수동 설정**

1. `~/.aws/amazonq/agents/default.json` 열기
2. `mcpServers`에 추가:

```json
"mcpServers": {
  "notifly-mcp-server": {
    "command": "npx",
    "args": ["-y", "notifly-mcp-server@latest"]
  }
}
```

#### Google Antigravity

**수동 설정**

1. Agent tab > ellipsis (...) > MCP Server > Manage MCP Servers.
2. `mcp_config.json`에 추가:

```json
{
  "mcpServers": {
    "notifly-mcp-server": {
      "command": "npx",
      "args": ["-y", "notifly-mcp-server@latest"]
    }
  }
}
```

#### VS Code

**수동 설정**

1. `~/.vscode/mcp.json` 열기
2. JSON을 붙여넣고 재시작:

```json
{
  "mcpServers": {
    "notifly-mcp-server": {
      "command": "npx",
      "args": ["-y", "notifly-mcp-server@latest"]
    }
  }
}
```

#### Claude Code CLI

**커맨드 라인:**

```bash
claude mcp add --transport stdio notifly-mcp-server -- npx -y notifly-mcp-server@latest
```

**마켓플레이스:**

```bash
/plugin marketplace add notifly-tech/notifly-mcp-server
```

#### Codex CLI

**설정**

1. `~/.codex/config.toml` 열기
2. 추가 후 재시작:

```toml
[mcp_servers]
  # 중요: 이 이름을 "notifly-mcp-server"로 유지해야 툴이
  # `notifly-mcp-server:*`로 노출됩니다 (`notifly:*`가 아님).
  [mcp_servers."notifly-mcp-server"]
  command = "npx"
  args = ["-y", "notifly-mcp-server@latest"]
```

#### Kiro CLI

**설정**

1. `.kiro/settings/mcp.json` 열기
2. 추가:

```json
{
  "mcpServers": {
    "notifly-mcp-server": {
      "command": "npx",
      "args": ["-y", "notifly-mcp-server@latest"]
    }
  }
}
```

#### Amp

**설정**

Amp는 VS Code 설정 파일에서 `amp.mcpServers`를 사용합니다. 아래 중 하나에
설정하세요:

- **워크스페이스 설정**: `.vscode/settings.json` (프로젝트별 설정 권장)
- **유저 설정**: `~/.vscode/settings.json` (전역 설정)

1. `.vscode/settings.json` 열기(없으면 생성)
2. 다음 설정 추가:

```json
{
  "amp.mcpServers": {
    "notifly-mcp-server": {
      "command": "npx",
      "args": ["-y", "notifly-mcp-server@latest"]
    }
  }
}
```

3. Amp를 재시작하거나 VS Code 창을 reload 하세요.

**참고**: 서버 이름을 `notifly-mcp-server`로 유지하면 툴이
`notifly-mcp-server:*`로 노출됩니다(예: `notifly-mcp-server:search_sdk`,
`notifly-mcp-server:search_docs`). 자세한 내용은
[Amp MCP 문서](https://ampcode.com/manual#mcp)를 참고하세요.

#### OpenCode

**설정**

OpenCode는 프로젝트 루트의 `opencode.json` 또는 `opencode.jsonc`를 사용합니다.
자세한 내용은 [OpenCode MCP 문서](https://opencode.ai/docs/mcp-servers/)를
참고하세요.

1. `opencode.json` 또는 `opencode.jsonc` 열기(없으면 생성)
2. 다음 설정 추가:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    "notifly-mcp-server": {
      "type": "local",
      "command": ["npx", "-y", "notifly-mcp-server@latest"],
      "enabled": true
    }
  }
}
```

3. OpenCode를 재시작하거나 설정을 reload 하세요.

**참고**: 서버 이름을 `notifly-mcp-server`로 유지하면 툴이
`notifly-mcp-server:*`로 노출됩니다(예: `notifly-mcp-server:search_sdk`,
`notifly-mcp-server:search_docs`). 또한 프롬프트에서 `use notifly-mcp-server`로
서버를 참조하거나, `AGENTS.md`에 추가할 수 있습니다.

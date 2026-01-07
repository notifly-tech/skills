# Notifly MCP Server

Notifly MCP Server implements the
[Model Context Protocol (MCP)](https://modelcontextprotocol.io/) to enable LLMs
to search Notifly documentation and SDK code.

## Integration Guide

### Install

You generally do **not** need a global install. The recommended setup runs the
server via `npx` from your MCP client config.

Optional global install (only if your client requires a direct binary on PATH):

- **npm**:

```bash
npm i -g notifly-mcp-server@latest
```

- **yarn**:

```bash
yarn global add notifly-mcp-server@latest
```

### Configure .mcp.json

Create or update the `.mcp.json` at your project root (or the configuration
location your MCP client uses).

Recommended configuration using `npx`:

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

### Important: Server name affects tool namespace

Most MCP clients expose tools with a prefix that matches the **server name**.
For example, naming the server `notifly-mcp-server` yields tools like:

- `notifly-mcp-server:search_docs`
- `notifly-mcp-server:search_sdk`

If you name the server something else (e.g. `notifly`), your tools will appear
as `notifly:*` and skills that expect `notifly-mcp-server:*` will think the
server is missing.

### Use Notifly MCP Server with Popular MCP Clients and IDEs

#### Android Studio

**Option 1: GitHub Copilot plugin in Android Studio**

1. Settings > Tools > GitHub Copilot > Model Context Protocol (MCP) > Configure.
2. Edit `mcp.json`:

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

**Option 2: Using MCP Server plugin from JetBrains**

1. Install "MCP Server" plugin from JetBrains.
2. Configure client:

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

**Option 3: Gemini in Android Studio**

1. [Add an MCP server to Gemini](https://developer.android.com/studio/gemini/add-mcp-server).
2. Use standard configuration:

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

**Option 1: GitHub Copilot for Xcode**

1. Settings > MCP Configuration > Edit Config.
2. Add:

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

**Option 2: XcodeBuildMCP**

1. Add to your MCP client:

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

**Manual setup**

1. Cursor Settings > Tool & MCP > New MCP Server.
2. Paste JSON and restart:

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

**Manual setup**

1. Open `~/.aws/amazonq/agents/default.json`.
2. Add to `mcpServers`:

```json
"mcpServers": {
  "notifly-mcp-server": {
    "command": "npx",
    "args": ["-y", "notifly-mcp-server@latest"]
  }
}
```

#### Google Antigravity

**Manual setup**

1. Agent tab > ellipsis (...) > MCP Server > Manage MCP Servers.
2. Add to `mcp_config.json`:

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

**Manual setup**

1. Open `~/.vscode/mcp.json`.
2. Paste JSON and restart:

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

**Command Line:**

```bash
claude mcp add --transport stdio notifly-mcp-server -- npx -y notifly-mcp-server@latest
```

**Marketplace:**

```bash
/plugin marketplace add notifly-tech/notifly-mcp-server
```

#### Codex CLI

**Setup**

1. Open `~/.codex/config.toml`.
2. Add and restart:

```toml
[mcp_servers]
  # IMPORTANT: keep this name as "notifly-mcp-server" so tools show up as
  # `notifly-mcp-server:*` (and not `notifly:*`).
  [mcp_servers."notifly-mcp-server"]
  command = "npx"
  args = ["-y", "notifly-mcp-server@latest"]
```

#### Kiro CLI

**Setup**

1. Open `.kiro/settings/mcp.json`.
2. Add:

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

**Setup**

Amp uses `amp.mcpServers` in VS Code settings files. Configure in either:

- **Workspace settings**: `.vscode/settings.json` (recommended for
  project-specific setup)
- **User settings**: `~/.vscode/settings.json` (for global setup)

1. Open `.vscode/settings.json` (create if it doesn't exist).
2. Add the configuration:

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

3. Restart Amp or reload the VS Code window.

**Note**: The server name `notifly-mcp-server` ensures tools appear as
`notifly-mcp-server:*` (e.g., `notifly-mcp-server:search_sdk`,
`notifly-mcp-server:search_docs`). See
[Amp MCP documentation](https://ampcode.com/manual#mcp) for more details.

#### OpenCode

**Setup**

OpenCode uses `opencode.json` or `opencode.jsonc` files in your project root.
See [OpenCode MCP documentation](https://opencode.ai/docs/mcp-servers/) for
details.

1. Open `opencode.json` or `opencode.jsonc` (create if it doesn't exist).
2. Add the configuration:

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

3. Restart OpenCode or reload the configuration.

**Note**: The server name `notifly-mcp-server` ensures tools appear as
`notifly-mcp-server:*` (e.g., `notifly-mcp-server:search_sdk`,
`notifly-mcp-server:search_docs`). You can reference the server in prompts with
`use notifly-mcp-server` or add it to your `AGENTS.md` file.

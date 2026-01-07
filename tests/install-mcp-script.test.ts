import { spawnSync } from "child_process";
import fs from "fs";
import os from "os";
import path from "path";

const nodeBinDir = path.dirname(process.execPath);

function makeTempDir(): string {
  return fs.mkdtempSync(path.join(os.tmpdir(), "notifly-agent-skills-"));
}

function writeExecutable(filePath: string, content: string) {
  fs.mkdirSync(path.dirname(filePath), { recursive: true });
  fs.writeFileSync(filePath, content, "utf8");
  fs.chmodSync(filePath, 0o755);
}

function runScript(scriptPath: string, cwd: string, env: Record<string, string | undefined>) {
  return spawnSync("bash", [scriptPath], {
    cwd,
    env: {
      ...process.env,
      ...env,
    },
    encoding: "utf8",
  });
}

function runScriptWithArgs(
  scriptPath: string,
  cwd: string,
  args: string[],
  env: Record<string, string | undefined>
) {
  return spawnSync("bash", [scriptPath, ...args], {
    cwd,
    env: {
      ...process.env,
      ...env,
    },
    encoding: "utf8",
  });
}

function writeFakeNpm(binDir: string) {
  // Allows the installer to pass "npm view ..." without network access.
  writeExecutable(
    path.join(binDir, "npm"),
    `#!/usr/bin/env bash
set -euo pipefail
if [ "\${1:-}" = "view" ]; then
  echo "0.0.0-test"
  exit 0
fi
exit 0
`
  );
}

describe("skills/integration/scripts/install-mcp.sh", () => {
  const scriptPath = path.resolve(
    __dirname,
    "..",
    "skills",
    "integration",
    "scripts",
    "install-mcp.sh"
  );

  it("--help prints usage and exits 0", () => {
    const tmp = makeTempDir();
    const res = runScriptWithArgs(scriptPath, tmp, ["--help"], {
      PATH: process.env.PATH,
    });
    expect(res.status).toBe(0);
    expect((res.stdout || "") + (res.stderr || "")).toMatch(/Usage:|사용법:/);
    expect((res.stdout || "") + (res.stderr || "")).toMatch(/--client/);
    expect((res.stdout || "") + (res.stderr || "")).toMatch(/Supported:|지원:/);
  });

  it("unknown args fail with status 2", () => {
    const tmp = makeTempDir();
    const res = runScriptWithArgs(scriptPath, tmp, ["--nope"], {
      PATH: process.env.PATH,
    });
    expect(res.status).toBe(2);
    expect((res.stdout || "") + (res.stderr || "")).toMatch(/Unknown argument|알 수 없는 인자/);
  });

  it("invalid --client fails with status 2", () => {
    const tmp = makeTempDir();
    const res = runScriptWithArgs(scriptPath, tmp, ["--client", "nope"], {
      PATH: process.env.PATH,
    });
    expect(res.status).toBe(2);
    expect((res.stdout || "") + (res.stderr || "")).toMatch(/Invalid --client|잘못된 --client/);
  });

  it("detects Claude Code CLI first (even if opencode.jsonc exists) and runs `claude mcp add`", () => {
    const tmp = makeTempDir();
    const binDir = path.join(tmp, "bin");
    const homeDir = path.join(tmp, "home");
    const claudeLog = path.join(tmp, "claude.log");

    // Make an opencode.jsonc file in cwd (this previously caused mis-detection).
    fs.writeFileSync(
      path.join(tmp, "opencode.jsonc"),
      `{\n  "$schema": "https://opencode.ai/config.json",\n  "mcp": {}\n}\n`,
      "utf8"
    );

    writeFakeNpm(binDir);

    // Fake claude CLI with mcp support.
    writeExecutable(
      path.join(binDir, "claude"),
      `#!/usr/bin/env bash
set -euo pipefail
echo "$@" >> "${claudeLog}"

if [ "\${1:-}" = "mcp" ] && [ "\${2:-}" = "--help" ]; then
  echo "help"
  exit 0
fi

if [ "\${1:-}" = "mcp" ] && [ "\${2:-}" = "list" ]; then
  # No servers configured
  exit 0
fi

if [ "\${1:-}" = "mcp" ] && [ "\${2:-}" = "add" ]; then
  echo "added"
  exit 0
fi

exit 0
`
    );

    const res = runScriptWithArgs(scriptPath, tmp, ["--client", "claude"], {
      HOME: homeDir,
      PATH: `${binDir}:/usr/bin:/bin`,
    });

    expect(res.status).toBe(0);
    expect(fs.existsSync(claudeLog)).toBe(true);
    const log = fs.readFileSync(claudeLog, "utf8");
    expect(log).toMatch(/mcp list/);
    expect(log).toMatch(
      /mcp add --transport stdio notifly-mcp-server -- npx -y notifly-mcp-server@latest/
    );
  });

  it("treats --client claude-code as Claude Code and runs `claude mcp add`", () => {
    const tmp = makeTempDir();
    const binDir = path.join(tmp, "bin");
    const homeDir = path.join(tmp, "home");
    const claudeLog = path.join(tmp, "claude.log");

    writeFakeNpm(binDir);

    writeExecutable(
      path.join(binDir, "claude"),
      `#!/usr/bin/env bash
set -euo pipefail
echo "$@" >> "${claudeLog}"
if [ "\${1:-}" = "mcp" ] && [ "\${2:-}" = "--help" ]; then exit 0; fi
if [ "\${1:-}" = "mcp" ] && [ "\${2:-}" = "list" ]; then exit 0; fi
if [ "\${1:-}" = "mcp" ] && [ "\${2:-}" = "add" ]; then exit 0; fi
exit 0
`
    );

    const res = runScriptWithArgs(scriptPath, tmp, ["--client", "claude-code"], {
      HOME: homeDir,
      PATH: `${binDir}:${nodeBinDir}:/usr/bin:/bin`,
    });

    expect(res.status).toBe(0);
    const log = fs.readFileSync(claudeLog, "utf8");
    expect(log).toMatch(/mcp add --transport stdio notifly-mcp-server/);
  });

  it("updates opencode.jsonc containing https:// in $schema + comments without JSON.parse failure", () => {
    const tmp = makeTempDir();
    const binDir = path.join(tmp, "bin");
    const homeDir = path.join(tmp, "home");

    writeFakeNpm(binDir);

    // Ensure Claude is NOT detected, so OpenCode path is chosen.
    // (No `claude` executable in PATH.)

    const opencodePath = path.join(tmp, "opencode.jsonc");
    fs.writeFileSync(
      opencodePath,
      String.raw`{
  // comment line that must be stripped
  "$schema": "https://opencode.ai/config.json",
  "note": "keep // inside string, and escaped quote: \"ok\"",
  "mcp": {
    /* block comment */
  }
}
`,
      "utf8"
    );

    const res = runScriptWithArgs(scriptPath, tmp, ["--client", "opencode"], {
      HOME: homeDir,
      PATH: `${binDir}:${nodeBinDir}:/usr/bin:/bin`,
    });

    expect(res.status).toBe(0);
    const updated = fs.readFileSync(opencodePath, "utf8");
    expect(updated).toMatch(/"notifly-mcp-server"/);
    expect(updated).toMatch(/"command": \[\s*"npx",\s*"-y",\s*"notifly-mcp-server@latest"\s*\]/);
    expect(updated).toMatch(/"enabled": true/);
  });

  it("creates opencode.jsonc if missing when using --client opencode", () => {
    const tmp = makeTempDir();
    const binDir = path.join(tmp, "bin");
    const homeDir = path.join(tmp, "home");

    writeFakeNpm(binDir);

    const opencodePath = path.join(tmp, "opencode.jsonc");
    expect(fs.existsSync(opencodePath)).toBe(false);

    const res = runScriptWithArgs(scriptPath, tmp, ["--client", "opencode"], {
      HOME: homeDir,
      PATH: `${binDir}:${nodeBinDir}:/usr/bin:/bin`,
    });

    expect(res.status).toBe(0);
    const updated = fs.readFileSync(opencodePath, "utf8");
    expect(updated).toMatch(/"mcp"/);
    expect(updated).toMatch(/"notifly-mcp-server"/);
  });

  it("detects Codex via ~/.codex/config.toml and injects notifly-mcp-server entry", () => {
    const tmp = makeTempDir();
    const binDir = path.join(tmp, "bin");
    const homeDir = path.join(tmp, "home");

    writeFakeNpm(binDir);

    const codexPath = path.join(homeDir, ".codex", "config.toml");
    fs.mkdirSync(path.dirname(codexPath), { recursive: true });
    fs.writeFileSync(codexPath, "[mcp_servers]\n", "utf8");

    const res = runScriptWithArgs(scriptPath, tmp, ["--client", "codex"], {
      HOME: homeDir,
      PATH: `${binDir}:${nodeBinDir}:/usr/bin:/bin`,
    });

    expect(res.status).toBe(0);
    const updated = fs.readFileSync(codexPath, "utf8");
    expect(updated).toMatch(/\[mcp_servers\."notifly-mcp-server"\]/);
    expect(updated).toMatch(/notifly-mcp-server@latest/);
  });

  it("detects Amp via .vscode/settings.json and updates JSONC safely (https:// + comments)", () => {
    const tmp = makeTempDir();
    const binDir = path.join(tmp, "bin");
    const homeDir = path.join(tmp, "home");

    writeFakeNpm(binDir);

    fs.mkdirSync(path.join(tmp, ".vscode"), { recursive: true });
    const settingsPath = path.join(tmp, ".vscode", "settings.json");
    fs.writeFileSync(
      settingsPath,
      String.raw`{
  // comment
  "someUrl": "https://example.com/schema",
  "note": "escaped quote: \"ok\" and // inside string",
  "amp.mcpServers": {
    /* block comment */
  }
}
`,
      "utf8"
    );

    const res = runScriptWithArgs(scriptPath, tmp, ["--client", "amp"], {
      HOME: homeDir,
      PATH: `${binDir}:${nodeBinDir}:/usr/bin:/bin`,
    });

    expect(res.status).toBe(0);
    const updated = fs.readFileSync(settingsPath, "utf8");
    expect(updated).toMatch(/"amp\.mcpServers"/);
    expect(updated).toMatch(/"notifly-mcp-server"/);
    expect(updated).toMatch(/"notifly-mcp-server@latest"/);
  });

  it("detects Cursor via ~/.cursor/mcp.json and writes mcpServers", () => {
    const tmp = makeTempDir();
    const binDir = path.join(tmp, "bin");
    const homeDir = path.join(tmp, "home");

    writeFakeNpm(binDir);

    const cursorPath = path.join(homeDir, ".cursor", "mcp.json");
    fs.mkdirSync(path.dirname(cursorPath), { recursive: true });
    fs.writeFileSync(cursorPath, `{"mcpServers": {}}\n`, "utf8");

    const res = runScriptWithArgs(scriptPath, tmp, ["--client", "cursor"], {
      HOME: homeDir,
      PATH: `${binDir}:${nodeBinDir}:/usr/bin:/bin`,
    });

    expect(res.status).toBe(0);
    const updated = fs.readFileSync(cursorPath, "utf8");
    expect(updated).toMatch(/"mcpServers"/);
    expect(updated).toMatch(/"notifly-mcp-server"/);
  });

  it("writes VS Code mcp.json when using --client vscode", () => {
    const tmp = makeTempDir();
    const binDir = path.join(tmp, "bin");
    const homeDir = path.join(tmp, "home");

    writeFakeNpm(binDir);

    const vscodePath = path.join(homeDir, ".vscode", "mcp.json");
    expect(fs.existsSync(vscodePath)).toBe(false);

    const res = runScriptWithArgs(scriptPath, tmp, ["--client", "vscode"], {
      HOME: homeDir,
      PATH: `${binDir}:${nodeBinDir}:/usr/bin:/bin`,
    });

    expect(res.status).toBe(0);
    const updated = fs.readFileSync(vscodePath, "utf8");
    expect(updated).toMatch(/"mcpServers"/);
    expect(updated).toMatch(/"notifly-mcp-server"/);
  });

  it("treats --client claude as Claude Code and runs `claude mcp add`", () => {
    const tmp = makeTempDir();
    const binDir = path.join(tmp, "bin");
    const homeDir = path.join(tmp, "home");
    const claudeLog = path.join(tmp, "claude.log");

    writeFakeNpm(binDir);

    // Fake claude CLI with mcp support.
    writeExecutable(
      path.join(binDir, "claude"),
      `#!/usr/bin/env bash
set -euo pipefail
echo "$@" >> "${claudeLog}"

if [ "\${1:-}" = "mcp" ] && [ "\${2:-}" = "--help" ]; then
  echo "help"
  exit 0
fi

if [ "\${1:-}" = "mcp" ] && [ "\${2:-}" = "list" ]; then
  # No servers configured
  exit 0
fi

if [ "\${1:-}" = "mcp" ] && [ "\${2:-}" = "add" ]; then
  echo "added"
  exit 0
fi

exit 0
`
    );

    const res = runScriptWithArgs(scriptPath, tmp, ["--client", "claude"], {
      HOME: homeDir,
      PATH: `${binDir}:${nodeBinDir}:/usr/bin:/bin`,
    });

    expect(res.status).toBe(0);
    expect(fs.existsSync(claudeLog)).toBe(true);
    const log = fs.readFileSync(claudeLog, "utf8");
    expect(log).toMatch(/mcp list/);
    expect(log).toMatch(
      /mcp add --transport stdio notifly-mcp-server -- npx -y notifly-mcp-server@latest/
    );
  });

  it("fails safely when multiple clients are detected and no --client is provided (non-interactive)", () => {
    const tmp = makeTempDir();
    const binDir = path.join(tmp, "bin");
    const homeDir = path.join(tmp, "home");

    writeFakeNpm(binDir);

    // Make OpenCode detectable
    fs.writeFileSync(
      path.join(tmp, "opencode.jsonc"),
      `{\n  "$schema": "https://opencode.ai/config.json",\n  "mcp": {}\n}\n`,
      "utf8"
    );

    // Make Claude Code detectable too
    writeExecutable(
      path.join(binDir, "claude"),
      `#!/usr/bin/env bash
set -euo pipefail
if [ "\${1:-}" = "mcp" ] && [ "\${2:-}" = "--help" ]; then
  exit 0
fi
exit 0
`
    );

    const res = runScript(scriptPath, tmp, {
      HOME: homeDir,
      PATH: `${binDir}:/usr/bin:/bin`,
    });

    expect(res.status).toBe(2);
    expect((res.stdout || "") + (res.stderr || "")).toMatch(
      /Multiple MCP clients detected|여러 MCP 클라이언트/
    );
    expect((res.stdout || "") + (res.stderr || "")).toMatch(/--client/);
  });
});

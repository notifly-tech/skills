import { spawnSync } from "child_process";
import fs from "fs";
import path from "path";

function run(
  command: string,
  args: string[],
  cwd: string,
  env: Record<string, string | undefined>
) {
  return spawnSync(command, args, {
    cwd,
    env: { ...process.env, ...env },
    encoding: "utf8",
    stdio: ["ignore", "pipe", "pipe"], // Non-interactive: ignore stdin, capture stdout/stderr
    timeout: 60_000, // 60 second timeout per command
  });
}

function mkRepoTempDir(repoRoot: string, prefix: string) {
  const base = path.join(repoRoot, ".tmp-tests");
  fs.mkdirSync(base, { recursive: true });
  return fs.mkdtempSync(path.join(base, prefix));
}

type VerifyResult = { valid: boolean; missing: string[]; found: string[] };

/**
 * Verify all necessary files are present in a skill folder
 */
function verifySkillFiles(skillPath: string, _skillName: string): VerifyResult {
  const requiredFiles = ["SKILL.md", "LICENSE.txt"];
  const requiredDirs = ["references", "scripts"];

  const missing: string[] = [];
  const found: string[] = [];

  // Check required files
  for (const file of requiredFiles) {
    const filePath = path.join(skillPath, file);
    if (fs.existsSync(filePath)) {
      found.push(file);
    } else {
      missing.push(file);
    }
  }

  // Check required directories exist and have content
  for (const dir of requiredDirs) {
    const dirPath = path.join(skillPath, dir);
    if (fs.existsSync(dirPath) && fs.statSync(dirPath).isDirectory()) {
      const files = fs.readdirSync(dirPath);
      if (files.length > 0) {
        found.push(`${dir}/ (${files.length} files)`);
      } else {
        missing.push(`${dir}/ (empty)`);
      }
    } else {
      missing.push(`${dir}/ (missing)`);
    }
  }

  // Optional: examples directory (nice to have, but not required)
  const examplesPath = path.join(skillPath, "examples");
  if (fs.existsSync(examplesPath) && fs.statSync(examplesPath).isDirectory()) {
    const exampleFiles = fs.readdirSync(examplesPath);
    if (exampleFiles.length > 0) {
      found.push(`examples/ (${exampleFiles.length} files)`);
    }
  }

  return { valid: missing.length === 0, missing, found };
}

function writeJson(filePath: string, data: unknown) {
  fs.mkdirSync(path.dirname(filePath), { recursive: true });
  fs.writeFileSync(filePath, JSON.stringify(data, null, 2) + "\n", "utf8");
}

function seedMcpConfig(homeDir: string, client: string) {
  const notiflyServer = {
    command: "npx",
    args: ["-y", "notifly-mcp-server@latest"],
  };

  switch (client) {
    case "amazonq":
      writeJson(path.join(homeDir, ".aws", "amazonq", "agents", "default.json"), {
        mcpServers: { "notifly-mcp-server": notiflyServer },
      });
      return;
    case "amp":
      writeJson(path.join(homeDir, ".config", "amp", "settings.json"), {
        "amp.mcpServers": { "notifly-mcp-server": notiflyServer },
      });
      return;
    case "codex": {
      const p = path.join(homeDir, ".codex", "config.toml");
      fs.mkdirSync(path.dirname(p), { recursive: true });
      fs.writeFileSync(
        p,
        `[mcp_servers]
  [mcp_servers."notifly-mcp-server"]
  command = "npx"
  args = ["-y", "notifly-mcp-server@latest"]
`,
        "utf8"
      );
      return;
    }
    case "cursor":
      writeJson(path.join(homeDir, ".cursor", "mcp.json"), {
        mcpServers: { "notifly-mcp-server": notiflyServer },
      });
      return;
    case "gemini":
      writeJson(path.join(homeDir, ".gemini", "settings.json"), {
        mcpServers: { "notifly-mcp-server": notiflyServer },
      });
      return;
    case "github":
    case "vscode":
      writeJson(path.join(homeDir, ".vscode", "mcp.json"), {
        mcpServers: { "notifly-mcp-server": notiflyServer },
      });
      return;
    case "kiro":
      writeJson(path.join(homeDir, ".kiro", "settings", "mcp.json"), {
        mcpServers: { "notifly-mcp-server": notiflyServer },
      });
      return;
    case "opencode":
      writeJson(path.join(homeDir, "opencode.json"), {
        $schema: "https://opencode.ai/config.json",
        mcp: {
          "notifly-mcp-server": {
            type: "local",
            command: ["npx", "-y", "notifly-mcp-server@latest"],
            enabled: true,
          },
        },
      });
      return;
    default:
      return;
  }
}

describe("released package smoke test (npm)", () => {
  // Building + downloading + installing can be slow on CI.
  jest.setTimeout(3 * 60 * 1000);

  // IMPORTANT: This test requires network access to fetch `@latest` from npm.
  // It is intentionally skipped unless explicitly enabled.
  const runReleased = process.env.NOTIFLY_RELEASE_SMOKE_TEST === "1";

  const repoRoot = path.resolve(__dirname, "..");
  const tmpTestsRoot = path.join(repoRoot, ".tmp-tests");

  afterAll(() => {
    try {
      if (fs.existsSync(tmpTestsRoot)) {
        fs.rmSync(tmpTestsRoot, { recursive: true, force: true });
      }
    } catch {
      // cleanup failures should not fail the test suite
    }
  });

  const pkg = "notifly-agent-skills@latest";

  // Currently only one skill is shipped, but this keeps the test structure future-proof.
  const expectedSkills = ["integration"];

  // Keep this aligned with src/bin/commands/install.ts default paths.
  const clients: Array<{ name: string; path: string }> = [
    { name: "amazonq", path: ".amazonq/skills" },
    { name: "amp", path: ".amp/skills" },
    { name: "claude", path: ".claude/skills" },
    { name: "claude-code", path: ".claude/skills" },
    { name: "codex", path: ".codex/skills" },
    { name: "cursor", path: ".cursor/skills" },
    { name: "gemini", path: ".gemini/skills" },
    { name: "github", path: ".github/skills" },
    { name: "goose", path: ".goose/skills" },
    { name: "kiro", path: ".kiro/skills" },
    { name: "letta", path: ".skills" },
    { name: "opencode", path: ".opencode/skill" },
    { name: "vscode", path: ".vscode/skills" },
  ];

  (runReleased ? it : it.skip)("CLI version check", () => {
    const tmp = mkRepoTempDir(repoRoot, "released-version-");
    const projectDir = path.join(tmp, "project");
    const homeDir = path.join(tmp, "home");
    const npmCacheDir = path.join(tmp, "npm-cache");

    try {
      fs.mkdirSync(projectDir, { recursive: true });
      fs.mkdirSync(homeDir, { recursive: true });

      const env = {
        HOME: homeDir,
        npm_config_cache: npmCacheDir,
        npm_config_fund: "false",
        npm_config_audit: "false",
        npm_config_update_notifier: "false",
      };

      const versionRes = run("npx", ["-y", pkg, "--version"], projectDir, env);

      expect(versionRes.status).toBe(0);
      expect((versionRes.stdout || "").trim()).toMatch(/\d+\.\d+\.\d+/);
    } finally {
      fs.rmSync(tmp, { recursive: true, force: true });
    }
  });

  clients.forEach(({ name, path: expectedPath }) => {
    (runReleased ? it : it.skip)(`installs all skills at repo root for client: ${name}`, () => {
      const tmp = mkRepoTempDir(repoRoot, `released-${name}-`);
      const projectDir = path.join(tmp, "project");
      const homeDir = path.join(tmp, "home");
      const npmCacheDir = path.join(tmp, "npm-cache");

      try {
        fs.mkdirSync(projectDir, { recursive: true });
        fs.mkdirSync(homeDir, { recursive: true });

        // Seed MCP config so the released CLI doesn't hang on interactive prompts.
        // (We still verify skill installation paths; MCP config is secondary here.)
        seedMcpConfig(homeDir, name);

        const env = {
          HOME: homeDir,
          npm_config_cache: npmCacheDir,
          npm_config_fund: "false",
          npm_config_audit: "false",
          npm_config_update_notifier: "false",
          CI: "true",
          FORCE_COLOR: "0",
        };

        const installCmd = ["-y", pkg, "install", "--all", "--client", name];
        const cliRes = run("npx", installCmd, projectDir, env);

        // Primary assertion: skills installed in correct path
        const installedSkillsRoot = path.join(projectDir, ...expectedPath.split("/"));

        const installedSkills: string[] = [];
        const missingSkills: string[] = [];
        const skillFileIssues: Array<{ skill: string; missing: string[] }> = [];

        expectedSkills.forEach((skill) => {
          const skillPath = path.join(installedSkillsRoot, skill);
          const skillMd = path.join(skillPath, "SKILL.md");
          if (fs.existsSync(skillMd)) {
            installedSkills.push(skill);
            const check = verifySkillFiles(skillPath, skill);
            if (!check.valid) {
              skillFileIssues.push({ skill, missing: check.missing });
            }
          } else {
            missingSkills.push(skill);
          }
        });

        const allSkillsInstalled = missingSkills.length === 0 && skillFileIssues.length === 0;
        if (!allSkillsInstalled) {
          const stderr = (cliRes.stderr || "").toString();
          const stdout = (cliRes.stdout || "").toString();
          let msg = `Released install failed for client ${name}\n`;
          msg += `Exit status: ${cliRes.status}\n`;
          msg += `STDOUT:\n${stdout}\nSTDERR:\n${stderr}\n`;
          msg += `Expected skills at: ${installedSkillsRoot}\n`;
          if (missingSkills.length > 0) msg += `Missing skills: ${missingSkills.join(", ")}\n`;
          if (skillFileIssues.length > 0) {
            msg += `Skills with missing files:\n`;
            skillFileIssues.forEach(({ skill, missing }) => {
              msg += `- ${skill}: ${missing.join(", ")}\n`;
            });
          }
          throw new Error(msg);
        }

        // Secondary: CLI should generally succeed, but we don't hard-fail on MCP config hiccups
        // as long as skills were installed correctly.
        if (cliRes.status !== null && cliRes.status !== 0) {
          // eslint-disable-next-line no-console
          console.warn(
            `WARNING: CLI exited with status ${cliRes.status} for client ${name}, but skills were installed.\n` +
              `STDERR:\n${(cliRes.stderr || "").toString()}`
          );
        }
      } finally {
        fs.rmSync(tmp, { recursive: true, force: true });
      }
    });
  });
});

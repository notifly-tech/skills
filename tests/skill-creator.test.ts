import { spawnSync } from "child_process";
import fs from "fs";
import path from "path";

function makeTempDir(): string {
  // In sandboxed environments, writing to OS temp directories can be disallowed.
  // Create temp dirs within the repo instead.
  const base = path.join(process.cwd(), ".tmp-test");
  fs.mkdirSync(base, { recursive: true });
  return fs.mkdtempSync(path.join(base, "notifly-skill-creator-"));
}

function writeFile(filePath: string, content: string) {
  fs.mkdirSync(path.dirname(filePath), { recursive: true });
  fs.writeFileSync(filePath, content, "utf8");
}

function writeNonEmptyDir(dirPath: string, filename = "placeholder.txt") {
  fs.mkdirSync(dirPath, { recursive: true });
  fs.writeFileSync(path.join(dirPath, filename), "ok\n", "utf8");
}

function runValidateSkillScaffold(skillDir: string) {
  const scriptPath = path.resolve(
    __dirname,
    "..",
    "skills",
    "skill-creator",
    "scripts",
    "validate-skill-scaffold.sh"
  );

  return spawnSync("bash", [scriptPath, skillDir], {
    cwd: process.cwd(),
    env: process.env,
    encoding: "utf8",
  });
}

function makeMinimalSkill({
  name,
  includeMcpRef = true,
  nonEmptyReferences = true,
  nonEmptyScripts = true,
}: {
  name: string;
  includeMcpRef?: boolean;
  nonEmptyReferences?: boolean;
  nonEmptyScripts?: boolean;
}): string {
  const dir = makeTempDir();

  const mcpLine = includeMcpRef ? "\n\nMCP: notifly-mcp-server:search_docs\n" : "\n";

  writeFile(
    path.join(dir, "SKILL.md"),
    `---
name: ${name}
display-name: Test Skill
short-description: Test
description: Test skill
user-invocable: true
---

# Test Skill
${mcpLine}
`
  );

  writeFile(path.join(dir, "LICENSE.txt"), "Apache-2.0\n");

  const refsDir = path.join(dir, "references");
  const scriptsDir = path.join(dir, "scripts");
  fs.mkdirSync(refsDir, { recursive: true });
  fs.mkdirSync(scriptsDir, { recursive: true });

  if (nonEmptyReferences) writeNonEmptyDir(refsDir, "ref.md");
  if (nonEmptyScripts) writeNonEmptyDir(scriptsDir, "validate.sh");

  return dir;
}

describe("skill-creator validator: validate-skill-scaffold.sh", () => {
  it("passes for notifly-* name and notifly-mcp-server reference", () => {
    const dir = makeMinimalSkill({ name: "notifly-test-skill" });
    const res = runValidateSkillScaffold(dir);
    expect(res.status).toBe(0);
    expect((res.stdout || "") + (res.stderr || "")).toMatch(/OK: 스킬 스캐폴드 검증 통과/);
  });

  it("fails when frontmatter name does not start with notifly-", () => {
    const dir = makeMinimalSkill({ name: "clix-test-skill" });
    const res = runValidateSkillScaffold(dir);
    expect(res.status).toBe(1);
    expect((res.stdout || "") + (res.stderr || "")).toMatch(
      /프론트매터 name은 'notifly-'로 시작해야 합니다/
    );
  });

  it("fails when SKILL.md does not reference notifly-mcp-server", () => {
    const dir = makeMinimalSkill({ name: "notifly-test-skill", includeMcpRef: false });
    const res = runValidateSkillScaffold(dir);
    expect(res.status).toBe(1);
    expect((res.stdout || "") + (res.stderr || "")).toMatch(/notifly-mcp-server/);
  });

  it("fails when references/ exists but is empty", () => {
    const dir = makeMinimalSkill({ name: "notifly-test-skill", nonEmptyReferences: false });
    const res = runValidateSkillScaffold(dir);
    expect(res.status).toBe(1);
    expect((res.stdout || "") + (res.stderr || "")).toMatch(
      /필수 디렉터리가 비어 있습니다: references\//
    );
  });

  it("fails when scripts/ exists but is empty", () => {
    const dir = makeMinimalSkill({ name: "notifly-test-skill", nonEmptyScripts: false });
    const res = runValidateSkillScaffold(dir);
    expect(res.status).toBe(1);
    expect((res.stdout || "") + (res.stderr || "")).toMatch(
      /필수 디렉터리가 비어 있습니다: scripts\//
    );
  });
});

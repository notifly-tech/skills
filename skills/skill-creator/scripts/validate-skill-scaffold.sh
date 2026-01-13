#!/usr/bin/env bash
#
# Notifly 에이전트 스킬 스캐폴드를 검증합니다(폴더 구조 + 프론트매터).
#
# 사용법:
#   bash skills/skill-creator/scripts/validate-skill-scaffold.sh path/to/skill-folder
#
# 검증 내용:
# - SKILL.md and LICENSE.txt exist
# - references/ and scripts/ exist and are non-empty
# - SKILL.md has YAML frontmatter with required keys
# - SKILL.md contains an MCP-first section that references `notifly-mcp-server`
#
set -euo pipefail

skill_dir="${1:-}"
if [[ -z "$skill_dir" ]]; then
  echo "사용법: bash skills/skill-creator/scripts/validate-skill-scaffold.sh path/to/skill-folder" >&2
  exit 2
fi

if [[ ! -d "$skill_dir" ]]; then
  echo "오류: 디렉터리를 찾을 수 없습니다: $skill_dir" >&2
  exit 2
fi

validate_with_python() {
  python3 - "$skill_dir" <<'PY'
import os
import re
import sys

skill_dir = sys.argv[1]

errors = []

def require_file(name: str):
  p = os.path.join(skill_dir, name)
  if not os.path.isfile(p):
    errors.append(f"필수 파일이 없습니다: {name}")
  return p

def require_non_empty_dir(name: str):
  p = os.path.join(skill_dir, name)
  if not os.path.isdir(p):
    errors.append(f"필수 디렉터리가 없습니다: {name}/")
    return
  entries = [e for e in os.listdir(p) if not e.startswith(".")]
  if len(entries) == 0:
    errors.append(f"필수 디렉터리가 비어 있습니다: {name}/")

skill_md_path = require_file("SKILL.md")
require_file("LICENSE.txt")
require_non_empty_dir("references")
require_non_empty_dir("scripts")

frontmatter = None
try:
  with open(skill_md_path, "r", encoding="utf-8") as f:
    content = f.read()
except Exception as e:
  errors.append(f"SKILL.md를 읽지 못했습니다: {e}")
  content = ""

m = re.match(r"^---\n([\s\S]*?)\n---\n", content)
if not m:
  errors.append("SKILL.md는 --- 로 구분된 YAML 프론트매터로 시작해야 합니다")
else:
  frontmatter = m.group(1)
  # IMPORTANT: avoid substring false-positives:
  # - "display-name:" contains "name:"
  # - "short-description:" contains "description:"
  # So we must match keys at beginning-of-line only.
  def has_key(key: str) -> bool:
    return re.search(rf"^{re.escape(key)}\s*", frontmatter, re.M) is not None

  required_keys = [
    "name:",
    "display-name:",
    "short-description:",
    "description:",
    "user-invocable:",
  ]
  for k in required_keys:
    if not has_key(k):
      errors.append(f"프론트매터에 키가 없습니다: {k.rstrip(':')}")

  name_match = re.search(r"^name:\s*(.+)$", frontmatter, re.M)
  if name_match:
    name = name_match.group(1).strip()
    if not name.startswith("notifly-"):
      errors.append("프론트매터 name은 'notifly-'로 시작해야 합니다")

  inv_match = re.search(r"^user-invocable:\s*(.+)$", frontmatter, re.M)
  if inv_match:
    val = inv_match.group(1).strip().lower()
    if val not in ("true", "false"):
      errors.append("프론트매터 user-invocable은 true 또는 false여야 합니다")

if "notifly-mcp-server" not in content:
  errors.append("SKILL.md에는 'notifly-mcp-server'를 참조해야 합니다(MCP-first 요구사항)")

if errors:
  print("오류: 스킬 스캐폴드 검증 실패:")
  for e in errors:
    print(f"- {e}")
  sys.exit(1)

print("OK: 스킬 스캐폴드 검증 통과")
PY
}

if command -v python3 >/dev/null 2>&1; then
  validate_with_python
  exit 0
fi

echo "경고: python3를 찾을 수 없어, 가능하면 node로 기본 검증을 수행합니다." >&2
if command -v node >/dev/null 2>&1; then
  node - "$skill_dir" <<'NODE'
const fs = require("fs");
const path = require("path");

const skillDir = process.argv[1];
const errors = [];

function hasFrontmatterKey(frontmatter, key) {
  // Match key at beginning of line only (avoid substring collisions):
  // - "display-name:" contains "name:"
  // - "short-description:" contains "description:"
  const re = new RegExp(`^${key.replace(/[.*+?^${}()|[\]\\]/g, "\\$&")}\\s*`, "m");
  return re.test(frontmatter);
}

function requireFile(name) {
  const p = path.join(skillDir, name);
  if (!fs.existsSync(p) || !fs.statSync(p).isFile()) errors.push(`필수 파일이 없습니다: ${name}`);
  return p;
}

function requireNonEmptyDir(name) {
  const p = path.join(skillDir, name);
  if (!fs.existsSync(p) || !fs.statSync(p).isDirectory()) {
    errors.push(`필수 디렉터리가 없습니다: ${name}/`);
    return;
  }
  const entries = fs.readdirSync(p).filter((e) => !e.startsWith("."));
  if (entries.length === 0) errors.push(`필수 디렉터리가 비어 있습니다: ${name}/`);
}

const skillMd = requireFile("SKILL.md");
requireFile("LICENSE.txt");
requireNonEmptyDir("references");
requireNonEmptyDir("scripts");

let content = "";
try {
  content = fs.readFileSync(skillMd, "utf8");
} catch (e) {
  errors.push(`SKILL.md를 읽지 못했습니다: ${String(e)}`);
}

// Frontmatter validation (best-effort; mirrors Python validator behavior).
if (!content.startsWith("---\n")) {
  errors.push("SKILL.md는 YAML 프론트매터(---)로 시작해야 합니다");
} else {
  const m = content.match(/^---\n([\s\S]*?)\n---\n/);
  if (!m) {
    errors.push("SKILL.md는 --- 로 구분된 YAML 프론트매터로 시작해야 합니다");
  } else {
    const frontmatter = m[1];
    const required = ["name:", "display-name:", "short-description:", "description:", "user-invocable:"];
    for (const k of required) {
      if (!hasFrontmatterKey(frontmatter, k)) {
        errors.push(`프론트매터에 키가 없습니다: ${k.replace(/:$/, "")}`);
      }
    }

    const nameMatch = frontmatter.match(/^name:\s*(.+)$/m);
    if (nameMatch) {
      const name = (nameMatch[1] || "").trim();
      if (!name.startsWith("notifly-")) errors.push("프론트매터 name은 'notifly-'로 시작해야 합니다");
    }

    const invMatch = frontmatter.match(/^user-invocable:\s*(.+)$/m);
    if (invMatch) {
      const val = (invMatch[1] || "").trim().toLowerCase();
      if (!["true", "false"].includes(val)) errors.push("프론트매터 user-invocable은 true 또는 false여야 합니다");
    }
  }
}
if (!content.includes("notifly-mcp-server"))
  errors.push("SKILL.md에는 'notifly-mcp-server'를 참조해야 합니다");

if (errors.length) {
  console.error("오류: 스킬 스캐폴드 검증 실패:");
  for (const e of errors) console.error(`- ${e}`);
  process.exit(1);
}

console.log("OK: 스킬 스캐폴드 검증 통과");
NODE
  exit 0
fi

echo "오류: python3 또는 node를 찾을 수 없어 검증을 수행할 수 없습니다." >&2
exit 2


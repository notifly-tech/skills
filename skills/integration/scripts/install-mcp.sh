#!/usr/bin/env bash
#
# Notifly MCP 서버 설치 스크립트
#
# 사용법:
#   bash scripts/install-mcp.sh
#

set -euo pipefail

BLUE='\033[34m'
GREEN='\033[32m'
RED='\033[31m'
YELLOW='\033[33m'
RESET='\033[0m'

log() {
  printf "%b\n" "$1"
}

log_err() {
  printf "%b\n" "$1" >&2
}

usage() {
  cat <<'EOF'
Notifly MCP 서버 설치 스크립트

사용법:
  bash scripts/install-mcp.sh [--client <client>]

옵션:
  --client <client>      설정할 MCP 클라이언트를 명시적으로 선택합니다.
                         지원: claude, claude-code, opencode, amp, codex, cursor, vscode, gemini
  --help                 이 도움말을 표시합니다.

환경 변수:
  NOTIFLY_MCP_CLIENT         --client와 동일(우선 적용).

참고:
  이 머신에서 MCP 클라이언트가 여러 개 감지되면, 반드시 --client를 전달해야 합니다
  (또는 NOTIFLY_MCP_CLIENT를 설정). 쉘 스크립트만으로는 여러 클라이언트가 설치된
  환경에서 "현재 실행 중인 클라이언트"를 신뢰성 있게 판별할 수 없습니다.
EOF
}

# 인자/환경 변수 파싱
CLIENT_OVERRIDE="${NOTIFLY_MCP_CLIENT:-}"
while [ $# -gt 0 ]; do
  case "$1" in
    --help|-h)
      usage
      exit 0
      ;;
    --client)
      shift
      CLIENT_OVERRIDE="${1:-}"
      ;;
    --client=*)
      CLIENT_OVERRIDE="${1#*=}"
      ;;
    *)
      log_err "${YELLOW}⚠️  알 수 없는 인자: $1${RESET}"
      usage
      exit 2
      ;;
  esac
  shift || true
done

validate_client() {
  case "${1:-}" in
    claude|claude-code|opencode|amp|codex|cursor|vscode|gemini) return 0 ;;
    "") return 1 ;;
    *) return 1 ;;
  esac
}

# 플랫폼 감지
detect_platform() {
  case "$(uname -s)" in
    Darwin*) echo "darwin" ;;
    Linux*) echo "linux" ;;
    MINGW*|MSYS*|CYGWIN*) echo "win32" ;;
    *) echo "unknown" ;;
  esac
}

# 클라이언트별 설정 파일 경로 조회
get_config_path() {
  local client=$1
  local home="${HOME:-$HOME}"
  local platform=$(detect_platform)

  case "$client" in
    claude-code)
      # Claude Code CLI는 `claude mcp ...` 명령으로 MCP를 관리합니다(직접 편집할 설정 파일 없음).
      echo ""
      ;;
    codex)
      echo "${home}/.codex/config.toml"
      ;;
    cursor)
      # 프로젝트 레벨 설정을 우선 확인
      if [ -f ".cursor/mcp.json" ]; then
        echo ".cursor/mcp.json"
      else
        echo "${home}/.cursor/mcp.json"
      fi
      ;;
    claude)
      # Claude Code 별칭
      echo ""
      ;;
    vscode)
      echo "${home}/.vscode/mcp.json"
      ;;
    gemini)
      # Gemini CLI stores MCP server configuration in `~/.gemini/settings.json` (user scope).
      echo "${home}/.gemini/settings.json"
      ;;
    amp)
      # Amp는 VS Code settings.json 포맷을 사용
      # 워크스페이스 설정을 우선 확인한 뒤, 유저 설정 확인
      if [ -f ".vscode/settings.json" ]; then
        echo ".vscode/settings.json"
      elif [ -f "${home}/.vscode/settings.json" ]; then
        echo "${home}/.vscode/settings.json"
      else
        # 기본값: 워크스페이스 설정
        echo ".vscode/settings.json"
      fi
      ;;
    opencode)
      # OpenCode는 프로젝트 루트의 opencode.json 또는 opencode.jsonc를 사용
      # .jsonc를 먼저 확인(권장)한 뒤, .json 확인
      if [ -f "opencode.jsonc" ]; then
        echo "opencode.jsonc"
      elif [ -f "opencode.json" ]; then
        echo "opencode.json"
      else
        # 기본값: .jsonc
        echo "opencode.jsonc"
      fi
      ;;
    *)
      echo ""
      ;;
  esac
}

# Claude Code CLI용 MCP 설정
configure_claude_code() {
  if ! command -v claude &> /dev/null; then
    log "${RED}❌ PATH에서 claude CLI를 찾을 수 없습니다.${RESET}"
    exit 1
  fi

  # 최선의 시도: 이미 설정되어 있다면 실패하지 않도록 합니다.
  # list가 지원되지 않으면 add를 그대로 시도합니다.
  if claude mcp list 2>/dev/null | grep -q "notifly-mcp-server"; then
    log "${GREEN}✔ Claude Code에 Notifly MCP 서버가 이미 설정되어 있습니다${RESET}"
    return 0
  fi

  # CLI로 설정(비대화형)
  claude mcp add --transport stdio notifly-mcp-server -- npx -y notifly-mcp-server@latest
  log "${GREEN}✔ Claude Code에 Notifly MCP 서버를 설정했습니다${RESET}"
}

# Codex용 MCP 설정(TOML 포맷)
configure_codex() {
  local config_path="$1"
  local config_dir=$(dirname "$config_path")

  mkdir -p "$config_dir"

  if [ ! -f "$config_path" ]; then
    cat > "$config_path" <<'EOF'
[mcp_servers]
EOF
    log "${GREEN}✔ Codex 설정 파일을 생성했습니다${RESET}"
  fi

  # 이미 설정되어 있는지 확인
  if grep -q "notifly-mcp-server" "$config_path" 2>/dev/null; then
    log "${GREEN}✔ Codex에 Notifly MCP 서버가 이미 설정되어 있습니다${RESET}"
    return 0
  fi

  # 사용자가 Codex를 다른 이름(예: "notifly")으로 설정해둔 경우,
  # 툴이 "notifly-mcp-server:*"가 아닌 "notifly:*"로 노출될 수 있습니다.
  # 올바른 서버 이름을 추가하되, 경고를 출력합니다.
  if grep -q "\[mcp_servers\.notifly\]" "$config_path" 2>/dev/null; then
    log "${YELLOW}⚠️  \"notifly\"라는 이름의 기존 Codex MCP 엔트리를 발견했습니다.${RESET}"
    log "${YELLOW}   이 경우 툴이 \"notifly:*\"로 노출될 수 있습니다(\"notifly-mcp-server:*\"가 아님).${RESET}"
    log "${YELLOW}   올바른 \"notifly-mcp-server\" 엔트리를 추가합니다.${RESET}"
  fi

  # 설정 추가
  if grep -q "\[mcp_servers\]" "$config_path"; then
    # 기존 [mcp_servers] 섹션에 추가
    cat >> "$config_path" <<'EOF'

  [mcp_servers."notifly-mcp-server"]
  command = "npx"
  args = ["-y", "notifly-mcp-server@latest"]
EOF
  else
    # 새 섹션 생성
    cat >> "$config_path" <<'EOF'
[mcp_servers]
  [mcp_servers."notifly-mcp-server"]
  command = "npx"
  args = ["-y", "notifly-mcp-server@latest"]
EOF
  fi

  log "${GREEN}✔ Codex 설정에 Notifly MCP 서버를 추가했습니다${RESET}"
}

# Amp용 MCP 설정( VS Code settings.json의 amp.mcpServers 사용 )
configure_amp() {
  local config_path="$1"
  local config_dir=$(dirname "$config_path")

  mkdir -p "$config_dir"

  if [ ! -f "$config_path" ]; then
    echo '{}' > "$config_path"
    log "${GREEN}✔ Amp 설정 파일을 생성했습니다${RESET}"
  fi

  # 이미 설정되어 있는지 확인
  if grep -q "notifly-mcp-server" "$config_path" 2>/dev/null; then
    log "${GREEN}✔ Amp에 Notifly MCP 서버가 이미 설정되어 있습니다${RESET}"
    return 0
  fi

  # node를 사용해 JSON/JSONC를 안전하게 갱신합니다(VS Code 설정은 주석을 허용하는 경우가 많음).
  if command -v node &> /dev/null; then
    node <<EOF
const fs = require('fs');
const path = '$config_path';
let config = {};
try {
  const content = fs.readFileSync(path, 'utf8');
  const stripJsonc = (input) => {
    // // 및 /* */ 주석을 제거하되, 문자열 내부 내용은 보존합니다.
    let out = '';
    let inStr = false;
    let esc = false;
    let inLine = false;
    let inBlock = false;
    for (let i = 0; i < input.length; i++) {
      const c = input[i];
      const n = input[i + 1];
      if (inLine) {
        if (c === '\n') {
          inLine = false;
          out += c;
        }
        continue;
      }
      if (inBlock) {
        if (c === '*' && n === '/') {
          inBlock = false;
          i++;
        }
        continue;
      }
      if (inStr) {
        out += c;
        if (esc) {
          esc = false;
        } else if (c === '\\\\') {
          esc = true;
        } else if (c === '"') {
          inStr = false;
        }
        continue;
      }
      if (c === '"') {
        inStr = true;
        out += c;
        continue;
      }
      if (c === '/' && n === '/') {
        inLine = true;
        i++;
        continue;
      }
      if (c === '/' && n === '*') {
        inBlock = true;
        i++;
        continue;
      }
      out += c;
    }
    return out;
  };
  config = JSON.parse(stripJsonc(content));
} catch (e) {
  config = {};
}
if (!config['amp.mcpServers']) config['amp.mcpServers'] = {};
config['amp.mcpServers']['notifly-mcp-server'] = {
  command: 'npx',
  args: ['-y', 'notifly-mcp-server@latest']
};
fs.writeFileSync(path, JSON.stringify(config, null, 2) + '\n');
EOF
    log "${GREEN}✔ Amp에 Notifly MCP 서버를 설정했습니다${RESET}"
  else
    log "${YELLOW}⚠️  Node.js를 찾을 수 없습니다. $config_path에 수동으로 추가하세요:${RESET}"
    log "${BLUE}{${RESET}"
    log "${BLUE}  \"amp.mcpServers\": {${RESET}"
    log "${BLUE}    \"notifly-mcp-server\": {${RESET}"
    log "${BLUE}      \"command\": \"npx\",${RESET}"
    log "${BLUE}      \"args\": [\"-y\", \"notifly-mcp-server@latest\"]${RESET}"
    log "${BLUE}    }${RESET}"
    log "${BLUE}  }${RESET}"
    log "${BLUE}}${RESET}"
  fi
}

# OpenCode용 MCP 설정(mcp 섹션이 있는 opencode.json/jsonc 사용)
configure_opencode() {
  local config_path="$1"

  if [ ! -f "$config_path" ]; then
    # 새 opencode.jsonc 파일 생성
    cat > "$config_path" <<'EOF'
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {}
}
EOF
    log "${GREEN}✔ OpenCode 설정 파일을 생성했습니다${RESET}"
  fi

  # 이미 설정되어 있는지 확인
  if grep -q "notifly-mcp-server" "$config_path" 2>/dev/null; then
    log "${GREEN}✔ OpenCode에 Notifly MCP 서버가 이미 설정되어 있습니다${RESET}"
    return 0
  fi

  # node를 사용해 JSON/JSONC를 안전하게 갱신
  if command -v node &> /dev/null; then
    node <<EOF
const fs = require('fs');
const path = '$config_path';
let content = fs.readFileSync(path, 'utf8');
const stripJsonc = (input) => {
  // // 및 /* */ 주석을 제거하되, 문자열 내부 내용은 보존합니다.
  let out = '';
  let inStr = false;
  let esc = false;
  let inLine = false;
  let inBlock = false;
  for (let i = 0; i < input.length; i++) {
    const c = input[i];
    const n = input[i + 1];
    if (inLine) {
      if (c === '\n') {
        inLine = false;
        out += c;
      }
      continue;
    }
    if (inBlock) {
      if (c === '*' && n === '/') {
        inBlock = false;
        i++;
      }
      continue;
    }
    if (inStr) {
      out += c;
      if (esc) {
        esc = false;
      } else if (c === '\\\\') {
        esc = true;
      } else if (c === '"') {
        inStr = false;
      }
      continue;
    }
    if (c === '"') {
      inStr = true;
      out += c;
      continue;
    }
    if (c === '/' && n === '/') {
      inLine = true;
      i++;
      continue;
    }
    if (c === '/' && n === '*') {
      inBlock = true;
      i++;
      continue;
    }
    out += c;
  }
  return out;
};
let config = {};
try {
  config = JSON.parse(stripJsonc(content));
} catch (e) {
  config = {};
}
if (!config.mcp) config.mcp = {};
config.mcp['notifly-mcp-server'] = {
  type: 'local',
  command: ['npx', '-y', 'notifly-mcp-server@latest'],
  enabled: true
};
fs.writeFileSync(path, JSON.stringify(config, null, 2) + '\n');
EOF
    log "${GREEN}✔ OpenCode에 Notifly MCP 서버를 설정했습니다${RESET}"
  else
    log "${YELLOW}⚠️  Node.js를 찾을 수 없습니다. $config_path에 수동으로 추가하세요:${RESET}"
    log "${BLUE}{${RESET}"
    log "${BLUE}  \"mcp\": {${RESET}"
    log "${BLUE}    \"notifly-mcp-server\": {${RESET}"
    log "${BLUE}      \"type\": \"local\",${RESET}"
    log "${BLUE}      \"command\": [\"npx\", \"-y\", \"notifly-mcp-server@latest\"],${RESET}"
    log "${BLUE}      \"enabled\": true${RESET}"
    log "${BLUE}    }${RESET}"
    log "${BLUE}  }${RESET}"
    log "${BLUE}}${RESET}"
  fi
}

# JSON 기반 클라이언트용 MCP 설정
configure_json_client() {
  local config_path="$1"
  local config_dir=$(dirname "$config_path")

  mkdir -p "$config_dir"

  if [ ! -f "$config_path" ]; then
    echo '{"mcpServers": {}}' > "$config_path"
    log "${GREEN}✔ 설정 파일을 생성했습니다${RESET}"
  fi

  # 이미 설정되어 있는지 확인
  if grep -q "notifly-mcp-server" "$config_path" 2>/dev/null; then
    log "${GREEN}✔ Notifly MCP 서버가 이미 설정되어 있습니다${RESET}"
    return 0
  fi

  # node를 사용해 JSON을 안전하게 갱신
  if command -v node &> /dev/null; then
    node <<EOF
const fs = require('fs');
const path = '$config_path';
const config = JSON.parse(fs.readFileSync(path, 'utf8'));
if (!config.mcpServers) config.mcpServers = {};
config.mcpServers['notifly-mcp-server'] = {
  command: 'npx',
  args: ['-y', 'notifly-mcp-server@latest']
};
fs.writeFileSync(path, JSON.stringify(config, null, 2) + '\n');
EOF
    log "${GREEN}✔ Notifly MCP 서버를 설정했습니다${RESET}"
  else
    log "${YELLOW}⚠️  Node.js를 찾을 수 없습니다. $config_path에 수동으로 추가하세요:${RESET}"
    log "${BLUE}{${RESET}"
    log "${BLUE}  \"mcpServers\": {${RESET}"
    log "${BLUE}    \"notifly-mcp-server\": {${RESET}"
    log "${BLUE}      \"command\": \"npx\",${RESET}"
    log "${BLUE}      \"args\": [\"-y\", \"notifly-mcp-server@latest\"]${RESET}"
    log "${BLUE}    }${RESET}"
    log "${BLUE}  }${RESET}"
    log "${BLUE}}${RESET}"
  fi
}

# 조건에 맞는 클라이언트를 모두 감지(휴리스틱). 한 줄에 하나씩 출력합니다.
detect_clients() {
  # Claude Code CLI (`claude mcp ...` 지원)
  if command -v claude &> /dev/null && claude mcp --help &> /dev/null; then
    echo "claude"
  fi

  # Gemini CLI (user scope config file or gemini command)
  if [ -f "${HOME}/.gemini/settings.json" ] || command -v gemini &> /dev/null; then
    echo "gemini"
  fi

  # OpenCode (프로젝트 설정 파일 또는 opencode 커맨드)
  if [ -f "opencode.json" ] || [ -f "opencode.jsonc" ] || command -v opencode &> /dev/null; then
    echo "opencode"
  fi

  # Amp (amp 커맨드 또는 amp.mcpServers 설정 존재)
  if command -v amp &> /dev/null || \
     grep -q "amp.mcpServers" ".vscode/settings.json" 2>/dev/null || \
     grep -q "amp.mcpServers" "${HOME}/.vscode/settings.json" 2>/dev/null; then
    echo "amp"
  fi

  # Codex
  if [ -f "${HOME}/.codex/config.toml" ] || command -v codex &> /dev/null; then
    echo "codex"
  fi

  # Cursor
  if [ -f "${HOME}/.cursor/mcp.json" ] || [ -f ".cursor/mcp.json" ]; then
    echo "cursor"
  fi

  # VS Code
  if [ -f "${HOME}/.vscode/mcp.json" ]; then
    echo "vscode"
  fi
}

choose_client() {
  if [ -n "${CLIENT_OVERRIDE:-}" ]; then
    if ! validate_client "$CLIENT_OVERRIDE"; then
      log_err "${RED}❌ 잘못된 --client / NOTIFLY_MCP_CLIENT: ${CLIENT_OVERRIDE}${RESET}"
      usage
      exit 2
    fi
    if [ "$CLIENT_OVERRIDE" = "claude-code" ]; then
      echo "claude"
      return
    fi
    echo "$CLIENT_OVERRIDE"
    return
  fi

  local detected
  detected="$(detect_clients | awk 'NF' | sort -u)"
  local count
  count="$(printf "%s\n" "$detected" | awk 'NF' | wc -l | tr -d ' ')"

  if [ "${count:-0}" -eq 0 ]; then
    echo "unknown"
    return
  fi

  if [ "${count:-0}" -eq 1 ]; then
    printf "%s\n" "$detected"
    return
  fi

  # 여러 개가 감지되면, 어떤 클라이언트가 "현재 실행 중"인지 알 수 없습니다.
  log_err "${YELLOW}⚠️  이 머신에서 여러 MCP 클라이언트가 감지되었습니다:${RESET}"
  printf "%s\n" "$detected" | sed 's/^/  - /' >&2

  if [ -t 0 ]; then
    log_err "${BLUE}설정할 클라이언트를 선택하세요:${RESET}"
    local options=()
    while IFS= read -r line; do options+=("$line"); done <<<"$detected"
    options+=("cancel")
    select opt in "${options[@]}"; do
      if [ "$opt" = "cancel" ] || [ -z "${opt:-}" ]; then
        log_err "${YELLOW}취소했습니다.${RESET}"
        exit 2
      fi
      echo "$opt"
      return
    done
  fi

  log_err "${RED}❌ 비대화형 모드에서는 MCP 클라이언트를 자동으로 결정할 수 없습니다.${RESET}"
  log_err "${YELLOW}다음과 같이 다시 실행하세요: bash scripts/install-mcp.sh --client <client>${RESET}"
  exit 2
}

log "${BLUE}🧩 Notifly MCP 서버 설정을 진행합니다...${RESET}"

# 이 스크립트는 "설치"라기보다는, MCP 클라이언트 설정 파일에
# `npx -y notifly-mcp-server@latest` 실행 구성을 추가합니다.
# (따라서 여기서 npm 레지스트리 접근/패키지 조회를 강제하지 않습니다.)
if ! command -v npx &> /dev/null && ! command -v npm &> /dev/null; then
  log "${YELLOW}⚠️  npx/npm을 찾을 수 없습니다. 실행 시 Node.js가 필요할 수 있습니다.${RESET}"
  log "${YELLOW}   필요하면 Node.js를 설치하세요: https://nodejs.org/${RESET}"
fi

# 자동 감지 후 설정
log "${BLUE}🔍 MCP 클라이언트를 감지합니다...${RESET}"
detected_client=$(choose_client)

if [ "$detected_client" != "unknown" ]; then
  log "${GREEN}감지됨: ${detected_client}${RESET}"
  config_path=$(get_config_path "$detected_client")

  if [ "$detected_client" = "claude" ]; then
    log "${BLUE}Claude Code용 MCP 서버를 설정합니다...${RESET}"
    configure_claude_code
    log "${GREEN}✅ Notifly MCP 서버 설정이 완료되었습니다!${RESET}"
    log "${YELLOW}⚠️  중요: 변경 사항을 적용하려면 Claude Code를 재시작하세요.${RESET}"
  elif [ -n "$config_path" ]; then
    log "${BLUE}${detected_client}용 MCP 서버를 설정합니다...${RESET}"

    if [ "$detected_client" = "codex" ]; then
      configure_codex "$config_path"
    elif [ "$detected_client" = "amp" ]; then
      configure_amp "$config_path"
    elif [ "$detected_client" = "opencode" ]; then
      configure_opencode "$config_path"
    else
      configure_json_client "$config_path"
    fi

    log "${GREEN}✅ Notifly MCP 서버 설정이 완료되었습니다!${RESET}"
    log "${YELLOW}⚠️  중요: 변경 사항을 적용하려면 ${detected_client}를 재시작하세요.${RESET}"
  else
    log "${YELLOW}⚠️  ${detected_client}의 설정 파일 경로를 결정할 수 없습니다${RESET}"
    log "${YELLOW}수동으로 설정하세요. 안내는 references/mcp-integration.md를 참고하세요.${RESET}"
  fi
else
  log "${YELLOW}⚠️  MCP 클라이언트를 자동으로 감지하지 못했습니다.${RESET}"
  log "${BLUE}패키지는 사용할 준비가 되었습니다. 아래 중 해당하는 설정 파일에 수동으로 추가하세요:${RESET}"
  log "${BLUE}  - OpenCode: opencode.json 또는 opencode.jsonc에 추가${RESET}"
  log "${BLUE}  - Amp: .vscode/settings.json 또는 ~/.vscode/settings.json에 추가${RESET}"
  log "${BLUE}  - Codex: ~/.codex/config.toml에 추가${RESET}"
  log "${BLUE}  - Cursor: .cursor/mcp.json 또는 ~/.cursor/mcp.json에 추가${RESET}"
  log "${BLUE}  - Gemini CLI: ~/.gemini/settings.json에 추가${RESET}"
  log "${BLUE}  - Claude Code: 실행: claude mcp add --transport stdio notifly-mcp-server -- npx -y notifly-mcp-server@latest${RESET}"
  log "${BLUE}자세한 안내는 references/mcp-integration.md를 참고하세요.${RESET}"
fi

log "${GREEN}✅ 설정이 완료되었습니다!${RESET}"

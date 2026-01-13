#!/usr/bin/env bash
#
# 생성된 스킬 폴더가 올바른 "skills" 디렉터리에 위치하는지 검증합니다.
#
# 사용법:
#   bash skills/skill-creator/scripts/validate-skill-location.sh <skill-folder> [--mode repo|client] [--client <name>]
#
# 모드(Modes):
# - repo  : 스킬 폴더가 다음 경로 아래에 있어야 합니다: skills/<skill-folder-name>/
# - client: 스킬 폴더가 클라이언트의 skills 디렉터리 아래에 있어야 합니다:
#           (.*)/skills/<skill-folder-name>/  또는  (.*)/skill/<skill-folder-name>/ (OpenCode)
#
# client 모드에서 --client가 주어지면, 경로에 예상되는 클라이언트 디렉터리 세그먼트가
# 포함되는지도 추가로 검사합니다(베스트 에포트).
#
set -euo pipefail

skill_dir="${1:-}"
mode="repo"
client=""

shift || true
while [[ "${1:-}" != "" ]]; do
  case "$1" in
    --mode)
      if [[ -z "${2:-}" || "${2:-}" == "-"* ]]; then
        echo "오류: --mode는 값을 필요로 합니다" >&2
        exit 2
      fi
      mode="${2:-}"
      shift 2
      ;;
    --client)
      if [[ -z "${2:-}" || "${2:-}" == "-"* ]]; then
        echo "오류: --client는 값을 필요로 합니다" >&2
        exit 2
      fi
      client="${2:-}"
      shift 2
      ;;
    -h|--help)
      cat <<'EOF'
스킬 폴더 위치를 검증합니다.

사용법:
  bash skills/skill-creator/scripts/validate-skill-location.sh <skill-folder> [--mode repo|client] [--client <name>]

예시:
  bash skills/skill-creator/scripts/validate-skill-location.sh skills/personalization --mode repo
  bash skills/skill-creator/scripts/validate-skill-location.sh .cursor/skills/personalization --mode client --client cursor
EOF
      exit 0
      ;;
    *)
      echo "알 수 없는 인자: $1" >&2
      exit 2
      ;;
  esac
done

if [[ -z "$skill_dir" ]]; then
  echo "오류: <skill-folder> 인자가 필요합니다" >&2
  exit 2
fi

if [[ ! -d "$skill_dir" ]]; then
  echo "오류: 디렉터리를 찾을 수 없습니다: $skill_dir" >&2
  exit 2
fi

skills_parent="$(basename "$(dirname "$skill_dir")")"

case "$mode" in
  repo)
    if [[ "$skills_parent" != "skills" ]]; then
      echo "오류: 잘못된 위치입니다. 스킬 폴더는 'skills/<name>/' 아래에 있어야 하지만 부모 디렉터리가 '$skills_parent'입니다." >&2
      echo "   경로: $skill_dir" >&2
      exit 1
    fi
    ;;
  client)
    # Client installs usually use "skills/" (most clients), "skill/" (OpenCode),
    # or ".skills/" (Letta).
    if [[ "$skills_parent" != "skills" && "$skills_parent" != "skill" && "$skills_parent" != ".skills" ]]; then
      echo "오류: 잘못된 위치입니다. 스킬 폴더는 '<client>/(skills|skill|.skills)/<name>/' 아래에 있어야 하지만 부모 디렉터리가 '$skills_parent'입니다." >&2
      echo "   경로: $skill_dir" >&2
      exit 1
    fi

    if [[ -n "$client" ]]; then
      # Best-effort path segment checks (not exhaustive, but catches common mistakes).
      case "${client,,}" in
        cursor)
          [[ "$skill_dir" == *"/.cursor/skills/"* || "$skill_dir" == ".cursor/skills/"* ]] || {
            echo "오류: Cursor 스킬 경로에는 '.cursor/skills/'가 포함되어야 합니다" >&2
            echo "   경로: $skill_dir" >&2
            exit 1
          }
          ;;
        claude|claude-code)
          [[ "$skill_dir" == *"/.claude/skills/"* || "$skill_dir" == ".claude/skills/"* ]] || {
            echo "오류: Claude 스킬 경로에는 '.claude/skills/'가 포함되어야 합니다" >&2
            echo "   경로: $skill_dir" >&2
            exit 1
          }
          ;;
        codex)
          [[ "$skill_dir" == *"/.codex/skills/"* || "$skill_dir" == ".codex/skills/"* ]] || {
            echo "오류: Codex 스킬 경로에는 '.codex/skills/'가 포함되어야 합니다" >&2
            echo "   경로: $skill_dir" >&2
            exit 1
          }
          ;;
        opencode)
          [[ "$skill_dir" == *"/.opencode/skill/"* || "$skill_dir" == ".opencode/skill/"* ]] || {
            echo "오류: OpenCode 스킬 경로에는 '.opencode/skill/'가 포함되어야 합니다" >&2
            echo "   경로: $skill_dir" >&2
            exit 1
          }
          # OpenCode uses singular "skill", reject "skills" for this client.
          [[ "$skill_dir" != *"/.opencode/skills/"* && "$skill_dir" != ".opencode/skills/"* ]] || {
            echo "오류: OpenCode는 '.opencode/skill/'(단수)을 사용합니다. '.opencode/skills/'가 아니어야 합니다" >&2
            echo "   경로: $skill_dir" >&2
            exit 1
          }
          ;;
        vscode)
          [[ "$skill_dir" == *"/.vscode/skills/"* || "$skill_dir" == ".vscode/skills/"* ]] || {
            echo "오류: VS Code 스킬 경로에는 '.vscode/skills/'가 포함되어야 합니다" >&2
            echo "   경로: $skill_dir" >&2
            exit 1
          }
          ;;
        amp)
          # Amp는 워크스페이스에서는 `.agents/skills/`, 전역(global)에서는 `~/.config/agents/skills/`를 사용합니다.
          # 여기서는 클라이언트 스킬 디렉터리 검증을 위해 `.agents/skills/` 세그먼트만 확인합니다.
          [[ "$skill_dir" == *"/.agents/skills/"* || "$skill_dir" == ".agents/skills/"* ]] || {
            echo "오류: Amp 스킬 경로에는 '.agents/skills/'가 포함되어야 합니다" >&2
            echo "   경로: $skill_dir" >&2
            exit 1
          }
          ;;
        goose)
          # Goose는 goose 전용 경로와 포터블 경로를 모두 지원합니다.
          [[
            "$skill_dir" == *"/.goose/skills/"* ||
            "$skill_dir" == ".goose/skills/"* ||
            "$skill_dir" == *"/.agents/skills/"* ||
            "$skill_dir" == ".agents/skills/"*
          ]] || {
            echo "오류: Goose 스킬 경로에는 '.goose/skills/' 또는 '.agents/skills/'가 포함되어야 합니다" >&2
            echo "   경로: $skill_dir" >&2
            exit 1
          }
          ;;
        github|copilot)
          [[ "$skill_dir" == *"/.github/skills/"* || "$skill_dir" == ".github/skills/"* ]] || {
            echo "오류: GitHub Copilot 스킬 경로에는 '.github/skills/'가 포함되어야 합니다" >&2
            echo "   경로: $skill_dir" >&2
            exit 1
          }
          ;;
        gemini)
          [[ "$skill_dir" == *"/.gemini/skills/"* || "$skill_dir" == ".gemini/skills/"* ]] || {
            echo "오류: Gemini 스킬 경로에는 '.gemini/skills/'가 포함되어야 합니다" >&2
            echo "   경로: $skill_dir" >&2
            exit 1
          }
          ;;
        kiro)
          [[ "$skill_dir" == *"/.kiro/skills/"* || "$skill_dir" == ".kiro/skills/"* ]] || {
            echo "오류: Kiro 스킬 경로에는 '.kiro/skills/'가 포함되어야 합니다" >&2
            echo "   경로: $skill_dir" >&2
            exit 1
          }
          ;;
        amazonq)
          [[ "$skill_dir" == *"/.amazonq/skills/"* || "$skill_dir" == ".amazonq/skills/"* ]] || {
            echo "오류: AmazonQ 스킬 경로에는 '.amazonq/skills/'가 포함되어야 합니다" >&2
            echo "   경로: $skill_dir" >&2
            exit 1
          }
          ;;
        letta)
          # Letta uses a root-level `.skills/` directory.
          [[ "$skill_dir" == *"/.skills/"* || "$skill_dir" == ".skills/"* ]] || {
            echo "오류: Letta 스킬 경로에는 '.skills/'가 포함되어야 합니다" >&2
            echo "   경로: $skill_dir" >&2
            exit 1
          }
          ;;
        *)
          # Unknown client; skip strict segment check.
          ;;
      esac
    fi
    ;;
  *)
    echo "오류: --mode는 'repo' 또는 'client'여야 합니다(현재: '$mode')" >&2
    exit 2
    ;;
esac

echo "OK: 스킬 위치가 정상입니다 ($mode)"


#!/usr/bin/env bash
#
# 새로 생성된 스킬이 이 스킬과 동일한 스코프에 설치되었는지 검증합니다:
# 설치된 `skill-creator`와 동일한 상위 "skills" 디렉터리 아래에 있어야 합니다.
#
# 근거:
# - `skill-creator`가 프로젝트 레벨(예: .cursor/skills/skill-creator)에 설치되었다면,
#   생성된 스킬도 프로젝트 레벨(예: .cursor/skills/<new-skill>)이어야 합니다.
# - `skill-creator`가 사용자/전역 레벨(예: ~/.cursor/skills/skill-creator)에 설치되었다면,
#   생성된 스킬도 사용자/전역 레벨(예: ~/.cursor/skills/<new-skill>)이어야 합니다.
#
# 사용법:
#   bash skills/skill-creator/scripts/validate-same-scope.sh <skill-creator-dir> <new-skill-dir>
#
set -euo pipefail

creator_dir="${1:-}"
new_skill_dir="${2:-}"

if [[ -z "$creator_dir" || -z "$new_skill_dir" ]]; then
  echo "사용법: bash skills/skill-creator/scripts/validate-same-scope.sh <skill-creator-dir> <new-skill-dir>" >&2
  exit 2
fi

if [[ ! -d "$creator_dir" ]]; then
  echo "오류: skill-creator 디렉터리를 찾을 수 없습니다: $creator_dir" >&2
  exit 2
fi

if [[ ! -d "$new_skill_dir" ]]; then
  echo "오류: 새 스킬 디렉터리를 찾을 수 없습니다: $new_skill_dir" >&2
  exit 2
fi

creator_parent="$(dirname "$creator_dir")"
new_parent="$(dirname "$new_skill_dir")"

creator_parent_base="$(basename "$creator_parent")"
new_parent_base="$(basename "$new_parent")"

if [[ "$creator_parent_base" != "skills" && "$creator_parent_base" != "skill" && "$creator_parent_base" != ".skills" ]]; then
  echo "오류: skill-creator는 skills 디렉터리 아래에 있어야 합니다 (skills/ 또는 skill/ 또는 .skills/)." >&2
  echo "  creator_dir: $creator_dir" >&2
  exit 1
fi

if [[ "$new_parent_base" != "skills" && "$new_parent_base" != "skill" && "$new_parent_base" != ".skills" ]]; then
  echo "오류: 새 스킬은 skills 디렉터리 아래에 있어야 합니다 (skills/ 또는 skill/ 또는 .skills/)." >&2
  echo "  new_skill_dir: $new_skill_dir" >&2
  exit 1
fi

if [[ "$creator_parent" != "$new_parent" ]]; then
  echo "오류: 스코프 불일치. 새 스킬은 동일한 skills 디렉터리에서 skill-creator 옆에 설치되어야 합니다." >&2
  echo "  skill_creator_parent: $creator_parent" >&2
  echo "  new_skill_parent:     $new_parent" >&2
  exit 1
fi

echo "OK: 스킬 스코프가 일치합니다(동일한 상위 skills 디렉터리)"


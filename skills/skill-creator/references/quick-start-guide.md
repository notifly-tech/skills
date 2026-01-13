# Quick Start: Creating Your First Notifly Skill

이 가이드는 `notifly-skill-creator`를 사용해 새 Notifly 스킬을 처음부터 만드는
전체 과정을 안내합니다.

## Prerequisites

시작하기 전에 다음을 확인하세요:

1. `notifly-skill-creator` 스킬이 설치되어 있어야 합니다:

   ```bash
   npx notifly-agent-skills@latest install skill-creator --client cursor
   ```

2. (선택) Notifly MCP Server가 설치되어 있으면 더 좋습니다:
   ```bash
   bash skills/integration/scripts/install-mcp.sh
   ```

## Step 1: 스킬 아이디어 정의

새 스킬을 만들기 전에 다음 질문에 답하세요:

- **목표(Goal)**: 이 스킬이 항상 만들어내야 하는 결과는?
- **대상(Audience)**: 앱 개발자? 백엔드 개발자? 마케터?
- **플랫폼(Platform)**: iOS, Android, Flutter, React Native, Web?
- **Notifly 기능(Feature)**: 푸시, 인앱, 이벤트 트래킹, 유저 관리?
- **성공 기준(Success)**: "완료"는 어떤 상태인가?

**예시**: "iOS 앱에 푸시 알림을 통합하는 개발자를 돕는 스킬"

## Step 2: 기존 스킬 확인

먼저, 기존 스킬로 해결할 수 있는지 확인하세요:

```bash
# 현재 사용 가능한 스킬 목록 확인
ls skills/
```

현재 포함된 스킬:

- `integration`: SDK 통합 (푸시 알림 설정 포함)
- `skill-creator`: 새 스킬 생성

**중요**: 기존 스킬을 약간 확장하는 것으로 충분하다면, 새 스킬을 만들지 마세요!

## Step 3: MCP로 조사하기

`notifly-mcp-server`를 사용해 근거를 수집하세요:

### 문서 조사

```
Claude에게 요청:
"notifly-mcp-server:search_docs를 사용해 푸시 알림 초기화에 대한 문서를 찾아줘"
```

### SDK 시그니처 조사

```
Claude에게 요청:
"notifly-mcp-server:search_sdk를 사용해 iOS에서 setPushToken 메서드의 정확한 시그니처를 찾아줘"
```

**중요**: SDK 메서드나 API 엔드포인트를 절대 추측하지 마세요!

## Step 4: Skill Brief 작성

조사 결과를 바탕으로 Skill Brief를 작성하세요:

```yaml
skill:
  folder_name: "push-integration"
  name: "notifly-push-integration"
  display_name: "Push Integration"
  short_description: "iOS/Android 푸시 알림 통합"
  description: >
    개발자가 iOS와 Android 앱에 Notifly 푸시 알림을 통합하도록 돕습니다. MCP를
    통해 최신 SDK 시그니처를 확인합니다.
  user_invocable: true

triggers:
  - "푸시 알림을 설정하고 싶어요"
  - "iOS에 푸시 통합해줘"

inputs:
  - "플랫폼 (iOS/Android)"
  - "프로젝트 경로"

outputs:
  - "초기화 코드"
  - "통합 체크리스트"

guardrails:
  - "MCP-first: SDK 시그니처는 notifly-mcp-server에서만 가져오기"
  - "시크릿 금지: API 키는 환경변수 사용"

files_to_generate:
  skill_md: true
  references:
    - "ios-setup.md"
    - "android-setup.md"
  scripts:
    - "validate-integration.sh"
  examples:
    - "sample-ios-code.swift"
```

## Step 5: 스킬 폴더 생성

Brief를 승인받았다면, 스킬 폴더를 생성하세요:

```bash
# 스킬 디렉터리 생성
mkdir -p skills/push-integration/{references,scripts,examples}

# 필수 파일 생성
touch skills/push-integration/SKILL.md
touch skills/push-integration/LICENSE.txt
```

## Step 6: SKILL.md 작성

`references/skill-template.md`를 참고해 SKILL.md를 작성하세요:

```markdown
---
name: notifly-push-integration
display-name: Push Integration
short-description: iOS/Android 푸시 알림 통합
description:
  개발자가 iOS와 Android 앱에 Notifly 푸시 알림을 통합하도록 돕습니다. MCP를
  통해 최신 SDK 시그니처를 확인합니다.
user-invocable: true
---

# Push Integration

## MCP-first (단일 진실원)

이 스킬은 `notifly-mcp-server`를 단일 진실원으로 사용합니다:

- `notifly-mcp-server:search_docs`: 푸시 개념/제약 확인
- `notifly-mcp-server:search_sdk`: iOS/Android SDK 시그니처 확인

...
```

## Step 7: References 추가

조사한 내용을 references/ 디렉터리에 저장하세요:

```bash
# iOS 설정 문서
cat > skills/push-integration/references/ios-setup.md <<EOF
# iOS Push Setup

## MCP 조사 결과

### 검색 쿼리
- \`notifly-mcp-server:search_sdk "setPushToken iOS"\`

### 시그니처
\`\`\`swift
Notifly.setPushToken(_ token: Data)
\`\`\`

...
EOF
```

## Step 8: 검증 스크립트 추가

스킬 산출물을 검증하는 스크립트를 추가하세요:

```bash
cat > skills/push-integration/scripts/validate-integration.sh <<'BASH'
#!/usr/bin/env bash
set -euo pipefail

# 통합 코드 검증 로직
echo "Validating push integration..."

# 여기에 검증 로직 추가
# - 필수 파일 존재 확인
# - 초기화 코드 구문 체크
# - etc.

echo "OK: Integration validated"
BASH

chmod +x skills/push-integration/scripts/validate-integration.sh
```

## Step 9: 라이센스 추가

```bash
echo "Apache-2.0" > skills/push-integration/LICENSE.txt
```

## Step 10: 스킬 검증

생성한 스킬을 검증하세요:

```bash
# 스캐폴드 검증
bash skills/skill-creator/scripts/validate-skill-scaffold.sh skills/push-integration

# 위치 검증
bash skills/skill-creator/scripts/validate-skill-location.sh skills/push-integration --mode repo

# 스코프 검증 (skill-creator와 같은 디렉터리에 있는지)
bash skills/skill-creator/scripts/validate-same-scope.sh skills/skill-creator skills/push-integration
```

모든 검증이 통과하면:

```
OK: 스킬 스캐폴드 검증 통과
OK: 스킬 위치가 정상입니다 (repo)
OK: 스킬 스코프가 일치합니다
```

## Step 11: 레포에 통합

### README 업데이트

`README.md`와 `README.en.md`에 새 스킬을 추가하세요:

```markdown
- **notifly-push-integration**: iOS와 Android 앱에 푸시 알림을 통합합니다.
```

### llms.txt 업데이트

```bash
# llms.txt에 스킬 인덱스 추가
cat >> llms.txt <<EOF

## notifly-push-integration

- [notifly-push-integration](https://raw.githubusercontent.com/notifly-tech/skills/refs/heads/main/skills/push-integration/SKILL.md): Main skill documentation

### References

- [iOS Setup (Reference)](https://raw.githubusercontent.com/notifly-tech/skills/refs/heads/main/skills/push-integration/references/ios-setup.md): Reference documentation
- [Android Setup (Reference)](https://raw.githubusercontent.com/notifly-tech/skills/refs/heads/main/skills/push-integration/references/android-setup.md): Reference documentation

### Scripts

- [Validate Integration (Script)](https://raw.githubusercontent.com/notifly-tech/skills/refs/heads/main/skills/push-integration/scripts/validate-integration.sh): Validation script

---
EOF
```

### 테스트 추가 (선택)

```typescript
// tests/push-integration.test.ts
describe("notifly-push-integration", () => {
  it("validates iOS integration plan", () => {
    // 테스트 로직
  });
});
```

## Step 12: 커밋 및 PR

```bash
# 변경사항 확인
git status

# 스킬 추가
git add skills/push-integration/
git add README.md README.en.md llms.txt

# 커밋
git commit -m "feat: add notifly-push-integration skill

- iOS and Android push notification integration
- MCP-first SDK signature verification
- Validation scripts for integration plans

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

## 체크리스트

생성 전:

- [ ] 기존 스킬로 해결할 수 없는 니즈인가?
- [ ] MCP로 충분한 근거를 수집했는가?
- [ ] Skill Brief를 작성하고 승인받았는가?

생성 후:

- [ ] SKILL.md에 YAML 프론트매터가 있는가?
- [ ] name이 `notifly-`로 시작하는가?
- [ ] `notifly-mcp-server`를 언급하는가?
- [ ] references/ 디렉터리가 비어있지 않은가?
- [ ] scripts/ 디렉터리가 비어있지 않은가?
- [ ] LICENSE.txt가 있는가?
- [ ] 모든 검증 스크립트가 통과하는가?
- [ ] README와 llms.txt가 업데이트되었는가?

## 문제 해결

### "프론트매터에 키가 없습니다"

SKILL.md의 YAML 프론트매터에 필수 키를 추가하세요:

- `name:`
- `display-name:`
- `short-description:`
- `description:`
- `user-invocable:`

### "필수 디렉터리가 비어 있습니다"

references/ 또는 scripts/ 디렉터리에 최소 1개 파일을 추가하세요.

### "스킬 위치가 잘못되었습니다"

스킬 폴더는 반드시 `skills/<skill-name>/` 경로에 있어야 합니다.

## 다음 단계

스킬 생성이 완료되면:

1. **실제로 사용해보기**: 스킬을 설치하고 실제 프로젝트에서 테스트
2. **피드백 수집**: 사용자 피드백을 받아 개선
3. **문서 개선**: references/에 더 많은 예시와 가이드 추가
4. **테스트 추가**: 더 많은 엣지 케이스 커버

## 참고 자료

- `references/skill-template.md`: 스킬 템플릿
- `references/mcp-research-playbook.md`: MCP 조사 방법
- `examples/skill-brief-example.yaml`: Skill Brief 예시
- 기존 스킬: `skills/integration/SKILL.md`

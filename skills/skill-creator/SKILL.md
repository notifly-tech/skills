---
name: notifly-skill-creator
display-name: Skill Creator
short-description: 새로운 Notifly 에이전트 스킬 생성
description: Notifly MCP Server로 최신 Notifly SDK + 문서를 먼저 조사한 뒤, 이 레포의 컨벤션에 맞는
  완전한 스킬 폴더(SKILL.md, references, scripts, examples)를 생성하도록 돕습니다. 사용자가 새로운
  Notifly 스킬을 만들거나/작성하거나, 스킬 라이브러리를 확장하고자 하거나, `notifly-skill-creator`를
  입력했을 때 사용하세요.
user-invocable: true
---

# Notifly Skill Creator

이 스킬은 사용자의 니즈에 맞는 **새로운 Notifly 스킬**을 만들 때 사용합니다. 기존 스킬과의 스코프
중복을 피하고, Notifly MCP 서버를 **단일 진실원(source of truth)** 으로 삼아 **환각(hallucination)으로
잘못된 API를 쓰는 것**을 방지하는 데 초점을 둡니다.

이 스킬은 “메타 스킬”입니다. SDK를 직접 연동하는 스킬이 아니라, **다른 스킬 폴더**(문서 + 결정적 스크립트)를
만들도록 가이드합니다.

## 언제 이 스킬을 쓰나

- 사용자가 말함: “Notifly에서 X를 도와주는 새 스킬을 만들어줘”
- 내부 요청: “Notifly의 기능 X를 위한 새 스킬이 필요해”
- 기존 스킬로 잘 커버되지 않는 워크플로우가 주어짐
- 사용자가 입력: `notifly-skill-creator`

## 비목표(중요)

- 기존 스킬을 조합하면 해결되는 요청이라면 **새 스킬을 만들지 마세요**  
  (우선 `notifly-integration`을 확인하고, 그 다음 이 레포에 존재하는 다른 스킬들도 확인).
- SDK 메서드/엔드포인트/제약을 **발명하지 마세요**. MCP로 확인할 수 없으면 “미확인”으로 취급하고,
  사용자에게 질문하거나 TODO로 남기세요.
- 스킬에 시크릿/프로젝트 ID/API 키/고객 데이터를 **절대 포함하지 마세요**.

## MCP 우선(필수: 단일 진실원)

새로 생성하는 스킬에 “Notifly API 동작”이나 “SDK 시그니처”를 적기 전에 반드시:

- 개념/제약/콘솔 의미 확인: `notifly-mcp-server:search_docs` **필수**
- 언급할 플랫폼(iOS/Android/Flutter/React Native)별 정확한 메서드 시그니처 확인:
  `notifly-mcp-server:search_sdk` **필수**

만약 `notifly-mcp-server` 도구가 없다면:

- MCP 서버 설치를 먼저 제안하세요(가능하면 `skills/integration/scripts/install-mcp.sh` 설치 스크립트 사용).
- 사용자가 거절하면, “정적 자료는 오래되었을 수 있다”는 경고를 명시하고 단정적인 표현을 최소화하세요.

## 워크플로우(복사해서 체크)

```
Notifly 스킬 생성 진행 상황:
- [ ] 1) 인테이크: 사용자 니즈 → 명확한 문제 정의 + 수용 기준(acceptance criteria)
- [ ] 2) 스코프 확인: 기존 스킬로 이미 커버되는지 검증
- [ ] 3) MCP 조사: 대상 스코프에 대한 근거 수집(문서 + SDK 시그니처)
- [ ] 4) Skill Brief 초안 작성(이름, 트리거 문구, 입력/출력, 가드레일)
- [ ] 5) 스캐폴드 생성(SKILL.md + references/ + scripts/ + examples/)
- [ ] 6) 스캐폴드 검증(구조 + 프론트매터 + MCP-first 섹션)
- [ ] 7) 연결 작업(README + llms 인덱스 + 필요 시 테스트)
```

## 1) 인테이크: 최소 질문

안정적인 스킬 경계를 정의하는 데 필요한 것만 묻습니다:

- **목표**: 이 스킬이 “항상” 만들어내야 하는 결과는 무엇인가?
- **대상**: 앱 개발자 / 백엔드 개발자 / 마케터·운영 / 혼합?
- **플랫폼**(SDK 관련 시): iOS / Android / Flutter / React Native
- **Notifly 기능**: 푸시 / 인앱(팝업) / 이메일 / 오디언스 / 유저 여정 / 등
- **제약**: PII 정책, 컴플라이언스, 성능 제한, 레이트 리밋
- **성공 기준**: “완료”는 어떤 상태인가?

## 2) 공식 스킬 참고(레포 스타일 매칭)

새 스킬을 만들기 전에, 이 레포에 있는 **공식 Notifly 스킬**을 스타일 가이드로 삼아
생성될 스킬이 이 레포의 표준(포맷, 톤, 워크플로우, 밸리데이터)을 따르도록 하세요.
동시에 사용자의 니즈에 맞게 맞춤화되어야 합니다.

- 작성 방식에서 확인할 것:
  - YAML 프론트매터 컨벤션
  - MCP-first “단일 진실원” 동작
  - 점진적 공개(Progressive Disclosure: `references/`, `scripts/`, `examples/`)
  - 플랜 산출물 + 결정적(재현 가능한) 밸리데이터(쉘 스크립트)
- 그 다음, 같은 패턴을 이용해 사용자의 니즈에 맞는 새 스킬을 생성하세요.
  니즈가 “기존 스킬에 아주 작은 추가”로 보이면 새 스킬을 만들기보다,
  그 스킬의 `references/` 문서나 `examples/` 파일을 추가하는 쪽을 우선 고려하세요.

- `notifly-integration`

## 3) MCP 조사: “Evidence Pack” 만들기

새 스킬을 작성할 때 근거로 인용할 짧은 Evidence Pack을 만드세요:

- **문서 근거**(`notifly-mcp-server:search_docs`에서)
  - 동작 보장(behavior guarantees)
  - 제약/한도(constraints/limits)
  - 콘솔 용어/동작(console terminology)
- **SDK 근거**(`notifly-mcp-server:search_sdk`에서)
  - 플랫폼별 정확한 시그니처
  - 초기화/필수 파라미터
  - 에러 동작(throw? promise reject? 등)

근거는 노트에 저장하거나(추천), 새 스킬의 `references/`에 마크다운 파일로 남기세요.
나중에 유지보수자가 다시 갱신할 수 있도록, 사용한 검색 쿼리도 함께 기록합니다.

## 4) Skill Brief 초안(출력 포맷)

파일을 생성하기 전에, 아래 brief를 먼저 작성하고 사용자 승인(또는 합의)을 받습니다:

```yaml
skill:
  folder_name: "<kebab-case>" # 예: "push-troubleshooting"
  name: "notifly-<kebab-case>" # 예: "notifly-push-troubleshooting"
  display_name: "<Title Case>"
  short_description: "<short>"
  description: "<2-3 lines>"
  user_invocable: true

triggers:
  - "사용자가 말할 수 있는 문장"

inputs:
  - "스킬이 물어볼 최소 입력값"

outputs:
  - "스킬이 생성하는 산출물(플랜 JSON, 코드 변경, 체크리스트 등)"

guardrails:
  - "MCP-first 요구사항"
  - "보안 / PII 제약"

files_to_generate:
  skill_md: true
  references:
    - "<doc>.md"
  scripts:
    - "<script>.sh"
  examples:
    - "<optional>"
```

## 5) 스캐폴드 생성(레포 컨벤션)

이 레포에서 “완성된” 스킬 폴더는 다음을 포함해야 합니다:

- `SKILL.md` (YAML 프론트매터, MCP-first, 워크플로우, 점진적 공개 포함)
- `LICENSE.txt`
- `references/` (마크다운 문서; 비어있으면 안 됨)
- `scripts/` (결정적 bash 스크립트; 비어있으면 안 됨)
- `examples/` (선택이지만, 복붙 가능한 코드가 유용하다면 권장)

## 6) 스캐폴드 검증(빠른 피드백 루프)

새 스킬 폴더를 만든 뒤, 다음 스크립트로 검증하세요:

```bash
bash <skill-dir>/scripts/validate-same-scope.sh path/to/installed/skill-creator path/to/new-skill-folder
bash <skill-dir>/scripts/validate-skill-location.sh path/to/new-skill-folder --mode repo
bash <skill-dir>/scripts/validate-skill-scaffold.sh path/to/new-skill-folder
```

검증 내용:

- 새 스킬이 `skill-creator`와 **동일한 스코프**(프로젝트 레벨 vs 유저 레벨)에 설치되었는지  
  즉, 같은 `.../skills/` 디렉터리 아래에서 `skill-creator` 옆에 존재하는지
- 스킬 폴더가 이 레포 기준 올바른 위치(`skills/<name>/`)에 있는지
- 필수 파일 존재 여부
- `references/` 및 `scripts/` 디렉터리가 존재하고 비어있지 않은지
- `SKILL.md` 프론트매터 키가 유효한지
- 스킬이 `notifly-mcp-server`를 언급하는 MCP-first 섹션을 포함하는지

## 점진적 공개(Progressive Disclosure)

- **Level 1**: 이 `SKILL.md` (항상 로드)
- **Level 2**: `references/` (새 스킬을 작성할 때 로드)
- **Level 3**: `examples/` (스캐폴드를 복사/붙여넣기 할 때 로드)
- **Level 4**: `scripts/` (직접 실행; 컨텍스트에 로드하지 않음)

## 참고(References)

- `references/skill-template.md`
- `references/mcp-research-playbook.md`

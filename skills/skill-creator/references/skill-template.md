# 스킬 템플릿(새 Notifly 스킬용)

이 문서는 이 레포의 스타일에 맞춰 새 스킬을 만들기 위한 **복사/붙여넣기용 스캐폴드**입니다.

## 폴더 구조

다음을 생성하세요:

- `skills/<folder-name>/SKILL.md`
- `skills/<folder-name>/LICENSE.txt`
- `skills/<folder-name>/references/<docs>.md` (최소 1개 파일)
- `skills/<folder-name>/scripts/<script>.sh` (최소 1개 파일)
- `skills/<folder-name>/examples/` (선택이지만 권장)

## `SKILL.md` 스켈레톤

```markdown
---
name: notifly-<kebab-case>
display-name: <Title Case>
short-description: <short>
description: <2-3줄. 언제 쓰는지 포함. MCP-first를 명시적으로 언급.>
user-invocable: true
---

# <Title Case>

## 이 스킬이 하는 일(What this skill does)

- ...

## MCP-first(단일 진실원)

Notifly MCP 도구가 사용 가능하면, 이를 **단일 진실원(source of truth)** 으로 취급합니다:

- `notifly-mcp-server:search_docs`: 개념/동작/제약(한도) 확인
- `notifly-mcp-server:search_sdk`: 플랫폼 시그니처 확인(SDK 호출이 포함되는 경우)

MCP 도구를 사용할 수 없다면:

- MCP 설치를 먼저 요청(권장)하고, 설치가 불가하면 references/를 사용하되 정적 문서는
  오래되었을 수 있음을 명확히 경고합니다.

## 워크플로우(복사해서 체크)
```

<Skill> 진행 상황:

- [ ] 1. 최소 입력값 확인
- [ ] 2. 플랜 산출물 작성(JSON / 체크리스트 / 표)
- [ ] 3. 플랜 검증(스크립트)
- [ ] 4. 구현(코드/설정)
- [ ] 5. 검증(Notifly 콘솔 + 런타임)

```

## 점진적 공개(Progressive Disclosure)

- **Level 1**: 이 `SKILL.md`
- **Level 2**: `references/`
- **Level 3**: `examples/`
- **Level 4**: `scripts/` (직접 실행; 컨텍스트에 로드하지 않음)
```

## 품질 체크리스트(배포 전)

- **환각 없음**: 스킬에 언급된 모든 SDK 시그니처는 references에 기록된
  `notifly-mcp-server:search_sdk` 쿼리로부터 재도출 가능해야 합니다.
- **시크릿 없음**: 예시에 프로젝트 ID/API 키/고객 데이터 포함 금지.
- **명확한 스코프**: 한 가지 일을 잘 하도록. 잡탕이면 분리하세요.
- **백스톱**: “플랜 산출물”을 검증하는 결정적 스크립트 포함(JSON 스키마/구조 체크 등).
- **좋은 UX**: 최소 인테이크 질문, 사용자가 승인할 수 있는 구체적 산출물 제공.

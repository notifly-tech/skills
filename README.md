# Notifly Agent Skills

[![npm version](https://img.shields.io/npm/v/notifly-agent-skills.svg?logo=npm&label=npm)](https://www.npmjs.com/package/notifly-agent-skills)
[![npm downloads](https://img.shields.io/npm/dm/notifly-agent-skills.svg)](https://www.npmjs.com/package/notifly-agent-skills)

이 문서에서는 **노티플라이 에이전트 스킬** 패키지 모음을 소개합니다. 각 스킬은
AI 클라이언트(예: Cursor, Claude Code, Codex, VS Code 등)에서 불러와서 실행할 수
있는 **오픈 에이전트 스킬 기반의 독립형 패키지**입니다.

노티플라이(Notifly) MCP 서버와 함께 사용하면 SDK 연동 및 문서 검색과 같은 작업을
에이전트 스킬 단위로 쉽게 재사용할 수 있습니다.

## 스킬 설치하기

이 저장소의 에이전트 스킬은
[오픈 에이전트 스킬 표준](https://agentskills.io/home)을 기반으로
구축되었습니다. 지원되는 AI 클라이언트 목록과 최신 정보는
[공식 문서](https://agentskills.io/home#adoption)를 참고하시기 바랍니다.
사용하는 AI 클라이언트에 따라 여러 가지 방법으로 스킬을 설치할 수 있습니다.

### Universal CLI (권장)

Amp, Claude Code, Codex, Copilot, Cursor, Goose, Letta, OpenCode, VS Code 등의
클라이언트에서는 `notifly-agent-skills` 패키지가 제공하는 **Universal CLI**를
사용하여 스킬을 설치하고 노티플라이 MCP 서버를 자동으로 구성하는 것을
권장합니다.

#### 설치 모드

CLI는 스킬에 대해 두 가지 설치 모드를 지원합니다.

1. **Repo Root (프로젝트별)** – 현재 프로젝트 디렉터리에 스킬을 설치합니다
   (기본값)
   - 스킬은 **현재 프로젝트에서만 사용 가능**합니다.
   - 프로젝트별로 다른 설정을 사용하고자 할 때 적합합니다.

2. **System Root (전역)** – 홈 디렉터리에 스킬을 설치합니다.
   - 스킬은 **모든 프로젝트에서 사용 가능**합니다.
   - 개인 개발 환경 전체에서 공통 설정을 사용하고자 할 때 적합합니다.

**참고:** MCP(Model Context Protocol) 서버 구성은 스킬 설치 모드와 무관하게 항상
전역(System Root)에 저장됩니다. 이를 통해 모든 프로젝트에서 MCP 서버를 재사용할
수 있습니다.

```bash
# 특정 스킬 설치 (repo root - 기본값)
npx notifly-agent-skills@latest install <skill-name> --client <your-client>
# 예: Cursor에 integration 스킬을 설치
npx notifly-agent-skills@latest install integration --client cursor

# 특정 스킬을 전역으로 설치 (system root)
npx notifly-agent-skills@latest install <skill-name> --client <your-client> --global
# 예: Cursor에 integration 스킬을 전역 설치
npx notifly-agent-skills@latest install integration --client cursor --global

# 모든 스킬 한 번에 설치 (repo root)
npx notifly-agent-skills@latest install --all --client cursor
# 현재 포함된 스킬: integration

# 모든 스킬을 전역으로 설치 (system root)
npx notifly-agent-skills@latest install --all --client cursor --global
```

## 사용 가능한 스킬

현재 제공되는 스킬은 다음과 같습니다.

- **notifly-integration**: iOS, Android, Flutter, React Native 프로젝트에
  노티플라이 모바일 SDK를 통합하고 노티플라이 MCP 서버를 함께 구성해 주는
  스킬입니다.

### 지원되는 클라이언트 및 설치 플래그

각 클라이언트별로 CLI에서 사용할 플래그와 기본 스킬 저장 경로는 다음과 같습니다.

| 클라이언트     | 플래그                                 | 기본 경로          |
| :------------- | :------------------------------------- | :----------------- |
| Amp            | `--client amp`                         | `.amp/skills/`     |
| Claude Code    | `--client claude` (또는 `claude-code`) | `.claude/skills/`  |
| Codex          | `--client codex`                       | `.codex/skills/`   |
| Cursor         | `--client cursor`                      | `.cursor/skills/`  |
| GitHub Copilot | `--client github`                      | `.github/skills/`  |
| Goose          | `--client goose`                       | `.goose/skills/`   |
| Letta          | `--client letta`                       | `.skills/`         |
| OpenCode       | `--client opencode`                    | `.opencode/skill/` |

**참고:** Letta의 기본 경로인 `.skills/`는 홈 디렉터리 기준 상대 경로입니다.

## 클라이언트별 설정 가이드

### Claude Code

이 저장소를 Claude Code의 플러그인 마켓플레이스에 등록하려면 다음 명령어를
실행합니다.

```bash
/plugin marketplace add notifly-tech/skills
```

특정 스킬을 설치하려면 다음 단계를 따라 진행하세요.

1. `/plugin`에서 **Marketplace** 섹션으로 이동합니다.
2. **Browse plugins**를 선택합니다.
3. 설치하려는 스킬을 선택합니다.
4. 스킬을 설치합니다.

또는 다음 명령어로 단일 스킬을 직접 설치할 수 있습니다.

```bash
/plugin install <plugin-name>@<marketplace-name>
# 예시
/plugin install notifly-integration@notifly-agent-skills
```

설치 후 새로 설치한 스킬이 인식되도록 Claude Code를 재시작해야 합니다.

### Codex

스킬을 수동으로 설치하려면 이 저장소의 스킬을 Codex 설정 디렉터리에 저장하시기
바랍니다. 자세한 위치는 공식 문서를 참고하시기 바랍니다.

- [Codex 스킬 저장 경로 안내](https://developers.openai.com/codex/skills/#where-to-save-skills)

또는 명령줄에서 `skill-installer`로 특정 스킬을 직접 설치할 수 있습니다.

```bash
$skill-installer install <link-to-skill-folder>
# 예시
$skill-installer install https://github.com/notifly-tech/skills/tree/main/skills/integration
```

설치 후 Codex를 재시작해야 새로 설치한 스킬이 로드됩니다.

## 면책 조항

AI의 비결정적 특성으로 인해 이러한 스킬이 때때로 실패하거나 의도한 대로 동작하지
않을 수 있습니다. 스킬이 수행하는 모든 작업은 **항상 주의 깊게 검토하고 확인**해
주시기 바랍니다.

이 스킬들은 개발 생산성을 높이도록 설계되었지만, 실제 결과물(코드, 설정, 명령 실행 등)에 대한 최종 책임은 사용자에게 있습니다. 실제 운영 환경에서는 특히 결제, 데이터 삭제, 대규모 알림 발송과 같은 작업 전에 반드시 실행 결과 및 생성된 코드와 설정을 검토하시기 바랍니다.

## 라이선스

이 저장소의 각 스킬에는 각 스킬 디렉터리 내 `LICENSE.txt` 파일에 명시된 라이선스
조항이 적용됩니다. 구체적인 라이선스 조항은 각 스킬 디렉터리의 `LICENSE.txt`
파일을 확인하시기 바랍니다.

자세한 내용과 최신 스킬 목록은 `notifly-agent-skills` 패키지와 GitHub 저장소를
참고하시기 바랍니다.

# Notifly Agent Skills

[![npm version](https://img.shields.io/npm/v/notifly-agent-skills.svg?logo=npm&label=npm)](https://www.npmjs.com/package/notifly-agent-skills)
[![npm downloads](https://img.shields.io/npm/dm/notifly-agent-skills.svg)](https://www.npmjs.com/package/notifly-agent-skills)

이 저장소에는 **Notifly Agent Skills** 모음이 포함되어 있습니다. 각 스킬은 AI
클라이언트에서 로드하고 실행할 수 있는 독립적인 패키지입니다.

## 스킬 설치하기

이 저장소의 에이전트 스킬은
[오픈 에이전트 스킬 표준](https://agentskills.io/home)을 기반으로
구축되었습니다. 지원되는 AI 클라이언트에 대한 최신 정보는
[공식 문서](https://agentskills.io/home#adoption)를 참조하세요. 사용하는 AI
클라이언트에 따라 다양한 방법으로 스킬을 설치할 수 있습니다.

### Universal CLI (권장)

Amp, Claude Code, Codex, Copilot, Cursor, Goose, Letta, OpenCode, VS Code의
경우, 저희가 제공하는 설치 도구를 사용하여 스킬을 설정하고 Notifly MCP 서버를
자동으로 구성하는 것을 권장합니다.

#### 설치 모드

CLI는 스킬에 대해 두 가지 설치 모드를 지원합니다:

1. **Repo Root (프로젝트별)** - 현재 프로젝트 디렉토리에 스킬을 설치합니다
   (기본값)
   - 스킬은 현재 프로젝트에서만 사용 가능합니다
   - 프로젝트별 구성에 적합합니다

2. **System Root (전역)** - 홈 디렉토리에 스킬을 설치합니다
   - 스킬은 모든 프로젝트에서 사용 가능합니다
   - 개인 개발 환경 설정에 적합합니다

**참고:** MCP(Model Context Protocol) 서버 구성은 스킬 설치 모드와 관계없이 항상
전역(system root)으로 설정됩니다. 이를 통해 모든 프로젝트에서 MCP 서버를 사용할
수 있습니다.

```bash
# 특정 스킬 설치 (repo root - 기본값)
npx notifly-agent-skills@latest install <skill-name> --client <your-client>
# 예를 들어, Cursor에 스킬을 설치하려면:
npx notifly-agent-skills@latest install integration --client cursor

# 특정 스킬을 전역으로 설치 (system root)
npx notifly-agent-skills@latest install <skill-name> --client <your-client> --global
# 예시:
npx notifly-agent-skills@latest install integration --client cursor --global

# 모든 스킬 한 번에 설치 (repo root)
npx notifly-agent-skills@latest install --all --client cursor
# 현재 설치되는 스킬: integration

# 모든 스킬을 전역으로 설치 (system root)
npx notifly-agent-skills@latest install --all --client cursor --global
```

### 사용 가능한 스킬

- **notifly-integration**: iOS, Android, Flutter, React Native 프로젝트에
  Notifly Mobile SDK를 통합하고 Notifly MCP 서버를 구성합니다.

**지원되는 클라이언트:**

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

### Claude Code

이 저장소를 Claude Code의 플러그인 마켓플레이스로 등록하려면 다음 명령어를
실행하세요:

```bash
/plugin marketplace add notifly-tech/skills
```

특정 스킬을 설치하려면:

1. `/plugin`에서 Marketplace 섹션으로 이동합니다
2. `Browse plugins`를 선택합니다
3. 설치하려는 스킬을 선택합니다
4. 스킬을 설치합니다

또는 다음 명령어를 실행하여 단일 스킬을 직접 설치할 수 있습니다:

```bash
/plugin install <plugin-name>@<marketplace-name>
# 예시
/plugin install notifly-integration@notifly-agent-skills
```

설치 후 새 스킬을 로드하려면 Claude Code를 재시작해야 합니다.

### Codex

스킬을 수동으로 설치하려면 이 저장소에서 Codex 설정 디렉토리로 저장하세요:
[https://developers.openai.com/codex/skills/#where-to-save-skills](https://developers.openai.com/codex/skills/#where-to-save-skills)

또는 명령줄을 사용하여 특정 스킬을 설치하세요:

```bash
$skill-installer install <link-to-skill-folder>
# 예시
$skill-installer install https://github.com/notifly-tech/skills/tree/main/skills/integration
```

새 스킬을 감지하려면 설치 후 Codex를 재시작해야 합니다.

## 면책 조항

AI의 비결정적 특성으로 인해 이러한 스킬이 때때로 실패하거나 잘못 실행될 수
있다는 점을 유의하세요. 이러한 스킬이 수행하는 모든 작업을 주의 깊게 검토하고
확인하는 것이 중요합니다. 스킬은 도움이 되도록 설계되었지만, 사용 전에 출력을
확인하는 것은 사용자의 책임입니다. 주의와 감독하에 사용하시기 바랍니다.

## 라이선스

이 저장소의 각 스킬은 자체 라이선스에 따라 관리됩니다. 구체적인 이용 약관은 각
스킬의 개별 디렉토리에 있는 `LICENSE.txt` 파일을 참조하세요.

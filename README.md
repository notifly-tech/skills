# Notifly Agent Skills

AI 코딩 에이전트를 위한 스킬 모음입니다. 스킬은 에이전트의 기능을 확장하는 패키지화된 인스트럭션과 스크립트입니다.

스킬은 [Agent Skills](https://agentskills.io/) 포맷을 따릅니다.

## 사용 가능한 스킬

### notifly-integration

- 실제 스킬 이름: `notifly-integration`
- 표시 이름: `SDK Integration`
- 경로: `skills/integration`

노티플라이 SDK를 Mobile(iOS/Android/Flutter/React Native) 및 Web(JavaScript/Google Tag Manager) 프로젝트에 연동하고, 필요 시 Notifly MCP 설정과 검증 흐름까지 안내하는 스킬입니다.

**사용 시기:**
- 새 프로젝트에 Notifly SDK를 연동할 때
- 기존 프로젝트에 푸시 알림, 인앱 팝업, 웹 팝업, 유저 식별, 유저 프로퍼티, 이벤트 트래킹을 추가할 때
- iOS, Android, Flutter, React Native, Web, Google Tag Manager 환경에서 SDK를 설정할 때
- Notifly MCP를 함께 구성하거나 SDK 연동 상태를 검증할 때

### migrate-from-braze

- 실제 스킬 이름: `migrate-from-braze`
- 표시 이름: `Migrate from Braze to Notifly`
- 경로: `skills/migrate-from-braze`

Braze SDK 연동을 Notifly SDK와 Remote MCP 기반 운영 흐름으로 이전하는 스킬입니다. iOS(Swift), Android(Kotlin/Java), Flutter, React Native, Expo, Web을 지원합니다.

**사용 시기:**
- Braze에서 Notifly로 CRM/푸시/인앱 SDK를 이전할 때
- Braze를 완전히 제거할지, 일정 기간 Notifly와 공존시킬지 먼저 결정해야 할 때
- SDK 연동 전 MCP event/property catalog가 비어 있을 수 있음을 고려해 Braze 코드 기준 목표 catalog를 만들 때
- 플랫폼별 Braze 이벤트·유저 속성·푸시 클릭·인앱 흐름을 Notifly SDK/MCP 기반으로 매핑할 때

### migrate-from-onesignal

- 실제 스킬 이름: `migrate-from-onesignal`
- 표시 이름: `Migrate from OneSignal to Notifly`
- 경로: `skills/migrate-from-onesignal`

OneSignal SDK 연동을 Notifly SDK와 Remote MCP 기반 운영 흐름으로 이전하는 스킬입니다. iOS(Swift), Android(Kotlin/Java), Flutter, React Native, Expo, Web을 지원합니다.

**사용 시기:**
- OneSignal에서 Notifly로 CRM/푸시/인앱 SDK를 이전할 때
- OneSignal을 완전히 제거할지, 일정 기간 Notifly와 공존시킬지 먼저 결정해야 할 때
- OneSignal User Model(`login`, Tags, Custom Events, Subscriptions)과 구형 API를 구분해 목표 catalog를 만들 때
- Web service worker, Expo plugin, iOS NSE/App Group, Android FCM service 등 OneSignal SDK 구조를 확인하며 Notifly로 매핑할 때


## 설치

전체 스킬을 설치하려면 다음 명령을 사용합니다.

```bash
npx skills add notifly-tech/skills
```

프롬프트 없이 모든 스킬을 모든 지원 에이전트에 설치하려면:

```bash
npx skills add notifly-tech/skills --all
```

설치 가능한 개별 스킬 이름을 확인하려면:

```bash
npx skills add notifly-tech/skills --list
```

개별 스킬만 설치하려면 `--skill` 뒤에 위의 **실제 스킬 이름**을 지정합니다.

```bash
# Notifly SDK 신규 연동 스킬만 설치
npx skills add notifly-tech/skills --skill notifly-integration

# Braze → Notifly 마이그레이션 스킬만 설치
npx skills add notifly-tech/skills --skill migrate-from-braze

# OneSignal → Notifly 마이그레이션 스킬만 설치
npx skills add notifly-tech/skills --skill migrate-from-onesignal

# 여러 개별 스킬을 한 번에 설치
npx skills add notifly-tech/skills --skill notifly-integration migrate-from-braze migrate-from-onesignal
```

특정 에이전트 또는 전역 범위에 설치하려면 `npx skills`의 표준 옵션을 함께 사용할 수 있습니다.

```bash
npx skills add notifly-tech/skills --skill migrate-from-braze --agent claude-code
npx skills add notifly-tech/skills --skill migrate-from-onesignal --agent claude-code
npx skills add notifly-tech/skills --skill migrate-from-braze --global
```

## 사용법

스킬은 설치 후 자동으로 사용 가능합니다. 에이전트가 관련 작업을 감지하면 해당 스킬을 활용합니다.

**예시:**
```
노티플라이 SDK를 React Native 프로젝트에 연동해 줘
```
```
노티플라이 푸시 알림을 설정해 줘
```
```
노티플라이 SDK 연동 상태를 확인해 줘
```
```
OneSignal에서 노티플라이로 마이그레이션해 줘
```

## 스킬 구조

각 스킬은 다음과 같은 요소로 구성됩니다.
- `SKILL.md` - 에이전트를 위한 인스트럭션
- `scripts/` - 자동화를 위한 헬퍼 스크립트 (선택사항)
- `references/` - 보조 문서 (선택사항)

## 면책 조항

AI의 비결정적 특성으로 인해 이러한 스킬이 때때로 실패하거나 의도한 대로 동작하지 않을 수 있습니다. 스킬이 수행하는 모든 작업은 **항상 주의 깊게 검토하고 확인**해 주시기 바랍니다.

이 스킬들은 개발 생산성을 높이도록 설계되었지만, 실제 결과물(코드, 설정, 명령 실행 등)에 대한 최종 책임은 사용자에게 있습니다. 실제 운영 환경에서는 특히 결제, 데이터 삭제, 대규모 알림 발송과 같은 작업 전에 반드시 실행 결과 및 생성된 코드와 설정을 검토하시기 바랍니다.

## 라이선스

이 저장소의 각 스킬에는 각 스킬 디렉터리 내 `LICENSE.txt` 파일에 명시된 라이선스 조항이 적용됩니다.

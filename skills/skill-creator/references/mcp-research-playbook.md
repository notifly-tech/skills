# MCP 조사 플레이북(Notifly)

이 플레이북은 새로운 Notifly 스킬을 작성하기 전에 **정확하게 조사**하는 방법을 안내합니다.
목표는 추측 없이도 스킬을 유지보수할 수 있을 만큼의 근거를 수집하는 것입니다.

## 황금 규칙(Golden rules)

- **SDK 시그니처는 반드시** `notifly-mcp-server:search_sdk`에서 가져옵니다(기억/추측 금지).
- **동작/제약은 반드시** `notifly-mcp-server:search_docs`에서 가져옵니다.
- 근거가 불명확하면 단정하지 말고, 그 불확실성을 스킬에 그대로 적고 사용자 확인을 받습니다.

## 권장 조사 순서

### 1) “기능 명사(feature nouns)” 식별

사용자 니즈에서 핵심 키워드를 뽑습니다:

- 채널: 모바일 푸시 / **웹 푸시** / 인앱(팝업) / 웹 팝업 / 이메일 / SMS / 등
- 트리거 타입: 이벤트 트리거 / API 트리거 / 스케줄
- 도메인: 유저 여정, 세그먼트, 템플릿, 어트리뷰션, 딥링크, 등
- 플랫폼(SDK 관련 시): iOS / Android / Flutter / React Native / **Web (JavaScript)** / **GTM**

**웹 푸시(Web Push)** 는 다음 “인프라 명사”도 함께 뽑아야 합니다(대부분의 장애 원인을 결정):

- Service Worker 파일 경로(예: `/notifly-service-worker.js`)
- VAPID 키 / 웹사이트 설정(콘솔)
- HTTPS / origin / 브라우저 권한(permissions) 모델
- 구독(subscription) 라이프사이클(권한 → 구독 → 토큰/엔드포인트 → 전송/수신)

### 2) 문서를 먼저 검색(개념적 계약/컨트랙트)

다음과 같은 `notifly-mcp-server:search_docs` 쿼리를 사용하세요:

- `"<feature> limits"`
- `"<feature> troubleshooting"`
- `"<feature> required fields"`
- `"<endpoint or concept> authentication headers"`
- `"Message Logs template rendering errors"`
- **웹 푸시 전용(Web Push-specific)**:
  - `"web push VAPID key"`
  - `"service worker notifly-service-worker.js"`
  - `"web push permission prompt"`
  - `"push subscription not created"`
  - `"HTTPS requirement web push"`

기록할 것:

- 제약/한도(예: 최대 속성 수, 페이로드 제한)
- 필수 필드(required fields)
- “콘솔이 이렇게 동작한다” 같은 문장(콘솔 동작 계약)

### 3) SDK를 다음으로 검색(정확한 시그니처)

다음과 같은 `notifly-mcp-server:search_sdk` 쿼리를 사용하세요:

- `"initialize"`
- `"setUserId"`
- `"setUserProperty"`
- `"trackEvent"`
- `"push token"`
- `"<feature name>"` + 플랫폼 필터
- **웹 푸시 전용(JavaScript / Service Worker)**:
  - `"requestPermission"`
  - `"service worker"`
  - `"NotiflyServiceWorker"`
  - `"vapid"`
  - `"subscribe"`

대상 플랫폼별로 다음을 캡처하세요:

- 메서드 이름 + 파라미터(가능하면 타입 포함)
- 반환 타입(동기/비동기)
- 에러 동작(throw? promise reject? error object 반환?)

### 4) 근거를 “스킬 계약”으로 변환

새 스킬의 `SKILL.md`에:

- MCP-first 섹션을 포함하고
- 구체적인 워크플로우 단계를 포함하며
- 유지보수가 어려운 큰 정적 API 표는 피합니다(대신 “MCP로 정확한 시그니처를 가져오라”는 방식 권장)

## 권장 “Evidence Pack” 포맷

새 스킬의 `references/`에 `evidence.md`(또는 유사 파일)를 만들고 다음을 담습니다:

- 실행한 **검색 쿼리**
- **고신호 발췌(high-signal excerpts)** (짧게)
- 발췌별로 “우리가 도출한 결론”을 짧게 정리한 문단

이렇게 하면 유지보수와 디버깅이 훨씬 쉬워집니다.

# Notifly JavaScript SDK 웹 연동 계약

이 문서는 Notifly JavaScript SDK로 **웹 팝업**과 **웹 푸시**를 붙일 때 agent가 놓치기 쉬운 런타임 계약을 정리합니다. 최신 단일 기준은 공식 문서와 MCP 결과입니다.

- 공식 문서: `https://docs.notifly.tech/ko/developer-guide/javascript-sdk`
- SDK 저장소: `https://github.com/team-michael/notifly-js-sdk`

## 기능별로 먼저 분리하기

### 웹 팝업 only

웹 팝업은 Notification 권한이나 Service Worker가 아니라 다음 경로로 동작합니다.

1. `notifly.initialize({ projectId, username, password })`
2. SDK가 user state를 동기화
3. `setUserId`, `setUserProperties`, `trackEvent` 호출
4. 캠페인 조건과 이벤트/세그먼트가 매칭
5. SDK가 웹 메시지를 렌더링하고 show/click/close 이벤트를 로깅

따라서 popup-only 연동의 핵심은 **어떤 제품 이벤트를 어떤 이름/속성으로 보낼지**입니다.

권장 순서:

```js
await notifly.setUserId(user.id);
await notifly.setUserProperties({
  $email: user.email,
  paid_membership: user.isPaid,
});
await notifly.trackEvent("view_product", { product_id: product.id }, ["product_id"]);
```

주의:

- `segmentationEventParamKeys`는 최대 1개 키만 사용합니다.
- 로그인 직후에는 `setUserId → setUserProperties → trackEvent` 순서를 유지합니다.
- `setUserId(null)` 또는 `setUserId()`는 로그아웃 처리이며, 문서상 유저 데이터 삭제성 동작이 있으므로 의도 확인 후 사용합니다.
- 웹 팝업 HTML 내부에서 사용자 정의 이벤트를 로깅해야 하는 경우에만 SDK 2.17.2+에서 `allowUserSuppliedLogEvent: true`를 초기화 옵션에 추가합니다.

### 웹 푸시 only

웹 푸시는 브라우저 런타임 계약이 더 중요합니다.

필수 계약:

- HTTPS secure context. 운영은 HTTPS가 필수이고, 로컬 웹푸시 테스트도
  `https://localhost`에서 수행합니다. plain HTTP/localhost 예외에 기대어 검증하지 마세요.
- Notifly 콘솔의 웹사이트 SDK 설정에서 VAPID 키 생성
- Notifly 콘솔의 `serviceWorkerPath`와 실제 제공 경로 일치
- 해당 URL이 HTML fallback이 아니라 JavaScript Service Worker 파일로 200 응답
- 브라우저 Notification 권한이 `default` 또는 `granted` 상태
- 권한 허용 후 PushSubscription 생성 및 Notifly device property logging 확인

기본 Service Worker 파일:

```js
self.importScripts(
  "https://cdn.jsdelivr.net/npm/notifly-js-sdk@2/dist/NotiflyServiceWorker.js"
);
```

## 로컬 HTTPS 웹푸시 테스트

웹푸시는 단순 SDK 호출이 아니라 브라우저의 secure-context 기능입니다. 따라서 로컬에서
테스트할 때도 `http://localhost`가 아니라 `https://localhost`로 서버를 띄우고 다음 축을
함께 확인합니다: Service Worker 등록, Notification 권한, PushSubscription 생성, Notifly
기기 속성 로깅.

Next.js라면 공식 `next dev` HTTPS 플래그를 사용합니다.

```bash
# package.json의 dev script가 `next dev`라면
npm run dev -- --experimental-https

# 또는 직접 실행
npx next dev --experimental-https
```

정해진 인증서를 써야 하면 mkcert 등으로 만든 key/cert를 지정합니다.

```bash
npx next dev --experimental-https \
  --experimental-https-key ./certificates/localhost-key.pem \
  --experimental-https-cert ./certificates/localhost.pem
```

Next.js가 아니면 먼저 프로젝트의 프레임워크를 확인합니다.

1. `package.json`의 dependencies/devDependencies/scripts를 읽어 Next/Vite/CRA/Remix/Astro/SvelteKit 등인지 식별
2. 해당 프레임워크의 공식 local HTTPS dev-server 방법을 확인
3. HTTPS 서버로 실행한 뒤 `https://localhost:<port>`에서 Service Worker path와 권한 흐름 검증

예: Vite는 `@vitejs/plugin-basic-ssl` 또는 `server.https` 설정, CRA는 `HTTPS=true npm start`처럼
프레임워크별 방법이 다릅니다. 추측하지 말고 현재 프로젝트의 프레임워크와 버전에 맞춰 확인하세요.

### 웹 팝업 + 웹 푸시

초기화는 하나입니다. 다만 검증 축이 다릅니다.

- 웹 팝업: user/event/campaign trigger 검증
- 웹 푸시: Service Worker/permission/subscription/device logging 검증

두 기능을 동시에 붙여도 `trackEvent`와 푸시 권한 요청을 섞어서 생각하지 마세요. 하나는 캠페인 타깃팅 신호이고, 하나는 브라우저 구독 계약입니다.

## 현재 SDK 2.5+ 초기화 계약

Notifly JavaScript SDK는 `notifly.initialize({ projectId, username, password })` 형태를
사용합니다. 다만 현재 정책상 password 값은 사용하지 않습니다. 별도
`NEXT_PUBLIC_NOTIFLY_PASSWORD`/`NEXT_PUBLIC_NOTIFLY_PROJECT_PASSWORD`를 요구하지 말고,
SDK 타입/시그니처 호환을 위해 `password` 필드에는 빈 문자열, `username`, 또는 프로젝트가
정한 더미값을 넘깁니다. `.env.example`은 프로젝트마다 다를 수 있으므로 연동 품질의 필수
판정 기준으로 삼지 않습니다.

```js
const projectId = process.env.NEXT_PUBLIC_NOTIFLY_PROJECT_ID;
const username = process.env.NEXT_PUBLIC_NOTIFLY_PROJECT_USERNAME;
const password = username || ""; // compatibility field; do not require NEXT_PUBLIC_NOTIFLY_PASSWORD

if (!projectId) throw new Error("Missing Notifly projectId");
if (!/^[a-f0-9]{32}$/i.test(projectId)) throw new Error("Invalid Notifly projectId");

notifly.initialize({
  projectId,
  username,
  password,
});
```

선택 옵션:

```js
notifly.initialize({
  projectId,
  username,
  password,
  allowUserSuppliedLogEvent: true, // 웹 팝업 HTML 내부 custom event logging이 필요한 경우에만
});
```

기존 프로젝트에 projectId validation, missing/invalid 구분, `allowUserSuppliedLogEvent`
plumbing/test가 있으면 삭제하지 말고 확장하세요.

하지 말아야 할 것:

- SDK 2.5+ 연동에서 `pushSubscriptionOptions`를 새로 추가하지 마세요.
- top-level `serviceWorkerPath`를 임의로 넣지 마세요. 현재 공개 타입의 초기화 옵션이 아닙니다.
- 웹 푸시 세부값(VAPID, SW path, askPermission, prompt delay)은 Notifly 콘솔의 웹사이트 SDK 설정과 서버 SDK configuration을 기준으로 확인합니다.

Legacy SDK 2.4 이하를 명시적으로 지원해야 할 때만 `pushSubscriptionOptions`를 사용합니다.

## 프레임워크별 배치

### React / Next.js

- 브라우저에서만 실행합니다. SSR 중 `window` 접근 금지.
- React StrictMode에서 effect가 두 번 실행될 수 있으므로 앱 레벨에서 한 번만 초기화되게 합니다.
- Next.js App Router에서는 client component 또는 client-only provider 안에서 초기화합니다.
- 기존 `Provider`/config parser/SDK client/test 구조가 있으면 가능하면 유지하고, 필요한 호출만 추가합니다. 다만 기존 앱의 명시적 계약을 깨지 않는 한 이 항목은 blocker가 아니라 parity/maintainability 신호입니다.

예시:

```js
import { useEffect } from "react";
import notifly from "notifly-js-sdk";

let notiflyInitialized = false;

export function useNotifly() {
  useEffect(() => {
    if (notiflyInitialized) return;
    if (typeof window === "undefined") return;

    notifly.initialize({
      projectId: process.env.NEXT_PUBLIC_NOTIFLY_PROJECT_ID,
      username: process.env.NEXT_PUBLIC_NOTIFLY_PROJECT_USERNAME,
      password: process.env.NEXT_PUBLIC_NOTIFLY_PROJECT_USERNAME || "",
    });

    notiflyInitialized = true;
  }, []);
}
```

### Vite / CRA / Vanilla

- `public/notifly-service-worker.js`처럼 빌드 산출물 루트에 그대로 복사되는 위치를 사용합니다.
- CDN 방식이면 SDK script 로드 후 `window.notifly.initialize(...)`를 호출합니다.

### Google Tag Manager

- SDK script load timing과 dataLayer 이벤트 순서를 보장합니다.
- `userId`, `userProperties`, 제품 이벤트를 dataLayer 변수/이벤트로 매핑합니다.
- 웹 푸시는 GTM만으로 끝나지 않습니다. Service Worker 파일은 여전히 사이트에서 직접 제공해야 합니다.
- CSP가 있으면 `script-src`, `connect-src`, `worker-src`에서 Notifly/CDN 호출을 허용해야 합니다.

## Service Worker 충돌 체크

웹 푸시 연동 전에 기존 Service Worker를 먼저 찾습니다.

흔한 파일/설정:

- `public/service-worker.js`
- `public/firebase-messaging-sw.js`
- `src/service-worker.*`
- `OneSignalSDKWorker.js`
- Workbox 또는 `next-pwa` 설정

기존 root-scope Service Worker가 있으면 `public/notifly-service-worker.js`를 무작정 추가하지 마세요. 같은 scope의 SW는 충돌하거나 마지막 등록자가 scope를 가져갈 수 있습니다.

선택지는 보통 둘입니다.

1. 기존 Service Worker 안에서 Notifly SW를 `importScripts(...)`로 함께 로드
2. Notifly 콘솔의 `serviceWorkerPath`를 기존 SW 경로에 맞추고, push/click handler 충돌을 검토

충돌 가능성이 있으면 최종 구현 전에 사용자에게 확인해야 합니다.

## 권한 요청 계약

자동 요청:

- 콘솔의 권한 요청 팝업을 켜면 SDK가 안내 팝업 후 브라우저 권한을 요청합니다.

수동 요청:

```js
notifly.requestPermission();
notifly.requestPermission("en");
```

조건:

- SDK 2.7.0+ 필요
- 콘솔의 “권한 팝업 자동 노출”이 비활성화되어 있어야 함
- `requestPermission(...)` 호출은 권한 프롬프트 시도일 뿐입니다. 성공/구독 증명은
  `Notification.permission`, Service Worker 등록, PushSubscription 생성, Notifly device
  property logging으로 별도 확인합니다.
- SDK initialized/ready 상태와 push subscribed/verified 상태를 UI/문서/리포트에서 분리합니다.
- 브라우저 권한이 이미 `denied`이면 SDK가 다시 요청할 수 없음

## 런타임 검증 체크리스트

- [ ] Web Push 테스트 페이지를 `https://localhost:<port>` 또는 배포 HTTPS 도메인에서 열었다. plain HTTP가 아니다.
- [ ] `https://<domain>/notifly-service-worker.js` 또는 콘솔에 설정한 SW path가 200 JS로 응답한다. SPA `index.html`이 아니다.
- [ ] DevTools > Application > Service Workers에서 Notifly SW가 등록되어 있다.
- [ ] Network에서 `/sdk-configurations?project_id=...&type=website`가 200이다.
- [ ] 콘솔에 `[Notifly] Failed to initialize PushManager` 오류가 없다.
- [ ] `Notification.permission`이 의도한 상태다: `default`, `granted`, `denied`.
- [ ] 권한 요청 버튼/API 호출은 prompt 시도이고, `Notification.permission`/PushSubscription/device logging으로 실제 성공을 따로 확인했다.
- [ ] 권한 허용 후 PushSubscription이 생성된다.
- [ ] `set_device_properties` 또는 device token logging이 Notifly 쪽에 반영된다.
- [ ] SDK ready와 push subscribed/verified 상태를 같은 의미로 표시하지 않는다.
- [ ] `setUserId → setUserProperties → trackEvent` 호출 후 Notifly 콘솔/테스트 페이지에서 이벤트가 보인다.
- [ ] 웹 팝업 캠페인 조건에 맞는 이벤트 호출 시 modal이 노출된다.

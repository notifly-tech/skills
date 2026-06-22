# Web JavaScript Migration

Use for browser apps using Braze Web SDK, including React, Next.js, vanilla JS, or tag-manager based integrations.

## Detect Braze

Search for:

- `@braze/web-sdk`, `braze-web-sdk`, `appboy-web-sdk`
- `braze.initialize`, `braze.openSession`, `braze.changeUser`
- `braze.logCustomEvent`, `braze.logPurchase`
- Content Cards, Feature Flags, in-app messages
- service worker / web push setup

## Notifly setup

Notifly JavaScript docs: `/ko/developer-guide/javascript-sdk`.

Key points from docs:

- Web push requires VAPID key and HTTPS/browser permission setup
- A service worker file must be served from the expected path and must not be swallowed by the bundler
- Package install or CDN script are both possible depending on app architecture
- `serviceWorkerPath` must match the deployed service worker path

Core APIs:

```ts
import notifly from 'notifly-sdk';

notifly.initialize({
  projectId: 'PROJECT_ID',
  username: 'USERNAME',
  serviceWorkerPath: '/notifly-service-worker.js',
});

notifly.setUserId('user_123');
notifly.setUserId(null);
notifly.setUserProperties({ $email: 'user@example.com' });
notifly.trackEvent('purchase_completed', { price: 120000 }, ['price']);
```

Service worker:

```js
// public/notifly-service-worker.js
self.importScripts('https://sdk.notifly.tech/notifly-service-worker.js');
```

Always confirm the current official script URL/path in `/ko/developer-guide/javascript-sdk` before changing production code.

## Mapping

| Braze Web | Notifly Web |
| --- | --- |
| `braze.initialize(...)` | `notifly.initialize(...)` |
| `braze.changeUser(userId)` | `notifly.setUserId(userId)` |
| `braze.getUser().setCustomUserAttribute` | `notifly.setUserProperties({...})` |
| `braze.logCustomEvent(name, props)` | `notifly.trackEvent(name, props, segmentationEventParamKeys?)` |
| Braze service worker/web push | Notifly service worker + VAPID/browser permission |
| Content Cards / Feature Flags | product design required |

## SSR/SPA caveats

- Guard browser-only code behind client/runtime checks in SSR frameworks.
- Service worker files must be copied to the public output root.
- Do not initialize twice during React strict-mode/dev hot reload; keep an idempotent adapter.
- If GTM is used, preserve `setUserId → setUserProperties → trackEvent` sequencing.

## Verification

- Build the web app
- Confirm service worker file exists in final static output
- Test on HTTPS origin
- Verify browser permission prompt and push subscription path
- Use MCP/console after representative user/event calls

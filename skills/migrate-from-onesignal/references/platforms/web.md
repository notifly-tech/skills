# Web JavaScript Migration

Use for browser apps using OneSignal Web SDK, including React, Next.js, vanilla JS, or tag-manager based integrations.

## Detect OneSignal

Search for:

- `https://cdn.onesignal.com/sdks/web/v16/OneSignalSDK.page.js`
- `window.OneSignalDeferred`, `OneSignalDeferred.push`
- `OneSignal.init({ appId: ... })`
- `OneSignal.login`, `OneSignal.logout`, `OneSignal.User.addTag(s)`, `OneSignal.User.trackEvent`
- `OneSignal.Notifications.requestPermission`, `addEventListener('click')`, `permissionChange`
- `OneSignalSDKWorker.js`, `OneSignalSDKUpdaterWorker.js`, service worker path/scope config
- web prompt options: slidedown/category prompts, notify button, welcome notification, auto-resubscribe
- dashboard integration type: Typical Site, Custom Code, WordPress, Shopify

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

| OneSignal Web | Notifly Web |
| --- | --- |
| `OneSignalSDK.page.js` + `OneSignal.init(...)` | `notifly.initialize(...)` |
| `OneSignal.login(userId)` | `notifly.setUserId(userId)` |
| `OneSignal.logout()` | `notifly.setUserId(null)` |
| `OneSignal.User.addTag(s)` | `notifly.setUserProperties({...})` |
| `OneSignal.User.trackEvent(name, props)` | `notifly.trackEvent(name, props, segmentationEventParamKeys?)` |
| `OneSignalSDKWorker.js` | Notifly service worker + VAPID/browser permission |
| Slidedown/category prompts | Notifly permission UX/campaign design; tag categories become user properties or events |
| Welcome notification / notify button | product UX decision; not a blind SDK rename |

## SSR/SPA caveats

- Guard browser-only code behind client/runtime checks in SSR frameworks.
- Service worker files must be copied to the public output root.
- Do not initialize twice during React strict-mode/dev hot reload; keep an idempotent adapter.
- If GTM is used, preserve `setUserId → setUserProperties → trackEvent` sequencing.
- Same-origin service worker scope matters. Confirm OneSignal and Notifly workers do not fight for the same scope during coexist.

## Complete mode removal checklist

- Remove OneSignal script snippet after Notifly web verification
- Remove `OneSignalSDKWorker.js` / updater worker only after no active OneSignal web push dependency remains
- Remove OneSignal init options from tag manager/CMS templates
- Search for `OneSignal`, `OneSignalDeferred`, `OneSignalSDK`, `onesignal`, `subscription_id`, `player_id`
- Verify production build output contains Notifly service worker at the configured path

## Verification

- Build the web app
- Confirm service worker file exists in final static output
- Test on HTTPS origin
- Verify browser permission prompt and push subscription path
- Use MCP/console after representative user/property/event calls

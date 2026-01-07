/**
 * Notifly JavaScript SDK integration (example)
 *
 * This is a minimal example you can adapt to React/Next.js/Vue/etc.
 *
 * Notes:
 * - The SDK runs only in the browser (window exists).
 * - For Web Push, you must serve a Service Worker file (see `notifly-service-worker.js`).
 * - Credentials should be injected via env/secrets; do not hardcode real values.
 */

import notifly from "notifly-js-sdk";

export function initNotiflyWeb() {
  if (typeof window === "undefined") return;

  notifly.initialize({
    projectId: process.env.NEXT_PUBLIC_NOTIFLY_PROJECT_ID,
    username: process.env.NEXT_PUBLIC_NOTIFLY_PROJECT_USERNAME,
    password: process.env.NEXT_PUBLIC_NOTIFLY_PROJECT_PASSWORD,
    // For some versions / setups you may need:
    // serviceWorkerPath: "/notifly-service-worker.js",
  });
}

export function loginNotifly(userId) {
  notifly.setUserId(userId);
}

export function logoutNotifly() {
  // Warning: per docs, setting null can reset user data associated with the user.
  notifly.setUserId(null);
}

export function setNotiflyUserProperties(props) {
  notifly.setUserProperties(props);
}

export function trackNotiflyEvent(name, params, segmentationEventParamKeys) {
  notifly.trackEvent(name, params, segmentationEventParamKeys);
}

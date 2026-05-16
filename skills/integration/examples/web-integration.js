/**
 * Notifly JavaScript SDK integration (example)
 *
 * Minimal browser-only pattern for React/Next.js/Vite/etc.
 *
 * Notes:
 * - SDK 2.5.0+ usually needs only projectId, username, password in code.
 * - Web push options such as VAPID, serviceWorkerPath, askPermission, and prompt
 *   delay come from Notifly Console website SDK settings.
 * - For Web Push, serve a Service Worker file that imports NotiflyServiceWorker.js.
 * - Credentials should be injected via env/secrets; do not hardcode real values.
 */

import { useEffect, useRef } from "react";
import notifly from "notifly-js-sdk";

export function useNotiflyWeb() {
  const initialized = useRef(false);

  useEffect(() => {
    if (initialized.current) return;
    if (typeof window === "undefined") return;

    initialized.current = true;

    notifly.initialize({
      projectId: process.env.NEXT_PUBLIC_NOTIFLY_PROJECT_ID,
      username: process.env.NEXT_PUBLIC_NOTIFLY_PROJECT_USERNAME,
      password: process.env.NEXT_PUBLIC_NOTIFLY_PROJECT_PASSWORD,
      // Only enable when a web-popup HTML template needs to emit custom events.
      // allowUserSuppliedLogEvent: true,
    });
  }, []);
}

export async function loginNotifly(userId, userProperties = {}) {
  // Recommended order after login: setUserId -> setUserProperties -> trackEvent.
  await notifly.setUserId(userId);
  if (Object.keys(userProperties).length > 0) {
    await notifly.setUserProperties(userProperties);
  }
  await notifly.trackEvent("login");
}

export async function logoutNotifly() {
  // Warning: per docs, null/unset unregisters the user and can remove user data.
  await notifly.setUserId(null);
}

export function setNotiflyUserProperties(props) {
  return notifly.setUserProperties(props);
}

export function trackNotiflyEvent(name, params, segmentationEventParamKeys) {
  // segmentationEventParamKeys supports at most one key.
  return notifly.trackEvent(name, params, segmentationEventParamKeys);
}

export function requestNotiflyPushPermission(language) {
  // Manual prompt requires SDK 2.7.0+ and console auto prompt disabled.
  return notifly.requestPermission(language);
}

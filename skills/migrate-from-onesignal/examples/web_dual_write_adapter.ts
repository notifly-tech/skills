import notifly from 'notifly-sdk';

type JsonMap = Record<string, unknown>;

declare global {
  interface Window {
    OneSignalDeferred?: Array<(oneSignal: any) => void | Promise<void>>;
  }
}

function stringifyOneSignalTags(properties: JsonMap): Record<string, string> {
  return Object.fromEntries(
    Object.entries(properties)
      .filter(([, value]) => value !== null && value !== undefined && typeof value !== 'object')
      .map(([key, value]) => [key, String(value)]),
  );
}

export class OneSignalNotiflyWebDualWriteAdapter {
  private oneSignalReady(callback: (oneSignal: any) => void | Promise<void>) {
    window.OneSignalDeferred = window.OneSignalDeferred || [];
    window.OneSignalDeferred.push(callback);
  }

  initializeNotifly(params: { projectId: string; username: string; serviceWorkerPath: string }) {
    notifly.initialize({
      projectId: params.projectId,
      username: params.username,
      serviceWorkerPath: params.serviceWorkerPath,
    });
  }

  setUserId(userId?: string | null) {
    this.oneSignalReady((OneSignal) => {
      if (userId) OneSignal.login(userId);
      else OneSignal.logout();
    });
    notifly.setUserId(userId ?? null);
  }

  setUserProperties(properties: JsonMap) {
    const tags = stringifyOneSignalTags(properties);
    if (Object.keys(tags).length > 0) {
      this.oneSignalReady((OneSignal) => OneSignal.User.addTags(tags));
    }
    notifly.setUserProperties(properties);
  }

  trackEvent(eventName: string, eventParams: JsonMap = {}, segmentationEventParamKeys?: string[]) {
    this.oneSignalReady((OneSignal) => OneSignal.User.trackEvent(eventName, eventParams));
    notifly.trackEvent(eventName, eventParams, segmentationEventParamKeys);
  }
}

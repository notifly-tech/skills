import notifly from 'notifly-sdk';

type JsonMap = Record<string, unknown>;

type BrazeWebBridge = {
  changeUser?: (userId: string | null) => void;
  setUserProperties?: (properties: JsonMap) => void;
  trackEvent?: (eventName: string, eventParams?: JsonMap) => void;
};

let initialized = false;

export class BrazeNotiflyWebDualWriteAdapter {
  constructor(private readonly braze: BrazeWebBridge = {}) {}

  initializeNotifly(params: {
    projectId: string;
    username: string;
    serviceWorkerPath?: string;
  }) {
    if (initialized) return;
    initialized = true;

    notifly.initialize({
      projectId: params.projectId,
      username: params.username,
      serviceWorkerPath: params.serviceWorkerPath ?? '/notifly-service-worker.js',
    });
  }

  setUserId(userId: string | null) {
    this.braze.changeUser?.(userId);
    notifly.setUserId(userId);
  }

  setUserProperties(properties: JsonMap) {
    this.braze.setUserProperties?.(properties);
    notifly.setUserProperties(properties);
  }

  trackEvent(eventName: string, eventParams?: JsonMap) {
    this.braze.trackEvent?.(eventName, eventParams);
    notifly.trackEvent(eventName, eventParams);
  }
}

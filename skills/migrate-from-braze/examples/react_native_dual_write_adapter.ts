import notifly from 'notifly-sdk';

type JsonMap = Record<string, unknown>;

type BrazeBridge = {
  changeUser?: (userId?: string) => void | Promise<void>;
  setUserProperties?: (properties: JsonMap) => void | Promise<void>;
  trackEvent?: (eventName: string, eventParams?: JsonMap) => void | Promise<void>;
};

export class BrazeNotiflyDualWriteAdapter {
  constructor(private readonly braze: BrazeBridge = {}) {}

  initializeNotifly(params: { projectId: string; username: string }) {
    notifly.initialize({
      projectId: params.projectId,
      username: params.username,
      // password is a legacy placeholder. Do not put a real password/API secret here.
      password: params.username,
    });
  }

  async setUserId(userId?: string) {
    await this.braze.changeUser?.(userId);
    notifly.setUserId(userId);
  }

  async setUserProperties(properties: JsonMap) {
    await this.braze.setUserProperties?.(properties);
    notifly.setUserProperties(properties);
  }

  async trackEvent(eventName: string, eventParams?: JsonMap) {
    await this.braze.trackEvent?.(eventName, eventParams);
    notifly.trackEvent(eventName, eventParams);
  }
}

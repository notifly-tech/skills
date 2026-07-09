import { OneSignal } from 'react-native-onesignal';
import notifly from 'notifly-sdk';

type JsonMap = Record<string, unknown>;

function stringifyOneSignalTags(properties: JsonMap): Record<string, string> {
  return Object.fromEntries(
    Object.entries(properties)
      .filter(([, value]) => value !== null && value !== undefined && typeof value !== 'object')
      .map(([key, value]) => [key, String(value)]),
  );
}

export class OneSignalNotiflyDualWriteAdapter {
  initializeNotifly(params: { projectId: string; username: string }) {
    notifly.initialize({
      projectId: params.projectId,
      username: params.username,
      // password is a legacy placeholder. Do not put a real password/API secret here.
      password: params.username,
    });
  }

  setUserId(userId?: string) {
    if (userId) {
      OneSignal.login(userId);
    } else {
      OneSignal.logout();
    }
    notifly.setUserId(userId);
  }

  setUserProperties(properties: JsonMap) {
    // OneSignal tags are string-only; Notifly can preserve richer property types.
    const tags = stringifyOneSignalTags(properties);
    if (Object.keys(tags).length > 0) {
      OneSignal.User.addTags(tags);
    }
    notifly.setUserProperties(properties);
  }

  trackEvent(eventName: string, eventParams: JsonMap = {}, segmentationEventParamKeys?: string[]) {
    OneSignal.User.trackEvent(eventName, eventParams);
    notifly.trackEvent(eventName, eventParams, segmentationEventParamKeys);
  }
}

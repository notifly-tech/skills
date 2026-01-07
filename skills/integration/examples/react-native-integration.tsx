// React Native Notifly SDK Integration Example
//
// Source of truth:
// - Docs: https://docs.notifly.tech/ko/developer-guide/react-native-sdk.md
// - Official example: https://github.com/team-michael/notifly-react-native-sdk
// - NPM package: https://www.npmjs.com/package/notifly-sdk
//
// Notes:
// - React Native integration requires native setup on iOS/Android (AppDelegate.mm / Application).
// - After native setup, you can use the JS API from `notifly-sdk`.

// @ts-expect-error - example file; `notifly-sdk` is installed in the consumer app, not this repo
import notifly from "notifly-sdk";

// Official SDK sample shows setUserId / setUserProperties / setEmail / setPhoneNumber / setTimezone:
// https://github.com/team-michael/notifly-react-native-sdk/blob/main/example/src/MyPage.js

export async function setUserIdExample(userID?: string) {
  await notifly.setUserId(userID);
}

export async function removeUserIdExample() {
  await notifly.setUserId();
}

export async function setUserPropertiesExample(key: string, value: string) {
  await notifly.setUserProperties({
    [key]: value,
  });
}

export async function setEmailExample(email: string) {
  await notifly.setEmail(email);
}

export async function setPhoneNumberExample(phoneNumber: string) {
  await notifly.setPhoneNumber(phoneNumber);
}

export async function setTimezoneExample(timezone: string) {
  await notifly.setTimezone(timezone);
}

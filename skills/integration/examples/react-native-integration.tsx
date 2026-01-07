// React Native Notifly SDK 연동 예시
//
// 단일 기준(Source of Truth):
// - 문서: https://docs.notifly.tech/ko/developer-guide/react-native-sdk.md
// - 공식 예시: https://github.com/team-michael/notifly-react-native-sdk
// - NPM 패키지: https://www.npmjs.com/package/notifly-sdk
//
// 참고:
// - React Native 연동에는 iOS/Android 네이티브 설정(AppDelegate.mm / Application)이 필요합니다.
// - 네이티브 설정 이후 `notifly-sdk`의 JS API를 사용할 수 있습니다.

// @ts-expect-error - 예시 파일입니다. `notifly-sdk`는 이 레포가 아니라 실제 앱 프로젝트에 설치됩니다.
import notifly from "notifly-sdk";

// 공식 SDK 샘플에는 setUserId / setUserProperties / setEmail / setPhoneNumber / setTimezone가 포함됩니다:
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

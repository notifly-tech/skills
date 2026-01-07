# Notifly SDK Integration Error Handling

This guide covers common integration errors and how to fix them.

## 1) Credentials missing / incorrect

Symptoms:

- SDK initializes but nothing appears in console
- auth-related logs/errors

Fix:

- Ensure you have **all three** values:
  - `NOTIFLY_PROJECT_ID`
  - `NOTIFLY_USERNAME`
  - `NOTIFLY_PASSWORD`
- Confirm they come from `https://console.notifly.tech/` (Project Settings → SDK
  credentials)

## 2) iOS: Firebase not initialized

Symptoms:

- Logs similar to “FirebaseApp is not initialized. Please initialize FirebaseApp
  before calling Notifly.initialize.”

Fix:

- Call `FirebaseApp.configure()` **before** `Notifly.initialize(...)`.

## 3) iOS: Push doesn’t arrive

Fix checklist:

- Enable **Push Notifications** capability
- Enable **Background Modes**: Remote notifications + Background fetch
- APNs auth key/cert uploaded to Firebase
- `application.registerForRemoteNotifications()` called
- Forward APNs token via
  `Notifly.application(...didRegisterForRemoteNotificationsWithDeviceToken: ...)`

## 4) Android: Dependency not resolved

Symptoms:

- Gradle cannot resolve `com.github.team-michael:notifly-android-sdk`

Fix:

- Add JitPack:
  - `maven { url 'https://jitpack.io' }`

## 5) React Native: Wrong npm package

Fix:

- The package is **unscoped**: `notifly-sdk`

## 6) Flutter: iOS build issues

Fix:

- Open **Runner.xcworkspace** (not `.xcodeproj`)
- Run `cd ios && pod install`

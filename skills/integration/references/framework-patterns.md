# Notifly SDK Integration Patterns (Framework-Friendly)

This document provides _implementation patterns_ you can adapt, but the **source
of truth** is the official Notifly docs:

- `https://docs.notifly.tech/ko/developer-guide/ios-sdk.md`
- `https://docs.notifly.tech/ko/developer-guide/android-sdk.md`
- `https://docs.notifly.tech/ko/developer-guide/react-native-sdk.md`
- `https://docs.notifly.tech/ko/developer-guide/flutter-sdk.md`

## Shared prerequisites

- Notifly push depends on **Firebase Cloud Messaging (FCM)**.
- iOS requires APNs auth key/cert registered in Firebase.

## iOS (Swift / SwiftUI)

- Ensure Firebase is initialized first.
- Initialize Notifly in `application(_:didFinishLaunchingWithOptions:)`.

Key calls:

- `UNUserNotificationCenter.current().requestAuthorization(...)`
- `FirebaseApp.configure()`
- `Notifly.initialize(projectId:username:password)`
- `UNUserNotificationCenter.current().delegate = self`
- `Notifly.application(_:didRegisterForRemoteNotificationsWithDeviceToken:)`

## Android (Kotlin)

- Add JitPack repo + Notifly SDK dependency.
- Initialize in `Application.onCreate()`.

Key call:

- `Notifly.initialize(applicationContext, projectId, username, password)`

## React Native

- Install `notifly-sdk` and complete native setup (iOS + Android).
- Use JS API after initialization:

- `notifly.setUserId(userId)`
- `notifly.setUserProperties({...})`
- `notifly.trackEvent(name, params)`

## Flutter

- Add `notifly_flutter`
- Initialize:

- `await NotiflyPlugin.initialize(projectId: ..., username: ..., password: ...)`
- Optional: `NotiflyPlugin.inAppEvents.listen(...)`

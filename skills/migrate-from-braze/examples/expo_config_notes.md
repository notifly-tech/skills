# Expo migration notes

Use `examples/react_native_dual_write_adapter.ts` for JS-level dual-write.

Before adding native SDK configuration, determine the Expo mode:

1. Expo Go only: do not assume native Braze/Notifly push SDK migration is possible.
2. Development build / EAS / prebuild: follow `references/platforms/react-native.md` plus the native
   iOS and Android references.
3. If a config plugin exists for the current Braze setup, mirror its responsibilities for Notifly:
   - iOS deployment target/capabilities
   - APNs notification forwarding
   - Notification Service Extension/App Groups when rich push is required
   - Android manifest/Application/FCM setup

Always inspect generated `ios/` and `android/` diffs after `expo prebuild` before committing.

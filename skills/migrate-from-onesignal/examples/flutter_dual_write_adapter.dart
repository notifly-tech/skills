import 'dart:async';

import 'package:notifly_flutter/notifly_flutter.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

/// Small migration seam for OneSignal -> Notifly.
///
/// In coexist mode, route app-level identity/properties/events through this adapter.
/// In complete mode, remove the OneSignal calls and keep only the Notifly calls.
class OneSignalNotiflyDualWriteAdapter {
  Future<void> initializeNotifly({
    required String projectId,
    required String username,
  }) async {
    await NotiflyPlugin.initialize(
      projectId: projectId,
      username: username,
      // Compatibility placeholder only. Do not put an API secret in mobile code.
      password: username,
    );
  }

  Future<void> setUserId(String? userId) async {
    if (userId == null || userId.isEmpty) {
      OneSignal.logout();
    } else {
      OneSignal.login(userId);
    }
    await NotiflyPlugin.setUserId(userId);
  }

  Future<void> setUserProperties(Map<String, Object?> properties) async {
    final compact = <String, Object>{
      for (final entry in properties.entries)
        if (entry.value != null) entry.key: entry.value!,
    };
    if (compact.isEmpty) return;

    // OneSignal tags are string-only. Keep this conversion explicit so campaign
    // owners can review bool/number/timestamp semantics during migration.
    OneSignal.User.addTags(compact.map((key, value) => MapEntry(key, '$value')));
    await NotiflyPlugin.setUserProperties(compact);
  }

  Future<void> trackEvent(
    String eventName, {
    Map<String, Object?> eventParams = const {},
    List<String>? segmentationEventParamKeys,
  }) async {
    final compactParams = <String, Object>{
      for (final entry in eventParams.entries)
        if (entry.value != null) entry.key: entry.value!,
    };

    OneSignal.User.trackEvent(eventName, compactParams);
    await NotiflyPlugin.trackEvent(
      eventName: eventName,
      eventParams: compactParams,
      segmentationEventParamKeys: segmentationEventParamKeys,
    );
  }

  StreamSubscription<InAppMessageEvent> listenInAppEvents(
    void Function(InAppMessageEvent event) onEvent,
  ) {
    return NotiflyPlugin.inAppEvents.listen(onEvent);
  }
}

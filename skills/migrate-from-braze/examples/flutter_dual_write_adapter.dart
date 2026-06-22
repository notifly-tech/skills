import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:notifly_flutter/notifly_flutter.dart';

/// Small migration seam for Braze -> Notifly.
///
/// In coexist mode, keep the existing Braze implementation behind callbacks and
/// add Notifly next to it. In complete mode, remove the Braze callbacks and keep
/// only the Notifly calls.
class MarketingMigrationAdapter {
  MarketingMigrationAdapter({
    this.onBrazeSetUserId,
    this.onBrazeSetUserProperties,
    this.onBrazeTrackEvent,
    this.dualWrite = false,
  });

  final bool dualWrite;
  final FutureOr<void> Function(String? userId)? onBrazeSetUserId;
  final FutureOr<void> Function(Map<String, Object?> properties)?
      onBrazeSetUserProperties;
  final FutureOr<void> Function(
    String eventName,
    Map<String, Object?> eventParams,
  )? onBrazeTrackEvent;

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
    if (dualWrite) {
      // In coexist mode, preserve the existing Braze path even if the new
      // Notifly write fails during rollout.
      await onBrazeSetUserId?.call(userId);
    }
    await NotiflyPlugin.setUserId(userId);
  }

  Future<void> setUserProperties(Map<String, Object?> properties) async {
    // Drop nulls unless the target app has a deliberate null-clearing contract.
    final compact = <String, Object>{
      for (final entry in properties.entries)
        if (entry.value != null) entry.key: entry.value!,
    };

    if (compact.isEmpty) return;

    if (dualWrite) {
      // Keep Braze as the source-of-truth path during coexist; Notifly is the
      // added write and must not prevent existing Braze tracking.
      await onBrazeSetUserProperties?.call(compact);
    }
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

    if (dualWrite) {
      // Preserve the existing Braze event before attempting the new Notifly
      // write, so rollout/config/channel failures do not corrupt parity data.
      await onBrazeTrackEvent?.call(eventName, compactParams);
    }

    await NotiflyPlugin.trackEvent(
      eventName: eventName,
      eventParams: compactParams,
      segmentationEventParamKeys: segmentationEventParamKeys,
    );
  }

  Future<void> addAndroidPushClickRouter(
    void Function(Map<String, dynamic> customData) onCustomData,
  ) async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;

    await NotiflyPlugin.addNotificationClickListener((event) {
      final customData = event.notification.customData;
      if (customData == null || customData.isEmpty) return;
      onCustomData(customData);
    });
  }

  StreamSubscription<InAppMessageEvent> listenInAppEvents(
    void Function(InAppMessageEvent event) onEvent,
  ) {
    return NotiflyPlugin.inAppEvents.listen(onEvent);
  }
}

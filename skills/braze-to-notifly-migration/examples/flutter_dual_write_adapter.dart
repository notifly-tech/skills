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
    await NotiflyPlugin.setUserId(userId);
    if (dualWrite) {
      await onBrazeSetUserId?.call(userId);
    }
  }

  Future<void> setUserProperties(Map<String, Object?> properties) async {
    // Drop nulls unless the target app has a deliberate null-clearing contract.
    final compact = <String, Object>{
      for (final entry in properties.entries)
        if (entry.value != null) entry.key: entry.value!,
    };

    if (compact.isEmpty) return;

    await NotiflyPlugin.setUserProperties(compact);
    if (dualWrite) {
      await onBrazeSetUserProperties?.call(compact);
    }
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

    await NotiflyPlugin.trackEvent(
      eventName: eventName,
      eventParams: compactParams,
      segmentationEventParamKeys: segmentationEventParamKeys,
    );

    if (dualWrite) {
      await onBrazeTrackEvent?.call(eventName, compactParams);
    }
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

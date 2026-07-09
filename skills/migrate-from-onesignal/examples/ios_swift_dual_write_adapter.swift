import Foundation
import OneSignalFramework
import notifly_sdk

/// Small migration seam for OneSignal -> Notifly.
///
/// In coexist mode, keep app-level identity/properties/events behind this adapter.
/// In complete mode, remove the OneSignal calls and keep only the Notifly calls.
final class OneSignalNotiflyDualWriteAdapter {
    func initializeNotifly(projectId: String, username: String) {
        Notifly.initialize(
            projectId: projectId,
            username: username,
            // Compatibility placeholder only. Do not put an API secret in mobile code.
            password: username
        )
    }

    func setUserId(_ userId: String?) {
        if let userId, !userId.isEmpty {
            OneSignal.login(userId)
        } else {
            OneSignal.logout()
        }
        Notifly.setUserId(userId: userId)
    }

    func setUserProperties(_ properties: [String: Any]) {
        let tags = properties.compactMapValues(Self.tagValue)
        if !tags.isEmpty {
            // OneSignal tags are string-only. Keep this conversion explicit so campaign
            // owners can review bool/number/timestamp semantics during migration.
            OneSignal.User.addTags(tags)
        }
        Notifly.setUserProperties(userProperties: properties)
    }

    func trackEvent(
        _ eventName: String,
        eventParams: [String: Any] = [:],
        segmentationEventParamKeys: [String]? = nil
    ) {
        OneSignal.User.trackEvent(name: eventName, properties: eventParams)
        Notifly.trackEvent(
            eventName: eventName,
            eventParams: eventParams,
            segmentationEventParamKeys: segmentationEventParamKeys
        )
    }

    private static func tagValue(_ value: Any) -> String? {
        switch value {
        case let value as String:
            return value
        case let value as Bool:
            return value ? "true" : "false"
        case let value as NSNumber:
            return value.stringValue
        default:
            return nil
        }
    }
}

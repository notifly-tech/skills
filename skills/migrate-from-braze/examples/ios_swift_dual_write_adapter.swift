import Foundation
import notifly_sdk

/// Coexist-mode adapter sketch.
/// Keep existing Braze wiring outside this file and inject closures so the migration
/// does not spread vendor-specific calls across the app.
final class BrazeNotiflyDualWriteAdapter {
    private let brazeChangeUser: ((String?) -> Void)?
    private let brazeSetUserProperties: (([String: Any]) -> Void)?
    private let brazeTrackEvent: ((String, [String: Any]?) -> Void)?

    init(
        brazeChangeUser: ((String?) -> Void)? = nil,
        brazeSetUserProperties: (([String: Any]) -> Void)? = nil,
        brazeTrackEvent: ((String, [String: Any]?) -> Void)? = nil
    ) {
        self.brazeChangeUser = brazeChangeUser
        self.brazeSetUserProperties = brazeSetUserProperties
        self.brazeTrackEvent = brazeTrackEvent
    }

    func initializeNotifly(projectId: String, username: String) {
        // password is a legacy placeholder. Do not put a real password/API secret here.
        Notifly.initialize(projectId: projectId, username: username, password: username)
    }

    func setUserId(_ userId: String?) {
        brazeChangeUser?(userId)
        Notifly.setUserId(userId: userId)
    }

    func setUserProperties(_ properties: [String: Any]) {
        brazeSetUserProperties?(properties)
        Notifly.setUserProperties(userProperties: properties)
    }

    func trackEvent(_ name: String, params: [String: Any]? = nil) {
        brazeTrackEvent?(name, params)
        Notifly.trackEvent(eventName: name, eventParams: params)
    }
}

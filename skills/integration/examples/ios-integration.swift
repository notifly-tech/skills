// iOS Notifly SDK Integration Example (Swift)
//
// Source of truth:
// - Docs: https://docs.notifly.tech/ko/developer-guide/ios-sdk.md
// - Official example: https://github.com/team-michael/notifly-ios-sdk
//
// Notes:
// - Notifly requires FirebaseApp to be initialized first.
// - You must enable Push Notifications + Background Modes (Remote notifications, Background fetch).

import Firebase
import notifly_sdk
import UIKit
import UserNotifications

class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // 1) Initialize Firebase
        // Official sample calls FirebaseApp.configure() before requesting authorization:
        // https://github.com/team-michael/notifly-ios-sdk
        FirebaseApp.configure()

        // 2) Request notification authorization, then register for remote notifications
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("Failed to request authorization: \(error)")
                return
            }

            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }

        // 3) Initialize Notifly
        // Get these values from Notifly Console (Project Settings > SDK Credentials)
        Notifly.initialize(
            projectId: "YOUR_PROJECT_ID",
            username: "YOUR_USERNAME",
            password: "YOUR_PASSWORD"
        )
        
        // 4) Set UNUserNotificationCenter delegate (push click + foreground handling)
        UNUserNotificationCenter.current().delegate = self
        
        return true
    }
    
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        // Forward APNs token to Notifly
        Notifly.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    }
    
    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        // Forward APNs registration failure to Notifly
        Notifly.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
    }
    
    // Push click handling
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        Notifly.userNotificationCenter(center, didReceive: response)
        completionHandler()
    }
    
    // Foreground push presentation handling
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        Notifly.userNotificationCenter(center, willPresent: notification, withCompletionHandler: completionHandler)
    }
}

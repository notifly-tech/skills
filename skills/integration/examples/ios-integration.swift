// iOS Notifly SDK 연동 예시 (Swift)
//
// 단일 기준(Source of Truth):
// - 문서: https://docs.notifly.tech/ko/developer-guide/ios-sdk.md
// - 공식 예시: https://github.com/team-michael/notifly-ios-sdk
//
// 참고:
// - Notifly는 FirebaseApp이 먼저 초기화되어 있어야 합니다.
// - Push Notifications + Background Modes(Remote notifications, Background fetch)를 활성화해야 합니다.

import Firebase
import notifly_sdk
import UIKit
import UserNotifications

class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // 1) Firebase 초기화
        // 공식 샘플은 권한 요청 전에 FirebaseApp.configure()를 호출합니다:
        // https://github.com/team-michael/notifly-ios-sdk
        FirebaseApp.configure()

        // 2) 알림 권한 요청 후 remote notifications 등록
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("알림 권한 요청 실패: \(error)")
                return
            }

            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }

        // 3) Notifly 초기화
        // 값은 Notifly 콘솔(Project Settings > SDK Credentials)에서 확인하세요.
        Notifly.initialize(
            projectId: "YOUR_PROJECT_ID",
            username: "YOUR_USERNAME",
            password: "YOUR_PASSWORD"
        )
        
        // 4) UNUserNotificationCenter delegate 설정(푸시 클릭 + 포그라운드 처리)
        UNUserNotificationCenter.current().delegate = self
        
        return true
    }
    
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        // APNs 토큰을 Notifly로 전달
        Notifly.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    }
    
    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        // APNs 등록 실패를 Notifly로 전달
        Notifly.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
    }
    
    // 푸시 클릭 처리
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        Notifly.userNotificationCenter(center, didReceive: response)
        completionHandler()
    }
    
    // 포그라운드 푸시 표시 옵션 처리
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        Notifly.userNotificationCenter(center, willPresent: notification, withCompletionHandler: completionHandler)
    }
}

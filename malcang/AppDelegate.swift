import UIKit
import Firebase
import FirebaseMessaging
import UserNotifications
import KakaoSDKCommon

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        Thread.sleep(forTimeInterval: 2.0)
        FirebaseApp.configure()
        KakaoSDK.initSDK(appKey: "c059fa6e70fc95110a8af130c90352de")
        
        Messaging.messaging().delegate = self
        Messaging.messaging()
            .token { token, error in
                if let error = error {
                    print("(ERROR) AppDelegate: FCM_TOKEN - \(error.localizedDescription)")
                } else if let token = token {
                    print("(DEBUG) AppDelegate: FCM_TOKEN: \(token)")
                    AppStorage.fcmToken = token
                }
            }
        
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .badge, .sound]) { _ , error in
            if let error = error {
                print("(ERROR) AppDelegate: request notification authroization - \(error.localizedDescription)")
            }
        }
        
        application.registerForRemoteNotifications()
        return true
    }
    
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable : Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        print("(DEBUG) AppDelegate.didReceiveRemoteNotification: \(userInfo)")
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    func application(
        _ application: UIApplication,
        supportedInterfaceOrientationsFor window: UIWindow?
    ) -> UIInterfaceOrientationMask {
        return [.portrait]
    }

    
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        let userInfo = notification.request.content.userInfo
        print("(DEBUG) AppDelegate.willPresent: \(userInfo)")
        if #available(iOS 14.0, *) {
            completionHandler([.list, .banner, .badge, .sound])
        } else {
            completionHandler([.badge, .sound])
        }
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        print("(DEBUG) AppDelegate.didReceive: \(userInfo)")
        completionHandler()
    }
    
}

extension AppDelegate: MessagingDelegate {
    
    func messaging(
        _ messaging: Messaging,
        didReceiveRegistrationToken fcmToken: String?
    ) {
        if let token = fcmToken {
            print("(DEBUG) DID RECEIVE FCM TOKEN: \(token)")
            AppStorage.fcmToken = token
        }
    }
    
}

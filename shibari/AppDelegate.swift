import SwiftUI
import FirebaseCore
import FirebaseMessaging
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        // 通知のデリゲートを設定（フォアグラウンドでの通知受信などを制御）
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { granted, error in
            if granted {
                print("通知が許可されました！")
            } else {
                print("通知が拒否されました。")
            }
        }
        
        // FCMのデリゲートを設定（トークンの更新などを検知）
        Messaging.messaging().delegate = self
                
        // Appleのプッシュ通知サービス（APNs）へ端末を登録
        application.registerForRemoteNotifications()
        
        return true
    }
    
    // Appleからデバイストークン（APNsトークン）を受け取ったら、それをFirebase(FCM)に渡す
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
        
    // FCMトークンが新しく生成・更新された時に呼ばれる
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("FCMトークンが更新されました: \(String(describing: fcmToken))")
        // （※ここで最新のトークンをFirestoreに保存し直す処理を入れるとさらに堅牢になります）
    }
}

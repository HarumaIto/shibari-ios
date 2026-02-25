//
//  shibariApp.swift
//  shibari
//
//  Created by Haruma Ito on 2026/02/24.
//

import SwiftUI
import FirebaseCore // Firebaseの初期化用
import FirebaseMessaging 
import UserNotifications

// Firebaseを初期化するためのデリゲート
class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        // 通知のデリゲートを設定（フォアグラウンドでの通知受信などを制御）
        UNUserNotificationCenter.current().delegate = self
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

@main
struct shibariApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            RootView()
                .preferredColorScheme(.dark)
                .tint(.tacticalRed)
        }
    }
}

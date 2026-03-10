//
//  shibariApp.swift
//  shibari
//
//  Created by Haruma Ito on 2026/02/24.
//

import SwiftUI
import GoogleSignIn
import UserNotifications

@main
struct shibariApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var diContainer = AppDIContainer()
    @Environment(\.scenePhase) var scenePhase

    var body: some Scene {
        WindowGroup {
            diContainer.makeRootView()
                .environmentObject(diContainer)
                .preferredColorScheme(.dark)
                .tint(.tacticalRed)
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .active {
                // アプリが開かれた（アクティブになった）時に通知をクリア
                clearNotifications()
            }
        }
    }
    
    private func clearNotifications() {
        let center = UNUserNotificationCenter.current()
        
        // 1. 通知センターに残っているこのアプリの通知をすべて消去
        center.removeAllDeliveredNotifications()
        
        // 2. アプリアイコンのバッジ（赤い丸の数字）を0にする
        center.setBadgeCount(0) { error in
            if let error = error {
                print("バッジのクリアに失敗しました: \(error)")
            }
        }
    }
}

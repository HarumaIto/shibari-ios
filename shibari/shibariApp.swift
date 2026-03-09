//
//  shibariApp.swift
//  shibari
//
//  Created by Haruma Ito on 2026/02/24.
//

import SwiftUI
import GoogleSignIn

@main
struct shibariApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var diContainer = AppDIContainer()

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
    }
}

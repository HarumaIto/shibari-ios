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

    var body: some Scene {
        WindowGroup {
            RootView()
                .preferredColorScheme(.dark)
                .tint(.tacticalRed)
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
        }
    }
}

//
//  AppDelegate.swift
//  MultiFactor
//
//  Created by g.lofrumento on 21/07/22.
//

import SwiftUI

import FirebaseCore

#if os(iOS)
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()

        return true
    }
}
#elseif os(macOS)
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        FirebaseApp.configure()
    }
}
#endif

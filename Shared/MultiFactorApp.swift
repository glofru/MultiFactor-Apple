//
//  MultiFactorApp.swift
//  Shared
//
//  Created by g.lofrumento on 19/07/22.
//

import SwiftUI

@main
struct MultiFactorApp: App {

#if os(iOS)
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
#elseif os(macOS)
    @NSApplicationDelegateAdaptor(AppDelegate.self) var delegate
#endif

    let persistenceController = PersistenceController.shared

    @StateObject private var authenticationViewModel = AuthenticationViewModel()

    var body: some Scene {
        WindowGroup {
            ZStack {
                // Background
                #if os(macOS)
                VisualEffectView()
                    .edgesIgnoringSafeArea(.all)
                #endif

                // Actual content
                ContentView()
                    .environmentObject(authenticationViewModel)
            }
            #if os(macOS)
                .frame(minWidth: 400, idealWidth: 400, maxWidth: 400)
                .buttonStyle(.plain)
                .onAppear {
                    DispatchQueue.main.async {
                        NSApplication.shared.windows.forEach({ window in
                            window.standardWindowButton(.zoomButton)?.isHidden = true
                        })
                    }
                }
            #endif
                
        }
        #if os(macOS)
        .windowStyle(.hiddenTitleBar)
        #endif
    }
}

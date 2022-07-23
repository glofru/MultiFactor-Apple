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

    var body: some Scene {
        WindowGroup {
            ZStack {
                // Background
                #if os(iOS)
                Color.background
                    .ignoresSafeArea(.all)
                #elseif os(macOS)
                VisualEffectView()
                    .edgesIgnoringSafeArea(.all)
                #endif

                // Actual content
                ContentView()
            }
            #if os(macOS)
                .frame(minWidth: 400, idealWidth: 400)
                .buttonStyle(.plain)
            #endif
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                
        }
        #if os(macOS)
        .windowStyle(.hiddenTitleBar)
        #endif
    }
}

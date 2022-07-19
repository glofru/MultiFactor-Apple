//
//  MultiFactorApp.swift
//  Shared
//
//  Created by g.lofrumento on 19/07/22.
//

import SwiftUI

@main
struct MultiFactorApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

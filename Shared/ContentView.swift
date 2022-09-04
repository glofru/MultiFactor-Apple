//
//  ContentView.swift
//  Shared
//
//  Created by g.lofrumento on 19/07/22.
//

import SwiftUI
import CoreData

struct ContentView: View {

    @Environment(\.scenePhase) private var scenePhase

    @StateObject private var authenticationViewModel = AuthenticationViewModel()

    var body: some View {
        Group {
            switch authenticationViewModel.state {
            case .signedInCloud:
                MasterLoginView()
            case .signedInMaster:
                HomeView()
            case .signedOut:
                LoginView()
            case .unknown:
                ProgressView()
            }
        }
        .mfStyle()
        .environmentObject(authenticationViewModel)
        .environment(\.managedObjectContext, PersistenceController.shared.context)
        .onChange(of: scenePhase) { newPhase in
            switch newPhase {
            case .background:
                authenticationViewModel.onBackground()
            case .inactive:
                return
            case .active:
                authenticationViewModel.onActive()
            @unknown default:
                return
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

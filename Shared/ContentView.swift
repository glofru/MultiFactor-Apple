//
//  ContentView.swift
//  Shared
//
//  Created by g.lofrumento on 19/07/22.
//

import SwiftUI
import CoreData


struct ContentView: View {

    @StateObject var authenticationViewModel = AuthenticationViewModel()

    var body: some View {
        Group {
            switch authenticationViewModel.state {
            case .signedIn:
                HomeView()
            case .signedOut:
                LoginView()
            case .unknown:
                ProgressView()
            }
        }
        .environmentObject(authenticationViewModel)
        .privacySensitive()
        .environment(\.managedObjectContext, PersistenceController.shared.context)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

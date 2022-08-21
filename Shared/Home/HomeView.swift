//
//  HomeView.swift
//  MultiFactor
//
//  Created by g.lofrumento on 21/07/22.
//

import SwiftUI

struct HomeView: View {

    @EnvironmentObject private var authenticationViewModel: AuthenticationViewModel

    @StateObject private var homeViewModel = HomeViewModel()

    var body: some View {
        Group {
            #if os(iOS)
            TabView {
                CodesView()
                    .tabItem {
                        Label("Codes", systemImage: "lock")
                    }

                AccountView()
                    .tabItem {
                        Label("Account", systemImage: "person.crop.circle")
                    }
            }
            #elseif os(macOS)
            CodesView()
//            AccountView()
            #endif
        }
        .alert(homeViewModel.error ?? "", isPresented: Binding(get: { homeViewModel.error != nil }, set: { _, _ in homeViewModel.error = nil })) { }
        .environmentObject(homeViewModel)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(AuthenticationViewModel())
    }
}

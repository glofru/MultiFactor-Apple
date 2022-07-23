//
//  HomeView.swift
//  MultiFactor
//
//  Created by g.lofrumento on 21/07/22.
//

import SwiftUI

struct HomeView: View {

//    @State private var searched = ""
    @ObservedObject var authenticationViewModel: AuthenticationViewModel

    var body: some View {
        #if os(iOS)
        TabView {
            CodeView()
                .tabItem {
                    Label("Codes", systemImage: "lock")
                }

            AccountView()
                .tabItem {
                    Label("Account", systemImage: "person.crop.circle")
                }
        }
        #elseif os(macOS)
        CodeView()
        #endif
    }
}

struct CodeView: View {
    var body: some View {
        ScrollView {
            HStack {
                Button(action: {
//                    authenticationViewModel.signOut()
                }, label: {
                    Text("Sign out")
                })
            }
            LazyVStack {
                AuthCodeView()
                AuthCodeView()
                AuthCodeView()
                Spacer()
            }
        }
        .padding()
    }
}

struct AccountView: View {
    var body: some View {
        Form {
            Section(header: Text("ABOUT")) {
                HStack {
                    Text("Version")
                    Spacer()
                    Text("\(Bundle.main.releaseVersionNumber ?? "...")")
                }
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(authenticationViewModel: AuthenticationViewModel())
    }
}

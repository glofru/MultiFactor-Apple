//
//  HomeView.swift
//  MultiFactor
//
//  Created by g.lofrumento on 21/07/22.
//

import SwiftUI

struct HomeView: View {

//    @State private var searched = ""
    @EnvironmentObject var authenticationViewModel: AuthenticationViewModel
    @StateObject var homeViewModel = HomeViewModel()

    var body: some View {
        Group {
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
            AccountView()
            #endif
        }
        .environmentObject(homeViewModel)
    }
}

struct CodeView: View {
    @EnvironmentObject var homeViewModel: HomeViewModel

    var body: some View {
        ScrollView {
            Button(action: {
                Task {
                    await homeViewModel.addOTP()
                }
            }, label: {
                Label("Add", systemImage: "plus")
            })

            if homeViewModel.otps.isEmpty {
                Text("No otps")
            } else {
                LazyVStack {
                    ForEach(homeViewModel.otps, id: \.id) { otp in
                        OTPView(code: otp)
                    }
                }
            }
        }
        .padding()
    }
}

//#if os(iOS)
struct AccountView: View {

    @EnvironmentObject var authenticationViewModel: AuthenticationViewModel
    
    @State private var showSignOut = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("PROFILE")) {
                    Text("\(PersistenceController.shared.user?.username ?? "ALOA")")
                }

                Section(header: Text("ABOUT")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("\(Bundle.main.releaseVersionNumber ?? "...")")
                    }
                }

                Section {
                    Button("Sign out", role: .destructive) {
                        showSignOut.toggle()
                    }
                    .confirmationDialog("Do you want to sign out?", isPresented: $showSignOut, titleVisibility: .visible) {
                        Button("Sign out", role: .destructive) {
                            authenticationViewModel.signOut()
                        }

                        Button("Cancel", role: .cancel) {
                            showSignOut = false
                        }
                    }
                }
            }
            .navigationTitle("Account")
        }
    }
}
//#endif

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(AuthenticationViewModel())
    }
}

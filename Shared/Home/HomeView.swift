//
//  HomeView.swift
//  MultiFactor
//
//  Created by g.lofrumento on 21/07/22.
//

import SwiftUI

struct HomeView: View {
    @Environment(\.scenePhase) var scenePhase

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
        .onReceive(MFClock.shared.$time) { time in
            homeViewModel.updateGenerateCodes(for: time)
        }
        .onChange(of: scenePhase) { newPhase in
            switch newPhase {
            case .background:
                MFClock.shared.stop()
            case .inactive:
                return
            case .active:
                MFClock.shared.start()
            @unknown default:
                return
            }
        }
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

            if homeViewModel.totps.isEmpty {
                Text("No otps")
            } else {
                LazyVStack {
                    ForEach(homeViewModel.totps, id: \.id) { totp in
                        OTPView(totpViewModel: totp)
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

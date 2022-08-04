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
//            AccountView()
            #endif
        }
        .alert(homeViewModel.error ?? "", isPresented: Binding(get: { homeViewModel.error != nil }, set: { _, _ in homeViewModel.error = nil })) { }
        .environmentObject(homeViewModel)
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .background {
                MFClock.shared.stop()
                TOTPViewModel.reset()
                authenticationViewModel.background()
            }
        }
    }
}

struct CodeView: View {
    @EnvironmentObject var homeViewModel: HomeViewModel

    @FetchRequest(sortDescriptors: [
        SortDescriptor(\EncryptedOTP.label)
    ])
    private var encryptedOTPs: FetchedResults<EncryptedOTP>

    var body: some View {
        ScrollView {
            Button(action: {
                Task {
                    await homeViewModel.addOTP()
                }
            }, label: {
                Label("Add", systemImage: "plus")
            })

            if encryptedOTPs.isEmpty {
                Text("No otps")
            } else {
                LazyVStack {
                    ForEach(encryptedOTPs, id: \.id) { otp in
                        if otp.id != nil {
                            OTPView(encryptedOTP: otp)
                        } else {
                            EmptyView()
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
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

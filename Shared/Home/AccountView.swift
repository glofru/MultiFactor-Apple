//
//  AccountView.swift
//  MultiFactor
//
//  Created by Gianluca Lofrumento on 12/08/22.
//

import SwiftUI

import LocalAuthentication

struct AccountView: View {

    @EnvironmentObject private var authenticationViewModel: AuthenticationViewModel

    @AppStorage("biometryUnlock") private var biometryUnlock: Bool = false
    @AppStorage("biometryType") private var biometryType: BiometryType?

    init() {
        if biometryType == nil {
            let context = LAContext()
            if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil) {
                biometryType = BiometryType(from: context.biometryType)
            }
        }
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("PROFILE")) {
                    Text(PersistenceController.shared.user?.username ?? "")

                    Toggle("Unlock with \(biometryType!.name)", isOn: $biometryUnlock)
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
                        authenticationViewModel.showSignOut = true
                    }
                }
            }
            .navigationTitle("Account")
        }
    }
}

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        AccountView()
    }
}

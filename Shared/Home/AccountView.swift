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

    @AppStorage(MFKeys.biometryType) private var biometryType: BiometryType?
    @AppStorage(MFKeys.biometryUnlock) private var biometryUnlock: Bool = false
    @AppStorage(MFKeys.authenticationFrequency) private var authenticationFrequency = AuthenticationFrequency.always

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

                    Picker("Authentication frequency", selection: $authenticationFrequency) {
                        ForEach(AuthenticationFrequency.allCases, id: \.self) {
                            Text($0.rawValue)
                        }
                    }

                    Toggle("Unlock with \(biometryType!.name)", isOn: $biometryUnlock)
                        .disabled(authenticationFrequency == .never)
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

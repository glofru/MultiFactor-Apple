//
//  LoginView.swift
//  MultiFactor
//
//  Created by g.lofrumento on 22/07/22.
//

import SwiftUI
import LocalAuthentication

struct LoginView: View {

    @EnvironmentObject var authenticationViewModel: AuthenticationViewModel

    @State private var username = ""
    @State private var password = ""
    @State private var isSigningIn = false

    @FocusState private var focusedField: FocusedField?

    var body: some View {
        VStack(alignment: .center) {
            Text("MultiFactor")
                .font(.title)
                .padding()

            TextField("Username", text: $username)
                .submitLabel(.next)
                .focused($focusedField, equals: .username)
                .textFieldStyle(MFLoginTextFieldStyle())
                .onSubmit {
                    focusedField = .password
                }
            #if os(iOS)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .textInputAutocapitalization(.never)
            #endif

            SecureField("Password", text: $password)
                .textContentType(.password)
                .submitLabel(.done)
                .focused($focusedField, equals: .password)
                .textFieldStyle(MFLoginTextFieldStyle())
                .onSubmit(signIn)

            if let error = authenticationViewModel.error {
                Text(error)
                    .foregroundColor(.red)
            }
        }
        .padding()
        .disabled(isSigningIn)
    }

    private func signIn() {
        focusedField = nil
        isSigningIn = true
        Task {
            if let error = await authenticationViewModel.signInCloud(method: .username(username, password)) {
                switch error {
                case .usernameEmpty: fallthrough
                case .usernameNotFound: fallthrough
                case .userDisabled: fallthrough
                case .usernameInvalid:
                    focusedField = .username
                case .passwordEmpty: fallthrough
                case .passwordInvalid: fallthrough
                case .passwordIncorrect:
                    focusedField = .password
                case .unknown(_):
                    focusedField = nil
                }
            }
            isSigningIn = false
        }
    }

    private enum FocusedField {
        case username, password
    }
}

struct MasterLoginView: View {

    @EnvironmentObject var authenticationViewModel: AuthenticationViewModel

    @AppStorage("biometryUnlock") private var biometryUnlock: Bool?
    @AppStorage("biometryType") private var biometryType: BiometryType?

    @State private var isSigningIn = false
    @State private var password = ""

    @FocusState private var focusPassword: Bool?

    var body: some View {
        VStack(alignment: .center) {
            Text("Master login")
                .font(.title)
                .padding()

            SecureField("Master password", text: $password)
                .textContentType(.password)
                .submitLabel(.done)
                .focused($focusPassword, equals: true)
                .textFieldStyle(MFLoginTextFieldStyle())
                .onSubmit(signIn)

            if biometryUnlock == true, let biometryType = biometryType {
                Button(action: {
                    Task(priority: .userInitiated) {
                        await signInBiometric()
                    }
                }, label: {
                    Label("Unlock with \(biometryType.name)", systemImage: biometryType.systemName)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 15).foregroundColor(.white))
                })
            }

            if isSigningIn {
                ProgressView()
            }

            if let error = authenticationViewModel.error {
                Text(error)
                    .foregroundColor(.red)
            }
        }
        .padding()
        .disabled(isSigningIn)
//        .task(id: "mpwd", priority: .userInitiated) {
//            if biometricUnlock {
//                await signInBiometric()
//            } else {
//                focusPassword = true
//            }
//        }
    }

    private func signIn() {
        guard !password.isEmpty else {
            return
        }
        isSigningIn = true
        Task {
            await authenticationViewModel.signInMaster(password: password)
            isSigningIn = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                focusPassword = true
            }
        }
    }

    private func signInBiometric() async {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            let reason = "We need to unlock your data."

            let success = try? await context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason)
            if success == true {
                withAnimation {
                    isSigningIn = true
                }
                Task {
                    await authenticationViewModel.signInMaster(password: "master")
                    isSigningIn = false
                }
            }
        } else {
            isSigningIn = false
        }
    }
}

private struct MFLoginTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .glassBackground(.element)
            .cornerRadius(10)
        #if os(macOS)
            .textFieldStyle(.plain)
        #endif
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(AuthenticationViewModel())
    }
}

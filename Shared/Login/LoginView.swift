//
//  LoginView.swift
//  MultiFactor
//
//  Created by g.lofrumento on 22/07/22.
//

import SwiftUI
import AuthenticationServices

struct LoginView: View {

    @Environment(\.colorScheme) var colorScheme

    @EnvironmentObject private var authenticationViewModel: AuthenticationViewModel

    @State private var username = ""
    @State private var password = ""
    @State private var isSigningIn = false
    
    @State private var appleNonce: String?

    @State private var sheet: PresentedSheet?

    @FocusState private var focusedField: FocusedField?

    var body: some View {
        VStack(alignment: .center) {
            Text("Login")
                .mfTitle()

            VStack {
                TextField("Username", text: $username)
                    .submitLabel(.next)
                    .focused($focusedField, equals: .username)
                    .onSubmit {
                        focusedField = .password
                    }
                    .padding(.vertical)
                    .disableAutocorrection(true)
                #if os(iOS)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .textInputAutocapitalization(.never)
                #endif

                PasswordTextField(text: $password)
                    .submitLabel(.done)
                    .focused($focusedField, equals: .password)
                    .onSubmit(signInPassword)
                    .disableAutocorrection(true)
                #if os(iOS)
                    .textContentType(.password)
                    .textInputAutocapitalization(.never)
                #endif

                if let error = authenticationViewModel.signInError {
                    Text(error)
                        .mfError()
                }

                Button(action: {
                    sheet = .forgotPassword
                }, label: {
                    Text("Forgot password?")
                        .foregroundColor(.label)
                        .padding(.vertical)
                })
            }

            Button(action: signInPassword, label: {
                if isSigningIn {
                    ProgressView()
                        .gradientBackground(.login)
                } else {
                    Text("Login")
                        .gradientBackground(.login)
                }
            })

            HStack {
                Spacer()
                Text("or")
                Spacer()
            }
            .padding()

            Button(action: {
                sheet = .signUp
            }, label: {
                Text("Sign Up")
                    .gradientBackground(.signUp)
            })
            
            SignInWithAppleButton(.continue) { request in
                request.requestedScopes = [.email]
                appleNonce = UUID().uuidString
                request.nonce = MFCipher.hash(appleNonce!)
            } onCompletion: { result in
                switch result {
                case .success(let authorization):
                    signWithApple(authorization)
                case .failure(let error):
                    authenticationViewModel.signInError = error.localizedDescription
                }
            }
            .frame(height: 60, alignment: .center)
            .cornerRadius(12)
            .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)

            Spacer()
        }
        .padding()
        .animation(.default, value: authenticationViewModel.signInError)
        .disabled(isSigningIn)
        .sheet(item: $sheet, onDismiss: {
            sheet = nil
        }) { type in
            switch type {
            case .signUp:
                SignUpView()
            case .forgotPassword:
                ForgotPasswordView()
            }
        }
    }

    private func signInPassword() {
        focusedField = nil
        isSigningIn = true
        Task {
            if let error = await authenticationViewModel.signInCloud(method: .password(username, password)) {
                await MainActor.run {
                    switch error {
                    case .usernameEmpty: fallthrough
                    case .usernameNotFound: fallthrough
                    case .userDisabled: fallthrough
                    case .usernameInvalid:
                        focusedField = .username
                    case .passwordEmpty: fallthrough
                    case .passwordInvalid: fallthrough
                    case .passwordIncorrect: fallthrough
                    case .passwordsDoNotMatch:
                        focusedField = .password
                    case .unknown:
                        focusedField = nil
                    }
                }
            }
            await MainActor.run {
                isSigningIn = false
            }
        }
    }
    
    public func signWithApple(_ authorization: ASAuthorization) {
        if let credential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let token = String(data: credential.identityToken!, encoding: .utf8)!
            
            Task {
                await authenticationViewModel.signInCloud(method: .apple(token, appleNonce!))
            }
        }
    }

    private enum FocusedField {
        case username, password
    }

    private enum PresentedSheet: Identifiable {
        case signUp, forgotPassword

        var id: UUID {
            UUID()
        }
    }
    
    private enum PresentedAlert: Identifiable {
        case signWithAppleError(String)

        var id: UUID {
            UUID()
        }
    }
}

struct MasterLoginView: View {

    @EnvironmentObject private var authenticationViewModel: AuthenticationViewModel

    @Environment(\.scenePhase) private var scenePhase

    @AppStorage(MFKeys.biometryType) private var biometryType = BiometryType.none
    @AppStorage(MFKeys.biometryUnlock) private var biometryUnlock = false

    @State private var isSigningIn = false
    @State private var password = ""

    @FocusState private var focusPassword: Bool?

    var body: some View {
        VStack(alignment: .center) {
            Spacer()

            Text("Master login")
                .font(.title)
                .padding()

            SecureField("Master password", text: $password)
                .textContentType(.password)
                .submitLabel(.done)
                .focused($focusPassword, equals: true)
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
            } else if let error = authenticationViewModel.signInError {
                Text(error)
                    .mfError()
            }

            Spacer()

            Button(role: .destructive, action: {
                authenticationViewModel.signOut()
            }, label: {
                Text("Sign out")
                    .gradientBackground(.login)
            })
        }
        .padding()
        .animation(.default, value: isSigningIn)
        .disabled(isSigningIn)
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active && biometryUnlock && !authenticationViewModel.biometryFailed {
                Task {
                    await authenticationViewModel.signInMaster(method: .biometric)
                }
            }
        }
    }

    private func signIn() {
        isSigningIn = true
        Task {
            let success = await authenticationViewModel.signInMaster(method: .password(password))
            isSigningIn = false
            if !success {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    focusPassword = true
                }
            }
        }
    }

    private func signInBiometric() async {
        password = "******"
        isSigningIn = true
        _ = await authenticationViewModel.signInMaster(method: .biometric)
        isSigningIn = false
    }
}

struct PasswordTextField: View {

    @Binding var text: String
    @State private var showPassword = false

    var body: some View {
        ZStack(alignment: .trailing) {
            if showPassword {
                TextField("Password", text: $text)
            } else {
                SecureField("Password", text: $text)
            }

            Button(action: {
                showPassword.toggle()
            }, label: {
                Image(systemName: showPassword ? "eye.slash" : "eye")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 15)
                    .foregroundColor(.label)
                    .padding()
            })
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(AuthenticationViewModel())
//            .preferredColorScheme(.dark)
    }
}

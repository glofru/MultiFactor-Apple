//
//  LoginView.swift
//  MultiFactor
//
//  Created by g.lofrumento on 22/07/22.
//

import SwiftUI

struct LoginView: View {

    @EnvironmentObject private var authenticationViewModel: AuthenticationViewModel

    @State private var username = ""
    @State private var password = ""
    @State private var isSigningIn = false

    @State private var sheet: PresentedSheet?

    @FocusState private var focusedField: FocusedField?

    var body: some View {
        VStack(alignment: .trailing) {
            HStack {
                Spacer()
                Text("Login")
                    .mfFont(size: 30)
                    .bold()
                    .padding(.vertical)
                Spacer()
            }

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
                    .onSubmit(signIn)
                    .disableAutocorrection(true)
                #if os(iOS)
                    .textContentType(.password)
                    .textInputAutocapitalization(.never)
                #endif

                if let error = authenticationViewModel.signInError {
                    Text(error)
                        .foregroundColor(.red)
                }

                Button(action: {
                    sheet = .forgotPassword
                }, label: {
                    Text("Forgot password?")
                        .foregroundColor(.label)
                        .padding(.vertical)
                })
            }

            Button(action: signIn, label: {
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

    private func signIn() {
        focusedField = nil
        isSigningIn = true
        Task {
            if let error = await authenticationViewModel.signInCloud(method: .username(username, password)) {
                await MainActor.run {
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
            }
            await MainActor.run {
                isSigningIn = false
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
}

struct MasterLoginView: View {

    @EnvironmentObject private var authenticationViewModel: AuthenticationViewModel

    @AppStorage("biometryUnlock") private var biometryUnlock: Bool?
    @AppStorage("biometryType") private var biometryType: BiometryType?

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
                    .foregroundColor(.red)
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
        .task(id: "biometryUnlock", priority: .userInitiated) {
            if biometryUnlock == true {
                await signInBiometric()
            } else {
                focusPassword = true
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
        let _ = await authenticationViewModel.signInMaster(method: .biometric)
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

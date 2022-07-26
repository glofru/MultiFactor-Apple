//
//  LoginView.swift
//  MultiFactor
//
//  Created by g.lofrumento on 22/07/22.
//

import SwiftUI

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
                .onSubmit {
                    focusedField = nil
                    signIn()
                }

            if let error = authenticationViewModel.error {
                Text(error)
                    .foregroundColor(.red)
            }

            Button(action: signIn, label: {
                if isSigningIn {
                    ProgressView()
                } else {
                    Text("SignIn")
                }
            })
            .buttonStyle(MFRoundedRectangleButtonStyle())
        }
        .padding()
        .disabled(isSigningIn)
    }

    private func signIn() {
        isSigningIn = true
        Task {
            if let error = await authenticationViewModel.signIn(method:.username(username, password)) {
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

private struct MFRoundedRectangleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            Spacer()
            configuration.label
            Spacer()
        }
        .padding()
        .glassBackground(.accentColor, intensity: .strong)
        .cornerRadius(8)
        .scaleEffect(configuration.isPressed ? 0.95 : 1)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(AuthenticationViewModel())
    }
}

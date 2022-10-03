//
//  SignUpView.swift
//  MultiFactor
//
//  Created by Gianluca Lofrumento on 19/08/22.
//

import SwiftUI

struct SignUpView: View {

    @Environment(\.dismiss) private var dismiss

    @EnvironmentObject private var authenticationViewModel: AuthenticationViewModel

    @State private var username = ""
    @State private var password = ""
    @State private var repeatPassword = ""
    @State private var isSigningUp = false

    @State private var error: String?

    @FocusState private var focusedField: FocusedField?

    var body: some View {
        #if os(iOS)
        if #available(iOS 16, *) {
            content
                .presentationDetents([.medium])
        } else {
            content
        }
        #else
        content
        #endif
    }

    private var content: some View {
        VStack(alignment: .leading) {
//            if #unavailable(iOS 16) {
//                Spacer()
//            }

            Text("Sign Up")
                .mfTitle()

            TextField("Username", text: $username)
                .submitLabel(.next)
                .focused($focusedField, equals: .username)
                .onSubmit {
                    focusedField = .password
                }
                .disableAutocorrection(true)
                .padding(.vertical)
            #if os(iOS)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .textInputAutocapitalization(.never)
            #endif

            SecureField("Password", text: $password)
                .textContentType(.password)
                .focused($focusedField, equals: .password)
                .onSubmit {
                    focusedField = .repeatPassword
                }

            SecureField("Repeat Password", text: $repeatPassword)
                .textContentType(.password)
                .submitLabel(.done)
                .focused($focusedField, equals: .repeatPassword)
                .onSubmit(signUp)

            if let error = authenticationViewModel.signUpError {
                Text(error)
                    .mfError()
            }

            Spacer()

            Button(action: signUp, label: {
                if isSigningUp {
                    ProgressView()
                        .gradientBackground(.signUp)
                } else {
                    Text("Sign Up")
                        .gradientBackground(.signUp)
                }
            })
        }
        .padding()
        .animation(.default, value: authenticationViewModel.signUpError)
        .disabled(isSigningUp)
        .mfStyle()
    }

    private func signUp() {
        isSigningUp = true
        Task {
            let success = false
//            let success = await signUp
            await MainActor.run {
                isSigningUp = false
                if success {
                    dismiss()
                }
            }
        }
    }

    private enum FocusedField {
        case username, password, repeatPassword
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}

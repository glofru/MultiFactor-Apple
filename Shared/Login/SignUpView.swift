//
//  SignUpView.swift
//  MultiFactor
//
//  Created by Gianluca Lofrumento on 19/08/22.
//

import SwiftUI

struct SignUpView: View {

    @EnvironmentObject private var authenticationViewModel: AuthenticationViewModel

    @State private var username = ""
    @State private var password = ""
    @State private var repeatPassword = ""
    @State private var isSigningUp = false

    @FocusState private var focusedField: FocusedField?

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Spacer()
                Text("Sign Up")
                    .mfFont(size: 30)
                    .bold()
                    .padding(.vertical)
                Spacer()
            }

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
                    .foregroundColor(.red)
            }

            Button(action: signUp, label: {
                Text("Sign Up")
                    .gradientBackground(.signUp)
            })

            Spacer()
        }
        .padding()
        .animation(.default, value: authenticationViewModel.signUpError)
        .disabled(isSigningUp)
    }

    private func signUp() {
        
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

//
//  ForgotPasswordView.swift
//  MultiFactor
//
//  Created by Gianluca Lofrumento on 19/08/22.
//

import SwiftUI

struct ForgotPasswordView: View {

    @EnvironmentObject private var authenticationViewModel: AuthenticationViewModel

    @State private var username = ""
    @State private var isRestoring = false

    func restorePassword() {
        
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Spacer()
                Text("Forgot password")
                    .mfFont(size: 30)
                    .bold()
                    .padding(.vertical)
                Spacer()
            }

            Text("Please enter your registered email ID. We’ll send a code to reset your password")

            TextField("Username", text: $username)
                .submitLabel(.next)
                .textFieldStyle(MFLoginTextFieldStyle())
                .onSubmit(restorePassword)
                .disableAutocorrection(true)
                .padding(.vertical)
            #if os(iOS)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .textInputAutocapitalization(.never)
            #endif

            Button(action: restorePassword, label: {
                Text("Send")
                    .bold()
                    .gradientBackground(.signUp)
            })

            if #unavailable(iOS 16) {
                Spacer()
            }
        }
        .padding()
        .disabled(isRestoring)
    }
}

struct ForgotPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ForgotPasswordView()
    }
}

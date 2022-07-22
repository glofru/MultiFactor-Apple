//
//  LoginView.swift
//  MultiFactor
//
//  Created by g.lofrumento on 22/07/22.
//

import SwiftUI

struct LoginView<ViewModel>: View where ViewModel: AuthenticationViewModel {

    @ObservedObject var authenticationViewModel: ViewModel

    @State private var email = ""
    @State private var password = ""

    var body: some View {
        VStack(alignment: .center) {
            TextField("Email", text: $email)
            TextField("Password", text: $password)
            if let error = authenticationViewModel.error {
                Text(error)
                    .foregroundColor(.red)
            }
            Button(action: {
                Task.init {
                    await authenticationViewModel.signIn(method: .email(email, password))
                }
            }, label: {
                Text("SignIn")
            })
        }
        .padding()
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(authenticationViewModel: FirebaseAuthenticationViewModel())
    }
}

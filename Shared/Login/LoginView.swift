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
            Text("MultiFactor")
                .font(.title)
                .padding()

            TextField("Email", text: $email)
            #if os(iOS)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
            #endif
                .textFieldStyle(MFLoginTextFieldStyle())

            SecureField("Password", text: $password)
                .textContentType(.password)
                .textFieldStyle(MFLoginTextFieldStyle())

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
            .buttonStyle(MFRoundedRectangleButtonStyle())
        }
        .padding()
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
        LoginView(authenticationViewModel: FirebaseAuthenticationViewModel())
    }
}

//
//  FirebaseAuthenticationViewModel.swift
//  MultiFactor
//
//  Created by g.lofrumento on 22/07/22.
//

import SwiftUI

import FirebaseAuth

class FirebaseAuthenticationViewModel: AuthenticationViewModel {

    @Published private(set) var user: MFUser?

    @Published private(set) var state = AuthenticationState.unknown

    @Published private(set) var error: String?

    private var authHandle: AuthStateDidChangeListenerHandle!

    init() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.authHandle = Auth.auth().addStateDidChangeListener({ _, user in
                withAnimation {
                    if let user = user {
                        self.state = .signedIn
                        self.user = MFUser(user: user)
                    } else {
                        self.state = .signedOut
                        self.user = nil
                    }
                }
            })
        }
    }

    deinit {
        Auth.auth().removeStateDidChangeListener(authHandle)
    }

    @MainActor
    func signIn(method: AuthenticationMethod) async {
        switch method {
        case .email(let email, let password):
            do {
                try await Auth.auth().signIn(withEmail: email, password: password)
            } catch {
                await MainActor.run {
                    withAnimation {
                        self.state = .signedOut
                        self.error = error.localizedDescription
                    }
                }
            }
        }
    }

    @MainActor
    func signOut() {
        do {
            defer {
                withAnimation {
                    state = .signedOut
                }
            }

            try Auth.auth().signOut()
        } catch {
            print("[Auth] Failed signed out: \(error)")
        }
    }
}

extension MFUser {
    init(user: User) {
        self.id = user.uid
        self.email = user.email ?? ""
    }
}

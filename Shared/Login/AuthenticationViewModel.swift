//
//  AuthenticationViewModel.swift
//  MultiFactor
//
//  Created by g.lofrumento on 22/07/22.
//

import SwiftUI

class AuthenticationViewModel: ObservableObject {

    @Published private(set) var user: MFUser? = nil {
        didSet {
            PersistenceController.shared.user = user
        }
    }
    @Published private(set) var state = AuthenticationState.unknown
    @Published private(set) var error: String?

    init() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            CloudProvider.shared.addUserDidChangeListener({ user in
                withAnimation {
                    if user != nil {
                        self.state = .signedIn
                    } else {
                        self.state = .signedOut
                    }
                    self.user = user
                }
            })
        }
    }

    func signIn(method: AuthenticationMethod) async {
        switch await CloudProvider.shared.signIn(method: method) {
        case .success: break
        case .failure(let error):
            await MainActor.run {
                withAnimation {
                    self.state = .signedOut
                    self.error = error.localizedDescription
                }
            }
        }
    }

    func signOut() {
        CloudProvider.shared.signOut()

        withAnimation {
            state = .signedOut
        }
    }
}

struct MFUser {
    let id: String
    let email: String
}

enum AuthenticationMethod {
    case email(String, String) // Email, password
}

enum AuthenticationState {
    case signedIn, signedOut, unknown
}

enum AuthenticationResponse {
    case success, failure(String)
}

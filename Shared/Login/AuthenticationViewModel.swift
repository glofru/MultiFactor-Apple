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
    @Published private(set) var state = AuthenticationState.unknown {
        didSet {
            error = nil
        }
    }
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

    func signIn(method: AuthenticationMethod) async -> AuthenticationError? {
        // Input validation
        switch method {
        case .username(let username, let password):
            if username.trimmingCharacters(in: .whitespaces).isEmpty {
                withAnimation {
                    error = "Provided username is empty"
                }
                return .usernameEmpty
            } else if password.isEmpty {
                withAnimation {
                    error = "Provided password is empty"
                }
                return .passwordEmpty
            }
        }

        // Actual sign in
        switch await CloudProvider.shared.signIn(method: method) {
        case .success: return nil
        case .failure(let error):
            await MainActor.run {
                withAnimation {
                    self.state = .signedOut
                    self.error = error.localizedDescription
                }
            }
            return error
        }
    }

    func signOut() {
        withAnimation {
            state = .signedOut
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            TOTPViewModel.reset()
            PersistenceController.shared.deleteAll()
            CloudProvider.shared.signOut()
        }
    }
}

extension AuthenticationViewModel {
    enum FocusedField {
        case username, password
    }
}

struct MFUser {
    let id: String
    let username: String
}

enum AuthenticationMethod {
    case username(String, String) // Username, password
}

enum AuthenticationState {
    case signedIn, signedOut, unknown
}

enum AuthenticationError: LocalizedError {
    case usernameEmpty
    case passwordEmpty

    case usernameInvalid
    case usernameNotFound

    case passwordInvalid
    case passwordIncorrect

    case userDisabled
    case unknown(String)

    var localizedDescription: String {
        switch self {
        case .usernameEmpty:
            return "Username empty"
        case .passwordEmpty:
            return "Password empty"
        case .usernameInvalid:
            return "Username invalid"
        case .usernameNotFound:
            return "User not found"
        case .passwordInvalid:
            return "Password invalid"
        case .passwordIncorrect:
            return "Password incorrect"
        case .userDisabled:
            return "User disabled"
        case .unknown(let message):
            return message
        }
    }
}

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
            signInError = nil
            signUpError = nil
        }
    }
    @Published private(set) var signInError: String?
    @Published private(set) var signUpError: String?

    init() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            CloudProvider.shared.addUserDidChangeListener({ user in
                withAnimation {
                    if user != nil {
                        if self.state == .unknown || self.state == .signedOut {
                            self.state = .signedInCloud
                        }
                    } else {
                        self.state = .signedOut
                    }
                    self.user = user
                }
            })
        }
    }

    func signInCloud(method: AuthenticationMethod) async -> AuthenticationError? {
        // Input validation
        switch method {
        case .username(let username, let password):
            if username.trimmingCharacters(in: .whitespaces).isEmpty {
                withAnimation {
                    signInError = "Provided username is empty"
                }
                return .usernameEmpty
            } else if password.isEmpty {
                withAnimation {
                    signInError = "Provided password is empty"
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
                    self.signInError = error.localizedDescription
                }
            }
            return error
        }
    }

    func signInMaster(password: String, biometric: Bool = false) async {
        guard biometric || !password.isEmpty else {
            withAnimation {
                signInError = "Provided password is empty"
            }
            return
        }

        do {
            var key: String
            if let cloudKey = try? await CloudProvider.shared.key {
                key = cloudKey
            } else if let cloudKey = PersistenceController.shared.cloudKey {
                key = cloudKey
            } else {
                throw CloudError.keyNotFound
            }

            if biometric {
                if let masterPassword = PersistenceController.shared.masterPassword {
                    MFCipher.setKeyFrom(hash: masterPassword)
                } else {
                    throw CloudError.keyNotFound
                }
            } else {
                MFCipher.setKeyFrom(password: password)
            }

            guard let decryptedKey = MFCipher.decrypt(base64: key) else {
                MFCipher.reset()
                throw CloudError.keyIncorrect
            }
            MFCipher.setKeyFrom(string: decryptedKey)

            if !biometric {
                PersistenceController.shared.masterPassword = MFCipher.hash(password)
            }

            await MainActor.run {
                withAnimation {
                    self.state = .signedInMaster
                }
            }
        } catch {
            await MainActor.run {
                withAnimation {
                    self.signInError = error.localizedDescription
                }
            }
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

    func sendResetPasswordLink(to email: String) async -> AuthenticationError? {
        guard !email.isEmpty else {
            return .usernameEmpty
        }

        switch await CloudProvider.shared.sendResetPasswordLink(to: email) {
        case .success:
            return nil
        case .failure(let error):
            return error
        }
    }

    func onActive() {
        MFClock.shared.start()
    }

    func onBackground() {
        if state == .signedInCloud {
            MFClock.shared.stop()
            TOTPViewModel.reset()
            state = .signedInCloud
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
    case signedInCloud, signedInMaster, signedOut, unknown
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

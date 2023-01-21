//
//  FirebaseAuthenticationViewModel.swift
//  MultiFactor
//
//  Created by g.lofrumento on 22/07/22.
//

import SwiftUI

import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift

final class FirebaseCloudProvider: MFCloudProvider {
    private init() { }
    static var shared = FirebaseCloudProvider()

    func initialize() {
        FirebaseApp.configure()
    }

    private var firebaseUser: User?

    private var handle: AuthStateDidChangeListenerHandle?
    private var otpListenerRegistration: ListenerRegistration?

    // MARK: Authentication
    func signIn(method: CloudAuthenticationMethod) async -> Result<MFUser, AuthenticationError> {
        switch method {
        case .username(let username, let password):
            do {
                let result = try await Auth.auth().signIn(withEmail: username, password: password)
                return .success(MFUser(firebaseUser: result.user)!)
            } catch let error as AuthErrorCode {
                return .failure(handleAuthErrorCode(error))
            } catch {
                return .failure(.unknown(error.localizedDescription))
            }
        }
    }

    func signOut() {
        Firestore.firestore().clearPersistence()
        try? Auth.auth().signOut()
    }

    func sendResetPasswordLink(to email: String) async -> Result<Bool, AuthenticationError> {
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
            return .success(true)
        } catch let error as AuthErrorCode {
            return .failure(handleAuthErrorCode(error))
        } catch {
            return .failure(.unknown(error.localizedDescription))
        }
    }

    func addUserDidChangeListener(_ listener: @escaping (MFUser?) -> Void) {
        if let handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }

        self.handle = Auth.auth().addStateDidChangeListener({ _, user in
            self.firebaseUser = user
            listener(MFUser(firebaseUser: user))
        })
    }

    // MARK: OTP
    func addOTP(_ otp: CloudEncryptedOTP) async throws {
        guard let user = firebaseUser else {
            throw CloudError.userNotLogged
        }

        do {
            try Firestore.firestore()
                .collection("otp")
                .document(user.uid)
                .collection("list")
                .document(otp.id)
                .setData(from: otp)
        } catch {
            throw CloudError.otpFail(error.localizedDescription)
        }
    }

    func updateOTP(id: OTPIdentifier, data: [AnyHashable: Any]) async throws {
        guard let user = firebaseUser else {
            throw CloudError.userNotLogged
        }

        do {
            try await Firestore.firestore()
                .collection("otp")
                .document(user.uid)
                .collection("list")
                .document(id)
                .updateData(data)
        } catch {
            throw CloudError.otpFail(error.localizedDescription)
        }
    }

    func deleteOTP(_ id: OTPIdentifier) async throws {
        guard let user = firebaseUser else {
            throw CloudError.userNotLogged
        }

        do {
            try await Firestore.firestore()
                .collection("otp")
                .document(user.uid)
                .collection("list")
                .document(id)
                .delete()
        } catch {
            throw CloudError.otpFail(error.localizedDescription)
        }
    }

    func addOTPChangeListener(_ listener: @escaping ([CloudEncryptedOTP]) -> Void) throws {
        guard let user = firebaseUser else {
            throw CloudError.userNotLogged
        }

        otpListenerRegistration?.remove()
        otpListenerRegistration = Firestore.firestore()
            .collection("otp")
            .document(user.uid)
            .collection("list")
            .addSnapshotListener({ query, error in
                guard let query = query else {
                    return
                }
                let otps: [CloudEncryptedOTP] = query.documents.compactMap({ document in
                    let result = Result {
                        try document.data(as: CloudEncryptedOTP.self)
                    }

                    switch result {
                    case .success(let otp):
                        return otp
                    case .failure(let error):
                        print("[Firebase] Failure parsing otp: \(error.localizedDescription)")
                        return nil
                    }
                })
                listener(otps)
            })
    }

    var key: String {
        get async throws {
            guard let user = firebaseUser else {
                throw CloudError.userNotLogged
            }

            var document: DocumentSnapshot?
            do {
                document = try await Firestore.firestore()
                    .collection("otp")
                    .document(user.uid)
                    .getDocument()
            } catch {
                throw CloudError.keyFail(error.localizedDescription)
            }

            guard let key = document?.data()?["key"] as? String else {
                throw CloudError.keyNotFound
            }

            return key
        }
    }
}

extension FirebaseCloudProvider {
    fileprivate func handleAuthErrorCode(_ error: AuthErrorCode) -> AuthenticationError {
        let code = error.code
        if code == .invalidEmail {
            return .usernameInvalid
        } else if code == .userNotFound {
            return .usernameNotFound
        } else if code == .weakPassword {
            return .passwordInvalid
        } else if code == .wrongPassword {
            return .passwordIncorrect
        } else if code == .userDisabled {
            return .userDisabled
        } else if code == .invalidRecipientEmail || code == .invalidMessagePayload {
            return .usernameInvalid
        } else {
            return .unknown(error.localizedDescription)
        }
    }
}

extension MFUser {
    init?(firebaseUser: User?) {
        guard let user = firebaseUser else {
            return nil
        }

        self.id = user.uid
        self.username = user.email ?? ""
    }
}

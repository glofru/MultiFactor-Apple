//
//  FirebaseAuthenticationViewModel.swift
//  MultiFactor
//
//  Created by g.lofrumento on 22/07/22.
//

import SwiftUI

import FirebaseAuth
import FirebaseCore

final class FirebaseCloudProvider: MFCloudProvider {
    private init() { }
    static var shared = FirebaseCloudProvider()
    
    func initialize() {
        FirebaseApp.configure()
    }

    private var handle: AuthStateDidChangeListenerHandle?

    func signIn(method: AuthenticationMethod) async -> AuthenticationResponse {
        switch method {
        case .email(let email, let password):
            do {
                try await Auth.auth().signIn(withEmail: email, password: password)
                return .success
            } catch {
                return .failure(error.localizedDescription)
            }
        }
    }
    
    func signOut() {
        try? Auth.auth().signOut()
    }

    func addUserDidChangeListener(_ listener: @escaping (MFUser?) -> Void) {
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
        
        self.handle = Auth.auth().addStateDidChangeListener({ _, user in
            listener(MFUser(firebaseUser: user))
        })
    }
}

extension MFUser {
    init?(firebaseUser: User?) {
        guard let user = firebaseUser else {
            return nil
        }
        
        self.id = user.uid
        self.email = user.email ?? ""
    }
}

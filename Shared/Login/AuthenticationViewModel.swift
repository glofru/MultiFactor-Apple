//
//  AuthenticationViewModel.swift
//  MultiFactor
//
//  Created by g.lofrumento on 22/07/22.
//

import SwiftUI

protocol AuthenticationViewModel: ObservableObject {
    var user: MFUser? { get }
    var state: AuthenticationState { get }
    var error: String? { get }

    func signIn(method: AuthenticationMethod) async
    func signOut()
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

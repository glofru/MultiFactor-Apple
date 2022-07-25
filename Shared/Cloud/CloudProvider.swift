//
//  CloudProvider.swift
//  MultiFactor
//
//  Created by g.lofrumento on 24/07/22.
//

import Foundation

protocol MFCloudProvider {

    static var shared: Self { get }

    func initialize()

    //MARK: Authentication
    func signIn(method: AuthenticationMethod) async -> AuthenticationResponse
    func signOut()

    func addUserDidChangeListener(_ listener: @escaping (MFUser?) -> Void)
}

class CloudProvider {
    private init() { }
    static let shared: MFCloudProvider = FirebaseCloudProvider.shared
}

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

    //MARK: Database stuff
    func addOTP(_ otp: OTPCode) async -> Result<OTPCodeID, CloudError>
}

enum CloudError: Error {
    case userNotLogged
    case otpAddingFail(String)
}

class CloudProvider {
    private init() { }
    static let shared: MFCloudProvider = FirebaseCloudProvider.shared
}

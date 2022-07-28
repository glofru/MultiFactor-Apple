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
    func signIn(method: AuthenticationMethod) async -> Result<MFUser, AuthenticationError>
    func signOut()

    func addUserDidChangeListener(_ listener: @escaping (MFUser?) -> Void)

    //MARK: OTP
    func addOTP(_ otp: CloudEncryptedOTP) async throws
    func deleteOTP(_ otp: OTPIdentifier) async throws
    func addOTPChangeListener(_ listener: @escaping ([CloudEncryptedOTP]) -> Void) throws
}

enum CloudError: Error {
    case userNotLogged
    case authenticationFail(String)
    case otpFail(String)
}

class CloudProvider {
    private init() { }
    static let shared: MFCloudProvider = FirebaseCloudProvider.shared
}

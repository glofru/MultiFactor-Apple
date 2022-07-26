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
    func signIn(method: AuthenticationMethod) async -> Result<MFUser, CloudError>
    func signOut()

    func addUserDidChangeListener(_ listener: @escaping (MFUser?) -> Void)

    //MARK: OTP
    func addOTP(_ otp: OTPCode) async throws
    func addOTPChangeListener(_ listener: @escaping ([OTPCode]) -> Void) throws
}

enum CloudError: Error {
    case userNotLogged
    case authenticationFail(String)
    case otpAddingFail(String)
}

class CloudProvider {
    private init() { }
    static let shared: MFCloudProvider = FirebaseCloudProvider.shared
}

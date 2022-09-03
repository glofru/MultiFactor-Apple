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
    func sendResetPasswordLink(to email: String) async -> Result<Bool, AuthenticationError>

    func addUserDidChangeListener(_ listener: @escaping (MFUser?) -> Void)

    //MARK: OTP
    func addOTP(_ otp: CloudEncryptedOTP) async throws
    func deleteOTP(_ otp: OTPIdentifier) async throws
    func addOTPChangeListener(_ listener: @escaping ([CloudEncryptedOTP]) -> Void) throws

    var key: String { get async throws }
}

enum CloudError: Error, LocalizedError {
    case userNotLogged
    case authenticationFail(String)
    case otpFail(String)
    case keyNotFound
    case keyIncorrect
    case keyFail(String)

    var errorDescription: String? {
        switch self {
        case .userNotLogged:
            return "User not logged"
        case .authenticationFail(let string):
            return "Authentication failed: \(string)"
        case .otpFail(let string):
            return "OTP failed: \(string)"
        case .keyNotFound:
            return "Key not found"
        case .keyIncorrect:
            return "Key incorrect"
        case .keyFail(let string):
            return "Key fail: \(string)"
        }
    }
}

class CloudProvider {
    private init() { }
    static let shared: MFCloudProvider = FirebaseCloudProvider.shared
}

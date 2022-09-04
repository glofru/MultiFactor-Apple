//
//  HomeViewModel.swift
//  MultiFactor
//
//  Created by g.lofrumento on 24/07/22.
//

import Foundation
import SwiftUI

class HomeViewModel: ObservableObject {

    init() {
        try? CloudProvider.shared.addOTPChangeListener { otps in
            PersistenceController.shared.save(cloudEncryptedOTPs: otps)
        }
    }

    func addOTPFrom(url: String) async throws {
        guard let decrypted = DecryptedOTP(from: url) else {
            throw AddOTPError.urlInvalid
        }

        guard let encrypted = MFCipher.encrypt(decrypted) else {
            throw AddOTPError.encryptionFailed
        }

        do {
            try await CloudProvider.shared.addOTP(encrypted)
        } catch {
            throw AddOTPError.cloudFailed(error.localizedDescription)
        }
    }

    func deleteOTP(_ otp: OTPIdentifier) async {
        try? await CloudProvider.shared.deleteOTP(otp)
    }

    enum AddOTPError: Error, LocalizedError {
        case urlInvalid
        case encryptionFailed
        case cloudFailed(String)

        var errorDescription: String? {
            switch self {
            case .urlInvalid:
                return "URL invalid"
            case .encryptionFailed:
                return "Encryption failed, are you logged in?"
            case .cloudFailed(let string):
                return "Cloud provider error: \(string)"
            }
        }
    }
}

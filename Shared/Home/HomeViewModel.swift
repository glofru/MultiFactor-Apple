//
//  HomeViewModel.swift
//  MultiFactor
//
//  Created by g.lofrumento on 24/07/22.
//

import Foundation
import SwiftUI

class HomeViewModel: ObservableObject {

    @Published var error: String?

    init() {
        try? CloudProvider.shared.addOTPChangeListener { otps in
            PersistenceController.shared.save(cloudEncryptedOTPs: otps)
        }
    }

    func addOTP() async {
        let decrypted = DecryptedOTP(id: UUID().uuidString, secret: "I65VU7K5ZQL7WB4E", issuer: "Dropbox", label: "gianluca", algorithm: .sha256, digits: .six, period: .thirty)
        if let encrypted = MFCipher.encrypt(decrypted) {
            do {
                try await CloudProvider.shared.addOTP(encrypted)
            } catch {
                self.error = error.localizedDescription
            }
        } else {
            error = "Cannot encrypt"
        }
    }

    func deleteOTP(_ otp: OTPIdentifier) async {
        try? await CloudProvider.shared.deleteOTP(otp)
    }
}

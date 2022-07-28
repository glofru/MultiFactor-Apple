//
//  HomeViewModel.swift
//  MultiFactor
//
//  Created by g.lofrumento on 24/07/22.
//

import Foundation
import SwiftUI

class HomeViewModel: ObservableObject {

    @Published private(set) var totps = [TOTPViewModel]()
    private var totpsKeys = [OTPIdentifier: TOTPViewModel]()

    private var encryptedOTPs = [EncryptedOTP]() {
        willSet {
            var newTOTPsKeys = [OTPIdentifier: TOTPViewModel]()
            newValue.forEach { otp in
                if let totp = totpsKeys[otp.id] {
                    newTOTPsKeys[otp.id] = totp
                } else {
                    newTOTPsKeys[otp.id] = TOTPViewModel(encryptedOTP: otp)
                }
            }
            totpsKeys.removeAll()
            totps.removeAll()

            totpsKeys = newTOTPsKeys
            totps = totpsKeys.values.map { $0 }

            MFClock.shared.update()
        }
    }

    init() {
        try? CloudProvider.shared.addOTPChangeListener { [weak self] otps in
            withAnimation {
                self?.encryptedOTPs = otps
            }
        }
    }

    func addOTP() async {
        try? await CloudProvider.shared.addOTP(EncryptedOTP(id: UUID().uuidString, secret: "I65VU7K5ZQL7WB4E", issuer: "Google", label: "gianluca.lofrumento@gmail.com", algorithm: .sha256, digits: .six, period: .thirty))
    }

    func deleteOTP(_ otp: OTPIdentifier) async {
        try? await CloudProvider.shared.deleteOTP(otp)
    }

    func updateGenerateCodes(for date: Date) {
        totps.forEach {
            $0.generateCode(for: date)
        }
    }
}

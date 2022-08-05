//
//  TOTPViewModel.swift
//  MultiFactor
//
//  Created by g.lofrumento on 24/07/22.
//

import SwiftUI
import SwiftOTP

class TOTPViewModel: ObservableObject, Identifiable {
    let id: OTPIdentifier
    let issuer: String?
    let label: String?
    let period: DecryptedOTP.Period

    private let totp: TOTP

    @Published var code: String

    private init(encryptedOTP: EncryptedOTP) {
        let decryptedOTP = MFCipher.decrypt(encryptedOTP)!

        self.id = decryptedOTP.id
        self.issuer = decryptedOTP.issuer
        self.label = decryptedOTP.label
        self.period = decryptedOTP.period
        self.totp = TOTP(secret: base32DecodeToData(decryptedOTP.secret)!, digits: decryptedOTP.digits.rawValue, timeInterval: decryptedOTP.period.rawValue, algorithm: .sha1)!
        self.code = self.totp.generate(time: .now) ?? ""
    }

    func generateCode(for date: Date) {
        self.code = self.totp.generate(time: date) ?? ""
    }
}

extension TOTPViewModel {
    static private var instancesMappings = [OTPIdentifier: TOTPViewModel]()
    static func getInstance(otp: EncryptedOTP) -> TOTPViewModel {
        if let viewModel = instancesMappings[otp.id!] {
            return viewModel
        } else {
            let newViewModel = TOTPViewModel(encryptedOTP: otp)
            instancesMappings[otp.id!] = newViewModel
            return newViewModel
        }
    }
    static func reset() {
        instancesMappings.removeAll()
    }
}

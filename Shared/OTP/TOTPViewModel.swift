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
    let decryptedOTP: DecryptedOTP

    private let totp: TOTP

    @Published var code: String = "******"

    init(encryptedOTP: EncryptedOTP) {
        self.id = encryptedOTP.id
        self.decryptedOTP = DecryptedOTP(issuer: encryptedOTP.issuer, label: encryptedOTP.label, algorithm: encryptedOTP.algorithm, digits: encryptedOTP.digits, period: encryptedOTP.period)

        let data = base32DecodeToData(encryptedOTP.secret)!
        self.totp = TOTP(secret: data, digits: encryptedOTP.digits.rawValue, timeInterval: encryptedOTP.period.rawValue, algorithm: .sha1)!
    }

    func generateCode(for date: Date) {
        self.code = self.totp.generate(time: date) ?? ""
    }

}

struct DecryptedOTP {
    let issuer: String?
    let label: String?
    let algorithm: EncryptedOTP.Algorithm
    let digits: EncryptedOTP.Digits
    let period: EncryptedOTP.Period

    init(issuer: String? = nil, label: String? = nil, algorithm: EncryptedOTP.Algorithm = .sha256, digits: EncryptedOTP.Digits = .six, period: EncryptedOTP.Period = .thirty) {
        self.issuer = issuer
        self.label = label
        self.algorithm = algorithm
        self.digits = digits
        self.period = period
    }
}

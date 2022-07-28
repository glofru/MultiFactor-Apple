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

//    private let totp: TOTP

    @Published var code: String = "******"

    init(encryptedOTP: EncryptedOTP) {
        self.id = UUID().uuidString
        self.issuer = ""
        self.label = ""
//        let decryptedOTP = DecryptedOTP(id: encryptedOTP.id!, issuer: encryptedOTP.issuer, label: encryptedOTP.label, algorithm: DecryptedOTP.Algorithm(rawValue: encryptedOTP.algorithm ?? "")!, digits: DecryptedOTP.Digits(rawValue: Int(encryptedOTP.digits))!, period: DecryptedOTP.Period(rawValue: Int(encryptedOTP.period))!)
//
//        self.id = decryptedOTP.id
//        self.issuer = decryptedOTP.issuer
//        self.label = decryptedOTP.label
//        self.totp = TOTP(secret: base32DecodeToData(encryptedOTP.secret!)!, digits: decryptedOTP.digits.rawValue, timeInterval: decryptedOTP.period.rawValue, algorithm: .sha1)!
    }

    func generateCode(for date: Date) {
        self.code = "123456"
//        self.code = self.totp.generate(time: date) ?? ""
    }

}

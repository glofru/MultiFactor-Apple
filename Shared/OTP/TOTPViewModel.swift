//
//  TOTPViewModel.swift
//  MultiFactor
//
//  Created by g.lofrumento on 24/07/22.
//

import SwiftUI
import SwiftOTP

class TOTPViewModel: ObservableObject, Identifiable {
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

    let id: OTPIdentifier
    let issuer: String?
    let label: String?

    private let totp: TOTP

    @Published var code: String = "******"

    private init(encryptedOTP: EncryptedOTP) {
        let decryptedOTP = DecryptedOTP(id: encryptedOTP.id!, issuer: encryptedOTP.issuer, label: encryptedOTP.label, algorithm: DecryptedOTP.Algorithm(rawValue: encryptedOTP.algorithm ?? "")!, digits: DecryptedOTP.Digits(rawValue: Int(encryptedOTP.digits))!, period: DecryptedOTP.Period(rawValue: Int(encryptedOTP.period))!)

        self.id = decryptedOTP.id
        self.issuer = decryptedOTP.issuer
        self.label = decryptedOTP.label
        self.totp = TOTP(secret: base32DecodeToData(encryptedOTP.secret!)!, digits: decryptedOTP.digits.rawValue, timeInterval: decryptedOTP.period.rawValue, algorithm: .sha1)!
    }

    func generateCode(for date: Date) {
        self.code = self.totp.generate(time: date) ?? ""
    }

}

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

    private let totp: TOTP?

    @Published private(set) var code: String

    private init(encryptedOTP: EncryptedOTP) {
        let decryptedOTP = MFCipher.decrypt(encryptedOTP)

        self.id = decryptedOTP?.id ?? UUID().uuidString
        self.period = decryptedOTP?.period ?? .standard
        if let secret = base32DecodeToData(decryptedOTP?.secret ?? ""),
           let totp = TOTP(secret: secret, digits: (decryptedOTP?.digits ?? .standard).rawValue, timeInterval: (decryptedOTP?.period ?? .standard).rawValue, algorithm: (decryptedOTP?.algorithm ?? .standard).swiftOTP) {
            self.totp = totp
            self.issuer = decryptedOTP?.issuer
            self.label = decryptedOTP?.label
        } else {
            self.totp = nil
            self.issuer = "Error"
            self.label = "Error"
        }
        self.code = "******"
    }

    func generateCode(for date: Date) {
        if let totp = totp {
            self.code = totp.generate(time: date) ?? ""
        }
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

private extension DecryptedOTP.Algorithm {
    // This shounds a bit stupid but you know... strong typing... that kind of stuff saved computer science
    var swiftOTP: OTPAlgorithm {
        switch self {
        case .sha1: return .sha1
        case .sha256: return .sha256
        case .sha512: return .sha512
        }
    }
}

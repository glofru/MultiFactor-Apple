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
    let secret: String
    var issuer: String?
    var label: String?
    var algorithm: DecryptedOTP.Algorithm
    var digits: DecryptedOTP.Digits
    var period: DecryptedOTP.Period
    var order: Int16

    private let totp: TOTP?

    @Published private(set) var code: String

    private init(encryptedOTP: EncryptedOTP) {
        let decryptedOTP = MFCipher.decrypt(encryptedOTP)

        self.id = decryptedOTP?.id ?? UUID().uuidString
        self.algorithm = decryptedOTP?.algorithm ?? .standard
        self.digits = decryptedOTP?.digits ?? .standard
        self.period = decryptedOTP?.period ?? .standard
        self.secret = decryptedOTP?.secret ?? "Error"
        self.order = decryptedOTP?.order ?? 0
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

    func encode() -> String? {
        if let totp {
            return "otpauth://totp/\(label ?? "")?secret=\(totp.secret.base32EncodedString)&issuer=\(issuer ?? "")&period=\(period.rawValue)&digits=\(totp.digits)&algorithm=\(totp.algorithm)"
        } else {
            return nil
        }
    }

    func generateCode(for date: Date) {
        if let totp {
            self.code = totp.generate(time: date) ?? ""
        }
    }

    func saveQRCodeInLibrary(onCompleted: @escaping (ImageSaver.Result) -> Void) {
        if let url = encode() {
            ImageSaver().saveQRInLibrary(text: url, onCompleted: onCompleted)
        } else {
            onCompleted(.qrGenerationFailed)
        }
    }

    func update() async throws {
        let decrypted = DecryptedOTP(id: self.id, secret: self.secret, issuer: self.issuer, label: self.label, algorithm: self.algorithm, digits: self.digits, period: self.period)
        if let encrypted = MFCipher.encrypt(decrypted) {
            try await CloudProvider.shared.updateOTP(id: self.id, data: [
                DecryptedOTP.CodingKeys.issuer.rawValue: encrypted.issuer,
                DecryptedOTP.CodingKeys.label.rawValue: encrypted.label,
                DecryptedOTP.CodingKeys.algorithm.rawValue: encrypted.algorithm.rawValue,
                DecryptedOTP.CodingKeys.digits.rawValue: encrypted.digits.rawValue,
                DecryptedOTP.CodingKeys.period.rawValue: encrypted.period.rawValue
            ])
        }
    }
}

// Instances handling
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

    static func isValid(secret: String) -> Bool {
        base32DecodeToData(secret) != nil
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

//
//  MFCipher.swift
//  MultiFactor
//
//  Created by g.lofrumento on 03/08/22.
//

import Foundation
import CryptoKit

class MFCipher {
    static private var key: SymmetricKey!

    static func setKey(_ key: String) {
        MFCipher.key = SymmetricKey(data: Data(hex: key))
    }

    static func reset() {
        key = nil
    }

    static func encrypt(_ decryptedOTP: DecryptedOTP) -> CloudEncryptedOTP? {
        guard let secret = encrypt(data: decryptedOTP.secret) else {
            return nil
        }
        return CloudEncryptedOTP(
            id: decryptedOTP.id,
            secret: secret,
            issuer: encrypt(data: decryptedOTP.issuer) ?? "",
            label: encrypt(data: decryptedOTP.label) ?? "",
            algorithm: decryptedOTP.algorithm,
            digits: decryptedOTP.digits,
            period: decryptedOTP.period
        )
    }

    static func decrypt(_ encryptedOTP: EncryptedOTP) -> DecryptedOTP? {
        guard let unwrappedSecret = encryptedOTP.secret, let secret = decrypt(base64: unwrappedSecret) else {
            return nil
        }
        return DecryptedOTP(
            id: encryptedOTP.id!,
            secret: secret,
            issuer: decrypt(base64: encryptedOTP.issuer ?? "") ?? "",
            label: decrypt(base64: encryptedOTP.label ?? "") ?? "",
            algorithm: .init(rawValue: encryptedOTP.algorithm!) ?? .sha256,
            digits: .init(rawValue: Int(encryptedOTP.digits)) ?? .six,
            period: .init(rawValue: Int(encryptedOTP.period)) ?? .thirty
        )
    }

    static func encrypt(data: String) -> String? {
        guard !data.isEmpty else {
            return nil
        }

        let plainData = data.data(using: .utf8)
        guard let sealedData = try? AES.GCM.seal(plainData!, using: key, nonce: AES.GCM.Nonce()).combined else {
            return nil
        }
        return sealedData.base64EncodedString()
    }

    static func decrypt(base64 encodedData: String) -> String? {
        guard !encodedData.isEmpty else {
            return nil
        }

        guard let decodedData = Data(base64Encoded: encodedData),
              let unsealedData = try? AES.GCM.open(.init(combined: decodedData), using: key) else {
            return nil
        }
        return String(decoding: unsealedData, as: UTF8.self)
    }
}

extension MFCipher {
    static func hash(_ data: String) -> String {
        SHA256.hash(data: Data(data.utf8)).digest
    }

    static func generateKey() -> String {
        String.random()
    }
}

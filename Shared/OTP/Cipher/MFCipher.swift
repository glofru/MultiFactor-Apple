//
//  MFCipher.swift
//  MultiFactor
//
//  Created by g.lofrumento on 03/08/22.
//

import Foundation
import CryptoKit

class MFCipher {
    private let key: SymmetricKey

    init(key: String) {
        self.key = SymmetricKey(data: Data(hex: key))
    }

    func encrypt(data: String) -> String? {
        let plainData = data.data(using: .utf8)
        guard let sealedData = try? AES.GCM.seal(plainData!, using: key, nonce: AES.GCM.Nonce()).combined else {
            return nil
        }
        return sealedData.base64EncodedString()
    }

    func decrypt(base64 encodedData: String) -> String? {
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

//
//  SHA256Digest.swift
//  MultiFactor
//
//  Created by g.lofrumento on 04/08/22.
//

import CryptoKit

extension SHA256Digest {
    var digest: String {
        self.compactMap { String(format: "%02x", $0) }.joined()
    }
}

//
//  CloudEncryptedOTP.swift
//  MultiFactor
//
//  Created by g.lofrumento on 28/07/22.
//

struct CloudEncryptedOTP: Codable, Identifiable {
    var id: OTPIdentifier
    let secret: String
    let issuer: String
    let label: String
    let algorithm: DecryptedOTP.Algorithm
    let digits: DecryptedOTP.Digits
    let period: DecryptedOTP.Period

    init(id: OTPIdentifier, secret: String, issuer: String = "", label: String = "", algorithm: DecryptedOTP.Algorithm = .sha256, digits: DecryptedOTP.Digits = .six, period: DecryptedOTP.Period = .thirty) {
        self.id = id
        self.secret = secret
        self.issuer = issuer
        self.label = label
        self.algorithm = algorithm
        self.digits = digits
        self.period = period
    }
}

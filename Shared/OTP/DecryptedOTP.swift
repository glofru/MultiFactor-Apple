//
//  DecryptedOTP.swift
//  MultiFactor
//
//  Created by g.lofrumento on 28/07/22.
//

typealias OTPIdentifier = String

struct DecryptedOTP: Codable, Identifiable {
    var id: OTPIdentifier
    let issuer: String?
    let label: String?
    let algorithm: Algorithm
    let digits: Digits
    let period: Period

    init(id: OTPIdentifier, issuer: String? = nil, label: String? = nil, algorithm: Algorithm = .sha256, digits: Digits = .six, period: Period = .thirty) {
        self.id = id
        self.issuer = issuer
        self.label = label
        self.algorithm = algorithm
        self.digits = digits
        self.period = period
    }

    enum Algorithm: String, Codable {
        case sha1
        case sha256
        case sha512
    }

    enum Digits: Int, Codable {
        case six = 6
        case eight = 8
    }

    enum Period: Int, Codable {
        case thirty = 30
//        case sixty = 60
    }
}

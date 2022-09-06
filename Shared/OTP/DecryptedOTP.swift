//
//  DecryptedOTP.swift
//  MultiFactor
//
//  Created by g.lofrumento on 28/07/22.
//

import Foundation

typealias OTPIdentifier = String

struct DecryptedOTP: Codable, Identifiable {
    var id: OTPIdentifier
    let secret: String
    let issuer: String
    let label: String
    let algorithm: Algorithm
    let digits: Digits
    let period: Period
    var order: Int16

    init(id: OTPIdentifier, secret: String, issuer: String = "", label: String = "", algorithm: Algorithm = .sha256, digits: Digits = .six, period: Period = .thirty, order: Int16 = .max) {
        self.id = id
        self.secret = secret
        self.issuer = issuer
        self.label = label
        self.algorithm = algorithm
        self.digits = digits
        self.period = period
        self.order = order
    }

    enum Algorithm: String, Codable {
        case sha1
        case sha256
        case sha512

        static let standard = Algorithm.sha1
    }

    enum Digits: Int, Codable {
        case six = 6
        case eight = 8

        static let standard = Digits.six
    }

    enum Period: Int, Codable {
        case thirty = 30
//        case sixty = 60

        static let standard = Period.thirty
    }

    //MARK: CodingKeys needed to update
    enum CodingKeys: String, CodingKey {
        case id
        case secret
        case issuer
        case label
        case algorithm
        case digits
        case period
        case order
    }
}

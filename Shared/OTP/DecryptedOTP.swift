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

    init(id: OTPIdentifier? = nil, secret: String, issuer: String? = nil, label: String? = nil, algorithm: Algorithm? = nil, digits: Digits? = nil, period: Period? = nil, order: Int16? = nil) {
        self.id = id ?? UUID().uuidString
        self.secret = secret
        self.issuer = issuer ?? ""
        self.label = label ?? ""
        self.algorithm = algorithm ?? .standard
        self.digits = digits ?? .standard
        self.period = period ?? .standard
        self.order = order ?? .max
    }

    enum Algorithm: String, CaseIterable, Codable {
        case sha1
        case sha256
        case sha512

        static let standard = Algorithm.sha1
    }

    enum Digits: Int, CaseIterable, Codable {
        case six = 6
        case eight = 8

        static let standard = Digits.six
    }

    enum Period: Int, CaseIterable, Codable {
        case thirty = 30
//        case sixty = 60

        static let standard = Period.thirty
    }

    // MARK: CodingKeys needed to update
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

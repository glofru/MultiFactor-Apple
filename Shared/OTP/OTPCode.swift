//
//  OTPCode.swift
//  MultiFactor
//
//  Created by g.lofrumento on 26/07/22.
//

typealias OTPCodeID = String

struct OTPCode: Codable, Identifiable {
    var id: OTPCodeID
    let secret: String
    let issuer: String?
    let label: String?
    let algorithm: Algorithm?
    let digits: Digits?
    let period: UInt8?

    init(id: OTPCodeID, secret: String, issuer: String? = nil, label: String? = nil, algorithm: Algorithm = .sha256, digits: Digits = .six, period: UInt8 = 30) {
        self.id = id
        self.secret = secret
        self.issuer = issuer
        self.label = label
        self.algorithm = algorithm
        self.digits = digits
        self.period = period
    }

//    var code = [Number.one, .two, .three, .four, .five, .six]
//
//    enum Number: Int {
//        case one = 1, two, three, four, five, six, seven, eight, nine, ten
//    }
    
    enum Algorithm: String, Codable {
        case sha1
        case sha256
        case sha512
    }

    enum Digits: Int, Codable {
        case six = 6
        case eight = 8
    }
}

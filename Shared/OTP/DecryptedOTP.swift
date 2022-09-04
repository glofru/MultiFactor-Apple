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

    init(id: OTPIdentifier, secret: String, issuer: String = "", label: String = "", algorithm: Algorithm = .sha256, digits: Digits = .six, period: Period = .thirty) {
        self.id = id
        self.secret = secret
        self.issuer = issuer
        self.label = label
        self.algorithm = algorithm
        self.digits = digits
        self.period = period
    }

    init?(from url: String) {
        guard let components = URLComponents(string: url),
              (components.scheme == "otpauth" || components.scheme == "otpauthmigration"),
              components.host == "totp",
              let queryItems = components.queryItems,
              queryItems.contains(where: { $0.name == "secret" }) else {
            return nil
        }

        var secret = ""
        var issuer = ""
        var algorithm = DecryptedOTP.Algorithm.standard
        var digits = DecryptedOTP.Digits.standard
        var period = DecryptedOTP.Period.standard
        for item in queryItems {
            switch item.name {
            case "secret": secret = item.value!
            case "issuer": issuer = item.value ?? issuer
            case "algorithm":
                if let newAlgorithm = DecryptedOTP.Algorithm(rawValue: item.value?.lowercased() ?? "") {
                    algorithm = newAlgorithm
                } else {
                    return nil
                }
            case "digits":
                if let newDigits = DecryptedOTP.Digits(rawValue: Int(item.value ?? "0") ?? 0) {
                    digits = newDigits
                } else {
                    return nil
                }
            case "period":
                if let newPeriod = DecryptedOTP.Period(rawValue: Int(item.value ?? "0") ?? 0) {
                    period = newPeriod
                } else {
                    return nil
                }
            default: continue
            }
        }

        self.id = UUID().uuidString
        self.secret = secret
        self.issuer = issuer
        self.algorithm = algorithm
        self.digits = digits
        self.period = period

        var labelPath = components.path
        labelPath.removeFirst()
        self.label = labelPath
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
}

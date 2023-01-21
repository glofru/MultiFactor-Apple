//
//  HomeViewModel.swift
//  MultiFactor
//
//  Created by g.lofrumento on 24/07/22.
//

import Foundation
import SwiftUI
import SwiftOTP

class HomeViewModel: ObservableObject {

    private var otpNumber = 0

    @Published var showCopy = false
    @Published var sheet: PresentedSheet?

    init() {
        try? CloudProvider.shared.addOTPChangeListener { [weak self] otps in
            self?.otpNumber = otps.count
            PersistenceController.shared.save(cloudEncryptedOTPs: otps)
        }
    }

    func addOTPFrom(decrypted: DecryptedOTP) async throws {
        guard TOTPViewModel.isValid(secret: decrypted.secret) else {
            throw AddOTPError.secretInvalid
        }
        var decrypted = decrypted
        decrypted.order = Int16(otpNumber)

        guard let encrypted = MFCipher.encrypt(decrypted) else {
            throw AddOTPError.encryptionFailed
        }

        try await CloudProvider.shared.addOTP(encrypted)
    }

    func addOTPFrom(url: String) async throws {
        let decrypted = DecryptedOTP.decode(from: url)
        guard !decrypted.isEmpty else {
            throw AddOTPError.urlInvalid
        }

        var lastIndex = otpNumber
        var failError: Error?
        await withThrowingTaskGroup(of: Void.self) { group in
            for var decrypt in decrypted {
                decrypt.order = Int16(lastIndex)
                lastIndex += 1

                guard let encrypted = MFCipher.encrypt(decrypt) else {
                    failError = AddOTPError.encryptionFailed
                    group.cancelAll()
                    return
                }

                _ = group.addTaskUnlessCancelled(priority: .userInitiated) {
                    try await CloudProvider.shared.addOTP(encrypted)
                }
            }
        }

        if let failError {
            throw failError
        }
    }

    func moveOTPs(_ otps: [EncryptedOTP]) async {
        await withTaskGroup(of: Void.self) { group in
            for otp in otps {
                group.addTask(priority: .userInitiated) {
                    try? await CloudProvider.shared.updateOTP(id: otp.id!, data: [
                        DecryptedOTP.CodingKeys.order.rawValue: otp.order
                    ])
                }
            }
        }
    }

    func deleteOTP(_ otp: OTPIdentifier) async {
        try? await CloudProvider.shared.deleteOTP(otp)
    }

    func deleteOTPs(_ otps: [OTPIdentifier]) async {
        for otp in otps {
            await deleteOTP(otp)
        }
    }

    func copyCode(_ code: String) {
        #if os(iOS)
        UIPasteboard.general.string = code
        #elseif os(macOS)
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.writeObjects([code as NSString])
        #endif
        showCopy = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.showCopy = false
        }
    }

    private enum AddOTPError: Error, LocalizedError {
        case urlInvalid
        case secretInvalid
        case encryptionFailed
        case cloudFailed(String)

        var errorDescription: String? {
            switch self {
            case .urlInvalid:
                return "URL invalid"
            case .secretInvalid:
                return "Secret invalid"
            case .encryptionFailed:
                return "Encryption failed, are you logged in?"
            case .cloudFailed(let string):
                return "Cloud provider error: \(string)"
            }
        }
    }

    enum PresentedSheet: Identifiable {
        case addQr, addManual

        var id: UUID {
            UUID()
        }
    }
}

private extension DecryptedOTP {
    static func decode(from url: String) -> [DecryptedOTP] {
        guard let components = URLComponents(string: url) else {
            return []
        }

        switch components.scheme {
        case "otpauth":
            guard components.host == "totp",
                  let queryItems = components.queryItems,
                  let secret = queryItems.first(where: { $0.name == "secret" })?.value,
                  TOTPViewModel.isValid(secret: secret) else {
                return []
            }

            var issuer = ""
            var algorithm = DecryptedOTP.Algorithm.standard
            var digits = DecryptedOTP.Digits.standard
            var period = DecryptedOTP.Period.standard
            for item in queryItems {
                switch item.name {
                case "issuer": issuer = item.value ?? issuer
                case "algorithm":
                    if let newAlgorithm = DecryptedOTP.Algorithm(rawValue: item.value?.lowercased() ?? "") {
                        algorithm = newAlgorithm
                    } else {
                        return []
                    }
                case "digits":
                    if let newDigits = DecryptedOTP.Digits(rawValue: Int(item.value ?? "0") ?? 0) {
                        digits = newDigits
                    } else {
                        return []
                    }
                case "period":
                    if let newPeriod = DecryptedOTP.Period(rawValue: Int(item.value ?? "0") ?? 0) {
                        period = newPeriod
                    } else {
                        return []
                    }
                default: continue
                }
            }

            var labelPath = components.path
            if !labelPath.isEmpty {
                labelPath.removeFirst() // remove leading slash
                labelPath = labelPath.split(separator: ":").last?.description ?? ""
            }

            return [DecryptedOTP(secret: secret, issuer: issuer, label: labelPath, algorithm: algorithm, digits: digits, period: period)]
        case "otpauth-migration":
            guard let data = components.queryItems?.first(where: { $0.name == "data" })?.value,
                  let decoded = Data(base64Encoded: data) else {
                return []
            }

            if let payload = try? MigrationPayload(serializedData: decoded) {
                var result = [DecryptedOTP]()
                for otp in payload.otpParameters {
                    if otp.type == .totp {
                        result.append(DecryptedOTP(secret: base32Encode(otp.secret), issuer: otp.issuer, label: otp.name, algorithm: otp.algorithm.mfAlgorithm, digits: otp.digits.mfDigits, period: .init(rawValue: Int(otp.counter)) ?? .standard))
                    }
                }
                return result
            }

            fallthrough
        default: return []
        }
    }
}

private extension MigrationPayload.Algorithm {
    var mfAlgorithm: DecryptedOTP.Algorithm {
        switch self {
        case .sha1: return .sha1
        case .sha256: return .sha256
        case .sha512: return .sha512
        default: return .standard
        }
    }
}

private extension MigrationPayload.DigitCount {
    var mfDigits: DecryptedOTP.Digits {
        switch self {
        case .six: return .six
        case .eight: return .eight
        default: return .standard
        }
    }
}

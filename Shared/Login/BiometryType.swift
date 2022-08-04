//
//  LABiometricType.swift
//  MultiFactor
//
//  Created by g.lofrumento on 04/08/22.
//

import LocalAuthentication

enum BiometryType: String {
    case faceID, touchID, none

    init(from biometry: LABiometryType) {
        switch biometry {
        case .touchID:
            self = .touchID
        case .faceID:
            self = .faceID
        case .none: fallthrough
        @unknown default:
            self = .none
        }
    }

    var name: String {
        switch self {
        case .touchID:
            return "Touch ID"
        case .faceID:
            return "Face ID"
        case .none:
            return ""
        }
    }

    var systemName: String {
        switch self {
        case .touchID:
            return "touchid"
        case .faceID:
            return "faceid"
        case .none:
            return ""
        }
    }
}

//
//  HomeViewModel.swift
//  MultiFactor
//
//  Created by g.lofrumento on 24/07/22.
//

import Foundation
import SwiftUI

class HomeViewModel: ObservableObject {

    init() {
        try? CloudProvider.shared.addOTPChangeListener { otps in
            PersistenceController.shared.save(cloudEncryptedOTPs: otps)
            MFClock.shared.update()
        }
    }

    func addOTP() async {
        try? await CloudProvider.shared.addOTP(CloudEncryptedOTP(id: UUID().uuidString, secret: "I65VU7K5ZQL7WB4E", issuer: "Dropbox", label: "gianluca", algorithm: .sha256, digits: .six, period: .thirty))
    }

    func deleteOTP(_ otp: OTPIdentifier) async {
        try? await CloudProvider.shared.deleteOTP(otp)
    }
}

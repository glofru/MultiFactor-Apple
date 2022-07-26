//
//  HomeViewModel.swift
//  MultiFactor
//
//  Created by g.lofrumento on 24/07/22.
//

import Foundation
import SwiftUI

class HomeViewModel: ObservableObject {

//    @Published var otps = [TOTPViewModel]()
    @Published var otps = [OTPCode]()

    init() {
        try? CloudProvider.shared.addOTPChangeListener({ [weak self] otps in
            withAnimation {
                self?.otps = otps
            }
        })
    }

    func addOTP() async {
        try? await CloudProvider.shared.addOTP(OTPCode(id: UUID().uuidString, secret: "pinco pallo", issuer: "Google", label: "gianluca.lofrumento@gmail.com", algorithm: .sha256, digits: .six, period: 30))
        
    }
}

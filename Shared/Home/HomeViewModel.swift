//
//  HomeViewModel.swift
//  MultiFactor
//
//  Created by g.lofrumento on 24/07/22.
//

import Foundation

class HomeViewModel: ObservableObject {

    @Published var otps = [TOTPViewModel]()

    func addOTP() async {
        let id = await CloudProvider.shared.addOTP(OTPCode(secret: "pinco pallo", issuer: "Google", label: "gianluca.lofrumento@gmail.com", algorithm: .sha256, digits: .six, period: 30))
        print("ID added: \(id)")
    }
}

//
//  TOTPViewModel.swift
//  MultiFactor
//
//  Created by g.lofrumento on 24/07/22.
//

import SwiftUI

class TOTPViewModel: ObservableObject {

    private let totp: TOTPEntity

    init(totp: TOTPEntity) {
        self.totp = totp
    }

}

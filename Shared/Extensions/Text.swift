//
//  Text.swift
//  MultiFactor
//
//  Created by Gianluca Lofrumento on 18/08/22.
//

import SwiftUI

extension Text {
    func mfFont(size: CGFloat = 20) -> Text {
        self.font(.custom("PlayfairDisplay-Regular", size: size))
    }
}

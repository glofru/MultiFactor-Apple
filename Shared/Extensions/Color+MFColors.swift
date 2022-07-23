//
//  Color.swift
//  MultiFactor
//
//  Created by g.lofrumento on 23/07/22.
//

import SwiftUI

extension Color {
    #if os(iOS)
    static let background = Color(uiColor: .systemBackground)
    #elseif os(macOS)
    static let background = Color(nsColor: .controlBackgroundColor)
    #endif

    static let element = Color("element")
}

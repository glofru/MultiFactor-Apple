//
//  Color.swift
//  MultiFactor
//
//  Created by g.lofrumento on 23/07/22.
//

import SwiftUI

extension Color {
    #if os(iOS)
    static let systemBackground = Color(uiColor: .systemBackground)
    #elseif os(macOS)
    static let systemBackground = Color(nsColor: .controlBackgroundColor)
    #endif

    #if os(iOS)
    static let label = Color(uiColor: .label)
    #elseif os(macOS)
    static let label = Color(nsColor: .labelColor)
    #endif

    static let element = Color("element")
}

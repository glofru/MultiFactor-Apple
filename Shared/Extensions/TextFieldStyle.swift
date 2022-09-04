//
//  TextFieldStyle.swift
//  MultiFactor
//
//  Created by Gianluca Lofrumento on 03/09/22.
//

import SwiftUI

extension View {
    func mfStyle() -> some View {
        modifier(MFStyle())
    }
}

private struct MFStyle: ViewModifier {
    func body(content: Content) -> some View {
        content.textFieldStyle(MFTextFieldStyle())
    }
}

private struct MFTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .glassBackground(.element)
            .cornerRadius(10)
        #if os(macOS)
            .textFieldStyle(.plain)
        #endif
    }
}

//
//  Text.swift
//  MultiFactor
//
//  Created by Gianluca Lofrumento on 18/08/22.
//

import SwiftUI

extension Text {
    func mfTitle() -> some View {
        self
            .bold()
            .modifier(MFTitle())
    }

    func mfError() -> some View {
        self
            .foregroundColor(.red)
            .multilineTextAlignment(.center)
    }
}

private struct MFTitle: ViewModifier {
    func body(content: Content) -> some View {
        HStack {
            Spacer()
            content
                .mfFont(size: 30)
                .padding(.vertical)
            Spacer()
        }
    }
}

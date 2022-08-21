//
//  Text+GradientBackground.swift
//  MultiFactor
//
//  Created by Gianluca Lofrumento on 18/08/22.
//

import SwiftUI

struct GradientBackground: ViewModifier {

    let type: GradientType

    func body(content: Content) -> some View {
        GeometryReader { reader in
            content
                .foregroundColor(.white)
                .padding()
                .frame(width: reader.size.width, height: 60)
                .background(type.gradient)
                .cornerRadius(12)
        }
        .frame(height: 60)
    }

    enum GradientType {
        case login
        case signUp

        fileprivate var gradient: LinearGradient {
            switch self {
            case .login: return LinearGradient(gradient: Gradient(colors: [.init(red: 0, green: 0.34, blue: 1), .init(red: 0.3, green: 0.85, blue: 0.39)]), startPoint: .leading, endPoint: .trailing)
            case .signUp: return LinearGradient(gradient: Gradient(colors: [.init(red: 0.93, green: 0.45, blue: 0.02), .init(red: 0.94, green: 0, blue: 0.86)]), startPoint: .leading, endPoint: .trailing)
            }
        }
    }
}

extension Text {
    func gradientBackground(_ type: GradientBackground.GradientType) -> some View {
        modifier(GradientBackground(type: type))
    }

    func mfFont(size: CGFloat = 20) -> Text {
        self.font(.custom("PlayfairDisplay-Regular", size: size))
    }
}

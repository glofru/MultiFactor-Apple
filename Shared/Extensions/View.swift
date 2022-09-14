//
//  View.swift
//  MultiFactor
//
//  Created by g.lofrumento on 23/07/22.
//

import SwiftUI

extension View {
    func glassBackground(_ color: Color, intensity: GlassBackground.Intensity = .weak) -> some View {
        modifier(GlassBackground(color: color, intensity: intensity))
    }

    func gradientBackground(_ type: GradientBackground.GradientType) -> some View {
        modifier(GradientBackground(type: type))
    }

    func mfFont(size: CGFloat = 20) -> some View {
        self.font(.custom("PlayfairDisplay-Regular", size: size))
    }
}

struct GlassBackground: ViewModifier {
    let color: Color
    let intensity: Intensity

    func body(content: Content) -> some View {
        content
            #if os(iOS)
            .background(color)
            #elseif os(macOS)
            .background(color.opacity(intensity.rawValue))
            #endif
    }

    enum Intensity: Double {
        case weak = 0.4
        case strong = 0.7
    }
}

struct GradientBackground: ViewModifier {

    let type: GradientType
    @Environment(\.isEnabled) var isEnabled

    func body(content: Content) -> some View {
        GeometryReader { reader in
            content
                .font(.bold(.body)())
                .foregroundColor(.white)
                .padding()
                .frame(width: reader.size.width, height: 60)
                .background(type.gradient)
                .cornerRadius(12)
                .opacity(isEnabled ? 1 : 0.3)
                .animation(.default, value: isEnabled)
        }
        .frame(height: 60)
    }

    enum GradientType {
        case login
        case signUp

        fileprivate var gradient: LinearGradient {
            switch self {
            case .login: return LinearGradient(gradient: Gradient(colors: [.init(red: 0, green: 0.34, blue: 1), .init(red: 0.11, green: 1, blue: 0.95)]), startPoint: .bottomLeading, endPoint: .topTrailing)
            case .signUp: return LinearGradient(gradient: Gradient(colors: [.init(red: 0.93, green: 0.45, blue: 0.02), .init(red: 0.94, green: 0, blue: 0.86)]), startPoint: .bottomLeading, endPoint: .topTrailing)
            }
        }
    }
}

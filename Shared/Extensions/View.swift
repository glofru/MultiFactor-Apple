//
//  View+GlassBackground.swift
//  MultiFactor
//
//  Created by g.lofrumento on 23/07/22.
//

import SwiftUI

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

extension View {
    func glassBackground(_ color: Color, intensity: GlassBackground.Intensity = .weak) -> some View {
        modifier(GlassBackground(color: color, intensity: intensity))
    }

    func gradientBackground(_ type: GradientBackground.GradientType) -> some View {
        modifier(GradientBackground(type: type))
    }
}

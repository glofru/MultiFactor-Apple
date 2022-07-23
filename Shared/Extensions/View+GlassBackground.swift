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

extension View {
    func glassBackground(intensity: GlassBackground.Intensity = .weak) -> some View {
        glassBackground(.background, intensity: intensity)
    }
    
    func glassBackground(_ color: Color, intensity: GlassBackground.Intensity = .weak) -> some View {
        modifier(GlassBackground(color: color, intensity: intensity))
    }
}

//
//  VisualEffectiveView.swift
//  MultiFactor (macOS)
//
//  Created by g.lofrumento on 21/07/22.

import SwiftUI

struct VisualEffectView: NSViewRepresentable {
    func makeNSView(context: Self.Context) -> NSView {
        return NSVisualEffectView()
    }

    func updateNSView(_ nsView: NSView, context: Context) { }
}

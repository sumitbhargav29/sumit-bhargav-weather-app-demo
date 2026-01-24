//
//  GlassEffect.swift
//  Glasscast-A Minimal Weather App
//
//  Created by Sam's Mac on 24/01/26.
//

import SwiftUI

private struct GlassEffect: ViewModifier {
    @Environment(\.colorScheme) private var systemScheme
    @ObservedObject private var schemeManager = ColorSchemeManager.shared

    // Resolve final scheme: respect user override or system
    private var effectiveScheme: ColorScheme {
        schemeManager.colorScheme ?? systemScheme
    }

    // Tunable parameters if you want to iterate on the look
    var cornerRadius: CGFloat = 16
    var strokeWidthLight: CGFloat = 1.0
    var strokeWidthDark: CGFloat = 1.2

    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)

        return content
            .background(
                ZStack {
                    if effectiveScheme == .dark {
                        // Dark: rely on system material with depth
                        shape.fill(.ultraThinMaterial)
                    } else {
                        // Light: slightly opaque white base plus thin material to keep legibility
                        shape
                            .fill(Color.white.opacity(0.50))
                            .background(.thinMaterial)
                    }
                }
            )
            .overlay(
                shape.stroke(
                    LinearGradient(
                        colors: effectiveScheme == .dark
                            ? [ .white.opacity(0.45), .white.opacity(0.20), .white.opacity(0.25) ]
                            : [ .white.opacity(0.28), .clear, .white.opacity(0.12) ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: effectiveScheme == .dark ? strokeWidthDark : strokeWidthLight
                )
            )
            .clipShape(shape)
            .shadow(
                color: effectiveScheme == .dark ? .black.opacity(0.45) : .black.opacity(0.18),
                radius: effectiveScheme == .dark ? 28 : 18,
                y: effectiveScheme == .dark ? 18 : 10
            )
    }
}

extension View {
    func glassEffect(cornerRadius: CGFloat = 16) -> some View {
        modifier(GlassEffect(cornerRadius: cornerRadius))
    }
}

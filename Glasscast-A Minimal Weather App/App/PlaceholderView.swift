//
//  PlaceholderView.swift
//  Glasscast-A Minimal Weather App
//
//  Created by Sam's Mac on 26/01/26.
//

import SwiftUI
import Foundation

struct PlaceholderView: View {
    // Use a neutral theme so the background doesn't add sunny glow; dark/light comes from ColorSchemeManager.
    private let theme: WeatherTheme = .foggy
    
    var body: some View {
        ZStack {
            WeatherBackground(theme: theme)
                .ignoresSafeArea()
            
            // Animated sky scene
            AnimatedSkyScene()
                .allowsHitTesting(false)
                .accessibilityHidden(true)
            
            VStack(spacing: 16) {
                Text("Demo by Sumit Bhargav Glasscast app")
                    .font(.system(.title3, design: .rounded).weight(.heavy))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.35), radius: 10)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)
                
                ProgressView()
                    .tint(.white)
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(Color.white.opacity(0.25), lineWidth: 1)
                    )
            )
            .shadow(color: .black.opacity(0.35), radius: 16, y: 8)
            .padding(.horizontal, 24)
        }
        .navigationBarBackButtonHidden(true)
        .preferredColorScheme(.dark) // Force dark mode for this view only
        .environment(\.colorScheme, .dark) // Ensure WeatherBackground and any scheme-dependent views render dark
    }
}

// MARK: - Animated Sky Scene

private struct AnimatedSkyScene: View {
    // Keep cloud drifts
    @State private var cloudDrift1: CGFloat = -0.6
    @State private var cloudDrift2: CGFloat = 0.8
    @State private var twinklePhase: CGFloat = 0
    @State private var moonDrift: CGFloat = 0 // horizontal drift
    @State private var starFlicker: CGFloat = 0
    
    var body: some View {
        GeometryReader { proxy in
            let w = proxy.size.width
            let h = proxy.size.height
            let d = min(w, h)
            
            ZStack {
                // Subtle moonlight from bottom horizon
                LinearGradient(
                    colors: [
                        Color.clear,
                        Color.white.opacity(0.08),
                        Color.white.opacity(0.12),
                        .clear
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: h * 0.8)
                .offset(y: h * 0.18)
                .blendMode(.plusLighter)
                .allowsHitTesting(false)
                
                // Denser star field: two layers (extended farther down)
                DenseStars(countFactor: d, flicker: starFlicker, layerOpacity: 0.7, spread: 0.7, verticalCoverage: 0.95)
                    .blendMode(.plusLighter)
                    .opacity(0.9)
                    .allowsHitTesting(false)
                DenseStars(countFactor: d, flicker: starFlicker, layerOpacity: 0.5, spread: 1.0, verticalCoverage: 1.0)
                    .blendMode(.plusLighter)
                    .opacity(0.6)
                    .allowsHitTesting(false)
                
                // Full moon with gentle drift
                FullMoon(size: d * 0.26)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    .offset(x: -w * 0.14 + moonDrift, y: h * 0.08)
                
                // Moonlight glow from bottom (slightly reduced intensity)
                MoonlightGlow(intensity: 0.8)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                    .offset(y: h * 0.02)
                    .allowsHitTesting(false)
                
                // Two clouds: 1 big center, 1 small side, two bands for parallax
                TwoClouds(scale: 1.0, opacity: 0.88)
                    .offset(x: cloudDrift1 * w, y: -h * 0.16)
                    .frame(height: d * 0.28)
                
                TwoClouds(scale: 0.9, opacity: 0.68)
                    .offset(x: cloudDrift2 * w, y: -h * 0.06)
                    .frame(height: d * 0.30)
                
                // Gentle floating particles for depth
                FloatingDust(count: 40)
                    .blendMode(.plusLighter)
                    .opacity(0.35)
                    .offset(y: h * 0.1)
                
                // Occasional twinkle line
                Twinkles(phase: twinklePhase)
                    .opacity(0.16)
                    .blendMode(.plusLighter)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .padding(.top, h * 0.08)
            }
            .onAppear {
                // Cloud parallax
                withAnimation(.linear(duration: 22).repeatForever(autoreverses: false)) {
                    cloudDrift1 = 1.2
                }
                withAnimation(.linear(duration: 34).repeatForever(autoreverses: false)) {
                    cloudDrift2 = -1.2
                }
                // Twinkle phase oscillation
                withAnimation(.linear(duration: 8).repeatForever(autoreverses: true)) {
                    twinklePhase = .pi * 2
                }
                // Slow moon drift left-right
                withAnimation(.easeInOut(duration: 14).repeatForever(autoreverses: true)) {
                    moonDrift = w * 0.08
                }
                // Star flicker
                withAnimation(.easeInOut(duration: 3.2).repeatForever(autoreverses: true)) {
                    starFlicker = .pi * 2
                }
            }
        }
        .ignoresSafeArea()
    }
}

// MARK: - Components

// Full moon with soft rim light and inner texture glow
private struct FullMoon: View {
    let size: CGFloat
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.white.opacity(0.35),
                            Color.white.opacity(0.12),
                            .clear
                        ],
                        center: .center,
                        startRadius: size * 0.1,
                        endRadius: size * 0.9
                    )
                )
                .frame(width: size * 1.8, height: size * 1.8)
                .blur(radius: size * 0.4)
                .blendMode(.plusLighter)
            
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white,
                            Color.white.opacity(0.95)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size, height: size)
                .overlay {
                    Circle()
                        .stroke(Color.white.opacity(0.35), lineWidth: size * 0.02)
                }
                .shadow(color: .white.opacity(0.45), radius: size * 0.16)
        }
    }
}

// Bottom moonlight glow
private struct MoonlightGlow: View {
    var intensity: CGFloat = 1.0
    var body: some View {
        GeometryReader { geo in
            let d = min(geo.size.width, geo.size.height)
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.white.opacity(0.18 * intensity),
                            Color.white.opacity(0.06 * intensity),
                            .clear
                        ],
                        center: .center,
                        startRadius: d * 0.1,
                        endRadius: d * 0.9
                    )
                )
                .frame(width: d * 1.6, height: d * 0.9)
                .offset(y: d * 0.38)
                .blur(radius: d * 0.18)
                .blendMode(.plusLighter)
        }
    }
}

// Denser star field using Canvas (reduced density + varied shapes/sizes)
private struct DenseStars: View {
    let countFactor: CGFloat
    let flicker: CGFloat
    let layerOpacity: Double
    let spread: CGFloat
    // New: how much of the height stars can occupy (0...1)
    var verticalCoverage: CGFloat = 0.55
    
    var body: some View {
        TimelineView(.animation) { _ in
            Canvas { context, size in
                // Reduce count significantly and clamp
                let base = Int((countFactor * 0.25) * spread) // was 1.2
                let baseCount = max(40, min(140, base))
                
                // Simple stable RNG from index
                func rand(_ i: Int, _ m: Int) -> Double {
                    let a = 1103515245
                    let c = 12345
                    var x = i &* a &+ c
                    x = x &* a &+ c
                    let v = abs(x % m)
                    return Double(v) / Double(m)
                }
                
                for i in 0..<baseCount {
                    // Position (allow configurable vertical coverage)
                    let fx = rand(i &* 73, 997)
                    let fy = rand(i &* 191, 983)
                    let x = CGFloat(fx) * size.width
                    let y = CGFloat(fy) * size.height * max(0.0, min(1.0, verticalCoverage))
                    
                    // Size tier: many small, some medium, a few large
                    let sizePick = rand(i &* 29, 1000)
                    let starSize: CGFloat
                    if sizePick < 0.75 {        // 75% tiny
                        starSize = CGFloat(0.6 + rand(i &* 7, 1000) * 0.6)
                    } else if sizePick < 0.95 { // 20% small/medium
                        starSize = CGFloat(1.2 + rand(i &* 11, 1000) * 1.2)
                    } else {                    // 5% larger accents
                        starSize = CGFloat(2.2 + rand(i &* 17, 1000) * 1.6)
                    }
                    
                    // Shape choice: circle, cross, dash
                    let shapePick = rand(i &* 41, 1000)
                    
                    // Flicker: subtle, per-star phase
                    let phase = Double(flicker) + rand(i &* 5, 1000) * .pi * 2
                    let flick = 0.85 + 0.15 * sin(phase)
                    let alpha = layerOpacity * flick
                    
                    // Color
                    let color = Color.white.opacity(alpha)
                    
                    // Draw
                    var starPath = Path()
                    switch shapePick {
                    case ..<0.70:
                        // Circle (most)
                        let rect = CGRect(x: x, y: y, width: starSize, height: starSize)
                        starPath.addEllipse(in: rect)
                        context.fill(starPath, with: .color(color))
                        
                    case ..<0.90:
                        // Small cross
                        let len = max(1.0, starSize * 1.2)
                        let lw: CGFloat = max(0.6, starSize * 0.22)
                        var p = Path()
                        p.move(to: CGPoint(x: x - len/2, y: y))
                        p.addLine(to: CGPoint(x: x + len/2, y: y))
                        p.move(to: CGPoint(x: x, y: y - len/2))
                        p.addLine(to: CGPoint(x: x, y: y + len/2))
                        context.stroke(p, with: .color(color), lineWidth: lw)
                        
                    default:
                        // Short dash with slight rotation
                        let len = max(1.0, starSize * 1.6)
                        let lw: CGFloat = max(0.6, starSize * 0.22)
                        let angle = CGFloat(rand(i &* 23, 1000) * .pi)
                        let dx = cos(angle) * (len / 2)
                        let dy = sin(angle) * (len / 2)
                        var p = Path()
                        p.move(to: CGPoint(x: x - dx, y: y - dy))
                        p.addLine(to: CGPoint(x: x + dx, y: y + dy))
                        context.stroke(p, with: .color(color), lineWidth: lw)
                    }
                }
            }
        }
    }
}

// Two clouds side-by-side: 1 big center, 1 small side
private struct TwoClouds: View {
    var scale: CGFloat = 1.0
    var opacity: Double = 0.85
    
    private let emoji = "☁️"
    
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let base = min(w, h)
            
            HStack(alignment: .center, spacing: base * 0.06) {
                cloudEmoji(size: base * 0.55 * scale, opacity: opacity * 0.82)
                    .offset(y: base * 0.02)
                cloudEmoji(size: base * 0.80 * scale, opacity: opacity) // big center
                    .offset(y: -base * 0.02)
                // Removed third cloud
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        .allowsHitTesting(false)
    }
    
    private func cloudEmoji(size: CGFloat, opacity: Double) -> some View {
        Text(emoji)
            .font(.system(size: max(80, size)))
            .opacity(opacity)
            .shadow(color: .black.opacity(0.06), radius: 4, y: 1.2)
            .accessibilityHidden(true)
    }
}

private struct FloatingDust: View {
    let count: Int
    @State private var time: CGFloat = 0
    
    var body: some View {
        TimelineView(.animation) { _ in
            Canvas { context, size in
                for i in 0..<count {
                    let seed = CGFloat(i) * 37.123
                    // x position
                    let sinSeed = sin(Double(seed))
                    let xFactor = CGFloat(sinSeed) * 0.5 + 0.5
                    let x = xFactor * size.width
                    // y base
                    let cosSeed = cos(Double(seed * 0.7))
                    let yFactor = CGFloat(cosSeed) * 0.5 + 0.5
                    let yBase = yFactor * size.height
                    // drift and vertical oscillation
                    let drift = CGFloat(sin(Double(time * 0.25 + seed))) * 18
                    let yOsc = CGFloat(sin(Double(time * 0.18 + seed * 1.3))) * 10
                    let y = yBase + yOsc
                    // radius
                    let absSin = abs(CGFloat(sin(Double(seed))))
                    let r = CGFloat(1.2 + absSin * 2.0)
                    
                    let rect = CGRect(x: x + drift, y: y, width: r, height: r)
                    context.fill(Path(ellipseIn: rect), with: .color(.white.opacity(0.6)))
                }
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 1.0).repeatForever(autoreverses: false)) {
                time = 1000 // animation engine samples over time
            }
        }
    }
}

private struct Twinkles: View {
    var phase: CGFloat
    
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let count = max(14, Int(min(w, h) / 28)) // a bit denser
            Canvas { context, _ in
                for i in 0..<count {
                    let fx = CGFloat(i) / CGFloat(max(1, count - 1))
                    let x = fx * w
                    let ySin = sin(Double(fx * .pi * 2 + phase))
                    let y = CGFloat(ySin) * 6 + h * 0.08
                    let rSin = sin(Double(fx * 8 + phase))
                    let r = 1.0 + (CGFloat(rSin) + 1) * 0.8
                    let rect = CGRect(x: x, y: y, width: r, height: r)
                    context.fill(Path(ellipseIn: rect), with: .color(.white))
                }
            }
        }
        .frame(height: 60)
    }
}

#Preview {
    PlaceholderView()
}


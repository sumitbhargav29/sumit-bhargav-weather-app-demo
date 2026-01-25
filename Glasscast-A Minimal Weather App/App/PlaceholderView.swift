//
//  PlaceholderView.swift
//  Glasscast-A Minimal Weather App
//
//  Created by Sam's Mac on 26/01/26.
//

import SwiftUI

struct PlaceholderView: View {
    // Pick any theme you like for the splash
    private let theme: WeatherTheme = .sunny
    
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
    }
}

// MARK: - Animated Sky Scene

private struct AnimatedSkyScene: View {
    // Flip direction: start below (positive), animate upward toward slight negative/zero
    @State private var sunRise: CGFloat = 0.6
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
                // Subtle horizon glow
                LinearGradient(
                    colors: [
                        Color.clear,
                        Color.orange.opacity(0.10),
                        Color.yellow.opacity(0.12),
                        .clear
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: h * 0.75)
                .offset(y: h * 0.12)
                .blendMode(.plusLighter)
                .allowsHitTesting(false)
                
                
                
                // Star cluster around the moon (brighter than background twinkles)
                StarCluster(radius: d * 0.18, flicker: starFlicker)
                    .opacity(0.65)
                    .blendMode(.plusLighter)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    .offset(x: -w * 0.18 + moonDrift, y: h * 0.05)
                
                // Rising sun
                RisingSun(size: d * 0.6, verticalOffset: sunRise * h)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                    .offset(y: -h * 0.08)
                
                // Drifting clouds (two layers for parallax)
                CloudBand(amplitude: 10, blur: 0, opacity: 0.75)
                    .offset(x: cloudDrift1 * w, y: -h * 0.18)
                    .frame(height: d * 0.28)
                
                CloudBand(amplitude: 16, blur: 2, opacity: 0.55)
                    .offset(x: cloudDrift2 * w, y: -h * 0.08)
                    .frame(height: d * 0.32)
                
                // Gentle floating particles for depth
                FloatingDust(count: 30)
                    .blendMode(.plusLighter)
                    .opacity(0.35)
                    .offset(y: h * 0.1)
                
                // Occasional twinkle in the upper sky (very subtle)
                Twinkles(phase: twinklePhase)
                    .opacity(0.12)
                    .blendMode(.plusLighter)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .padding(.top, h * 0.08)
            }
            .onAppear {
                // Animate sun upward
                withAnimation(.easeInOut(duration: 2.6)) {
                    sunRise = -0.05
                }
                // Cloud parallax
                withAnimation(.linear(duration: 18).repeatForever(autoreverses: false)) {
                    cloudDrift1 = 1.2
                }
                withAnimation(.linear(duration: 28).repeatForever(autoreverses: false)) {
                    cloudDrift2 = -1.2
                }
                // Twinkle phase oscillation
                withAnimation(.linear(duration: 8).repeatForever(autoreverses: true)) {
                    twinklePhase = .pi * 2
                }
                // Slow moon drift left-right
                withAnimation(.easeInOut(duration: 12).repeatForever(autoreverses: true)) {
                    moonDrift = w * 0.06
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

private struct RisingSun: View {
    let size: CGFloat
    let verticalOffset: CGFloat
    
    var body: some View {
        ZStack {
            // Soft glow layers
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.yellow.opacity(0.12),
                            Color.orange.opacity(0.08),
                            .clear
                        ],
                        center: .center,
                        startRadius: size * 0.15,
                        endRadius: size * 0.65
                    )
                )
                .frame(width: size * 1.6, height: size * 1.2)
                .blur(radius: size * 0.2)
                .offset(y: verticalOffset - size * 0.4)
                .blendMode(.plusLighter)
            
            // Sun
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color.yellow, Color.orange],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size * 0.32, height: size * 0.32)
                .shadow(color: .yellow.opacity(0.6), radius: size * 0.08, y: size * 0.02)
                .offset(y: verticalOffset)
        }
    }
}

 
private struct StarCluster: View {
    let radius: CGFloat
    var flicker: CGFloat // 0...2π
    
    private struct Star {
        var angle: CGFloat
        var dist: CGFloat
        var size: CGFloat
        var phase: CGFloat
    }
    
    private func stars() -> [Star] {
        // Fixed set for deterministic layout
        [
            Star(angle: .pi * 0.15, dist: radius * 0.35, size: 2.6, phase: 0.0),
            Star(angle: .pi * 0.35, dist: radius * 0.55, size: 2.0, phase: 0.8),
            Star(angle: .pi * 0.52, dist: radius * 0.42, size: 1.6, phase: 1.6),
            Star(angle: .pi * 0.80, dist: radius * 0.60, size: 2.2, phase: 2.2),
            Star(angle: .pi * 1.05, dist: radius * 0.50, size: 1.8, phase: 2.8),
            Star(angle: .pi * 1.28, dist: radius * 0.38, size: 1.4, phase: 3.6)
        ]
    }
    
    var body: some View {
        GeometryReader { geo in
            let center = CGPoint(x: geo.size.width * 0.5, y: geo.size.height * 0.5)
            Canvas { context, _ in
                for s in stars() {
                    let alpha = 0.6 + 0.4 * sin(flicker + s.phase)
                    let x = center.x + cos(s.angle) * s.dist
                    let y = center.y - sin(s.angle) * s.dist
                    let rect = CGRect(x: x, y: y, width: s.size, height: s.size)
                    context.fill(Path(ellipseIn: rect), with: .color(.white.opacity(alpha)))
                }
            }
        }
        .frame(width: radius * 2.0, height: radius * 1.2)
    }
}

private struct CloudBand: View {
    var amplitude: CGFloat = 12
    var blur: CGFloat = 0
    var opacity: Double = 0.7
    
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let base = h * 0.42
            
            ZStack {
                CloudShape()
                    .fill(.white.opacity(opacity))
                    .frame(width: w * 0.9, height: base)
                    .offset(x: -w * 0.25, y: 0)
                    .blur(radius: blur)
                
                CloudShape()
                    .fill(.white.opacity(opacity * 0.9))
                    .frame(width: w * 0.7, height: base * 0.95)
                    .offset(x: w * 0.05, y: -amplitude * 0.3)
                    .blur(radius: blur * 0.8)
                
                CloudShape()
                    .fill(.white.opacity(opacity * 0.8))
                    .frame(width: w * 0.55, height: base * 0.9)
                    .offset(x: w * 0.35, y: amplitude * 0.25)
                    .blur(radius: blur * 0.6)
            }
        }
        .allowsHitTesting(false)
    }
}

private struct CloudShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width
        let h = rect.height
        
        // A puffy cloud made from overlapping arcs
        let c1 = CGRect(x: w * 0.05, y: h * 0.35, width: w * 0.35, height: h * 0.7)
        let c2 = CGRect(x: w * 0.28, y: h * 0.15, width: w * 0.42, height: h * 0.9)
        let c3 = CGRect(x: w * 0.58, y: h * 0.30, width: w * 0.35, height: h * 0.7)
        let base = CGRect(x: w * 0.05, y: h * 0.55, width: w * 0.88, height: h * 0.5)
        
        p.addEllipse(in: c1)
        p.addEllipse(in: c2)
        p.addEllipse(in: c3)
        p.addRoundedRect(in: base, cornerSize: CGSize(width: h * 0.25, height: h * 0.25))
        return p
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
                    let x = CGFloat(truncating: NSNumber(value: Float(sin(seed) * 0.5 + 0.5))) * size.width
                    let yBase = CGFloat(truncating: NSNumber(value: Float(cos(seed * 0.7) * 0.5 + 0.5))) * size.height
                    let drift = sin((time * 0.25) + seed) * 18
                    let y = yBase + sin((time * 0.18) + seed * 1.3) * 10
                    let r = CGFloat(1.2 + abs(sin(seed)) * 2.0)
                    
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
            let count = max(10, Int(min(w, h) / 40))
            
            Canvas { context, _ in
                for i in 0..<count {
                    let fx = CGFloat(i) / CGFloat(count - 1)
                    let x = fx * w
                    let y = sin(fx * .pi * 2 + phase) * 6 + h * 0.08
                    let r = 1.0 + (sin(fx * 8 + phase) + 1) * 0.8
                    
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


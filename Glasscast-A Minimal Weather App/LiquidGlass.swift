//
//  LiquidGlass.swift
//  Glasscast-A Minimal Weather App
//
//  Created by Sam's Mac on 21/01/26.
//

import Foundation
import SwiftUI
import Combine

// Shared animation timer to reduce battery usage
class LiquidGlassTimer: ObservableObject {
    static let shared = LiquidGlassTimer()
    
    @Published var time: Float = 0
    private var timer: Timer?
    private var activeViewCount = 0
    private let lockQueue = DispatchQueue(label: "com.glasscast.timer")
    
    private init() {
        // Timer starts when first view appears
    }
    
    func incrementViewCount() {
        lockQueue.async { [weak self] in
            guard let self = self else { return }
            let shouldStart = self.activeViewCount == 0
            self.activeViewCount += 1
            if shouldStart {
                DispatchQueue.main.async {
                    self.startTimer()
                }
            }
        }
    }
    
    func decrementViewCount() {
        lockQueue.async { [weak self] in
            guard let self = self else { return }
            self.activeViewCount = max(0, self.activeViewCount - 1)
            let shouldStop = self.activeViewCount == 0
            if shouldStop {
                DispatchQueue.main.async {
                    self.stopTimer()
                }
            }
        }
    }
    
    private func startTimer() {
        guard timer == nil else { return }
        
        // Update at 30fps instead of 60fps to reduce battery usage
        // Slower animation speed for smoother, less intensive animation
        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 30.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.time += 0.008 // Slower increment for better battery life
            if self.time > 100 {
                self.time = 0 // Reset to prevent overflow
            }
        }
        
        // Use common mode to ensure timer runs during scrolling
        if let timer = timer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    deinit {
        timer?.invalidate()
    }
}

struct LiquidGlass: ViewModifier {
    var cornerRadius: CGFloat
    var intensity: Float

    @ObservedObject private var timer = LiquidGlassTimer.shared

    func body(content: Content) -> some View {
        content
            .background {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.ultraThinMaterial)
                    .distortionEffect(
                        Shader(
                            function: ShaderFunction(
                                library: .default,
                                name: "liquidRefraction"
                            ),
                            arguments: [
                                .float(timer.time),
                                .float(intensity)
                            ]
                        ),
                        // Reduced maxSampleOffset for better performance
                        maxSampleOffset: CGSize(width: 8, height: 8)
                    )
                    .overlay {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        .white.opacity(0.35),
                                        .clear,
                                        .white.opacity(0.15)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    }
            }
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .shadow(color: .black.opacity(0.3), radius: 30, y: 20)
            .onAppear {
                timer.incrementViewCount()
            }
            .onDisappear {
                timer.decrementViewCount()
            }
    }
}

extension View {
    func liquidGlass(cornerRadius: CGFloat, intensity: Float = 0.4) -> some View {
        modifier(LiquidGlass(cornerRadius: cornerRadius, intensity: intensity))
    }
}

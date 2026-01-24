//
//  LiquidGlass.swift
//  Glasscast-A Minimal Weather App
//
//  Created by Sam's Mac on 21/01/26.


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


//sam sepration

//import Foundation
//import SwiftUI
//import Combine
//
//// MARK: - Shared animation timer (battery friendly)
//final class LiquidGlassTimer: ObservableObject {
//    static let shared = LiquidGlassTimer()
//
//    @Published var time: Float = 0
//    private var timer: Timer?
//    private var activeViewCount = 0
//    private let lockQueue = DispatchQueue(label: "com.glasscast.timer")
//
//    private init() {}
//
//    func incrementViewCount() {
//        lockQueue.async { [weak self] in
//            guard let self else { return }
//            let shouldStart = self.activeViewCount == 0
//            self.activeViewCount += 1
//            if shouldStart {
//                DispatchQueue.main.async { self.startTimer() }
//            }
//        }
//    }
//
//    func decrementViewCount() {
//        lockQueue.async { [weak self] in
//            guard let self else { return }
//            self.activeViewCount = max(0, self.activeViewCount - 1)
//            if self.activeViewCount == 0 {
//                DispatchQueue.main.async { self.stopTimer() }
//            }
//        }
//    }
//
//    private func startTimer() {
//        guard timer == nil else { return }
//
//        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 30.0, repeats: true) { [weak self] _ in
//            guard let self else { return }
//            self.time += 0.008
//            if self.time > 100 { self.time = 0 }
//        }
//
//        if let timer {
//            RunLoop.main.add(timer, forMode: .common)
//        }
//    }
//
//    private func stopTimer() {
//        timer?.invalidate()
//        timer = nil
//    }
//}
//
//// MARK: - Liquid Glass Modifier
//struct LiquidGlass: ViewModifier {
//    var cornerRadius: CGFloat
//    var intensity: Float
//
//    @ObservedObject private var timer = LiquidGlassTimer.shared
//    @Environment(\.colorScheme) private var scheme
//
//    func body(content: Content) -> some View {
//        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
//
//        content
//            .background {
//                if scheme == .dark {
//                    // 🌙 DARK MODE — YOUR ORIGINAL HEAVEN
//                    shape
//                        .fill(.ultraThinMaterial)
//                        .distortionEffect(
//                            Shader(
//                                function: ShaderFunction(
//                                    library: .default,
//                                    name: "liquidRefraction"
//                                ),
//                                arguments: [
//                                    .float(timer.time),
//                                    .float(intensity)
//                                ]
//                            ),
//                            maxSampleOffset: CGSize(width: 8, height: 8)
//                        )
//                } else {
//                    // 🌤 LIGHT MODE — SIMPLE & READABLE
//                    shape
//                        .fill(Color.white.opacity(0.55))
//                        .background(.thinMaterial)
//                }
//            }
//            .overlay(
//                shape.stroke(Color.white.opacity(0.35), lineWidth: 1)
//            )
//            .clipShape(shape)
//            .shadow(
//                color: .black.opacity(scheme == .dark ? 0.35 : 0.18),
//                radius: scheme == .dark ? 30 : 18,
//                y: scheme == .dark ? 20 : 10
//            )
//            .onAppear { timer.incrementViewCount() }
//            .onDisappear { timer.decrementViewCount() }
//    }
//}
//
//// MARK: - View Extension
//extension View {
//    func liquidGlass(cornerRadius: CGFloat, intensity: Float = 0.4) -> some View {
//        modifier(LiquidGlass(cornerRadius: cornerRadius, intensity: intensity))
//    }
//}

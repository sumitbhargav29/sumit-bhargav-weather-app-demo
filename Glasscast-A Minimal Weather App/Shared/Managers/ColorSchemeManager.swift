//
//  ColorSchemeManager.swift
//  Glasscast-A Minimal Weather App
//
//  Created by Sam's Mac on 23/01/26.
//

import SwiftUI
import Combine

/// Manages app-wide color scheme preference
class ColorSchemeManager: ObservableObject {
    static let shared = ColorSchemeManager()
    
    // 🌤️ Sky ink colors (Light Mode)
    private let skyTextPrimary = Color(red: 0.12, green: 0.22, blue: 0.32)
    private let skyTextSecondary = Color(red: 0.32, green: 0.42, blue: 0.52)
    
    // Default to dark so app launches in dark mode on first run.
    // User changes in SettingsView persist via @AppStorage.
    @AppStorage(AppConstants.StorageKeys.appColorScheme) var storedScheme: String = "dark" {
        didSet {
            objectWillChange.send()
        }
    }
    
    var colorScheme: ColorScheme? {
        switch storedScheme {
        case "dark":
            return .dark
        case "light":
            return .light
        default:
            return nil // system
        }
    }
    
    var isDarkMode: Bool {
        storedScheme == "dark"
    }
    
    var isLightMode: Bool {
        storedScheme == "light"
    }
    
    func setDarkMode() {
        storedScheme = "dark"
    }
    
    func setLightMode() {
        storedScheme = "light"
    }
    
    func setSystemMode() {
        storedScheme = "system"
    }
    
    private init() {}
}

// MARK: - Adaptive Colors Extension

extension ColorSchemeManager {
    /// Returns adaptive text/icon color: white for dark mode, dark for light mode
    func adaptiveForegroundColor(
        opacity: Double = 1.0,
        isSecondary: Bool = false
    ) -> Color {
        if isLightMode {
            return (isSecondary ? skyTextSecondary : skyTextPrimary)
                .opacity(opacity)
        } else if isDarkMode {
            return Color.white.opacity(opacity)
        } else {
            // System mode
            return Color.primary.opacity(opacity)
        }
    }
    
    /// Static helper to get adaptive foreground color from shared instance
    static func adaptiveForegroundColor(
        opacity: Double = 1.0,
        isSecondary: Bool = false
    ) -> Color {
        shared.adaptiveForegroundColor(
            opacity: opacity,
            isSecondary: isSecondary
        )
    }
}

extension View {
    func adaptiveForeground(
        colorSchemeManager: ColorSchemeManager = ColorSchemeManager.shared,
        opacity: Double = 1.0,
        secondary: Bool = false
    ) -> some View {
        self.foregroundColor(
            colorSchemeManager.adaptiveForegroundColor(
                opacity: opacity,
                isSecondary: secondary
            )
        )
    }
}

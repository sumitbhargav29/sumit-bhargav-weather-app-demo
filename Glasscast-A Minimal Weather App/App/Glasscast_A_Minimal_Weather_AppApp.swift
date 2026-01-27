//
//  Glasscast_A_Minimal_Weather_AppApp.swift
//  Glasscast-A Minimal Weather App
//
//  Created by Sam's Mac on 20/01/26.
//

import SwiftUI

@main
struct Glasscast_A_Minimal_Weather_AppApp: App {
    // Create one shared container for the whole app, optionally with UI-test mocks
    @StateObject private var container: AppContainer
    @ObservedObject private var colorSchemeManager = ColorSchemeManager.shared

    init() {
        // Detect UI test mode
        let args = ProcessInfo.processInfo.arguments
        if args.contains("-UITests") {
            // Use mocks for deterministic UI testing
            // Use MockAuthService (always succeeds). Weather can stay real or be mocked if available.
            let mockAuth = MockAuthService()
            // If you have a MockWeatherService in your project, you can use it here.
            // Otherwise, the default WeatherAPIService will be used.
            let weatherService: WeatherService? = nil
            _container = StateObject(wrappedValue: AppContainer(
                session: AppSession(),
                favoritesStore: nil,
                weatherService: weatherService,
                favoritingService: nil,
                authService: mockAuth
            ))
        } else {
            _container = StateObject(wrappedValue: AppContainer())
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                // Inject DI container into environment
                .environment(\.container, container)
                // Expose the single FavoritesStore instance app-wide
                .environmentObject(container.favoritesStore)
                // Apply color scheme preference (nil = system)
                .preferredColorScheme(colorSchemeManager.colorScheme)
        }
    }
}

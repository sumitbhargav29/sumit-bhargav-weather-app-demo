//
//  Glasscast_A_Minimal_Weather_AppApp.swift
//  Glasscast-A Minimal Weather App
//
//  Created by Sam's Mac on 20/01/26.
//

import SwiftUI

@main
struct Glasscast_A_Minimal_Weather_AppApp: App {
    // Create one shared container for the whole app
    @StateObject private var container = AppContainer()
    @ObservedObject private var colorSchemeManager = ColorSchemeManager.shared
    
    init() {
        print(
            Bundle.main.infoDictionary?["SUPABASE_PROJECT_URL"] ?? "MISSING",
            Bundle.main.infoDictionary?["SUPABASE_ANON_KEY"] ?? "MISSING",
            Bundle.main.infoDictionary?["WEATHER_API_URL"] ?? "MISSING",
            Bundle.main.infoDictionary?["WEATHER_API_KEY"] ?? "MISSING",
        )
    }
    
    var body: some Scene {
        WindowGroup {
            
            AuthContainer()
            
            // Inject DI container into environment
                .environment(\.container, container)
            // Expose the single FavoritesStore instance app-wide
                .environmentObject(container.favoritesStore)
            // Apply color scheme preference (nil = system)
                .preferredColorScheme(colorSchemeManager.colorScheme)
            
        }
    }
}

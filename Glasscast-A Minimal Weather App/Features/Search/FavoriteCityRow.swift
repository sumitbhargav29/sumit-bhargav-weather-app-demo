//
//  FavoriteCityRow.swift
//  Glasscast-A Minimal Weather App
//
//  Created by Sam's Mac on 24/01/26.
//

import SwiftUI

struct FavoriteCityRow: View {
    let city: FavoriteCity
    let weather: CurrentWeather?
    let isLoading: Bool
    let onDelete: () -> Void

    private func adaptiveForeground(opacity: Double = 1.0) -> Color {
        ColorSchemeManager.shared.adaptiveForegroundColor(opacity: opacity)
    }

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(.ultraThinMaterial)
                .frame(width: 36, height: 36)
                .overlay {
                    Image(systemName: AppConstants.Symbols.starFill)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(LinearGradient(
                            colors: [.cyan, .blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                }

            VStack(alignment: .leading, spacing: 2) {
                Text(city.city)
                    .font(.subheadline.bold())
                    .foregroundColor(adaptiveForeground())
                Text(city.country)
                    .font(.caption)
                    .foregroundColor(adaptiveForeground(opacity: 0.7))
            }

            Spacer()

            if isLoading {
                ProgressView()
                    .tint(.white)
            } else if let cw = weather {
                HStack(spacing: 8) {
                    Image(systemName: cw.symbolName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(adaptiveForeground())
                    let (t, h, l) = TemperatureUnit.convert(temp: cw.temperature, high: cw.high, low: cw.low)
                    Text("\(t)°")
                        .font(.subheadline.bold())
                        .foregroundColor(adaptiveForeground())
                    Text("\(AppConstants.UI.highAbbrev) \(h)°  \(AppConstants.UI.lowAbbrev) \(l)°")
                        .font(.caption)
                        .foregroundColor(adaptiveForeground(opacity: 0.8))
                }
            } else {
                Text(AppConstants.UI.placeholderDash)
                    .font(.caption)
                    .foregroundColor(adaptiveForeground(opacity: 0.6))
            }

            Button {
                HapticFeedback.light()
                onDelete()
            } label: {
                Image(systemName: AppConstants.Symbols.trashFill)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.red)
                    .padding(8)
                    .background(
                        Circle().fill(.ultraThinMaterial)
                    )
            }
            .buttonStyle(.plain)
            .accessibilityLabel(AppConstants.Accessibility.removeFavorite)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
        .glassEffect()
    }
}

#Preview {
    let fav = FavoriteCity(
        id: UUID(),
        user_id: UUID(),
        city: "Cupertino",
        country: "USA",
        created_at: Date(),
        lat: 37.3349,
        lon: -122.0090
    )
    let weather = CurrentWeather(
        city: "Cupertino",
        temperature: 72,
        condition: "Sunny",
        high: 76,
        low: 58,
        symbolName: "sun.max.fill",
        theme: .sunny,
        feelsLikeF: 74,
        windKph: 12,
        humidity: 50,
        pressureMb: 1016,
        visibilityKm: 10,
        uvIndex: 5,
        gustKph: 20,
        windDirection: "W",
        windDegrees: 270,
        dewpointF: 50,
        heatIndexF: 75,
        aqiEPA: 2,
        aqiDEFRA: 3,
        pm25: 12,
        pm10: 18,
        sunrise: "6:42 AM",
        sunset: "7:58 PM",
        precipChance: 10
    )
    return SearchCityView(selectedTab: .constant(1))
        .environmentObject(FavoritesStore())
        .environment(\.container, AppContainer())
        .environmentObject(SelectedCityStore())
        .previewDisplayName("Integration Preview")
}

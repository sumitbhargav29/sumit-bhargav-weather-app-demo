//
//  SearchResultRow.swift
//  Glasscast-A Minimal Weather App
//
//  Created by Sam's Mac on 24/01/26.
//

import SwiftUI

struct SearchResultRow: View {
    let city: CitySearchResult
    let weather: CurrentWeather?
    let isFavorite: Bool
    let isLoading: Bool
    let onToggleFavorite: () -> Void
    
    private func adaptiveForeground(opacity: Double = 1.0) -> Color {
        ColorSchemeManager.shared.adaptiveForegroundColor(opacity: opacity)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(.ultraThinMaterial)
                .frame(width: 36, height: 36)
                .overlay {
                    Image(systemName: AppConstants.Symbols.magnifyingglass)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(adaptiveForeground())
                }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(city.name)
                    .font(.subheadline.bold())
                    .foregroundColor(adaptiveForeground())
                Text("\(city.region.isEmpty ? "" : city.region + ", ")\(city.country)")
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
                HapticFeedback.selection()
                onToggleFavorite()
            } label: {
                Image(systemName: isFavorite ? AppConstants.Symbols.starFill : AppConstants.Symbols.star)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(isFavorite ? .yellow : adaptiveForeground())
                    .padding(8)
                    .background(
                        Circle().fill(.ultraThinMaterial)
                    )
            }
            .buttonStyle(.plain)
            .accessibilityLabel(isFavorite ? AppConstants.Accessibility.removeFromFavorites : AppConstants.Accessibility.addToFavorites)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
        .glassEffect()
    }
}

#Preview {
    let sample = CitySearchResult(
        id: 1,
        name: "London",
        region: "England",
        country: "UK",
        lat: 51.5072,
        lon: -0.1276,
        url: "london"
    )
    return SearchResultRow(
        city: sample,
        weather: nil,
        isFavorite: false,
        isLoading: false,
        onToggleFavorite: {}
    )
    .padding()
    .background(Color.black.opacity(0.2))
}

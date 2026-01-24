//
//  HomeView.swift
//  Glasscast-A Minimal Weather App
//
//  Created by Sam's Mac on 22/01/26.
//

import Foundation
import SwiftUI
import CoreLocation

struct HomeView: View {
    @Environment(\.container) private var container
    @EnvironmentObject private var selectedCity: SelectedCityStore
    
    @StateObject private var model: HomeViewModel
    @StateObject private var locator = LocationProvider()
    @ObservedObject private var colorSchemeManager = ColorSchemeManager.shared
    @Environment(\.colorScheme) private var systemScheme
    private var effectiveScheme: ColorScheme {
        colorSchemeManager.colorScheme ?? systemScheme
    }
    private let geocoder = CLGeocoder()
    
    // Units
    @AppStorage(AppConstants.StorageKeys.windUnitIsKmh) private var windUnitIsKmh: Bool = true
    @AppStorage(AppConstants.StorageKeys.pressureUnitIsHpa) private var pressureUnitIsHpa: Bool = true
    @AppStorage(AppConstants.StorageKeys.useCelsius) private var useCelsius: Bool = true
    // Notifications
    @AppStorage(AppConstants.StorageKeys.notificationsSevereAlerts) private var severeAlerts: Bool = true
    @AppStorage(AppConstants.StorageKeys.notificationsDailySummary) private var dailySummary: Bool = false
    
    // Background theme
    private let theme: WeatherTheme = .sunny
    
    // Adaptive foreground color helper
    private func adaptiveForeground(opacity: Double = 1.0) -> Color {
        ColorSchemeManager.shared.adaptiveForegroundColor(opacity: opacity)
    }
    
    init(model: HomeViewModel) {
        _model = StateObject(wrappedValue: model)
    }
    
    var body: some View {
        ZStack {
            WeatherBackground(theme: theme)
                .ignoresSafeArea()
            
            GeometryReader { proxy in
                let safeTop = proxy.safeAreaInsets.top
                let safeBottom = proxy.safeAreaInsets.bottom
                let contentTopPadding = max(24, safeTop + 8)
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 18) {
                        header
                        notificationsBanner
                        currentCard
                        forecastStrip
                        sunriseSunsetCard
                        todayHighlightsGrid
                        airQualityCardIfAvailable
                        precipitationCard
                        
                        if case let .failed(message) = model.loadingState {
                            Text(message)
                                .font(.footnote)
                                .foregroundColor(.red.opacity(0.9))
                                .padding(.top, 8)
                        }
                        
                        Spacer(minLength: 16)
                    }
                    .padding(.top, contentTopPadding)
                    .padding(.bottom, max(24, safeBottom + 8))
                    .frame(maxWidth: 700)
                }
                .refreshable {
                    HapticFeedback.medium()
                    await model.refresh()
                }
            }
            
            if case .loading = model.loadingState {
                ProgressView()
                    .tint(.cyan)
                    .scaleEffect(1.2)
            }
        }
        .task {
            await model.load()
        }
        .onAppear {
            locator.requestWhenInUse()
        }
        .task(id: locator.coordinate?.latitude) {
            guard let coord = locator.coordinate else { return }
            await updateCityFromCoordinate(coord)
        }
        // Observe selection coming from Search tab
        .onChange(of: selectedCity.city) { _, newValue in
            guard let city = newValue, !city.isEmpty else { return }
            Task {
                // Cancel any in-flight refresh, set new city, and refresh immediately.
                model.cancelRefresh()
                let old = model.city
                await MainActor.run { model.city = city }
                if old.caseInsensitiveCompare(city) != .orderedSame {
                    await model.refresh()
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    private func updateCityFromCoordinate(_ coord: CLLocationCoordinate2D) async {
        // If a city has been explicitly selected from Search, prefer that and skip location override
        if let explicit = selectedCity.city, !explicit.isEmpty {
            return
        }
        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(
                CLLocation(latitude: coord.latitude, longitude: coord.longitude)
            )
            let city = placemarks.first?.locality ?? placemarks.first?.name ?? AppConstants.UI.currentLocation
            let old = model.city
            await MainActor.run { model.city = city }
            if old.caseInsensitiveCompare(city) != .orderedSame {
                await model.refresh()
            }
        } catch {
#if DEBUG
            print("[HomeView] reverseGeocode failed: \(error.localizedDescription)")
#endif
        }
    }
    
    private var header: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(.ultraThinMaterial)
                .frame(width: 44, height: 44)
                .overlay {
                    Image(systemName: AppConstants.Symbols.cloudSunFill)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(LinearGradient(
                            colors: [.cyan, .blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                }
                .shadow(color: .black.opacity(0.35), radius: 14, y: 6)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(AppConstants.UI.homeTitle)
                    .font(.system(.title3, design: .rounded).weight(.bold))
                    .foregroundColor(adaptiveForeground())
                Text(AppConstants.UI.homeSubtitle)
                    .font(.caption)
                    .foregroundColor(adaptiveForeground(opacity: 0.65))
            }
            
        }
    }
    
    private var notificationsBanner: some View {
        Group {
            if severeAlerts || dailySummary {
                HStack(spacing: 12) {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 36, height: 36)
                        .overlay {
                            Image(systemName: severeAlerts ? AppConstants.Symbols.exclamationTriangleFill : "bell.fill")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(severeAlerts ? .red.opacity(0.95) : adaptiveForeground(opacity: 0.95))
                        }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        if severeAlerts && dailySummary {
                            Text("Severe Alerts + Daily Summary")
                                .font(.subheadline.bold())
                                .foregroundColor(adaptiveForeground())
                            
                            Text("You’ll receive severe weather alerts and a daily digest.")
                                .font(.caption)
                                .foregroundColor(adaptiveForeground())
                            
                        } else if severeAlerts {
                            Text("Severe Weather Alerts")
                                .font(.subheadline.bold())
                                .foregroundColor(adaptiveForeground())
                            
                            Text("Enabled in Settings")
                                .font(.caption)
                                .foregroundColor(adaptiveForeground())
                            
                        } else {
                            Text("Daily Summary")
                                .font(.subheadline.bold())
                                .foregroundColor(adaptiveForeground())
                            
                            Text("Enabled in Settings")
                                .font(.caption)
                                .foregroundColor(adaptiveForeground())
                            
                        }
                    }
                    
                    Spacer()
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 14)
                //                .liquidGlass(cornerRadius: 16, intensity: 0.30)
                .glassEffect()
                .padding(.horizontal, 16)
            }
        }
    }
    
    private var currentCard: some View {
        VStack(spacing: 16) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(model.current?.city ?? AppConstants.UI.loadingEllipsis)
                        .font(.headline.bold())
                        .foregroundColor(adaptiveForeground())
                    
                    HStack(spacing: 8) {
                        if let condition = model.current?.condition {
                            Text(condition)
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(adaptiveForeground(opacity: 0.85))
                        }
                        if let high = model.current?.high, let low = model.current?.low {
                            let (h, l) = TemperatureUnit.convert(high: high, low: low)
                            Text("\(AppConstants.UI.highAbbrev) \(h)°  \(AppConstants.UI.lowAbbrev) \(l)°")
                                .font(.caption.weight(.semibold))
                                .foregroundColor(adaptiveForeground(opacity: 0.7))
                        }
                    }
                }
                
                Spacer()
                
                if let symbol = model.current?.symbolName {
                    Image(systemName: symbol)
                        .font(.system(size: 36, weight: .semibold))
                        .foregroundStyle(
                            (effectiveScheme == .light && symbol == AppConstants.Symbols.sunMaxFill)
                            ? AnyShapeStyle(LinearGradient(colors: [.yellow, .orange], startPoint: .topLeading, endPoint: .bottomTrailing))
                            : AnyShapeStyle(adaptiveForeground())
                        )
                        .shadow(color: .black.opacity(0.35), radius: 10, y: 4)
                }
            }
            
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                let tempF = Double(model.current?.temperature ?? 0)
                let temp = useCelsius ? Int(round((tempF - 32) * 5 / 9)) : Int(round(tempF))
                Text("\(temp)")
                    .font(.system(size: 64, weight: .bold, design: .rounded))
                    .foregroundColor(adaptiveForeground())
                    .shadow(color: .black.opacity(0.35), radius: 12, y: 6)
                Text("°")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .offset(y: -6)
                    .foregroundColor(adaptiveForeground(opacity: 0.9))
                
                Text(TemperatureUnit.unitLabel)
                    .font(.caption.weight(.semibold))
                    .foregroundColor(adaptiveForeground(opacity: 0.85))
                    .padding(.leading, 2)
                
                Spacer()
                
                if case .loading = model.loadingState {
                    ProgressView()
                        .tint(.cyan)
                } else {
                    Button {
                        HapticFeedback.medium()
                        Task { await model.refresh() }
                    } label: {
                        Label(AppConstants.UI.refresh, systemImage: AppConstants.Symbols.arrowClockwiseCircleFill)
                            .font(.subheadline.bold())
                            .foregroundColor(adaptiveForeground())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(20)
        .liquidGlass(cornerRadius: 28, intensity: 0.45)
        .padding(.horizontal, 16)
    }
    
    private var forecastStrip: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(AppConstants.UI.fiveDayForecast)
                .font(.headline.bold())
                .foregroundColor(adaptiveForeground())
                .padding(.horizontal, 16)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(model.forecast) { day in
                        VStack(spacing: 10) {
                            Text(day.weekday.uppercased())
                                .font(.caption.weight(.semibold))
                                .foregroundColor(adaptiveForeground(opacity: 0.8))
                            
                            Image(systemName: day.symbolName)
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundStyle(
                                    (effectiveScheme == .light && day.symbolName == AppConstants.Symbols.sunMaxFill)
                                    ? AnyShapeStyle(LinearGradient(colors: [.yellow, .orange], startPoint: .topLeading, endPoint: .bottomTrailing))
                                    : AnyShapeStyle(adaptiveForeground())
                                )
                            
                            HStack(spacing: 6) {
                                let (h, l) = TemperatureUnit.convert(high: day.high, low: day.low)
                                Text("\(h)°")
                                    .font(.subheadline.bold())
                                    .foregroundColor(adaptiveForeground())
                                Text("\(l)°")
                                    .font(.footnote)
                                    .foregroundColor(adaptiveForeground(opacity: 0.7))
                            }
                        }
                        .padding(.vertical, 16)
                        .padding(.horizontal, 14)
                        .frame(width: 120)
                        .liquidGlass(cornerRadius: 20, intensity: 0.35)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 4)
            }
        }
    }
    
    private var sunriseSunsetCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label(AppConstants.UI.sunriseSunset, systemImage: AppConstants.Symbols.sunriseFill)
                    .font(.subheadline.bold())
                    .foregroundColor(adaptiveForeground())
                Spacer()
            }
            
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Image(systemName: AppConstants.Symbols.sunriseFill).foregroundColor(.yellow)
                        Text(model.current?.sunrise ?? AppConstants.UI.placeholderTime)
                            .foregroundColor(adaptiveForeground())
                            .font(.headline.bold())
                    }
                    HStack(spacing: 8) {
                        Image(systemName: AppConstants.Symbols.sunsetFill).foregroundColor(.orange)
                        Text(model.current?.sunset ?? AppConstants.UI.placeholderTime)
                            .foregroundColor(adaptiveForeground())
                            .font(.headline.bold())
                    }
                }
                
                Spacer()
                
                SunriseArc(progress: 0.55)
                    .frame(width: 96, height: 56)
            }
        }
        .padding(16)
        .liquidGlass(cornerRadius: 22, intensity: 0.35)
        .padding(.horizontal, 16)
    }
    
    private var todayHighlightsGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(AppConstants.UI.todaysHighlights)
                .font(.headline.bold())
                .foregroundColor(adaptiveForeground())
                .padding(.horizontal, 16)
            
            let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]
            
            LazyVGrid(columns: columns, spacing: 12) {
                if let feels = model.current?.feelsLikeF {
                    let feelsDisplay = TemperatureUnit.convert(Int(round(feels)))
                    highlightTile(icon: AppConstants.Symbols.thermometerSunFill,
                                  title: AppConstants.UI.feelsLike,
                                  value: "\(feelsDisplay)°\(TemperatureUnit.unitLabel)")
                }
                if let wind = model.current?.windKph {
                    highlightTile(icon: AppConstants.Symbols.wind,
                                  title: AppConstants.UI.wind,
                                  value: formattedWind(wind))
                }
                if let hum = model.current?.humidity {
                    highlightTile(icon: AppConstants.Symbols.humidityFill,
                                  title: AppConstants.UI.humidity,
                                  value: "\(hum)%")
                }
                if let p = model.current?.pressureMb {
                    highlightTile(icon: AppConstants.Symbols.gauge,
                                  title: AppConstants.UI.pressure,
                                  value: formattedPressure(p))
                }
                if let vis = model.current?.visibilityKm {
                    highlightTile(icon: AppConstants.Symbols.eyeFill,
                                  title: AppConstants.UI.visibility,
                                  value: formattedVisibility(vis))
                }
                if let uv = model.current?.uvIndex {
                    highlightTile(icon: AppConstants.Symbols.sunMaxTriangleExclamation,
                                  title: AppConstants.UI.uvIndex,
                                  value: "\(Int(round(uv)))")
                }
                if let gust = model.current?.gustKph {
                    highlightTile(icon: AppConstants.Symbols.tornado,
                                  title: AppConstants.UI.windGust,
                                  value: formattedWind(gust))
                }
                if let dir = model.current?.windDirection, let deg = model.current?.windDegrees {
                    highlightTile(icon: AppConstants.Symbols.locationNorthLine,
                                  title: AppConstants.UI.windDir,
                                  value: "\(dir) (\(deg)°)")
                }
                if let dp = model.current?.dewpointF {
                    let dpDisplay = TemperatureUnit.convert(Int(round(dp)))
                    highlightTile(icon: AppConstants.Symbols.dropFill,
                                  title: AppConstants.UI.dewPoint,
                                  value: "\(dpDisplay)°\(TemperatureUnit.unitLabel)")
                }
                if let hi = model.current?.heatIndexF {
                    let hiDisplay = TemperatureUnit.convert(Int(round(hi)))
                    highlightTile(icon: AppConstants.Symbols.thermometerHigh,
                                  title: AppConstants.UI.heatIndex,
                                  value: "\(hiDisplay)°\(TemperatureUnit.unitLabel)")
                }
            }
            .padding(.horizontal, 16)
        }
    }
    
    private var airQualityCardIfAvailable: some View {
        Group {
            if let epa = model.current?.aqiEPA, let defra = model.current?.aqiDEFRA {
                HStack(spacing: 14) {
                    Image(systemName: AppConstants.Symbols.aqiMedium)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(adaptiveForeground())
                    VStack(alignment: .leading, spacing: 2) {
                        Text(AppConstants.UI.airQuality)
                            .font(.subheadline.bold())
                            .foregroundColor(adaptiveForeground())
                        Text("\(AppConstants.UI.airQualityEPADEFRA) \(epa)\(AppConstants.UI.airQualitySEP)\(defra)")
                            .font(.caption)
                            .foregroundColor(adaptiveForeground(opacity: 0.7))
                    }
                    Spacer()
                }
                .padding(.vertical, 14)
                .padding(.horizontal, 16)
                //                .liquidGlass(cornerRadius: 18, intensity: 0.30)
                .glassEffect()
                .padding(.horizontal, 16)
            }
        }
    }
    
    private var precipitationCard: some View {
        HStack(spacing: 14) {
            Image(systemName: AppConstants.Symbols.cloudRainFill)
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(adaptiveForeground())
            VStack(alignment: .leading, spacing: 2) {
                Text(AppConstants.UI.precipitation)
                    .font(.subheadline.bold())
                    .foregroundColor(adaptiveForeground())
                Text(AppConstants.UI.chanceToday)
                    .font(.caption)
                    .foregroundColor(adaptiveForeground(opacity: 0.7))
            }
            Spacer()
            Text("\(model.current?.precipChance ?? 0)%")
                .font(.headline.bold())
                .foregroundColor(adaptiveForeground())
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
        //        .liquidGlass(cornerRadius: 18, intensity: 0.30)
        .glassEffect()
        .padding(.horizontal, 16)
    }
    
    // MARK: - Helpers
    
    private func highlightTile(icon: String, title: String, value: String) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(.ultraThinMaterial)
                .frame(width: 38, height: 38)
                .overlay {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(adaptiveForeground(opacity: 0.95))
                }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .foregroundColor(adaptiveForeground(opacity: 0.8))
                    .font(.caption)
                Text(value)
                    .foregroundColor(adaptiveForeground())
                    .font(.subheadline.bold())
            }
            Spacer()
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
        //        .liquidGlass(cornerRadius: 16, intensity: 0.30)
        .glassEffect()
    }
    
    private func formattedWind(_ speedKph: Double) -> String {
        if windUnitIsKmh {
            return String(format: "%.0f \(AppConstants.UI.kmh)", speedKph)
        } else {
            let mph = speedKph * 0.621371
            return String(format: "%.0f \(AppConstants.UI.mph)", mph)
        }
    }
    
    private func formattedPressure(_ hPa: Double) -> String {
        if pressureUnitIsHpa {
            return String(format: "%.0f \(AppConstants.UI.hPa)", hPa)
        } else {
            let inHg = hPa / 33.8639
            return String(format: "%.2f \(AppConstants.UI.inHg)", inHg)
        }
    }
    
    private func formattedVisibility(_ km: Double) -> String {
        if windUnitIsKmh {
            return String(format: "%.1f km", km)
        } else {
            let miles = km * 0.621371
            return String(format: "%.1f mi", miles)
        }
    }
}

// MARK: - Sunrise Arc view (compact)
private struct SunriseArc: View {
    var progress: Double // 0...1
    
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let radius = min(w, h) * 0.9
            
            ZStack {
                Arc(startAngle: .degrees(180), endAngle: .degrees(0))
                    .stroke(.white.opacity(0.25), style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .frame(width: radius, height: radius/1.6)
                
                Arc(startAngle: .degrees(180), endAngle: .degrees(180 + 180 * progress))
                    .stroke(LinearGradient(colors: [.yellow, .orange], startPoint: .leading, endPoint: .trailing),
                            style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .frame(width: radius, height: radius/1.6)
                
                let angle = Angle.degrees(180 + 180 * progress)
                let r = radius/2.0
                let cx = w/2
                let cy = h/2 + radius/4.0
                let sunX = cx + CGFloat(cos(angle.radians)) * r
                let sunY = cy + CGFloat(sin(angle.radians)) * r
                Circle()
                    .fill(LinearGradient(colors: [.yellow, .orange], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 12, height: 12)
                    .shadow(color: .yellow.opacity(0.6), radius: 6)
                    .position(x: sunX, y: sunY)
            }
        }
    }
}

private struct Arc: Shape {
    var startAngle: Angle
    var endAngle: Angle
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let center = CGPoint(x: rect.midX, y: rect.maxY)
        let radius = min(rect.width, rect.height)
        p.addArc(center: center, radius: radius/2,
                 startAngle: startAngle,
                 endAngle: endAngle,
                 clockwise: false)
        return p
    }
}

#Preview {
    HomeView(model: HomeViewModel(service: MockWeatherService()))
}

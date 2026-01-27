//
//  RadarView.swift
//  Glasscast-A Minimal Weather App
//
//  Created by Sam's Mac on 22/01/26.
//

import Foundation
import MapKit
import CoreLocation
import SwiftUI

struct RadarView: View {
    // Default region centered on Cupertino; adjust as desired
    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: AppConstants.MapDefaults.defaultLatitude, longitude: AppConstants.MapDefaults.defaultLongitude),
            span: MKCoordinateSpan(latitudeDelta: AppConstants.MapDefaults.defaultSpanLat, longitudeDelta: AppConstants.MapDefaults.defaultSpanLon)
        )
    )
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.colorScheme) private var systemColorScheme
    @ObservedObject private var colorSchemeManager = ColorSchemeManager.shared
    
    private let theme: WeatherTheme = .sunny
    
    // Adaptive foreground color helper
    private func adaptiveForeground(opacity: Double = 1.0) -> Color {
        ColorSchemeManager.shared.adaptiveForegroundColor(opacity: opacity)
    }
    private let cardCornerRadius: CGFloat = 20
    private let innerInset: CGFloat = 5
    
    // Reusable location provider
    @StateObject private var locator = LocationProvider()
    
    // Favorites: use the shared store from the environment (same instance as SearchCityView)
    @EnvironmentObject private var favoritesStore: FavoritesStore
    @Environment(\.container) private var container
    @State private var favoriteCoords: [String: CLLocationCoordinate2D] = [:] // city -> coord
    @State private var favoriteGeocodingInFlight: Set<String> = []
    
    // User coordinate and popup
    @State private var userCoordinate: CLLocationCoordinate2D?
    @State private var showUserPopup: Bool = false
    
    // Weather for current location
    @State private var currentCity: String?
    @State private var currentWeather: CurrentWeather?
    @State private var isLoadingWeather: Bool = false
    @State private var weatherError: String?
    
    // Popup state for favorite markers
    @State private var selectedFavoriteCity: String?
    @State private var selectedFavoriteWeather: CurrentWeather?
    @State private var isLoadingFavoriteWeather: Bool = false
    @State private var favoriteWeatherError: String?
    
    // Service to fetch weather (resolved from the DI container)
    private var weatherService: WeatherService { container.weatherService }
    private let geocoder = CLGeocoder()
    
    var body: some View {
        ZStack {
            WeatherBackground(theme: theme).ignoresSafeArea()
            
            VStack(spacing: 16) {
                header
                
                ZStack {
                    RadarMapView(
                        position: $position,
                        userCoordinate: $userCoordinate,
                        showUserPopup: $showUserPopup,
                        currentCity: $currentCity,
                        currentWeather: $currentWeather,
                        isLoadingWeather: $isLoadingWeather,
                        weatherError: $weatherError,
                        selectedFavoriteCity: $selectedFavoriteCity,
                        selectedFavoriteWeather: $selectedFavoriteWeather,
                        isLoadingFavoriteWeather: $isLoadingFavoriteWeather,
                        favoriteWeatherError: $favoriteWeatherError,
                        favoriteCoords: $favoriteCoords
                    )
                    .environmentObject(favoritesStore)
                    .environment(\.container, container)
                    .accessibilityIdentifier("radar.map")
                    .task(id: locator.coordinate?.latitude) {
                        if let coord = locator.coordinate {
                            userCoordinate = coord
                            withAnimation(.easeInOut(duration: 0.4)) {
                                position = .region(
                                    MKCoordinateRegion(
                                        center: coord,
                                        span: MKCoordinateSpan(latitudeDelta: AppConstants.MapDefaults.focusSpanLat, longitudeDelta: AppConstants.MapDefaults.focusSpanLon)
                                    )
                                )
                            }
                        }
                    }
                    .task {
                        if favoritesStore.favorites.isEmpty {
                            await favoritesStore.load()
                        }
                        await resolveFavoriteCoordinates()
                    }
                    .onChange(of: favoritesStore.favorites) { _ in
                        Task { await resolveFavoriteCoordinates() }
                    }
                    
                    // Floating current-location glass button
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Button {
                                HapticFeedback.medium()
                                Task {
                                    locator.requestWhenInUse()
                                    if let coord = userCoordinate {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                                            position = .region(
                                                MKCoordinateRegion(
                                                    center: coord,
                                                    span: MKCoordinateSpan(latitudeDelta: AppConstants.MapDefaults.focusSpanLat, longitudeDelta: AppConstants.MapDefaults.focusSpanLon)
                                                )
                                            )
                                            showUserPopup = true
                                        }
                                        await fetchWeatherForCurrentLocation(coord)
                                    }
                                }
                            } label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                                        .fill(.ultraThinMaterial)
                                        .frame(width: 48, height: 48)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                                .stroke(
                                                    LinearGradient(
                                                        colors: [.white.opacity(0.30), .white.opacity(0.12)],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    ),
                                                    lineWidth: 1
                                                )
                                        )
                                        .shadow(color: .black.opacity(0.30), radius: 12, y: 6)
                                    
                                    Image(systemName: AppConstants.Symbols.locationCircleFill)
                                        .font(.system(size: 22, weight: .semibold))
                                        .foregroundStyle(LinearGradient(
                                            colors: [.cyan, .blue],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ))
                                }
                            }
                            .buttonStyle(.plain)
                            .padding(.trailing, 16)
                            .padding(.bottom, 16)
                        }
                    }
                    .allowsHitTesting(true)
                }
                .background {
                    RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .overlay {
                            RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous)
                                .stroke(
                                    LinearGradient(
                                        colors: colorScheme == .dark ? [
                                            .white.opacity(0.45),
                                            .white.opacity(0.20),
                                            .white.opacity(0.25)
                                        ] : [
                                            .white.opacity(0.25),
                                            .clear,
                                            .white.opacity(0.10)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: colorScheme == .dark ? 1.2 : 1.0
                                )
                        }
                }
                .clipShape(RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous))
                .shadow(
                    color: colorScheme == .dark ? .black.opacity(0.5) : .black.opacity(0.2),
                    radius: colorScheme == .dark ? 35 : 25,
                    y: colorScheme == .dark ? 25 : 15
                )
                .frame(maxWidth: 800)
                .frame(minHeight: 220)
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
            .padding(.top, 16)
        }
        .onAppear {
            locator.requestWhenInUse()
        }
        .navigationBarBackButtonHidden(true)
    }
    
    // Resolve a coordinate for a given favorite city.
    // Prefers cached geocoded coords, falls back to the favorite’s stored lat/lon.
    private func coordinateForFavorite(_ fav: FavoriteCity) -> CLLocationCoordinate2D? {
        if let cached = favoriteCoords[fav.city] {
            return cached
        }
        if let lat = fav.lat, let lon = fav.lon {
            return CLLocationCoordinate2D(latitude: lat, longitude: lon)
        }
        return nil
    }
    
    // Custom glass marker styled for this app
    struct GlassMarker: View {
        var icon: String
        
        var body: some View {
            VStack(spacing: 2) {
                ZStack {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 30, height: 30)
                        .overlay(
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [.white.opacity(0.35), .white.opacity(0.12)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                        .shadow(color: .black.opacity(0.25), radius: 8, y: 4)
                        .overlay(
                            Image(systemName: icon)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(LinearGradient(
                                    colors: [.cyan, .blue],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                        )
                }
                RoundedRectangle(cornerRadius: 1)
                    .fill(LinearGradient(colors: [.cyan.opacity(0.9), .blue.opacity(0.9)],
                                         startPoint: .top, endPoint: .bottom))
                    .frame(width: 2, height: 10)
                    .shadow(color: .black.opacity(0.25), radius: 4, y: 2)
            }
        }
    }
    
    // Anchored popup content directly above marker (current location)
    private var markerPopup: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(currentCity ?? AppConstants.UI.currentLocation)
                    .font(.subheadline.bold())
                    .foregroundColor(adaptiveForeground())
                Spacer()
                Button {
                    HapticFeedback.light()
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
                        showUserPopup = false
                    }
                } label: {
                    Image(systemName: AppConstants.Symbols.closeCircleFill)
                        .foregroundColor(adaptiveForeground())
                        .font(.system(size: 16, weight: .semibold))
                }
                .buttonStyle(.plain)
            }
            
            if isLoadingWeather {
                HStack(spacing: 8) {
                    ProgressView().tint(.white)
                    Text(AppConstants.UI.loadingEllipsis)
                        .foregroundColor(adaptiveForeground())
                        .font(.footnote)
                }
            } else if let error = weatherError {
                Text(error)
                    .foregroundColor(adaptiveForeground())
                    .font(.footnote)
            } else if let cw = currentWeather {
                HStack(spacing: 10) {
                    Image(systemName: cw.symbolName)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(adaptiveForeground())
                    VStack(alignment: .leading, spacing: 2) {
                        Text(cw.condition)
                            .font(.footnote.weight(.semibold))
                            .foregroundColor(adaptiveForeground())
                        HStack(spacing: 8) {
                            let (t, h, l) = TemperatureUnit.convert(temp: cw.temperature, high: cw.high, low: cw.low)
                            Text("\(t)°")
                                .font(.subheadline.bold())
                                .foregroundColor(adaptiveForeground())
                            Text(TemperatureUnit.unitLabel)
                                .font(.caption2.weight(.semibold))
                                .foregroundColor(.white.opacity(0.85))
                            Text("\(AppConstants.UI.highAbbrev) \(h)°  \(AppConstants.UI.lowAbbrev) \(l)°")
                                .font(.caption)
                                .foregroundColor(adaptiveForeground())
                            
                        }
                    }
                }
            } else {
                Text(AppConstants.UI.tapMarkerToLoad)
                    .foregroundColor(adaptiveForeground())
                    .font(.footnote)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.black.opacity(0.35),
                            Color.orange.opacity(0.55)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .glassEffect()
        .shadow(color: .black.opacity(0.35), radius: 10, y: 6)
        .frame(maxWidth: 260)
    }
    
    // Favorite popup
    private func favoritePopup(for city: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(city)
                    .font(.subheadline.bold())
                    .foregroundColor(adaptiveForeground())
                Spacer()
                Button {
                    HapticFeedback.light()
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
                        selectedFavoriteCity = nil
                        favoriteWeatherError = nil
                    }
                } label: {
                    Image(systemName: AppConstants.Symbols.closeCircleFill)
                        .foregroundColor(adaptiveForeground())
                        .font(.system(size: 16, weight: .semibold))
                }
                .buttonStyle(.plain)
            }
            
            if isLoadingFavoriteWeather {
                HStack(spacing: 8) {
                    ProgressView().tint(.white)
                    Text(AppConstants.UI.loadingEllipsis)
                        .foregroundColor(adaptiveForeground())
                        .font(.footnote)
                }
            } else if let error = favoriteWeatherError {
                Text(error)
                    .foregroundColor(adaptiveForeground())
                    .font(.footnote)
            } else if let cw = selectedFavoriteWeather, cw.city.caseInsensitiveCompare(city) == .orderedSame {
                HStack(spacing: 10) {
                    Image(systemName: cw.symbolName)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(adaptiveForeground())
                    VStack(alignment: .leading, spacing: 2) {
                        Text(cw.condition)
                            .font(.footnote.weight(.semibold))
                            .foregroundColor(adaptiveForeground())
                        HStack(spacing: 8) {
                            let (t, h, l) = TemperatureUnit.convert(temp: cw.temperature, high: cw.high, low: cw.low)
                            Text("\(t)°")
                                .font(.subheadline.bold())
                                .foregroundColor(adaptiveForeground())
                            Text(TemperatureUnit.unitLabel)
                                .font(.caption2.weight(.semibold))
                                .foregroundColor(.white.opacity(0.85))
                            Text("\(AppConstants.UI.highAbbrev) \(h)°  \(AppConstants.UI.lowAbbrev) \(l)°")
                                .font(.caption)
                                .foregroundColor(adaptiveForeground())
                        }
                    }
                }
            } else {
                Text(AppConstants.UI.tapMarkerToLoad)
                    .foregroundColor(adaptiveForeground())
                    .font(.footnote)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.black.opacity(0.35),
                            Color.blue.opacity(0.55)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .glassEffect()
        .shadow(color: .black.opacity(0.35), radius: 10, y: 6)
        .frame(maxWidth: 260)
    }
    
    private func fetchWeatherForCurrentLocation(_ coord: CLLocationCoordinate2D) async {
        if isLoadingWeather { return }
        isLoadingWeather = true
        weatherError = nil
        defer { isLoadingWeather = false }
        
        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(
                CLLocation(latitude: coord.latitude, longitude: coord.longitude)
            )
            let city = placemarks.first?.locality ?? AppConstants.UI.currentLocation
            await MainActor.run { self.currentCity = city }
            
            let weather = try await weatherService.fetchCurrentWeather(for: city)
            await MainActor.run {
                self.currentWeather = weather
            }
        } catch is CancellationError {
            // ignore
        } catch {
            await MainActor.run {
                self.weatherError = (error as NSError).localizedDescription
            }
        }
    }
    
    private func fetchWeatherForFavorite(city: String) async {
        if isLoadingFavoriteWeather { return }
        isLoadingFavoriteWeather = true
        favoriteWeatherError = nil
        defer { isLoadingFavoriteWeather = false }
        
        do {
            let weather = try await weatherService.fetchCurrentWeather(for: city)
            await MainActor.run {
                self.selectedFavoriteWeather = weather
            }
        } catch is CancellationError {
            // ignore
        } catch {
            await MainActor.run {
                self.favoriteWeatherError = (error as NSError).localizedDescription
            }
        }
    }
    
    private func resolveFavoriteCoordinates() async {
        for fav in favoritesStore.favorites {
            if let lat = fav.lat, let lon = fav.lon {
                favoriteCoords[fav.city] = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            }
        }
        await geocodeFavoritesIfNeeded()
        await centerIfNeeded()
    }
    
    private func geocodeFavoritesIfNeeded() async {
        let cities = favoritesStore.favorites.map { $0.city }
        for city in cities {
            guard favoriteCoords[city] == nil, !favoriteGeocodingInFlight.contains(city) else { continue }
            favoriteGeocodingInFlight.insert(city)
            do {
                let placemarks = try await geocoder.geocodeAddressString(city)
                if let loc = placemarks.first?.location?.coordinate {
                    await MainActor.run {
                        favoriteCoords[city] = loc
                    }
                }
            } catch {
                // optional: log error
            }
            favoriteGeocodingInFlight.remove(city)
        }
    }
    
    private func centerIfNeeded() async {
        guard userCoordinate == nil else { return }
        let coords = Array(favoriteCoords.values)
        guard !coords.isEmpty else { return }
        let region = regionToFit(coordinates: coords)
        await MainActor.run {
            withAnimation(.easeInOut) {
                position = .region(region)
            }
        }
    }
    
    private func regionToFit(coordinates: [CLLocationCoordinate2D]) -> MKCoordinateRegion {
        var minLat = 90.0, maxLat = -90.0, minLon = 180.0, maxLon = -180.0
        for c in coordinates {
            minLat = min(minLat, c.latitude)
            maxLat = max(maxLat, c.latitude)
            minLon = min(minLon, c.longitude)
            maxLon = max(maxLon, c.longitude)
        }
        let span = MKCoordinateSpan(
            latitudeDelta: max(AppConstants.MapDefaults.defaultSpanLat, (maxLat - minLat) * 1.6),
            longitudeDelta: max(AppConstants.MapDefaults.defaultSpanLon, (maxLon - minLon) * 1.6)
        )
        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2.0,
            longitude: (minLon + maxLon) / 2.0
        )
        return MKCoordinateRegion(center: center, span: span)
    }
    
    private var header: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(.ultraThinMaterial)
                .frame(width: 44, height: 44)
                .overlay {
                    Image(systemName: AppConstants.Symbols.map)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(LinearGradient(
                            colors: [.cyan, .blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                }
                .shadow(color: .black.opacity(0.35), radius: 14, y: 6)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(AppConstants.UI.radarTitle)
                    .font(.system(.title3, design: .rounded).weight(.bold))
                    .foregroundColor(adaptiveForeground())
                Text(AppConstants.UI.radarSubtitle)
                    .font(.caption)
                    .foregroundColor(adaptiveForeground())
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
    }
}

// MARK: - Extracted Map View

private struct RadarMapView: View {
    @Environment(\.container) private var container
    @EnvironmentObject private var favoritesStore: FavoritesStore
    
    @Binding var position: MapCameraPosition
    @Binding var userCoordinate: CLLocationCoordinate2D?
    @Binding var showUserPopup: Bool
    
    @Binding var currentCity: String?
    @Binding var currentWeather: CurrentWeather?
    @Binding var isLoadingWeather: Bool
    @Binding var weatherError: String?
    
    @Binding var selectedFavoriteCity: String?
    @Binding var selectedFavoriteWeather: CurrentWeather?
    @Binding var isLoadingFavoriteWeather: Bool
    @Binding var favoriteWeatherError: String?
    
    @Binding var favoriteCoords: [String: CLLocationCoordinate2D]
    
    private var weatherService: WeatherService { container.weatherService }
    private let geocoder = CLGeocoder()
    
    var body: some View {
        Map(position: $position) {
            if let coord = userCoordinate {
                Annotation(AppConstants.UI.annotationMe, coordinate: coord) {
                    VStack(spacing: 8) {
                        if showUserPopup {
                            markerPopup
                                .transition(.scale.combined(with: .opacity))
                                .zIndex(1)
                        }
                        
                        RadarView.GlassMarker(icon: AppConstants.Symbols.locationFill)
                            .onTapGesture {
                                HapticFeedback.light()
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.9)) {
                                    showUserPopup.toggle()
                                }
                                Task {
                                    if let coord = userCoordinate {
                                        await fetchWeatherForCurrentLocation(coord)
                                    }
                                }
                            }
                    }
                    .padding(.bottom, showUserPopup ? 10 : 0)
                    .accessibilityLabel(AppConstants.Accessibility.currentLocation)
                }
            }
            
            ForEach(favoritesStore.favorites, id: \.id) { fav in
                let coord = coordinateForFavorite(fav)
                if let coord {
                    Annotation(fav.city, coordinate: coord) {
                        VStack(spacing: 8) {
                            if selectedFavoriteCity == fav.city {
                                favoritePopup(for: fav.city)
                                    .transition(.scale.combined(with: .opacity))
                                    .zIndex(1)
                            }
                            RadarView.GlassMarker(icon: AppConstants.Symbols.starFill)
                                .onTapGesture {
                                    HapticFeedback.light()
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.9)) {
                                        if selectedFavoriteCity == fav.city {
                                            selectedFavoriteCity = nil
                                        } else {
                                            selectedFavoriteCity = fav.city
                                        }
                                    }
                                    Task {
                                        await fetchWeatherForFavorite(city: fav.city)
                                    }
                                }
                        }
                        .padding(.bottom, selectedFavoriteCity == fav.city ? 10 : 0)
                        .accessibilityLabel("\(fav.city)")
                    }
                }
            }
        }
        .mapStyle(.standard(elevation: .flat))
        .mask(
            RoundedRectangle(cornerRadius: 15, style: .continuous)
        )
        .padding(5)
    }
    
    // Local helpers (duplicate minimal logic needed in this subview)
    private func coordinateForFavorite(_ fav: FavoriteCity) -> CLLocationCoordinate2D? {
        if let cached = favoriteCoords[fav.city] {
            return cached
        }
        if let lat = fav.lat, let lon = fav.lon {
            return CLLocationCoordinate2D(latitude: lat, longitude: lon)
        }
        return nil
    }
    
    private var markerPopup: some View {
        // Use the outer RadarView’s popup via a proxy so styling remains consistent
        RadarViewProxyMarkerPopup(
            currentCity: currentCity,
            currentWeather: currentWeather,
            isLoadingWeather: isLoadingWeather,
            weatherError: weatherError,
            close: {
                withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
                    showUserPopup = false
                }
            }
        )
    }
    
    private func favoritePopup(for city: String) -> some View {
        RadarViewProxyFavoritePopup(
            city: city,
            selectedFavoriteWeather: selectedFavoriteWeather,
            isLoadingFavoriteWeather: isLoadingFavoriteWeather,
            favoriteWeatherError: favoriteWeatherError,
            close: {
                withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
                    selectedFavoriteCity = nil
                    favoriteWeatherError = nil
                }
            }
        )
    }
    
    // Networking wrappers reusing container service
    private func fetchWeatherForCurrentLocation(_ coord: CLLocationCoordinate2D) async {
        if isLoadingWeather { return }
        isLoadingWeather = true
        weatherError = nil
        defer { isLoadingWeather = false }
        
        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(
                CLLocation(latitude: coord.latitude, longitude: coord.longitude)
            )
            let city = placemarks.first?.locality ?? AppConstants.UI.currentLocation
            await MainActor.run { self.currentCity = city }
            
            let weather = try await weatherService.fetchCurrentWeather(for: city)
            await MainActor.run {
                self.currentWeather = weather
            }
        } catch is CancellationError {
        } catch {
            await MainActor.run {
                self.weatherError = (error as NSError).localizedDescription
            }
        }
    }
    
    private func fetchWeatherForFavorite(city: String) async {
        if isLoadingFavoriteWeather { return }
        isLoadingFavoriteWeather = true
        favoriteWeatherError = nil
        defer { isLoadingFavoriteWeather = false }
        
        do {
            let weather = try await weatherService.fetchCurrentWeather(for: city)
            await MainActor.run {
                self.selectedFavoriteWeather = weather
            }
        } catch is CancellationError {
        } catch {
            await MainActor.run {
                self.favoriteWeatherError = (error as NSError).localizedDescription
            }
        }
    }
}

// MARK: - Lightweight proxy popups to keep Map subview simple

private struct RadarViewProxyMarkerPopup: View {
    var currentCity: String?
    var currentWeather: CurrentWeather?
    var isLoadingWeather: Bool
    var weatherError: String?
    var close: () -> Void
    
    private func adaptiveForeground(opacity: Double = 1.0) -> Color {
        ColorSchemeManager.shared.adaptiveForegroundColor(opacity: opacity)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(currentCity ?? AppConstants.UI.currentLocation)
                    .font(.subheadline.bold())
                    .foregroundColor(adaptiveForeground())
                Spacer()
                Button {
                    HapticFeedback.light()
                    close()
                } label: {
                    Image(systemName: AppConstants.Symbols.closeCircleFill)
                        .foregroundColor(adaptiveForeground())
                        .font(.system(size: 16, weight: .semibold))
                }
                .buttonStyle(.plain)
            }
            if isLoadingWeather {
                HStack(spacing: 8) {
                    ProgressView().tint(.white)
                    Text(AppConstants.UI.loadingEllipsis)
                        .foregroundColor(adaptiveForeground())
                        .font(.footnote)
                }
            } else if let error = weatherError {
                Text(error)
                    .foregroundColor(adaptiveForeground())
                    .font(.footnote)
            } else if let cw = currentWeather {
                HStack(spacing: 10) {
                    Image(systemName: cw.symbolName)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(adaptiveForeground())
                    VStack(alignment: .leading, spacing: 2) {
                        Text(cw.condition)
                            .font(.footnote.weight(.semibold))
                            .foregroundColor(adaptiveForeground())
                        HStack(spacing: 8) {
                            let (t, h, l) = TemperatureUnit.convert(temp: cw.temperature, high: cw.high, low: cw.low)
                            Text("\(t)°")
                                .font(.subheadline.bold())
                                .foregroundColor(adaptiveForeground())
                            Text(TemperatureUnit.unitLabel)
                                .font(.caption2.weight(.semibold))
                                .foregroundColor(.white.opacity(0.85))
                            Text("\(AppConstants.UI.highAbbrev) \(h)°  \(AppConstants.UI.lowAbbrev) \(l)°")
                                .font(.caption)
                                .foregroundColor(adaptiveForeground())
                        }
                    }
                }
            } else {
                Text(AppConstants.UI.tapMarkerToLoad)
                    .foregroundColor(adaptiveForeground())
                    .font(.footnote)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.black.opacity(0.35),
                            Color.orange.opacity(0.55)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .glassEffect()
        .shadow(color: .black.opacity(0.35), radius: 10, y: 6)
        .frame(maxWidth: 260)
    }
}

private struct RadarViewProxyFavoritePopup: View {
    var city: String
    var selectedFavoriteWeather: CurrentWeather?
    var isLoadingFavoriteWeather: Bool
    var favoriteWeatherError: String?
    var close: () -> Void
    
    private func adaptiveForeground(opacity: Double = 1.0) -> Color {
        ColorSchemeManager.shared.adaptiveForegroundColor(opacity: opacity)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(city)
                    .font(.subheadline.bold())
                    .foregroundColor(adaptiveForeground())
                Spacer()
                Button {
                    HapticFeedback.light()
                    close()
                } label: {
                    Image(systemName: AppConstants.Symbols.closeCircleFill)
                        .foregroundColor(adaptiveForeground())
                        .font(.system(size: 16, weight: .semibold))
                }
                .buttonStyle(.plain)
            }
            if isLoadingFavoriteWeather {
                HStack(spacing: 8) {
                    ProgressView().tint(.white)
                    Text(AppConstants.UI.loadingEllipsis)
                        .foregroundColor(adaptiveForeground())
                        .font(.footnote)
                }
            } else if let error = favoriteWeatherError {
                Text(error)
                    .foregroundColor(adaptiveForeground())
                    .font(.footnote)
            } else if let cw = selectedFavoriteWeather, cw.city.caseInsensitiveCompare(city) == .orderedSame {
                HStack(spacing: 10) {
                    Image(systemName: cw.symbolName)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(adaptiveForeground())
                    VStack(alignment: .leading, spacing: 2) {
                        Text(cw.condition)
                            .font(.footnote.weight(.semibold))
                            .foregroundColor(adaptiveForeground())
                        HStack(spacing: 8) {
                            let (t, h, l) = TemperatureUnit.convert(temp: cw.temperature, high: cw.high, low: cw.low)
                            Text("\(t)°")
                                .font(.subheadline.bold())
                                .foregroundColor(adaptiveForeground())
                            Text("\(AppConstants.UI.highAbbrev) \(h)°  \(AppConstants.UI.lowAbbrev) \(l)°")
                                .font(.caption)
                                .foregroundColor(adaptiveForeground())
                            Text(TemperatureUnit.unitLabel)
                                .font(.caption2.weight(.semibold))
                                .foregroundColor(.white.opacity(0.85))
                        }
                    }
                }
            } else {
                Text(AppConstants.UI.tapMarkerToLoad)
                    .foregroundColor(adaptiveForeground())
                    .font(.footnote)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.black.opacity(0.35),
                            Color.blue.opacity(0.55)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .glassEffect()
        .shadow(color: .black.opacity(0.35), radius: 10, y: 6)
        .frame(maxWidth: 260)
    }
}

#Preview {
    RadarView()
        .environmentObject(FavoritesStore())
}


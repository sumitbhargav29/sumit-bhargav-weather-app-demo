//
//  RadarViewModel.swift
//  Glasscast-A Minimal Weather App
//
//  Created by Refactor.
//

import Foundation
import SwiftUI
import MapKit
import CoreLocation
import Combine

@MainActor
final class RadarViewModel: ObservableObject {
    // Map and user state
    @Published var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 37.3349, longitude: -122.0090),
            span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
        )
    )
    @Published var userCoordinate: CLLocationCoordinate2D?
    @Published var showUserPopup: Bool = false

    // Current location weather
    @Published var currentCity: String?
    @Published var currentWeather: CurrentWeather?
    @Published var isLoadingWeather: Bool = false
    @Published var weatherError: String?

    // Favorite selection popup/weather
    @Published var selectedFavoriteCity: String?
    @Published var selectedFavoriteWeather: CurrentWeather?
    @Published var isLoadingFavoriteWeather: Bool = false
    @Published var favoriteWeatherError: String?

    // Favorites coordinates cache
    @Published var favoriteCoords: [String: CLLocationCoordinate2D] = [:]
    private var favoriteGeocodingInFlight: Set<String> = []

    // Dependencies
    private let weatherService: WeatherService
    private let favoritesStore: FavoritesStore
    private let geocoder = CLGeocoder()

    init(weatherService: WeatherService, favoritesStore: FavoritesStore) {
        self.weatherService = weatherService
        self.favoritesStore = favoritesStore
    }

    // MARK: - Coordination

    func resolveFavoriteCoordinates() async {
        // Seed from stored lat/lon
        for fav in favoritesStore.favorites {
            if let lat = fav.lat, let lon = fav.lon {
                favoriteCoords[fav.city] = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            }
        }
        await geocodeFavoritesIfNeeded()
        await centerIfNeeded()
    }

    func geocodeFavoritesIfNeeded() async {
        let cities = favoritesStore.favorites.map { $0.city }
        for city in cities {
            guard favoriteCoords[city] == nil, !favoriteGeocodingInFlight.contains(city) else { continue }
            favoriteGeocodingInFlight.insert(city)
            do {
                let placemarks = try await geocoder.geocodeAddressString(city)
                if let loc = placemarks.first?.location?.coordinate {
                    favoriteCoords[city] = loc
                }
            } catch {
                // optional: log error
            }
            favoriteGeocodingInFlight.remove(city)
        }
    }

    func centerIfNeeded() async {
        guard userCoordinate == nil else { return }
        let coords = Array(favoriteCoords.values)
        guard !coords.isEmpty else { return }
        let region = regionToFit(coordinates: coords)
        withAnimation(.easeInOut) {
            position = .region(region)
        }
    }

    func regionToFit(coordinates: [CLLocationCoordinate2D]) -> MKCoordinateRegion {
        var minLat = 90.0, maxLat = -90.0, minLon = 180.0, maxLon = -180.0
        for c in coordinates {
            minLat = min(minLat, c.latitude)
            maxLat = max(maxLat, c.latitude)
            minLon = min(minLon, c.longitude)
            maxLon = max(maxLon, c.longitude)
        }
        let span = MKCoordinateSpan(
            latitudeDelta: max(0.2, (maxLat - minLat) * 1.6),
            longitudeDelta: max(0.2, (maxLon - minLon) * 1.6)
        )
        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2.0,
            longitude: (minLon + maxLon) / 2.0
        )
        return MKCoordinateRegion(center: center, span: span)
    }

    // MARK: - Weather

    func fetchWeatherForCurrentLocation(_ coord: CLLocationCoordinate2D) async {
        if isLoadingWeather { return }
        isLoadingWeather = true
        weatherError = nil
        defer { isLoadingWeather = false }

        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(
                CLLocation(latitude: coord.latitude, longitude: coord.longitude)
            )
            let city = placemarks.first?.locality ?? "Current Location"
            self.currentCity = city

            let weather = try await weatherService.fetchCurrentWeather(for: city)
            self.currentWeather = weather
        } catch is CancellationError {
            // ignore
        } catch {
            self.weatherError = (error as NSError).localizedDescription
        }
    }

    func fetchWeatherForFavorite(city: String) async {
        if isLoadingFavoriteWeather { return }
        isLoadingFavoriteWeather = true
        favoriteWeatherError = nil
        defer { isLoadingFavoriteWeather = false }

        do {
            let weather = try await weatherService.fetchCurrentWeather(for: city)
            self.selectedFavoriteWeather = weather
        } catch is CancellationError {
            // ignore
        } catch {
            self.favoriteWeatherError = (error as NSError).localizedDescription
        }
    }

    // MARK: - Helpers

    func coordinateForFavorite(_ fav: FavoriteCity) -> CLLocationCoordinate2D? {
        if let cached = favoriteCoords[fav.city] {
            return cached
        }
        if let lat = fav.lat, let lon = fav.lon {
            return CLLocationCoordinate2D(latitude: lat, longitude: lon)
        }
        return nil
    }
}


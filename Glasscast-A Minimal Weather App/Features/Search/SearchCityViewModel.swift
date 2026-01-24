//
//  SearchCityViewModel.swift
//  Glasscast-A Minimal Weather App
//
//  Created by Sam's Mac on 24/01/26.
//


import Foundation
import Combine
import CoreLocation
import SwiftUI

@MainActor
final class SearchCityViewModel: ObservableObject {
    
    // MARK: - Input
    @Published var query: String = "" {
        didSet {
            // Keep existing debounce behavior tied to query changes
            onQueryChange(query)
        }
    }
    
    // MARK: - UI flags
    @Published var showClearAllConfirm: Bool = false
    
    // MARK: - Output (UI state)
    @Published private(set) var results: [CitySearchResult] = []
    @Published private(set) var weatherCache: [Int: CurrentWeather] = [:]
    @Published private(set) var loadingSet: Set<Int> = []
    
    @Published private(set) var favoritesWeather: [UUID: CurrentWeather] = [:]
    @Published private(set) var favoritesLoading: Set<UUID> = []
    
    // MARK: - Dependencies
    private let weatherService: WeatherService
    private let apiKey: String
    
    // MARK: - Private
    private var searchTask: Task<Void, Never>?
    
    // MARK: - Init
    init(
        weatherService: WeatherService,
        apiKey: String = WeatherAPIService.defaultAPIKey
    ) {
        self.weatherService = weatherService
        self.apiKey = apiKey
    }
    
    // Convenience init to match SearchCityView’s usage
    convenience init(container: AppContainer) {
        self.init(weatherService: container.weatherService, apiKey: WeatherAPIService.defaultAPIKey)
    }
    
    // MARK: - Search debounce
    func onQueryChange(_ text: String) {
        searchTask?.cancel()
        
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            clearResults()
            return
        }
        
        searchTask = Task { [trimmed] in
            try? await Task.sleep(nanoseconds: 300_000_000)
            guard !Task.isCancelled else { return }
            await performSearch(query: trimmed)
        }
    }
    
    // MARK: - Search
    func search() async {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            clearResults()
            return
        }
        await performSearch(query: trimmed)
    }
    
    func performSearch(query: String) async {
        do {
            let cities = try await searchCities(query: query)
            results = cities
            
            for city in cities.prefix(6) {
                Task { await fetchWeatherIfNeeded(for: city) }
            }
        } catch {
#if DEBUG
            print("[SearchCityVM] search error:", error.localizedDescription)
#endif
            clearResults()
        }
    }
    
    private func searchCities(query: String) async throws -> [CitySearchResult] {
        var comps = URLComponents(string: "https://api.weatherapi.com/v1/search.json")!
        comps.queryItems = [
            .init(name: "q", value: query),
            .init(name: "key", value: apiKey)
        ]
        
        guard let url = comps.url else { throw CitySearchError.badURL }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            throw CitySearchError.http(
                http.statusCode,
                String(data: data, encoding: .utf8) ?? AppConstants.WeatherAPI.unknown
            )
        }
        
        let decoded = try JSONDecoder().decode([CitySearchDTO].self, from: data)
        
        return decoded.map {
            CitySearchResult(
                id: $0.id,
                name: $0.name,
                region: $0.region,
                country: $0.country,
                lat: $0.lat,
                lon: $0.lon,
                url: $0.url
            )
        }
    }
    
    // MARK: - Weather per result
    func fetchWeatherIfNeeded(for city: CitySearchResult) async {
        guard weatherCache[city.id] == nil,
              !loadingSet.contains(city.id)
        else { return }
        
        loadingSet.insert(city.id)
        defer { loadingSet.remove(city.id) }
        
        do {
            let query = "\(city.lat),\(city.lon)"
            let weather = try await weatherService.fetchCurrentWeather(for: query)
            weatherCache[city.id] = weather
        } catch {
#if DEBUG
            print("[SearchCityVM] weather error:", error.localizedDescription)
#endif
        }
    }
    
    // MARK: - Weather per favorite
    func fetchFavoriteWeatherIfNeeded(_ fav: FavoriteCity) async {
        guard favoritesWeather[fav.id] == nil,
              !favoritesLoading.contains(fav.id)
        else { return }
        
        favoritesLoading.insert(fav.id)
        defer { favoritesLoading.remove(fav.id) }
        
        do {
            let query: String = {
                if let lat = fav.lat, let lon = fav.lon {
                    return "\(lat),\(lon)"
                }
                return fav.city
            }()
            
            let weather = try await weatherService.fetchCurrentWeather(for: query)
            favoritesWeather[fav.id] = weather
        } catch {
#if DEBUG
            print("[SearchCityVM] favorite weather error:", error.localizedDescription)
#endif
        }
    }
    
    // MARK: - View compatibility aliases/shims
    
    var loadingResults: Set<Int> { loadingSet }
    var favoriteWeather: [UUID: CurrentWeather] { favoritesWeather }
    var loadingFavorites: Set<UUID> { favoritesLoading }
    
    func loadWeatherForResult(_ city: CitySearchResult) async {
        await fetchWeatherIfNeeded(for: city)
    }
    
    func loadWeatherForFavorite(_ fav: FavoriteCity) async {
        await fetchFavoriteWeatherIfNeeded(fav)
    }
    
    func clearSearch() {
        query = ""
        clearResults()
    }
    
    // MARK: - Helpers
    private func clearResults() {
        results = []
        weatherCache = [:]
        loadingSet = []
    }
}

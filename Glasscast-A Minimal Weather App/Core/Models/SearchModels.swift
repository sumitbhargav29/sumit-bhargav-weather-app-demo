//
//  SearchModels.swift
//  Glasscast-A Minimal Weather App
//
//  Created by Sam's Mac on 24/01/26.
//

import Foundation

// MARK: - WeatherAPI search endpoint model
// MARK: - Public model used by UI
struct CitySearchResult: Identifiable, Equatable {
    let id: Int
    let name: String
    let region: String
    let country: String
    let lat: Double
    let lon: Double
    let url: String
}

// MARK: - API DTO (internal use)
struct CitySearchDTO: Decodable {
    let id: Int
    let name: String
    let region: String
    let country: String
    let lat: Double
    let lon: Double
    let url: String
}

// MARK: - Search errors
enum CitySearchError: LocalizedError {
    case badURL
    case http(Int, String)

    var errorDescription: String? {
        switch self {
        case .badURL:
            return "Invalid search URL."
        case .http(let code, let body):
            return "HTTP \(code): \(body)"
        }
    }
}

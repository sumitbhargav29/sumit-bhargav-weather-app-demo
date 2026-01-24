//
//  HomeModel.swift
//  Glasscast-A Minimal Weather App
//
//  Created by Sam's Mac on 25/01/26.
//

import Foundation

struct CurrentWeather: Equatable, Sendable {
    let city: String
    let temperature: Int
    let condition: String
    let high: Int
    let low: Int
    let symbolName: String
    let theme: WeatherTheme
    
    // Enriched fields from WeatherAPI current + today forecast
    let feelsLikeF: Double
    let windKph: Double
    let humidity: Int
    let pressureMb: Double
    let visibilityKm: Double
    let uvIndex: Double
    let gustKph: Double
    let windDirection: String
    let windDegrees: Int
    let dewpointF: Double
    let heatIndexF: Double
    let aqiEPA: Int?
    let aqiDEFRA: Int?
    let pm25: Double?
    let pm10: Double?
    let sunrise: String
    let sunset: String
    let precipChance: Int
}

struct ForecastDay: Identifiable, Equatable, Sendable {
    let id = UUID()
    let weekday: String
    let high: Int
    let low: Int
    let symbolName: String
}


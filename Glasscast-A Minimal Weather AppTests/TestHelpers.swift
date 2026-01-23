//
//  TestHelpers.swift
//  Glasscast-A Minimal Weather AppTests
//
//  Created for unit testing - Shared test utilities
//

import Foundation
import XCTest
@testable import Glasscast_A_Minimal_Weather_App

// MARK: - Test Data Builders

struct TestDataBuilder {
    static func createCurrentWeather(
        city: String = "Cupertino",
        temperature: Int = 72,
        condition: String = "Sunny",
        high: Int = 76,
        low: Int = 58
    ) -> CurrentWeather {
        CurrentWeather(
            city: city,
            temperature: temperature,
            condition: condition,
            high: high,
            low: low,
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
    }
    
    static func createForecastDay(
        weekday: String = "Mon",
        high: Int = 75,
        low: Int = 60,
        symbolName: String = "sun.max.fill"
    ) -> ForecastDay {
        ForecastDay(
            weekday: weekday,
            high: high,
            low: low,
            symbolName: symbolName
        )
    }
    
    static func createFavoriteCity(
        id: UUID = UUID(),
        userID: UUID = UUID(),
        city: String = "Cupertino",
        country: String = "USA",
        lat: Double? = 37.3230,
        lon: Double? = -122.0322
    ) -> FavoriteCity {
        FavoriteCity(
            id: id,
            user_id: userID,
            city: city,
            country: country,
            created_at: Date(),
            lat: lat,
            lon: lon
        )
    }
}

// MARK: - Async Test Helpers

extension XCTestCase {
    func waitForAsync(timeout: TimeInterval = 1.0) async {
        try? await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
    }
    
    func expectToComplete<T>(
        _ operation: @escaping () async throws -> T,
        timeout: TimeInterval = 5.0,
        file: StaticString = #filePath,
        line: UInt = #line
    ) async throws -> T {
        return try await withThrowingTaskGroup(of: T.self) { group in
            group.addTask {
                try await operation()
            }
            
            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
                throw TimeoutError()
            }
            
            guard let result = try await group.next() else {
                throw TimeoutError()
            }
            
            group.cancelAll()
            return result
        }
    }
}

struct TimeoutError: Error {}

// MARK: - Assertion Helpers

extension XCTestCase {
    func assertEqual<T: FloatingPoint>(
        _ expression1: T,
        _ expression2: T,
        accuracy: T,
        _ message: @autoclosure () -> String = "",
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(expression1, expression2, accuracy: accuracy, message(), file: file, line: line)
    }
}

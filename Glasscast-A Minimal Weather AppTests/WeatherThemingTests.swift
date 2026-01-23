//
//  WeatherThemingTests.swift
//  Glasscast-A Minimal Weather AppTests
//
//  Created for unit testing
//

import XCTest
@testable import Glasscast_A_Minimal_Weather_App

final class WeatherThemingTests: XCTestCase {
    
    func testWeatherThemeCases() {
        // Given/When/Then
        let allCases = WeatherTheme.allCases
        XCTAssertEqual(allCases.count, 7)
        XCTAssertTrue(allCases.contains(.sunny))
        XCTAssertTrue(allCases.contains(.rainy))
        XCTAssertTrue(allCases.contains(.stormy))
        XCTAssertTrue(allCases.contains(.coldSnowy))
        XCTAssertTrue(allCases.contains(.windy))
        XCTAssertTrue(allCases.contains(.foggy))
        XCTAssertTrue(allCases.contains(.hotHumid))
    }
    
    func testWeatherThemeEquality() {
        // Given/When/Then
        XCTAssertEqual(WeatherTheme.sunny, WeatherTheme.sunny)
        XCTAssertEqual(WeatherTheme.rainy, WeatherTheme.rainy)
        XCTAssertNotEqual(WeatherTheme.sunny, WeatherTheme.rainy)
    }
    
    func testWeatherBackgroundCreation() {
        // Given
        let theme = WeatherTheme.sunny
        
        // When
        let background = WeatherBackground(theme: theme)
        
        // Then
        XCTAssertNotNil(background)
    }
    
    func testAllThemesCreateBackground() {
        // Given
        let themes = WeatherTheme.allCases
        
        // When/Then
        for theme in themes {
            let background = WeatherBackground(theme: theme)
            XCTAssertNotNil(background, "Background should be created for theme: \(theme)")
        }
    }
}

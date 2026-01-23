//
//  TemperatureUnitTests.swift
//  Glasscast-A Minimal Weather AppTests
//
//  Created for unit testing
//

import XCTest
@testable import Glasscast_A_Minimal_Weather_App

final class TemperatureUnitTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Reset to default (Celsius)
        UserDefaults.standard.set(true, forKey: "useCelsius")
    }
    
    override func tearDown() {
        // Clean up
        UserDefaults.standard.removeObject(forKey: "useCelsius")
        super.tearDown()
    }
    
    func testConvertToCelsius() {
        // Given
        UserDefaults.standard.set(true, forKey: "useCelsius")
        let fahrenheit = 72
        
        // When
        let celsius = TemperatureUnit.convert(fahrenheit)
        
        // Then
        XCTAssertEqual(celsius, 22) // (72 - 32) * 5/9 = 22.22... ≈ 22
    }
    
    func testConvertToFahrenheit() {
        // Given
        UserDefaults.standard.set(false, forKey: "useCelsius")
        let fahrenheit = 72
        
        // When
        let result = TemperatureUnit.convert(fahrenheit)
        
        // Then
        XCTAssertEqual(result, 72) // Should remain unchanged
    }
    
    func testConvertHighLowPair() {
        // Given
        UserDefaults.standard.set(true, forKey: "useCelsius")
        let high = 76
        let low = 58
        
        // When
        let (convertedHigh, convertedLow) = TemperatureUnit.convert(high: high, low: low)
        
        // Then
        XCTAssertEqual(convertedHigh, 24) // (76 - 32) * 5/9 = 24.44... ≈ 24
        XCTAssertEqual(convertedLow, 14)  // (58 - 32) * 5/9 = 14.44... ≈ 14
    }
    
    func testConvertTriple() {
        // Given
        UserDefaults.standard.set(true, forKey: "useCelsius")
        let temp = 72
        let high = 76
        let low = 58
        
        // When
        let (convertedTemp, convertedHigh, convertedLow) = TemperatureUnit.convert(temp: temp, high: high, low: low)
        
        // Then
        XCTAssertEqual(convertedTemp, 22)
        XCTAssertEqual(convertedHigh, 24)
        XCTAssertEqual(convertedLow, 14)
    }
    
    func testUnitLabelCelsius() {
        // Given
        UserDefaults.standard.set(true, forKey: "useCelsius")
        
        // When
        let label = TemperatureUnit.unitLabel
        
        // Then
        XCTAssertEqual(label, "C")
    }
    
    func testUnitLabelFahrenheit() {
        // Given
        UserDefaults.standard.set(false, forKey: "useCelsius")
        
        // When
        let label = TemperatureUnit.unitLabel
        
        // Then
        XCTAssertEqual(label, "F")
    }
    
    func testFreezingPoint() {
        // Given
        UserDefaults.standard.set(true, forKey: "useCelsius")
        let freezingF = 32
        
        // When
        let freezingC = TemperatureUnit.convert(freezingF)
        
        // Then
        XCTAssertEqual(freezingC, 0)
    }
    
    func testBoilingPoint() {
        // Given
        UserDefaults.standard.set(true, forKey: "useCelsius")
        let boilingF = 212
        
        // When
        let boilingC = TemperatureUnit.convert(boilingF)
        
        // Then
        XCTAssertEqual(boilingC, 100)
    }
    
    func testNegativeTemperatures() {
        // Given
        UserDefaults.standard.set(true, forKey: "useCelsius")
        let negativeF = -4
        
        // When
        let negativeC = TemperatureUnit.convert(negativeF)
        
        // Then
        XCTAssertEqual(negativeC, -20) // (-4 - 32) * 5/9 = -20
    }
    
    func testRounding() {
        // Given
        UserDefaults.standard.set(true, forKey: "useCelsius")
        let fahrenheit = 73 // Should round to 23 (22.78)
        
        // When
        let celsius = TemperatureUnit.convert(fahrenheit)
        
        // Then
        XCTAssertEqual(celsius, 23)
    }
}

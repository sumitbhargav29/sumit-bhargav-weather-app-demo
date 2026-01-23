//
//  SelectedCityStoreTests.swift
//  Glasscast-A Minimal Weather AppTests
//
//  Created for unit testing
//

import XCTest
import CoreLocation
@testable import Glasscast_A_Minimal_Weather_App

@MainActor
final class SelectedCityStoreTests: XCTestCase {
    var store: SelectedCityStore!
    
    override func setUp() {
        super.setUp()
        store = SelectedCityStore()
    }
    
    override func tearDown() {
        store = nil
        super.tearDown()
    }
    
    func testInitialState() {
        // Then
        XCTAssertNil(store.city)
        XCTAssertNil(store.coordinate)
    }
    
    func testSetCity() {
        // Given
        let cityName = "Cupertino"
        
        // When
        store.set(city: cityName)
        
        // Then
        XCTAssertEqual(store.city, cityName)
        XCTAssertNil(store.coordinate)
    }
    
    func testSetCityWithCoordinate() {
        // Given
        let cityName = "Cupertino"
        let coordinate = CLLocationCoordinate2D(latitude: 37.3230, longitude: -122.0322)
        
        // When
        store.set(city: cityName, coordinate: coordinate)
        
        // Then
        XCTAssertEqual(store.city, cityName)
        XCTAssertNotNil(store.coordinate)
        XCTAssertEqual(store.coordinate?.latitude, coordinate.latitude, accuracy: 0.0001)
        XCTAssertEqual(store.coordinate?.longitude, coordinate.longitude, accuracy: 0.0001)
    }
    
    func testClear() {
        // Given
        store.set(city: "Cupertino", coordinate: CLLocationCoordinate2D(latitude: 37.3230, longitude: -122.0322))
        
        // When
        store.clear()
        
        // Then
        XCTAssertNil(store.city)
        XCTAssertNil(store.coordinate)
    }
    
    func testUpdateCity() {
        // Given
        store.set(city: "Cupertino")
        
        // When
        store.set(city: "London")
        
        // Then
        XCTAssertEqual(store.city, "London")
    }
    
    func testUpdateCoordinate() {
        // Given
        let initialCoord = CLLocationCoordinate2D(latitude: 37.3230, longitude: -122.0322)
        store.set(city: "Cupertino", coordinate: initialCoord)
        
        // When
        let newCoord = CLLocationCoordinate2D(latitude: 51.5072, longitude: -0.1276)
        store.set(city: "London", coordinate: newCoord)
        
        // Then
        XCTAssertEqual(store.coordinate?.latitude, newCoord.latitude, accuracy: 0.0001)
        XCTAssertEqual(store.coordinate?.longitude, newCoord.longitude, accuracy: 0.0001)
    }
}

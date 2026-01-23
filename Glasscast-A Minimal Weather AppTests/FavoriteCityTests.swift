//
//  FavoriteCityTests.swift
//  Glasscast-A Minimal Weather AppTests
//
//  Created for unit testing
//

import XCTest
@testable import Glasscast_A_Minimal_Weather_App

final class FavoriteCityTests: XCTestCase {
    
    func testFavoriteCityInitialization() {
        // Given
        let id = UUID()
        let userID = UUID()
        let city = "Cupertino"
        let country = "USA"
        let createdAt = Date()
        let lat = 37.3230
        let lon = -122.0322
        
        // When
        let favorite = FavoriteCity(
            id: id,
            user_id: userID,
            city: city,
            country: country,
            created_at: createdAt,
            lat: lat,
            lon: lon
        )
        
        // Then
        XCTAssertEqual(favorite.id, id)
        XCTAssertEqual(favorite.user_id, userID)
        XCTAssertEqual(favorite.userID, userID)
        XCTAssertEqual(favorite.city, city)
        XCTAssertEqual(favorite.country, country)
        XCTAssertEqual(favorite.created_at, createdAt)
        XCTAssertEqual(favorite.lat, lat)
        XCTAssertEqual(favorite.lon, lon)
    }
    
    func testFavoriteCityEquality() {
        // Given
        let id = UUID()
        let userID = UUID()
        let city = "Cupertino"
        
        let favorite1 = FavoriteCity(
            id: id,
            user_id: userID,
            city: city,
            country: "USA",
            created_at: Date(),
            lat: 37.3230,
            lon: -122.0322
        )
        
        let favorite2 = FavoriteCity(
            id: id,
            user_id: userID,
            city: city,
            country: "USA",
            created_at: favorite1.created_at,
            lat: 37.3230,
            lon: -122.0322
        )
        
        // Then
        XCTAssertEqual(favorite1, favorite2)
    }
    
    func testFavoriteCityInequality() {
        // Given
        let userID = UUID()
        
        let favorite1 = FavoriteCity(
            id: UUID(),
            user_id: userID,
            city: "Cupertino",
            country: "USA",
            created_at: Date(),
            lat: 37.3230,
            lon: -122.0322
        )
        
        let favorite2 = FavoriteCity(
            id: UUID(),
            user_id: userID,
            city: "London",
            country: "UK",
            created_at: Date(),
            lat: 51.5072,
            lon: -0.1276
        )
        
        // Then
        XCTAssertNotEqual(favorite1, favorite2)
    }
    
    func testFavoriteCityWithNilValues() {
        // Given
        let id = UUID()
        let userID = UUID()
        
        // When
        let favorite = FavoriteCity(
            id: id,
            user_id: userID,
            city: "Cupertino",
            country: "USA",
            created_at: nil,
            lat: nil,
            lon: nil
        )
        
        // Then
        XCTAssertNil(favorite.created_at)
        XCTAssertNil(favorite.lat)
        XCTAssertNil(favorite.lon)
    }
    
    func testFavoriteCityCodable() throws {
        // Given
        let favorite = FavoriteCity(
            id: UUID(),
            user_id: UUID(),
            city: "Cupertino",
            country: "USA",
            created_at: Date(),
            lat: 37.3230,
            lon: -122.0322
        )
        
        // When
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(favorite)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(FavoriteCity.self, from: data)
        
        // Then
        XCTAssertEqual(favorite.id, decoded.id)
        XCTAssertEqual(favorite.user_id, decoded.user_id)
        XCTAssertEqual(favorite.city, decoded.city)
        XCTAssertEqual(favorite.country, decoded.country)
        XCTAssertEqual(favorite.lat, decoded.lat)
        XCTAssertEqual(favorite.lon, decoded.lon)
    }
}

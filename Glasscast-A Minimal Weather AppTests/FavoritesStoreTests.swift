//
//  FavoritesStoreTests.swift
//  Glasscast-A Minimal Weather AppTests
//
//  Created for unit testing
//

import XCTest
@testable import Glasscast_A_Minimal_Weather_App

@MainActor
final class FavoritesStoreTests: XCTestCase {
    var store: FavoritesStore!
    var mockService: MockSupabaseFavoriting!
    var mockSession: AppSession!
    
    override func setUp() {
        super.setUp()
        mockService = MockSupabaseFavoriting()
        mockSession = AppSession(currentUserID: UUID())
        store = FavoritesStore(service: mockService, session: mockSession)
    }
    
    override func tearDown() {
        store = nil
        mockService = nil
        mockSession = nil
        super.tearDown()
    }
    
    func testInitialState() {
        // Then
        XCTAssertTrue(store.favorites.isEmpty)
        XCTAssertFalse(store.isLoading)
        XCTAssertNil(store.errorMessage)
    }
    
    func testLoadSuccess() async {
        // Given
        mockService.shouldSucceed = true
        let mockFavorites = createMockFavorites(count: 3)
        mockService.mockFavorites = mockFavorites
        
        // When
        await store.load()
        
        // Then
        XCTAssertEqual(store.favorites.count, 3)
        XCTAssertFalse(store.isLoading)
        XCTAssertNil(store.errorMessage)
    }
    
    func testLoadFailure() async {
        // Given
        mockService.shouldSucceed = false
        mockService.error = NSError(domain: "TestError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Network error"])
        
        // When
        await store.load()
        
        // Then
        XCTAssertTrue(store.favorites.isEmpty)
        XCTAssertFalse(store.isLoading)
        XCTAssertNotNil(store.errorMessage)
    }
    
    func testIsFavorite() async {
        // Given
        mockService.shouldSucceed = true
        let mockFavorites = createMockFavorites(count: 2)
        mockService.mockFavorites = mockFavorites
        await store.load()
        
        // When/Then
        let favorite = store.isFavorite("Cupertino")
        XCTAssertNotNil(favorite)
        XCTAssertEqual(favorite?.city, "Cupertino")
        
        let notFavorite = store.isFavorite("Nonexistent")
        XCTAssertNil(notFavorite)
    }
    
    func testToggleAddFavorite() async {
        // Given
        mockService.shouldSucceed = true
        mockService.mockFavorites = []
        await store.load()
        
        // When
        await store.toggle(city: "New York", country: "USA", lat: 40.7128, lon: -74.0060)
        
        // Then
        XCTAssertEqual(store.favorites.count, 1)
        XCTAssertEqual(store.favorites.first?.city, "New York")
        XCTAssertTrue(mockService.addFavoriteCalled)
    }
    
    func testToggleRemoveFavorite() async {
        // Given
        mockService.shouldSucceed = true
        let mockFavorites = createMockFavorites(count: 1)
        mockService.mockFavorites = mockFavorites
        await store.load()
        
        let favoriteCity = store.favorites.first!
        
        // When
        await store.toggle(city: favoriteCity.city, country: favoriteCity.country)
        
        // Then
        XCTAssertTrue(store.favorites.isEmpty)
        XCTAssertTrue(mockService.removeFavoriteCalled)
    }
    
    func testClearAll() async {
        // Given
        mockService.shouldSucceed = true
        let mockFavorites = createMockFavorites(count: 3)
        mockService.mockFavorites = mockFavorites
        await store.load()
        
        // When
        await store.clearAll()
        
        // Then
        XCTAssertTrue(store.favorites.isEmpty)
        XCTAssertEqual(mockService.removeFavoriteCallCount, 3)
    }
    
    func testCaseInsensitiveFavoriteCheck() async {
        // Given
        mockService.shouldSucceed = true
        let mockFavorites = [
            FavoriteCity(
                id: UUID(),
                user_id: mockSession.currentUserID,
                city: "Cupertino",
                country: "USA",
                created_at: Date(),
                lat: 37.3230,
                lon: -122.0322
            )
        ]
        mockService.mockFavorites = mockFavorites
        await store.load()
        
        // When/Then
        XCTAssertNotNil(store.isFavorite("cupertino"))
        XCTAssertNotNil(store.isFavorite("CUPERTINO"))
        XCTAssertNotNil(store.isFavorite("Cupertino"))
    }
    
    // MARK: - Helper Methods
    
    private func createMockFavorites(count: Int) -> [FavoriteCity] {
        let cities = ["Cupertino", "London", "Tokyo", "Sydney", "Paris"]
        return (0..<count).map { i in
            FavoriteCity(
                id: UUID(),
                user_id: mockSession.currentUserID,
                city: cities[i % cities.count],
                country: "USA",
                created_at: Date(),
                lat: Double(37 + i),
                lon: Double(-122 - i)
            )
        }
    }
}

// MARK: - Mock SupabaseFavoriting

class MockSupabaseFavoriting: SupabaseFavoriting {
    var shouldSucceed = true
    var error: Error?
    var mockFavorites: [FavoriteCity] = []
    var addFavoriteCalled = false
    var removeFavoriteCalled = false
    var removeFavoriteCallCount = 0
    var lastAddCity: String?
    var lastRemoveID: UUID?
    
    func fetchFavorites(for userID: UUID) async throws -> [FavoriteCity] {
        if !shouldSucceed {
            throw error ?? NSError(domain: "MockError", code: 500)
        }
        return mockFavorites
    }
    
    func addFavorite(for userID: UUID, city: String, country: String?, lat: Double?, lon: Double?) async throws -> FavoriteCity {
        addFavoriteCalled = true
        lastAddCity = city
        
        if !shouldSucceed {
            throw error ?? NSError(domain: "MockError", code: 500)
        }
        
        let newFavorite = FavoriteCity(
            id: UUID(),
            user_id: userID,
            city: city,
            country: country ?? "Unknown",
            created_at: Date(),
            lat: lat,
            lon: lon
        )
        mockFavorites.append(newFavorite)
        return newFavorite
    }
    
    func removeFavorite(id: UUID) async throws {
        removeFavoriteCalled = true
        removeFavoriteCallCount += 1
        lastRemoveID = id
        
        if !shouldSucceed {
            throw error ?? NSError(domain: "MockError", code: 500)
        }
        
        mockFavorites.removeAll { $0.id == id }
    }
}

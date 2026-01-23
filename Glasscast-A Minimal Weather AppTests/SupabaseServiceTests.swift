//
//  SupabaseServiceTests.swift
//  Glasscast-A Minimal Weather AppTests
//
//  Created for unit testing
//

import XCTest
@testable import Glasscast_A_Minimal_Weather_App

@MainActor
final class SupabaseServiceTests: XCTestCase {
    var service: SupabaseService!
    var mockSession: MockURLSession!
    let testBaseURL = URL(string: "https://test.supabase.co/rest/v1")!
    let testAPIKey = "test-api-key"
    
    override func setUp() {
        super.setUp()
        mockSession = MockURLSession()
        service = SupabaseService(baseURL: testBaseURL, apiKey: testAPIKey, urlSession: mockSession)
    }
    
    override func tearDown() {
        service = nil
        mockSession = nil
        super.tearDown()
    }
    
    func testFetchFavoritesSuccess() async throws {
        // Given
        let userID = UUID()
        let mockFavorites = createMockFavoritesJSON(userID: userID)
        mockSession.mockData = mockFavorites.data(using: .utf8)
        mockSession.mockResponse = HTTPURLResponse(
            url: testBaseURL,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        
        // When
        let favorites = try await service.fetchFavorites(for: userID)
        
        // Then
        XCTAssertEqual(favorites.count, 2)
        XCTAssertEqual(favorites[0].city, "Cupertino")
        XCTAssertEqual(favorites[1].city, "London")
    }
    
    func testFetchFavoritesFailure() async {
        // Given
        let userID = UUID()
        mockSession.shouldFail = true
        mockSession.error = URLError(.notConnectedToInternet)
        
        // When/Then
        do {
            _ = try await service.fetchFavorites(for: userID)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertNotNil(error)
        }
    }
    
    func testAddFavoriteSuccess() async throws {
        // Given
        let userID = UUID()
        let mockResponse = createMockFavoriteJSON(userID: userID, city: "New York")
        mockSession.mockData = mockResponse.data(using: .utf8)
        mockSession.mockResponse = HTTPURLResponse(
            url: testBaseURL,
            statusCode: 201,
            httpVersion: nil,
            headerFields: nil
        )
        
        // When
        let favorite = try await service.addFavorite(
            for: userID,
            city: "New York",
            country: "USA",
            lat: 40.7128,
            lon: -74.0060
        )
        
        // Then
        XCTAssertEqual(favorite.city, "New York")
        XCTAssertEqual(favorite.country, "USA")
        XCTAssertNotNil(favorite.id)
    }
    
    func testRemoveFavoriteSuccess() async throws {
        // Given
        let favoriteID = UUID()
        mockSession.mockData = Data()
        mockSession.mockResponse = HTTPURLResponse(
            url: testBaseURL,
            statusCode: 204,
            httpVersion: nil,
            headerFields: nil
        )
        
        // When
        try await service.removeFavorite(id: favoriteID)
        
        // Then - Should not throw
        XCTAssertTrue(true)
    }
    
    func testRemoveFavoriteFailure() async {
        // Given
        let favoriteID = UUID()
        mockSession.shouldFail = true
        mockSession.error = NSError(domain: "TestError", code: 404, userInfo: [NSLocalizedDescriptionKey: "Not found"])
        
        // When/Then
        do {
            try await service.removeFavorite(id: favoriteID)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertNotNil(error)
        }
    }
    
    // MARK: - Helper Methods
    
    private func createMockFavoritesJSON(userID: UUID) -> String {
        let dateString = ISO8601DateFormatter().string(from: Date())
        return """
        [
            {
                "id": "\(UUID().uuidString)",
                "user_id": "\(userID.uuidString)",
                "city": "Cupertino",
                "country": "USA",
                "created_at": "\(dateString)",
                "lat": 37.3230,
                "lon": -122.0322
            },
            {
                "id": "\(UUID().uuidString)",
                "user_id": "\(userID.uuidString)",
                "city": "London",
                "country": "UK",
                "created_at": "\(dateString)",
                "lat": 51.5072,
                "lon": -0.1276
            }
        ]
        """
    }
    
    private func createMockFavoriteJSON(userID: UUID, city: String) -> String {
        let dateString = ISO8601DateFormatter().string(from: Date())
        return """
        [
            {
                "id": "\(UUID().uuidString)",
                "user_id": "\(userID.uuidString)",
                "city": "\(city)",
                "country": "USA",
                "created_at": "\(dateString)",
                "lat": 40.7128,
                "lon": -74.0060
            }
        ]
        """
    }
}

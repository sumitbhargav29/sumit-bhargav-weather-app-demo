//
//  AuthServiceTests.swift
//  Glasscast-A Minimal Weather AppTests
//
//  Created for unit testing
//

import XCTest
@testable import Glasscast_A_Minimal_Weather_App

@MainActor
final class AuthServiceTests: XCTestCase {
    var authService: SupabaseAuthService!
    
    override func setUp() {
        super.setUp()
        // Use the default manager (singleton)
        authService = SupabaseAuthService()
    }
    
    override func tearDown() {
        authService = nil
        super.tearDown()
    }
    
    func testAuthServiceInitialization() {
        // Given/When
        let service = SupabaseAuthService()
        
        // Then
        XCTAssertNotNil(service)
        XCTAssertNotNil(service.client)
    }
    
    func testClientAccess() {
        // Given/When
        let client = authService.client
        
        // Then
        XCTAssertNotNil(client)
    }
    
    // Note: Integration tests for signIn/signOut would require actual Supabase credentials
    // These are better suited for integration tests rather than unit tests
    // The service correctly forwards calls to SupabaseManager, which is tested separately
}

// MARK: - Mock SupabaseManager Protocol

protocol MockSupabaseManagerProtocol {
    var shouldSucceed: Bool { get set }
    var error: Error? { get set }
    var signInCalled: Bool { get set }
    var signInFallbackCalled: Bool { get set }
    var signOutCalled: Bool { get set }
    var clientAccessed: Bool { get set }
    var lastEmail: String? { get set }
    var lastPassword: String? { get set }
    var client: SupabaseClient { get }
    func signIn(email: String, password: String) async throws
    func signInFallback(email: String, password: String) async throws
    func signOut() async throws
}

// Note: Since SupabaseManager is a singleton, we'll test AuthService with a protocol-based approach
// In a real scenario, you'd inject a protocol-conforming manager

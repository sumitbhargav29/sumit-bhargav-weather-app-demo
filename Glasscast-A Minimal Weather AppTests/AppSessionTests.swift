//
//  AppSessionTests.swift
//  Glasscast-A Minimal Weather AppTests
//
//  Created for unit testing
//

import XCTest
@testable import Glasscast_A_Minimal_Weather_App

final class AppSessionTests: XCTestCase {
    
    func testInitializationWithDefaultUUID() {
        // When
        let session = AppSession()
        
        // Then
        XCTAssertNotNil(session.currentUserID)
        XCTAssertEqual(
            session.currentUserID.uuidString,
            "00000000-0000-0000-0000-000000000001"
        )
    }
    
    func testInitializationWithCustomUUID() {
        // Given
        let customUUID = UUID()
        
        // When
        let session = AppSession(currentUserID: customUUID)
        
        // Then
        XCTAssertEqual(session.currentUserID, customUUID)
    }
    
    func testCurrentUserIDIsPublished() {
        // Given
        let session = AppSession()
        let initialID = session.currentUserID
        
        // When
        let newID = UUID()
        session.currentUserID = newID
        
        // Then
        XCTAssertNotEqual(session.currentUserID, initialID)
        XCTAssertEqual(session.currentUserID, newID)
    }
}

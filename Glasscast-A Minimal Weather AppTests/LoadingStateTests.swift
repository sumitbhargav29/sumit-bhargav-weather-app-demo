//
//  LoadingStateTests.swift
//  Glasscast-A Minimal Weather AppTests
//
//  Created for unit testing
//

import XCTest
@testable import Glasscast_A_Minimal_Weather_App

final class LoadingStateTests: XCTestCase {
    
    func testIdleState() {
        // Given/When
        let state = LoadingState.idle
        
        // Then
        XCTAssertEqual(state, .idle)
    }
    
    func testLoadingState() {
        // Given/When
        let state = LoadingState.loading
        
        // Then
        XCTAssertEqual(state, .loading)
    }
    
    func testLoadedState() {
        // Given/When
        let state = LoadingState.loaded
        
        // Then
        XCTAssertEqual(state, .loaded)
    }
    
    func testFailedState() {
        // Given
        let errorMessage = "Network error"
        
        // When
        let state = LoadingState.failed(errorMessage)
        
        // Then
        if case .failed(let message) = state {
            XCTAssertEqual(message, errorMessage)
        } else {
            XCTFail("Expected failed state")
        }
    }
    
    func testFailedStateEquality() {
        // Given
        let errorMessage = "Network error"
        let state1 = LoadingState.failed(errorMessage)
        let state2 = LoadingState.failed(errorMessage)
        
        // Then
        XCTAssertEqual(state1, state2)
    }
    
    func testFailedStateInequality() {
        // Given
        let state1 = LoadingState.failed("Error 1")
        let state2 = LoadingState.failed("Error 2")
        
        // Then
        XCTAssertNotEqual(state1, state2)
    }
    
    func testStateInequality() {
        // Given
        let states: [LoadingState] = [.idle, .loading, .loaded, .failed("error")]
        
        // Then
        for i in 0..<states.count {
            for j in 0..<states.count where i != j {
                XCTAssertNotEqual(states[i], states[j], "States at indices \(i) and \(j) should not be equal")
            }
        }
    }
    
    func testFailedStateMessageExtraction() {
        // Given
        let errorMessage = "City not found"
        let state = LoadingState.failed(errorMessage)
        
        // When
        if case .failed(let message) = state {
            // Then
            XCTAssertEqual(message, errorMessage)
        } else {
            XCTFail("Failed to extract error message")
        }
    }
}

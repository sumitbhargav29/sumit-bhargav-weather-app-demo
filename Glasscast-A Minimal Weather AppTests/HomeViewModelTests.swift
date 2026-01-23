//
//  HomeViewModelTests.swift
//  Glasscast-A Minimal Weather AppTests
//
//  Created for unit testing
//

import XCTest
@testable import Glasscast_A_Minimal_Weather_App

@MainActor
final class HomeViewModelTests: XCTestCase {
    var viewModel: HomeViewModel!
    var mockService: MockWeatherService!
    
    override func setUp() {
        super.setUp()
        mockService = MockWeatherService()
        viewModel = HomeViewModel(service: mockService)
    }
    
    override func tearDown() {
        viewModel = nil
        mockService = nil
        super.tearDown()
    }
    
    func testInitialState() {
        // Then
        XCTAssertEqual(viewModel.city, "Cupertino")
        XCTAssertNil(viewModel.current)
        XCTAssertTrue(viewModel.forecast.isEmpty)
        XCTAssertEqual(viewModel.loadingState, .idle)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testLoadSuccess() async {
        // Given
        mockService.shouldSucceed = true
        
        // When
        await viewModel.load()
        
        // Then
        XCTAssertNotNil(viewModel.current)
        XCTAssertFalse(viewModel.forecast.isEmpty)
        XCTAssertEqual(viewModel.loadingState, .loaded)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testLoadFailure() async {
        // Given
        mockService.shouldSucceed = false
        mockService.error = NSError(domain: "TestError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Network error"])
        
        // When
        await viewModel.load()
        
        // Then
        XCTAssertNil(viewModel.current)
        XCTAssertTrue(viewModel.forecast.isEmpty)
        if case .failed(let message) = viewModel.loadingState {
            XCTAssertFalse(message.isEmpty)
        } else {
            XCTFail("Expected failed state")
        }
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNotNil(viewModel.errorMessage)
    }
    
    func testRefreshSuccess() async {
        // Given
        mockService.shouldSucceed = true
        
        // When
        await viewModel.refresh()
        
        // Then
        XCTAssertNotNil(viewModel.current)
        XCTAssertEqual(viewModel.forecast.count, 5)
        XCTAssertEqual(viewModel.loadingState, .loaded)
    }
    
    func testRefreshFailure() async {
        // Given
        mockService.shouldSucceed = false
        mockService.error = NSError(domain: "TestError", code: 404, userInfo: [NSLocalizedDescriptionKey: "City not found"])
        
        // When
        await viewModel.refresh()
        
        // Then
        if case .failed(let message) = viewModel.loadingState {
            XCTAssertFalse(message.isEmpty)
        } else {
            XCTFail("Expected failed state")
        }
    }
    
    func testCancelRefresh() async {
        // Given
        mockService.shouldSucceed = true
        mockService.delay = 1.0 // Simulate slow network
        
        // When
        let refreshTask = Task {
            await viewModel.refresh()
        }
        
        // Cancel immediately
        viewModel.cancelRefresh()
        
        // Wait a bit
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        XCTAssertEqual(viewModel.loadingState, .idle)
        refreshTask.cancel()
    }
    
    func testCityChangeTriggersRefresh() async {
        // Given
        mockService.shouldSucceed = true
        let initialCity = viewModel.city
        
        // When
        viewModel.city = "London"
        await viewModel.refresh()
        
        // Then
        XCTAssertEqual(viewModel.city, "London")
        XCTAssertNotEqual(viewModel.city, initialCity)
        XCTAssertNotNil(viewModel.current)
    }
    
    func testLoadingStateTransitions() async {
        // Given
        mockService.shouldSucceed = true
        
        // Initial state
        XCTAssertEqual(viewModel.loadingState, .idle)
        
        // Start loading
        let refreshTask = Task {
            await viewModel.refresh()
        }
        
        // Wait a tiny bit for loading to start
        try? await Task.sleep(nanoseconds: 10_000_000)
        
        // Should be loading or loaded (depending on speed)
        let state = viewModel.loadingState
        XCTAssertTrue(state == .loading || state == .loaded)
        
        await refreshTask.value
        
        // Should be loaded after completion
        XCTAssertEqual(viewModel.loadingState, .loaded)
    }
    
    func testIsUsingDefaultService() {
        // Given
        let defaultViewModel = HomeViewModel()
        
        // Then
        XCTAssertTrue(defaultViewModel.isUsingDefaultService)
        XCTAssertFalse(viewModel.isUsingDefaultService)
    }
}

// MARK: - Mock WeatherService

class MockWeatherService: WeatherService {
    var shouldSucceed = true
    var error: Error?
    var delay: TimeInterval = 0.0
    var fetchCurrentCalled = false
    var fetchForecastCalled = false
    
    func fetchCurrentWeather(for city: String) async throws -> CurrentWeather {
        fetchCurrentCalled = true
        
        if delay > 0 {
            try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        }
        
        if !shouldSucceed {
            throw error ?? NSError(domain: "MockError", code: 500)
        }
        
        return CurrentWeather(
            city: city,
            temperature: 72,
            condition: "Sunny",
            high: 76,
            low: 58,
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
    
    func fetch5DayForecast(for city: String) async throws -> [ForecastDay] {
        fetchForecastCalled = true
        
        if delay > 0 {
            try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        }
        
        if !shouldSucceed {
            throw error ?? NSError(domain: "MockError", code: 500)
        }
        
        let weekdays = Calendar.current.shortWeekdaySymbols
        return (0..<5).map { i in
            ForecastDay(
                weekday: weekdays[(i + 1) % weekdays.count],
                high: 75 + i,
                low: 60 - i,
                symbolName: "sun.max.fill"
            )
        }
    }
}

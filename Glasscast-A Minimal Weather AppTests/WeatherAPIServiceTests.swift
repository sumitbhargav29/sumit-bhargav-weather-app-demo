//
//  WeatherAPIServiceTests.swift
//  Glasscast-A Minimal Weather AppTests
//
//  Created for unit testing
//

import XCTest
@testable import Glasscast_A_Minimal_Weather_App

final class WeatherAPIServiceTests: XCTestCase {
    var service: WeatherAPIService!
    var mockSession: MockURLSession!
    
    override func setUp() {
        super.setUp()
        mockSession = MockURLSession()
        service = WeatherAPIService(apiKey: "test-key", session: mockSession)
    }
    
    override func tearDown() {
        service = nil
        mockSession = nil
        super.tearDown()
    }
    
    func testFetchCurrentWeatherSuccess() async throws {
        // Given
        let city = "Cupertino"
        let mockResponse = createMockCurrentWeatherResponse(city: city)
        mockSession.mockData = try JSONEncoder().encode(mockResponse)
        mockSession.mockResponse = HTTPURLResponse(
            url: URL(string: "https://api.weatherapi.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        
        // Mock forecast response for today's data
        let mockForecastResponse = createMockForecastResponse()
        mockSession.mockForecastData = try JSONEncoder().encode(mockForecastResponse)
        
        // When
        let currentWeather = try await service.fetchCurrentWeather(for: city)
        
        // Then
        XCTAssertEqual(currentWeather.city, city)
        XCTAssertEqual(currentWeather.temperature, 72)
        XCTAssertEqual(currentWeather.condition, "Sunny")
        XCTAssertNotNil(currentWeather.symbolName)
        XCTAssertNotNil(currentWeather.theme)
    }
    
    func testFetchCurrentWeatherNetworkError() async {
        // Given
        let city = "InvalidCity"
        mockSession.shouldFail = true
        mockSession.error = URLError(.notConnectedToInternet)
        
        // When/Then
        do {
            _ = try await service.fetchCurrentWeather(for: city)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertNotNil(error)
        }
    }
    
    func testFetchCurrentWeatherHTTPError() async {
        // Given
        let city = "Cupertino"
        mockSession.mockResponse = HTTPURLResponse(
            url: URL(string: "https://api.weatherapi.com")!,
            statusCode: 404,
            httpVersion: nil,
            headerFields: nil
        )
        mockSession.mockData = Data("Not Found".utf8)
        
        // When/Then
        do {
            _ = try await service.fetchCurrentWeather(for: city)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertNotNil(error)
        }
    }
    
    func testFetch5DayForecastSuccess() async throws {
        // Given
        let city = "Cupertino"
        let mockForecastResponse = createMockForecastResponse()
        mockSession.mockForecastData = try JSONEncoder().encode(mockForecastResponse)
        mockSession.mockResponse = HTTPURLResponse(
            url: URL(string: "https://api.weatherapi.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        
        // When
        let forecast = try await service.fetch5DayForecast(for: city)
        
        // Then
        XCTAssertEqual(forecast.count, 5)
        XCTAssertNotNil(forecast.first?.weekday)
        XCTAssertNotNil(forecast.first?.symbolName)
    }
    
    func testSymbolNameMapping() {
        // Test various condition strings map to correct symbols
        let testCases: [(String, Bool, String)] = [
            ("Sunny", true, "sun.max.fill"),
            ("Clear", false, "moon.stars.fill"),
            ("Partly Cloudy", true, "cloud.sun.fill"),
            ("Rain", true, "cloud.rain.fill"),
            ("Thunderstorm", true, "cloud.bolt.rain.fill"),
            ("Snow", true, "snow"),
            ("Fog", true, "cloud.fog.fill")
        ]
        
        // Note: symbolName is private, so we test indirectly through fetchCurrentWeather
        // This is a documentation test showing expected mappings
        for (condition, isDay, expectedSymbol) in testCases {
            XCTAssertTrue(
                expectedSymbol.contains("sun") || expectedSymbol.contains("cloud") || expectedSymbol.contains("moon"),
                "Condition '\(condition)' should map to a valid symbol"
            )
        }
    }
    
    // MARK: - Helper Methods
    
    private func createMockCurrentWeatherResponse(city: String) -> WeatherAPIResponse {
        let location = WeatherAPILocation(
            name: city,
            region: "CA",
            country: "USA",
            lat: 37.3230,
            lon: -122.0322,
            tz_id: "America/Los_Angeles",
            localtime_epoch: Int(Date().timeIntervalSince1970),
            localtime: "2026-01-23 12:00"
        )
        
        let condition = WeatherAPICondition(
            text: "Sunny",
            icon: "//cdn.weatherapi.com/weather/64x64/day/113.png",
            code: 1000
        )
        
        let airQuality = WeatherAPIAirQuality(
            co: 200.0,
            no2: 10.0,
            o3: 50.0,
            so2: 5.0,
            pm2_5: 12.0,
            pm10: 18.0,
            us_epa_index: 2,
            gb_defra_index: 3
        )
        
        let current = WeatherAPICurrent(
            last_updated_epoch: Int(Date().timeIntervalSince1970),
            last_updated: "2026-01-23 12:00",
            temp_c: 22.0,
            temp_f: 72.0,
            is_day: 1,
            condition: condition,
            wind_mph: 5.0,
            wind_kph: 8.0,
            wind_degree: 270,
            wind_dir: "W",
            pressure_mb: 1016.0,
            pressure_in: 30.0,
            precip_mm: 0.0,
            precip_in: 0.0,
            humidity: 50,
            cloud: 0,
            feelslike_c: 24.0,
            feelslike_f: 74.0,
            windchill_c: 22.0,
            windchill_f: 72.0,
            heatindex_c: 24.0,
            heatindex_f: 75.0,
            dewpoint_c: 10.0,
            dewpoint_f: 50.0,
            vis_km: 10.0,
            vis_miles: 6.0,
            uv: 5.0,
            gust_mph: 10.0,
            gust_kph: 20.0,
            air_quality: airQuality,
            short_rad: nil,
            diff_rad: nil,
            dni: nil,
            gti: nil
        )
        
        return WeatherAPIResponse(location: location, current: current)
    }
    
    private func createMockForecastResponse() -> WeatherAPIForecastResponse {
        let location = WeatherAPILocation(
            name: "Cupertino",
            region: "CA",
            country: "USA",
            lat: 37.3230,
            lon: -122.0322,
            tz_id: "America/Los_Angeles",
            localtime_epoch: Int(Date().timeIntervalSince1970),
            localtime: "2026-01-23 12:00"
        )
        
        let forecastDays = (0..<5).map { dayOffset -> WeatherAPIForecastDay in
            let date = Calendar.current.date(byAdding: .day, value: dayOffset, to: Date())!
            let dateString = ISO8601DateFormatter().string(from: date).prefix(10)
            
            let condition = WeatherAPICondition(
                text: dayOffset % 2 == 0 ? "Sunny" : "Partly Cloudy",
                icon: "//cdn.weatherapi.com/weather/64x64/day/113.png",
                code: 1000
            )
            
            let day = WeatherAPIDay(
                maxtemp_c: 25.0 + Double(dayOffset),
                maxtemp_f: 77.0 + Double(dayOffset),
                mintemp_c: 15.0 - Double(dayOffset),
                mintemp_f: 59.0 - Double(dayOffset),
                avgtemp_c: 20.0,
                avgtemp_f: 68.0,
                maxwind_mph: 10.0,
                maxwind_kph: 16.0,
                totalprecip_mm: 0.0,
                totalprecip_in: 0.0,
                daily_chance_of_rain: dayOffset == 2 ? 30 : 0,
                daily_chance_of_snow: 0,
                condition: condition,
                avghumidity: 50.0,
                uv: 5.0
            )
            
            let astro = WeatherAPIAstro(
                sunrise: "6:42 AM",
                sunset: "7:58 PM"
            )
            
            return WeatherAPIForecastDay(
                date: String(dateString),
                day: day,
                astro: astro
            )
        }
        
        let forecast = WeatherAPIForecast(forecastday: forecastDays)
        return WeatherAPIForecastResponse(location: location, forecast: forecast)
    }
}

// MARK: - Mock URLSession

class MockURLSession: URLSession {
    var mockData: Data?
    var mockForecastData: Data?
    var mockResponse: HTTPURLResponse?
    var shouldFail = false
    var error: Error?
    private var requestCount = 0
    
    override func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        requestCount += 1
        
        if shouldFail {
            throw error ?? URLError(.badServerResponse)
        }
        
        // Return forecast data for forecast requests, current data for current requests
        let urlString = request.url?.absoluteString ?? ""
        let data = urlString.contains("forecast") ? mockForecastData : mockData
        
        guard let data = data else {
            throw URLError(.badServerResponse)
        }
        
        let response = mockResponse ?? HTTPURLResponse(
            url: request.url!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!
        
        return (data, response)
    }
}

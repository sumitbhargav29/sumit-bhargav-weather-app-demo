//
//  WeatherAPIModelsTests.swift
//  Glasscast-A Minimal Weather AppTests
//
//  Created for unit testing
//

import XCTest
@testable import Glasscast_A_Minimal_Weather_App

final class WeatherAPIModelsTests: XCTestCase {
    
    func testWeatherAPIResponseDecoding() throws {
        // Given
        let json = """
        {
            "location": {
                "name": "Cupertino",
                "region": "CA",
                "country": "USA",
                "lat": 37.3230,
                "lon": -122.0322,
                "tz_id": "America/Los_Angeles",
                "localtime_epoch": 1706025600,
                "localtime": "2026-01-23 12:00"
            },
            "current": {
                "last_updated_epoch": 1706025600,
                "last_updated": "2026-01-23 12:00",
                "temp_c": 22.0,
                "temp_f": 72.0,
                "is_day": 1,
                "condition": {
                    "text": "Sunny",
                    "icon": "//cdn.weatherapi.com/weather/64x64/day/113.png",
                    "code": 1000
                },
                "wind_mph": 5.0,
                "wind_kph": 8.0,
                "wind_degree": 270,
                "wind_dir": "W",
                "pressure_mb": 1016.0,
                "pressure_in": 30.0,
                "precip_mm": 0.0,
                "precip_in": 0.0,
                "humidity": 50,
                "cloud": 0,
                "feelslike_c": 24.0,
                "feelslike_f": 74.0,
                "windchill_c": 22.0,
                "windchill_f": 72.0,
                "heatindex_c": 24.0,
                "heatindex_f": 75.0,
                "dewpoint_c": 10.0,
                "dewpoint_f": 50.0,
                "vis_km": 10.0,
                "vis_miles": 6.0,
                "uv": 5.0,
                "gust_mph": 10.0,
                "gust_kph": 20.0,
                "air_quality": {
                    "co": 200.0,
                    "no2": 10.0,
                    "o3": 50.0,
                    "so2": 5.0,
                    "pm2_5": 12.0,
                    "pm10": 18.0,
                    "us-epa-index": 2,
                    "gb-defra-index": 3
                }
            }
        }
        """
        
        // When
        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        let response = try decoder.decode(WeatherAPIResponse.self, from: data)
        
        // Then
        XCTAssertEqual(response.location.name, "Cupertino")
        XCTAssertEqual(response.current.temp_f, 72.0)
        XCTAssertEqual(response.current.condition.text, "Sunny")
        XCTAssertNotNil(response.current.air_quality)
        XCTAssertEqual(response.current.air_quality?.us_epa_index, 2)
        XCTAssertEqual(response.current.air_quality?.gb_defra_index, 3)
    }
    
    func testWeatherAPIForecastResponseDecoding() throws {
        // Given
        let json = """
        {
            "location": {
                "name": "Cupertino",
                "region": "CA",
                "country": "USA",
                "lat": 37.3230,
                "lon": -122.0322,
                "tz_id": "America/Los_Angeles",
                "localtime_epoch": 1706025600,
                "localtime": "2026-01-23 12:00"
            },
            "forecast": {
                "forecastday": [
                    {
                        "date": "2026-01-23",
                        "day": {
                            "maxtemp_c": 25.0,
                            "maxtemp_f": 77.0,
                            "mintemp_c": 15.0,
                            "mintemp_f": 59.0,
                            "condition": {
                                "text": "Sunny",
                                "icon": "//cdn.weatherapi.com/weather/64x64/day/113.png",
                                "code": 1000
                            },
                            "daily_chance_of_rain": 0
                        },
                        "astro": {
                            "sunrise": "6:42 AM",
                            "sunset": "7:58 PM"
                        }
                    }
                ]
            }
        }
        """
        
        // When
        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        let response = try decoder.decode(WeatherAPIForecastResponse.self, from: data)
        
        // Then
        XCTAssertEqual(response.location.name, "Cupertino")
        XCTAssertEqual(response.forecast.forecastday.count, 1)
        XCTAssertEqual(response.forecast.forecastday[0].day.maxtemp_f, 77.0)
        XCTAssertEqual(response.forecast.forecastday[0].astro.sunrise, "6:42 AM")
    }
    
    func testAirQualityCodingKeys() throws {
        // Given
        let json = """
        {
            "co": 200.0,
            "no2": 10.0,
            "o3": 50.0,
            "so2": 5.0,
            "pm2_5": 12.0,
            "pm10": 18.0,
            "us-epa-index": 2,
            "gb-defra-index": 3
        }
        """
        
        // When
        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        let airQuality = try decoder.decode(WeatherAPIAirQuality.self, from: data)
        
        // Then
        XCTAssertEqual(airQuality.us_epa_index, 2)
        XCTAssertEqual(airQuality.gb_defra_index, 3)
        XCTAssertEqual(airQuality.pm2_5, 12.0)
    }
    
    func testCurrentWeatherEquality() {
        // Given
        let weather1 = CurrentWeather(
            city: "Cupertino",
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
        
        let weather2 = CurrentWeather(
            city: "Cupertino",
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
        
        // Then
        XCTAssertEqual(weather1, weather2)
    }
    
    func testForecastDayEquality() {
        // Given
        let day1 = ForecastDay(weekday: "Mon", high: 75, low: 60, symbolName: "sun.max.fill")
        let day2 = ForecastDay(weekday: "Mon", high: 75, low: 60, symbolName: "sun.max.fill")
        
        // Then
        XCTAssertEqual(day1.weekday, day2.weekday)
        XCTAssertEqual(day1.high, day2.high)
        XCTAssertEqual(day1.low, day2.low)
        XCTAssertEqual(day1.symbolName, day2.symbolName)
    }
}

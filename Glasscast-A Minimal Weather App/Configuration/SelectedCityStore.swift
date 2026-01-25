import Foundation
import CoreLocation
import SwiftUI
import Combine

@MainActor
final class SelectedCityStore: ObservableObject {
    @Published var city: String?
    @Published var coordinate: CLLocationCoordinate2D?
    @Published var cachedWeather: CurrentWeather? // preloaded preview for instant feel
    
    func set(city: String, coordinate: CLLocationCoordinate2D? = nil) {
        self.city = city
        self.coordinate = coordinate
        // Do not clear cachedWeather here; caller may set it just before/after.
    }
    
    // Convenience to set city + cached weather atomically
    func set(city: String, coordinate: CLLocationCoordinate2D? = nil, cachedWeather: CurrentWeather?) {
        self.city = city
        self.coordinate = coordinate
        self.cachedWeather = cachedWeather
    }
    
    func clear() {
        city = nil
        coordinate = nil
        cachedWeather = nil
    }
}


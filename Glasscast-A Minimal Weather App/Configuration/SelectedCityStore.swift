import Foundation
import CoreLocation
import SwiftUI
import Combine

@MainActor
final class SelectedCityStore: ObservableObject {
    @Published var city: String?
    @Published var coordinate: CLLocationCoordinate2D?
    
    func set(city: String, coordinate: CLLocationCoordinate2D? = nil) {
        self.city = city
        self.coordinate = coordinate
    }
    
    func clear() {
        city = nil
        coordinate = nil
    }
}

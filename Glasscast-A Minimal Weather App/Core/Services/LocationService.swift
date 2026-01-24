//
//  CoreLocationService.swift
//  Glasscast-A Minimal Weather App
//
//  Created by Sam's Mac on 24/01/26.
//

import Foundation
import CoreLocation

@MainActor
protocol LocationService: ObservableObject {
    var authorizationStatus: CLAuthorizationStatus { get }
    var coordinate: CLLocationCoordinate2D? { get }
    func requestWhenInUse()
}

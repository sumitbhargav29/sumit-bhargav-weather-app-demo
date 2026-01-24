//
//  AppConstants.swift.swift
//  Glasscast-A Minimal Weather App
//
//  Created by Sam's Mac on 24/01/26.
//

import Foundation
import CoreLocation

enum AppConstants {

    enum AppInfo {
        static let appName = "Glasscast-A Minimal Weather App"
    }

    enum StorageKeys {
        static let useCelsius = "useCelsius"
        static let appColorScheme = "appColorScheme"
    }

    enum Supabase {
        static let projectURLString = "https://gkhjjokrsiuyqcmpjcmw.supabase.co"
        static let projectURL = URL(string: projectURLString)!
        static let restBaseURLString = "\(projectURLString)/rest/v1"
        static let restBaseURL = URL(string: restBaseURLString)!
        static let authTokenPath = "auth/v1/token"
        static let grantTypeKey = "grant_type"
        static let grantTypePassword = "password"
        static let anonKey = "sb_publishable_kpJ_2UmkDA8QwugO5JTApQ_2GVu-L-0"
        static let headerAPIKey = "apikey"
        static let headerAuthorization = "Authorization"
        static let headerContentType = "Content-Type"
        static let headerAccept = "Accept"
        static let headerPrefer = "Prefer"
        static let contentTypeJSON = "application/json"
        static let tableFavoriteCities = "favorite_cities"
        static let selectFavoriteCities = "id,user_id,city:city_name,country,created_at,lat,lon"
        static let orderKey = "order"
        static let orderCreatedAtDesc = "created_at.desc"
        static let userIDFilterKey = "user_id"
        static let idFilterKey = "id"
        static let eqPrefix = "eq."
        static let preferReturnRepresentation = "return=representation"
        static let preferReturnMinimal = "return=minimal"
        static let logPrefix = "[Supabase]"
        static let serviceLogPrefix = "[SupabaseService]"
        static let probeLogPrefix = "[Supabase Probe]"
        static let fallbackLogPrefix = "[Supabase Fallback]"
    }

    enum UI {
        static let radarTitle = "Radar"
        static let radarSubtitle = "Explore the map"
        static let loadingEllipsis = "Loading…"
        static let tapMarkerToLoad = "Tap marker to load weather."
        static let currentLocation = "Current Location"
        static let annotationMe = "Me"
        static let highAbbrev = "H"
        static let lowAbbrev = "L"
        static let symbolMap = "map"
        static let symbolLocationCircleFill = "location.circle.fill"
        static let symbolLocationFill = "location.fill"
        static let symbolStarFill = "star.fill"
        static let symbolCloseCircleFill = "xmark.circle.fill"
    }

    enum Accessibility {
        static let currentLocation = "Current Location"
    }

    enum MapDefaults {
        static let defaultLatitude: CLLocationDegrees = 37.3349
        static let defaultLongitude: CLLocationDegrees = -122.0090
        static let defaultSpanLat: CLLocationDegrees = 0.2
        static let defaultSpanLon: CLLocationDegrees = 0.2
        static let focusSpanLat: CLLocationDegrees = 0.15
        static let focusSpanLon: CLLocationDegrees = 0.15
    }

    enum Logging {
        static let request = "REQUEST"
        static let response = "RESPONSE"
        static let error = "ERROR"
        static let httpPrefix = "HTTP"
        static let nonUTF8Body = "non-UTF8 body"
        static let nilURL = "<nil url>"
        static let none = "<none>"
        static let homeVM = "[HomeVM]"
    }

    enum MockData {
        static let cityCupertino = "Cupertino"
        static let countryUSA = "USA"
        static let cityLondon = "London"
        static let countryUK = "UK"
    }
}

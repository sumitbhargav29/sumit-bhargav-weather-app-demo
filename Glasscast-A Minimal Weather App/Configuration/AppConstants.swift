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
        static let windUnitIsKmh = "windUnitIsKmh"
        static let pressureUnitIsHpa = "pressureUnitIsHpa"
        static let notificationsSevereAlerts = "notificationsSevereAlerts"
        static let notificationsDailySummary = "notificationsDailySummary"
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
    
    enum WeatherAPI {
        static let baseURL = "https://api.weatherapi.com/v1"
        static let currentPath = "current.json"
        static let forecastPath = "forecast.json"
        static let searchPath = "search.json"
        static let queryKeyKey = "key"
        static let queryKeyQ = "q"
        static let queryKeyDays = "days"
        static let queryKeyAQI = "aqi"
        static let queryKeyAlerts = "alerts"
        static let aqiYes = "yes"
        static let aqiNo = "no"
        static let alertsNo = "no"
        static let headerAccept = "Accept"
        static let contentTypeJSON = "application/json"
        static let defaultAPIKey = "e576ecaf37344b5da74135851262201"
        static let errorDomain = "WeatherAPIService"
        static let unknown = "Unknown"
    }
    
    enum UI {
        // Common
        static let loadingEllipsis = "Loading…"
        static let refresh = "Refresh"
        static let placeholderDash = "—"
        static let placeholderTime = "--:--"
        static let currentLocation = "Current Location"
        static let annotationMe = "Me"
        static let highAbbrev = "H"
        static let lowAbbrev = "L"
        
        // Tabs
        static let homeTab = "Home"
        static let searchTab = "Search"
        
        // Radar
        static let radarTitle = "Radar"
        static let radarSubtitle = "Explore the map"
        static let tapMarkerToLoad = "Tap marker to load weather."
        
        // Home
        static let homeTitle = "Glasscast"
        static let homeSubtitle = "A Minimal Weather App"
        static let fiveDayForecast = "5-Day Forecast"
        static let sunriseSunset = "Sunrise & Sunset"
        static let todaysHighlights = "Today’s Highlights"
        static let feelsLike = "Feels Like"
        static let wind = "Wind"
        static let humidity = "Humidity"
        static let pressure = "Pressure"
        static let visibility = "Visibility"
        static let uvIndex = "UV Index"
        static let windGust = "Wind Gust"
        static let windDir = "Wind Dir"
        static let dewPoint = "Dew Point"
        static let heatIndex = "Heat Index"
        static let airQuality = "Air Quality"
        static let airQualityEPADEFRA = "EPA"
        static let airQualitySEP = "  •  DEFRA "
        static let precipitation = "Precipitation"
        static let chanceToday = "Chance today"
        
        // Settings
        static let settingsTitle = "Settings"
        static let settingsSubtitle = "Basic preferences"
        static let sectionWeatherUnits = "Weather Units"
        static let sectionAppearance = "Appearance"
        static let sectionNotifications = "Notifications"
        static let temperatureTitle = "Temperature"
        static let temperatureSubtitle = "Choose between Celsius and Fahrenheit"
        static let tempC = "°C"
        static let tempF = "°F"
        static let windSpeedTitle = "Wind Speed"
        static let windSpeedSubtitle = "Display in km/h or mph"
        static let kmh = "km/h"
        static let mph = "mph"
        static let pressureTitle = "Pressure"
        static let pressureSubtitle = "Display in hPa or inHg"
        static let hPa = "hPa"
        static let inHg = "inHg"
        static let notificationsTitle = "Notifications"
        static let severeAlerts = "Severe Alerts"
        static let severeAlertsSubtitle = "Get notified for severe weather"
        static let dailySummary = "Daily Summary"
        static let dailySummarySubtitle = "Receive a daily weather digest"
        static let signOut = "Sign Out"
        static let signingOut = "Signing Out..."
        static let signOutConfirmTitle = "Are you sure you want to sign out?"
        static let signOutConfirmMessage = "You will need to sign in again to access your account."
        static let cancel = "Cancel"
        static let signOutDestructive = "Sign Out"
        static let profileDefaultName = "User"
        static let profileNoEmail = "(no email)"
        static let premiumBadge = "PREMIUM GLASS ACCOUNT"
        static let appearanceMode = "Appearance Mode"
        static let darkMode = "Dark Mode"
        static let lightMode = "Light Mode"
        static let systemMode = "System"
        static let darkShort = "Dark"
        static let lightShort = "Light"
        static let footerName = "Demo by Sumit bhargav"
        static let footerEmail = "sumitbhargav2994@gmail.com"
        
        // Search
        static let searchTitle = "Search for a City"
        static let searchSubtitle = "Find and save locations"
        static let searchPlaceholder = "Find a city…"
        static let favoritesHeader = "FAVORITES"
        static let favoritesEmpty = "No favorites yet. Search and add cities you care about."
        static let sync = "SYNC"
        static let clearAll = "CLEAR ALL"
        static let searchResultsHeader = "SEARCH RESULTS"
        static let clearAllAlertTitle = "Clear all favorites?"
        static let clearAllAlertMessage = "This will remove all your saved cities."
        
        // Signup
        static let signupTitle = "Glasscast"
        static let signupSubtitle = "CREATE YOUR ACCOUNT"
        static let signupJoin = "Join the portal"
        static let signupDesc = "Set up your account to start exploring the weather"
        static let fullNameTitle = "FULL NAME"
        static let fullNamePlaceholder = "Jane Doe"
        static let emailTitle = "EMAIL ADDRESS"
        static let emailPlaceholder = "name@weather.com"
        static let passwordTitle = "PASSWORD"
        static let passwordPlaceholder = "Create a password"
        static let confirmPasswordTitle = "CONFIRM PASSWORD"
        static let confirmPasswordPlaceholder = "Re-enter your password"
        static let termsPrefix = "I agree to the"
        static let terms = "Terms"
        static let and = "and"
        static let privacyPolicy = "Privacy Policy"
        static let createAccount = "Create Account"
        static let alreadyHaveAccount = "Already have an account?"
        static let signIn = "Sign In"
        static let secureBySupabase = "SECURE BY SUPABASE"
        static let checkYourEmail = "Check your email"
        static let ok = "OK"
        static let signupEmailSentPrefix = "We sent a confirmation link to "
        static let signupEmailSentSuffix = ". Please verify to finish creating your account."
        static let signupSuccess = "Account created successfully."
        
        // Login
        static let loginTitle = "Glasscast"
        static let loginSubtitle = "SIGN IN TO YOUR WEATHER PORTAL"
        static let loginWelcomeBack = "Welcome back"
        static let loginSecurelySignIn = "Securely sign in to continue"
        static let forgot = "FORGOT?"
        static let yourPassword = "Your password"
        static let signingIn = "Signing In..."
        static let signInAction = "Sign In"
        static let dontHaveAccount = "Don’t have an account?"
        static let createAccountAction = "Create Account"
        static let signInFailedTitle = "Sign In Failed"
        static let unknownError = "An unknown error occurred. Please try again."
        static let debugSignInProbe = "Debug Sign-In Probe"
        static let enterEmailAndPasswordFirst = "Enter email and password first."
        static let probeOutput = "Probe Output"
        static let pleaseEnterValidEmailPassword = "Please enter a valid email and password."
        
        // Login error mapping constants
        static let loginDecodingError1 = "The data couldn’t be read because it is missing."
        static let loginDecodingError2 = "The data couldn’t be read because it isn’t in the correct format."
        static let loginDecodingFriendly = "Sign in didn’t complete. Please check your email and password, then try again. If the issue persists, try again later."
        static let loginOffline = "You appear to be offline. Please check your internet connection."
        static let loginTimeout = "The request timed out. Please try again."
        static let loginInvalidCredentials = "Invalid email or password. Please try again."
        static let loginConfirmEmail = "Please confirm your email before signing in. Check your inbox for the verification link."
    }
    
    enum Symbols {
        static let map = "map"
        static let locationCircleFill = "location.circle.fill"
        static let locationFill = "location.fill"
        static let starFill = "star.fill"
        static let star = "star"
        static let closeCircleFill = "xmark.circle.fill"
        static let gearshapeFill = "gearshape.fill"
        static let thermometerMedium = "thermometer.medium"
        static let wind = "wind"
        static let gauge = "gauge.with.dots.needle.bottom.50percent"
        static let exclamationTriangleFill = "exclamationmark.triangle.fill"
        static let sunMaxTriangleExclamation = "sun.max.trianglebadge.exclamationmark"
        static let rectanglePortraitArrowRight = "rectangle.portrait.and.arrow.right"
        static let personCropCircleFill = "person.crop.circle.fill"
        static let checkmarkSealFill = "checkmark.seal.fill"
        static let moonFill = "moon.fill"
        static let sunMaxFill = "sun.max.fill"
        static let circleLeftHalfFilled = "circle.lefthalf.filled"
        static let checkmark = "checkmark"
        static let chevronDown = "chevron.down"
        static let magnifyingglass = "magnifyingglass"
        static let trashFill = "trash.fill"
        static let cloudSunFill = "cloud.sun.fill"
        static let sunriseFill = "sunrise.fill"
        static let sunsetFill = "sunset.fill"
        static let aqiMedium = "aqi.medium"
        static let cloudRainFill = "cloud.rain.fill"
        static let thermometerSunFill = "thermometer.sun.fill"
        static let humidityFill = "humidity.fill"
        static let eyeFill = "eye.fill"
        static let tornado = "tornado"
        static let locationNorthLine = "location.north.line"
        static let dropFill = "drop.fill"
        static let thermometerHigh = "thermometer.high"
        static let arrowClockwiseCircleFill = "arrow.clockwise.circle.fill"
        static let shieldFill = "shield.fill"
        static let personBadgePlus = "person.badge.plus"
        static let lockFill = "lock.fill"
        static let lockCircleFill = "lock.circle.fill"
        static let envelopeFill = "envelope.fill"
        static let personFill = "person.fill"
        static let cloudSunRainFill = "cloud.sun.rain.fill"
        static let arrowRight = "arrow.right"
        static let eyeFillAlt = "eye.fill"
        static let eyeSlashFill = "eye.slash.fill"
        static let wrenchScrewdriverFill = "wrench.and.screwdriver.fill"
        static let houseFill = "house.fill"
    }
    
    enum Accessibility {
        static let currentLocation = "Current Location"
        static let addToFavorites = "Add to favorites"
        static let removeFromFavorites = "Remove from favorites"
        static let removeFavorite = "Remove favorite"
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


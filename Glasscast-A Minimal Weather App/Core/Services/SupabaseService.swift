//
//  SupabaseService.swift
//  Glasscast-A Minimal Weather App
//
//  Created by Sam's Mac on 21/01/26.
//

import Foundation
import Combine

// Minimal session holder. Replace with real auth integration later.
final class AppSession: ObservableObject, @unchecked Sendable {
    @Published var currentUserID: UUID
    
    init(currentUserID: UUID = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!) {
        self.currentUserID = currentUserID
    }
}

// Updated model to include optional country returned by Supabase.
// Extended with optional lat/lon so we can place map markers without geocoding.
struct FavoriteCity: Identifiable, Codable, Equatable, Sendable {
    let id: UUID
    let user_id: UUID
    let city: String
    let country: String
    let created_at: Date?
    let lat: Double?
    let lon: Double?
    
    var userID: UUID { user_id }
}

protocol SupabaseFavoriting {
    func fetchFavorites(for userID: UUID) async throws -> [FavoriteCity]
    func addFavorite(for userID: UUID, city: String, country: String?, lat: Double?, lon: Double?) async throws -> FavoriteCity
    func removeFavorite(id: UUID) async throws
}

// NOTE: This is a minimal PostgREST-based client using URLSession.
// If you add the official Supabase Swift SDK, you can replace this with that client.
final class SupabaseService: SupabaseFavoriting, @unchecked Sendable {
    private let baseURL: URL
    private let apiKey: String
    private let urlSession: URLSession
    
    // Configure with your Supabase project URL and anon key.
    // IMPORTANT: baseURL must point to the PostgREST endpoint (/rest/v1).
    init(
        baseURL: URL = AppConstants.Supabase.restBaseURL,
        apiKey: String = AppConstants.Supabase.anonKey,
        urlSession: URLSession = .shared
    ) {
        self.baseURL = baseURL
        self.apiKey = apiKey
        self.urlSession = urlSession
    }
    
    private func request(path: String, method: String, query: [URLQueryItem] = [], body: Data? = nil, prefer: String? = nil) throws -> URLRequest {
        // path should be a table path relative to /rest/v1, e.g. "favorite_cities"
        var components = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false)!
        if !query.isEmpty {
            components.queryItems = query
        }
        var req = URLRequest(url: components.url!)
        req.httpMethod = method
        // Default headers use anon key. We'll override Authorization below with user token if available.
        req.addValue(apiKey, forHTTPHeaderField: AppConstants.Supabase.headerAPIKey)
        req.addValue(AppConstants.Supabase.contentTypeJSON, forHTTPHeaderField: AppConstants.Supabase.headerContentType)
        req.addValue(AppConstants.Supabase.contentTypeJSON, forHTTPHeaderField: AppConstants.Supabase.headerAccept)
        if let prefer {
            req.addValue(prefer, forHTTPHeaderField: AppConstants.Supabase.headerPrefer)
        }
        req.httpBody = body
        return req
    }

    // Inject Authorization after building the request, preferring the authenticated token.
    private func authorize(_ request: URLRequest) async -> URLRequest {
        var req = request
        // Ask SupabaseManager for the best Authorization header (user token if exists, else anon)
        let authHeader = await SupabaseManager.shared.authorizationHeader()
        req.setValue(authHeader, forHTTPHeaderField: AppConstants.Supabase.headerAuthorization)
        return req
    }
    
    func fetchFavorites(for userID: UUID) async throws -> [FavoriteCity] {
        // Include lat/lon in the select.
        let select = AppConstants.Supabase.selectFavoriteCities
        let req = try request(
            path: AppConstants.Supabase.tableFavoriteCities,
            method: "GET",
            query: [
                URLQueryItem(name: "select", value: select),
                URLQueryItem(name: AppConstants.Supabase.orderKey, value: AppConstants.Supabase.orderCreatedAtDesc),
                URLQueryItem(name: AppConstants.Supabase.userIDFilterKey, value: "\(AppConstants.Supabase.eqPrefix)\(userID.uuidString.lowercased())")
            ]
        )
        let authorized = await authorize(req)
        logRequest(authorized, label: "FETCH favorites")
        do {
            let (data, resp) = try await urlSession.data(for: authorized)
            try SupabaseService.ensureOK(resp: resp, data: data, context: "FETCH favorites")
            logResponse(resp, data: data, label: "FETCH favorites OK")
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode([FavoriteCity].self, from: data)
        } catch {
            logError(error, label: "FETCH favorites FAILED")
            throw error
        }
    }
    
    func addFavorite(for userID: UUID, city: String, country: String?, lat: Double?, lon: Double?) async throws -> FavoriteCity {
        // Insert using city_name, country, lat, lon; return with alias for city and include all fields.
        struct Insert: Codable {
            let user_id: UUID
            let city_name: String
            let country: String?
            let lat: Double?
            let lon: Double?
        }
        let payload = try JSONEncoder().encode([Insert(user_id: userID, city_name: city, country: country, lat: lat, lon: lon)])
        let req = try request(
            path: AppConstants.Supabase.tableFavoriteCities,
            method: "POST",
            query: [
                URLQueryItem(name: "select", value: AppConstants.Supabase.selectFavoriteCities)
            ],
            body: payload,
            prefer: AppConstants.Supabase.preferReturnRepresentation
        )
        let authorized = await authorize(req)
        logRequest(authorized, label: "ADD favorite", bodyPreview: payload)
        do {
            let (data, resp) = try await urlSession.data(for: authorized)
            try SupabaseService.ensureOK(resp: resp, data: data, context: "ADD favorite")
            logResponse(resp, data: data, label: "ADD favorite OK")
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let inserted = try decoder.decode([FavoriteCity].self, from: data)
            guard let first = inserted.first else {
                let err = NSError(domain: "SupabaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Insert returned no rows"])
                logError(err, label: "ADD favorite decode FAILED")
                throw err
            }
            return first
        } catch {
            logError(error, label: "ADD favorite FAILED")
            throw error
        }
    }
    
    func removeFavorite(id: UUID) async throws {
        let req = try request(
            path: AppConstants.Supabase.tableFavoriteCities,
            method: "DELETE",
            query: [
                URLQueryItem(name: AppConstants.Supabase.idFilterKey, value: "\(AppConstants.Supabase.eqPrefix)\(id.uuidString.lowercased())")
            ],
            prefer: AppConstants.Supabase.preferReturnMinimal
        )
        let authorized = await authorize(req)
        logRequest(authorized, label: "REMOVE favorite")
        do {
            let (data, resp) = try await urlSession.data(for: authorized)
            try SupabaseService.ensureOK(resp: resp, data: data, context: "REMOVE favorite")
            logResponse(resp, data: data, label: "REMOVE favorite OK")
        } catch {
            logError(error, label: "REMOVE favorite FAILED")
            throw error
        }
    }
    
    private static func ensureOK(resp: URLResponse, data: Data) throws {
        // kept for backward compat; calls the contextual version with a default label
        try ensureOK(resp: resp, data: data, context: "HTTP")
    }
    
    private static func ensureOK(resp: URLResponse, data: Data, context: String) throws {
        guard let http = resp as? HTTPURLResponse else { return }
        if (200...299).contains(http.statusCode) { return }
        let body = String(data: data, encoding: .utf8) ?? ""
        print("\(AppConstants.Supabase.serviceLogPrefix) \(context) \(AppConstants.Logging.error) status=\(http.statusCode) body=\(body)")
        throw NSError(domain: "SupabaseService", code: http.statusCode, userInfo: [NSLocalizedDescriptionKey: "HTTP \(http.statusCode): \(body)"])
    }
    
    // MARK: - Logging helpers
    
    private func logRequest(_ req: URLRequest, label: String, bodyPreview: Data? = nil) {
        let urlStr = req.url?.absoluteString ?? AppConstants.Logging.nilURL
        let method = req.httpMethod ?? "GET"
        let auth = req.value(forHTTPHeaderField: AppConstants.Supabase.headerAuthorization) ?? AppConstants.Logging.none
        let apiKeyHeader = req.value(forHTTPHeaderField: AppConstants.Supabase.headerAPIKey) != nil
        var msg = "\(AppConstants.Supabase.serviceLogPrefix) \(label) \(AppConstants.Logging.request) \(method) \(urlStr)\n  apikeyHeader=\(apiKeyHeader) authPrefix=\(auth.prefix(16))…"
        if let bodyPreview, let bodyText = String(data: bodyPreview, encoding: .utf8) {
            msg += "\n  body=\(bodyText)"
        }
        print(msg)
    }
    
    private func logResponse(_ resp: URLResponse, data: Data, label: String) {
        guard let http = resp as? HTTPURLResponse else {
            print("\(AppConstants.Supabase.serviceLogPrefix) \(label) \(AppConstants.Logging.response) non-HTTP")
            return
        }
        let body = String(data: data, encoding: .utf8) ?? "<\(AppConstants.Logging.nonUTF8Body), \(data.count) bytes>"
        print("\(AppConstants.Supabase.serviceLogPrefix) \(label) \(AppConstants.Logging.response) status=\(http.statusCode) body=\(body)")
    }
    
    private func logError(_ error: Error, label: String) {
        let ns = error as NSError
        print("\(AppConstants.Supabase.serviceLogPrefix) \(label): \(ns.domain) code=\(ns.code) message=\(ns.localizedDescription) userInfo=\(ns.userInfo)")
    }
}


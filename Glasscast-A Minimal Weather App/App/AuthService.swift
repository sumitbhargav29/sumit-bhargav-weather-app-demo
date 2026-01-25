//
//  AuthService.swift
//  Glasscast-A Minimal Weather App
//
//  Small abstraction over Supabase auth so views depend on a protocol
//  instead of the concrete SupabaseManager singleton.
//

import Foundation
import Supabase

/// High-level authentication API used by views.
protocol AuthService {
    var client: SupabaseClient { get }

    // Sign up a new user with optional user metadata.
    @discardableResult
    func signUp(email: String, password: String, data: [String: AnyJSON]?) async throws -> AuthResponse

    func signIn(email: String, password: String) async throws
    func signInFallback(email: String, password: String) async throws
    func signOut() async throws
}

/// Default implementation that forwards to `SupabaseManager`.
final class SupabaseAuthService: AuthService {
    private let manager: SupabaseManager

    init(manager: SupabaseManager = .shared) {
        self.manager = manager
    }

    var client: SupabaseClient {
        manager.client
    }

    @discardableResult
    func signUp(email: String, password: String, data: [String: AnyJSON]? = nil) async throws -> AuthResponse {
        try await manager.client.auth.signUp(
            email: email,
            password: password,
            data: data
        )
    }

    func signIn(email: String, password: String) async throws {
        try await manager.signIn(email: email, password: password)
    }

    func signInFallback(email: String, password: String) async throws {
        try await manager.signInFallback(email: email, password: password)
    }

    func signOut() async throws {
        try await manager.signOut()
    }
}

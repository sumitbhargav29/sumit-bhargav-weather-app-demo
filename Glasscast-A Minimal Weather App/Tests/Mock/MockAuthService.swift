//
//  MockAuthService.swift
//  Glasscast-A Minimal Weather App
//
//  Created by Sam's Mac on 24/01/26.
//

import Foundation
import Supabase

final class MockAuthService: AuthService {
    // Provide a usable client to satisfy callers that access client.auth,
    // but tests/previews should not rely on real network.
    var client: SupabaseClient {
        SupabaseManager.shared.client
    }
    
    // Controls to simulate outcomes in tests/previews
    var shouldSucceedSignUp: Bool = true
    var shouldSucceedSignIn: Bool = true
    var shouldSucceedFallback: Bool = true
    var shouldSucceedSignOut: Bool = true
    
    var lastSignUp: (email: String, password: String, data: [String: AnyJSON]?)?
    var lastSignIn: (email: String, password: String)?
    
    @discardableResult
    func signUp(email: String, password: String, data: [String : AnyJSON]?) async throws -> AuthResponse {
        lastSignUp = (email, password, data)
        guard shouldSucceedSignUp else {
            throw NSError(domain: "MockAuthService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Mock sign up failed"])
        }
        // Simulate email confirmation required: return a response with a user but no session.
        // AuthResponse is an enum; use the .user case with a minimal mock User.
        let user = User(
            id: UUID(),
            appMetadata: [:],
            userMetadata: data ?? [:],
            aud: "authenticated",
            confirmationSentAt: Date(),
            recoverySentAt: nil,
            emailChangeSentAt: nil,
            newEmail: nil,
            invitedAt: nil,
            actionLink: nil,
            email: email,
            phone: nil,
            createdAt: Date(),
            confirmedAt: nil,
            emailConfirmedAt: nil,
            phoneConfirmedAt: nil,
            lastSignInAt: nil,
            role: nil,
            updatedAt: Date(),
            identities: nil,
            isAnonymous: false,
            factors: nil
        )
        return .user(user)
    }
    
    func signIn(email: String, password: String) async throws {
        lastSignIn = (email, password)
        guard shouldSucceedSignIn else {
            throw NSError(domain: "MockAuthService", code: -2, userInfo: [NSLocalizedDescriptionKey: "Mock sign in failed"])
        }
    }
    
    func signInFallback(email: String, password: String) async throws {
        lastSignIn = (email, password)
        guard shouldSucceedFallback else {
            throw NSError(domain: "MockAuthService", code: -3, userInfo: [NSLocalizedDescriptionKey: "Mock fallback sign in failed"])
        }
    }
    
    func signOut() async throws {
        guard shouldSucceedSignOut else {
            throw NSError(domain: "MockAuthService", code: -4, userInfo: [NSLocalizedDescriptionKey: "Mock sign out failed"])
        }
    }
}

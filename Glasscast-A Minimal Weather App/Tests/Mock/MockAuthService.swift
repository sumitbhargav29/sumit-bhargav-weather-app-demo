//
//  MockAuthService.swift
//  Glasscast-A Minimal Weather App
//
//  Created by Sam's Mac on 24/01/26.
//

import Foundation
import Supabase

final class MockAuthService: AuthService {
    var client: SupabaseClient { fatalError() }
    
    func signIn(email: String, password: String) async throws {}
    func signInFallback(email: String, password: String) async throws {}
    func signOut() async throws {}
}

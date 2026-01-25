//
//  SettingsViewModel.swift
//  Glasscast-A Minimal Weather App
//
//  Created by Sam's Mac on 24/01/26.
//

import Foundation
import SwiftUI
import Supabase
import Combine

@MainActor
final class SettingsViewModel: ObservableObject {
    // Auth state
    @Published private(set) var isAuthenticated: Bool = false
    
    // Navigation/alerts
    @Published var isSigningOut: Bool = false
    @Published var navigateToLogin: Bool = false
    @Published var showConfirmSignOut: Bool = false
    
    // Profile values
    @Published var profileDisplayName: String = AppConstants.UI.profileDefaultName
    @Published var profileEmail: String = AppConstants.UI.profileNoEmail
    @Published var profileIsPremium: Bool = false
    
    private let container: AppContainer
    private var authObserverTask: Task<Void, Never>?
    
    init(container: AppContainer? = nil) {
        // Construct default inside the @MainActor initializer body to avoid nonisolated default-arg evaluation
        self.container = container ?? AppContainer()
        
        // Observe Supabase auth state
        authObserverTask = Task { [weak self] in
            guard let self else { return }
            for await authed in SupabaseManager.shared.$isAuthenticated.values {
                await MainActor.run { self.isAuthenticated = authed }
            }
        }
        
        // Seed initial auth flag
        isAuthenticated = SupabaseManager.shared.isAuthenticated
    }
    
    deinit {
        authObserverTask?.cancel()
    }
    
    func performSignOut() {
        guard !isSigningOut else { return }
        isSigningOut = true
        Task {
            do {
                try await container.authService.signOut()
            } catch {
                // ignore and continue UX flow
            }
            // Brief delay for visual feedback
            try? await Task.sleep(nanoseconds: 300_000_000)
            await MainActor.run {
                isSigningOut = false
                navigateToLogin = true
            }
        }
    }
    
    func refreshProfileFromSession() async {
        // Try to read session; if unavailable, reset to defaults.
        guard let session = try? await container.authService.client.auth.session else {
            await MainActor.run {
                profileDisplayName = AppConstants.UI.profileDefaultName
                profileEmail = AppConstants.UI.profileNoEmail
                profileIsPremium = false
            }
            return
        }
        
        let user = session.user
        let email = user.email ?? AppConstants.UI.profileNoEmail
        var display = AppConstants.UI.profileDefaultName
        
        var isPremium = false
        let meta = user.userMetadata // [String: AnyJSON]
        
        // Prefer "full_name", fallback to "name"
        if let fullName = meta["full_name"]?.string,
           !fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            display = fullName
        } else if let name = meta["name"]?.string,
                  !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            display = name
        }
        
        // Parse premium flag from multiple possible types
        if let b = meta["premium"]?.bool {
            isPremium = b
        } else if let i = meta["premium"]?.int {
            isPremium = i != 0
        } else if let d = meta["premium"]?.double {
            isPremium = d != 0
        } else if let s = meta["premium"]?.string {
            isPremium = (s as NSString).boolValue
        }
        
        // Fallback display to local-part of email if still default
        if display == AppConstants.UI.profileDefaultName, let e = user.email {
            let local = e.split(separator: "@").first.map(String.init) ?? e
            if !local.isEmpty {
                display = local
            }
        }
        
        await MainActor.run {
            profileDisplayName = display
            profileEmail = email
            profileIsPremium = isPremium
        }
    }
}

// Lightweight helpers to pull values out of Supabase AnyJSON safely
private extension AnyJSON {
    var string: String? {
        if case let .string(s) = self { return s }
        return nil
    }
    var bool: Bool? {
        if case let .bool(b) = self { return b }
        if case let .string(s) = self { return (s as NSString).boolValue }
        if case let .integer(i) = self { return i != 0 }
        if case let .double(d) = self { return d != 0 }
        return nil
    }
    var int: Int? {
        if case let .integer(i) = self { return i }
        if case let .double(d) = self { return Int(d) }
        if case let .string(s) = self { return Int(s) }
        return nil
    }
    var double: Double? {
        if case let .double(d) = self { return d }
        if case let .integer(i) = self { return Double(i) }
        if case let .string(s) = self { return Double(s) }
        return nil
    }
}

//
//  RootView.swift
//  Glasscast-A Minimal Weather App
//
//  Created by Sam's Mac on 26/01/26.
//

import SwiftUI
import Combine

struct RootView: View {
    @Environment(\.container) private var container
    
    // Track whether the initial auth resolution has completed
    @State private var isAuthResolved: Bool = false
    @State private var isAuthenticated: Bool = SupabaseManager.shared.isAuthenticated
    
    var body: some View {
        Group {
            if !isAuthResolved {
                PlaceholderView()
                    .task {
                        // Kick off an early read; SupabaseManager already tries to restore on init.
                        // We wait a brief moment to allow the initial authStateChanges/session read to settle.
                        await resolveInitialAuth()
                    }
            } else {
                NavigationStack {
                    if isAuthenticated {
                        TabContainerView(homeModel: container.makeHomeViewModel())
                            .navigationBarBackButtonHidden(true)
                    } else {
                        LoginView()
                            .navigationBarBackButtonHidden(true)
                    }
                }
            }
        }
        .task {
            // Observe subsequent auth changes to keep routing accurate after initial resolve.
            for await authed in SupabaseManager.shared.$isAuthenticated.values {
                await MainActor.run {
                    self.isAuthenticated = authed
                }
            }
        }
    }
    
    private func resolveInitialAuth() async {
        // Read current auth state immediately (in case session already restored)
        await MainActor.run {
            self.isAuthenticated = SupabaseManager.shared.isAuthenticated
        }
        
        // Two parallel tasks:
        // 1) Minimum splash duration of 3 seconds.
        // 2) Allow Supabase to settle/restore any session state.
        async let minimumSplash: Void = {
            try? await Task.sleep(nanoseconds: 3_000_000_000)
        }()
        
        async let authSettle: Void = {
            // If your SupabaseManager emits/settles quickly, this can be short.
            // Keep a small buffer to let initial authStateChanges/session read settle.
            try? await Task.sleep(nanoseconds: 300_000_000)
            await MainActor.run {
                self.isAuthenticated = SupabaseManager.shared.isAuthenticated
            }
        }()
        
        // Wait for both to complete
        _ = await (minimumSplash, authSettle)
        
        await MainActor.run {
            self.isAuthResolved = true
        }
    }
}


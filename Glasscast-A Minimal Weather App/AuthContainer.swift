//
//  AuthContainer.swift
//  Glasscast-A Minimal Weather App
//
//  Created by Sam's Mac on 21/01/26.
//

import SwiftUI

struct AuthContainer: View {
    // Observe Supabase auth state
    @StateObject private var auth = SupabaseManager.shared
    @Environment(\.container) private var container

    var body: some View {
        NavigationStack {
            Group {
                if auth.isAuthenticated {
                    // Build the real HomeViewModel from container and pass it down
                    TabContainerView(homeModel: container.makeHomeViewModel())
                        .navigationBarBackButtonHidden(true)
                } else {
                    LoginView()
                }
            }
        }
    }
}

#Preview {
    AuthContainer()
}

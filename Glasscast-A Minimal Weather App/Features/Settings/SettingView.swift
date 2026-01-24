//
//  SettingView.swift
//  Glasscast-A Minimal Weather App
//
//  Created by Sam's Mac on 21/01/26.
//

import Foundation
import SwiftUI
import Combine
import Supabase
import Auth

struct SettingsView: View {
    // Keep a consistent background
    private let theme: WeatherTheme = .sunny
    
    // Persist temperature unit preference
    @AppStorage(AppConstants.StorageKeys.useCelsius) private var useCelsius: Bool = true
    
    // New persisted preferences
    @AppStorage(AppConstants.StorageKeys.windUnitIsKmh) private var windUnitIsKmh: Bool = true // true: km/h, false: mph
    @AppStorage(AppConstants.StorageKeys.pressureUnitIsHpa) private var pressureUnitIsHpa: Bool = true // true: hPa, false: inHg
    @AppStorage(AppConstants.StorageKeys.notificationsSevereAlerts) private var severeAlerts: Bool = true
    @AppStorage(AppConstants.StorageKeys.notificationsDailySummary) private var dailySummary: Bool = false
    
    // Color scheme preference
    @ObservedObject private var colorSchemeManager = ColorSchemeManager.shared
    
    // Adaptive foreground color helper
    private func adaptiveForeground(opacity: Double = 1.0) -> Color {
        ColorSchemeManager.shared.adaptiveForegroundColor(opacity: opacity)
    }
    
    // Local sign-out navigation
    @State private var isSigningOut = false
    @State private var navigateToLogin = false
    @State private var showConfirmSignOut = false
    
    // Observe Supabase auth
    @StateObject private var auth = SupabaseManager.shared
    @Environment(\.container) private var container
    
    // Cached profile values populated asynchronously
    @State private var profileDisplayName: String = AppConstants.UI.profileDefaultName
    @State private var profileEmail: String = AppConstants.UI.profileNoEmail
    @State private var profileIsPremium: Bool = false
    
    var body: some View {
        ZStack {
            WeatherBackground(theme: theme).ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 18) {
                    // Invisible NavigationLink to LoginView, triggered by navigateToLogin
                    NavigationLink(isActive: $navigateToLogin) {
                        LoginView()
                            .navigationBarBackButtonHidden(true)
                    } label: {
                        EmptyView()
                    }
                    .hidden()
                    
                    header
                    
                    // Profile card
                    profileCard
                    
                    // Weather Units section
                    sectionHeader(title: AppConstants.UI.sectionWeatherUnits)
                    VStack(spacing: 12) {
                        settingsRow(
                            icon: AppConstants.Symbols.thermometerMedium,
                            title: AppConstants.UI.temperatureTitle,
                            subtitle: AppConstants.UI.temperatureSubtitle,
                            trailing: AnyView(
                                unitToggle(
                                    isOn: $useCelsius,
                                    onLabel: AppConstants.UI.tempC,
                                    offLabel: AppConstants.UI.tempF
                                )
                            )
                        )
                        
                        settingsRow(
                            icon: AppConstants.Symbols.wind,
                            title: AppConstants.UI.windSpeedTitle,
                            subtitle: AppConstants.UI.windSpeedSubtitle,
                            trailing: AnyView(
                                unitToggle(
                                    isOn: $windUnitIsKmh,
                                    onLabel: AppConstants.UI.kmh,
                                    offLabel: AppConstants.UI.mph
                                )
                            )
                        )
                        
                        settingsRow(
                            icon: AppConstants.Symbols.gauge,
                            title: AppConstants.UI.pressureTitle,
                            subtitle: AppConstants.UI.pressureSubtitle,
                            trailing: AnyView(
                                unitToggle(
                                    isOn: $pressureUnitIsHpa,
                                    onLabel: AppConstants.UI.hPa,
                                    offLabel: AppConstants.UI.inHg
                                )
                            )
                        )
                    }
                    .padding(.horizontal, 16)
                    
                    // Appearance section
                    sectionHeader(title: AppConstants.UI.sectionAppearance)
                    VStack(spacing: 12) {
                        appearanceModeRow
                    }
                    .padding(.horizontal, 16)
                    
                    // Notifications section
                    sectionHeader(title: AppConstants.UI.sectionNotifications)
                    VStack(spacing: 12) {
                        toggleRow(
                            icon: AppConstants.Symbols.exclamationTriangleFill,
                            title: AppConstants.UI.severeAlerts,
                            subtitle: AppConstants.UI.severeAlertsSubtitle,
                            isOn: $severeAlerts
                        )
                        
                        toggleRow(
                            icon: AppConstants.Symbols.sunMaxTriangleExclamation,
                            title: AppConstants.UI.dailySummary,
                            subtitle: AppConstants.UI.dailySummarySubtitle,
                            isOn: $dailySummary
                        )
                    }
                    .padding(.horizontal, 16)
                    
                    
                    // Sign out button with glassy gradient (kept from your current code)
                    VStack(spacing: 12) {
                        Button {
                            showConfirmSignOut = true
                        } label: {
                            HStack(spacing: 10) {
                                if isSigningOut {
                                    ProgressView().tint(.white)
                                } else {
                                    Image(systemName: AppConstants.Symbols.rectanglePortraitArrowRight)
                                        .foregroundStyle(Color.red)
                                        .font(.headline)
                                }
                                Text(isSigningOut ? AppConstants.UI.signingOut : AppConstants.UI.signOut)
                                    .foregroundStyle(Color.red)
                                    .font(.headline.bold())
                            }
                            .foregroundColor(adaptiveForeground())
                            .frame(maxWidth: .infinity)
                            .padding()
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .shadow(color: .red.opacity(0.45), radius: 20, y: 8)
                        }
                        .glassEffect()
                        .disabled(isSigningOut)
                        .frame(maxWidth: 160,maxHeight: 50)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 6)
                    
                    // Footer
                    footer
                }
                .padding(.top, 24)
                .padding(.bottom, 24)
            }
            // Option A: Use an alert so it appears centered on all devices
            .alert(AppConstants.UI.signOutConfirmTitle, isPresented: $showConfirmSignOut) {
            Button(AppConstants.UI.cancel, role: .cancel) { }
            Button(AppConstants.UI.signOutDestructive, role: .destructive) {
                HapticFeedback.medium()
                performSignOut()
            }
        } message: {
                Text(AppConstants.UI.signOutConfirmMessage)
            }
        }
        .navigationBarBackButtonHidden(true)
        .task {
            await refreshProfileFromSession()
        }
        .onChange(of: auth.isAuthenticated) { _ in
            Task { await refreshProfileFromSession() }
        }
    }
    
    // MARK: - Header
    
    private var header: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(.ultraThinMaterial)
                .frame(width: 44, height: 44)
                .overlay {
                    Image(systemName: AppConstants.Symbols.gearshapeFill)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(LinearGradient(
                            colors: [.cyan, .blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                }
                .shadow(color: .black.opacity(0.35), radius: 14, y: 6)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(AppConstants.UI.settingsTitle)
                    .font(.system(.title3, design: .rounded).weight(.bold))
                    .foregroundColor(adaptiveForeground())
                Text(AppConstants.UI.settingsSubtitle)
                    .font(.caption)
                    .foregroundColor(adaptiveForeground(opacity: 0.65))
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
    }
    
    // MARK: - Profile Card
    
    private var profileCard: some View {
        HStack(alignment: .center, spacing: 16) {
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 64, height: 64)
                    .shadow(color: .black.opacity(0.35), radius: 12, y: 6)
                
                Image(systemName: AppConstants.Symbols.personCropCircleFill)
                    .font(.system(size: 58))
                    .foregroundStyle(LinearGradient(
                        colors: [.cyan, .blue],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .opacity(0.9)
                
                // Small verified badge
                if auth.isAuthenticated {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 18, height: 18)
                        .overlay {
                            Image(systemName: AppConstants.Symbols.checkmarkSealFill)
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(adaptiveForeground())
                        }
                        .offset(x: 22, y: 22)
                        .shadow(color: .black.opacity(0.3), radius: 6, y: 3)
                }
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(profileDisplayName)
                    .font(.headline.bold())
                    .foregroundColor(adaptiveForeground())
                
                Text(profileEmail)
                    .font(.footnote)
                    .foregroundColor(adaptiveForeground(opacity: 0.75))
                
                if profileIsPremium {
                    Text(AppConstants.UI.premiumBadge)
                        .font(.caption2.weight(.semibold))
                        .foregroundColor(adaptiveForeground(opacity: 0.9))
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background(
                            LinearGradient(
                                colors: [Color.cyan.opacity(0.35), Color.blue.opacity(0.25)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(.white.opacity(0.25), lineWidth: 1)
                        )
                }
            }
            
            Spacer()
        }
        .padding(16)
        .glassEffect()
         .padding(.horizontal, 16)
    }
    
    // MARK: - Section Header
    
    private func sectionHeader(title: String) -> some View {
        HStack {
            Text(title.uppercased())
                .font(.caption.weight(.semibold))
                .foregroundColor(adaptiveForeground(opacity: 0.75))
            Spacer()
        }
        .padding(.horizontal, 16)
    }
    
    // MARK: - Reusable Rows
    
    private func settingsRow(icon: String, title: String, subtitle: String, trailing: AnyView) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(.ultraThinMaterial)
                .frame(width: 36, height: 36)
                .overlay {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(adaptiveForeground(opacity: 0.9))
                }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .foregroundColor(adaptiveForeground())
                    .font(.subheadline.bold())
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(adaptiveForeground(opacity: 0.65))
            }
            
            Spacer()
            
            trailing
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
        .glassEffect()
    }
    
    private func unitToggle(isOn: Binding<Bool>, onLabel: String, offLabel: String) -> some View {
        VStack(spacing: 6) {
            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(.cyan)
            Text(isOn.wrappedValue ? onLabel : offLabel)
                .font(.caption.weight(.semibold))
                .foregroundColor(adaptiveForeground(opacity: 0.85))
                .frame(minWidth: 40)
        }
    }
    
    private var appearanceModeRow: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(.ultraThinMaterial)
                .frame(width: 36, height: 36)
                .overlay {
                    Image(systemName: colorSchemeManager.isDarkMode ? AppConstants.Symbols.moonFill : colorSchemeManager.isLightMode ? AppConstants.Symbols.sunMaxFill : AppConstants.Symbols.circleLeftHalfFilled)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(adaptiveForeground(opacity: 0.9))
                }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(AppConstants.UI.appearanceMode)
                    .foregroundColor(adaptiveForeground())
                    .font(.subheadline.bold())
                Text(colorSchemeManager.isDarkMode ? AppConstants.UI.darkMode : colorSchemeManager.isLightMode ? AppConstants.UI.lightMode : AppConstants.UI.systemMode)
                    .font(.caption)
                    .foregroundColor(adaptiveForeground(opacity: 0.65))
            }
            
            Spacer()
            
            Menu {
                Button {
                    HapticFeedback.light()
                    colorSchemeManager.setLightMode()
                } label: {
                    HStack {
                        Text(AppConstants.UI.lightMode)
                        if colorSchemeManager.isLightMode {
                            Image(systemName: AppConstants.Symbols.checkmark)
                        }
                    }
                }
                
                Button {
                    HapticFeedback.light()
                    colorSchemeManager.setDarkMode()
                } label: {
                    HStack {
                        Text(AppConstants.UI.darkMode)
                        if colorSchemeManager.isDarkMode {
                            Image(systemName: AppConstants.Symbols.checkmark)
                        }
                    }
                }
                
                Button {
                    HapticFeedback.light()
                    colorSchemeManager.setSystemMode()
                } label: {
                    HStack {
                        Text(AppConstants.UI.systemMode)
                        if !colorSchemeManager.isDarkMode && !colorSchemeManager.isLightMode {
                            Image(systemName: AppConstants.Symbols.checkmark)
                        }
                    }
                }
            } label: {
                HStack(spacing: 6) {
                    Text(colorSchemeManager.isDarkMode ? AppConstants.UI.darkShort : colorSchemeManager.isLightMode ? AppConstants.UI.lightShort : AppConstants.UI.systemMode)
                        .font(.caption.weight(.semibold))
                        .foregroundColor(adaptiveForeground(opacity: 0.85))
                    Image(systemName: AppConstants.Symbols.chevronDown)
                        .font(.caption2)
                        .foregroundColor(adaptiveForeground(opacity: 0.65))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.ultraThinMaterial)
                )
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
        .glassEffect()
    }
    
    private func toggleRow(icon: String, title: String, subtitle: String, isOn: Binding<Bool>) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(.ultraThinMaterial)
                .frame(width: 36, height: 36)
                .overlay {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(adaptiveForeground(opacity: 0.9))
                }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .foregroundColor(adaptiveForeground())
                    .font(.subheadline.bold())
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(adaptiveForeground(opacity: 0.65))
            }
            
            Spacer()
            
            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(.cyan)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
        .glassEffect()
    }
    
    private func navigationRow(icon: String, title: String, subtitle: String, trailingBadge: AnyView, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 36, height: 36)
                    .overlay {
                        Image(systemName: icon)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(adaptiveForeground(opacity: 0.9))
                    }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .foregroundColor(adaptiveForeground())
                        .font(.subheadline.bold())
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(adaptiveForeground(opacity: 0.65))
                }
                
                Spacer()
                
                trailingBadge
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 14)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .glassEffect()
    }
    
    private func statusBadge(text: String, color: Color) -> some View {
        Text(text)
            .font(.caption2.weight(.bold))
            .foregroundColor(.white)
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
            .background(color.opacity(0.7))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(.white.opacity(0.25), lineWidth: 1)
            )
    }
    
    // MARK: - Footer
    
    private var footer: some View {
        VStack(spacing: 4) {
            Text(AppConstants.UI.footerName)
                .font(.caption2.weight(.semibold))
                .foregroundColor(adaptiveForeground(opacity: 0.55))
            Text(AppConstants.UI.footerEmail)
                .font(.caption2)
                .foregroundColor(adaptiveForeground(opacity: 0.45))
        }
        .padding(.top, 8)
    }
    
    // MARK: - Sign Out
    
    private func performSignOut() {
        isSigningOut = true
        Task {
            do {
                try await container.authService.signOut()
            } catch {
                // If sign-out fails, we’ll still try to move on after brief delay
            }
            // Brief delay for visual feedback
            try? await Task.sleep(nanoseconds: 300_000_000)
            await MainActor.run {
                isSigningOut = false
                navigateToLogin = true
            }
        }
    }
    
    // MARK: - Profile loading
    
    private func refreshProfileFromSession() async {
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
        
        // Safely parse metadata using AnyJSON helpers
        var isPremium = false
        
        // user.userMetadata is [String: AnyJSON]
        let meta = user.userMetadata
        
        if let fullName = meta["full_name"]?.stringValue,
           !fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            display = fullName
        } else if let name = meta["name"]?.stringValue,
                  !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            display = name
        }
        
        if let premiumBool = meta["premium"]?.boolValue {
            isPremium = premiumBool
        } else if let premiumInt = meta["premium"]?.intValue {
            isPremium = premiumInt != 0
        } else if let premiumDouble = meta["premium"]?.doubleValue {
            isPremium = premiumDouble != 0
        } else if let premiumString = meta["premium"]?.stringValue {
            isPremium = (premiumString as NSString).boolValue
        }
        
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

#Preview {
    SettingsView()
}

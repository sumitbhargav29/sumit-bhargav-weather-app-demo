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
    
    // ViewModel
    @StateObject private var viewModel = SettingsViewModel()
    
    var body: some View {
        ZStack {
            WeatherBackground(theme: theme).ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 18) {
                    // Invisible NavigationLink to LoginView, triggered by viewModel.navigateToLogin
                    NavigationLink(isActive: $viewModel.navigateToLogin) {
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
                    SettingsSectionHeader(title: AppConstants.UI.sectionWeatherUnits, adaptiveForeground: adaptiveForeground)
                    VStack(spacing: 12) {
                        SettingsRow(
                            icon: AppConstants.Symbols.thermometerMedium,
                            title: AppConstants.UI.temperatureTitle,
                            subtitle: AppConstants.UI.temperatureSubtitle,
                            adaptiveForeground: adaptiveForeground
                        ) {
                            SettingsUnitToggle(
                                isOn: $useCelsius,
                                onLabel: AppConstants.UI.tempC,
                                offLabel: AppConstants.UI.tempF,
                                adaptiveForeground: adaptiveForeground
                            )
                        }
                        
                        SettingsRow(
                            icon: AppConstants.Symbols.wind,
                            title: AppConstants.UI.windSpeedTitle,
                            subtitle: AppConstants.UI.windSpeedSubtitle,
                            adaptiveForeground: adaptiveForeground
                        ) {
                            SettingsUnitToggle(
                                isOn: $windUnitIsKmh,
                                onLabel: AppConstants.UI.kmh,
                                offLabel: AppConstants.UI.mph,
                                adaptiveForeground: adaptiveForeground
                            )
                        }
                        
                        SettingsRow(
                            icon: AppConstants.Symbols.gauge,
                            title: AppConstants.UI.pressureTitle,
                            subtitle: AppConstants.UI.pressureSubtitle,
                            adaptiveForeground: adaptiveForeground
                        ) {
                            SettingsUnitToggle(
                                isOn: $pressureUnitIsHpa,
                                onLabel: AppConstants.UI.hPa,
                                offLabel: AppConstants.UI.inHg,
                                adaptiveForeground: adaptiveForeground
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    // Appearance section
                    SettingsSectionHeader(title: AppConstants.UI.sectionAppearance, adaptiveForeground: adaptiveForeground)
                    VStack(spacing: 12) {
                        SettingsAppearanceModeRow(
                            colorSchemeManager: colorSchemeManager,
                            adaptiveForeground: adaptiveForeground
                        )
                    }
                    .padding(.horizontal, 16)
                    
                    // Notifications section
                    SettingsSectionHeader(title: AppConstants.UI.sectionNotifications, adaptiveForeground: adaptiveForeground)
                    VStack(spacing: 12) {
                        SettingsToggleRow(
                            icon: AppConstants.Symbols.exclamationTriangleFill,
                            title: AppConstants.UI.severeAlerts,
                            subtitle: AppConstants.UI.severeAlertsSubtitle,
                            isOn: $severeAlerts,
                            adaptiveForeground: adaptiveForeground
                        )
                        
                        SettingsToggleRow(
                            icon: AppConstants.Symbols.sunMaxTriangleExclamation,
                            title: AppConstants.UI.dailySummary,
                            subtitle: AppConstants.UI.dailySummarySubtitle,
                            isOn: $dailySummary,
                            adaptiveForeground: adaptiveForeground
                        )
                    }
                    .padding(.horizontal, 16)
                    
                    // Sign out button with glassy gradient
                    VStack(spacing: 12) {
                        Button {
                            viewModel.showConfirmSignOut = true
                        } label: {
                            HStack(spacing: 10) {
                                if viewModel.isSigningOut {
                                    ProgressView().tint(.white)
                                } else {
                                    Image(systemName: AppConstants.Symbols.rectanglePortraitArrowRight)
                                        .foregroundStyle(Color.red)
                                        .font(.headline)
                                }
                                Text(viewModel.isSigningOut ? AppConstants.UI.signingOut : AppConstants.UI.signOut)
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
                        .disabled(viewModel.isSigningOut)
                        .frame(maxWidth: 160,maxHeight: 50)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 6)
                    
                    // Footer
                    SettingsFooter(adaptiveForeground: adaptiveForeground)
                }
                .padding(.top, 24)
                .padding(.bottom, 24)
            }
            .alert(AppConstants.UI.signOutConfirmTitle, isPresented: $viewModel.showConfirmSignOut) {
                Button(AppConstants.UI.cancel, role: .cancel) { }
                Button(AppConstants.UI.signOutDestructive, role: .destructive) {
                    HapticFeedback.medium()
                    viewModel.performSignOut()
                }
            } message: {
                Text(AppConstants.UI.signOutConfirmMessage)
            }
        }
        .navigationBarBackButtonHidden(true)
        .task {
            await viewModel.refreshProfileFromSession()
        }
        .onChange(of: viewModel.isAuthenticated) { _ in
            Task { await viewModel.refreshProfileFromSession() }
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
                if viewModel.isAuthenticated {
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
                Text(viewModel.profileDisplayName)
                    .font(.headline.bold())
                    .foregroundColor(adaptiveForeground())
                
                Text(viewModel.profileEmail)
                    .font(.footnote)
                    .foregroundColor(adaptiveForeground(opacity: 0.75))
                
                if viewModel.profileIsPremium {
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
}

#Preview {
    SettingsView()
}

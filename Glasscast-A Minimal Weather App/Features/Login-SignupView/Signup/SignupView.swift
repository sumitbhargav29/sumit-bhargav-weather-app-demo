//
//  SignupView.swift
//  Glasscast-A Minimal Weather App
//
//  Created by Sam's Mac on 21/01/26.
//

import SwiftUI
import Combine
import Helpers
import Supabase

struct SignupView: View {
    @Environment(\.container) private var container
    
    // MVVM: ViewModel owns all logic/state
    @StateObject private var viewModel: SignupViewModel
    
    // Pick the theme for this screen
    private let screenTheme: WeatherTheme = .hotHumid
    
    // Adaptive foreground color helper (match HomeView/LoginView)
    private func adaptiveForeground(opacity: Double = 1.0) -> Color {
        ColorSchemeManager.shared.adaptiveForegroundColor(opacity: opacity)
    }
    
    init(container: AppContainer? = nil) {
        let resolved = container ?? AppContainer()
        _viewModel = StateObject(wrappedValue: SignupViewModel(container: resolved))
    }
    
    var body: some View {
        ZStack {
            WeatherBackground(theme: screenTheme)
                .ignoresSafeArea()
            
            GeometryReader { proxy in
                let safeBottom = proxy.safeAreaInsets.bottom
                let minVPadding: CGFloat = 16
                let contentTopPadding: CGFloat = 0
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 22) {
                        // Navigation to Login after success
                        NavigationLink(isActive: $viewModel.navigateToLogin) {
                            LoginView()
                                .navigationBarBackButtonHidden(true)
                        } label: {
                            EmptyView()
                        }
                        .hidden()
                        
                        header
                        
                        card
                            .padding(.horizontal, 16)
                            .frame(maxWidth: 600)
                        
                        footer
                        
                        Spacer(minLength: minVPadding)
                    }
                    .padding(.top, contentTopPadding)
                    .padding(.bottom, max(24, safeBottom + 8))
                }
                .scrollDismissesKeyboard(.interactively)
            }
        }
        .navigationBarBackButtonHidden(true)
        .alert(AppConstants.UI.checkYourEmail, isPresented: .constant(viewModel.successMessage != nil)) {
            Button(AppConstants.UI.ok) {
                viewModel.acknowledgeSuccess()
            }
        } message: {
            Text(viewModel.successMessage ?? "")
        }
    }
    
    private var header: some View {
        VStack(spacing: 4) {
            Circle()
                .fill(.ultraThinMaterial)
                .frame(width: 44, height: 44)
                .overlay {
                    Image(systemName: AppConstants.Symbols.cloudSunFill)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(LinearGradient(
                            colors: [.yellow, .orange],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                }
                .shadow(color: .black.opacity(0.35), radius: 16, y: 8)
            
            Text(AppConstants.UI.signupTitle)
                .font(.system(.title2, design: .rounded).weight(.bold))
                .foregroundColor(adaptiveForeground())
                .shadow(color: .black.opacity(0.35), radius: 10)
            
            Text(AppConstants.UI.signupSubtitle)
                .font(.caption2.weight(.light))
                .foregroundColor(adaptiveForeground(opacity: 0.65))
                .tracking(1.1)
        }
    }
    
    private var card: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(AppConstants.UI.signupJoin)
                .font(.headline.bold())
                .foregroundColor(adaptiveForeground())
            
            Text(AppConstants.UI.signupDesc)
                .font(.footnote)
                .foregroundColor(adaptiveForeground(opacity: 0.65))
            
            LabeledIconTextField(
                title: AppConstants.UI.fullNameTitle,
                systemImage: AppConstants.Symbols.personFill,
                placeholder: AppConstants.UI.fullNamePlaceholder,
                text: $viewModel.fullName,
                autocapitalization: .words
            )
            
            LabeledIconTextField(
                title: AppConstants.UI.emailTitle,
                systemImage: AppConstants.Symbols.envelopeFill,
                placeholder: AppConstants.UI.emailPlaceholder,
                text: $viewModel.email,
                autocapitalization: .never,
                keyboard: .emailAddress
            )
            
            LabeledIconSecureField(
                title: AppConstants.UI.passwordTitle,
                systemImage: AppConstants.Symbols.lockFill,
                placeholder: AppConstants.UI.passwordPlaceholder,
                text: $viewModel.password
            )
            
            LabeledIconSecureField(
                title: AppConstants.UI.confirmPasswordTitle,
                systemImage: AppConstants.Symbols.lockCircleFill,
                placeholder: AppConstants.UI.confirmPasswordPlaceholder,
                text: $viewModel.confirmPassword
            )
            
            TermsToggleRow(isOn: $viewModel.agreeToTerms)
            
            AuthMessageView(
                error: viewModel.errorMessage,
                success: viewModel.successMessage
            )
            
            AuthPrimaryButton(
                title: AppConstants.UI.createAccount,
                systemImage: AppConstants.Symbols.personBadgePlus,
                isLoading: viewModel.isSigningUp,
                isEnabled: viewModel.isFormValid
            ) {
                viewModel.createAccountTapped()
            }
            
            // Link back to Sign In
            HStack(spacing: 6) {
                Text(AppConstants.UI.alreadyHaveAccount)
                    .foregroundColor(adaptiveForeground(opacity: 0.7))
                NavigationLink {
                    LoginView()
                        .navigationBarBackButtonHidden(true)
                } label: {
                    Text(AppConstants.UI.signIn)
                        .foregroundColor(.cyan)
                        .bold()
                }
            }
            .font(.footnote)
            .frame(maxWidth: .infinity)
        }
        .padding(18)
        .liquidGlass(cornerRadius: 28, intensity: 0.45)
    }
    
    private var footer: some View {
        HStack(spacing: 6) {
            Image(systemName: AppConstants.Symbols.shieldFill)
            Text(AppConstants.UI.secureBySupabase)
                .font(.caption.weight(.semibold))
        }
        .foregroundColor(adaptiveForeground(opacity: 0.55))
    }
}

#Preview {
    NavigationStack {
        SignupView()
    }
}

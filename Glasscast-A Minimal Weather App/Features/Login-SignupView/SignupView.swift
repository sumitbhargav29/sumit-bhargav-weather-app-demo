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
    
    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var agreeToTerms = false
    
    // Auth UI state
    @State private var isSigningUp = false
    @State private var errorMessage: String?
    @State private var successMessage: String?
    @State private var navigateToLogin = false
    @Environment(\.container) private var container
    
    // Pick the theme for this screen
    private let screenTheme: WeatherTheme = .hotHumid
    
    // Simple validation helpers
    private var isEmailValid: Bool {
        // Basic check; you can replace with a more robust validator
        email.contains("@") && email.contains(".")
    }
    
    private var isPasswordMatch: Bool {
        !password.isEmpty && password == confirmPassword
    }
    
    private var isFormValid: Bool {
        !fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        isEmailValid &&
        isPasswordMatch &&
        agreeToTerms
    }
    
    var body: some View {
        ZStack {
            // Weather-aware background
            WeatherBackground(theme: screenTheme)
                .ignoresSafeArea()
            
            GeometryReader { proxy in
                let safeTop = proxy.safeAreaInsets.top
                let safeBottom = proxy.safeAreaInsets.bottom
                let minVPadding: CGFloat = 16
                let contentTopPadding: CGFloat = 0
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 22) {
                        // Hidden NavigationLink to go back to Login after successful signup
                        NavigationLink(isActive: $navigateToLogin) {
                            LoginView()
                                .navigationBarBackButtonHidden(true)
                        } label: {
                            EmptyView()
                        }
                        .hidden()
                        
                        // Logo / Title
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
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.35), radius: 10)
                            
                            Text(AppConstants.UI.signupSubtitle)
                                .font(.caption2.weight(.light))
                                .foregroundColor(.white.opacity(0.65))
                                .tracking(1.1)
                        }
                        
                        // Liquid Glass Card
                        VStack(alignment: .leading, spacing: 16) {
                            
                            Text(AppConstants.UI.signupJoin)
                                .font(.headline.bold())
                                .foregroundColor(.white)
                            
                            Text(AppConstants.UI.signupDesc)
                                .font(.footnote)
                                .foregroundColor(.white.opacity(0.65))
                            
                            // Full Name
                            VStack(alignment: .leading, spacing: 6) {
                                Text(AppConstants.UI.fullNameTitle)
                                    .font(.caption.weight(.semibold))
                                    .foregroundColor(.white.opacity(0.7))
                                
                                HStack {
                                    Image(systemName: AppConstants.Symbols.personFill)
                                        .foregroundColor(.white.opacity(0.6))
                                    
                                    TextField(AppConstants.UI.fullNamePlaceholder, text: $fullName)
                                        .textInputAutocapitalization(.words)
                                        .disableAutocorrection(true)
                                        .foregroundColor(.white)
                                        .tint(.cyan)
                                }
                                .padding(12)
                                .glassEffect()
                            }
                            
                            // Email
                            VStack(alignment: .leading, spacing: 6) {
                                Text(AppConstants.UI.emailTitle)
                                    .font(.caption.weight(.semibold))
                                    .foregroundColor(.white.opacity(0.7))
                                
                                HStack {
                                    Image(systemName: AppConstants.Symbols.envelopeFill)
                                        .foregroundColor(.white.opacity(0.6))
                                    
                                    TextField(AppConstants.UI.emailPlaceholder, text: $email)
                                        .textInputAutocapitalization(.never)
                                        .keyboardType(.emailAddress)
                                        .foregroundColor(.white)
                                        .tint(.cyan)
                                }
                                .padding(12)
                                .glassEffect()
                            }
                            
                            // Password
                            VStack(alignment: .leading, spacing: 6) {
                                Text(AppConstants.UI.passwordTitle)
                                    .font(.caption.weight(.semibold))
                                    .foregroundColor(.white.opacity(0.7))
                                
                                HStack {
                                    Image(systemName: AppConstants.Symbols.lockFill)
                                        .foregroundColor(.white.opacity(0.6))
                                    
                                    SecureField(AppConstants.UI.passwordPlaceholder, text: $password)
                                        .foregroundColor(.white)
                                        .tint(.cyan)
                                }
                                .padding(12)
                                .glassEffect()
                            }
                            
                            // Confirm Password
                            VStack(alignment: .leading, spacing: 6) {
                                Text(AppConstants.UI.confirmPasswordTitle)
                                    .font(.caption.weight(.semibold))
                                    .foregroundColor(.white.opacity(0.7))
                                
                                HStack {
                                    Image(systemName: AppConstants.Symbols.lockCircleFill)
                                        .foregroundColor(.white.opacity(0.6))
                                    
                                    SecureField(AppConstants.UI.confirmPasswordPlaceholder, text: $confirmPassword)
                                        .foregroundColor(.white)
                                        .tint(.cyan)
                                }
                                .padding(12)
                                .glassEffect()
                            }
                            
                            // Terms and Conditions
                            Toggle(isOn: $agreeToTerms) {
                                HStack(alignment: .firstTextBaseline, spacing: 4) {
                                    Text(AppConstants.UI.termsPrefix)
                                        .foregroundColor(.white.opacity(0.8))
                                    Text(AppConstants.UI.terms)
                                        .foregroundColor(.cyan)
                                        .bold()
                                    Text(AppConstants.UI.and)
                                        .foregroundColor(.white.opacity(0.8))
                                    Text(AppConstants.UI.privacyPolicy)
                                        .foregroundColor(.cyan)
                                        .bold()
                                }
                                .font(.footnote)
                            }
                            .toggleStyle(.switch)
                            .tint(.cyan)
                            
                            // Error / Success messages
                            if let error = errorMessage {
                                Text(error)
                                    .font(.footnote)
                                    .foregroundColor(.red.opacity(0.95))
                                    .transition(.opacity)
                            }
                            if let success = successMessage {
                                Text(success)
                                    .font(.footnote.weight(.semibold))
                                    .foregroundColor(.green.opacity(0.95))
                                    .transition(.opacity)
                            }
                            
                            // Create Account Button
                            Button {
                                Task { await signUp() }
                            } label: {
                                HStack {
                                    if isSigningUp {
                                        ProgressView().tint(.white)
                                    } else {
                                        Text(AppConstants.UI.createAccount).bold()
                                        Image(systemName: AppConstants.Symbols.personBadgePlus)
                                    }
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(
                                    LinearGradient(
                                        colors: [
                                            Color.cyan.opacity(0.95),
                                            Color.blue
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                .shadow(color: .cyan.opacity(0.45), radius: 20, y: 8)
                            }
                            .disabled(!isFormValid || isSigningUp)
                            .opacity((isFormValid && !isSigningUp) ? 1.0 : 0.5)
                            
                            // Link back to Sign In
                            HStack(spacing: 6) {
                                Text(AppConstants.UI.alreadyHaveAccount)
                                    .foregroundColor(.white.opacity(0.7))
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
                        .padding(.horizontal, 16)
                        .frame(maxWidth: 600) // keep it nice on larger devices
                        
                        // Footer
                        HStack(spacing: 6) {
                            Image(systemName: AppConstants.Symbols.shieldFill)
                            Text(AppConstants.UI.secureBySupabase)
                                .font(.caption.weight(.semibold))
                        }
                        .foregroundColor(.white.opacity(0.55))
                        
                        Spacer(minLength: minVPadding)
                    }
                    .padding(.top, contentTopPadding)
                    .padding(.bottom, max(24, safeBottom + 8))
                }
                .scrollDismissesKeyboard(.interactively)
            }
        }
        .navigationBarBackButtonHidden(true)
        // Optional: present success as an alert that routes to Login
        .alert(AppConstants.UI.checkYourEmail, isPresented: .constant(successMessage != nil)) {
            Button(AppConstants.UI.ok) {
                successMessage = nil
                // After acknowledging, go to Login
                navigateToLogin = true
            }
        } message: {
            Text(successMessage ?? "")
        }
    }
    
    // MARK: - Supabase Signup
    @MainActor
    private func signUp() async {
        guard isFormValid, !isSigningUp else { return }
        errorMessage = nil
        successMessage = nil
        isSigningUp = true
        defer { isSigningUp = false }
        
        do {
            // Pass full name to user metadata so you can use it later.
            let metadata: [String: AnyJSON] = ["full_name": .string(fullName)]
            let response = try await container.authService.client.auth.signUp(
                email: email,
                password: password,
                data: metadata
            )
            
            // If email confirmations are enabled, session will be nil and a confirmation email is sent.
            if response.session == nil {
                HapticFeedback.success()
                successMessage = "\(AppConstants.UI.signupEmailSentPrefix)\(email)\(AppConstants.UI.signupEmailSentSuffix)"
            } else {
                // If confirmations are disabled, user is signed in immediately.
                HapticFeedback.success()
                successMessage = AppConstants.UI.signupSuccess
            }
        } catch {
            HapticFeedback.error()
            errorMessage = (error as NSError).localizedDescription
        }
    }
}

#Preview {
    NavigationStack {
        SignupView()
    }
}


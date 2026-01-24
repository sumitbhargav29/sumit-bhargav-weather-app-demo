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
                                    Image(systemName: "cloud.sun.fill")
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundStyle(LinearGradient(
                                            colors: [.yellow, .orange],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ))
                                }
                                .shadow(color: .black.opacity(0.35), radius: 16, y: 8)
                            
                            Text("Glasscast")
                                .font(.system(.title2, design: .rounded).weight(.bold))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.35), radius: 10)
                            
                            Text("CREATE YOUR ACCOUNT")
                                .font(.caption2.weight(.light))
                                .foregroundColor(.white.opacity(0.65))
                                .tracking(1.1)
                        }
                        
                        // Liquid Glass Card
                        VStack(alignment: .leading, spacing: 16) {
                            
                            Text("Join the portal")
                                .font(.headline.bold())
                                .foregroundColor(.white)
                            
                            Text("Set up your account to start exploring the weather")
                                .font(.footnote)
                                .foregroundColor(.white.opacity(0.65))
                            
                            // Full Name
                            VStack(alignment: .leading, spacing: 6) {
                                Text("FULL NAME")
                                    .font(.caption.weight(.semibold))
                                    .foregroundColor(.white.opacity(0.7))
                                
                                HStack {
                                    Image(systemName: "person.fill")
                                        .foregroundColor(.white.opacity(0.6))
                                    
                                    TextField("Jane Doe", text: $fullName)
                                        .textInputAutocapitalization(.words)
                                        .disableAutocorrection(true)
                                        .foregroundColor(.white)
                                        .tint(.cyan)
                                }
                                .padding(12)
                                //                                .liquidGlass(cornerRadius: 16, intensity: 0.25)
                                .glassEffect()
                            }
                            
                            // Email
                            VStack(alignment: .leading, spacing: 6) {
                                Text("EMAIL ADDRESS")
                                    .font(.caption.weight(.semibold))
                                    .foregroundColor(.white.opacity(0.7))
                                
                                HStack {
                                    Image(systemName: "envelope.fill")
                                        .foregroundColor(.white.opacity(0.6))
                                    
                                    TextField("name@weather.com", text: $email)
                                        .textInputAutocapitalization(.never)
                                        .keyboardType(.emailAddress)
                                        .foregroundColor(.white)
                                        .tint(.cyan)
                                }
                                .padding(12)
                                //                                .liquidGlass(cornerRadius: 16, intensity: 0.25)
                                .glassEffect()
                            }
                            
                            // Password
                            VStack(alignment: .leading, spacing: 6) {
                                Text("PASSWORD")
                                    .font(.caption.weight(.semibold))
                                    .foregroundColor(.white.opacity(0.7))
                                
                                HStack {
                                    Image(systemName: "lock.fill")
                                        .foregroundColor(.white.opacity(0.6))
                                    
                                    SecureField("Create a password", text: $password)
                                        .foregroundColor(.white)
                                        .tint(.cyan)
                                }
                                .padding(12)
                                //                                .liquidGlass(cornerRadius: 16, intensity: 0.25)
                                .glassEffect()
                            }
                            
                            // Confirm Password
                            VStack(alignment: .leading, spacing: 6) {
                                Text("CONFIRM PASSWORD")
                                    .font(.caption.weight(.semibold))
                                    .foregroundColor(.white.opacity(0.7))
                                
                                HStack {
                                    Image(systemName: "lock.circle.fill")
                                        .foregroundColor(.white.opacity(0.6))
                                    
                                    SecureField("Re-enter your password", text: $confirmPassword)
                                        .foregroundColor(.white)
                                        .tint(.cyan)
                                }
                                .padding(12)
                                //                                .liquidGlass(cornerRadius: 16, intensity: 0.25)
                                .glassEffect()
                            }
                            
                            // Terms and Conditions
                            Toggle(isOn: $agreeToTerms) {
                                HStack(alignment: .firstTextBaseline, spacing: 4) {
                                    Text("I agree to the")
                                        .foregroundColor(.white.opacity(0.8))
                                    Text("Terms")
                                        .foregroundColor(.cyan)
                                        .bold()
                                    Text("and")
                                        .foregroundColor(.white.opacity(0.8))
                                    Text("Privacy Policy")
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
                                        Text("Create Account").bold()
                                        Image(systemName: "person.badge.plus")
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
                                Text("Already have an account?")
                                    .foregroundColor(.white.opacity(0.7))
                                NavigationLink {
                                    LoginView()
                                        .navigationBarBackButtonHidden(true)
                                } label: {
                                    Text("Sign In")
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
                            Image(systemName: "shield.fill")
                            Text("SECURE BY SUPABASE")
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
        .alert("Check your email", isPresented: .constant(successMessage != nil)) {
            Button("OK") {
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
                successMessage = "We sent a confirmation link to \(email). Please verify to finish creating your account."
            } else {
                // If confirmations are disabled, user is signed in immediately.
                HapticFeedback.success()
                successMessage = "Account created successfully."
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

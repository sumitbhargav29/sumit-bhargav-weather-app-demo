//
//  LoginView.swift
//  Glasscast-A Minimal Weather App
//
//  Created by Sam's Mac on 20/01/26.
//

import SwiftUI
import Combine

struct LoginView: View {
    
    @State private var email = ""
    @State private var password = ""
    @State private var isSigningIn = false
    @State private var navigateToHome = false
    @FocusState private var focusedField: Field?
    @State private var showPassword: Bool = false
    @State private var errorMessage: String? = nil
    @State private var showErrorAlert: Bool = false
    
    // Debug probe output
    @State private var probeOutput: String? = nil
    @State private var showProbeAlert: Bool = false
    
    @Environment(\.container) private var container
    private var authService: AuthService { container.authService }
    
    // Pick the theme for this screen
    private let screenTheme: WeatherTheme = .coldSnowy
    
    private enum Field {
        case email
        case password
    }
    
    // Basic validation
    private var isEmailValid: Bool {
        email.contains("@") && email.contains(".")
    }
    private var isFormValid: Bool {
        isEmailValid && !password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        ZStack {
            // Weather-aware background
            WeatherBackground(theme: screenTheme)
                .ignoresSafeArea()
                .onTapGesture {
                    focusedField = nil
                }
            
            GeometryReader { proxy in
                let safeTop = proxy.safeAreaInsets.top
                let safeBottom = proxy.safeAreaInsets.bottom
                let contentTopPadding = max(24, safeTop + 8)
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 24) {
                        
                        // Invisible NavigationLink to HomeView, triggered by navigateToHome
                        NavigationLink(isActive: $navigateToHome) {
                            TabContainerView(homeModel: container.makeHomeViewModel())
                                .navigationBarBackButtonHidden(true)
                        } label: {
                            EmptyView()
                        }
                        .hidden()
                        
                        // Logo / Title
                        VStack(spacing: 10) {
                            Circle()
                                .fill(.ultraThinMaterial)
                                .frame(width: 44, height: 44)
                                .overlay {
                                    Image(systemName: AppConstants.Symbols.cloudSunRainFill)
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundStyle(LinearGradient(
                                            colors: [.cyan, .blue],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ))
                                }
                                .shadow(color: .black.opacity(0.35), radius: 16, y: 8)
                            
                            Text(AppConstants.UI.loginTitle)
                                .font(.system(.title2, design: .rounded).weight(.bold))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.35), radius: 10)
                            
                            Text(AppConstants.UI.loginSubtitle)
                                .font(.caption2.weight(.light))
                                .foregroundColor(.white.opacity(0.65))
                                .tracking(1.1)
                        }
                        
                        // Liquid Glass Card
                        VStack(alignment: .leading, spacing: 18) {
                            
                            Text(AppConstants.UI.loginWelcomeBack)
                                .font(.headline.bold())
                                .foregroundColor(.white)
                            
                            Text(AppConstants.UI.loginSecurelySignIn)
                                .font(.footnote)
                                .foregroundColor(.white.opacity(0.65))
                            
                            // Email
                            VStack(alignment: .leading, spacing: 6) {
                                Text(AppConstants.UI.emailTitle)
                                    .font(.caption.weight(.semibold))
                                    .foregroundColor(.white.opacity(0.7))
                                
                                HStack(spacing: 10) {
                                    Image(systemName: AppConstants.Symbols.envelopeFill)
                                        .foregroundColor(.white.opacity(0.6))
                                    
                                    TextField(AppConstants.UI.emailPlaceholder, text: $email)
                                        .textInputAutocapitalization(.never)
                                        .keyboardType(.emailAddress)
                                        .disableAutocorrection(true)
                                        .foregroundColor(.white)
                                        .tint(.cyan)
                                        .focused($focusedField, equals: .email)
                                        .submitLabel(.next)
                                        .onSubmit {
                                            focusedField = .password
                                        }
                                }
                                .padding(12)
                                .glassEffect()
                            }
                            
                            // Password
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text(AppConstants.UI.passwordTitle)
                                        .font(.caption.weight(.semibold))
                                        .foregroundColor(.white.opacity(0.7))
                                    
                                    Spacer()
                                    
                                    Button {
                                        // TODO: forgot password flow
                                    } label: {
                                        Text(AppConstants.UI.forgot)
                                            .font(.caption.bold())
                                            .foregroundColor(.cyan)
                                    }
                                    .buttonStyle(.plain)
                                }
                                
                                HStack(spacing: 10) {
                                    Image(systemName: AppConstants.Symbols.lockFill)
                                        .foregroundColor(.white.opacity(0.6))
                                    
                                    if showPassword {
                                        TextField(AppConstants.UI.yourPassword, text: $password)
                                            .foregroundColor(.white)
                                            .tint(.cyan)
                                            .focused($focusedField, equals: .password)
                                            .submitLabel(.go)
                                            .onSubmit {
                                                attemptSignIn()
                                            }
                                    } else {
                                        SecureField(AppConstants.UI.yourPassword, text: $password)
                                            .foregroundColor(.white)
                                            .tint(.cyan)
                                            .focused($focusedField, equals: .password)
                                            .submitLabel(.go)
                                            .onSubmit {
                                                attemptSignIn()
                                            }
                                    }
                                    
                                    Button {
                                        withAnimation(.easeInOut(duration: 0.15)) {
                                            showPassword.toggle()
                                        }
                                    } label: {
                                        Image(systemName: showPassword ? AppConstants.Symbols.eyeSlashFill : AppConstants.Symbols.eyeFillAlt)
                                            .foregroundColor(.white.opacity(0.75))
                                    }
                                    .buttonStyle(.plain)
                                }
                                .padding(12)
                                .glassEffect()
                            }
                            
                            // Sign In Button
                            Button {
                                attemptSignIn()
                            } label: {
                                HStack(spacing: 10) {
                                    if isSigningIn {
                                        ProgressView()
                                            .tint(.white)
                                    }
                                    Text(isSigningIn ? AppConstants.UI.signingIn : AppConstants.UI.signInAction).bold()
                                    if !isSigningIn {
                                        Image(systemName: AppConstants.Symbols.arrowRight)
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
                            .disabled(isSigningIn || !isFormValid)
                            .opacity((isSigningIn || !isFormValid) ? 0.55 : 1.0)
                            
                            // Navigate to Signup
                            HStack(spacing: 6) {
                                Text(AppConstants.UI.dontHaveAccount)
                                    .foregroundColor(.white.opacity(0.7))
                                NavigationLink {
                                    SignupView()
                                } label: {
                                    Text(AppConstants.UI.createAccountAction)
                                        .foregroundColor(.cyan)
                                        .bold()
                                }
                            }
                            .font(.footnote)
                            .frame(maxWidth: .infinity)
                            
#if DEBUG
                            // Debug: Raw REST probe button
                            Button {
                                Task {
                                    await runProbe()
                                }
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: AppConstants.Symbols.wrenchScrewdriverFill)
                                    Text(AppConstants.UI.debugSignInProbe)
                                }
                                .font(.footnote.bold())
                                .foregroundColor(.white)
                                .padding(.vertical, 10)
                                .frame(maxWidth: .infinity)
                                .background(Color.orange.opacity(0.25))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .padding(.top, 4)
#endif
                        }
                        .padding(18)
                        .liquidGlass(cornerRadius: 16, intensity: 0.25)
                        .padding(.horizontal, 16)
                        .frame(maxWidth: 600)
                        
                        
                        // Footer
                        HStack(spacing: 6) {
                            Image(systemName: AppConstants.Symbols.shieldFill)
                            Text(AppConstants.UI.secureBySupabase)
                                .font(.caption.weight(.semibold))
                        }
                        .foregroundColor(.white.opacity(0.55))
                        
                        Spacer(minLength: 16)
                    }
                    .padding(.top, contentTopPadding)
                    .padding(.bottom, max(24, safeBottom + 8))
                    .frame(minHeight: proxy.size.height) // centers content when plenty of space
                }
                .scrollDismissesKeyboard(.interactively)
            }
        }
        .navigationBarBackButtonHidden(true)
        .alert(AppConstants.UI.signInFailedTitle, isPresented: $showErrorAlert) {
            Button(AppConstants.UI.ok, role: .cancel) {
                showErrorAlert = false
            }
        } message: {
            Text(errorMessage ?? AppConstants.UI.unknownError)
        }
#if DEBUG
        .alert(AppConstants.UI.probeOutput, isPresented: $showProbeAlert) {
            Button(AppConstants.UI.ok, role: .cancel) { showProbeAlert = false }
        } message: {
            Text(probeOutput ?? AppConstants.UI.placeholderDash)
        }
#endif
    }
    
    private func attemptSignIn() {
        guard !isSigningIn else { return }
        // Trim inputs to avoid common mistakes
        email = email.trimmingCharacters(in: .whitespacesAndNewlines)
        password = password.trimmingCharacters(in: .whitespacesAndNewlines)
        guard isFormValid else {
            presentError(AppConstants.UI.pleaseEnterValidEmailPassword)
            return
        }
        
        errorMessage = nil
        showErrorAlert = false
        isSigningIn = true
        focusedField = nil
        
        Task {
            do {
                try await authService.signIn(email: email, password: password)
                // On success, navigate to the main app
                await MainActor.run {
                    HapticFeedback.success()
                    isSigningIn = false
                    navigateToHome = true
                }
            } catch {
                // Try fallback path
                do {
                    try await authService.signInFallback(email: email, password: password)
                    await MainActor.run {
                        HapticFeedback.success()
                        isSigningIn = false
                        navigateToHome = true
                    }
                } catch {
                    let friendly = friendlyAuthError(from: error)
                    await MainActor.run {
                        HapticFeedback.error()
                        isSigningIn = false
                        presentError(friendly)
                    }
                }
            }
        }
    }
    
#if DEBUG
    private func runProbe() async {
        let e = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let p = password.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !e.isEmpty, !p.isEmpty else {
            probeOutput = AppConstants.UI.enterEmailAndPasswordFirst
            showProbeAlert = true
            return
        }
        do {
            let output = try await SupabaseManager.shared.rawSignInProbe(email: e, password: p)
            probeOutput = output
        } catch {
            let ns = error as NSError
            probeOutput = "Probe failed: \(ns.localizedDescription)\n(domain=\(ns.domain) code=\(ns.code))"
        }
        showProbeAlert = true
    }
#endif
    
    // MARK: - Error presentation helpers
    
    private func presentError(_ message: String) {
        errorMessage = message
        showErrorAlert = true
    }
    
    // Map opaque/technical errors to friendly messages for users.
    private func friendlyAuthError(from error: Error) -> String {
        let ns = error as NSError
        let raw = ns.localizedDescription
        
        // Common opaque decoding error from SDK when response is unexpected
        if raw == AppConstants.UI.loginDecodingError1 ||
            raw == AppConstants.UI.loginDecodingError2 {
            return AppConstants.UI.loginDecodingFriendly
        }
        
        // Network offline / connectivity
        if ns.domain == NSURLErrorDomain {
            switch ns.code {
            case NSURLErrorNotConnectedToInternet:
                return AppConstants.UI.loginOffline
            case NSURLErrorTimedOut:
                return AppConstants.UI.loginTimeout
            default:
                break
            }
        }
        
        // Supabase / auth typical messages we can clarify a bit
        let lowered = raw.lowercased()
        if lowered.contains("invalid login") || lowered.contains("invalid email or password") {
            return AppConstants.UI.loginInvalidCredentials
        }
        if lowered.contains("email not confirmed") || lowered.contains("confirm") {
            return AppConstants.UI.loginConfirmEmail
        }
        
        // Fallback to the original message
        return raw
    }
}

#Preview {
    NavigationStack {
        LoginView()
    }
}


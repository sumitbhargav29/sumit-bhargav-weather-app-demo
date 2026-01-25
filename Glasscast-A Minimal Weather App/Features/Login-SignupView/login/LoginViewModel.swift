//
//  LoginViewModel.swift
//  Glasscast-A Minimal Weather App
//
//  Created by Sam's Mac on 25/01/26.
//

import Foundation
import Combine

@MainActor
final class LoginViewModel: ObservableObject {
    // Inputs
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var showPassword: Bool = false
    
    // UI State
    @Published private(set) var isSigningIn: Bool = false
    @Published var navigateToHome: Bool = false
    @Published var errorMessage: String? = nil
    @Published var showErrorAlert: Bool = false
    
    // Debug probe output
#if DEBUG
    @Published var probeOutput: String? = nil
    @Published var showProbeAlert: Bool = false
#endif
    
    // Dependencies
    private let auth: AuthService
    
    init(container: AppContainer) {
        self.auth = container.authService
    }
    
    // Validation
    var isEmailValid: Bool {
        email.contains("@") && email.contains(".")
    }
    var isFormValid: Bool {
        isEmailValid && !password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    func signInTapped() {
        guard !isSigningIn else { return }
        Task { await attemptSignIn() }
    }
    
    private func presentError(_ message: String) {
        errorMessage = message
        showErrorAlert = true
    }
    
    // MARK: - Sign In
    func attemptSignIn() async {
        email = email.trimmingCharacters(in: .whitespacesAndNewlines)
        password = password.trimmingCharacters(in: .whitespacesAndNewlines)
        guard isFormValid else {
            presentError(AppConstants.UI.pleaseEnterValidEmailPassword)
            return
        }
        
        errorMessage = nil
        showErrorAlert = false
        isSigningIn = true
        
        do {
            try await auth.signIn(email: email, password: password)
            HapticFeedback.success()
            isSigningIn = false
            navigateToHome = true
        } catch {
            do {
                try await auth.signInFallback(email: email, password: password)
                HapticFeedback.success()
                isSigningIn = false
                navigateToHome = true
            } catch {
                let friendly = friendlyAuthError(from: error)
                HapticFeedback.error()
                isSigningIn = false
                presentError(friendly)
            }
        }
    }
    
#if DEBUG
    func runProbe() async {
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


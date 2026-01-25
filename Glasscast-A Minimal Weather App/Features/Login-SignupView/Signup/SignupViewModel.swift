//
//  SignupViewModel.swift
//  Glasscast-A Minimal Weather App
//
//  Created by Sam's Mac on 25/01/26.
//

import Foundation
import Supabase
import Combine

@MainActor
final class SignupViewModel: ObservableObject {
    // Inputs
    @Published var fullName: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var agreeToTerms: Bool = false
    
    // UI State
    @Published private(set) var isSigningUp: Bool = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var successMessage: String?
    @Published var navigateToLogin: Bool = false
    
    // Dependencies
    private let auth: AuthService
    
    init(container: AppContainer) {
        self.auth = container.authService
    }
    
    // Validation
    var isEmailValid: Bool {
        email.contains("@") && email.contains(".")
    }
    var isPasswordMatch: Bool {
        !password.isEmpty && password == confirmPassword
    }
    var isFormValid: Bool {
        !fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        isEmailValid &&
        isPasswordMatch &&
        agreeToTerms
    }
    
    func createAccountTapped() {
        Task { await signUp() }
    }
    
    private func clearMessages() {
        errorMessage = nil
        successMessage = nil
    }
    
    func acknowledgeSuccess() {
        successMessage = nil
        navigateToLogin = true
    }
    
    // MARK: - Signup
    func signUp() async {
        guard isFormValid, !isSigningUp else { return }
        clearMessages()
        isSigningUp = true
        defer { isSigningUp = false }
        
        do {
            let metadata: [String: AnyJSON] = ["full_name": .string(fullName)]
            let response = try await auth.signUp(email: email, password: password, data: metadata)
            
            if response.session == nil {
                HapticFeedback.success()
                successMessage = "\(AppConstants.UI.signupEmailSentPrefix)\(email)\(AppConstants.UI.signupEmailSentSuffix)"
            } else {
                HapticFeedback.success()
                successMessage = AppConstants.UI.signupSuccess
            }
        } catch {
            HapticFeedback.error()
            errorMessage = (error as NSError).localizedDescription
        }
    }
}


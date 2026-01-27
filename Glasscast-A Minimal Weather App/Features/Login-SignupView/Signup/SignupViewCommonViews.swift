//
//  SignupCommonViews.swift
//  Glasscast-A Minimal Weather App
//
//  Created by Sam's Mac on 25/01/26.
//

import SwiftUI

struct LabeledIconTextField: View {
    let title: String
    let systemImage: String
    let placeholder: String
    @Binding var text: String
    var autocapitalization: TextInputAutocapitalization = .never
    var keyboard: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundColor(ColorSchemeManager.shared.adaptiveForegroundColor(opacity: 0.7))
            
            HStack {
                Image(systemName: systemImage)
                    .foregroundColor(ColorSchemeManager.shared.adaptiveForegroundColor(opacity: 0.6))
                
                TextField(placeholder, text: $text)
                    .textInputAutocapitalization(autocapitalization)
                    .keyboardType(keyboard)
                    .disableAutocorrection(true)
                    .foregroundColor(ColorSchemeManager.shared.adaptiveForegroundColor(opacity: 1.0))
                    .tint(.cyan)
            }
            .padding(12)
            .glassEffect()
        }
    }
}

struct LabeledIconSecureField: View {
    let title: String
    let systemImage: String
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundColor(ColorSchemeManager.shared.adaptiveForegroundColor(opacity: 0.7))
            
            HStack {
                Image(systemName: systemImage)
                    .foregroundColor(ColorSchemeManager.shared.adaptiveForegroundColor(opacity: 0.6))
                
                SecureField(placeholder, text: $text)
                    .foregroundColor(ColorSchemeManager.shared.adaptiveForegroundColor(opacity: 1.0))
                    .tint(.cyan)
            }
            .padding(12)
            .glassEffect()
        }
    }
}

struct TermsToggleRow: View {
    @Binding var isOn: Bool
    
    var body: some View {
        Toggle(isOn: $isOn) {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(AppConstants.UI.termsPrefix)
                    .foregroundColor(ColorSchemeManager.shared.adaptiveForegroundColor(opacity: 0.8))
                Text(AppConstants.UI.terms)
                    .foregroundColor(.cyan)
                    .bold()
                Text(AppConstants.UI.and)
                    .foregroundColor(ColorSchemeManager.shared.adaptiveForegroundColor(opacity: 0.8))
                Text(AppConstants.UI.privacyPolicy)
                    .foregroundColor(.cyan)
                    .bold()
            }
            .font(.footnote)
        }
        .accessibilityIdentifier("signup.terms")
        .toggleStyle(.switch)
        .tint(.cyan)
    }
}

struct AuthMessageView: View {
    let error: String?
    let success: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let error {
                Text(error)
                    .font(.footnote)
                    .foregroundColor(.red.opacity(0.95))
                    .transition(.opacity)
            }
            if let success {
                Text(success)
                    .font(.footnote.weight(.semibold))
                    .foregroundColor(.green.opacity(0.95))
                    .transition(.opacity)
            }
        }
    }
}

struct AuthPrimaryButton: View {
    let title: String
    let systemImage: String?
    let isLoading: Bool
    let isEnabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            HStack {
                if isLoading {
                    ProgressView().tint(.white)
                } else {
                    Text(title).bold()
                    if let systemImage {
                        Image(systemName: systemImage)
                    }
                }
            }
            .foregroundColor(.white) // Keep white for contrast against cyan/blue gradient
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
        .disabled(!isEnabled || isLoading)
        .opacity((isEnabled && !isLoading) ? 1.0 : 0.5)
    }
}

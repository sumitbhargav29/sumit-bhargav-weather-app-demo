//
//  LoginViewCommonViews.swift
//  Glasscast-A Minimal Weather App
//
//  Created by Sam's Mac on 25/01/26.
//

import SwiftUI

// Optional reusable header for auth screens (not used directly since your layout is inline in LoginView)
// Kept here for future reuse if you want to share with Signup.
struct AuthHeaderView: View {
    let symbol: String
    let gradient: LinearGradient
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 10) {
            Circle()
                .fill(.ultraThinMaterial)
                .frame(width: 44, height: 44)
                .overlay {
                    Image(systemName: symbol)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(gradient)
                }
                .shadow(color: .black.opacity(0.35), radius: 16, y: 8)
            
            Text(title)
                .font(.system(.title2, design: .rounded).weight(.bold))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.35), radius: 10)
            
            Text(subtitle)
                .font(.caption2.weight(.light))
                .foregroundColor(.white.opacity(0.65))
                .tracking(1.1)
        }
    }
}

// Password row with show/hide toggle and optional trailing action (e.g., FORGOT?)
struct LabeledIconPasswordWithToggle: View {
    let title: String
    let systemImage: String
    let placeholder: String
    @Binding var text: String
    @Binding var showPassword: Bool
    var forgotAction: (() -> Void)? = nil
    var submit: (() -> Void)? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.white.opacity(0.7))
                
                Spacer()
                
                if let forgotAction {
                    Button(action: forgotAction) {
                        Text(AppConstants.UI.forgot)
                            .font(.caption.bold())
                            .foregroundColor(.cyan)
                    }
                    .buttonStyle(.plain)
                }
            }
            
            HStack(spacing: 10) {
                Image(systemName: systemImage)
                    .foregroundColor(.white.opacity(0.6))
                
                if showPassword {
                    TextField(placeholder, text: $text)
                        .foregroundColor(.white)
                        .tint(.cyan)
                        .submitLabel(.go)
                        .onSubmit { submit?() }
                } else {
                    SecureField(placeholder, text: $text)
                        .foregroundColor(.white)
                        .tint(.cyan)
                        .submitLabel(.go)
                        .onSubmit { submit?() }
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
    }
}


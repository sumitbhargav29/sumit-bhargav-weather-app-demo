//
//  LoginView.swift
//  Glasscast-A Minimal Weather App
//
//  Created by Sam's Mac on 20/01/26.
//

import SwiftUI
import Combine

struct LoginView: View {
    @Environment(\.container) private var container
    
    // MVVM: ViewModel owns all logic/state
    @StateObject private var viewModel: LoginViewModel
    
    // Local focus management stays in the View (FocusState requires View property wrapper)
    @FocusState private var focusedField: Field?
    private enum Field: Hashable {
        case email
        case password
    }
    
    // Pick the theme for this screen
    private let screenTheme: WeatherTheme = .coldSnowy
    
    // Adaptive foreground color helper (mirrors HomeView)
    private func adaptiveForeground(opacity: Double = 1.0) -> Color {
        ColorSchemeManager.shared.adaptiveForegroundColor(opacity: opacity)
    }
    
    init(container: AppContainer? = nil) {
        let resolved = container ?? AppContainer()
        _viewModel = StateObject(wrappedValue: LoginViewModel(container: resolved))
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
                        NavigationLink(isActive: $viewModel.navigateToHome) {
                            TabContainerView(homeModel: container.makeHomeViewModel())
                                .navigationBarBackButtonHidden(true)
                        } label: {
                            EmptyView()
                        }
                        .hidden()
                        
                        // Header (kept identical except adaptive text colors)
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
                                .foregroundColor(adaptiveForeground())
                                .shadow(color: .black.opacity(0.35), radius: 10)
                            
                            Text(AppConstants.UI.loginSubtitle)
                                .font(.caption2.weight(.light))
                                .foregroundColor(adaptiveForeground(opacity: 0.65))
                                .tracking(1.1)
                        }
                        
                        // Liquid Glass Card
                        VStack(alignment: .leading, spacing: 18) {
                            
                            Text(AppConstants.UI.loginWelcomeBack)
                                .font(.headline.bold())
                                .foregroundColor(adaptiveForeground())
                            
                            Text(AppConstants.UI.loginSecurelySignIn)
                                .font(.footnote)
                                .foregroundColor(adaptiveForeground(opacity: 0.65))
                            
                            // Email
                            VStack(alignment: .leading, spacing: 6) {
                                Text(AppConstants.UI.emailTitle)
                                    .font(.caption.weight(.semibold))
                                    .foregroundColor(adaptiveForeground(opacity: 0.7))
                                
                                HStack(spacing: 10) {
                                    Image(systemName: AppConstants.Symbols.envelopeFill)
                                        .foregroundColor(adaptiveForeground(opacity: 0.6))
                                    
                                    TextField(AppConstants.UI.emailPlaceholder, text: $viewModel.email)
                                        .textInputAutocapitalization(.never)
                                        .keyboardType(.emailAddress)
                                        .disableAutocorrection(true)
                                        .foregroundColor(adaptiveForeground())
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
                                        .foregroundColor(adaptiveForeground(opacity: 0.7))
                                    
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
                                        .foregroundColor(adaptiveForeground(opacity: 0.6))
                                    
                                    if viewModel.showPassword {
                                        TextField(AppConstants.UI.yourPassword, text: $viewModel.password)
                                            .foregroundColor(adaptiveForeground())
                                            .tint(.cyan)
                                            .focused($focusedField, equals: .password)
                                            .submitLabel(.go)
                                            .onSubmit {
                                                viewModel.signInTapped()
                                            }
                                    } else {
                                        SecureField(AppConstants.UI.yourPassword, text: $viewModel.password)
                                            .foregroundColor(adaptiveForeground())
                                            .tint(.cyan)
                                            .focused($focusedField, equals: .password)
                                            .submitLabel(.go)
                                            .onSubmit {
                                                viewModel.signInTapped()
                                            }
                                    }
                                    
                                    Button {
                                        withAnimation(.easeInOut(duration: 0.15)) {
                                            viewModel.showPassword.toggle()
                                        }
                                    } label: {
                                        Image(systemName: viewModel.showPassword ? AppConstants.Symbols.eyeSlashFill : AppConstants.Symbols.eyeFillAlt)
                                            .foregroundColor(adaptiveForeground(opacity: 0.75))
                                    }
                                    .buttonStyle(.plain)
                                }
                                .padding(12)
                                .glassEffect()
                            }
                            
                            // Sign In Button
                            Button {
                                viewModel.signInTapped()
                            } label: {
                                HStack(spacing: 10) {
                                    if viewModel.isSigningIn {
                                        ProgressView()
                                            .tint(.white)
                                    }
                                    Text(viewModel.isSigningIn ? AppConstants.UI.signingIn : AppConstants.UI.signInAction).bold()
                                    if !viewModel.isSigningIn {
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
                            .disabled(viewModel.isSigningIn || !viewModel.isFormValid)
                            .opacity((viewModel.isSigningIn || !viewModel.isFormValid) ? 0.55 : 1.0)
                            
                            // Navigate to Signup
                            HStack(spacing: 6) {
                                Text(AppConstants.UI.dontHaveAccount)
                                    .foregroundColor(adaptiveForeground(opacity: 0.7))
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
                            //                            Button {
                            //                                Task {
                            //                                    await viewModel.runProbe()
                            //                                }
                            //                            } label: {
                            //                                HStack(spacing: 8) {
                            //                                    Image(systemName: AppConstants.Symbols.wrenchScrewdriverFill)
                            //                                    Text(AppConstants.UI.debugSignInProbe)
                            //                                }
                            //                                .font(.footnote.bold())
                            //                                .foregroundColor(adaptiveForeground())
                            //                                .padding(.vertical, 10)
                            //                                .frame(maxWidth: .infinity)
                            //                                .background(Color.orange.opacity(0.25))
                            //                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            //                            }
                            //                            .padding(.top, 4)
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
                        .foregroundColor(adaptiveForeground(opacity: 0.55))
                        
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
        .alert(AppConstants.UI.signInFailedTitle, isPresented: $viewModel.showErrorAlert) {
            Button(AppConstants.UI.ok, role: .cancel) {
                viewModel.showErrorAlert = false
            }
        } message: {
            Text(viewModel.errorMessage ?? AppConstants.UI.unknownError)
        }
#if DEBUG
        //        .alert(AppConstants.UI.probeOutput, isPresented: $viewModel.showProbeAlert) {
        //            Button(AppConstants.UI.ok, role: .cancel) { viewModel.showProbeAlert = false }
        //        } message: {
        //            Text(viewModel.probeOutput ?? AppConstants.UI.placeholderDash)
        //        }
#endif
    }
}

#Preview {
    NavigationStack {
        LoginView()
    }
}

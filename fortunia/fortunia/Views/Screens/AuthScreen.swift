//
//  AuthScreen.swift
//  fortunia
//
//  Created by Can Soğancı on 24.10.2025.
//

import SwiftUI
import AuthenticationServices

// MARK: - Auth Screen
struct AuthScreen: View {
    @StateObject private var viewModel = AuthViewModel()
    @State private var showingSignUp = false
    @State private var showingSignIn = false
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isSignUpMode = false
    
    let onAuthComplete: () -> Void
    
    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(
                colors: [
                    Color.backgroundPrimary,
                    Color.primary.opacity(0.05)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: Spacing.xxl) {
                    Spacer()
                    
                    // Header Section
                    VStack(spacing: Spacing.lg) {
                        // App Icon/Logo
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.primary, .accent],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 80, height: 80)
                            .overlay(
                                Image(systemName: "sparkles")
                                    .font(.system(size: 32, weight: .medium))
                                    .foregroundColor(.white)
                            )
                        
                        // Welcome Text
                        VStack(spacing: Spacing.sm) {
                            Text(LocalizedStringKey("auth_welcome_title")) // localized
                                .font(AppTypography.heading1)
                                .foregroundColor(.textPrimary)
                                .multilineTextAlignment(.center)
                            
                            Text(LocalizedStringKey("auth_welcome_subtitle")) // localized
                                .font(AppTypography.bodyMedium)
                                .foregroundColor(.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    
                    // Auth Options
                    VStack(spacing: Spacing.lg) {
                        // Apple Sign In Button
                        SignInWithAppleButton(
                            onRequest: { request in
                                request.requestedScopes = [.fullName, .email]
                            },
                            onCompletion: { result in
                                handleAppleSignIn(result)
                            }
                        )
                        .signInWithAppleButtonStyle(.black)
                        .frame(height: 56)
                        .cornerRadius(CornerRadius.md)
                        
                        // Email/Password Button
                        PrimaryButton(
                            title: NSLocalizedString("auth_continue_with_email", comment: "Continue with Email button"), // localized
                            action: {
                                showingSignUp = true
                            }
                        )
                        
                        // Guest Mode Button
                        SecondaryButton(
                            title: NSLocalizedString("auth_not_now", comment: "Not Now button"), // localized
                            action: {
                                continueAsGuest()
                            }
                        )
                    }
                    
                    Spacer()
                    
                    // Footer
                    VStack(spacing: Spacing.sm) {
                        Text(LocalizedStringKey("auth_by_continuing")) // localized
                            .font(AppTypography.caption)
                            .foregroundColor(.textSecondary)
                        
                        HStack(spacing: Spacing.xs) {
                            Button(NSLocalizedString("auth_terms", comment: "Terms of Service")) { // localized
                                // Open terms
                            }
                            .font(AppTypography.caption)
                            .foregroundColor(.primary)
                            
                            Text(LocalizedStringKey("auth_and")) // localized
                                .font(AppTypography.caption)
                                .foregroundColor(.textSecondary)
                            
                            Button(NSLocalizedString("auth_privacy", comment: "Privacy Policy")) { // localized
                                // Open privacy
                            }
                            .font(AppTypography.caption)
                            .foregroundColor(.primary)
                        }
                    }
                }
                .padding(.horizontal, Spacing.xl)
                .padding(.vertical, Spacing.xxl)
            }
            
            // Loading Overlay
            if viewModel.isLoading {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                MysticalLoadingView()
            }
        }
        .sheet(isPresented: $showingSignUp) {
            EmailAuthSheet(
                isSignUpMode: $isSignUpMode,
                email: $email,
                password: $password,
                confirmPassword: $confirmPassword,
                onComplete: handleEmailAuth
            )
        }
        .alert(NSLocalizedString("auth_error", comment: "Error alert title"), isPresented: $viewModel.isErrorPresented) { // localized
            Button(NSLocalizedString("auth_ok", comment: "OK button")) { // localized
                viewModel.clearError()
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
    
    // MARK: - Auth Handlers
    private func handleAppleSignIn(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            // Handle successful Apple Sign In
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                let userIdentifier = appleIDCredential.user
                let fullName = appleIDCredential.fullName
                let email = appleIDCredential.email
                
                // TODO: Implement Apple Sign In with Supabase
                print("Apple Sign In successful: \(userIdentifier)")
                onAuthComplete()
            }
        case .failure(let error):
            viewModel.handleError(error)
        }
    }
    
    private func handleEmailAuth() {
        if isSignUpMode {
            // Sign Up
            Task {
                await viewModel.signUp(email: email, password: password)
                if !viewModel.isErrorPresented {
                    onAuthComplete()
                }
            }
        } else {
            // Sign In
            Task {
                await viewModel.signIn(email: email, password: password)
                if !viewModel.isErrorPresented {
                    onAuthComplete()
                }
            }
        }
    }
    
    private func continueAsGuest() {
        Task {
            await viewModel.continueAsGuest()
            await MainActor.run {
                onAuthComplete()
            }
        }
    }
}

// MARK: - Email Auth Sheet
struct EmailAuthSheet: View {
    @Binding var isSignUpMode: Bool
    @Binding var email: String
    @Binding var password: String
    @Binding var confirmPassword: String
    @Environment(\.dismiss) private var dismiss
    let onComplete: () -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: Spacing.lg) {
                // Header
                VStack(spacing: Spacing.sm) {
                    Text(isSignUpMode ? LocalizedStringKey("auth_create_account") : LocalizedStringKey("auth_sign_in")) // localized
                        .font(AppTypography.heading2)
                        .foregroundColor(.textPrimary)
                    
                    Text(isSignUpMode ? LocalizedStringKey("auth_join_mystical") : LocalizedStringKey("auth_welcome_back")) // localized
                        .font(AppTypography.bodyMedium)
                        .foregroundColor(.textSecondary)
                }
                .padding(.top, Spacing.lg)
                
                // Form
                VStack(spacing: Spacing.md) {
                    // Email Field
                    AppTextField(
                        placeholder: NSLocalizedString("auth_email", comment: "Email placeholder"), // localized
                        text: $email,
                        icon: "envelope"
                    )
                    
                    // Password Field
                    AppTextField(
                        placeholder: NSLocalizedString("auth_password", comment: "Password placeholder"), // localized
                        text: $password,
                        icon: "lock"
                    )
                    
                    // Confirm Password (Sign Up only)
                    if isSignUpMode {
                        AppTextField(
                            placeholder: NSLocalizedString("auth_confirm_password", comment: "Confirm Password placeholder"), // localized
                            text: $confirmPassword,
                            icon: "lock"
                        )
                    }
                }
                
                // Action Button
                PrimaryButton(
                    title: isSignUpMode ? NSLocalizedString("auth_create_account", comment: "Create Account") : NSLocalizedString("auth_sign_in", comment: "Sign In"), // localized
                    action: onComplete
                )
                .disabled(!isFormValid)
                
                // Toggle Mode
                Button(action: {
                    isSignUpMode.toggle()
                    clearForm()
                }) {
                    HStack {
                        Text(isSignUpMode ? LocalizedStringKey("auth_already_have_account") : LocalizedStringKey("auth_dont_have_account")) // localized
                            .font(AppTypography.bodySmall)
                            .foregroundColor(.textSecondary)
                        
                        Text(isSignUpMode ? LocalizedStringKey("auth_sign_in") : LocalizedStringKey("auth_sign_up")) // localized
                            .font(AppTypography.bodySmall)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, Spacing.xl)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(NSLocalizedString("auth_cancel", comment: "Cancel button")) { // localized
                        dismiss()
                    }
                    .foregroundColor(.primary)
                }
            }
        }
    }
    
    private var isFormValid: Bool {
        if isSignUpMode {
            return !email.isEmpty && 
                   !password.isEmpty && 
                   !confirmPassword.isEmpty && 
                   password == confirmPassword &&
                   password.count >= 8
        } else {
            return !email.isEmpty && !password.isEmpty
        }
    }
    
    private func clearForm() {
        email = ""
        password = ""
        confirmPassword = ""
    }
}

// MARK: - App Text Field
struct AppTextField: View {
    let placeholder: String
    @Binding var text: String
    var icon: String? = nil
    var isSecure: Bool = false
    
    var body: some View {
        HStack(spacing: Spacing.sm) {
            if let icon = icon {
                Image(systemName: icon)
                    .foregroundColor(.textSecondary)
                    .frame(width: 24, height: 24)
            }
            
            if isSecure {
                SecureField(placeholder, text: $text)
                    .font(AppTypography.bodyMedium)
                    .foregroundColor(.textPrimary)
            } else {
                TextField(placeholder, text: $text)
                    .font(AppTypography.bodyMedium)
                    .foregroundColor(.textPrimary)
                    .keyboardType(placeholder.lowercased().contains("email") ? .emailAddress : .default)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }
        }
        .padding(Spacing.md)
        .background(Color.surface)
        .cornerRadius(CornerRadius.md)
        .overlay(
            RoundedRectangle(cornerRadius: CornerRadius.md)
                .stroke(Color.primary.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Preview
struct AuthScreen_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AuthScreen(onAuthComplete: {})
                .preferredColorScheme(.light)
                .previewDisplayName(NSLocalizedString("preview_light_mode", comment: "Light mode preview"))
            
            AuthScreen(onAuthComplete: {})
                .preferredColorScheme(.dark)
                .previewDisplayName(NSLocalizedString("preview_dark_mode", comment: "Dark mode preview"))
        }
    }
}

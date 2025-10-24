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
                            Text("Welcome to Fortunia")
                                .font(AppTypography.heading1)
                                .foregroundColor(.textPrimary)
                                .multilineTextAlignment(.center)
                            
                            Text("Discover your fortune through ancient wisdom")
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
                            title: "Continue with Email",
                            action: {
                                showingSignUp = true
                            }
                        )
                        
                        // Guest Mode Button
                        SecondaryButton(
                            title: "Not Now",
                            action: {
                                continueAsGuest()
                            }
                        )
                    }
                    
                    Spacer()
                    
                    // Footer
                    VStack(spacing: Spacing.sm) {
                        Text("By continuing, you agree to our")
                            .font(AppTypography.caption)
                            .foregroundColor(.textSecondary)
                        
                        HStack(spacing: Spacing.xs) {
                            Button("Terms of Service") {
                                // Open terms
                            }
                            .font(AppTypography.caption)
                            .foregroundColor(.primary)
                            
                            Text("and")
                                .font(AppTypography.caption)
                                .foregroundColor(.textSecondary)
                            
                            Button("Privacy Policy") {
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
        .alert("Error", isPresented: $viewModel.isErrorPresented) {
            Button("OK") {
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
        viewModel.continueAsGuest()
        onAuthComplete()
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
                    Text(isSignUpMode ? "Create Account" : "Sign In")
                        .font(AppTypography.heading2)
                        .foregroundColor(.textPrimary)
                    
                    Text(isSignUpMode ? "Join the mystical journey" : "Welcome back")
                        .font(AppTypography.bodyMedium)
                        .foregroundColor(.textSecondary)
                }
                .padding(.top, Spacing.lg)
                
                // Form
                VStack(spacing: Spacing.md) {
                    // Email Field
                    AppTextField(
                        placeholder: "Email",
                        text: $email,
                        icon: "envelope"
                    )
                    
                    // Password Field
                    AppTextField(
                        placeholder: "Password",
                        text: $password,
                        icon: "lock"
                    )
                    
                    // Confirm Password (Sign Up only)
                    if isSignUpMode {
                        AppTextField(
                            placeholder: "Confirm Password",
                            text: $confirmPassword,
                            icon: "lock"
                        )
                    }
                }
                
                // Action Button
                PrimaryButton(
                    title: isSignUpMode ? "Create Account" : "Sign In",
                    action: onComplete
                )
                .disabled(!isFormValid)
                
                // Toggle Mode
                Button(action: {
                    isSignUpMode.toggle()
                    clearForm()
                }) {
                    HStack {
                        Text(isSignUpMode ? "Already have an account?" : "Don't have an account?")
                            .font(AppTypography.bodySmall)
                            .foregroundColor(.textSecondary)
                        
                        Text(isSignUpMode ? "Sign In" : "Sign Up")
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
                    Button("Cancel") {
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
                .previewDisplayName("Light Mode")
            
            AuthScreen(onAuthComplete: {})
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark Mode")
        }
    }
}

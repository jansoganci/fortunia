//
//  AuthViewModel.swift
//  fortunia
//
//  Created by Can Soğancı on 24.10.2025.
//

import Foundation
import SwiftUI
import FirebaseAnalytics

// AuthViewModel now uses the modular AuthService (Dec 2025)
// Handles signup, signin, and signout with Supabase-backed authentication

// MARK: - Auth View Model
class AuthViewModel: BaseViewModel {
    
    // MARK: - Auth State
    @Published var isAuthenticated = false
    
    // MARK: - Auth Methods
    func signUp(email: String, password: String) async {
        isLoading = true
        
        do {
            let response = try await AuthService.shared.signUp(email: email, password: password)
            await MainActor.run {
                self.isAuthenticated = true
                self.errorMessage = nil
                self.isLoading = false
            }
            
            // Refresh premium status from backend after signup
            if let userId = AuthService.shared.currentUserId {
                await QuotaManager.shared.refreshPremiumStatus(for: userId)
            }
            
            // Analytics: Track signup completion
            AnalyticsService.shared.logEvent(
                AnalyticsEvents.SignupCompleted.name,
                parameters: AnalyticsEvents.SignupCompleted.parameters(method: .email)
            )
            
            LocalizedDebugLogger.shared.logAuth("signUp", email: response.user.email, success: true)
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isAuthenticated = false
                self.isLoading = false
            }
            SupabaseService.shared.logAuthError(error, action: "signUp", email: email)
            
            // Analytics: Track signup error
            AnalyticsService.shared.logEvent(
                AnalyticsEvents.ErrorOccurred.name,
                parameters: AnalyticsEvents.ErrorOccurred.parameters(
                    errorType: "signup_error",
                    errorMessage: error.localizedDescription,
                    context: "email_signup"
                )
            )
        }
    }
    
    func signIn(email: String, password: String) async {
        isLoading = true
        
        do {
            let session = try await AuthService.shared.signIn(email: email, password: password)
            await MainActor.run {
                self.isAuthenticated = true
                self.errorMessage = nil
                self.isLoading = false
            }
            
            // Refresh premium status from backend after signin
            if let userId = AuthService.shared.currentUserId {
                await QuotaManager.shared.refreshPremiumStatus(for: userId)
            }
            
            // Analytics: Track app open (user session start)
            AnalyticsService.shared.logEvent(
                AnalyticsEvents.AppOpen.name,
                parameters: AnalyticsEvents.AppOpen.parameters(sessionID: UUID().uuidString)
            )
            
            LocalizedDebugLogger.shared.logAuth("signIn", email: session.user.email, success: true)
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isAuthenticated = false
                self.isLoading = false
            }
            SupabaseService.shared.logAuthError(error, action: "signIn", email: email)
            
            // Analytics: Track signin error
            AnalyticsService.shared.logEvent(
                AnalyticsEvents.ErrorOccurred.name,
                parameters: AnalyticsEvents.ErrorOccurred.parameters(
                    errorType: "signin_error",
                    errorMessage: error.localizedDescription,
                    context: "email_signin"
                )
            )
        }
    }
    
    func signOut() async {
        do {
            try await AuthService.shared.signOut()
            await MainActor.run {
                self.isAuthenticated = false
                self.errorMessage = nil
            }
            
            // Analytics: Track session end
            AnalyticsService.shared.logEvent(
                AnalyticsEvents.SessionEnd.name,
                parameters: AnalyticsEvents.SessionEnd.parameters(duration: 0.0, sessionID: UUID().uuidString)
            )
            
            LocalizedDebugLogger.shared.logAuth("signOut", success: true)
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
            }
            SupabaseService.shared.logAuthError(error, action: "signOut", email: nil)
            
            // Analytics: Track signout error
            AnalyticsService.shared.logEvent(
                AnalyticsEvents.ErrorOccurred.name,
                parameters: AnalyticsEvents.ErrorOccurred.parameters(
                    errorType: "signout_error",
                    errorMessage: error.localizedDescription,
                    context: "user_signout"
                )
            )
        }
    }
    
    func continueAsGuest() async {
        // Set guest mode - user can access app without authentication
        isAuthenticated = false
        errorMessage = nil
        
        // Generate device ID for quota tracking
        let deviceID = DeviceIDManager.shared.getOrCreateDeviceID()
        DebugLogger.shared.quota("🔵 [GUEST] Device ID for guest: \(deviceID)")
        
        // Create guest user in database
        do {
            let guestUserId = try await AuthService.shared.createGuestUser(deviceId: deviceID)
            DebugLogger.shared.quota("✅ [GUEST] Guest user created: \(guestUserId)")
            
            // Store guest user_id for quota tracking
            UserDefaults.standard.set(guestUserId.uuidString, forKey: "guest_user_id")
            
        } catch {
            DebugLogger.shared.error("❌ [GUEST] Failed to create guest user: \(error)")
            errorMessage = error.localizedDescription
        }
        
        // Analytics: Track guest signup completion
        AnalyticsService.shared.logEvent(
            AnalyticsEvents.SignupCompleted.name,
            parameters: AnalyticsEvents.SignupCompleted.parameters(method: .guest)
        )
        
        // Analytics: Track app open for guest session
        AnalyticsService.shared.logEvent(
            AnalyticsEvents.AppOpen.name,
            parameters: AnalyticsEvents.AppOpen.parameters(sessionID: UUID().uuidString)
        )
        
        LocalizedDebugLogger.shared.logAuth("guest", success: true)
    }
    
    // MARK: - Error Handling
    override func handleError(_ error: Error) {
        errorMessage = error.localizedDescription
        isErrorPresented = true
        isLoading = false
    }
    
    override func clearError() {
        errorMessage = nil
        isErrorPresented = false
    }
}

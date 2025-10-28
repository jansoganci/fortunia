//
//  AuthService.swift
//  fortunia
//
//  Created by Cursor AI on December 19, 2024
//

import Foundation
import Supabase

// MARK: - Auth Service
/// AuthService handles all user authentication operations in the Fortunia app.
/// 
/// This service provides:
/// - User registration (sign up)
/// - User authentication (sign in)
/// - User session management (sign out)
/// - Password reset functionality
/// - Session refresh capabilities
/// - Account deletion
/// - Error logging and debugging for auth operations
///
/// Dependencies:
/// - SupabaseService.shared for Supabase client access
/// - SupabaseService.shared for error logging
///
/// Usage:
/// ```swift
/// let authService = AuthService.shared
/// let response = try await authService.signUp(email: "user@example.com", password: "password123")
/// ```
///
/// - Note: This service uses a singleton pattern and should be accessed via `AuthService.shared`
/// - Important: All methods are async and should be called with proper error handling
class AuthService: ObservableObject {
    
    // MARK: - Singleton
    /// Shared instance of AuthService
    /// 
    /// Use this singleton instance throughout the app to access authentication functionality.
    /// The singleton pattern ensures consistent state management across the app.
    static let shared = AuthService()
    
    // MARK: - Private Initializer
    /// Private initializer for singleton pattern
    private init() {}
    
    // MARK: - Current User Properties
    
    /// Get the current user's ID from the active session
    /// - Returns: User ID if authenticated, nil otherwise
    var currentUserId: String? {
        guard let supabase = SupabaseService.shared.supabase else {
            print("🧩 [AUTH] currentUserId: Supabase client not available")
            return nil
        }
        
        guard let currentUser = supabase.auth.currentUser else {
            print("🧩 [AUTH] currentUserId: No authenticated user")
            
            // Check for guest user_id
            let guestUserId = UserDefaults.standard.string(forKey: "guest_user_id")
            print("🧩 [AUTH] currentUserId: Guest user_id from UserDefaults: \(guestUserId ?? "nil")")
            return guestUserId
        }
        
        let userId = currentUser.id.uuidString
        print("🧩 [AUTH] currentUserId: Authenticated user ID: \(userId)")
        return userId
    }
    
    // MARK: - Authentication Methods
    
    /// Sign up a new user with email and password
    /// - Parameters:
    ///   - email: User's email address
    ///   - password: User's password (minimum 8 characters)
    /// - Returns: AuthResponse containing user session and metadata
    /// - Throws: SupabaseAuthError for various authentication failures
    func signUp(email: String, password: String) async throws -> AuthResponse {
        LocalizedDebugLogger.shared.logAuth("signUp", email: email, success: false)
        
        do {
            // Use SupabaseService's client for authentication
            guard let supabase = SupabaseService.shared.supabase else {
                throw SupabaseError.invalidURL
            }
            let response = try await supabase.auth.signUp(
                email: email,
                password: password
            )
            
            LocalizedDebugLogger.shared.logAuth("signUp", email: email, success: true)
            return response
        } catch {
            LocalizedDebugLogger.shared.logAuth("signUp", email: email, success: false)
            // Log detailed error information for debugging
            SupabaseService.shared.logAuthError(error, action: "signUp", email: email)
            throw error
        }
    }
    
    /// Sign in an existing user with email and password
    /// - Parameters:
    ///   - email: User's email address
    ///   - password: User's password
    /// - Returns: Session containing user session and metadata
    /// - Throws: SupabaseAuthError for invalid credentials or network issues
    func signIn(email: String, password: String) async throws -> Session {
        LocalizedDebugLogger.shared.logAuth("signIn", email: email, success: false)
        
        do {
            // Use SupabaseService's client for authentication
            guard let supabase = SupabaseService.shared.supabase else {
                throw SupabaseError.invalidURL
            }
            let session = try await supabase.auth.signIn(
                email: email,
                password: password
            )
            
            LocalizedDebugLogger.shared.logAuth("signIn", email: email, success: true)
            return session
        } catch {
            LocalizedDebugLogger.shared.logAuth("signIn", email: email, success: false)
            // Log detailed error information for debugging
            SupabaseService.shared.logAuthError(error, action: "signIn", email: email)
            throw error
        }
    }
    
    /// Sign out the current user
    /// - Throws: SupabaseAuthError if sign out fails
    func signOut() async throws {
        LocalizedDebugLogger.shared.logAuth("signOut", success: false)
        
        do {
            // Use SupabaseService's client for authentication
            guard let supabase = SupabaseService.shared.supabase else {
                throw SupabaseError.invalidURL
            }
            try await supabase.auth.signOut()
            LocalizedDebugLogger.shared.logAuth("signOut", success: true)
        } catch {
            LocalizedDebugLogger.shared.logAuth("signOut", success: false)
            // Log detailed error information for debugging
            SupabaseService.shared.logAuthError(error, action: "signOut", email: nil)
            throw error
        }
    }
    
    /// Reset password for a user by sending a reset email
    /// - Parameter email: User's email address
    /// - Throws: SupabaseAuthError if reset fails
    func resetPassword(email: String) async throws {
        LocalizedDebugLogger.shared.logAuth("resetPassword", email: email, success: false)
        
        do {
            guard let supabase = SupabaseService.shared.supabase else {
                throw SupabaseError.invalidURL
            }
            try await supabase.auth.resetPasswordForEmail(email)
            LocalizedDebugLogger.shared.logAuth("resetPassword", email: email, success: true)
        } catch {
            LocalizedDebugLogger.shared.logAuth("resetPassword", email: email, success: false)
            // Log detailed error information for debugging
            SupabaseService.shared.logAuthError(error, action: "resetPassword", email: email)
            throw error
        }
    }
    
    /// Refresh the current user's session
    /// - Returns: Updated Session with fresh tokens
    /// - Throws: SupabaseAuthError if refresh fails
    func refreshSession() async throws -> Session {
        LocalizedDebugLogger.shared.logAuth("refreshSession", success: false)
        
        do {
            guard let supabase = SupabaseService.shared.supabase else {
                throw SupabaseError.invalidURL
            }
            let session = try await supabase.auth.refreshSession()
            LocalizedDebugLogger.shared.logAuth("refreshSession", success: true)
            return session
        } catch {
            LocalizedDebugLogger.shared.logAuth("refreshSession", success: false)
            // Log detailed error information for debugging
            SupabaseService.shared.logAuthError(error, action: "refreshSession", email: nil)
            throw error
        }
    }
    
    /// Create a guest user with device_id
    /// - Parameter deviceId: The device identifier from DeviceIDManager
    /// - Returns: The UUID of the created or existing guest user
    /// - Throws: SupabaseError for database failures
    func createGuestUser(deviceId: String) async throws -> UUID {
        LocalizedDebugLogger.shared.logAuth("createGuestUser", success: false)
        
        do {
            guard let supabase = SupabaseService.shared.supabase else {
                throw SupabaseError.invalidURL
            }
            
            // Call the create_guest_user RPC function
            let userId: String = try await supabase.rpc(
                "create_guest_user",
                params: ["p_device_id": deviceId]
            ).execute().value
            
            LocalizedDebugLogger.shared.logAuth("createGuestUser", success: true)
            
            guard let uuid = UUID(uuidString: userId) else {
                throw SupabaseError.authenticationFailed
            }
            
            return uuid
            
        } catch {
            LocalizedDebugLogger.shared.logAuth("createGuestUser", success: false)
            SupabaseService.shared.logAuthError(error, action: "createGuestUser", email: nil)
            throw error
        }
    }
    
    /// Delete the current user's account
    /// - Throws: SupabaseAuthError if deletion fails
    func deleteAccount() async throws {
        LocalizedDebugLogger.shared.logAuth("deleteAccount", success: false)
        
        do {
            guard let supabase = SupabaseService.shared.supabase else {
                throw SupabaseError.invalidURL
            }
            let user = supabase.auth.currentUser
            guard let userId = user?.id else {
                throw SupabaseError.authenticationFailed
            }
            
            // Note: This requires admin privileges in Supabase
            // For user-initiated deletion, consider using a different approach
            // or implementing this through an Edge Function
            try await supabase.auth.admin.deleteUser(id: userId)
            LocalizedDebugLogger.shared.logAuth("deleteAccount", success: true)
        } catch {
            LocalizedDebugLogger.shared.logAuth("deleteAccount", success: false)
            // Log detailed error information for debugging
            SupabaseService.shared.logAuthError(error, action: "deleteAccount", email: nil)
            throw error
        }
    }
}


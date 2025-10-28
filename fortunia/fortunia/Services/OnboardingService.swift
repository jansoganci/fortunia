//
//  OnboardingService.swift
//  fortunia
//
//  Created by Cursor AI on January 25, 2025
//

import Foundation
import Supabase

/// Service to manage user onboarding status and related operations
/// Provides methods to check if a user has completed onboarding and to mark completion
class OnboardingService {
    
    /// Shared singleton instance
    static let shared = OnboardingService()
    
    /// Private initializer for singleton pattern
    private init() {}
    
    /// Check if user has completed onboarding
    /// - Parameter userId: The user ID to check
    /// - Returns: True if onboarding is complete, false otherwise
    /// - Throws: Error if the database query fails
    func hasCompletedOnboarding(for userId: String) async throws -> Bool {
        LocalizedDebugLogger.shared.logDebug("ONBOARDING", "🔍 [START] Checking onboarding status for user: \(userId)")
        
        guard let supabase = SupabaseService.shared.supabase else {
            LocalizedDebugLogger.shared.logDebug("ONBOARDING", "❌ Supabase not configured, returning false")
            return false
        }
        
        do {
            LocalizedDebugLogger.shared.logDebug("ONBOARDING", "📡 [STEP 1/3] Querying database for user onboarding status")
            let response: [User] = try await supabase
                .from("users")
                .select()
                .eq("id", value: userId)
                .execute()
                .value
            
            LocalizedDebugLogger.shared.logDebug("ONBOARDING", "📊 [STEP 2/3] Database query completed. Found \(response.count) user(s)")
            
            guard let user = response.first else {
                LocalizedDebugLogger.shared.logDebug("ONBOARDING", "❌ [STEP 3/3] User not found in database")
                return false
            }
            
            LocalizedDebugLogger.shared.logDebug("ONBOARDING", "✅ [STEP 3/3] User \(userId) hasCompletedOnboarding: \(user.onboardingCompleted)")
            print("🔥 ONBOARDING CHECK: User \(userId) - Completed: \(user.onboardingCompleted)")
            return user.onboardingCompleted
            
        } catch {
            LocalizedDebugLogger.shared.logDebug("ONBOARDING", "❌ Failed to check onboarding status: \(error.localizedDescription)")
            throw error
        }
    }
    
    /// Mark user onboarding as complete
    /// - Parameter userId: The user ID to mark as complete
    /// - Throws: Error if the database update fails
    func markOnboardingComplete(for userId: String) async throws {
        guard let supabase = SupabaseService.shared.supabase else {
            throw OnboardingError.supabaseNotConfigured
        }
        
        do {
            LocalizedDebugLogger.shared.logDebug("ONBOARDING", "🔥 [STEP 1/2] Attempting to mark user \(userId) as onboarding complete")
            
            try await supabase
                .from("users")
                .update(["onboarding_completed": true])
                .eq("id", value: userId)
                .execute()
            
            LocalizedDebugLogger.shared.logDebug("ONBOARDING", "✅ [STEP 2/2] Successfully marked user \(userId) as onboarding complete")
            
        } catch {
            LocalizedDebugLogger.shared.logDebug("ONBOARDING", "❌ [ERROR] Failed to mark onboarding complete: \(error.localizedDescription)")
            throw error
        }
    }
}

// MARK: - Onboarding Errors
enum OnboardingError: Error, LocalizedError {
    case supabaseNotConfigured
    
    var errorDescription: String? {
        switch self {
        case .supabaseNotConfigured:
            return "Supabase client is not configured. Cannot check onboarding status."
        }
    }
}


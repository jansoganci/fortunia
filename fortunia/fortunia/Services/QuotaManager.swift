//
//  QuotaManager.swift
//  fortunia
//
//  Created by Cursor AI on December 19, 2024
//

import Foundation
import Supabase

/// QuotaManager handles daily quota management for free readings
/// Connects to Supabase Edge Functions to enforce the 3-free-readings-per-day limit
@MainActor
final class QuotaManager: ObservableObject {
    
    // MARK: - Singleton
    static let shared = QuotaManager()
    private init() {}
    
    // MARK: - Properties
    private let userDefaults = UserDefaults.standard
    private let cachedQuotaKey = "cachedQuota"
    private var cachedQuotaResponse: QuotaResponse?
    private var lastFetchTimestamp: Date?
    private var isCurrentlyFetching = false
    
    // FIXED: Premium state now synced from backend
    @Published var isPremiumUser: Bool = false
    @Published var hasError: Bool = false
    @Published var quotaRemaining: Int = 0
    
    // MARK: - Public Methods
    
    /// Fetch the current remaining quota for a user from Supabase
    /// - Parameter userId: The user's unique identifier (guest user_id or authenticated user_id)
    /// - Returns: The number of remaining free readings (0-3)
    /// - Throws: QuotaError if the request fails
    func fetchQuota(for userId: String? = nil, forceRefresh: Bool = false) async throws -> Int {
        // Return cached data if it's less than 5 minutes old and not forcing refresh
        if !forceRefresh,
           let lastFetchTimestamp = lastFetchTimestamp,
           let cachedQuotaResponse = cachedQuotaResponse,
           Date().timeIntervalSince(lastFetchTimestamp) < 300 {
            DebugLogger.shared.quota("🔵 [FETCH_QUOTA] Returning cached data (age: \(Int(Date().timeIntervalSince(lastFetchTimestamp)))s)")
            return cachedQuotaResponse.quotaRemaining
        }
        
        // Prevent concurrent fetches
        if isCurrentlyFetching {
            if let cachedQuotaResponse = cachedQuotaResponse {
                DebugLogger.shared.quota("🔵 [FETCH_QUOTA] Fetch already in progress, returning cached data")
                return cachedQuotaResponse.quotaRemaining
            }
            throw QuotaError.fetchFailed("Previous fetch still in progress")
        }
        
        isCurrentlyFetching = true
        defer { isCurrentlyFetching = false }
        
        // Get user_id (guest or authenticated)
        let actualUserId = userId ?? getGuestUserId()
        DebugLogger.shared.quota("🔵 [FETCH_QUOTA] Starting fresh fetch for userId: \(actualUserId ?? "none")")
        
        guard let actualUserId = actualUserId else {
            throw QuotaError.fetchFailed("No user ID or guest user ID available")
        }
        
        do {
            DebugLogger.shared.quota("🔵 [FETCH_QUOTA] Calling Supabase RPC 'get_quota'...")
            
            // Call Supabase RPC function to get current quota
            guard let supabase = SupabaseService.shared.supabase else {
                throw QuotaError.fetchFailed("Supabase client not configured")
            }
            
            let response: QuotaResponse = try await supabase.rpc(
                "get_quota",
                params: ["p_user_id": actualUserId]
            ).execute().value
            
            DebugLogger.shared.quota("🔵 [FETCH_QUOTA] RPC call completed")
            
            DebugLogger.shared.quota("🔵 [FETCH_QUOTA] Parsed response - quotaUsed: \(response.quotaUsed), quotaLimit: \(response.quotaLimit), quotaRemaining: \(response.quotaRemaining), isPremium: \(response.isPremium)")
            
            // Parse the response (RPC returns data directly)
            let quotaData = response
            
            // Update cache
            self.cachedQuotaResponse = quotaData
            self.lastFetchTimestamp = Date()
            
            // FIXED: Premium state now synced from backend
            isPremiumUser = quotaData.isPremium
            
            // Update published quota remaining for UI
            quotaRemaining = quotaData.quotaRemaining
            
            DebugLogger.shared.quota("🔵 [FETCH_QUOTA] Updated isPremiumUser to: \(isPremiumUser)")
            DebugLogger.shared.quota("🔵 [FETCH_QUOTA] Updated quotaRemaining to: \(quotaRemaining)")
            
            // Update local cache with fresh data
            userDefaults.set(quotaData.quotaRemaining, forKey: cachedQuotaKey)
            
            DebugLogger.shared.quota("🔵 [FETCH_QUOTA] Cached quota: \(quotaData.quotaRemaining)")
            
            // Log analytics event
            AnalyticsService.shared.logEvent("quota_checked", parameters: [
                "user_id": actualUserId,
                "quota_remaining": quotaData.quotaRemaining,
                "is_premium": quotaData.isPremium
            ])
            
            DebugLogger.shared.quota("✅ [FETCH_QUOTA] Success - Quota fetched: \(quotaData.quotaRemaining) remaining")
            
            return quotaData.quotaRemaining
            
        } catch {
            DebugLogger.shared.quota("🔴 [FETCH_QUOTA] ERROR occurred: \(error)")
            DebugLogger.shared.quota("🔴 [FETCH_QUOTA] Error type: \(type(of: error))")
            
            if let decodingError = error as? DecodingError {
                DebugLogger.shared.quota("🔴 [FETCH_QUOTA] Decoding error details: \(decodingError)")
            }
            
            // If API call fails, try to return cached value
            if let cachedQuotaResponse = cachedQuotaResponse {
                DebugLogger.shared.warning("🔴 [FETCH_QUOTA] API failed, using cached quota: \(cachedQuotaResponse.quotaRemaining)")
                return cachedQuotaResponse.quotaRemaining
            }
            
            // If no cached value and API failed, throw error
            DebugLogger.shared.warning("🔴 [FETCH_QUOTA] Quota fetch failed: \(error.localizedDescription)")
            throw QuotaError.fetchFailed(error.localizedDescription)
        }
    }
    
    /// Consume one quota reading for a user
    /// - Parameter userId: The user's unique identifier (nil means use guest or authenticated user_id)
    /// - Returns: The updated remaining quota after consumption
    /// - Throws: QuotaError if the request fails or quota is exhausted
    func consumeQuota(for userId: String? = nil) async throws -> Int {
        // Get user_id (guest or authenticated)
        let actualUserId = userId ?? getGuestUserId()
        guard let actualUserId = actualUserId else {
            throw QuotaError.consumeFailed("No user ID or guest user ID available")
        }
        
        do {
            // Call Supabase RPC function to consume one quota
            guard let supabase = SupabaseService.shared.supabase else {
                throw QuotaError.consumeFailed("Supabase client not configured")
            }
            
            let response: QuotaResponse = try await supabase.rpc(
                "consume_quota",
                params: ["p_user_id": actualUserId]
            ).execute().value
            
            // Parse the response (RPC returns data directly)
            let quotaData = response
            
            // Check if quota consumption was successful
            guard quotaData.isSuccessful else {
                throw QuotaError.quotaExhausted("Daily quota limit reached")
            }
            
            // Update local cache with new remaining quota
            userDefaults.set(quotaData.quotaRemaining, forKey: cachedQuotaKey)
            
            // Log analytics event
            AnalyticsService.shared.logEvent("quota_consumed", parameters: [
                "user_id": actualUserId,
                "quota_remaining": quotaData.quotaRemaining,
                "is_premium": quotaData.isPremium
            ])
            
            DebugLogger.shared.quota("Quota consumed for user \(actualUserId): \(quotaData.quotaRemaining) remaining")
            
            return quotaData.quotaRemaining
            
        } catch {
            DebugLogger.shared.warning("Quota consumption failed: \(error.localizedDescription)")
            throw QuotaError.consumeFailed(error.localizedDescription)
        }
    }
    
    /// Check if user has quota remaining (using cached value)
    /// - Returns: True if user has at least 1 free reading remaining
    func hasQuotaRemaining() -> Bool {
        // TEMP: Premium bypass for testing – remove before release
        if isPremiumUser {
            DebugLogger.shared.quota("Premium user - unlimited access")
            return true
        }
        
        // Use the published quotaRemaining value for real-time UI updates
        let hasQuota = quotaRemaining > 0
        
        DebugLogger.shared.quota("Quota check: \(hasQuota ? "Available" : "Exhausted") (quotaRemaining: \(quotaRemaining))")
        
        return hasQuota
    }
    
    /// Get guest user_id from UserDefaults
    /// - Returns: Guest user_id if exists, nil otherwise
    private func getGuestUserId() -> String? {
        return userDefaults.string(forKey: "guest_user_id")
    }
    
    /// Get the current cached quota value
    /// - Returns: The number of remaining free readings from cache
    func getCachedQuota() -> Int {
        return userDefaults.integer(forKey: cachedQuotaKey)
    }
    
    /// Reset the cached quota (useful for testing or when user signs out)
    func resetCachedQuota() {
        userDefaults.removeObject(forKey: cachedQuotaKey)
        DebugLogger.shared.quota("Cached quota reset")
    }
    
    /// Check if quota is exhausted (0 remaining)
    /// - Returns: True if no free readings are available
    func isQuotaExhausted() -> Bool {
        return !hasQuotaRemaining()
    }
    
    /// Get quota status for display purposes
    /// - Returns: A formatted string showing current quota status
    func getQuotaStatusText() -> String {
        // TEMP: Premium bypass for testing – remove before release
        if isPremiumUser {
            return "Unlimited"
        }
        
        let remaining = getCachedQuota()
        return "\(3 - remaining)/3 used"
    }
    
    /// Refresh premium status from backend
    /// This method fetches the current subscription status from Supabase
    func refreshPremiumStatus(for userId: String, isRetry: Bool = false) async {
        DebugLogger.shared.quota("🟢 [REFRESH_PREMIUM] Starting refresh for userId: \(userId)")
        hasError = false
        
        do {
            DebugLogger.shared.quota("🟢 [REFRESH_PREMIUM] Calling RPC 'get_quota'...")
            
            guard let supabase = SupabaseService.shared.supabase else {
                throw QuotaError.fetchFailed("Supabase client not configured")
            }
            let response: QuotaResponse = try await supabase.rpc(
                "get_quota",
                params: ["p_user_id": userId]
            ).execute().value
            
            DebugLogger.shared.quota("🟢 [REFRESH_PREMIUM] RPC call completed")
            
            DebugLogger.shared.quota("🟢 [REFRESH_PREMIUM] Parsed - isPremium: \(response.isPremium), quotaRemaining: \(response.quotaRemaining)")
            
            isPremiumUser = response.isPremium
            
            DebugLogger.shared.quota("✅ [REFRESH_PREMIUM] Premium status refreshed: \(isPremiumUser)")
        } catch {
            // Log the error for debugging
            DebugLogger.shared.warning("🔴 [REFRESH_PREMIUM] Failed to refresh premium status: \(error.localizedDescription)")
            hasError = true
            
            // Handle different error types
            switch error {
            case is DecodingError:
                // Catches JSON parsing errors
                DebugLogger.shared.warning("🔴 [REFRESH_PREMIUM] Decoding error: \(error.localizedDescription)")
            case let urlError as URLError where urlError.code == .notConnectedToInternet:
                // Catches network connection errors and retries once
                if !isRetry {
                    DebugLogger.shared.warning("🔴 [REFRESH_PREMIUM] Network error. Retrying in 2 seconds...")
                    try? await Task.sleep(nanoseconds: 2_000_000_000)
                    await refreshPremiumStatus(for: userId, isRetry: true)
                }
            default:
                // Catches other errors (auth, unknown, etc.)
                DebugLogger.shared.warning("🔴 [REFRESH_PREMIUM] An unknown error occurred.")
            }
        }
    }
}

// MARK: - Response Models

/// Response model for Supabase quota functions
private struct QuotaResponse: Codable {
    let success: Bool?
    let quotaUsed: Int
    let quotaLimit: Int
    let quotaRemaining: Int
    let isPremium: Bool
    let message: String?
    
    enum CodingKeys: String, CodingKey {
        case success
        case quotaUsed = "quota_used"
        case quotaLimit = "quota_limit"
        case quotaRemaining = "quota_remaining"
        case isPremium = "is_premium"
        case message
    }
    
    // Computed property for backward compatibility
    var isSuccessful: Bool {
        return success ?? true  // Default to true if not present
    }
}

// MARK: - Error Handling

/// Custom errors for quota management
enum QuotaError: LocalizedError {
    case fetchFailed(String)
    case consumeFailed(String)
    case quotaExhausted(String)
    case invalidResponse
    
    var errorDescription: String? {
        switch self {
        case .fetchFailed(let message):
            return "Failed to fetch quota: \(message)"
        case .consumeFailed(let message):
            return "Failed to consume quota: \(message)"
        case .quotaExhausted(let message):
            return "Quota exhausted: \(message)"
        case .invalidResponse:
            return "Invalid response from server"
        }
    }
}

// MARK: - Debug Logger Extension
// Note: quota() method is now defined in DebugLogger class


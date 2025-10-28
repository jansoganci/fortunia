//
//  BusinessAnalyticsService.swift
//  fortunia
//
//  Created by Can Soğancı on 24.10.2025.
//

import Foundation
import Supabase

/// BusinessAnalyticsService - Business intelligence analytics for Supabase
/// Tracks only business-critical events for product insights and revenue analysis
/// Lightweight, secure, and focused on key metrics only
final class BusinessAnalyticsService {
    
    // MARK: - Singleton
    static let shared = BusinessAnalyticsService()
    private init() {}
    
    // MARK: - Properties
    private let supabase = SupabaseService.shared.supabase
    
    // MARK: - Business Event Logging
    
    /// Log reading completion for business intelligence
    /// - Parameters:
    ///   - userId: User identifier from Supabase auth
    ///   - type: Type of reading completed (face, palm, tarot, etc.)
    ///   - culture: Cultural origin of the reading
    ///   - isPremium: Whether this was a premium reading
    func logReadingCompleted(userId: String, type: String, culture: String, isPremium: Bool) {
        // Runtime analytics toggle (enables testing in debug builds)
        guard AppConstants.analyticsEnabled else {
            LocalizedDebugLogger.shared.logDebug("ANALYTICS", "Reading completed logged (disabled by runtime flag)")
            return
        }
        
        Task.detached { [weak self] in
            do {
                let eventData: [String: Any] = [
                    "type": type,
                    "culture": culture,
                    "is_premium": isPremium,
                    "timestamp": ISO8601DateFormatter().string(from: Date()),
                    "app_version": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
                ]
                
                // Serialize eventData to JSON string
                let jsonData = try JSONSerialization.data(withJSONObject: eventData)
                let eventDataString = String(data: jsonData, encoding: .utf8) ?? "{}"
                
                try await self?.supabase?
                    .from("business_analytics_events")
                    .insert([
                        "event_name": "reading_completed",
                        "user_id": userId,
                        "event_data": eventDataString
                    ])
                    .execute()
                
                DebugLogger.shared.network("Business analytics: Reading completed logged for user \(userId)")
            } catch {
                // Gracefully ignore errors in production - no user impact
                DebugLogger.shared.network("Business analytics error (ignored): \(error.localizedDescription)")
            }
        }
    }
    
    /// Log subscription purchase for revenue tracking
    /// - Parameters:
    ///   - userId: User identifier from Supabase auth
    ///   - tier: Subscription tier (free, premium, lifetime, monthly, yearly)
    func logSubscriptionPurchased(userId: String, tier: String) {
        // Runtime analytics toggle (enables testing in debug builds)
        guard AppConstants.analyticsEnabled else {
            LocalizedDebugLogger.shared.logDebug("ANALYTICS", "Subscription purchased logged (disabled by runtime flag)")
            return
        }
        
        Task.detached { [weak self] in
            do {
                let eventData: [String: Any] = [
                    "tier": tier,
                    "timestamp": ISO8601DateFormatter().string(from: Date()),
                    "app_version": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
                ]
                
                // Serialize eventData to JSON string
                let jsonData = try JSONSerialization.data(withJSONObject: eventData)
                let eventDataString = String(data: jsonData, encoding: .utf8) ?? "{}"
                
                try await self?.supabase?
                    .from("business_analytics_events")
                    .insert([
                        "event_name": "subscription_purchased",
                        "user_id": userId,
                        "event_data": eventDataString
                    ])
                    .execute()
                
                DebugLogger.shared.network("Business analytics: Subscription purchased logged for user \(userId)")
            } catch {
                // Gracefully ignore errors in production - no user impact
                DebugLogger.shared.network("Business analytics error (ignored): \(error.localizedDescription)")
            }
        }
    }
    
    /// Log paywall display for conversion analysis
    /// - Parameters:
    ///   - userId: User identifier from Supabase auth
    ///   - trigger: What triggered the paywall (quota_exceeded, premium_feature, etc.)
    func logPaywallShown(userId: String, trigger: String) {
        // Runtime analytics toggle (enables testing in debug builds)
        guard AppConstants.analyticsEnabled else {
            LocalizedDebugLogger.shared.logDebug("ANALYTICS", "Paywall shown logged (disabled by runtime flag)")
            return
        }
        
        Task.detached { [weak self] in
            do {
                let eventData: [String: Any] = [
                    "trigger": trigger,
                    "timestamp": ISO8601DateFormatter().string(from: Date()),
                    "app_version": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
                ]
                
                // Serialize eventData to JSON string
                let jsonData = try JSONSerialization.data(withJSONObject: eventData)
                let eventDataString = String(data: jsonData, encoding: .utf8) ?? "{}"
                
                try await self?.supabase?
                    .from("business_analytics_events")
                    .insert([
                        "event_name": "paywall_shown",
                        "user_id": userId,
                        "event_data": eventDataString
                    ])
                    .execute()
                
                DebugLogger.shared.network("Business analytics: Paywall shown logged for user \(userId)")
            } catch {
                // Gracefully ignore errors in production - no user impact
                DebugLogger.shared.network("Business analytics error (ignored): \(error.localizedDescription)")
            }
        }
    }
    
    /// Log user signup for acquisition tracking
    /// - Parameters:
    ///   - userId: User identifier from Supabase auth
    ///   - method: Signup method (email, apple, guest)
    func logUserSignup(userId: String, method: String) {
        // Runtime analytics toggle (enables testing in debug builds)
        guard AppConstants.analyticsEnabled else {
            LocalizedDebugLogger.shared.logDebug("ANALYTICS", "User signup logged (disabled by runtime flag)")
            return
        }
        
        Task.detached { [weak self] in
            do {
                let eventData: [String: Any] = [
                    "method": method,
                    "timestamp": ISO8601DateFormatter().string(from: Date()),
                    "app_version": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
                ]
                
                // Serialize eventData to JSON string
                let jsonData = try JSONSerialization.data(withJSONObject: eventData)
                let eventDataString = String(data: jsonData, encoding: .utf8) ?? "{}"
                
                try await self?.supabase?
                    .from("business_analytics_events")
                    .insert([
                        "event_name": "user_signup",
                        "user_id": userId,
                        "event_data": eventDataString
                    ])
                    .execute()
                
                DebugLogger.shared.network("Business analytics: User signup logged for user \(userId)")
            } catch {
                // Gracefully ignore errors in production - no user impact
                DebugLogger.shared.network("Business analytics error (ignored): \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Testing & Verification
    
    /// Test business analytics integration (development only)
    /// 
    /// Usage in DEBUG builds:
    /// 1. Enable analytics: `AppConstants.setAnalyticsEnabled(true)`
    /// 2. Call this method to test events
    /// 3. Check Supabase analytics table for logged events
    func testBusinessAnalyticsIntegration() {
        #if DEBUG
        let analyticsStatus = AppConstants.analyticsEnabled ? "enabled" : "disabled"
        DebugLogger.shared.network("Testing business analytics integration (analytics is \(analyticsStatus))...")
        
        if !AppConstants.analyticsEnabled {
            DebugLogger.shared.warning("Analytics is disabled. Enable it with: AppConstants.setAnalyticsEnabled(true)")
        }
        
        // Test reading completed
        logReadingCompleted(
            userId: "test-user-123",
            type: "face",
            culture: "turkish",
            isPremium: false
        )
        
        // Test subscription purchase
        logSubscriptionPurchased(
            userId: "test-user-123",
            tier: "premium"
        )
        
        DebugLogger.shared.network("Business analytics test completed - check Supabase table")
        #else
        DebugLogger.shared.network("Business analytics test skipped in production build")
        #endif
    }
}

// MARK: - SQL Schema Reference
/*
-- Execute this SQL in Supabase SQL Editor to create the business_analytics_events table:

CREATE TABLE IF NOT EXISTS business_analytics_events (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    event_name TEXT NOT NULL,
    user_id UUID REFERENCES auth.users(id),
    event_data JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_business_analytics_events_user_id ON business_analytics_events(user_id);
CREATE INDEX IF NOT EXISTS idx_business_analytics_events_event_name ON business_analytics_events(event_name);
CREATE INDEX IF NOT EXISTS idx_business_analytics_events_created_at ON business_analytics_events(created_at);

-- Enable RLS
ALTER TABLE business_analytics_events ENABLE ROW LEVEL SECURITY;

-- Policy for service-role inserts (for app backend)
CREATE POLICY "Allow service-role inserts" ON business_analytics_events
    FOR INSERT
    TO service_role
    WITH CHECK (true);

-- Policy for authenticated users to read their own events
CREATE POLICY "Users can read own events" ON business_analytics_events
    FOR SELECT
    TO authenticated
    USING (auth.uid() = user_id);
*/

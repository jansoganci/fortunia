//
//  AnalyticsService.swift
//  fortunia
//
//  Created by Can Soğancı on 24.10.2025.
//

import Foundation
import FirebaseAnalytics
import FirebaseCrashlytics
import Supabase

/// AnalyticsService - Comprehensive analytics and monitoring service
/// Integrates Firebase Analytics, Crashlytics, and Supabase custom event logging
/// Handles user consent, performance tracking, and error reporting
final class AnalyticsService: ObservableObject {
    
    // MARK: - Singleton
    static let shared = AnalyticsService()
    private init() {}
    
    // MARK: - Properties
    private let supabase = SupabaseService.shared.supabase
    private let crashlytics = Crashlytics.crashlytics()
    
    /// Analytics consent status - respects user privacy preferences
    private var analyticsEnabled: Bool {
        UserDefaults.standard.bool(forKey: "AnalyticsConsent")
    }
    
    // MARK: - Core Event Logging
    
    /// Log analytics event to both Firebase and Supabase
    /// - Parameters:
    ///   - name: Event name (e.g., "app_open", "reading_completed")
    ///   - parameters: Optional event parameters dictionary
    func logEvent(_ name: String, parameters: [String: Any]? = nil) {
        guard analyticsEnabled else {
            DebugLogger.shared.network("Analytics disabled (no consent)")
            return
        }
        
        // Firebase Analytics event
        Analytics.logEvent(name, parameters: parameters)
        
        // Log custom event to Supabase (non-blocking)
        Task {
            do {
                try await self.logEventToSupabase(name: name, parameters: parameters)
            } catch {
                SupabaseService.shared.logNetworkError(error, endpoint: "analytics_event", context: name)
            }
        }
        
        DebugLogger.shared.network("Analytics event logged: \(name)")
    }
    
    // MARK: - Crash & Error Logging
    
    /// Record error to Crashlytics with optional user context
    /// - Parameters:
    ///   - error: The error to record
    ///   - userInfo: Optional additional context information
    func recordError(_ error: Error, userInfo: [String: Any]? = nil) {
        #if !DEBUG
        crashlytics.record(error: error, userInfo: userInfo)
        #endif
        DebugLogger.shared.network("Crash logged: \(error.localizedDescription)")
    }
    
    /// Log crash with context for better debugging
    /// - Parameters:
    ///   - error: The error that occurred
    ///   - context: Additional context about where the error occurred
    func logCrash(_ error: Error, context: String) {
        #if !DEBUG
        crashlytics.record(error: error)
        crashlytics.setCustomValue(context, forKey: "error_context")
        #endif
        
        // Also log as analytics event
        logEvent(
            AnalyticsEvents.ErrorOccurred.name,
            parameters: AnalyticsEvents.ErrorOccurred.parameters(
                errorType: "crash_error",
                errorMessage: error.localizedDescription,
                context: context
            )
        )
        
        DebugLogger.shared.network("Crash logged with context: \(context) - \(error.localizedDescription)")
    }
    
    /// Set custom user identifier for crash reporting
    /// - Parameter userId: User identifier from Supabase auth
    func setUserId(_ userId: String) {
        #if !DEBUG
        crashlytics.setUserID(userId)
        #endif
        DebugLogger.shared.network("Crashlytics user ID set: \(userId)")
    }
    
    /// Set custom key-value pairs for crash context
    /// - Parameters:
    ///   - value: Value to store
    ///   - key: Key identifier
    func setCustomValue(_ value: String, forKey key: String) {
        #if !DEBUG
        crashlytics.setCustomValue(value, forKey: key)
        #endif
        DebugLogger.shared.network("Crashlytics custom value set: \(key) = \(value)")
    }
    
    // MARK: - Performance Tracking
    
    /// Track performance metrics (app launch time, reading generation time, etc.)
    /// - Parameters:
    ///   - metricName: Name of the performance metric
    ///   - value: Metric value (usually in seconds or milliseconds)
    func trackPerformanceMetric(_ metricName: String, value: Double) {
        Analytics.logEvent("performance_metric", parameters: [
            "metric_name": metricName,
            "value": value,
            "timestamp": Date().timeIntervalSince1970
        ])
        
        DebugLogger.shared.network("Performance metric tracked: \(metricName) = \(value)")
    }
    
    /// Track app launch performance
    /// - Parameter launchTime: Time taken for app to launch (in seconds)
    func trackAppLaunchTime(_ launchTime: Double) {
        trackPerformanceMetric("app_launch_time", value: launchTime)
    }
    
    /// Track reading generation performance
    /// - Parameter generationTime: Time taken to generate reading (in seconds)
    func trackReadingGenerationTime(_ generationTime: Double) {
        trackPerformanceMetric("reading_generation_time", value: generationTime)
    }
    
    // MARK: - Firebase Performance Monitoring (Currently Disabled)
    
    // Note: Firebase Performance Monitoring is not included in the current build
    // To enable: Add FirebasePerformance dependency to project
    
    /// Start a custom performance trace
    /// - Parameter traceName: Name of the trace to start
    /// - Returns: The trace object for stopping later (currently nil)
    func startPerformanceTrace(_ traceName: String) -> Any? {
        DebugLogger.shared.network("Performance trace started (disabled): \(traceName)")
        return nil
    }
    
    /// Stop a performance trace
    /// - Parameter trace: The trace to stop (unused, kept for compatibility)
    func stopPerformanceTrace(_ trace: Any?) {
        DebugLogger.shared.network("Performance trace stopped (disabled)")
    }
    
    /// Start app launch performance trace
    /// - Returns: The trace object for stopping when MainTabView loads
    func startAppLaunchTrace() -> Any? {
        return startPerformanceTrace("app_launch_time")
    }
    
    /// Start reading generation performance trace
    /// - Returns: The trace object for stopping when reading completes
    func startReadingGenerationTrace() -> Any? {
        return startPerformanceTrace("reading_generation_time")
    }
    
    // MARK: - Supabase Custom Event Storage
    
    /// Log event to Supabase for detailed business intelligence analysis
    /// - Parameters:
    ///   - name: Event name
    ///   - parameters: Event parameters
    private func logEventToSupabase(name: String, parameters: [String: Any]? = nil) async throws {
        struct AnalyticsEventData: Encodable {
            let event_name: String
            let event_parameters: [String: String]
            let session_id: String
            let device_info: DeviceInfo
            let timestamp: String
        }
        
        struct DeviceInfo: Encodable {
            let os: String
            let version: String
            let model: String
            let app_version: String
        }
        
        // Convert Any parameters to String for encoding
        let stringParams = parameters?.mapValues { "\($0)" } ?? [:]
        
        let data = AnalyticsEventData(
            event_name: name,
            event_parameters: stringParams,
            session_id: UUID().uuidString,
            device_info: DeviceInfo(
                os: "iOS",
                version: UIDevice.current.systemVersion,
                model: UIDevice.current.model,
                app_version: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
            ),
            timestamp: ISO8601DateFormatter().string(from: Date())
        )
        
        guard let supabase = SupabaseService.shared.supabase else {
            return // Skip if Supabase not configured
        }
        
        do {
            try await supabase
                .from("analytics_events")
                .insert(data)
                .execute()
        } catch {
            throw error
        }
    }
    
    // MARK: - User Consent Management
    
    /// Set user consent for analytics data collection
    /// - Parameter granted: Whether user has granted consent
    func setUserConsent(_ granted: Bool) {
        UserDefaults.standard.set(granted, forKey: "AnalyticsConsent")
        
        if granted {
            DebugLogger.shared.network("Analytics consent granted.")
        } else {
            DebugLogger.shared.network("Analytics consent revoked.")
        }
    }
    
    /// Check if user has granted analytics consent
    /// - Returns: True if consent granted, false otherwise
    func hasUserConsent() -> Bool {
        return analyticsEnabled
    }
    
    // MARK: - Predefined Analytics Events
    
    /// Log app open event (called on app launch)
    func logAppOpen() {
        logEvent("app_open", parameters: [
            "timestamp": Date().timeIntervalSince1970,
            "app_version": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
        ])
    }
    
    /// Log user signup completion
    /// - Parameter method: Signup method ("email", "apple", "guest")
    func logSignupCompleted(method: String) {
        logEvent("signup_completed", parameters: [
            "method": method,
            "timestamp": Date().timeIntervalSince1970
        ])
        
        // Also log to business analytics for acquisition tracking
        if let userId = getCurrentUserId() {
            BusinessAnalyticsService.shared.logUserSignup(
                userId: userId,
                method: method
            )
        }
    }
    
    /// Log fortune reading request
    /// - Parameters:
    ///   - type: Type of reading ("face", "palm", "tarot", etc.)
    ///   - culture: Cultural origin ("western", "eastern", "mystical", etc.)
    func logReadingRequested(type: String, culture: String) {
        logEvent("reading_requested", parameters: [
            "type": type,
            "culture": culture,
            "timestamp": Date().timeIntervalSince1970
        ])
    }
    
    /// Log fortune reading completion
    /// - Parameters:
    ///   - type: Type of reading completed
    ///   - isPremium: Whether this was a premium reading
    func logReadingCompleted(type: String, isPremium: Bool) {
        logEvent("reading_completed", parameters: [
            "type": type,
            "premium": isPremium,
            "timestamp": Date().timeIntervalSince1970
        ])
        
        // Also log to business analytics for BI
        if let userId = getCurrentUserId() {
            BusinessAnalyticsService.shared.logReadingCompleted(
                userId: userId,
                type: type,
                culture: "turkish", // Default culture - can be parameterized later
                isPremium: isPremium
            )
        }
    }
    
    /// Log social sharing action
    /// - Parameter platform: Sharing platform ("instagram", "twitter", "facebook", "copy_link")
    func logShareTapped(platform: String) {
        logEvent("share_tapped", parameters: [
            "platform": platform,
            "timestamp": Date().timeIntervalSince1970
        ])
    }
    
    /// Log subscription purchase
    /// - Parameter tier: Subscription tier ("monthly", "yearly", "lifetime")
    func logSubscriptionPurchased(tier: String) {
        logEvent("subscription_purchased", parameters: [
            "tier": tier,
            "timestamp": Date().timeIntervalSince1970
        ])
        
        // Also log to business analytics for revenue tracking
        if let userId = getCurrentUserId() {
            BusinessAnalyticsService.shared.logSubscriptionPurchased(
                userId: userId,
                tier: tier
            )
        }
    }
    
    /// Log paywall display
    /// - Parameter trigger: What triggered the paywall ("quota_exceeded", "premium_feature", "upgrade_prompt")
    func logPaywallShown(trigger: String) {
        logEvent("paywall_shown", parameters: [
            "trigger": trigger,
            "timestamp": Date().timeIntervalSince1970
        ])
        
        // Also log to business analytics for conversion analysis
        if let userId = getCurrentUserId() {
            BusinessAnalyticsService.shared.logPaywallShown(
                userId: userId,
                trigger: trigger
            )
        }
    }
    
    /// Log user session start
    func logSessionStart() {
        logEvent("session_start", parameters: [
            "timestamp": Date().timeIntervalSince1970
        ])
    }
    
    /// Log user session end
    /// - Parameter duration: Session duration in seconds
    func logSessionEnd(duration: Double) {
        logEvent("session_end", parameters: [
            "duration": duration,
            "timestamp": Date().timeIntervalSince1970
        ])
    }
    
    // MARK: - Debug & Development
    
    /// Enable/disable debug logging for development
    /// - Parameter enabled: Whether to enable debug logging
    func setDebugLogging(_ enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: "AnalyticsDebugLogging")
        DebugLogger.shared.network("Analytics debug logging \(enabled ? "enabled" : "disabled")")
    }
    
    /// Check if debug logging is enabled
    /// - Returns: True if debug logging is enabled
    func isDebugLoggingEnabled() -> Bool {
        return UserDefaults.standard.bool(forKey: "AnalyticsDebugLogging")
    }
    
    // MARK: - Helper Methods
    
    /// Get current user ID from Supabase auth
    /// - Returns: User ID if authenticated, nil otherwise
    private func getCurrentUserId() -> String? {
        // This would need to be implemented based on your auth system
        // For now, return nil - this should be connected to your auth state
        return nil
    }
    
    // MARK: - Testing & Verification
    
    /// Test Crashlytics integration (for development/testing only)
    /// - Warning: This will cause a test crash in production builds
    func testCrashlyticsIntegration() {
        #if DEBUG
        DebugLogger.shared.network("Testing Crashlytics integration...")
        
        // Test error logging
        let testError = NSError(domain: "com.fortunia.test", code: 999, userInfo: [
            NSLocalizedDescriptionKey: "Test error for Crashlytics verification"
        ])
        logCrash(testError, context: "test_integration")
        
        // Test performance trace
        let testTrace = startPerformanceTrace("test_trace")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.stopPerformanceTrace(testTrace)
        }
        
        DebugLogger.shared.network("Crashlytics test completed - check Firebase console")
        #else
        DebugLogger.shared.network("Crashlytics test skipped in production build")
        #endif
    }
    
    /// Test business analytics integration (for development/testing only)
    func testBusinessAnalyticsIntegration() {
        #if DEBUG
        DebugLogger.shared.network("Testing business analytics integration...")
        
        // Test business analytics service directly
        BusinessAnalyticsService.shared.testBusinessAnalyticsIntegration()
        
        DebugLogger.shared.network("Business analytics test completed - check Supabase table")
        #else
        DebugLogger.shared.network("Business analytics test skipped in production build")
        #endif
    }
}

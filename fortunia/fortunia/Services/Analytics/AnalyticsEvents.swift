//
//  AnalyticsEvents.swift
//  fortunia
//
//  Created by Can Soğancı on 24.10.2025.
//

import Foundation

/// AnalyticsEvents - Type-safe analytics event definitions
/// Centralizes all event names and parameters for consistent analytics tracking
/// Used by AnalyticsService for Firebase and Supabase event logging
enum AnalyticsEvents {
    
    // MARK: - Supporting Enums
    
    /// Signup method enumeration
    enum SignupMethod: String, CaseIterable {
        case email = "email"
        case apple = "apple"
        case guest = "guest"
        
        var localizedValue: String {
            switch self {
            case .email: return NSLocalizedString("analytics_value_email", comment: "Email signup method")
            case .apple: return NSLocalizedString("analytics_value_apple", comment: "Apple signup method")
            case .guest: return NSLocalizedString("analytics_value_guest", comment: "Guest signup method")
            }
        }
    }
    
    /// Reading type enumeration
    enum ReadingType: String, CaseIterable {
        case face = "face"
        case palm = "palm"
        case tarot = "tarot"
        case coffee = "coffee"
    }
    
    /// Reading culture/origin enumeration
    enum ReadingCulture: String, CaseIterable {
        case chinese = "chinese"
        case turkish = "turkish"
        case western = "western"
        case eastern = "eastern"
        case mystical = "mystical"
    }
    
    /// Social sharing platform enumeration
    enum SocialPlatform: String, CaseIterable {
        case instagram = "instagram"
        case tiktok = "tiktok"
        case facebook = "facebook"
        case twitter = "twitter"
        case copyLink = "copy_link"
        case whatsapp = "whatsapp"
    }
    
    /// Subscription tier enumeration
    enum SubscriptionTier: String, CaseIterable {
        case free = "free"
        case premium = "premium"
        case lifetime = "lifetime"
        case monthly = "monthly"
        case yearly = "yearly"
    }
    
    /// Paywall trigger enumeration
    enum PaywallTrigger: String, CaseIterable {
        case quotaExceeded = "quota_exceeded"
        case premiumFeature = "premium_feature"
        case upgradePrompt = "upgrade_prompt"
        case readingLimit = "reading_limit"
    }
    
    // MARK: - Core Analytics Events
    
    /// App open event - triggered when app launches
    struct AppOpen {
        static let name = NSLocalizedString("analytics_app_open", comment: "App open event name")
        
        static func parameters(sessionID: String? = nil) -> [String: Any] {
            var params: [String: Any] = [
                "timestamp": Date().timeIntervalSince1970,
                "app_version": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
            ]
            
            if let sessionID = sessionID {
                params[NSLocalizedString("analytics_param_session_id", comment: "Session ID parameter")] = sessionID
            }
            
            return params
        }
    }
    
    /// Signup completion event - triggered when user completes registration
    struct SignupCompleted {
        static let name = NSLocalizedString("analytics_signup_completed", comment: "Signup completed event name")
        
        static func parameters(method: SignupMethod) -> [String: Any] {
            [
                NSLocalizedString("analytics_param_method", comment: "Method parameter"): method.localizedValue,
                "timestamp": Date().timeIntervalSince1970
            ]
        }
    }
    
    /// Reading request event - triggered when user initiates a fortune reading
    struct ReadingRequested {
        static let name = "reading_requested"
        
        static func parameters(type: ReadingType, culture: ReadingCulture) -> [String: Any] {
            [
                "type": type.rawValue,
                "culture": culture.rawValue,
                "timestamp": Date().timeIntervalSince1970
            ]
        }
    }
    
    /// Reading completion event - triggered when fortune reading is generated
    struct ReadingCompleted {
        static let name = "reading_completed"
        
        static func parameters(type: ReadingType, isPremium: Bool) -> [String: Any] {
            [
                "type": type.rawValue,
                "premium": isPremium,
                "timestamp": Date().timeIntervalSince1970
            ]
        }
    }
    
    /// Share action event - triggered when user shares content
    struct ShareTapped {
        static let name = "share_tapped"
        
        static func parameters(platform: SocialPlatform) -> [String: Any] {
            [
                "platform": platform.rawValue,
                "timestamp": Date().timeIntervalSince1970
            ]
        }
    }
    
    /// Subscription purchase event - triggered when user purchases subscription
    struct SubscriptionPurchased {
        static let name = "subscription_purchased"
        
        static func parameters(tier: SubscriptionTier) -> [String: Any] {
            [
                "tier": tier.rawValue,
                "timestamp": Date().timeIntervalSince1970
            ]
        }
    }
    
    // MARK: - Additional Events
    
    /// Paywall display event - triggered when paywall is shown
    struct PaywallShown {
        static let name = "paywall_shown"
        
        static func parameters(trigger: PaywallTrigger) -> [String: Any] {
            [
                "trigger": trigger.rawValue,
                "timestamp": Date().timeIntervalSince1970
            ]
        }
    }
    
    /// Session start event - triggered when user session begins
    struct SessionStart {
        static let name = "session_start"
        
        static func parameters(sessionID: String? = nil) -> [String: Any] {
            var params: [String: Any] = [
                "timestamp": Date().timeIntervalSince1970
            ]
            
            if let sessionID = sessionID {
                params["session_id"] = sessionID
            }
            
            return params
        }
    }
    
    /// Session end event - triggered when user session ends
    struct SessionEnd {
        static let name = "session_end"
        
        static func parameters(duration: Double, sessionID: String? = nil) -> [String: Any] {
            var params: [String: Any] = [
                "duration": duration,
                "timestamp": Date().timeIntervalSince1970
            ]
            
            if let sessionID = sessionID {
                params["session_id"] = sessionID
            }
            
            return params
        }
    }
    
    /// Performance metric event - triggered for performance tracking
    struct PerformanceMetric {
        static let name = "performance_metric"
        
        static func parameters(metricName: String, value: Double) -> [String: Any] {
            [
                "metric_name": metricName,
                "value": value,
                "timestamp": Date().timeIntervalSince1970
            ]
        }
    }
    
    /// Error event - triggered when errors occur
    struct ErrorOccurred {
        static let name = "error_occurred"
        
        static func parameters(errorType: String, errorMessage: String, context: String? = nil) -> [String: Any] {
            var params: [String: Any] = [
                "error_type": errorType,
                "error_message": errorMessage,
                "timestamp": Date().timeIntervalSince1970
            ]
            
            if let context = context {
                params["context"] = context
            }
            
            return params
        }
    }
    
    // MARK: - Utility Methods
    
    /// Photo capture events
    struct PhotoCapture {
        static let cameraRequested = "photo_camera_requested"
        static let libraryRequested = "photo_library_requested"
        static let uploadedSuccessfully = "photo_uploaded_successfully"
        static let uploadFailed = "photo_upload_failed"
        static let permissionDenied = "photo_permission_denied"
        static let selectionCancelled = "photo_selection_cancelled"
    }
    
    /// Share functionality events
    struct Share {
        static let tapped = "share_tapped"
        static let completed = "share_completed"
        static let cancelled = "share_cancelled"
        static let cardGenerationRequested = "share_card_generation_requested"
        static let cardGeneratedSuccessfully = "share_card_generated_successfully"
        static let cardGenerationFailed = "share_card_generation_failed"
    }
    
    /// Network connectivity events
    struct Network {
        static let connected = "network_connected"
        static let disconnected = "network_disconnected"
        static let offlineAlertShown = "network_offline_alert_shown"
        static let retryAttempted = "network_retry_attempted"
    }
    
    /// Get all available event names
    static var allEventNames: [String] {
        [
            AppOpen.name,
            SignupCompleted.name,
            ReadingRequested.name,
            ReadingCompleted.name,
            ShareTapped.name,
            SubscriptionPurchased.name,
            PaywallShown.name,
            SessionStart.name,
            SessionEnd.name,
            PerformanceMetric.name,
            ErrorOccurred.name,
            PhotoCapture.cameraRequested,
            PhotoCapture.libraryRequested,
            PhotoCapture.uploadedSuccessfully,
            PhotoCapture.uploadFailed,
            PhotoCapture.permissionDenied,
            PhotoCapture.selectionCancelled,
            Share.tapped,
            Share.completed,
            Share.cancelled,
            Share.cardGenerationRequested,
            Share.cardGeneratedSuccessfully,
            Share.cardGenerationFailed,
            Network.connected,
            Network.disconnected,
            Network.offlineAlertShown,
            Network.retryAttempted
        ]
    }
    
    /// Validate event name exists
    static func isValidEventName(_ name: String) -> Bool {
        allEventNames.contains(name)
    }
}

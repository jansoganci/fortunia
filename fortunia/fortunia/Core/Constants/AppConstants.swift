//
//  AppConstants.swift
//  fortunia
//
//  Created by Can Soğancı on 24.10.2025.
//

import Foundation

// MARK: - App Constants
struct AppConstants {
    
    // MARK: - App Information
    static let appName = "Fortunia"
    static let appVersion = "1.0.0"
    static let buildNumber = "1"
    
    // MARK: - Bundle Identifiers
    static let bundleIdentifier = "com.janstrade.fortunia"
    
    // MARK: - API Configuration
    struct API {
        static let baseURL = "https://nnejcjbzspqxsowwnzvh.supabase.co"
        static let timeout: TimeInterval = 30.0
        static let retryCount = 3
    }
    
    // MARK: - Supabase Configuration
    struct Supabase {
        static let projectID = "nnejcjbzspqxsowwnzvh"
        
        /// Supabase anonymous key - loaded from environment or Info.plist
        /// SECURITY: Never hardcode this value in source code
        static var anonKey: String {
            // Try to load from environment variable first (for CI/CD)
            if let envKey = ProcessInfo.processInfo.environment["SUPABASE_ANON_KEY"] {
                return envKey
            }
            
            // Fallback to Info.plist for local development
            guard let path = Bundle.main.path(forResource: "Info", ofType: "plist"),
                  let plist = NSDictionary(contentsOfFile: path),
                  let key = plist["SUPABASE_ANON_KEY"] as? String else {
                fatalError("SUPABASE_ANON_KEY not found in environment or Info.plist")
            }
            
            return key
        }
    }
    
    // MARK: - Firebase Configuration
    struct Firebase {
        static let projectID = "fortunia-9348a"
        static let storageBucket = "fortunia-9348a.firebasestorage.app"
    }
    
    // MARK: - Quota System
    struct Quota {
        static let dailyFreeLimit = 3
        static let resetTime = "00:00" // UTC
    }
    
    // MARK: - Fortune Reading Types
    struct FortuneTypes {
        static let faceReading = "face"
        static let palmReading = "palm"
        static let tarotReading = "tarot"
        static let coffeeReading = "coffee"
    }
    
    // MARK: - Cultural Origins
    struct CulturalOrigins {
        static let chinese = "chinese"
        static let middleEastern = "middle_eastern"
        static let european = "european"
    }
    
    // MARK: - User Defaults Keys
    struct UserDefaultsKeys {
        static let isFirstLaunch = "isFirstLaunch"
        static let lastQuotaReset = "lastQuotaReset"
        static let dailyQuotaUsed = "dailyQuotaUsed"
        static let isPremiumUser = "isPremiumUser"
        static let selectedLanguage = "selectedLanguage"
        static let notificationPermissionAsked = "notificationPermissionAsked"
        static let allowCloudProcessing = "allowCloudProcessing"
        static let analyticsEnabled = "analyticsEnabled"
    }
    
    // MARK: - Analytics Configuration
    /// Determines if analytics should be enabled
    /// In DEBUG builds: Uses UserDefaults flag (defaults to false, can be toggled for testing)
    /// In RELEASE builds: Always returns true (analytics always enabled in production)
    static var analyticsEnabled: Bool {
        #if DEBUG
        // In debug mode, check UserDefaults for explicit toggle
        // Developers can enable/disable via: UserDefaults.standard.set(true, forKey: "analyticsEnabled")
        return UserDefaults.standard.bool(forKey: UserDefaultsKeys.analyticsEnabled)
        #else
        // In production, analytics is always enabled
        return true
        #endif
    }
    
    /// Toggle analytics on/off (DEBUG only)
    #if DEBUG
    static func setAnalyticsEnabled(_ enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: UserDefaultsKeys.analyticsEnabled)
        DebugLogger.shared.network("Analytics \(enabled ? "enabled" : "disabled") in debug mode")
    }
    #endif
    
    // MARK: - Animation Durations
    struct Animation {
        static let short: Double = 0.2
        static let medium: Double = 0.3
        static let long: Double = 0.5
        static let fortuneProcessing: Double = 10.0
    }
    
    // MARK: - Image Configuration
    struct Image {
        static let maxSize: CGFloat = 1024
        static let compressionQuality: CGFloat = 0.8
        static let thumbnailSize: CGFloat = 300
    }
    
    // MARK: - UI Configuration
    struct UI {
        static let cornerRadius: CGFloat = 12
        static let shadowRadius: CGFloat = 8
        static let shadowOpacity: Double = 0.1
        static let minimumTouchTarget: CGFloat = 44
    }
    
    // MARK: - Error Messages
    struct ErrorMessages {
        static var networkError: String {
            return NSLocalizedString("error_network", comment: "Network connection error. Please check your internet connection.")
        }
        static var quotaExceeded: String {
            return NSLocalizedString("error_quota_exceeded", comment: "Daily quota exceeded. Upgrade to Premium for unlimited readings.")
        }
        static var imageProcessingError: String {
            return NSLocalizedString("error_image_processing", comment: "Failed to process image. Please try again.")
        }
        static var aiProcessingError: String {
            return NSLocalizedString("error_ai_processing", comment: "AI processing failed. Please try again.")
        }
        static var unknownError: String {
            return NSLocalizedString("error_unknown", comment: "An unexpected error occurred. Please try again.")
        }
    }
    
    // MARK: - Success Messages
    struct SuccessMessages {
        static var readingCompleted: String {
            return NSLocalizedString("success_reading_completed", comment: "Your fortune reading is ready!")
        }
        static var imageUploaded: String {
            return NSLocalizedString("success_image_uploaded", comment: "Image uploaded successfully")
        }
        static var quotaConsumed: String {
            return NSLocalizedString("success_quota_consumed", comment: "Reading completed successfully")
        }
    }
    
    // MARK: - Legal
    struct Legal {
        static let disclaimer = "For entertainment purposes only. Not a substitute for professional, medical, legal, or financial advice."
        static let privacyPolicyURL = "https://fortunia.app/privacy"
        static let termsOfServiceURL = "https://fortunia.app/terms"
        static let supportEmail = "support@fortunia.app"
    }
}

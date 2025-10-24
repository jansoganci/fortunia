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
        static let baseURL = "https://your-supabase-url.supabase.co"
        static let timeout: TimeInterval = 30.0
        static let retryCount = 3
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
    }
    
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
        static let networkError = "Network connection error. Please check your internet connection."
        static let quotaExceeded = "Daily quota exceeded. Upgrade to Premium for unlimited readings."
        static let imageProcessingError = "Failed to process image. Please try again."
        static let aiProcessingError = "AI processing failed. Please try again."
        static let unknownError = "An unexpected error occurred. Please try again."
    }
    
    // MARK: - Success Messages
    struct SuccessMessages {
        static let readingCompleted = "Your fortune reading is ready!"
        static let imageUploaded = "Image uploaded successfully"
        static let quotaConsumed = "Reading completed successfully"
    }
    
    // MARK: - Legal
    struct Legal {
        static let disclaimer = "For entertainment purposes only. Not a substitute for professional, medical, legal, or financial advice."
        static let privacyPolicyURL = "https://fortunia.app/privacy"
        static let termsOfServiceURL = "https://fortunia.app/terms"
        static let supportEmail = "support@fortunia.app"
    }
}

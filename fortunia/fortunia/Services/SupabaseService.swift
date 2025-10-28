//
//  SupabaseService.swift
//  fortunia
//
//  Created by Cursor AI on December 19, 2024
//

import Foundation
import Supabase
import UIKit

// MARK: - Supabase Service Constants
extension SupabaseService {
    
    // MARK: - Storage Configuration
    struct Storage {
        static let bucketName = "fortune-images-prod"
        static let readingsFolder = "readings"
        static let imageCompressionQuality: CGFloat = 0.8
        static let maxImageSize: CGFloat = 1024
    }
    
    // MARK: - Edge Function Names
    struct EdgeFunctions {
        static let processFaceReading = "process-face-reading"
        static let processPalmReading = "process-palm-reading"
        static let processTarotReading = "process-tarot-reading"
        static let processCoffeeReading = "process-coffee-reading"
        static let getUserQuota = "get-user-quota"
        static let consumeQuota = "consume-quota"
    }
    
    // MARK: - Error Messages
    struct ErrorMessages {
        static let invalidImageData = NSLocalizedString("supabase_invalid_image_data", comment: "Failed to compress image data") // localized
        static let uploadFailed = NSLocalizedString("supabase_upload_failed", comment: "Image upload failed") // localized
        static let invalidURL = NSLocalizedString("supabase_invalid_url", comment: "Invalid Supabase URL configuration") // localized
        static let functionInvocationFailed = NSLocalizedString("supabase_function_failed", comment: "Edge function failed") // localized
        static let authenticationFailed = NSLocalizedString("supabase_auth_failed", comment: "Authentication failed") // localized
        static let networkError = NSLocalizedString("supabase_network_error", comment: "Network connection error") // localized
        static let quotaExceeded = NSLocalizedString("supabase_quota_exceeded", comment: "Daily quota exceeded") // localized
        static let aiProcessingFailed = NSLocalizedString("supabase_ai_failed", comment: "AI processing failed") // localized
    }
    
    // MARK: - Success Messages
    struct SuccessMessages {
        static let imageUploaded = NSLocalizedString("supabase_image_uploaded", comment: "Image uploaded successfully") // localized
        static let functionExecuted = NSLocalizedString("supabase_function_executed", comment: "Edge function executed successfully") // localized
        static let authenticationSuccess = NSLocalizedString("supabase_auth_success", comment: "Authentication successful") // localized
        static let quotaConsumed = NSLocalizedString("supabase_quota_consumed", comment: "Quota consumed successfully") // localized
    }
    
    // MARK: - Cultural Origins
    struct CulturalOrigins {
        static let chinese = "chinese"
        static let middleEastern = "middle_eastern"
        static let european = "european"
        
        static let allOrigins = [chinese, middleEastern, european]
    }
    
    // MARK: - Reading Types
    struct ReadingTypes {
        static let face = "face"
        static let palm = "palm"
        static let tarot = "tarot"
        static let coffee = "coffee"
        
        static let allTypes = [face, palm, tarot, coffee]
    }
}

// MARK: - Supabase Service
/// SupabaseService provides shared infrastructure for all Supabase operations in the Fortunia app.
/// 
/// This service provides:
/// - SupabaseClient instance for all other services
/// - Configuration structs (Storage, EdgeFunctions, ErrorMessages, etc.)
/// - Error logging and debugging utilities
/// - Shared constants and enums
///
/// For specific operations, use the dedicated services:
/// - AuthService.shared for authentication operations
/// - StorageService.shared for image upload operations
/// - FunctionService.shared for edge function invocations
/// - AIProcessingService.shared for AI-powered fortune reading
///
/// Usage:
/// ```swift
/// let supabase = SupabaseService.shared
/// let client = supabase.supabase // Access to SupabaseClient
/// ```
///
/// - Note: This service uses a singleton pattern and should be accessed via `SupabaseService.shared`
/// - Important: This is now a shared infrastructure service, not a direct operation service
class SupabaseService: ObservableObject {
    
    // MARK: - Singleton
    /// Shared instance of SupabaseService
    /// 
    /// Use this singleton instance throughout the app to access Supabase functionality.
    /// The singleton pattern ensures consistent configuration and state management.
    static let shared = SupabaseService()
    
    // MARK: - Supabase Client
    /// Private Supabase client instance
    /// 
    /// This client is initialized with configuration from AppConstants and handles
    /// all communication with Supabase services including auth, storage, and functions.
    private let _supabase: SupabaseClient?
    
    @Published var isConfigured = false
    
    /// Public access to the Supabase client for service dependencies
    var supabase: SupabaseClient? {
        return _supabase
    }
    
    // MARK: - Private Initializer
    /// Private initializer for singleton pattern
    /// 
    /// Initializes the Supabase client with configuration from AppConstants.
    /// Uses graceful error handling instead of fatalError for production safety.
    private init() {
        // Initialize Supabase client with configuration from AppConstants
        guard let supabaseURL = URL(string: AppConstants.API.baseURL) else {
            // Use custom error instead of fatalError to prevent production crashes
            LocalizedDebugLogger.shared.logDebug("SUPABASE", "Invalid Supabase URL in AppConstants.API.baseURL")
            self._supabase = nil
            self.isConfigured = false
            return
        }
        
        // Use Supabase configuration from AppConstants (centralized configuration)
        let supabaseAnonKey = AppConstants.Supabase.anonKey
        
        self._supabase = SupabaseClient(
            supabaseURL: supabaseURL,
            supabaseKey: supabaseAnonKey
        )
        
        self.isConfigured = true
        // Log successful initialization
        LocalizedDebugLogger.shared.logDebug("SUPABASE", "Client initialized with URL: \(supabaseURL)")
    }
    
    // MARK: - Shared Infrastructure
    // Authentication, Storage, and Function operations have been moved to dedicated services:
    // - AuthService.shared for authentication operations
    // - StorageService.shared for image upload operations  
    // - FunctionService.shared for edge function invocations
    // - AIProcessingService.shared for AI-powered fortune reading
    
    // MARK: - Error Logging Methods
    
    /// Log authentication errors with detailed context
    /// - Parameters:
    ///   - error: The error that occurred
    ///   - action: The authentication action being performed
    ///   - email: The email address (if available)
    func logAuthError(_ error: Error, action: String, email: String?) {
        let errorInfo = [
            "auth_action": action,
            "email": email ?? "unknown",
            "error_type": "authentication",
            "timestamp": ISO8601DateFormatter().string(from: Date()),
            "error_description": error.localizedDescription
        ] as [String: Any]
        
        LocalizedDebugLogger.shared.logDebug("SUPABASE", "AUTH_ERROR \(action): \(error.localizedDescription)")
        LocalizedDebugLogger.shared.logDebug("SUPABASE", "AUTH_ERROR Context: \(errorInfo)")
        
        // Integrate with AnalyticsService for Crashlytics
        AnalyticsService.shared.logCrash(error, context: "auth_\(action)")
    }
    
    /// Log network errors with detailed context
    /// - Parameters:
    ///   - error: The error that occurred
    ///   - endpoint: The endpoint that failed
    ///   - context: Additional context about the operation
    func logNetworkError(_ error: Error, endpoint: String, context: String) {
        let errorInfo = [
            "endpoint": endpoint,
            "context": context,
            "error_type": "network",
            "timestamp": ISO8601DateFormatter().string(from: Date()),
            "error_description": error.localizedDescription
        ] as [String: Any]
        
        LocalizedDebugLogger.shared.logDebug("SUPABASE", "NETWORK_ERROR \(endpoint): \(error.localizedDescription)")
        LocalizedDebugLogger.shared.logDebug("SUPABASE", "NETWORK_ERROR Context: \(errorInfo)")
        
        // Integrate with AnalyticsService for Crashlytics
        AnalyticsService.shared.logCrash(error, context: "network_\(endpoint)")
        // ErrorLogger.shared.logNetworkError(error, endpoint: endpoint)
    }
    
    /// Log AI processing errors with detailed context
    /// - Parameters:
    ///   - error: The error that occurred
    ///   - readingType: Type of reading being processed
    ///   - culturalOrigin: Cultural origin of the reading
    func logAIError(_ error: Error, readingType: String, culturalOrigin: String) {
        let errorInfo = [
            "reading_type": readingType,
            "cultural_origin": culturalOrigin,
            "error_type": "ai_processing",
            "timestamp": ISO8601DateFormatter().string(from: Date()),
            "error_description": error.localizedDescription
        ] as [String: Any]
        
        LocalizedDebugLogger.shared.logDebug("SUPABASE", "AI_ERROR \(readingType) (\(culturalOrigin)): \(error.localizedDescription)")
        LocalizedDebugLogger.shared.logDebug("SUPABASE", "AI_ERROR Context: \(errorInfo)")
        
        // Integrate with AnalyticsService for Crashlytics
        AnalyticsService.shared.logCrash(error, context: "ai_\(readingType)_\(culturalOrigin)")
    }
    
}

// MARK: - Supabase Errors
enum SupabaseError: Error, LocalizedError {
    case invalidImageData
    case uploadFailed(String)
    case invalidURL
    case functionInvocationFailed(String, String)
    case authenticationFailed
    
    var errorDescription: String? {
        switch self {
        case .invalidImageData:
            return NSLocalizedString("supabase_invalid_image_data", comment: "Failed to compress image data") // localized
        case .uploadFailed(let message):
            let localizedUploadFailed = NSLocalizedString("supabase_upload_failed", comment: "Image upload failed") // localized
            return "\(localizedUploadFailed): \(message)"
        case .invalidURL:
            return NSLocalizedString("supabase_invalid_url", comment: "Invalid Supabase URL configuration") // localized
        case .functionInvocationFailed(let functionName, let message):
            let localizedFunctionFailed = NSLocalizedString("supabase_function_failed", comment: "Edge function failed") // localized
            return "\(localizedFunctionFailed) '\(functionName)': \(message)"
        case .authenticationFailed:
            return NSLocalizedString("supabase_auth_failed", comment: "Authentication failed") // localized
        }
    }
}

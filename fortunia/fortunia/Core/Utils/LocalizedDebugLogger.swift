//
//  LocalizedDebugLogger.swift
//  fortunia
//
//  Created by Can Soğancı on 24.10.2025.
//

import Foundation

/// LocalizedDebugLogger - Localized debug logging system
/// Provides localized debug messages for development and production builds
/// Respects user's language preference and debug settings
final class LocalizedDebugLogger {
    
    // MARK: - Singleton
    static let shared = LocalizedDebugLogger()
    private init() {}
    
    // MARK: - Properties
    private var isDebugMode: Bool {
        #if DEBUG
        return true
        #else
        return UserDefaults.standard.bool(forKey: "DebugLoggingEnabled")
        #endif
    }
    
    // MARK: - Logging Methods
    
    /// Log authentication events with localized messages
    /// - Parameters:
    ///   - action: Authentication action being performed
    ///   - email: User email (optional)
    ///   - success: Whether the action was successful
    func logAuth(_ action: String, email: String? = nil, success: Bool = true) {
        guard isDebugMode else { return }
        
        let message = success ? 
            NSLocalizedString("debug_auth_success", comment: "Authentication success message") :
            NSLocalizedString("debug_auth_failed", comment: "Authentication failure message")
        
        let localizedAction = getLocalizedAuthAction(action)
        let emailText = email != nil ? " (\(email!))" : ""
        
        print("🔐 [AUTH] \(localizedAction): \(message)\(emailText)")
    }
    
    /// Log AI processing events with localized messages
    /// - Parameters:
    ///   - readingType: Type of reading being processed
    ///   - culturalOrigin: Cultural origin of the reading
    ///   - success: Whether the processing was successful
    func logAI(_ readingType: String, culturalOrigin: String, success: Bool = true) {
        guard isDebugMode else { return }
        
        let message = success ?
            NSLocalizedString("debug_ai_success", comment: "AI processing success message") :
            NSLocalizedString("debug_ai_failed", comment: "AI processing failure message")
        
        let localizedType = getLocalizedReadingType(readingType)
        let localizedOrigin = getLocalizedCulturalOrigin(culturalOrigin)
        
        print("🔮 [AI] \(localizedType) (\(localizedOrigin)): \(message)")
    }
    
    /// Log network events with localized messages
    /// - Parameters:
    ///   - endpoint: Network endpoint
    ///   - success: Whether the request was successful
    func logNetwork(_ endpoint: String, success: Bool = true) {
        guard isDebugMode else { return }
        
        let message = success ?
            NSLocalizedString("debug_network_success", comment: "Network success message") :
            NSLocalizedString("debug_network_failed", comment: "Network failure message")
        
        print("🌐 [NETWORK] \(endpoint): \(message)")
    }
    
    /// Log storage events with localized messages
    /// - Parameters:
    ///   - action: Storage action being performed
    ///   - success: Whether the action was successful
    func logStorage(_ action: String, success: Bool = true) {
        guard isDebugMode else { return }
        
        let message = success ?
            NSLocalizedString("debug_storage_success", comment: "Storage success message") :
            NSLocalizedString("debug_storage_failed", comment: "Storage failure message")
        
        let localizedAction = getLocalizedStorageAction(action)
        print("📸 [STORAGE] \(localizedAction): \(message)")
    }
    
    /// Log edge function events with localized messages
    /// - Parameters:
    ///   - functionName: Name of the edge function
    ///   - success: Whether the function executed successfully
    func logEdgeFunction(_ functionName: String, success: Bool = true) {
        guard isDebugMode else { return }
        
        let message = success ?
            NSLocalizedString("debug_edge_success", comment: "Edge function success message") :
            NSLocalizedString("debug_edge_failed", comment: "Edge function failure message")
        
        print("⚡ [EDGE] \(functionName): \(message)")
    }
    
    /// Log general debug information with localized messages
    /// - Parameters:
    ///   - category: Debug category
    ///   - message: Debug message
    func logDebug(_ category: String, _ message: String) {
        guard isDebugMode else { return }
        
        let localizedCategory = getLocalizedCategory(category)
        print("🔧 [\(localizedCategory)] \(message)")
    }
    
    // MARK: - Helper Methods
    
    /// Get localized authentication action
    private func getLocalizedAuthAction(_ action: String) -> String {
        switch action {
        case "signUp": return NSLocalizedString("debug_auth_signup", comment: "Sign up action")
        case "signIn": return NSLocalizedString("debug_auth_signin", comment: "Sign in action")
        case "signOut": return NSLocalizedString("debug_auth_signout", comment: "Sign out action")
        case "resetPassword": return NSLocalizedString("debug_auth_reset", comment: "Password reset action")
        case "refreshSession": return NSLocalizedString("debug_auth_refresh", comment: "Session refresh action")
        case "deleteAccount": return NSLocalizedString("debug_auth_delete", comment: "Account deletion action")
        default: return action
        }
    }
    
    /// Get localized reading type
    private func getLocalizedReadingType(_ type: String) -> String {
        switch type {
        case "face": return NSLocalizedString("reading_type_face", comment: "Face Reading")
        case "palm": return NSLocalizedString("reading_type_palm", comment: "Palm Reading")
        case "tarot": return NSLocalizedString("reading_type_tarot", comment: "Tarot Reading")
        case "coffee": return NSLocalizedString("reading_type_coffee", comment: "Coffee Reading")
        default: return type
        }
    }
    
    /// Get localized cultural origin
    private func getLocalizedCulturalOrigin(_ origin: String) -> String {
        switch origin {
        case "chinese": return NSLocalizedString("cultural_origin_chinese", comment: "Chinese")
        case "middle_eastern": return NSLocalizedString("cultural_origin_middle_eastern", comment: "Middle Eastern")
        case "european": return NSLocalizedString("cultural_origin_european", comment: "European")
        case "turkish": return NSLocalizedString("cultural_origin_turkish", comment: "Turkish")
        default: return origin
        }
    }
    
    /// Get localized storage action
    private func getLocalizedStorageAction(_ action: String) -> String {
        switch action {
        case "upload": return NSLocalizedString("debug_storage_upload", comment: "Upload action")
        case "download": return NSLocalizedString("debug_storage_download", comment: "Download action")
        case "delete": return NSLocalizedString("debug_storage_delete", comment: "Delete action")
        default: return action
        }
    }
    
    /// Get localized debug category
    private func getLocalizedCategory(_ category: String) -> String {
        switch category {
        case "SUPABASE": return NSLocalizedString("debug_category_supabase", comment: "Supabase category")
        case "ANALYTICS": return NSLocalizedString("debug_category_analytics", comment: "Analytics category")
        case "PERFORMANCE": return NSLocalizedString("debug_category_performance", comment: "Performance category")
        default: return category
        }
    }
}

//
//  AIProcessingService.swift
//  fortunia
//
//  Created by Cursor AI on December 19, 2024
//

import Foundation
import UIKit

// MARK: - AI Processing Service
/// AIProcessingService handles all AI-powered fortune reading operations in the Fortunia app.
/// 
/// This service provides:
/// - Face reading processing using AI analysis
/// - Palm reading processing using AI analysis
/// - Tarot reading processing using AI analysis
/// - Coffee reading processing using AI analysis
/// - Integration with StorageService and FunctionService
///
/// Dependencies:
/// - StorageService.shared for image upload operations
/// - FunctionService.shared for edge function invocations
/// - SupabaseService.shared for error logging
///
/// Usage:
/// ```swift
/// let aiService = AIProcessingService.shared
/// let result = try await aiService.processFaceReading(image: faceImage, culturalOrigin: "chinese")
/// ```
///
/// - Note: This service uses a singleton pattern and should be accessed via `AIProcessingService.shared`
/// - Important: All methods are async and should be called with proper error handling
class AIProcessingService: ObservableObject {
    
    // MARK: - Singleton
    /// Shared instance of AIProcessingService
    /// 
    /// Use this singleton instance throughout the app to access AI processing functionality.
    /// The singleton pattern ensures consistent state management across the app.
    static let shared = AIProcessingService()
    
    // MARK: - Private Initializer
    /// Private initializer for singleton pattern
    private init() {}
    
    // MARK: - AI Processing Methods
    
    /// Process face reading using AI analysis
    /// - Parameters:
    ///   - imageData: Data of the face to analyze
    ///   - culturalOrigin: Cultural origin for the reading (chinese, middle_eastern, european)
    /// - Returns: FortuneResult containing the reading text and metadata
    /// - Throws: SupabaseError for processing failures
    func processFaceReading(imageData: Data, culturalOrigin: String) async throws -> FortuneResult {
        print("🔥 [AI PROCESSING] processFaceReading START - Image size: \(imageData.count) bytes, Origin: \(culturalOrigin)")
        LocalizedDebugLogger.shared.logAI("face", culturalOrigin: culturalOrigin, success: false)
        
        do {
            // Get current user ID (guest or authenticated)
            let userId = AuthService.shared.currentUserId ?? UserDefaults.standard.string(forKey: "guest_user_id")
            
            guard let userId = userId else {
                print("🔥 [AI PROCESSING] ❌ No user ID found!")
                throw NSError(domain: "AIProcessingError", code: -1, userInfo: [NSLocalizedDescriptionKey: "User ID not found"])
            }
            print("🔥 [AI PROCESSING] User ID: \(userId)")
            
            // 1. Upload image using StorageService
            print("🔥 [AI PROCESSING] [STEP 1/4] Uploading image via StorageService...")
            let imageUrl = try await StorageService.shared.uploadImage(imageData)
            print("🔥 [AI PROCESSING] [STEP 1/4] ✅ Image uploaded! URL: \(imageUrl)")
            
            // 2. Call Edge Function "process-face-reading" using FunctionService
            print("🔥 [AI PROCESSING] [STEP 2/4] Calling Edge Function: process-face-reading")
            let parameters: [String: Any] = [
                "image_url": imageUrl,
                "user_id": userId,
                "cultural_origin": culturalOrigin,
                "reading_type": "face"
            ]
            print("🔥 [AI PROCESSING] Parameters: \(parameters)")
            
            print("🔥 [AI PROCESSING] [STEP 3/4] Invoking edge function...")
            let responseData = try await FunctionService.shared.invokeEdgeFunction(
                name: SupabaseService.EdgeFunctions.processFaceReading,
                parameters: parameters
            )
            print("🔥 [AI PROCESSING] [STEP 3/4] ✅ Edge function returned! Response size: \(responseData.count) bytes")
            
            // 3. Parse response and return FortuneResult
            print("🔥 [AI PROCESSING] [STEP 4/4] Parsing FortuneResult...")
            let result = try JSONDecoder().decode(FortuneResult.self, from: responseData)
            print("🔥 [AI PROCESSING] [STEP 4/4] ✅ FortuneResult parsed successfully!")
            
            LocalizedDebugLogger.shared.logAI("face", culturalOrigin: culturalOrigin, success: true)
            return result
            
        } catch {
            print("🔥 [AI PROCESSING] ❌ ERROR: \(error)")
            print("🔥 [AI PROCESSING] ❌ Error type: \(type(of: error))")
            LocalizedDebugLogger.shared.logAI("face", culturalOrigin: culturalOrigin, success: false)
            // Log detailed error information for debugging
            SupabaseService.shared.logAIError(error, readingType: "face", culturalOrigin: culturalOrigin)
            throw error
        }
    }
    
    /// Process palm reading using AI analysis
    /// - Parameters:
    ///   - imageData: Data of the palm to analyze
    ///   - culturalOrigin: Cultural origin for the reading
    /// - Returns: FortuneResult containing the reading text and metadata
    /// - Throws: SupabaseError for processing failures
    func processPalmReading(imageData: Data, culturalOrigin: String) async throws -> FortuneResult {
        LocalizedDebugLogger.shared.logAI("palm", culturalOrigin: culturalOrigin, success: false)
        
        do {
            // Get current user ID (guest or authenticated)
            let userId = AuthService.shared.currentUserId ?? UserDefaults.standard.string(forKey: "guest_user_id")
            
            guard let userId = userId else {
                throw NSError(domain: "AIProcessingError", code: -1, userInfo: [NSLocalizedDescriptionKey: "User ID not found"])
            }
            
            // 1. Upload image using StorageService
            let imageUrl = try await StorageService.shared.uploadImage(imageData)
            
            // 2. Call Edge Function "process-palm-reading" using FunctionService
            let parameters: [String: Any] = [
                "image_url": imageUrl,
                "user_id": userId,
                "cultural_origin": culturalOrigin,
                "reading_type": "palm"
            ]
            
            let responseData = try await FunctionService.shared.invokeEdgeFunction(
                name: SupabaseService.EdgeFunctions.processPalmReading,
                parameters: parameters
            )
            
            // 3. Parse response and return FortuneResult
            let result = try JSONDecoder().decode(FortuneResult.self, from: responseData)
            LocalizedDebugLogger.shared.logAI("palm", culturalOrigin: culturalOrigin, success: true)
            return result
            
        } catch {
            LocalizedDebugLogger.shared.logAI("palm", culturalOrigin: culturalOrigin, success: false)
            // Log detailed error information for debugging
            SupabaseService.shared.logAIError(error, readingType: "palm", culturalOrigin: culturalOrigin)
            throw error
        }
    }
    
    /// Process tarot reading using AI analysis
    /// - Parameters:
    ///   - culturalOrigin: Cultural origin for the reading
    /// - Returns: FortuneResult containing the reading text and metadata
    /// - Throws: SupabaseError for processing failures
    func processTarotReading(culturalOrigin: String) async throws -> FortuneResult {
        LocalizedDebugLogger.shared.logAI("tarot", culturalOrigin: culturalOrigin, success: false)
        
        do {
            // 1. Call Edge Function "process-tarot-reading" using FunctionService
            let parameters: [String: Any] = [
                "cultural_origin": culturalOrigin,
                "reading_type": "tarot"
            ]
            
            let responseData = try await FunctionService.shared.invokeEdgeFunction(
                name: SupabaseService.EdgeFunctions.processTarotReading,
                parameters: parameters
            )
            
            // 2. Parse response and return FortuneResult
            let result = try JSONDecoder().decode(FortuneResult.self, from: responseData)
            LocalizedDebugLogger.shared.logAI("tarot", culturalOrigin: culturalOrigin, success: true)
            return result
            
        } catch {
            LocalizedDebugLogger.shared.logAI("tarot", culturalOrigin: culturalOrigin, success: false)
            // Log detailed error information for debugging
            SupabaseService.shared.logAIError(error, readingType: "tarot", culturalOrigin: culturalOrigin)
            throw error
        }
    }
    
    /// Process coffee reading using AI analysis
    /// - Parameters:
    ///   - imageData: Data of the coffee grounds to analyze
    ///   - culturalOrigin: Cultural origin for the reading
    /// - Returns: FortuneResult containing the reading text and metadata
    /// - Throws: SupabaseError for processing failures
    func processCoffeeReading(imageData: Data, culturalOrigin: String) async throws -> FortuneResult {
        LocalizedDebugLogger.shared.logAI("coffee", culturalOrigin: culturalOrigin, success: false)
        
        do {
            // Get current user ID (guest or authenticated)
            let userId = AuthService.shared.currentUserId ?? UserDefaults.standard.string(forKey: "guest_user_id")
            
            guard let userId = userId else {
                throw NSError(domain: "AIProcessingError", code: -1, userInfo: [NSLocalizedDescriptionKey: "User ID not found"])
            }
            
            // 1. Upload image using StorageService
            let imageUrl = try await StorageService.shared.uploadImage(imageData)
            
            // 2. Call Edge Function "process-coffee-reading" using FunctionService
            let parameters: [String: Any] = [
                "image_url": imageUrl,
                "user_id": userId,
                "cultural_origin": culturalOrigin,
                "reading_type": "coffee"
            ]
            
            let responseData = try await FunctionService.shared.invokeEdgeFunction(
                name: SupabaseService.EdgeFunctions.processCoffeeReading,
                parameters: parameters
            )
            
            // 3. Parse response and return FortuneResult
            let result = try JSONDecoder().decode(FortuneResult.self, from: responseData)
            LocalizedDebugLogger.shared.logAI("coffee", culturalOrigin: culturalOrigin, success: true)
            return result
            
        } catch {
            LocalizedDebugLogger.shared.logAI("coffee", culturalOrigin: culturalOrigin, success: false)
            // Log detailed error information for debugging
            SupabaseService.shared.logAIError(error, readingType: "coffee", culturalOrigin: culturalOrigin)
            throw error
        }
    }
}

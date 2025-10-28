//
//  StorageService.swift
//  fortunia
//
//  Created by Cursor AI on December 19, 2024
//

import Foundation
import UIKit
import Supabase

// MARK: - Storage Service
/// StorageService handles all file and image upload operations in the Fortunia app.
/// 
/// This service provides:
/// - Image compression and upload to Supabase Storage
/// - Public URL generation for uploaded files
/// - Error handling and logging for storage operations
///
/// Dependencies:
/// - SupabaseService.shared for Supabase client access
/// - SupabaseService.shared for storage configuration and error logging
///
/// Usage:
/// ```swift
/// let storageService = StorageService.shared
/// let imageUrl = try await storageService.uploadImage(image)
/// ```
///
/// - Note: This service uses a singleton pattern and should be accessed via `StorageService.shared`
/// - Important: All methods are async and should be called with proper error handling
class StorageService: ObservableObject {
    
    // MARK: - Singleton
    /// Shared instance of StorageService
    /// 
    /// Use this singleton instance throughout the app to access storage functionality.
    /// The singleton pattern ensures consistent state management across the app.
    static let shared = StorageService()
    
    // MARK: - Private Initializer
    /// Private initializer for singleton pattern
    private init() {}
    
    // MARK: - Image Upload Methods
    
    /// Upload an image to Supabase Storage
    /// - Parameter image: UIImage to upload
    /// - Returns: Public URL string for the uploaded image
    /// - Throws: SupabaseStorageError for upload failures
    func uploadImage(_ imageData: Data) async throws -> String {
        print("🔥 [STORAGE] uploadImage called - Size: \(imageData.count) bytes")
        LocalizedDebugLogger.shared.logStorage("upload", success: false)
        
        do {
            print("🔥 [STORAGE] [STEP 1/4] Checking image data size: \(imageData.count) bytes")
            LocalizedDebugLogger.shared.logDebug("STORAGE", "Image data size: \(imageData.count) bytes")
            
            // Generate unique filename
            let fileName = "\(UUID().uuidString).jpg"
            let filePath = "\(SupabaseService.Storage.readingsFolder)/\(fileName)"
            print("🔥 [STORAGE] [STEP 2/4] Generated file path: \(filePath)")
            LocalizedDebugLogger.shared.logDebug("STORAGE", "Uploading to path: \(filePath)")
            
            // Upload to Supabase Storage using SupabaseService's client
            guard let supabase = SupabaseService.shared.supabase else {
                print("🔥 [STORAGE] ❌ Supabase client not configured!")
                throw SupabaseError.authenticationFailed
            }
            
            print("🔥 [STORAGE] [STEP 3/4] Uploading to bucket: \(SupabaseService.Storage.bucketName)")
            try await supabase.storage
                .from(SupabaseService.Storage.bucketName)
                .upload(filePath, data: imageData)
            print("🔥 [STORAGE] [STEP 3/4] ✅ Upload successful!")
            
            // Get public URL using Supabase's built-in method (safer than manual string construction)
            print("🔥 [STORAGE] [STEP 4/4] Getting public URL")
            let imageUrl = try supabase.storage
                .from(SupabaseService.Storage.bucketName)
                .getPublicURL(path: filePath)
                .absoluteString
            print("🔥 [STORAGE] [STEP 4/4] ✅ Public URL: \(imageUrl)")
            
            LocalizedDebugLogger.shared.logStorage("upload", success: true)
            return imageUrl
            
        } catch {
            print("🔥 [STORAGE] ❌ ERROR: \(error)")
            print("🔥 [STORAGE] ❌ Error type: \(type(of: error))")
            LocalizedDebugLogger.shared.logStorage("upload", success: false)
            // Log detailed error information for debugging
            SupabaseService.shared.logNetworkError(error, endpoint: "image-upload", context: "uploadImage")
            throw error
        }
    }
}

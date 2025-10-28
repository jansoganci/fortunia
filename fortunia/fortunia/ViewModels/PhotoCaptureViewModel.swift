//
//  PhotoCaptureViewModel.swift
//  fortunia
//
//  Created by Cursor AI on December 19, 2024
//

import SwiftUI
import UIKit
import AVFoundation
import Photos

/// PhotoCaptureViewModel handles camera and photo library functionality
/// Manages permissions, image selection, and upload to StorageService
@MainActor
class PhotoCaptureViewModel: NSObject, ObservableObject {
    
    // MARK: - Published Properties
    @Published var selectedImageData: Data?
    @Published var isProcessing = false
    @Published var errorMessage: String?
    @Published var showImagePicker = false
    @Published var sourceType: UIImagePickerController.SourceType = .camera
    @Published var uploadedImageUrl: String?
    
    // Permission-related published properties
    @Published var showPermissionRationale = false
    @Published var showPermissionDenied = false
    @Published var permissionType: PermissionType = .camera
    
    // MARK: - Private Properties
    private let storageService = StorageService.shared
    private let analyticsService = AnalyticsService.shared
    
    // MARK: - Public Methods
    
    /// Take photo using camera
    func takePhoto() {
        Task {
            permissionType = .camera
            
            // Check current authorization status
            let status = AVCaptureDevice.authorizationStatus(for: .video)
            
            switch status {
            case .authorized:
                // Already authorized, show camera
                sourceType = .camera
                showImagePicker = true
                analyticsService.logEvent("photo_camera_requested")
                
            case .notDetermined:
                // Show rationale modal first
                showPermissionRationale = true
                analyticsService.logEvent("photo_camera_rationale_shown")
                
            case .denied, .restricted:
                // Show settings alert
                showPermissionDenied = true
                analyticsService.logEvent("photo_camera_denied_shown")
            @unknown default:
                showPermissionDenied = true
            }
        }
    }
    
    /// Select photo from library
    func selectFromLibrary() {
        Task {
            permissionType = .photoLibrary
            
            // Check current authorization status
            let status = PHPhotoLibrary.authorizationStatus()
            
            switch status {
            case .authorized, .limited:
                // Already authorized, show library
                sourceType = .photoLibrary
                showImagePicker = true
                analyticsService.logEvent("photo_library_requested")
                
            case .notDetermined:
                // Show rationale modal first
                showPermissionRationale = true
                analyticsService.logEvent("photo_library_rationale_shown")
                
            case .denied, .restricted:
                // Show settings alert
                showPermissionDenied = true
                analyticsService.logEvent("photo_library_denied_shown")
            @unknown default:
                showPermissionDenied = true
            }
        }
    }
    
    /// Handle permission rationale - user tapped "Allow"
    func handlePermissionAllow() {
        showPermissionRationale = false
        
        Task {
            let hasPermission = permissionType == .camera
                ? await requestCameraPermission()
                : await requestPhotoLibraryPermission()
            
            if hasPermission {
                sourceType = permissionType == .camera ? .camera : .photoLibrary
                showImagePicker = true
                analyticsService.logEvent("photo_permission_granted", parameters: [
                    "type": permissionType == .camera ? "camera" : "library"
                ])
            }
        }
    }
    
    /// Handle permission rationale - user tapped "Not Now"
    func handlePermissionDeny() {
        showPermissionRationale = false
        analyticsService.logEvent("photo_permission_declined", parameters: [
            "type": permissionType == .camera ? "camera" : "library"
        ])
    }
    
    /// Open Settings app
    func openSettings() {
        showPermissionDenied = false
        
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
            analyticsService.logEvent("photo_settings_opened", parameters: [
                "type": permissionType == .camera ? "camera" : "library"
            ])
        }
    }
    
    /// Cancel permission alert
    func cancelPermissionAlert() {
        showPermissionDenied = false
    }
    
    /// Process selected image and upload to storage
    func processSelectedImage(_ imageData: Data) {
        print("🔥 [PHOTO CAPTURE] processSelectedImage called - Image size: \(imageData.count) bytes")
        selectedImageData = imageData
        isProcessing = true
        errorMessage = nil
        
        Task {
            do {
                print("🔥 [PHOTO CAPTURE] [STEP 1/3] Starting image resize/compression")
                // Resize and compress image data in the background
                let resizedImageData = await resizeImage(imageData: imageData)
                print("🔥 [PHOTO CAPTURE] [STEP 1/3] ✅ Image resized: \(resizedImageData.count) bytes")
                
                print("🔥 [PHOTO CAPTURE] [STEP 2/3] Starting image upload to StorageService")
                // Upload image using StorageService
                let imageUrl = try await storageService.uploadImage(resizedImageData)
                print("🔥 [PHOTO CAPTURE] [STEP 2/3] ✅ Image uploaded successfully! URL: \(imageUrl)")
                
                uploadedImageUrl = imageUrl
                print("🔥 [PHOTO CAPTURE] [STEP 3/3] ✅ uploadedImageUrl set: \(imageUrl)")
                
                // Log successful upload
                analyticsService.logEvent("photo_uploaded_successfully", parameters: [
                    "source": sourceType == .camera ? "camera" : "library"
                ])
                
                isProcessing = false
                print("🔥 [PHOTO CAPTURE] ✅ All steps completed successfully")
                
            } catch {
                print("🔥 [PHOTO CAPTURE] ❌ ERROR at step 2: \(error)")
                print("🔥 [PHOTO CAPTURE] ❌ Error details: \(error.localizedDescription)")
                
                // Handle upload error
                isProcessing = false
                errorMessage = NSLocalizedString("photo_upload_error", comment: "Failed to upload photo")
                
                analyticsService.logEvent("photo_upload_failed", parameters: [
                    "error": error.localizedDescription,
                    "source": sourceType == .camera ? "camera" : "library"
                ])
            }
        }
    }
    
    /// Clear selected image and reset state
    func clearSelection() {
        selectedImageData = nil
        uploadedImageUrl = nil
        errorMessage = nil
        isProcessing = false
    }
    
    // MARK: - Private Methods
    
    private func resizeImage(imageData: Data) async -> Data {
        guard let image = UIImage(data: imageData) else {
            return imageData
        }
        
        let targetSize = CGSize(width: 1080, height: 1920)
        let imageSize = image.size
        
        if imageSize.width <= targetSize.width && imageSize.height <= targetSize.height {
            return imageData
        }
        
        return await Task.detached(priority: .userInitiated) {
            let newImage = image.preparingThumbnail(of: targetSize) ?? image
            return newImage.jpegData(compressionQuality: 0.8) ?? imageData
        }.value
    }
    
    /// Request camera permission
    private func requestCameraPermission() async -> Bool {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch status {
        case .authorized:
            return true
        case .notDetermined:
            return await AVCaptureDevice.requestAccess(for: .video)
        case .denied, .restricted:
            return false
        @unknown default:
            return false
        }
    }
    
    /// Request photo library permission
    private func requestPhotoLibraryPermission() async -> Bool {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        
        switch status {
        case .authorized, .limited:
            return true
        case .notDetermined:
            let newStatus = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
            return newStatus == .authorized || newStatus == .limited
        case .denied, .restricted:
            return false
        @unknown default:
            return false
        }
    }
    
}

// MARK: - UIImagePickerControllerDelegate
extension PhotoCaptureViewModel: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        showImagePicker = false
        
        guard let image = info[.originalImage] as? UIImage,
              let imageData = image.jpegData(compressionQuality: 0.8) else {
            errorMessage = NSLocalizedString("photo_invalid_image", comment: "Invalid image selected")
            return
        }
        
        // Process the selected image
        processSelectedImage(imageData)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        showImagePicker = false
        analyticsService.logEvent("photo_selection_cancelled", parameters: [
            "source": sourceType == .camera ? "camera" : "library"
        ])
    }
}

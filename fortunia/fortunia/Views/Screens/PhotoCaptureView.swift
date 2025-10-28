
//
//  PhotoCaptureView.swift
//  fortunia
//
//  Created by Can Soğancı on 25.10.2025.
//

import SwiftUI
import PhotosUI

struct PhotoCaptureView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = PhotoCaptureViewModel()
    @State private var showProcessingView = false
    
    // MARK: - Reading Configuration
    let readingType: String
    let culturalOrigin: String
    
    // Default initializer for backward compatibility
    init(readingType: String = "face", culturalOrigin: String = "chinese") {
        self.readingType = readingType
        self.culturalOrigin = culturalOrigin
    }

    var body: some View {
        ZStack {
            Color.backgroundPrimary.ignoresSafeArea()
            
            VStack(spacing: Spacing.lg) {
                Spacer()

                // Header
                VStack(spacing: Spacing.md) {
                    Text(LocalizedStringKey("photo_capture_title")) // localized
                        .font(AppTypography.heading1)
                        .foregroundColor(.textPrimary)

                    Text(LocalizedStringKey("photo_capture_subtitle_\(readingType)")) // localized
                        .font(AppTypography.bodyMedium)
                        .foregroundColor(.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, Spacing.md)

                // Image Preview or Placeholder
                Group {
                    if let imageData = viewModel.selectedImageData, let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 300)
                            .cornerRadius(CornerRadius.lg)
                            .overlay(
                                RoundedRectangle(cornerRadius: CornerRadius.lg)
                                    .stroke(Color.primary.opacity(0.3), lineWidth: 2)
                            )
                    } else {
                        RoundedRectangle(cornerRadius: CornerRadius.lg)
                            .fill(Color.surface)
                            .frame(height: 300)
                            .overlay(
                                VStack(spacing: Spacing.md) {
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 100))
                                        .foregroundColor(.textSecondary.opacity(0.5))
                                    
                                    Text(LocalizedStringKey("photo_preview_placeholder")) // localized
                                        .font(AppTypography.bodyMedium)
                                        .foregroundColor(.textSecondary)
                                }
                            )
                    }
                }
                .padding(.horizontal, Spacing.xl)

                // Processing State
                if viewModel.isProcessing {
                    VStack(spacing: Spacing.sm) {
                        MysticalLoadingView(size: 80)
                        
                        Text(LocalizedStringKey("photo_uploading")) // localized
                            .font(AppTypography.bodyMedium)
                            .foregroundColor(.textSecondary)
                    }
                    .padding(.horizontal, Spacing.xl)
                    .transition(.opacity.animation(.easeInOut(duration: 0.4)))
                }

                Spacer()

                // Action Buttons
                VStack(spacing: Spacing.md) {
                    if viewModel.selectedImageData == nil {
                        // Initial action buttons
                        PrimaryButton(
                            title: NSLocalizedString("photo_take_button", comment: "Take Photo"),
                            action: {
                                viewModel.takePhoto()
                            }
                        )
                        .disabled(viewModel.isProcessing)
                        
                        SecondaryButton(
                            title: NSLocalizedString("photo_choose_library_button", comment: "Choose from Library"),
                            action: {
                                viewModel.selectFromLibrary()
                            }
                        )
                        .disabled(viewModel.isProcessing)
                    } else {
                        // Image selected - show continue/retake options
                        PrimaryButton(
                            title: NSLocalizedString("photo_continue_button", comment: "Continue"),
                            action: {
                                if viewModel.uploadedImageUrl != nil {
                                    // Navigate to processing view with image URL
                                    showProcessingView = true
                                }
                            }
                        )
                        .disabled(viewModel.isProcessing || viewModel.uploadedImageUrl == nil)
                        
                        SecondaryButton(
                            title: NSLocalizedString("photo_retake_button", comment: "Retake Photo"),
                            action: {
                                viewModel.clearSelection()
                            }
                        )
                        .disabled(viewModel.isProcessing)
                    }
                }
                .padding(.horizontal, Spacing.xl)
                
                Spacer()
            }
        }
        .navigationTitle(NSLocalizedString("photo_nav_title", comment: "Add Photo")) // localized
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $viewModel.showImagePicker) {
            ImagePicker(
                sourceType: viewModel.sourceType,
                onImageSelected: { imageData in
                    viewModel.processSelectedImage(imageData)
                }
            )
        }
        .fullScreenCover(isPresented: $showProcessingView) {
            if let imageUrl = viewModel.uploadedImageUrl,
               let imageData = viewModel.selectedImageData {
                ReadingProcessingView(
                    imageData: imageData,
                    imageUrl: imageUrl,
                    readingType: readingType,
                    culturalOrigin: culturalOrigin
                )
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .dismissToHome)) { _ in
            print("🔥🔥🔥 [PHOTO CAPTURE] Dismiss to home notification received!")
            dismiss()
        }
        .sheet(isPresented: $viewModel.showPermissionRationale) {
            PermissionModalView(
                permissionType: viewModel.permissionType,
                onAllow: { viewModel.handlePermissionAllow() },
                onDeny: { viewModel.handlePermissionDeny() }
            )
        }
        .alert(isPresented: $viewModel.showPermissionDenied) {
            Alert(
                title: Text(LocalizedStringKey(viewModel.permissionType.deniedTitleKey)),
                message: Text(LocalizedStringKey(viewModel.permissionType.deniedMessageKey)),
                primaryButton: .default(Text(NSLocalizedString("permission_open_settings_button", comment: "Open Settings"))) {
                    viewModel.openSettings()
                },
                secondaryButton: .cancel(Text(NSLocalizedString("permission_cancel_button", comment: "Cancel"))) {
                    viewModel.cancelPermissionAlert()
                }
            )
        }
        .alert(NSLocalizedString("photo_error_title", comment: "Error"), isPresented: .constant(viewModel.errorMessage != nil)) {
            Button(NSLocalizedString("photo_error_ok", comment: "OK")) {
                viewModel.errorMessage = nil
            }
        } message: {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            }
        }
    }
}

// MARK: - ImagePicker (PHPickerViewController)
struct ImagePicker: UIViewControllerRepresentable {
    let sourceType: UIImagePickerController.SourceType
    let onImageSelected: (Data) -> Void
    
    func makeUIViewController(context: Context) -> UIViewController {
        if sourceType == .camera {
            // For camera, use UIImagePickerController
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.delegate = context.coordinator
            picker.allowsEditing = false
            return picker
        } else {
            // For photo library, use PHPickerViewController (modern iOS API)
            var configuration = PHPickerConfiguration()
            configuration.selectionLimit = 1
            configuration.filter = .images
            
            let picker = PHPickerViewController(configuration: configuration)
            picker.delegate = context.coordinator
            return picker
        }
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self, onImageSelected: onImageSelected)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PHPickerViewControllerDelegate {
        let parent: ImagePicker
        let onImageSelected: (Data) -> Void
        
        init(_ parent: ImagePicker, onImageSelected: @escaping (Data) -> Void) {
            self.parent = parent
            self.onImageSelected = onImageSelected
        }
        
        // UIImagePickerControllerDelegate (for camera)
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage,
               let imageData = image.jpegData(compressionQuality: 0.8) {
                onImageSelected(imageData)
            }
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
        
        // PHPickerViewControllerDelegate (for photo library)
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            guard let item = results.first else { return }
            
            // Load image from PHAsset
            if item.itemProvider.canLoadObject(ofClass: UIImage.self) {
                item.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                    if let image = image as? UIImage,
                       let imageData = image.jpegData(compressionQuality: 0.8) {
                        DispatchQueue.main.async {
                            self?.onImageSelected(imageData)
                        }
                    }
                }
            }
        }
    }
}

struct PhotoCaptureView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PhotoCaptureView()
        }
        .preferredColorScheme(.dark)
    }
}

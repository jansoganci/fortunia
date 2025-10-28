//
//  ShareService.swift
//  fortunia
//
//  Created by Cursor AI on December 19, 2024
//

import Foundation
import UIKit
import Supabase

/// ShareService handles share card generation and native sharing functionality
/// Integrates with Supabase Edge Functions for share card creation
@MainActor
class ShareService: ObservableObject {
    
    // MARK: - Singleton
    static let shared = ShareService()
    private init() {}
    
    // MARK: - Private Properties
    private let supabase = SupabaseService.shared.supabase
    private let analyticsService = AnalyticsService.shared
    private let functionService = FunctionService.shared
    
    // MARK: - Public Methods
    
    /// Generate a share card using the create-share-card Edge Function
    /// - Parameters:
    ///   - fortuneText: The fortune reading text
    ///   - readingType: Type of reading (face, palm, coffee, tarot)
    ///   - culturalOrigin: Cultural origin (chinese, middle_eastern, european)
    ///   - userId: User ID for the reading
    /// - Returns: URL of the generated share card image
    func generateShareCard(
        fortuneText: String,
        readingType: String,
        culturalOrigin: String,
        userId: String
    ) async throws -> String {
        
        analyticsService.logEvent("share_card_generation_requested", parameters: [
            "reading_type": readingType,
            "cultural_origin": culturalOrigin
        ])
        
        do {
            let requestData = [
                "fortune_text": fortuneText,
                "reading_type": readingType,
                "cultural_origin": culturalOrigin,
                "user_id": userId
            ]
            
            let response: ShareCardResponse = try await functionService.invokeFunction(
                name: "create-share-card",
                parameters: requestData
            )
            
            if response.success, let shareCardUrl = response.share_card_url {
                analyticsService.logEvent("share_card_generated_successfully", parameters: [
                    "reading_type": readingType,
                    "cultural_origin": culturalOrigin,
                    "share_card_url": shareCardUrl
                ])
                
                return shareCardUrl
            } else {
                throw ShareServiceError.generationFailed(response.error ?? "Unknown error")
            }
            
        } catch {
            analyticsService.logEvent("share_card_generation_failed", parameters: [
                "error": error.localizedDescription,
                "reading_type": readingType,
                "cultural_origin": culturalOrigin
            ])
            
            throw error
        }
    }
    
    /// Share fortune reading with native iOS share sheet
    /// - Parameters:
    ///   - fortuneText: The fortune reading text
    ///   - shareCardUrl: Optional URL of the share card image
    ///   - readingType: Type of reading for context
    ///   - culturalOrigin: Cultural origin for context
    ///   - from: The view controller to present the share sheet from
    func shareFortune(
        fortuneText: String,
        shareCardUrl: String? = nil,
        readingType: String,
        culturalOrigin: String,
        from viewController: UIViewController
    ) {
        
        analyticsService.logEvent("share_tapped", parameters: [
            "reading_type": readingType,
            "cultural_origin": culturalOrigin,
            "has_share_card": shareCardUrl != nil
        ])
        
        var shareItems: [Any] = []
        
        // Add fortune text
        let shareText = buildShareText(fortuneText: fortuneText, readingType: readingType, culturalOrigin: culturalOrigin)
        shareItems.append(shareText)
        
        // Add share card image if available
        if let shareCardUrl = shareCardUrl {
            Task {
                do {
                    let image = try await loadImageFromURL(shareCardUrl)
                    shareItems.append(image)
                    presentShareSheet(items: shareItems, from: viewController)
                } catch {
                    // Fallback to text-only sharing if image loading fails
                    presentShareSheet(items: shareItems, from: viewController)
                }
            }
        } else {
            // Present text-only sharing immediately
            presentShareSheet(items: shareItems, from: viewController)
        }
    }
    
    /// Share fortune reading with share card generation
    /// - Parameters:
    ///   - fortuneReading: Complete fortune reading object
    ///   - from: The view controller to present the share sheet from
    func shareFortuneWithCard(
        fortuneReading: FortuneReading,
        from viewController: UIViewController
    ) {
        
        Task {
            do {
                // Generate share card if not already available
                let shareCardUrl: String?
                if let existingUrl = fortuneReading.shareCardUrl {
                    shareCardUrl = existingUrl
                } else {
                    shareCardUrl = try await generateShareCard(
                        fortuneText: fortuneReading.resultText,
                        readingType: fortuneReading.readingType,
                        culturalOrigin: fortuneReading.culturalOrigin,
                        userId: fortuneReading.userId?.uuidString ?? "unknown"
                    )
                }
                
                // Share with the generated card
                shareFortune(
                    fortuneText: fortuneReading.resultText,
                    shareCardUrl: shareCardUrl,
                    readingType: fortuneReading.readingType,
                    culturalOrigin: fortuneReading.culturalOrigin,
                    from: viewController
                )
                
            } catch {
                // Fallback to text-only sharing
                shareFortune(
                    fortuneText: fortuneReading.resultText,
                    shareCardUrl: nil,
                    readingType: fortuneReading.readingType,
                    culturalOrigin: fortuneReading.culturalOrigin,
                    from: viewController
                )
            }
        }
    }
    
    // MARK: - Private Methods
    
    /// Build share text with proper formatting
    private func buildShareText(fortuneText: String, readingType: String, culturalOrigin: String) -> String {
        let readingTypeName = FortuneReadingType(rawValue: readingType)?.displayName ?? readingType.capitalized
        let culturalName = CulturalOrigin(rawValue: culturalOrigin)?.displayName ?? culturalOrigin.capitalized
        
        return """
        🔮 \(NSLocalizedString("share_fortune_title", comment: "My Fortune Reading"))
        
        \(NSLocalizedString("share_reading_type", comment: "Reading Type")): \(readingTypeName) (\(culturalName))
        
        \(fortuneText)
        
        \(NSLocalizedString("share_app_attribution", comment: "Get your own reading at fortunia.app"))
        """
    }
    
    /// Present native iOS share sheet
    private func presentShareSheet(items: [Any], from viewController: UIViewController) {
        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        
        // Configure for iPad
        if let popover = activityViewController.popoverPresentationController {
            popover.sourceView = viewController.view
            popover.sourceRect = CGRect(x: viewController.view.bounds.midX, y: viewController.view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        // Track completion
        activityViewController.completionWithItemsHandler = { [weak self] activityType, completed, returnedItems, error in
            if completed {
                self?.analyticsService.logEvent("share_completed", parameters: [
                    "activity_type": activityType?.rawValue ?? "unknown",
                    "items_count": items.count
                ])
            } else {
                self?.analyticsService.logEvent("share_cancelled", parameters: [
                    "activity_type": activityType?.rawValue ?? "unknown"
                ])
            }
        }
        
        viewController.present(activityViewController, animated: true)
    }
    
    /// Load image from URL asynchronously
    private func loadImageFromURL(_ urlString: String) async throws -> UIImage {
        guard let url = URL(string: urlString) else {
            throw ShareServiceError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        guard let image = UIImage(data: data) else {
            throw ShareServiceError.invalidImageData
        }
        
        return image
    }
}

// MARK: - ShareService Errors
enum ShareServiceError: LocalizedError {
    case generationFailed(String)
    case invalidURL
    case invalidImageData
    case networkError
    
    var errorDescription: String? {
        switch self {
        case .generationFailed(let message):
            return NSLocalizedString("share_error_generation_failed", comment: "Failed to generate share card: \(message)")
        case .invalidURL:
            return NSLocalizedString("share_error_invalid_url", comment: "Invalid share card URL")
        case .invalidImageData:
            return NSLocalizedString("share_error_invalid_image", comment: "Invalid share card image data")
        case .networkError:
            return NSLocalizedString("share_error_network", comment: "Network error while loading share card")
        }
    }
}

// MARK: - Share Card Response Model
struct ShareCardResponse: Codable {
    let success: Bool
    let share_card_url: String?
    let error: String?
}

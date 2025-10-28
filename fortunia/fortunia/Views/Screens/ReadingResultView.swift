
//
//  ReadingResultView.swift
//  fortunia
//
//  Created by Can Soğancı on 25.10.2025.
//

import SwiftUI

extension Notification.Name {
    static let dismissToPhotoCapture = Notification.Name("dismissToPhotoCapture")
    static let dismissToHome = Notification.Name("dismissToHome")
}

struct ReadingResultView: View {
    // MARK: - Properties
    let result: FortuneResult
    let imageUrl: String
    
    // MARK: - Environment
    @Environment(\.dismiss) private var dismiss
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @StateObject private var shareService = ShareService.shared
    @State private var fortuneReading: FortuneReading?
    @State private var showShareSheet = false
    @State private var shareItems: [Any] = []
    @State private var errorMessage: String?
    @State private var isGeneratingShareCard = false
    @State private var showNoConnectionAlert = false
    @State private var lastRetryAction: (() -> Void)?

    var body: some View {
        NavigationView {
            ZStack {
                Color.backgroundPrimary.ignoresSafeArea()

                ScrollView {
                VStack(spacing: Spacing.lg) {
                    Spacer(minLength: Spacing.lg)

                    // Header - Dynamic title based on reading type
                    Text(LocalizedStringKey("result_your_\(result.readingType)_reading")) // localized
                        .font(AppTypography.fortuneTitle)
                        .foregroundColor(.textPrimary)

                    // User's Image
                    AsyncImage(url: URL(string: imageUrl)) { phase in
                        switch phase {
                        case .empty:
                            RoundedRectangle(cornerRadius: CornerRadius.lg)
                                .fill(Color.surface)
                                .frame(height: 350)
                                .overlay(
                                    MysticalLoadingView(size: 60)
                                )
                                .padding(.horizontal, Spacing.xl)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(height: 350)
                                .clipped()
                                .cornerRadius(CornerRadius.lg)
                                .padding(.horizontal, Spacing.xl)
                                .padding(.top, Spacing.sm)
                                .padding(.bottom, Spacing.lg)
                        case .failure:
                            RoundedRectangle(cornerRadius: CornerRadius.lg)
                                .fill(Color.surface)
                                .frame(height: 350)
                                .overlay(
                                    Image(systemName: "person.crop.artframe")
                                        .font(.system(size: 100))
                                        .foregroundColor(.textSecondary.opacity(0.5))
                                )
                                .padding(.horizontal, Spacing.xl)
                        @unknown default:
                            RoundedRectangle(cornerRadius: CornerRadius.lg)
                                .fill(Color.surface)
                                .frame(height: 350)
                                .padding(.horizontal, Spacing.xl)
                        }
                    }

                    // Fortune Text
                    VStack(spacing: Spacing.md) {
                        // Split result text into heading and body if possible
                        let lines = result.result.split(separator: "\n")
                        let heading = lines.first.map(String.init) ?? result.result
                        let body = lines.count > 1 ? lines.dropFirst().joined(separator: "\n") : result.result
                        
                        Text(heading)
                            .font(AppTypography.heading3)
                            .foregroundColor(.textPrimary)
                            .multilineTextAlignment(.center)

                        Text(body)
                            .font(AppTypography.fortuneText)
                            .foregroundColor(.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, Spacing.md)

                    Spacer()

                    // Action Buttons
                    VStack(spacing: Spacing.md) {
                        PrimaryButton(
                            title: isGeneratingShareCard ? 
                                NSLocalizedString("result_generating_share_card", comment: "Generating Share Card...") :
                                NSLocalizedString("result_share_fortune", comment: "Share Your Fortune"),
                            action: {
                                handleShareAction()
                            }
                        )
                        .disabled(isGeneratingShareCard)
                        
                        SecondaryButton(title: NSLocalizedString("result_get_another_reading", comment: "Get Another Reading"), action: { // localized
                            print("🔥🔥🔥 [GET ANOTHER READING] BUTTON CLICKED!")
                            
                            // Dismiss ReadingResultView
                            presentationMode.wrappedValue.dismiss()
                            print("🔥🔥🔥 [GET ANOTHER READING] First dismiss called")
                            
                            // Post notification to ReadingProcessingView to dismiss itself
                            NotificationCenter.default.post(name: .dismissToPhotoCapture, object: nil)
                            print("🔥🔥🔥 [GET ANOTHER READING] Notification posted to dismiss ReadingProcessingView")
                        })
                    }
                    .padding(.horizontal, Spacing.xl)

                    // Disclaimer
                    DisclaimerView()
                        .padding(.top, Spacing.lg)
                    
                    Spacer(minLength: Spacing.md)
                }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        print("🔥🔥🔥 [X BUTTON] X button clicked!")
                        print("🔥🔥🔥 [X BUTTON] Dismissing ReadingResultView...")
                        
                        // Dismiss ReadingResultView
                        presentationMode.wrappedValue.dismiss()
                        
                        // Post notification to dismiss both ReadingProcessingView and PhotoCaptureView
                        NotificationCenter.default.post(name: .dismissToHome, object: nil)
                        print("🔥🔥🔥 [X BUTTON] Notification posted to dismiss to HomeView")
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.textSecondary)
                    }
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(items: shareItems)
        }
        .alert(NSLocalizedString("share_error_title", comment: "Share Error"), isPresented: .constant(errorMessage != nil)) {
            Button(NSLocalizedString("share_error_ok", comment: "OK")) {
                errorMessage = nil
            }
        } message: {
            if let errorMessage = errorMessage {
                Text(errorMessage)
            }
        }
        .alert(NSLocalizedString("no_internet_title", comment: "No Internet Connection"), isPresented: $showNoConnectionAlert) {
            Button(NSLocalizedString("try_again_button", comment: "Try Again")) {
                retryLastAction()
            }
            Button(NSLocalizedString("close_button", comment: "Close"), role: .cancel) { }
        } message: {
            Text(NSLocalizedString("no_internet_message", comment: "Please check your network and try again."))
        }
    }
    
    // MARK: - Private Methods
    
    /// Handle share button action
    private func handleShareAction() {
        // Store retry action
        lastRetryAction = {
            handleShareAction()
        }
        
        // Check network connectivity
        guard networkMonitor.isConnected else {
            showNoConnectionAlert = true
            AnalyticsService.shared.logEvent("network_offline_alert_shown")
            return
        }
        
        // For demo purposes, create a sample fortune reading
        // In production, this would come from the actual reading result
        let sampleReading = createSampleFortuneReading()
        
        Task {
            isGeneratingShareCard = true
            
            do {
                // Generate share card
                let shareCardUrl = try await shareService.generateShareCard(
                    fortuneText: sampleReading.resultText,
                    readingType: sampleReading.readingType,
                    culturalOrigin: sampleReading.culturalOrigin,
                    userId: sampleReading.userId?.uuidString ?? "demo-user"
                )
                
                // Prepare share items
                let shareText = buildShareText(
                    fortuneText: sampleReading.resultText,
                    readingType: sampleReading.readingType,
                    culturalOrigin: sampleReading.culturalOrigin
                )
                
                shareItems = [shareText]
                
                // Load share card image
                if let image = try? await loadImageFromURL(shareCardUrl) {
                    shareItems.append(image)
                }
                
                // Show share sheet
                showShareSheet = true
                
            } catch URLError.notConnectedToInternet {
                // Handle network error specifically
                showNoConnectionAlert = true
                AnalyticsService.shared.logEvent("network_offline_alert_shown")
            } catch {
                errorMessage = error.localizedDescription
            }
            
            isGeneratingShareCard = false
        }
    }
    
    /// Retry the last action when network is restored
    private func retryLastAction() {
        AnalyticsService.shared.logEvent("network_retry_attempted")
        lastRetryAction?()
    }
    
    /// Create fortune reading from result data
    private func createSampleFortuneReading() -> FortuneReading {
        return FortuneReading(
            id: UUID(),
            userId: UUID(),
            readingType: result.readingType,
            culturalOrigin: result.culturalOrigin,
            imageUrl: imageUrl,
            resultText: result.result,
            shareCardUrl: result.shareCardUrl,
            isPremium: false,
            createdAt: Date()
        )
    }
    
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

// MARK: - ShareSheet
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        
        // Configure for iPad
        if let popover = activityViewController.popoverPresentationController {
            popover.sourceView = UIApplication.shared.windows.first
            popover.sourceRect = CGRect(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        return activityViewController
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// As defined in DESIGN_RULEBOOK.md
struct DisclaimerView: View {
    var body: some View {
        Text(LocalizedStringKey("result_disclaimer")) // localized
            .font(AppTypography.caption)
            .foregroundColor(.textSecondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.xs)
    }
}

struct ReadingResultView_Previews: PreviewProvider {
    static var previews: some View {
        ReadingResultView(
            result: FortuneResult(
                success: true,
                result: "Your mystical journey reveals great wisdom and prosperity ahead.",
                shareCardUrl: nil,
                readingType: "face",
                culturalOrigin: "chinese",
                processingTime: 5000,
                error: nil
            ),
            imageUrl: "https://example.com/image.jpg"
        )
        .preferredColorScheme(.dark)
    }
}

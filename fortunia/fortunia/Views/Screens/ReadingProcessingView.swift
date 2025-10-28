
//
//  ReadingProcessingView.swift
//  fortunia
//
//  Created by Can Soğancı on 25.10.2025.
//

import SwiftUI

struct ReadingProcessingView: View {
    // MARK: - Properties
    let imageData: Data
    let imageUrl: String
    let readingType: String
    let culturalOrigin: String
    
    @Environment(\.dismiss) private var dismiss
    @State private var showResultView = false
    @State private var processedResult: FortuneResult?
    @State private var errorMessage: String?
    @State private var isProcessing = false
    
    // MARK: - Services
    private let aiProcessingService = AIProcessingService.shared
    
    var body: some View {
        ZStack {
            Color.backgroundPrimary.ignoresSafeArea()

            VStack(spacing: Spacing.xxl) {
                Spacer()
                VStack(spacing: Spacing.lg) {
                    MysticalLoadingView()
                    Text(LocalizedStringKey("processing_reading_message")) // localized
                        .font(AppTypography.bodySmall)
                        .foregroundColor(.textSecondary)
                }
                Spacer()
            }
        }
        .task {
            await processReading()
        }
        .fullScreenCover(isPresented: $showResultView) {
            if let result = processedResult {
                ReadingResultView(
                    result: result,
                    imageUrl: imageUrl
                )
                .onAppear {
                    print("🔥 [FULLSCREEN] ReadingResultView appeared with result")
                }
            } else {
                ZStack {
                    Color.backgroundPrimary.ignoresSafeArea()
                    VStack {
                        Text("ERROR: processedResult is NIL!")
                            .foregroundColor(.white)
                        Text("Please check console logs")
                            .foregroundColor(.gray)
                    }
                }
                .onAppear {
                    print("🔥🔥🔥 [FULLSCREEN] ERROR: processedResult is NIL when cover appears!")
                }
            }
        }
        .onChange(of: showResultView) { newValue in
            print("🔥 [FULLSCREEN] showResultView changed to \(newValue)")
            if newValue {
                print("🔥 [FULLSCREEN] processedResult is: \(processedResult != nil ? "NOT nil" : "nil")")
                if let result = processedResult {
                    print("🔥 [FULLSCREEN] Result preview: \(result.result.prefix(50))...")
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .dismissToPhotoCapture)) { _ in
            print("🔥🔥🔥 [READING PROCESSING] Dismiss notification received!")
            dismiss()
        }
        .onReceive(NotificationCenter.default.publisher(for: .dismissToHome)) { _ in
            print("🔥🔥🔥 [READING PROCESSING] Dismiss to home notification received!")
            dismiss()
            // Also dismiss PhotoCaptureView
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                NotificationCenter.default.post(name: .dismissToHome, object: nil)
            }
        }
        .alert(NSLocalizedString("processing_error_title", comment: "Alert title for processing failure"), isPresented: .constant(errorMessage != nil)) {
            Button(NSLocalizedString("ok_button", comment: "Confirmation button label")) {
                errorMessage = nil
            }
        } message: {
            if let errorMessage = errorMessage {
                Text(errorMessage)
            }
        }
    }
    
    // MARK: - Private Methods
    
    /// Process the reading with actual AI service
    private func processReading() async {
        print("🔥 [READING PROCESSING] processReading START - Type: \(readingType), Origin: \(culturalOrigin)")
        isProcessing = true
        
        defer {
            print("🔥 [READING PROCESSING] isProcessing set to false")
            isProcessing = false
        }
        
        do {
            print("🔥 [READING PROCESSING] Processing reading type: \(readingType)")
            // Process the reading based on type
            let result: FortuneResult
            
            switch readingType {
            case "face":
                print("🔥 [READING PROCESSING] Calling processFaceReading...")
                result = try await aiProcessingService.processFaceReading(
                    imageData: imageData,
                    culturalOrigin: culturalOrigin
                )
                print("🔥 [READING PROCESSING] ✅ processFaceReading completed!")
            case "palm":
                print("🔥 [READING PROCESSING] Calling processPalmReading...")
                result = try await aiProcessingService.processPalmReading(
                    imageData: imageData,
                    culturalOrigin: culturalOrigin
                )
                print("🔥 [READING PROCESSING] ✅ processPalmReading completed!")
            case "coffee":
                print("🔥 [READING PROCESSING] Calling processCoffeeReading...")
                result = try await aiProcessingService.processCoffeeReading(
                    imageData: imageData,
                    culturalOrigin: culturalOrigin
                )
                print("🔥 [READING PROCESSING] ✅ processCoffeeReading completed!")
            case "tarot":
                print("🔥 [READING PROCESSING] Calling processTarotReading...")
                result = try await aiProcessingService.processTarotReading(
                    culturalOrigin: culturalOrigin
                )
                print("🔥 [READING PROCESSING] ✅ processTarotReading completed!")
            default:
                print("🔥 [READING PROCESSING] ❌ Invalid reading type: \(readingType)")
                throw NSError(
                    domain: "InvalidReadingType",
                    code: 400,
                    userInfo: [NSLocalizedDescriptionKey: "Unknown reading type: \(readingType)"]
                )
            }
            
            processedResult = result
            print("🔥 [READING PROCESSING] ✅ Result received, navigating to result view...")
            print("🔥 [READING PROCESSING] Setting processedResult = result")
            print("🔥 [READING PROCESSING] Result preview: \(result.result.prefix(50))...")
            
            // Navigate to result view
            await MainActor.run {
                print("🔥 [READING PROCESSING] Setting showResultView = true on MainActor")
                showResultView = true
                print("🔥 [READING PROCESSING] showResultView is now: \(showResultView)")
            }
            print("🔥 [READING PROCESSING] ✅ Complete!")
            
        } catch {
            print("🔥 [READING PROCESSING] ❌ ERROR: \(error)")
            errorMessage = "Failed to process reading: \(error.localizedDescription)"
            LocalizedDebugLogger.shared.logAI(readingType, culturalOrigin: culturalOrigin, success: false)
        }
    }
}

struct ReadingProcessingView_Previews: PreviewProvider {
    static var previews: some View {
        ReadingProcessingView(
            imageData: Data(),
            imageUrl: "https://example.com/image.jpg",
            readingType: "face",
            culturalOrigin: "chinese"
        )
        .preferredColorScheme(.dark)
    }
}

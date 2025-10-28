//
//  CoffeeReadingIntroView.swift
//  fortunia
//
//  Created by Cursor AI on December 19, 2024
//

import SwiftUI

struct CoffeeReadingIntroView: View {
    @StateObject private var authService = AuthService.shared
    @State private var showBirthInfoModal = false
    @State private var showPhotoCapture = false
    @State private var isStartingReading = false
    @State private var hasCompletedOnboarding = false
    @State private var isCheckingOnboarding = true

    var body: some View {
        ZStack {
            Color.backgroundPrimary.ignoresSafeArea()

            ScrollView {
                // NavigationLink for programmatic navigation
                NavigationLink(destination: PhotoCaptureView(readingType: "coffee", culturalOrigin: "chinese"), isActive: $showPhotoCapture) { EmptyView() }

                VStack(spacing: Spacing.lg) {
                    Spacer(minLength: Spacing.lg)

                    // Header Icon
                    Image(systemName: "cup.and.saucer.fill")
                        .font(.system(size: 64, weight: .thin))
                        .foregroundColor(.accent)
                        .padding()
                        .background(Color.primary.opacity(0.1).clipShape(Circle()))

                    // Content
                    VStack(spacing: Spacing.md) {
                        Text("coffee_reading_intro_title") // localized
                            .font(AppTypography.heading1)
                            .foregroundColor(.textPrimary)

                        Text("coffee_reading_intro_desc") // localized
                            .font(AppTypography.bodyMedium)
                            .foregroundColor(.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, Spacing.md)

                    Spacer(minLength: Spacing.xxl)

                    // Action Button
                    PrimaryButton(title: NSLocalizedString("intro_get_started_button", comment: "Get Started"), action: {
                        handleGetStarted()
                    })
                    .padding(.horizontal, Spacing.xl)
                    .overlay(
                        (isStartingReading || isCheckingOnboarding) ? MysticalLoadingView(size: 24) : nil
                    )
                    
                    Spacer(minLength: Spacing.md)
                }
            }
        }
        .navigationTitle(NSLocalizedString("coffee_reading_nav_title", comment: "Coffee Reading"))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            checkOnboardingStatus()
        }
        .sheet(isPresented: $showBirthInfoModal) {
            BirthInfoModalView(onComplete: {
                showPhotoCapture = true
            })
        }
    }
    
    // MARK: - Private Methods
    
    /// Check if user has completed onboarding
    private func checkOnboardingStatus() {
        print("🔥 [COFFEE READING INTRO] checkOnboardingStatus START")
        
        guard let userId = authService.currentUserId else {
            print("🔥 [COFFEE READING INTRO] ❌ No userId found!")
            isCheckingOnboarding = false
            hasCompletedOnboarding = false
            return
        }
        
        print("🔥 [COFFEE READING INTRO] User ID: \(userId)")
        isCheckingOnboarding = true
        
        Task {
            do {
                print("🔥 [COFFEE READING INTRO] Calling OnboardingService.hasCompletedOnboarding...")
                let completed = try await OnboardingService.shared.hasCompletedOnboarding(for: userId)
                print("🔥 [COFFEE READING INTRO] ✅ OnboardingService returned: \(completed)")
                
                await MainActor.run {
                    hasCompletedOnboarding = completed
                    isCheckingOnboarding = false
                    print("🔥 [COFFEE READING INTRO] State updated - hasCompletedOnboarding: \(completed)")
                }
            } catch {
                print("🔥 [COFFEE READING INTRO] ❌ Error: \(error)")
                await MainActor.run {
                    hasCompletedOnboarding = false
                    isCheckingOnboarding = false
                }
                LocalizedDebugLogger.shared.logDebug("ONBOARDING", "Failed to check onboarding status: \(error.localizedDescription)")
            }
        }
    }
    
    /// Handle "Get Started" button tap with conditional logic
    private func handleGetStarted() {
        print("🔥 [COFFEE READING INTRO] handleGetStarted called")
        print("🔥 [COFFEE READING INTRO] hasCompletedOnboarding: \(hasCompletedOnboarding)")
        print("🔥 [COFFEE READING INTRO] authService.currentUserId: \(authService.currentUserId ?? "nil")")
        
        Task { @MainActor in
            print("🔥 [COFFEE READING INTRO] [STEP 1/3] Starting reading process...")
            isStartingReading = true
            
            // Briefly show loading state for better UX feedback
            try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
            print("🔥 [COFFEE READING INTRO] [STEP 2/3] Loading state timeout passed")
            
            isStartingReading = false
            
            print("🔥 [COFFEE READING INTRO] [STEP 3/3] Checking onboarding status: \(hasCompletedOnboarding)")
            if hasCompletedOnboarding {
                // User has already completed onboarding, skip modal and go to photo capture
                print("🔥 [COFFEE READING INTRO] ✅ Onboarding complete - showing PhotoCaptureView")
                showPhotoCapture = true
            } else {
                // User needs to complete onboarding first
                print("🔥 [COFFEE READING INTRO] 📝 Onboarding incomplete - showing BirthInfoModal")
                showBirthInfoModal = true
            }
        }
    }
}

struct CoffeeReadingIntroView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CoffeeReadingIntroView()
        }
        .preferredColorScheme(.dark)
    }
}


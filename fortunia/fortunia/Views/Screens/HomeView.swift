//
//  HomeView.swift
//  fortunia
//
//  Created by Cursor AI on December 19, 2024
//

import SwiftUI

/// Home view displaying the 4 reading card options
struct HomeView: View {
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @EnvironmentObject var localizationManager: LocalizationManager
    @State private var showNoConnectionAlert = false
    @State private var lastRetryAction: (() -> Void)?
    @State private var selectedReading: FortuneReadingType?
    @State private var isNavigating = false
    
    // Grid columns configuration
    private let columns = [
        GridItem(.flexible(minimum: 140)),
        GridItem(.flexible(minimum: 140))
    ]
    
    var body: some View {
        ZStack {
            // Background
            Color.backgroundPrimary
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: Spacing.lg) {
                    // Header
                    VStack(spacing: Spacing.sm) {
                        Text("home_discover_fortune".localized)
                            .font(AppTypography.heading1)
                            .foregroundColor(.textPrimary)
                            .multilineTextAlignment(.center)
                        
                        Text("home_choose_reading_method".localized)
                            .font(AppTypography.bodyMedium)
                            .foregroundColor(.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, Spacing.lg)
                    
                    // Fortune Types Grid
                    LazyVGrid(columns: columns, spacing: Spacing.md) {
                        
                        // Face Reading
                        FortuneCardView(
                            title: "home_face_reading".localized,
                            description: "home_face_reading_desc".localized,
                            icon: "face.smiling",
                            color: .primary,
                            onTap: { handleReadingTap(.face) }
                        )
                        
                        // Palm Reading
                        FortuneCardView(
                            title: "home_palm_reading".localized,
                            description: "home_palm_reading_desc".localized,
                            icon: "hand.raised.fill",
                            color: .accent,
                            onTap: { handleReadingTap(.palm) }
                        )
                        
                        // Tarot Cards
                        FortuneCardView(
                            title: "home_tarot_cards".localized,
                            description: "home_tarot_cards_desc".localized,
                            icon: "rectangle.portrait.fill",
                            color: .primary,
                            onTap: { handleReadingTap(.tarot) }
                        )
                        
                        // Coffee Reading
                        FortuneCardView(
                            title: "home_coffee_reading".localized,
                            description: "home_coffee_reading_desc".localized,
                            icon: "cup.and.saucer.fill",
                            color: .accent,
                            onTap: { handleReadingTap(.coffee) }
                        )
                    }
                    .padding(.horizontal, Spacing.md)
                    
                    // Daily Quota (only for free users)
                    if !QuotaManager.shared.isPremiumUser {
                        QuotaCard()
                            .padding(.horizontal, Spacing.md)
                    }
                    
                    // Hidden NavigationLink for programmatic navigation
                    if let reading = selectedReading {
                        NavigationLink(
                            destination: readingDestination(for: reading),
                            isActive: $isNavigating
                        ) {
                            EmptyView()
                        }
                        .hidden()
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            // Reset navigation state when returning to HomeView
            selectedReading = nil
            isNavigating = false
        }
        .onChange(of: isNavigating) { newValue in
            // After navigation completes, clear selectedReading
            if !newValue {
                Task { @MainActor in
                    try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
                    selectedReading = nil
                }
            }
        }
        .alert("no_internet_title".localized, isPresented: $showNoConnectionAlert) {
            Button("try_again_button".localized) {
                retryLastAction()
            }
            Button("close_button".localized, role: .cancel) { }
        } message: {
            Text("no_internet_message".localized)
        }
    }
    
    // MARK: - Private Methods
    
    /// Handle tap on reading card
    /// Note: FortuneCardView already handles locked state and shows paywall if needed
    /// This is only called when the card is unlocked
    private func handleReadingTap(_ reading: FortuneReadingType) {
        selectedReading = reading
        isNavigating = true
    }
    
    /// Retry the last action when network is restored
    private func retryLastAction() {
        AnalyticsService.shared.logEvent("network_retry_attempted")
        lastRetryAction?()
    }
    
    /// Navigation destination for reading type
    @ViewBuilder
    private func readingDestination(for reading: FortuneReadingType) -> some View {
        switch reading {
        case .face:
            FaceReadingIntroView()
        case .palm:
            PalmReadingIntroView()
        case .tarot:
            TarotReadingIntroView()
        case .coffee:
            CoffeeReadingIntroView()
        }
    }
}

// MARK: - Preview
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            HomeView()
                .environmentObject(NetworkMonitor.shared)
                .preferredColorScheme(.light)
            
            HomeView()
                .environmentObject(NetworkMonitor.shared)
                .preferredColorScheme(.dark)
        }
    }
}

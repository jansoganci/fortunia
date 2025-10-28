//
//  PaywallView.swift
//  fortunia
//
//  Created by Cursor AI on December 19, 2024
//

import SwiftUI

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPlan: SubscriptionPlan = .yearly
    @State private var isProcessing = false
    @State private var error: PaywallError? = nil
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color.backgroundPrimary
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: Spacing.xl) {
                        // Header
                        VStack(spacing: Spacing.md) {
                            Text(NSLocalizedString("paywall_title", comment: "Unlock Unlimited Readings ✨"))
                                .font(AppTypography.heading1)
                                .foregroundColor(.textPrimary)
                                .multilineTextAlignment(.center)
                            
                            Text(NSLocalizedString("paywall_subtitle", comment: "Get unlimited fortune readings, detailed reports, and premium features"))
                                .font(AppTypography.bodyMedium)
                                .foregroundColor(.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, Spacing.lg)
                        
                        // Subscription Plans
                        VStack(spacing: Spacing.md) {
                            // Yearly Plan (Recommended)
                            SubscriptionPlanCard(
                                plan: .yearly,
                                isSelected: selectedPlan == .yearly,
                                isRecommended: true
                            ) {
                                selectedPlan = .yearly
                            }
                            
                            // Monthly Plan
                            SubscriptionPlanCard(
                                plan: .monthly,
                                isSelected: selectedPlan == .monthly,
                                isRecommended: false
                            ) {
                                selectedPlan = .monthly
                            }
                        }
                        .padding(.horizontal, Spacing.md)
                        
                        // Features List
                        VStack(spacing: Spacing.sm) {
                            FeatureRow(icon: "infinity", text: NSLocalizedString("paywall_feature_unlimited", comment: "Unlimited daily readings"))
                            FeatureRow(icon: "doc.text", text: NSLocalizedString("paywall_feature_reports", comment: "Detailed 10-page reports"))
                            FeatureRow(icon: "photo", text: NSLocalizedString("paywall_feature_share_cards", comment: "HD share cards (no watermark)"))
                            FeatureRow(icon: "chart.line.uptrend.xyaxis", text: NSLocalizedString("paywall_feature_history", comment: "Reading history & trends"))
                            FeatureRow(icon: "bolt", text: NSLocalizedString("paywall_feature_priority", comment: "Priority processing (< 5 seconds)"))
                            FeatureRow(icon: "checkmark.shield", text: NSLocalizedString("paywall_feature_adfree", comment: "Ad-free experience"))
                        }
                        .padding(.horizontal, Spacing.lg)
                        .padding(.vertical, Spacing.md)
                        .background(Color.surface)
                        .cornerRadius(CornerRadius.lg)
                        .padding(.horizontal, Spacing.md)
                        
                        // Upgrade Button
                        VStack(spacing: Spacing.md) {
                            PrimaryButton(
                                title: NSLocalizedString("paywall_upgrade_button", comment: "Upgrade to Premium"),
                                action: {
                                    Task {
                                        await purchase()
                                    }
                                }
                            )
                            .padding(.horizontal, Spacing.lg)
                            
                            // Restore Purchases
                            Button(NSLocalizedString("paywall_restore_button", comment: "Restore Purchases")) {
                                Task {
                                    await restorePurchases()
                                }
                            }
                            .font(AppTypography.caption)
                            .foregroundColor(.textSecondary)
                        }
                        .padding(.bottom, Spacing.xl)
                    }
                }
                
                // Loading Overlay
                if isProcessing {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                    MysticalLoadingView()
                }
            }
            .navigationTitle(Text(NSLocalizedString("premium_title", comment: "Navigation bar title for paywall screen")))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(NSLocalizedString("paywall_close_button", comment: "Close")) {
                        dismiss()
                    }
                    .foregroundColor(.primary)
                }
            }
        }
        .alert(isPresented: .constant(error != nil), error: error) {
            Button(NSLocalizedString("alert_ok_button", comment: "OK")) {
                error = nil
            }
        }
    }
    
    private func purchase() async {
        isProcessing = true
        do {
            // Simulate a network call
            try await Task.sleep(nanoseconds: 2_000_000_000)
            // Simulate an error
            throw PaywallError.networkFailure
        } catch let error as PaywallError {
            DebugLogger.shared.error("Paywall Error: \(error.localizedDescription)")
            self.error = error
        } catch {
            DebugLogger.shared.error("An unexpected error occurred: \(error.localizedDescription)")
            self.error = .unknown
        }
        isProcessing = false
    }
    
    private func restorePurchases() async {
        isProcessing = true
        do {
            // Simulate a network call
            try await Task.sleep(nanoseconds: 2_000_000_000)
            // Simulate an error
            throw PaywallError.paymentCancelled
        } catch let error as PaywallError {
            DebugLogger.shared.error("Paywall Error: \(error.localizedDescription)")
            self.error = error
        } catch {
            DebugLogger.shared.error("An unexpected error occurred: \(error.localizedDescription)")
            self.error = .unknown
        }
        isProcessing = false
    }
}

enum PaywallError: Error, LocalizedError {
    case networkFailure
    case paymentCancelled
    case alreadyPurchased
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .networkFailure:
            return NSLocalizedString("paywall_error_network_failure", comment: "There was a problem connecting to the network. Please try again.")
        case .paymentCancelled:
            return NSLocalizedString("paywall_error_payment_cancelled", comment: "The payment was cancelled. Please try again.")
        case .alreadyPurchased:
            return NSLocalizedString("paywall_error_already_purchased", comment: "You have already purchased this item.")
        case .unknown:
            return NSLocalizedString("paywall_error_unknown", comment: "An unknown error occurred. Please try again later.")
        }
    }
}

// MARK: - Subscription Plan Card
struct SubscriptionPlanCard: View {
    let plan: SubscriptionPlan
    let isSelected: Bool
    let isRecommended: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: Spacing.sm) {
                HStack {
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        HStack {
                            Text(plan.title)
                                .font(AppTypography.heading4)
                                .foregroundColor(.textPrimary)
                            
                            if isRecommended {
                                RecommendedBadge()
                            }
                        }
                        
                        Text(plan.tagline)
                            .font(AppTypography.caption)
                            .foregroundColor(.textSecondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: Spacing.xs) {
                        Text(plan.price)
                            .font(AppTypography.heading3)
                            .foregroundColor(.primary)
                        
                        Text(plan.billingTerm)
                            .font(AppTypography.caption)
                            .foregroundColor(.textSecondary)
                    }
                }
                
                if isRecommended {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text(NSLocalizedString("paywall_save_annually", comment: "Save 40% annually"))
                            .font(AppTypography.caption)
                            .foregroundColor(.green)
                        Spacer()
                    }
                }
            }
            .padding(Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.lg)
                    .fill(isSelected ? Color.primary.opacity(0.1) : Color.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: CornerRadius.lg)
                            .stroke(
                                isSelected ? Color.primary : Color.clear,
                                lineWidth: 2
                            )
                    )
            )
            .shadow(
                color: Elevation.level2.color,
                radius: Elevation.level2.radius,
                x: Elevation.level2.x,
                y: Elevation.level2.y
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Recommended Badge
struct RecommendedBadge: View {
    var body: some View {
        Text(NSLocalizedString("paywall_recommended", comment: "RECOMMENDED"))
            .font(AppTypography.caption)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .padding(.horizontal, Spacing.sm)
            .padding(.vertical, Spacing.xs)
            .background(
                LinearGradient(
                    colors: [.primary, .accent],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(CornerRadius.sm)
    }
}

// MARK: - Feature Row
struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.primary)
                .frame(width: 20)
            
            Text(text)
                .font(AppTypography.bodyMedium)
                .foregroundColor(.textPrimary)
            
            Spacer()
        }
    }
}

// MARK: - Subscription Plan Enum
enum SubscriptionPlan: CaseIterable {
    case monthly
    case yearly
    
    var title: String {
        switch self {
        case .monthly:
            return NSLocalizedString("paywall_monthly_title", comment: "Monthly")
        case .yearly:
            return NSLocalizedString("paywall_yearly_title", comment: "Yearly")
        }
    }
    
    var price: String {
        switch self {
        case .monthly:
            return NSLocalizedString("paywall_monthly_price", comment: "$9")
        case .yearly:
            return NSLocalizedString("paywall_yearly_price", comment: "$55")
        }
    }
    
    var billingTerm: String {
        switch self {
        case .monthly:
            return NSLocalizedString("paywall_per_month", comment: "per month")
        case .yearly:
            return NSLocalizedString("paywall_per_year", comment: "per year")
        }
    }
    
    var tagline: String {
        switch self {
        case .monthly:
            return NSLocalizedString("paywall_monthly_tagline", comment: "Best for casual users")
        case .yearly:
            return NSLocalizedString("paywall_yearly_tagline", comment: "Best value for regular users")
        }
    }
    
    var productId: String {
        switch self {
        case .monthly:
            return "com.fortunia.monthly"
        case .yearly:
            return "com.fortunia.yearly"
        }
    }
}

// MARK: - Preview
#Preview {
    PaywallView()
}

//
//  FortuneCardView.swift
//  fortunia
//
//  Created by Cursor AI on December 19, 2024
//

import SwiftUI

/// Visual card content (no button logic)
struct FortuneCardContent: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    let isLocked: Bool
    
    var body: some View {
        ZStack {
            VStack(spacing: Spacing.md) {
                // Icon
                Image(systemName: icon)
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [color, color.opacity(0.7)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                
                // Text - with constraints to prevent variable height
                VStack(spacing: Spacing.xs) {
                    Text(title)
                        .font(AppTypography.heading4)
                        .foregroundColor(.textPrimary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                    
                    Text(description)
                        .font(AppTypography.caption)
                        .foregroundColor(.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                }
                .frame(maxHeight: 50)
            }
            .padding(Spacing.md)
            .frame(minWidth: 0, maxWidth: .infinity)
            .frame(height: 170)
            .background(Color.surface)
            .cornerRadius(CornerRadius.lg)
            .contentShape(RoundedRectangle(cornerRadius: CornerRadius.lg))
            .shadow(
                color: Elevation.level2.color,
                radius: Elevation.level2.radius,
                x: Elevation.level2.x,
                y: Elevation.level2.y
            )
            .opacity(isLocked ? 0.6 : 1.0)
            
            // Lock overlay when locked - uses absolute positioning to not affect card size
            if isLocked {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Image(systemName: "lock.fill")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.orange)
                            .padding(8)
                            .background(
                                Circle()
                                    .fill(Color.backgroundPrimary)
                                    .shadow(radius: 2)
                            )
                        Spacer()
                    }
                    Spacer()
                }
            }
        }
    }
}

/// Reusable card component with button and unlock logic
/// Unified unlock logic: Card is unlocked if user is premium OR has quota remaining
struct FortuneCardView: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    let onTap: () -> Void
    
    @State private var showPaywall = false
    @ObservedObject private var quotaManager = QuotaManager.shared
    
    /// Unified unlock logic: unlocked if premium OR has quota
    private var isLocked: Bool {
        !quotaManager.isPremiumUser && quotaManager.quotaRemaining == 0
    }
    
    var body: some View {
        Button(action: {
            if isLocked {
                showPaywall = true
            } else {
                onTap()
            }
        }) {
            FortuneCardContent(
                title: title,
                description: description,
                icon: icon,
                color: color,
                isLocked: isLocked
            )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isLocked)
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
    }
}

// MARK: - Preview
struct FortuneCardView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Unlocked card
            FortuneCardView(
                title: "Face Reading",
                description: "Discover your personality",
                icon: "face.smiling",
                color: .primary,
                onTap: {}
            )
            .padding()
            
            // Locked card
            FortuneCardView(
                title: "Palm Reading",
                description: "Read your life lines",
                icon: "hand.raised.fill",
                color: .accent,
                onTap: {}
            )
            .padding()
        }
        .preferredColorScheme(.dark)
    }
}


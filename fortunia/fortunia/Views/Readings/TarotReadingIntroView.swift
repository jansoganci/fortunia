//
//  TarotReadingIntroView.swift
//  fortunia
//
//  Created by Cursor AI on December 19, 2024
//

import SwiftUI

struct TarotReadingIntroView: View {
    var body: some View {
        ZStack {
            Color.backgroundPrimary.ignoresSafeArea()

            ScrollView {
                VStack(spacing: Spacing.lg) {
                    Spacer(minLength: Spacing.lg)

                    // Header Icon
                    Image(systemName: "rectangle.portrait.fill")
                        .font(.system(size: 64, weight: .thin))
                        .foregroundColor(.accent)
                        .padding()
                        .background(Color.primary.opacity(0.1).clipShape(Circle()))

                    // Content
                    VStack(spacing: Spacing.md) {
                        Text(NSLocalizedString("home_tarot_cards", comment: "Tarot Cards"))
                            .font(AppTypography.heading1)
                            .foregroundColor(.textPrimary)

                        Text(NSLocalizedString("home_tarot_cards_desc", comment: "Tarot Cards description"))
                            .font(AppTypography.bodyMedium)
                            .foregroundColor(.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, Spacing.md)

                    Spacer(minLength: Spacing.xxl)

                    // Coming Soon Placeholder
                    ComingSoonView()
                        .padding(.horizontal, Spacing.xl)
                    
                    Spacer(minLength: Spacing.md)
                }
            }
        }
        .navigationTitle(NSLocalizedString("home_tarot_cards", comment: "Tarot Cards"))
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct TarotReadingIntroView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TarotReadingIntroView()
        }
        .preferredColorScheme(.dark)
    }
}



//
//  ComingSoonView.swift
//  fortunia
//
//  Created by Can Soğancı on 25.10.2025.
//

import SwiftUI

struct ComingSoonView: View {
    var body: some View {
        ZStack {
            Color.backgroundPrimary.ignoresSafeArea()
            
            VStack(spacing: Spacing.lg) {
                Image(systemName: "wand.and.stars")
                    .font(.system(size: 56))
                    .foregroundColor(.primary)
                
                Text(LocalizedStringKey("coming_soon_title")) // localized
                    .font(AppTypography.heading1)
                    .foregroundColor(.textPrimary)
                
                Text(LocalizedStringKey("coming_soon_subtitle")) // localized
                    .font(AppTypography.bodyMedium)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.xl)
            }
        }
    }
}

struct ComingSoonView_Previews: PreviewProvider {
    static var previews: some View {
        ComingSoonView()
    }
}

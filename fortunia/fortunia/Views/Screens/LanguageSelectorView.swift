//
//  LanguageSelectorView.swift
//  fortunia
//
//  Created by iOS Engineer on December 2024.
//

import SwiftUI

/// A view for selecting and changing the app's language
struct LanguageSelectorView: View {
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @State private var selectedLanguage: String = LocalizationManager.shared.currentLanguage
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.backgroundPrimary
                    .ignoresSafeArea()
                
                VStack(spacing: Spacing.xl) {
                    // Header
                    VStack(spacing: Spacing.md) {
                        Image(systemName: "globe")
                            .font(.system(size: 60))
                            .foregroundColor(.primary)
                        
                        Text("Select Language".localized)
                            .font(AppTypography.heading2)
                            .foregroundColor(.textPrimary)
                        
                        Text("current_language_desc".localized)
                            .font(AppTypography.bodyMedium)
                            .foregroundColor(.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, Spacing.xxl)
                    
                    // Current Language Display
                    VStack(spacing: Spacing.sm) {
                        Text("Current Language:".localized)
                            .font(AppTypography.bodySmall)
                            .foregroundColor(.textSecondary)
                        
                        Text(localizationManager.languageDisplayNames[localizationManager.currentLanguage] ?? "Unknown")
                            .font(AppTypography.heading3)
                            .foregroundColor(.primary)
                            .padding(Spacing.md)
                            .background(
                                RoundedRectangle(cornerRadius: CornerRadius.md)
                                    .fill(Color.surface)
                            )
                    }
                    .padding(.horizontal, Spacing.xl)
                    
                    // Language Picker
                    VStack(spacing: Spacing.md) {
                        Text("Choose Language:".localized)
                            .font(AppTypography.heading4)
                            .foregroundColor(.textPrimary)
                        
                        Picker("".localized, selection: $selectedLanguage) {
                            ForEach(localizationManager.supportedLanguages, id: \.self) { code in
                                Text(localizationManager.languageDisplayNames[code] ?? code)
                                    .tag(code)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .onChange(of: selectedLanguage) { newValue in
                            localizationManager.setLanguage(newValue)
                        }
                    }
                    .padding(.horizontal, Spacing.xl)
                    
                    // Info
                    VStack(spacing: Spacing.sm) {
                        HStack(spacing: Spacing.sm) {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(.primary)
                            Text("language_change_info".localized)
                                .font(AppTypography.caption)
                        }
                        .foregroundColor(.textSecondary)
                        .padding(Spacing.md)
                        .background(
                            RoundedRectangle(cornerRadius: CornerRadius.md)
                                .fill(Color.primary.opacity(0.1))
                        )
                    }
                    .padding(.horizontal, Spacing.xl)
                    .padding(.top, Spacing.lg)
                    
                    Spacer()
                }
            }
            .navigationTitle("Language Settings".localized)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Preview
struct LanguageSelectorView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LanguageSelectorView()
                .preferredColorScheme(.light)
                .previewDisplayName(NSLocalizedString("preview_light_mode", comment: "Light mode preview"))
            
            LanguageSelectorView()
                .preferredColorScheme(.dark)
                .previewDisplayName(NSLocalizedString("preview_dark_mode", comment: "Dark mode preview"))
        }
    }
}

//
//  HistoryView.swift
//  fortunia
//
//  Created by Cursor AI on January 26, 2025
//

import SwiftUI

/// Simple, elegant History View - following Jobs' "radical simplicity" philosophy
///
/// Key principles:
/// - One primary action per screen (tap to view reading)
/// - Minimal, clean design
/// - Focus on content, not chrome
/// - Addictive UI like successful apps (Instagram, TikTok)
struct HistoryView: View {
    @StateObject private var viewModel = HistoryViewModel()
    @State private var selectedReading: FortuneReading?
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.backgroundPrimary
                    .ignoresSafeArea()
                
                contentView
            }
            .navigationTitle(NSLocalizedString("history_title", comment: "History"))
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !viewModel.readings.isEmpty {
                        Button(action: {
                            Task { await viewModel.refresh() }
                        }) {
                            Image(systemName: "arrow.clockwise")
                                .foregroundColor(.primary)
                        }
                    }
                }
            }
        }
        .task {
            await viewModel.loadReadings()
        }
        .refreshable {
            await viewModel.refresh()
        }
    }
    
    // MARK: - Content Views
    
    @ViewBuilder
    private var contentView: some View {
        if viewModel.isLoading {
            loadingView
        } else if viewModel.readings.isEmpty {
            emptyStateView
        } else {
            readingsList
        }
    }
    
    // MARK: - Loading State
    
    private var loadingView: some View {
        VStack(spacing: Spacing.md) {
            ProgressView()
                .scaleEffect(1.2)
            Text(NSLocalizedString("history_loading", comment: "Loading your history..."))
                .font(AppTypography.bodyMedium)
                .foregroundColor(.textSecondary)
        }
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: Spacing.lg) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 48))
                .foregroundColor(.textSecondary)
            
            Text(NSLocalizedString("history_empty_title", comment: "No Readings Yet"))
                .font(AppTypography.heading2)
                .foregroundColor(.textPrimary)
            
            Text(NSLocalizedString("history_empty_subtitle", comment: "Your fortune readings will appear here"))
                .font(AppTypography.bodyMedium)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.xl)
        }
        .padding(.top, Spacing.xxxl)
    }
    
    // MARK: - Readings List
    
    private var readingsList: some View {
        ScrollView {
            LazyVStack(spacing: Spacing.md) {
                ForEach(viewModel.readings) { reading in
                    ReadingHistoryCard(reading: reading) {
                        selectedReading = reading
                    }
                    .contextMenu {
                        Button(role: .destructive, action: {
                            Task { await viewModel.deleteReading(reading) }
                        }) {
                            Label(NSLocalizedString("history_delete", comment: "Delete"), systemImage: "trash")
                        }
                    }
                }
            }
            .padding(Spacing.md)
        }
        .sheet(item: $selectedReading) { reading in
            NavigationView {
                ReadingDetailView(reading: reading)
            }
        }
    }
}

// MARK: - Reading History Card

/// Simple, elegant card following Instagram/TikTok style
///
/// Shows: Reading type icon + preview + date
/// One tap to view full reading
struct ReadingHistoryCard: View {
    let reading: FortuneReading
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: Spacing.md) {
                // Icon
                ZStack {
                    Circle()
                        .fill(iconColor)
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                }
                
                // Content
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(readingTypeDisplayName)
                        .font(AppTypography.heading4)
                        .foregroundColor(.textPrimary)
                    
                    Text(previewText)
                        .font(AppTypography.bodySmall)
                        .foregroundColor(.textSecondary)
                        .lineLimit(2)
                    
                    Text(formattedDate)
                        .font(AppTypography.caption)
                        .foregroundColor(.textSecondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.textSecondary)
                    .font(.system(size: 14))
            }
            .padding(Spacing.md)
            .background(Color.surface)
            .cornerRadius(CornerRadius.lg)
            .shadow(
                color: Elevation.level2.color,
                radius: Elevation.level2.radius,
                x: Elevation.level2.x,
                y: Elevation.level2.y
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Computed Properties
    
    private var icon: String {
        switch reading.readingType {
        case "face": return "face.smiling"
        case "palm": return "hand.raised"
        case "tarot": return "sparkles"
        case "coffee": return "cup.and.saucer"
        default: return "circle"
        }
    }
    
    private var iconColor: Color {
        switch reading.readingType {
        case "face": return .primary
        case "palm": return .accent
        case "tarot": return Color(hex: "#8B7AB8")
        case "coffee": return Color(hex: "#E8B298")
        default: return .gray
        }
    }
    
    private var readingTypeDisplayName: String {
        switch reading.readingType {
        case "face": return NSLocalizedString("reading_type_face", comment: "Face Reading")
        case "palm": return NSLocalizedString("reading_type_palm", comment: "Palm Reading")
        case "tarot": return NSLocalizedString("reading_type_tarot", comment: "Tarot Reading")
        case "coffee": return NSLocalizedString("reading_type_coffee", comment: "Coffee Reading")
        default: return reading.readingType.capitalized
        }
    }
    
    private var previewText: String {
        let maxLength = 80
        if reading.resultText.count <= maxLength {
            return reading.resultText
        }
        return String(reading.resultText.prefix(maxLength)) + "..."
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: reading.createdAt)
    }
}

// MARK: - Reading Detail View

/// Simple detail view to show full reading
struct ReadingDetailView: View {
    let reading: FortuneReading
    @Environment(\.dismiss) private var dismiss
    @State private var shareImage: UIImage?
    @State private var showShareSheet = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    // Header
                    HStack {
                        ZStack {
                            Circle()
                                .fill(iconColor)
                                .frame(width: 48, height: 48)
                            
                            Image(systemName: icon)
                                .font(.system(size: 22))
                                .foregroundColor(.white)
                        }
                        
                        VStack(alignment: .leading, spacing: Spacing.xs) {
                            Text(readingTypeDisplayName)
                                .font(AppTypography.heading3)
                                .foregroundColor(.textPrimary)
                            
                            Text(formattedDate)
                                .font(AppTypography.caption)
                                .foregroundColor(.textSecondary)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            showShareSheet = true
                        }) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 20))
                                .foregroundColor(.primary)
                        }
                    }
                    .padding(.horizontal, Spacing.md)
                    .padding(.top, Spacing.lg)
                    
                    // Content
                    Text(reading.resultText)
                        .font(AppTypography.bodyLarge)
                        .foregroundColor(.textPrimary)
                        .lineSpacing(8)
                        .padding(.horizontal, Spacing.md)
                    
                    // Disclaimer (legal requirement)
                    DisclaimerView()
                        .padding(.horizontal, Spacing.md)
                        .padding(.bottom, Spacing.lg)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(NSLocalizedString("done_button", comment: "Done")) {
                        dismiss()
                    }
                    .foregroundColor(.primary)
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            if let shareImage = shareImage {
                ShareSheet(items: [shareImage])
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var icon: String {
        switch reading.readingType {
        case "face": return "face.smiling"
        case "palm": return "hand.raised"
        case "tarot": return "sparkles"
        case "coffee": return "cup.and.saucer"
        default: return "circle"
        }
    }
    
    private var iconColor: Color {
        switch reading.readingType {
        case "face": return .primary
        case "palm": return .accent
        case "tarot": return Color(hex: "#8B7AB8")
        case "coffee": return Color(hex: "#E8B298")
        default: return .gray
        }
    }
    
    private var readingTypeDisplayName: String {
        switch reading.readingType {
        case "face": return NSLocalizedString("reading_type_face", comment: "Face Reading")
        case "palm": return NSLocalizedString("reading_type_palm", comment: "Palm Reading")
        case "tarot": return NSLocalizedString("reading_type_tarot", comment: "Tarot Reading")
        case "coffee": return NSLocalizedString("reading_type_coffee", comment: "Coffee Reading")
        default: return reading.readingType.capitalized
        }
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: reading.createdAt)
    }
}



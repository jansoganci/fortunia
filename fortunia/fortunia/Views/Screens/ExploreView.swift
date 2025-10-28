//
//  ExploreView.swift
//  fortunia
//
//  Created by Cursor AI on January 26, 2025
//

import SwiftUI

/// Explore View - Daily Horoscope & Discover New Content
/// 
/// This is NOT a duplicate of Home. Home = Do readings. Explore = Get quick daily insights.
///
/// Features:
/// - Daily horoscope (changes every day)
/// - Weekly forecast
/// - Cultural spotlights
/// - Discovery content
struct ExploreView: View {
    @StateObject private var viewModel = ExploreViewModel()
    @State private var showBirthInfoAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.backgroundPrimary
                    .ignoresSafeArea()
                
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    ScrollView {
                        VStack(spacing: Spacing.lg) {
                            // Daily Horoscope Card
                            DailyHoroscopeCard(
                                horoscope: viewModel.dailyHoroscope,
                                zodiacSign: viewModel.zodiacSign
                            ) {
                                handleGetPersonalReading()
                            }
                            
                            // Weekly Forecast Card
                            WeeklyForecastCard(forecast: viewModel.weeklyForecast)
                            
                            // Cultural Spotlight
                            CulturalSpotlightCard()
                        }
                        .padding(Spacing.md)
                    }
                }
            }
            .navigationTitle(NSLocalizedString("explore_title", comment: "Explore"))
            .navigationBarTitleDisplayMode(.large)
        }
        .task {
            await viewModel.loadDailyHoroscope()
        }
        .alert(
            NSLocalizedString("birth_info_required", comment: "Birth Info Required"),
            isPresented: $showBirthInfoAlert
        ) {
            Button(NSLocalizedString("later_button", comment: "Later"), role: .cancel) { }
            Button(NSLocalizedString("add_button", comment: "Add")) {
                // Navigate to profile to add birth info
            }
        } message: {
            Text(NSLocalizedString("birth_info_required_message", comment: "Please add your birth info to get personalized horoscope"))
        }
    }
    
    // MARK: - Private Methods
    
    private func handleGetPersonalReading() {
        // Navigate to home to start reading
        NotificationCenter.default.post(name: Notification.Name("navigateToHome"), object: nil)
    }
}

// MARK: - Daily Horoscope Card
struct DailyHoroscopeCard: View {
    let horoscope: DailyHoroscope?
    let zodiacSign: String
    let onGetReading: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            // Header
            HStack {
                Image(systemName: "sparkles")
                    .font(.system(size: 24))
                    .foregroundColor(.primary)
                
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(NSLocalizedString("explore_daily_horoscope", comment: "Daily Horoscope"))
                        .font(AppTypography.heading3)
                        .foregroundColor(.textPrimary)
                    
                    if horoscope != nil {
                        Text("\(zodiacSign) • \(formattedDate)")
                            .font(AppTypography.caption)
                            .foregroundColor(.textSecondary)
                    }
                }
                
                Spacer()
            }
            
            if let horoscope = horoscope {
                // Fortune Text
                Text(horoscope.prediction)
                    .font(AppTypography.bodyLarge)
                    .foregroundColor(.textPrimary)
                    .lineSpacing(8)
                
                // Ratings
                HStack(spacing: Spacing.md) {
                    RatingView(
                        category: NSLocalizedString("horoscope_love", comment: "Love"),
                        rating: horoscope.ratings.love
                    )
                    
                    RatingView(
                        category: NSLocalizedString("horoscope_career", comment: "Career"),
                        rating: horoscope.ratings.career
                    )
                    
                    RatingView(
                        category: NSLocalizedString("horoscope_health", comment: "Health"),
                        rating: horoscope.ratings.health
                    )
                }
                
                Divider()
                
                // CTA
                Button(action: onGetReading) {
                    HStack {
                        Image(systemName: "wand.and.stars")
                        Text(NSLocalizedString("explore_get_personal_reading", comment: "Get Personal Reading"))
                            .fontWeight(.semibold)
                        Spacer()
                        Image(systemName: "arrow.right")
                    }
                    .font(AppTypography.bodyMedium)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(Spacing.md)
                    .background(
                        LinearGradient(
                            colors: [.primary, .accent],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(CornerRadius.md)
                }
            } else {
                Text(NSLocalizedString("explore_no_birth_info", comment: "Add your birth info for personalized horoscope"))
                    .font(AppTypography.bodyMedium)
                    .foregroundColor(.textSecondary)
                    .italic()
            }
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
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: Date())
    }
}

// MARK: - Rating View
struct RatingView: View {
    let category: String
    let rating: Int
    
    var body: some View {
        VStack(spacing: Spacing.xs) {
            Text(category)
                .font(AppTypography.caption)
                .foregroundColor(.textSecondary)
            
            HStack(spacing: 2) {
                ForEach(1...5, id: \.self) { index in
                    Image(systemName: index <= rating ? "star.fill" : "star")
                        .font(.system(size: 12))
                        .foregroundColor(index <= rating ? .accent : .gray.opacity(0.3))
                }
            }
        }
    }
}

// MARK: - Weekly Forecast Card
struct WeeklyForecastCard: View {
    let forecast: WeeklyForecast?
    
    var body: some View {
        if let forecast = forecast {
            VStack(alignment: .leading, spacing: Spacing.md) {
                HStack {
                    Image(systemName: "calendar")
                        .font(.system(size: 20))
                        .foregroundColor(.primary)
                    
                    Text(NSLocalizedString("explore_weekly_forecast", comment: "Weekly Forecast"))
                        .font(AppTypography.heading4)
                        .foregroundColor(.textPrimary)
                    
                    Spacer()
                }
                
                Text(forecast.summary)
                    .font(AppTypography.bodyMedium)
                    .foregroundColor(.textPrimary)
                    .lineSpacing(6)
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
    }
}

// MARK: - Cultural Spotlight Card
struct CulturalSpotlightCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                Image(systemName: "globe")
                    .font(.system(size: 20))
                    .foregroundColor(.primary)
                
                Text(NSLocalizedString("explore_cultural_spotlight", comment: "Cultural Spotlight"))
                    .font(AppTypography.heading4)
                    .foregroundColor(.textPrimary)
                
                Spacer()
            }
            
            Text(NSLocalizedString("explore_discover_traditions", comment: "Discover ancient fortune traditions from around the world"))
                .font(AppTypography.bodyMedium)
                .foregroundColor(.textSecondary)
                .lineSpacing(6)
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
}

// MARK: - Models
struct DailyHoroscope: Codable {
    let sign: String
    let prediction: String
    let ratings: Ratings
    let date: String
}

struct Ratings: Codable {
    let love: Int
    let career: Int
    let health: Int
}

struct WeeklyForecast: Codable {
    let summary: String
    let weekStart: String
    let weekEnd: String
}


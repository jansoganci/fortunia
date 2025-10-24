//
//  MainTabView.swift
//  fortunia
//
//  Created by Can Soğancı on 24.10.2025.
//

import SwiftUI

// MARK: - Main Tab View
struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Home Tab
            HomeView()
                .tabItem {
                    Image(systemName: selectedTab == 0 ? "house.fill" : "house")
                    Text("Home")
                }
                .tag(0)
            
            // Explore Tab
            ExploreView()
                .tabItem {
                    Image(systemName: selectedTab == 1 ? "sparkles" : "sparkles")
                    Text("Explore")
                }
                .tag(1)
            
            // History Tab
            HistoryView()
                .tabItem {
                    Image(systemName: selectedTab == 2 ? "clock.fill" : "clock")
                    Text("History")
                }
                .tag(2)
            
            // Profile Tab
            ProfileView()
                .tabItem {
                    Image(systemName: selectedTab == 3 ? "person.circle.fill" : "person.circle")
                    Text("Profile")
                }
                .tag(3)
        }
        .accentColor(.primary)
        .onAppear {
            setupTabBarAppearance()
        }
    }
    
    // MARK: - Tab Bar Appearance
    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color.surface)
        
        // Selected item color
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color.primary)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(Color.primary)
        ]
        
        // Normal item color
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor(Color.textSecondary)
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor(Color.textSecondary)
        ]
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

// MARK: - Home View
struct HomeView: View {
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color.backgroundPrimary
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: Spacing.lg) {
                        // Header
                        VStack(spacing: Spacing.sm) {
                            Text("Discover Your Fortune")
                                .font(AppTypography.heading1)
                                .foregroundColor(.textPrimary)
                                .multilineTextAlignment(.center)
                            
                            Text("Choose your reading method")
                                .font(AppTypography.bodyMedium)
                                .foregroundColor(.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, Spacing.lg)
                        
                        // Fortune Types Grid
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: Spacing.md) {
                            FortuneTypeCard(
                                title: "Face Reading",
                                description: "Discover your personality",
                                icon: "face.smiling",
                                color: .primary
                            )
                            
                            FortuneTypeCard(
                                title: "Palm Reading",
                                description: "Read your life lines",
                                icon: "hand.raised.fill",
                                color: .accent
                            )
                            
                            FortuneTypeCard(
                                title: "Tarot Cards",
                                description: "Get guidance from cards",
                                icon: "rectangle.portrait.fill",
                                color: .primary
                            )
                            
                            FortuneTypeCard(
                                title: "Coffee Reading",
                                description: "Interpret coffee grounds",
                                icon: "cup.and.saucer.fill",
                                color: .accent
                            )
                        }
                        .padding(.horizontal, Spacing.md)
                        
                        // Daily Quota
                        QuotaCard()
                            .padding(.horizontal, Spacing.md)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Explore View
struct ExploreView: View {
    var body: some View {
        NavigationView {
            ZStack {
                Color.backgroundPrimary
                    .ignoresSafeArea()
                
                VStack {
                    Text("Explore")
                        .font(AppTypography.heading1)
                        .foregroundColor(.textPrimary)
                    
                    Text("Discover new fortune reading methods")
                        .font(AppTypography.bodyMedium)
                        .foregroundColor(.textSecondary)
                        .multilineTextAlignment(.center)
                    
                    Spacer()
                }
                .padding(.top, Spacing.lg)
            }
            .navigationBarHidden(true)
        }
    }
}

// MARK: - History View
struct HistoryView: View {
    var body: some View {
        NavigationView {
            ZStack {
                Color.backgroundPrimary
                    .ignoresSafeArea()
                
                VStack {
                    Text("History")
                        .font(AppTypography.heading1)
                        .foregroundColor(.textPrimary)
                    
                    Text("Your past readings")
                        .font(AppTypography.bodyMedium)
                        .foregroundColor(.textSecondary)
                        .multilineTextAlignment(.center)
                    
                    Spacer()
                }
                .padding(.top, Spacing.lg)
            }
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Profile View
struct ProfileView: View {
    var body: some View {
        NavigationView {
            ZStack {
                Color.backgroundPrimary
                    .ignoresSafeArea()
                
                VStack {
                    Text("Profile")
                        .font(AppTypography.heading1)
                        .foregroundColor(.textPrimary)
                    
                    Text("Manage your account")
                        .font(AppTypography.bodyMedium)
                        .foregroundColor(.textSecondary)
                        .multilineTextAlignment(.center)
                    
                    Spacer()
                }
                .padding(.top, Spacing.lg)
            }
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Fortune Type Card
struct FortuneTypeCard: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    
    var body: some View {
        Button(action: {
            // TODO: Navigate to fortune reading
        }) {
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
                
                // Text
                VStack(spacing: Spacing.xs) {
                    Text(title)
                        .font(AppTypography.heading4)
                        .foregroundColor(.textPrimary)
                        .multilineTextAlignment(.center)
                    
                    Text(description)
                        .font(AppTypography.caption)
                        .foregroundColor(.textSecondary)
                        .multilineTextAlignment(.center)
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
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Quota Card
struct QuotaCard: View {
    @State private var dailyQuotaUsed = 1
    @State private var dailyQuotaLimit = 3
    @State private var isPremium = false
    
    var body: some View {
        VStack(spacing: Spacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("Daily Readings")
                        .font(AppTypography.heading4)
                        .foregroundColor(.textPrimary)
                    
                    Text(isPremium ? "Unlimited" : "\(dailyQuotaUsed)/\(dailyQuotaLimit) remaining")
                        .font(AppTypography.bodySmall)
                        .foregroundColor(.textSecondary)
                }
                
                Spacer()
                
                if isPremium {
                    PremiumBadge()
                } else {
                    Button("Upgrade") {
                        // TODO: Show paywall
                    }
                    .font(AppTypography.caption)
                    .foregroundColor(.primary)
                }
            }
            
            if !isPremium {
                // Progress Bar
                ProgressView(value: Double(dailyQuotaUsed), total: Double(dailyQuotaLimit))
                    .progressViewStyle(LinearProgressViewStyle(tint: .primary))
                    .frame(height: 8)
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
}

// MARK: - Premium Badge
struct PremiumBadge: View {
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "crown.fill")
                .font(.system(size: 12))
            Text("PRO")
                .font(AppTypography.caption)
                .fontWeight(.bold)
        }
        .foregroundColor(.white)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            LinearGradient(
                colors: [Color(hex: "#FFD700"), Color(hex: "#FFA500")],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(CornerRadius.xs)
    }
}

// MARK: - Preview
struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MainTabView()
                .preferredColorScheme(.light)
                .previewDisplayName("Light Mode")
            
            MainTabView()
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark Mode")
        }
    }
}

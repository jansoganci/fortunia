//
//  MainTabView.swift
//  fortunia
//
//  Created by Can Soğancı on 24.10.2025.
//

import SwiftUI

// MARK: - Main Tab View
struct MainTabView: View {
    @EnvironmentObject var localizationManager: LocalizationManager
    @EnvironmentObject var themeManager: ThemeManager
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Home Tab
            NavigationView {
                HomeView()
            }
            .tabItem {
                Image(systemName: selectedTab == 0 ? "house.fill" : "house")
                Text("tab_home".localized)
            }
            .tag(0)
            
            // Explore Tab
            ExploreView()
                .tabItem {
                    Image(systemName: selectedTab == 1 ? "sparkles" : "sparkles")
                    Text("tab_explore".localized)
                }
                .tag(1)
            
            // History Tab
            HistoryView()
                .tabItem {
                    Image(systemName: selectedTab == 2 ? "clock.fill" : "clock")
                    Text("tab_history".localized)
                }
                .tag(2)
            
            // Profile Tab
            ProfileView()
                .tabItem {
                    Image(systemName: selectedTab == 3 ? "person.circle.fill" : "person.circle")
                    Text("tab_profile".localized)
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

// MARK: - Explore View
// Now implemented with daily horoscope feature
// See ExploreView.swift for full implementation

// MARK: - History View
// Note: HistoryView is now in its own file (Views/Screens/HistoryView.swift)
// Import is handled automatically by SwiftUI

// MARK: - Profile View
struct ProfileView: View {
    @EnvironmentObject var localizationManager: LocalizationManager
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject private var authService = AuthService.shared
    @State private var selectedLanguage: String = ""
    @State private var selectedTheme: String = ""
    @State private var showSignOutAlert = false
    @State private var showBirthInfoModal = false
    @State private var showPaywall = false
    @State private var isPremium = false
    
    // Available languages for dropdown
    private let languages = [
        (code: "en", name: "English"),
        (code: "es", name: "Español")
    ]
    
    // Available themes for dropdown
    private let themes = [
        (code: "light", name: "Light", icon: "sun.max.fill"),
        (code: "dark", name: "Dark", icon: "moon.fill"),
        (code: "system", name: "System", icon: "circle.lefthalf.filled")
    ]
    
    // Check if user is premium
    private func checkPremiumStatus() {
        isPremium = QuotaManager.shared.isPremiumUser
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.backgroundPrimary
                    .ignoresSafeArea()
                
                List {
                    premiumSection
                    userSection
                    languageSection
                    themeSection
                    legalSection
                    signOutSection
                }
                .listStyle(InsetGroupedListStyle())
            }
            .navigationTitle("Profile".localized)
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear {
            selectedLanguage = localizationManager.currentLanguage
            selectedTheme = themeManager.currentTheme
            checkPremiumStatus()
        }
        .onChange(of: localizationManager.currentLanguage) { newValue in
            selectedLanguage = newValue
        }
        .onChange(of: themeManager.currentTheme) { newValue in
            selectedTheme = newValue
        }
        .sheet(isPresented: $showBirthInfoModal) {
            BirthInfoModalView(onComplete: {
                showBirthInfoModal = false
            })
        }
        .fullScreenCover(isPresented: $showPaywall) {
            PaywallView()
        }
        .alert("sign_out_confirmation".localized, isPresented: $showSignOutAlert) {
            Button("cancel_button".localized, role: .cancel) { }
            Button("sign_out".localized, role: .destructive) {
                signOut()
            }
        }
    }
    
    // MARK: - Private Methods
    
    private var premiumSection: some View {
        Group {
            if !isPremium {
                Section {
                    Button(action: { showPaywall = true }) {
                        HStack {
                            Image(systemName: "crown.fill")
                                .foregroundColor(.accent)
                                .font(.system(size: 24))
                            
                            VStack(alignment: .leading, spacing: Spacing.xs) {
                                Text("unlock_premium".localized)
                                    .font(AppTypography.heading3)
                                    .foregroundColor(.textPrimary)
                                
                                Text("upgrade_to_premium_desc".localized)
                                    .font(AppTypography.bodySmall)
                                    .foregroundColor(.textSecondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.textSecondary)
                        }
                        .padding(.vertical, Spacing.sm)
                    }
                }
            }
        }
    }
    
    private var userSection: some View {
        Section {
            Button(action: { showBirthInfoModal = true }) {
                HStack(spacing: Spacing.md) {
                    Image(systemName: "person.circle.fill")
                        .foregroundColor(.primary)
                        .frame(width: 24)
                    
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text(getUserEmail())
                            .font(AppTypography.bodyMedium)
                            .foregroundColor(.textPrimary)
                        
                        Text("tap_to_edit_birth_info".localized)
                            .font(AppTypography.caption)
                            .foregroundColor(.textSecondary)
                    }
                    
                    Spacer()
                }
                .padding(.vertical, Spacing.xs)
            }
        }
    }
    
    private var languageSection: some View {
        Section(header: Text("Language Settings".localized)) {
            HStack(spacing: Spacing.md) {
                Image(systemName: "globe")
                    .foregroundColor(.primary)
                    .frame(width: 24)
                
                Text("Language".localized)
                    .font(AppTypography.bodyMedium)
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                Menu {
                    ForEach(languages, id: \.code) { language in
                        Button(action: {
                            selectedLanguage = language.code
                            localizationManager.setLanguage(language.code)
                        }) {
                            HStack {
                                Text(language.name)
                                if selectedLanguage == language.code {
                                    Spacer()
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.primary)
                                }
                            }
                        }
                    }
                } label: {
                    HStack(spacing: Spacing.xs) {
                        Text(selectedLanguageDisplayName)
                            .font(AppTypography.bodyMedium)
                            .foregroundColor(.primary)
                        
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12))
                            .foregroundColor(.textSecondary)
                    }
                }
            }
            .padding(.vertical, Spacing.xs)
        }
    }
    
    private var themeSection: some View {
        Section(header: Text("Theme Settings".localized)) {
            HStack(spacing: Spacing.md) {
                Image(systemName: "paintbrush.fill")
                    .foregroundColor(.primary)
                    .frame(width: 24)
                
                Text("Theme".localized)
                    .font(AppTypography.bodyMedium)
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                Menu {
                    ForEach(themes, id: \.code) { theme in
                        Button(action: {
                            selectedTheme = theme.code
                            themeManager.setTheme(theme.code)
                        }) {
                            HStack {
                                Image(systemName: theme.icon)
                                    .foregroundColor(.primary)
                                Text(theme.name)
                                if selectedTheme == theme.code {
                                    Spacer()
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.primary)
                                }
                            }
                        }
                    }
                } label: {
                    HStack(spacing: Spacing.xs) {
                        Text(selectedThemeDisplayName)
                            .font(AppTypography.bodyMedium)
                            .foregroundColor(.primary)
                        
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12))
                            .foregroundColor(.textSecondary)
                    }
                }
            }
            .padding(.vertical, Spacing.xs)
        }
    }
    
    private var legalSection: some View {
        Section(header: Text("legal".localized)) {
            NavigationLink(destination: WebView(url: "https://fortunia.app/privacy")) {
                ProfileRow(
                    icon: "hand.raised.fill",
                    title: "privacy_policy".localized,
                    showChevron: false
                )
            }
            
            NavigationLink(destination: WebView(url: "https://fortunia.app/terms")) {
                ProfileRow(
                    icon: "doc.text.fill",
                    title: "terms_of_service".localized,
                    showChevron: false
                )
            }
        }
    }
    
    private var signOutSection: some View {
        Section {
            Button(action: { showSignOutAlert = true }) {
                ProfileRow(
                    icon: "rectangle.portrait.and.arrow.right",
                    title: "sign_out".localized,
                    showChevron: false,
                    isDestructive: true
                )
            }
        }
    }
    
    private func getUserEmail() -> String {
        guard let supabase = SupabaseService.shared.supabase else {
            return "User"
        }
        return supabase.auth.currentUser?.email ?? "User"
    }
    
    private func signOut() {
        Task {
            do {
                try await authService.signOut()
            } catch {
                print("Sign out error: \(error)")
            }
        }
    }
    
    // Computed property for language display name
    private var selectedLanguageDisplayName: String {
        return languages.first(where: { $0.code == selectedLanguage })?.name ?? "English"
    }
    
    // Computed property for theme display name
    private var selectedThemeDisplayName: String {
        return themes.first(where: { $0.code == selectedTheme })?.name ?? "System"
    }
}

// MARK: - Quota Card
struct QuotaCard: View {
    @State private var remainingQuota = 0
    @State private var dailyQuotaLimit = 3
    @State private var isPremium = false
    @State private var isLoading = false
    @State private var showPaywall = false
    @State private var hasLoadedOnce = false
    @State private var lastLoadTime: Date?
    
    var body: some View {
        VStack(spacing: Spacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(LocalizedStringKey("quota_daily_readings")) // localized
                        .font(AppTypography.heading4)
                        .foregroundColor(.textPrimary)
                    
                    if isLoading {
                        HStack {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text(NSLocalizedString("quota_loading", comment: "Loading..."))
                                .font(AppTypography.bodySmall)
                                .foregroundColor(.textSecondary)
                        }
                    } else if isPremium {
                        Text(NSLocalizedString("quota_unlimited", comment: "Unlimited"))
                            .font(AppTypography.bodySmall)
                            .foregroundColor(.textSecondary)
                    } else {
                        let quotaUsed = dailyQuotaLimit - remainingQuota
                        Text("\(quotaUsed)/\(dailyQuotaLimit) " + NSLocalizedString("quota_remaining", comment: "remaining"))
                            .font(AppTypography.bodySmall)
                            .foregroundColor(.textSecondary)
                    }
                }
                
                Spacer()
                
                if isPremium {
                    PremiumBadge()
                } else {
                    Button(NSLocalizedString("quota_upgrade_button", comment: "Upgrade")) {
                        showPaywall = true
                    }
                    .font(AppTypography.caption)
                    .foregroundColor(.primary)
                }
            }
            
            if !isPremium && !isLoading {
                // Progress Bar
                let quotaUsed = dailyQuotaLimit - remainingQuota
                ProgressView(value: Double(quotaUsed), total: Double(dailyQuotaLimit))
                    .progressViewStyle(LinearProgressViewStyle(tint: .primary))
                    .frame(height: 8)
                
                // Quota exhausted message
                if remainingQuota == 0 {
                    HStack {
                        Image(systemName: "lock.fill")
                            .foregroundColor(.orange)
                        Text(NSLocalizedString("quota_exhausted_message", comment: "You've reached your daily limit. Upgrade for more readings."))
                            .font(AppTypography.caption)
                            .foregroundColor(.orange)
                    }
                    .padding(.top, Spacing.xs)
                }
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
        .task {
            await loadQuotaAsyncIfNeeded()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            // Refresh quota when app comes to foreground (with cooldown)
            Task {
                await loadQuotaAsyncIfNeeded()
            }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
    }
    
    // MARK: - Private Methods
    
    /// Load quota only if not recently loaded (within 5 minutes)
    private func loadQuotaAsyncIfNeeded() async {
        // Skip if already loaded within cooldown period
        if let lastLoadTime = lastLoadTime,
           Date().timeIntervalSince(lastLoadTime) < 300 {
            DebugLogger.shared.quota("QuotaCard: Skipping fetch (within cooldown period)")
            return
        }
        
        await loadQuotaAsync()
    }
    
    private func loadQuotaAsync() async {
        isLoading = true
        
        do {
            let remaining = try await QuotaManager.shared.fetchQuota()
            
            await MainActor.run {
                self.remainingQuota = remaining
                self.isLoading = false
                self.hasLoadedOnce = true
                self.lastLoadTime = Date()
            }
            
            // Log analytics
            AnalyticsService.shared.logEvent("quota_fetch", parameters: [
                "remaining": remaining
            ])
            
        } catch {
            DebugLogger.shared.warning("Failed to fetch quota: \(error.localizedDescription)")
            
            await MainActor.run {
                // Fallback to cached quota
                self.remainingQuota = QuotaManager.shared.getCachedQuota()
                self.isLoading = false
                // Still update timestamp even on error to prevent rapid retries
                self.lastLoadTime = Date()
            }
        }
    }
    
    /// Refresh quota data (call this after consuming quota)
    /// This bypasses the cooldown to ensure fresh data after quota consumption
    func refreshQuota() {
        Task {
            isLoading = true
            
            do {
                let remaining = try await QuotaManager.shared.fetchQuota(forceRefresh: true)
                
                await MainActor.run {
                    self.remainingQuota = remaining
                    self.isLoading = false
                    self.hasLoadedOnce = true
                    self.lastLoadTime = Date()
                }
                
                // Log analytics
                AnalyticsService.shared.logEvent("quota_refreshed", parameters: [
                    "remaining": remaining
                ])
                
            } catch {
                DebugLogger.shared.warning("Failed to refresh quota: \(error.localizedDescription)")
                
                await MainActor.run {
                    // Fallback to cached quota
                    self.remainingQuota = QuotaManager.shared.getCachedQuota()
                    self.isLoading = false
                    self.lastLoadTime = Date()
                }
            }
        }
    }
}

// MARK: - Premium Badge
struct PremiumBadge: View {
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "crown.fill")
                .font(.system(size: 12))
            Text(NSLocalizedString("badge_premium", comment: "PRO")) // localized
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
                .previewDisplayName(NSLocalizedString("preview_light_mode", comment: "Light mode preview"))
            
            MainTabView()
                .preferredColorScheme(.dark)
                .previewDisplayName(NSLocalizedString("preview_dark_mode", comment: "Dark mode preview"))
        }
    }
}


import SwiftUI

struct AppCoordinator: View {
    @State private var appState: AppState = .splash
    @StateObject private var networkMonitor = NetworkMonitor.shared
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var localizationManager = LocalizationManager.shared
    @State private var isCheckingAuth = true
    @State private var isRefreshing = false
    @State private var lastRefreshDate = Date.distantPast

    enum AppState {
        case splash
        case auth
        case main
    }

    var body: some View {
        ZStack {
            if isCheckingAuth {
                // Show splash while checking authentication
                SplashScreen(onComplete: {})
                    .opacity(0)
            } else {
                switch appState {
                case .splash:
                    SplashScreen(onComplete: {
                        withAnimation {
                            appState = .auth
                        }
                    })
                case .auth:
                    AuthScreen(onAuthComplete: {
                        withAnimation {
                            appState = .main
                        }
                    })
                case .main:
                    MainTabView()
                        .environmentObject(networkMonitor)
                        .environmentObject(localizationManager)
                        .environmentObject(themeManager)
                }
            }
        }
        .onAppear(perform: {
            setupAppearance()
            checkExistingSessionAndRefreshPremium()
        })
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            checkExistingSessionAndRefreshPremium()
        }
        .preferredColorScheme(themeManager.colorScheme)
    }
    
    private func setupAppearance() {
        // You can add any global appearance setup here
    }
    
    private func checkExistingSessionAndRefreshPremium() {
        guard !isRefreshing, Date().timeIntervalSince(lastRefreshDate) > 2 else { return }
        
        isRefreshing = true
        lastRefreshDate = Date()
        
        Task {
            defer { isRefreshing = false }
            
            // Check if user is already logged in
            do {
                guard let supabase = SupabaseService.shared.supabase else {
                    await MainActor.run {
                        isCheckingAuth = false
                        appState = .auth
                    }
                    return
                }
                let session = try await supabase.auth.session
                if let userId = AuthService.shared.currentUserId {
                    DebugLogger.shared.quota("User already logged in, refreshing premium status.")
                    await QuotaManager.shared.refreshPremiumStatus(for: userId)
                    
                    // User is authenticated - go directly to main screen
                    await MainActor.run {
                        isCheckingAuth = false
                        appState = .main
                        DebugLogger.shared.quota("✅ Session restored - showing home screen")
                    }
                } else {
                    DebugLogger.shared.quota("Session exists but userId is nil")
                    await MainActor.run {
                        isCheckingAuth = false
                        appState = .auth
                    }
                }
            } catch {
                DebugLogger.shared.quota("No active session found.")
                // No session - show auth screen
                await MainActor.run {
                    isCheckingAuth = false
                    appState = .auth
                }
            }
        }
    }
}

struct AppCoordinator_Previews: PreviewProvider {
    static var previews: some View {
        AppCoordinator()
    }
}


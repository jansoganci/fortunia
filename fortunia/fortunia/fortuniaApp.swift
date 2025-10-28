//
//  fortuniaApp.swift
//  fortunia
//
//  Created by Can Soğancı on 24.10.2025.
//

import SwiftUI
import FirebaseCore
import FirebaseAnalytics
import FirebaseCrashlytics

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        // Configure Crashlytics
        Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(true)
        
        // Start app launch performance trace
        let launchTrace = AnalyticsService.shared.startAppLaunchTrace()
        
        // Store trace for stopping when MainTabView loads
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // This will be stopped when MainTabView appears
            UserDefaults.standard.set(true, forKey: "AppLaunchTraceStarted")
        }
        
        // Initialize Analytics
        AnalyticsService.shared.logAppOpen()
        
        return true
    }
}

@main
struct fortuniaApp: App {
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            AppCoordinator()
        }
    }
}

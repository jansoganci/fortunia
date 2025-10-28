//
//  ThemeManager.swift
//  fortunia
//
//  Created by iOS Engineer on December 2024.
//

import Foundation
import SwiftUI
import Combine

/// ThemeManager manages app theme settings and provides theme switching
/// Supports dynamic theme switching without app restart
class ThemeManager: ObservableObject {
    
    // MARK: - Singleton
    static let shared = ThemeManager()
    
    // MARK: - Published Properties
    @Published var currentTheme: String {
        didSet {
            UserDefaults.standard.set(currentTheme, forKey: "AppTheme")
        }
    }
    
    // MARK: - Supported Themes
    let supportedThemes = ["light", "dark", "system"]
    
    // MARK: - Theme Display Names
    var themeDisplayNames: [String: String] {
        return [
            "light": "Light",
            "dark": "Dark",
            "system": "System"
        ]
    }
    
    // MARK: - Computed Property
    /// Returns SwiftUI ColorScheme based on current theme
    var colorScheme: ColorScheme? {
        switch currentTheme {
        case "light":
            return .light
        case "dark":
            return .dark
        case "system":
            return nil // nil = use system setting
        default:
            return nil
        }
    }
    
    // MARK: - Private Properties
    private let userDefaultsKey = "AppTheme"
    
    // MARK: - Initialization
    private init() {
        // Load saved theme from UserDefaults or default to system
        let savedTheme = UserDefaults.standard.string(forKey: userDefaultsKey)
        
        // Validate theme is supported
        if let saved = savedTheme, supportedThemes.contains(saved) {
            self.currentTheme = saved
        } else {
            self.currentTheme = "system" // Fallback to system
        }
    }
    
    // MARK: - Public Methods
    
    /// Set the app theme
    /// - Parameter theme: Theme name ("light", "dark", or "system")
    func setTheme(_ theme: String) {
        guard supportedThemes.contains(theme) else {
            print("⚠️ [THEME] Unsupported theme: \(theme)")
            return
        }
        
        currentTheme = theme
        print("🎨 [THEME] Theme changed to: \(theme)")
    }
    
    /// Get localized theme name
    /// - Parameter theme: Theme code
    /// - Returns: Localized display name
    func getThemeDisplayName(_ theme: String) -> String {
        return themeDisplayNames[theme] ?? theme
    }
}


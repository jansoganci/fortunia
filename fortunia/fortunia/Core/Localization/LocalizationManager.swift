//
//  LocalizationManager.swift
//  fortunia
//
//  Created by iOS Engineer on December 2024.
//

import Foundation
import Combine

/// LocalizationManager manages app language settings and provides localized strings
/// Supports dynamic language switching without app restart
class LocalizationManager: ObservableObject {
    
    // MARK: - Singleton
    static let shared = LocalizationManager()
    
    // MARK: - Published Properties
    @Published var currentLanguage: String {
        didSet {
            UserDefaults.standard.set(currentLanguage, forKey: "AppLanguage")
            updateBundle()
        }
    }
    
    // MARK: - Supported Languages
    // To add a new language:
    // 1. Create a new .lproj folder (e.g., "de.lproj" for German)
    // 2. Add "de" to this array: ["en", "es", "de"]
    // 3. Add display name below: "de": "Deutsch 🇩🇪"
    let supportedLanguages = ["en", "es"]
    
    // MARK: - Language Display Names
    var languageDisplayNames: [String: String] {
        return [
            "en": "English 🇺🇸",
            "es": "Español 🇪🇸"
            // Add more languages here when you add them
        ]
    }
    
    // MARK: - Private Properties
    private var currentBundle: Bundle?
    
    // MARK: - Initialization
    private init() {
        // Load saved language from UserDefaults or default to device language
        let savedLanguage = UserDefaults.standard.string(forKey: "AppLanguage")
        let deviceLanguage = Locale.preferredLanguages.first?.prefix(2).lowercased() ?? "en"
        
        // Validate language is supported
        if let saved = savedLanguage, supportedLanguages.contains(saved) {
            self.currentLanguage = saved
        } else if supportedLanguages.contains(String(deviceLanguage)) {
            self.currentLanguage = String(deviceLanguage)
        } else {
            self.currentLanguage = "en" // Fallback to English
        }
        
        updateBundle()
    }
    
    // MARK: - Public Methods
    
    /// Set the app language and update the bundle
    /// - Parameter languageCode: Two-letter language code (e.g., "en", "es")
    func setLanguage(_ languageCode: String) {
        guard supportedLanguages.contains(languageCode) else {
            print("⚠️ [LOCALIZATION] Unsupported language code: \(languageCode)")
            return
        }
        
        currentLanguage = languageCode
        print("🌍 [LOCALIZATION] Language changed to: \(languageCode)")
    }
    
    /// Get localized string for a given key
    /// - Parameter key: The localization key
    /// - Returns: Localized string or the key itself if not found
    func localizedString(forKey key: String) -> String {
        guard let bundle = currentBundle else {
            print("⚠️ [LOCALIZATION] Bundle not available, using key: \(key)")
            return NSLocalizedString(key, comment: "")
        }
        
        return bundle.localizedString(forKey: key, value: nil, table: nil)
    }
    
    /// Get the bundle for a specific language
    /// - Parameter language: Language code
    /// - Returns: Bundle for the language or nil
    func bundle(for language: String) -> Bundle? {
        guard let path = Bundle.main.path(forResource: language, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            print("⚠️ [LOCALIZATION] Could not find bundle for language: \(language)")
            return Bundle.main
        }
        
        return bundle
    }
    
    // MARK: - Private Methods
    
    /// Update the current bundle based on current language
    private func updateBundle() {
        currentBundle = bundle(for: currentLanguage)
    }
}

// MARK: - String Extension
extension String {
    /// Returns a localized version of the string using LocalizationManager
    var localized: String {
        return LocalizationManager.shared.localizedString(forKey: self)
    }
}

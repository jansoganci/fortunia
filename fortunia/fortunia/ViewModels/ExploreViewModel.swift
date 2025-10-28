//
//  ExploreViewModel.swift
//  fortunia
//
//  Created by Cursor AI on January 26, 2025
//

import Foundation

/// ViewModel for Explore tab - manages daily horoscope and weekly forecast
@MainActor
class ExploreViewModel: ObservableObject {
    @Published var dailyHoroscope: DailyHoroscope?
    @Published var weeklyForecast: WeeklyForecast?
    @Published var zodiacSign: String = ""
    @Published var isLoading = false
    
    /// Load daily horoscope from cache or generate new one
    func loadDailyHoroscope() async {
        isLoading = true
        
        // Get user's zodiac sign
        zodiacSign = await getZodiacSign()
        
        // Check if we have today's horoscope cached
        if let cached = getCachedDailyHoroscope() {
            dailyHoroscope = cached
            DebugLogger.shared.info("Loaded cached daily horoscope for \(zodiacSign)")
            isLoading = false
            return
        }
        
        // Generate new horoscope
        do {
            let horoscope = try await generateDailyHoroscope(zodiacSign: zodiacSign)
            dailyHoroscope = horoscope
            cacheDailyHoroscope(horoscope)
            DebugLogger.shared.info("Generated new daily horoscope for \(zodiacSign)")
        } catch {
            DebugLogger.shared.warning("Failed to generate horoscope: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
    
    // MARK: - Private Methods
    
    /// Get zodiac sign from birth date (stored in profile)
    private func getZodiacSign() async -> String {
        // Try to get from Supabase user profile
        guard let client = SupabaseService.shared.supabase else {
            return getFallbackZodiacSign()
        }
        
        // TODO: Fetch birth_date from users table when user profile is available
        return getFallbackZodiacSign()
    }
    
    /// Fallback zodiac based on current date (defaults to current month)
    private func getFallbackZodiacSign() -> String {
        let month = Calendar.current.component(.month, from: Date())
        let day = Calendar.current.component(.day, from: Date())
        
        // Simplified zodiac calculation
        switch (month, day) {
        case (3, 21...31), (4, 1...19): return "♈ Aries"
        case (4, 20...30), (5, 1...20): return "♉ Taurus"
        case (5, 21...31), (6, 1...21): return "♊ Gemini"
        case (6, 22...30), (7, 1...22): return "♋ Cancer"
        case (7, 23...31), (8, 1...23): return "♌ Leo"
        case (8, 24...31), (9, 1...23): return "♍ Virgo"
        case (9, 24...30), (10, 1...22): return "♎ Libra"
        case (10, 23...31), (11, 1...22): return "♏ Scorpio"
        case (11, 23...30), (12, 1...22): return "♐ Sagittarius"
        case (12, 23...31), (1, 1...20): return "♑ Capricorn"
        case (1, 21...31), (2, 1...19): return "♒ Aquarius"
        case (2, 20...29), (3, 1...20): return "♓ Pisces"
        default: return "♓ Pisces"
        }
    }
    
    /// Generate daily horoscope using AI
    private func generateDailyHoroscope(zodiacSign: String) async throws -> DailyHoroscope {
        // For now, return a placeholder horoscope
        // TODO: Implement actual AI horoscope generation via edge function
        return DailyHoroscope(
            sign: zodiacSign,
            prediction: "Today brings unexpected opportunities in love. Your career path aligns with cosmic energies, bringing success in projects you've been working on. Maintain balance in health by listening to your body's needs.",
            ratings: Ratings(love: 4, career: 3, health: 4),
            date: DateFormatter().string(from: Date())
        )
    }
    
    /// Create prompt for horoscope generation
    private func createHoroscopePrompt(zodiacSign: String) -> String {
        return """
        Generate a daily horoscope for \(zodiacSign) for today, \(DateFormatter().string(from: Date())).
        
        Include:
        - A 2-3 sentence prediction for love, career, and health
        - Star ratings (1-5 stars) for each category
        
        Format as JSON:
        {
          "sign": "\(zodiacSign)",
          "prediction": "...",
          "ratings": {
            "love": 4,
            "career": 3,
            "health": 5
          }
        }
        """
    }
    
    /// Cache daily horoscope to UserDefaults
    private func cacheDailyHoroscope(_ horoscope: DailyHoroscope) {
        if let encoded = try? JSONEncoder().encode(horoscope) {
            UserDefaults.standard.set(encoded, forKey: "cached_daily_horoscope_\(DateFormatter().string(from: Date()))")
        }
    }
    
    /// Get cached daily horoscope
    private func getCachedDailyHoroscope() -> DailyHoroscope? {
        let today = DateFormatter().string(from: Date())
        guard let data = UserDefaults.standard.data(forKey: "cached_daily_horoscope_\(today)"),
              let horoscope = try? JSONDecoder().decode(DailyHoroscope.self, from: data) else {
            return nil
        }
        return horoscope
    }
}


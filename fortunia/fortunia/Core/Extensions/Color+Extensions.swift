//
//  Color+Extensions.swift
//  fortunia
//
//  Created by Can Soğancı on 24.10.2025.
//

import SwiftUI

// MARK: - Color System
extension Color {
    
    // MARK: - Primary Colors
    static let primary = Color("Primary")
    static let secondary = Color("Secondary")
    static let accent = Color("Accent")
    
    // MARK: - Text Colors
    static let textPrimary = Color("TextPrimary")
    static let textSecondary = Color("TextSecondary")
    static let textTertiary = Color("TextTertiary")
    
    // MARK: - Background Colors
    static let backgroundPrimary = Color("BackgroundPrimary")
    static let backgroundSecondary = Color("BackgroundSecondary")
    static let surface = Color("Surface")
    
    // MARK: - Status Colors
    static let success = Color("Success")
    static let warning = Color("Warning")
    static let error = Color("Error")
    static let info = Color("Info")
    
    // MARK: - Fortune Reading Colors
    static let mystical = Color("Mystical")
    static let spiritual = Color("Spiritual")
    static let cosmic = Color("Cosmic")
}

// MARK: - Color Definitions (Fallback)
extension Color {
    
    // MARK: - Primary Colors (Fallback)
    static let primaryFallback = Color(red: 0.545, green: 0.361, blue: 0.965) // #8B5CF6
    static let secondaryFallback = Color(red: 0.996, green: 0.596, blue: 0.588) // #FE9896
    static let accentFallback = Color(red: 0.996, green: 0.596, blue: 0.588) // #FE9896
    
    // MARK: - Text Colors (Fallback)
    static let textPrimaryFallback = Color(red: 0.133, green: 0.133, blue: 0.133) // #222222
    static let textSecondaryFallback = Color(red: 0.502, green: 0.502, blue: 0.502) // #808080
    static let textTertiaryFallback = Color(red: 0.741, green: 0.741, blue: 0.741) // #BDBDBD
    
    // MARK: - Background Colors (Fallback)
    static let backgroundPrimaryFallback = Color(red: 0.980, green: 0.980, blue: 0.980) // #FAFAFA
    static let backgroundSecondaryFallback = Color(red: 0.961, green: 0.961, blue: 0.961) // #F5F5F5
    static let surfaceFallback = Color.white
    
    // MARK: - Status Colors (Fallback)
    static let successFallback = Color(red: 0.200, green: 0.780, blue: 0.349) // #33C759
    static let warningFallback = Color(red: 1.000, green: 0.584, blue: 0.000) // #FF9500
    static let errorFallback = Color(red: 0.957, green: 0.263, blue: 0.212) // #F44336
    static let infoFallback = Color(red: 0.000, green: 0.478, blue: 1.000) // #007AFF
    
    // MARK: - Fortune Reading Colors (Fallback)
    static let mysticalFallback = Color(red: 0.545, green: 0.361, blue: 0.965) // #8B5CF6
    static let spiritualFallback = Color(red: 0.996, green: 0.596, blue: 0.588) // #FE9896
    static let cosmicFallback = Color(red: 0.000, green: 0.000, blue: 0.000) // #000000
}

// MARK: - Dark Mode Support
extension Color {
    
    // MARK: - Dynamic Colors
    static let dynamicPrimary = Color.primary
    static let dynamicSecondary = Color.secondary
    static let dynamicTextPrimary = Color.textPrimary
    static let dynamicTextSecondary = Color.textSecondary
    static let dynamicBackgroundPrimary = Color.backgroundPrimary
    static let dynamicBackgroundSecondary = Color.backgroundSecondary
    static let dynamicSurface = Color.surface
}

// MARK: - Color Utilities
extension Color {
    
    /// Creates a color from hex string
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    /// Returns hex string representation
    var hexString: String {
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        let rgb = Int(red * 255) << 16 | Int(green * 255) << 8 | Int(blue * 255) << 0
        return String(format: "#%06x", rgb)
    }
}

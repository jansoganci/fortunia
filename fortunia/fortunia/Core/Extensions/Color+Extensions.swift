//
//  Color+Extensions.swift
//  fortunia
//
//  Created by Can Soğancı on 24.10.2025.
//

import SwiftUI

// MARK: - Helper Function for Hex Conversion
private func colorFromHex(_ hex: String) -> Color {
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
    
    return Color(
        .sRGB,
        red: Double(r) / 255,
        green: Double(g) / 255,
        blue:  Double(b) / 255,
        opacity: Double(a) / 255
    )
}

// MARK: - Color System
extension Color {
    
    // MARK: - Primary Colors (Dynamic Light/Dark Mode)
    static let primary = Color(light: colorFromHex("#9B86BD"), dark: colorFromHex("#8B7AB8"))
    static let secondary = Color(light: colorFromHex("#D4A5A5"), dark: colorFromHex("#D4A5A5"))
    static let accent = Color(light: colorFromHex("#D4A5A5"), dark: colorFromHex("#E8B298"))
    
    // MARK: - Text Colors (Dynamic Light/Dark Mode)
    static let textPrimary = Color(light: colorFromHex("#1A1625"), dark: colorFromHex("#FFFFFF"))
    static let textSecondary = Color(light: colorFromHex("#6B5E7A"), dark: colorFromHex("#B8B0C8"))
    static let textTertiary = Color(light: colorFromHex("#B8B0C8"), dark: colorFromHex("#6B5E7A"))
    
    // MARK: - Background Colors (Dynamic Light/Dark Mode)
    static let backgroundPrimary = Color(light: colorFromHex("#F7F5F0"), dark: colorFromHex("#1A1625"))
    static let backgroundSecondary = Color(light: colorFromHex("#F5F5F5"), dark: colorFromHex("#2D2438"))
    static let surface = Color(light: colorFromHex("#FFFFFF"), dark: colorFromHex("#2D2438"))
    
    // MARK: - Status Colors (Dynamic Light/Dark Mode)
    static let success = Color(light: colorFromHex("#4CAF50"), dark: colorFromHex("#7BC9A6"))
    static let warning = Color(light: colorFromHex("#FFA726"), dark: colorFromHex("#F4C542"))
    static let error = Color(light: colorFromHex("#EF5350"), dark: colorFromHex("#E57373"))
    static let info = Color(light: colorFromHex("#42A5F5"), dark: colorFromHex("#64B5F6"))
    
    // MARK: - Fortune Reading Colors (Dynamic Light/Dark Mode)
    static let mystical = Color(light: colorFromHex("#9B86BD"), dark: colorFromHex("#8B7AB8"))
    static let spiritual = Color(light: colorFromHex("#D4A5A5"), dark: colorFromHex("#E8B298"))
    static let cosmic = Color(light: colorFromHex("#000000"), dark: colorFromHex("#1A1625"))
}

// MARK: - Dark Mode Support Helper
extension Color {
    /// Creates a dynamic color that adapts to light/dark mode
    init(light: Color, dark: Color) {
        self.init(UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor(dark)
            default:
                return UIColor(light)
            }
        })
    }
}

// MARK: - Color Utilities
extension Color {
    
    /// Creates a color from hex string
    init(hex: String) {
        self = colorFromHex(hex)
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

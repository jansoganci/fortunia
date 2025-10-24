//
//  Typography+Extensions.swift
//  fortunia
//
//  Created by Can Soğancı on 24.10.2025.
//

import SwiftUI

// MARK: - Typography System
struct AppTypography {
    
    // MARK: - Font Weights
    enum Weight {
        case light
        case regular
        case medium
        case semibold
        case bold
        case heavy
        
        var fontWeight: Font.Weight {
            switch self {
            case .light: return .light
            case .regular: return .regular
            case .medium: return .medium
            case .semibold: return .semibold
            case .bold: return .bold
            case .heavy: return .heavy
            }
        }
    }
    
    // MARK: - Font Sizes
    enum Size {
        case xs      // 12pt
        case sm      // 14pt
        case base    // 16pt
        case lg      // 18pt
        case xl      // 20pt
        case xxl     // 24pt
        case xxxl    // 32pt
        case huge    // 48pt
        
        var value: CGFloat {
            switch self {
            case .xs: return 12
            case .sm: return 14
            case .base: return 16
            case .lg: return 18
            case .xl: return 20
            case .xxl: return 24
            case .xxxl: return 32
            case .huge: return 48
            }
        }
    }
    
    // MARK: - Typography Styles
    static let largeTitle = Font.system(size: Size.huge.value, weight: .bold, design: .default)
    static let title1 = Font.system(size: Size.xxxl.value, weight: .bold, design: .default)
    static let title2 = Font.system(size: Size.xxl.value, weight: .semibold, design: .default)
    static let title3 = Font.system(size: Size.xl.value, weight: .semibold, design: .default)
    
    static let heading1 = Font.system(size: Size.xxl.value, weight: .bold, design: .default)
    static let heading2 = Font.system(size: Size.xl.value, weight: .semibold, design: .default)
    static let heading3 = Font.system(size: Size.lg.value, weight: .semibold, design: .default)
    static let heading4 = Font.system(size: Size.base.value, weight: .semibold, design: .default)
    
    static let bodyLarge = Font.system(size: Size.lg.value, weight: .regular, design: .default)
    static let bodyMedium = Font.system(size: Size.base.value, weight: .regular, design: .default)
    static let bodySmall = Font.system(size: Size.sm.value, weight: .regular, design: .default)
    
    static let caption = Font.system(size: Size.xs.value, weight: .regular, design: .default)
    static let captionBold = Font.system(size: Size.xs.value, weight: .semibold, design: .default)
    
    static let button = Font.system(size: Size.base.value, weight: .semibold, design: .default)
    static let buttonLarge = Font.system(size: Size.lg.value, weight: .semibold, design: .default)
    static let buttonSmall = Font.system(size: Size.sm.value, weight: .semibold, design: .default)
    
    // MARK: - Fortune Reading Specific
    static let fortuneTitle = Font.system(size: Size.xxxl.value, weight: .bold, design: .serif)
    static let fortuneText = Font.system(size: Size.lg.value, weight: .regular, design: .serif)
    static let fortuneCaption = Font.system(size: Size.sm.value, weight: .medium, design: .serif)
    
    static let mysticalTitle = Font.system(size: Size.huge.value, weight: .heavy, design: .serif)
    static let mysticalText = Font.system(size: Size.xl.value, weight: .medium, design: .serif)
    
    // MARK: - Custom Fonts (if you want to add custom fonts later)
    static func customFont(name: String, size: Size, weight: Weight) -> Font {
        return Font.custom(name, size: size.value)
            .weight(weight.fontWeight)
    }
}

// MARK: - Typography Modifiers
extension View {
    
    // MARK: - Title Modifiers
    func largeTitleStyle() -> some View {
        self.font(AppTypography.largeTitle)
    }
    
    func title1Style() -> some View {
        self.font(AppTypography.title1)
    }
    
    func title2Style() -> some View {
        self.font(AppTypography.title2)
    }
    
    func title3Style() -> some View {
        self.font(AppTypography.title3)
    }
    
    // MARK: - Heading Modifiers
    func heading1Style() -> some View {
        self.font(AppTypography.heading1)
    }
    
    func heading2Style() -> some View {
        self.font(AppTypography.heading2)
    }
    
    func heading3Style() -> some View {
        self.font(AppTypography.heading3)
    }
    
    func heading4Style() -> some View {
        self.font(AppTypography.heading4)
    }
    
    // MARK: - Body Modifiers
    func bodyLargeStyle() -> some View {
        self.font(AppTypography.bodyLarge)
    }
    
    func bodyMediumStyle() -> some View {
        self.font(AppTypography.bodyMedium)
    }
    
    func bodySmallStyle() -> some View {
        self.font(AppTypography.bodySmall)
    }
    
    // MARK: - Caption Modifiers
    func captionStyle() -> some View {
        self.font(AppTypography.caption)
    }
    
    func captionBoldStyle() -> some View {
        self.font(AppTypography.captionBold)
    }
    
    // MARK: - Button Modifiers
    func buttonStyle() -> some View {
        self.font(AppTypography.button)
    }
    
    func buttonLargeStyle() -> some View {
        self.font(AppTypography.buttonLarge)
    }
    
    func buttonSmallStyle() -> some View {
        self.font(AppTypography.buttonSmall)
    }
    
    // MARK: - Fortune Reading Modifiers
    func fortuneTitleStyle() -> some View {
        self.font(AppTypography.fortuneTitle)
    }
    
    func fortuneTextStyle() -> some View {
        self.font(AppTypography.fortuneText)
    }
    
    func fortuneCaptionStyle() -> some View {
        self.font(AppTypography.fortuneCaption)
    }
    
    func mysticalTitleStyle() -> some View {
        self.font(AppTypography.mysticalTitle)
    }
    
    func mysticalTextStyle() -> some View {
        self.font(AppTypography.mysticalText)
    }
}

// MARK: - Typography Utilities
extension AppTypography {
    
    /// Get font with custom size and weight
    static func font(size: Size, weight: Weight) -> Font {
        return Font.system(size: size.value, weight: weight.fontWeight, design: .default)
    }
    
    /// Get serif font with custom size and weight
    static func serifFont(size: Size, weight: Weight) -> Font {
        return Font.system(size: size.value, weight: weight.fontWeight, design: .serif)
    }
    
    /// Get monospaced font with custom size and weight
    static func monospacedFont(size: Size, weight: Weight) -> Font {
        return Font.system(size: size.value, weight: weight.fontWeight, design: .monospaced)
    }
}

//
//  Spacing+Extensions.swift
//  fortunia
//
//  Created by Can Soğancı on 24.10.2025.
//

import SwiftUI

// MARK: - Spacing System
struct Spacing {
    
    // MARK: - Spacing Values
    static let xs: CGFloat = 4      // 4pt
    static let sm: CGFloat = 8      // 8pt
    static let md: CGFloat = 16     // 16pt
    static let lg: CGFloat = 24     // 24pt
    static let xl: CGFloat = 32     // 32pt
    static let xxl: CGFloat = 48    // 48pt
    static let xxxl: CGFloat = 64   // 64pt
    static let huge: CGFloat = 96   // 96pt
    
    // MARK: - Semantic Spacing
    static let paddingXS = xs       // 4pt
    static let paddingSM = sm       // 8pt
    static let paddingMD = md       // 16pt
    static let paddingLG = lg       // 24pt
    static let paddingXL = xl       // 32pt
    
    static let marginXS = xs        // 4pt
    static let marginSM = sm        // 8pt
    static let marginMD = md        // 16pt
    static let marginLG = lg        // 24pt
    static let marginXL = xl        // 32pt
    
    static let gapXS = xs           // 4pt
    static let gapSM = sm           // 8pt
    static let gapMD = md           // 16pt
    static let gapLG = lg           // 24pt
    static let gapXL = xl           // 32pt
    
    // MARK: - Component Spacing
    static let cardPadding = md     // 16pt
    static let cardMargin = md      // 16pt
    static let cardGap = sm         // 8pt
    
    static let buttonPadding = md   // 16pt
    static let buttonMargin = sm    // 8pt
    static let buttonGap = sm       // 8pt
    
    static let inputPadding = md    // 16pt
    static let inputMargin = sm     // 8pt
    static let inputGap = sm        // 8pt
    
    static let sectionPadding = lg  // 24pt
    static let sectionMargin = md   // 16pt
    static let sectionGap = md      // 16pt
    
    // MARK: - Screen Spacing
    static let screenPadding = md   // 16pt
    static let screenMargin = md    // 16pt
    static let screenGap = md       // 16pt
    
    // MARK: - Fortune Reading Specific
    static let fortuneCardPadding = lg     // 24pt
    static let fortuneCardMargin = md      // 16pt
    static let fortuneCardGap = md         // 16pt
    
    static let fortuneTextPadding = md     // 16pt
    static let fortuneTextMargin = sm      // 8pt
    static let fortuneTextGap = sm         // 8pt
    
    static let mysticalPadding = xl        // 32pt
    static let mysticalMargin = lg         // 24pt
    static let mysticalGap = lg            // 24pt
}

// MARK: - Spacing Modifiers
extension View {
    
    // MARK: - Padding Modifiers
    func paddingXS() -> some View {
        self.padding(Spacing.paddingXS)
    }
    
    func paddingSM() -> some View {
        self.padding(Spacing.paddingSM)
    }
    
    func paddingMD() -> some View {
        self.padding(Spacing.paddingMD)
    }
    
    func paddingLG() -> some View {
        self.padding(Spacing.paddingLG)
    }
    
    func paddingXL() -> some View {
        self.padding(Spacing.paddingXL)
    }
    
    // MARK: - Horizontal Padding Modifiers
    func paddingHorizontalXS() -> some View {
        self.padding(.horizontal, Spacing.paddingXS)
    }
    
    func paddingHorizontalSM() -> some View {
        self.padding(.horizontal, Spacing.paddingSM)
    }
    
    func paddingHorizontalMD() -> some View {
        self.padding(.horizontal, Spacing.paddingMD)
    }
    
    func paddingHorizontalLG() -> some View {
        self.padding(.horizontal, Spacing.paddingLG)
    }
    
    func paddingHorizontalXL() -> some View {
        self.padding(.horizontal, Spacing.paddingXL)
    }
    
    // MARK: - Vertical Padding Modifiers
    func paddingVerticalXS() -> some View {
        self.padding(.vertical, Spacing.paddingXS)
    }
    
    func paddingVerticalSM() -> some View {
        self.padding(.vertical, Spacing.paddingSM)
    }
    
    func paddingVerticalMD() -> some View {
        self.padding(.vertical, Spacing.paddingMD)
    }
    
    func paddingVerticalLG() -> some View {
        self.padding(.vertical, Spacing.paddingLG)
    }
    
    func paddingVerticalXL() -> some View {
        self.padding(.vertical, Spacing.paddingXL)
    }
    
    // MARK: - Margin Modifiers (using padding)
    func marginXS() -> some View {
        self.padding(Spacing.marginXS)
    }
    
    func marginSM() -> some View {
        self.padding(Spacing.marginSM)
    }
    
    func marginMD() -> some View {
        self.padding(Spacing.marginMD)
    }
    
    func marginLG() -> some View {
        self.padding(Spacing.marginLG)
    }
    
    func marginXL() -> some View {
        self.padding(Spacing.marginXL)
    }
    
    // MARK: - Component Spacing Modifiers
    func cardPadding() -> some View {
        self.padding(Spacing.cardPadding)
    }
    
    func cardMargin() -> some View {
        self.padding(Spacing.cardMargin)
    }
    
    func buttonPadding() -> some View {
        self.padding(Spacing.buttonPadding)
    }
    
    func buttonMargin() -> some View {
        self.padding(Spacing.buttonMargin)
    }
    
    func inputPadding() -> some View {
        self.padding(Spacing.inputPadding)
    }
    
    func inputMargin() -> some View {
        self.padding(Spacing.inputMargin)
    }
    
    func sectionPadding() -> some View {
        self.padding(Spacing.sectionPadding)
    }
    
    func sectionMargin() -> some View {
        self.padding(Spacing.sectionMargin)
    }
    
    func screenPadding() -> some View {
        self.padding(Spacing.screenPadding)
    }
    
    func screenMargin() -> some View {
        self.padding(Spacing.screenMargin)
    }
    
    // MARK: - Fortune Reading Spacing Modifiers
    func fortuneCardPadding() -> some View {
        self.padding(Spacing.fortuneCardPadding)
    }
    
    func fortuneCardMargin() -> some View {
        self.padding(Spacing.fortuneCardMargin)
    }
    
    func fortuneTextPadding() -> some View {
        self.padding(Spacing.fortuneTextPadding)
    }
    
    func fortuneTextMargin() -> some View {
        self.padding(Spacing.fortuneTextMargin)
    }
    
    func mysticalPadding() -> some View {
        self.padding(Spacing.mysticalPadding)
    }
    
    func mysticalMargin() -> some View {
        self.padding(Spacing.mysticalMargin)
    }
}

// MARK: - Spacing Utilities
extension Spacing {
    
    /// Get spacing value by name
    static func value(for name: String) -> CGFloat {
        switch name.lowercased() {
        case "xs": return xs
        case "sm": return sm
        case "md": return md
        case "lg": return lg
        case "xl": return xl
        case "xxl": return xxl
        case "xxxl": return xxxl
        case "huge": return huge
        default: return md
        }
    }
    
    /// Get spacing value by multiplier
    static func value(multiplier: CGFloat) -> CGFloat {
        return md * multiplier
    }
    
    /// Get spacing value for screen size
    static func value(for screenSize: CGSize) -> CGFloat {
        if screenSize.width < 375 {
            return sm  // iPhone SE
        } else if screenSize.width < 414 {
            return md  // iPhone standard
        } else {
            return lg  // iPhone Plus/Max
        }
    }
}

// MARK: - Spacing Constants
extension Spacing {
    
    // MARK: - Standard Spacing
    static let standard = md        // 16pt
    static let compact = sm         // 8pt
    static let comfortable = lg     // 24pt
    static let spacious = xl        // 32pt
    
    // MARK: - Touch Target Sizes
    static let touchTargetMin: CGFloat = 44  // Apple HIG minimum
    static let touchTargetComfortable: CGFloat = 48
    static let touchTargetLarge: CGFloat = 56
    
    // MARK: - Border Radius
    static let cornerRadiusXS: CGFloat = 4
    static let cornerRadiusSM: CGFloat = 8
    static let cornerRadiusMD: CGFloat = 12
    static let cornerRadiusLG: CGFloat = 16
    static let cornerRadiusXL: CGFloat = 24
    static let cornerRadiusRound: CGFloat = 999
}

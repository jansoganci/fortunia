//
//  CornerRadius+Extensions.swift
//  fortunia
//
//  Created by Can Soğancı on 24.10.2025.
//

import SwiftUI

// MARK: - Corner Radius System
struct CornerRadius {
    
    // MARK: - Corner Radius Values
    static let xs: CGFloat = 4      // 4pt
    static let sm: CGFloat = 8      // 8pt
    static let md: CGFloat = 12     // 12pt
    static let lg: CGFloat = 16     // 16pt
    static let xl: CGFloat = 24     // 24pt
    static let xxl: CGFloat = 32    // 32pt
    static let round: CGFloat = 999 // Fully rounded
    
    // MARK: - Component Corner Radius
    static let button = md          // 12pt
    static let card = lg            // 16pt
    static let input = md           // 12pt
    static let modal = xl           // 24pt
    static let badge = round        // Fully rounded
    static let avatar = round       // Fully rounded
    
    // MARK: - Fortune Reading Specific
    static let fortuneCard = xl     // 24pt
    static let mysticalCard = xxl   // 32pt
    static let shareCard = lg       // 16pt
}

// MARK: - Corner Radius Modifiers
extension View {
    
    // MARK: - Basic Corner Radius Modifiers
    func cornerRadiusXS() -> some View {
        self.cornerRadius(CornerRadius.xs)
    }
    
    func cornerRadiusSM() -> some View {
        self.cornerRadius(CornerRadius.sm)
    }
    
    func cornerRadiusMD() -> some View {
        self.cornerRadius(CornerRadius.md)
    }
    
    func cornerRadiusLG() -> some View {
        self.cornerRadius(CornerRadius.lg)
    }
    
    func cornerRadiusXL() -> some View {
        self.cornerRadius(CornerRadius.xl)
    }
    
    func cornerRadiusXXL() -> some View {
        self.cornerRadius(CornerRadius.xxl)
    }
    
    func cornerRadiusRound() -> some View {
        self.cornerRadius(CornerRadius.round)
    }
    
    // MARK: - Component Corner Radius Modifiers
    func buttonCornerRadius() -> some View {
        self.cornerRadius(CornerRadius.button)
    }
    
    func cardCornerRadius() -> some View {
        self.cornerRadius(CornerRadius.card)
    }
    
    func inputCornerRadius() -> some View {
        self.cornerRadius(CornerRadius.input)
    }
    
    func modalCornerRadius() -> some View {
        self.cornerRadius(CornerRadius.modal)
    }
    
    func badgeCornerRadius() -> some View {
        self.cornerRadius(CornerRadius.badge)
    }
    
    func avatarCornerRadius() -> some View {
        self.cornerRadius(CornerRadius.avatar)
    }
    
    // MARK: - Fortune Reading Corner Radius Modifiers
    func fortuneCardCornerRadius() -> some View {
        self.cornerRadius(CornerRadius.fortuneCard)
    }
    
    func mysticalCardCornerRadius() -> some View {
        self.cornerRadius(CornerRadius.mysticalCard)
    }
    
    func shareCardCornerRadius() -> some View {
        self.cornerRadius(CornerRadius.shareCard)
    }
    
    // MARK: - Custom Corner Radius Modifiers
    func cornerRadius(_ radius: CGFloat) -> some View {
        self.clipShape(RoundedRectangle(cornerRadius: radius))
    }
    
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        self.clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

// MARK: - Custom Rounded Corner Shape
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Corner Radius Utilities
extension CornerRadius {
    
    /// Get corner radius value by name
    static func value(for name: String) -> CGFloat {
        switch name.lowercased() {
        case "xs": return xs
        case "sm": return sm
        case "md": return md
        case "lg": return lg
        case "xl": return xl
        case "xxl": return xxl
        case "round": return round
        default: return md
        }
    }
    
    /// Get corner radius value by multiplier
    static func value(multiplier: CGFloat) -> CGFloat {
        return md * multiplier
    }
    
    /// Get corner radius value for component type
    static func value(for component: ComponentType) -> CGFloat {
        switch component {
        case .button: return button
        case .card: return card
        case .input: return input
        case .modal: return modal
        case .badge: return badge
        case .avatar: return avatar
        case .fortuneCard: return fortuneCard
        case .mysticalCard: return mysticalCard
        case .shareCard: return shareCard
        }
    }
}

// MARK: - Component Types
enum ComponentType {
    case button
    case card
    case input
    case modal
    case badge
    case avatar
    case fortuneCard
    case mysticalCard
    case shareCard
}

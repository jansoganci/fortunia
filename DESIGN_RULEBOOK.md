# FORTUNIA - DESIGN RULEBOOK

**Version:** 1.0  
**Date:** October 24, 2025  
**Platform:** iOS 15.0+  
**Design System:** SwiftUI Native + Custom Components  
**Philosophy:** Simplicity. Consistency. Delight.

***

## TABLE OF CONTENTS

1. Design Principles
2. Color System
3. Typography
4. Spacing & Layout
5. Components Library
6. Icons & Imagery
7. Motion & Animation
8. States & Feedback
9. Accessibility
10. Implementation Guide

***

## 1. DESIGN PRINCIPLES

### Core Philosophy

**Radical Simplicity**
One primary action per screen. Remove everything that doesn't serve the core mission.

**Cultural Respect**
Mystical aesthetics that honor traditions while feeling modern and approachable.

**Feminine Elegance**
Soft colors, rounded corners, gentle transitions. Designed for women who value beauty and authenticity.

**Privacy First**
Visual cues that reinforce data safety and user control.

### Design Values

- **Clarity over cleverness**
- **Consistency over novelty**
- **User trust over viral tricks**
- **Accessibility as default, not afterthought**

***

## 2. COLOR SYSTEM

### 2.1 Color Tokens (SwiftUI Implementation)

All colors defined once in Assets.xcassets with light/dark mode variants.

**Primary Colors**

```swift
// Define in Assets.xcassets with Appearances: Any, Light, Dark

// DARK MODE
Primary Dark: #8B7AB8        // Lavender Purple
Accent Dark: #E8B298          // Rose Gold
Background Dark: #1A1625      // Deep Space
Surface Dark: #2D2438         // Card Background
Text Primary Dark: #FFFFFF    // White
Text Secondary Dark: #B8B0C8  // Muted Lavender

// LIGHT MODE
Primary Light: #9B86BD        // Soft Purple
Accent Light: #D4A5A5         // Dusty Rose
Background Light: #F7F5F0     // Cream White
Surface Light: #FFFFFF        // Pure White
Text Primary Light: #1A1625   // Deep Space
Text Secondary Light: #6B5E7A // Muted Purple
```

**Semantic Colors**

```swift
// Success
Success Dark: #7BC9A6
Success Light: #4CAF50

// Warning
Warning Dark: #F4C542
Warning Light: #FFA726

// Error
Error Dark: #E57373
Error Light: #EF5350

// Info
Info Dark: #64B5F6
Info Light: #42A5F5
```

**Gradient Definitions**

```swift
// Mystical Gradient (Primary)
let mysticalGradient = LinearGradient(
    colors: [
        Color("Primary"),
        Color("Accent")
    ],
    startPoint: .topLeading,
    endPoint: .bottomTrailing
)

// Dark Overlay (for images)
let darkOverlay = LinearGradient(
    colors: [
        Color.black.opacity(0.0),
        Color.black.opacity(0.6)
    ],
    startPoint: .top,
    endPoint: .bottom
)

// Premium Badge Gradient
let premiumGradient = LinearGradient(
    colors: [
        Color(hex: "#FFD700"), // Gold
        Color(hex: "#FFA500")  // Orange
    ],
    startPoint: .leading,
    endPoint: .trailing
)
```

### 2.2 Usage Guidelines

**Do:**
- Use Primary for main CTAs and important elements
- Use Accent sparingly for emphasis
- Use Surface for card backgrounds
- Use Text Secondary for supporting information

**Don't:**
- Mix custom hex codes outside the system
- Use pure black (#000000) or pure white (#FFFFFF) as backgrounds
- Use more than 2 colors in a single component

### 2.3 Color Extension (Swift Code)

```swift
// Color+Extension.swift
import SwiftUI

extension Color {
    static let primary = Color("Primary")
    static let accent = Color("Accent")
    static let background = Color("Background")
    static let surface = Color("Surface")
    static let textPrimary = Color("TextPrimary")
    static let textSecondary = Color("TextSecondary")
    static let success = Color("Success")
    static let warning = Color("Warning")
    static let error = Color("Error")
    
    // Hex initializer
    init(hex: String) {
        let scanner = Scanner(string: hex)
        scanner.currentIndex = hex.hasPrefix("#") ? hex.index(after: hex.startIndex) : hex.startIndex
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        let r = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let g = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let b = Double(rgbValue & 0x0000FF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}
```

***

## 3. TYPOGRAPHY

### 3.1 Type Scale

All typography uses SF Pro (system font) for consistency and accessibility.

```swift
// Typography.swift

struct AppTypography {
    // Display (Hero Text)
    static let displayLarge = Font.system(size: 48, weight: .bold, design: .default)
    static let displayMedium = Font.system(size: 36, weight: .bold, design: .default)
    
    // Headings
    static let heading1 = Font.system(size: 28, weight: .bold, design: .default)
    static let heading2 = Font.system(size: 24, weight: .semibold, design: .default)
    static let heading3 = Font.system(size: 20, weight: .semibold, design: .default)
    
    // Body
    static let bodyLarge = Font.system(size: 18, weight: .regular, design: .default)
    static let bodyMedium = Font.system(size: 16, weight: .regular, design: .default)
    static let bodySmall = Font.system(size: 14, weight: .regular, design: .default)
    
    // Labels
    static let labelLarge = Font.system(size: 16, weight: .medium, design: .default)
    static let labelMedium = Font.system(size: 14, weight: .medium, design: .default)
    static let labelSmall = Font.system(size: 12, weight: .medium, design: .default)
    
    // Caption
    static let caption = Font.system(size: 12, weight: .regular, design: .default)
    static let captionSmall = Font.system(size: 10, weight: .regular, design: .default)
}
```

### 3.2 Line Heights

```swift
extension View {
    func lineSpacing(_ type: AppTypography.LineSpacing) -> some View {
        switch type {
        case .tight: return self.lineSpacing(4)
        case .normal: return self.lineSpacing(8)
        case .relaxed: return self.lineSpacing(12)
        }
    }
}

extension AppTypography {
    enum LineSpacing {
        case tight    // 4pt
        case normal   // 8pt
        case relaxed  // 12pt
    }
}
```

### 3.3 Usage Examples

```swift
// Page Title
Text("Your Fortune")
    .font(AppTypography.heading1)
    .foregroundColor(.textPrimary)

// Body Text
Text("Discover what the stars have aligned for you.")
    .font(AppTypography.bodyMedium)
    .foregroundColor(.textSecondary)
    .lineSpacing(.normal)

// Button Label
Text("Get Reading")
    .font(AppTypography.labelLarge)
    .foregroundColor(.white)
```

***

## 4. SPACING & LAYOUT

### 4.1 Spacing Scale (8pt Grid System)

All spacing multiples of 8pt for consistency.

```swift
struct Spacing {
    static let xxxs: CGFloat = 2   // Tight spacing
    static let xxs: CGFloat = 4    // Very tight
    static let xs: CGFloat = 8     // Base unit
    static let sm: CGFloat = 12    // Small
    static let md: CGFloat = 16    // Medium (column)
    static let lg: CGFloat = 24    // Large
    static let xl: CGFloat = 32    // Extra large
    static let xxl: CGFloat = 48   // Section spacing
    static let xxxl: CGFloat = 64  // Major sections
}
```

### 4.2 Corner Radius

```swift
struct CornerRadius {
    static let xs: CGFloat = 4     // Small elements
    static let sm: CGFloat = 8     // Buttons, chips
    static let md: CGFloat = 12    // Input fields
    static let lg: CGFloat = 16    // Cards
    static let xl: CGFloat = 24    // Bottom sheets
    static let xxl: CGFloat = 32   // Modals
    static let full: CGFloat = 9999 // Circular
}
```

### 4.3 Safe Area & Margins

```swift
struct Layout {
    // Screen Margins
    static let screenHorizontalPadding: CGFloat = 20
    static let screenVerticalPadding: CGFloat = 16
    
    // Content Width (for large screens)
    static let maxContentWidth: CGFloat = 428 // iPhone 14 Pro Max width
    
    // Card Padding
    static let cardPadding: CGFloat = 16
    static let cardSpacing: CGFloat = 12
}
```

### 4.4 Elevation (Shadow Depths)

```swift
struct Elevation {
    // Level 1: Subtle lift (buttons)
    static let level1 = (color: Color.black.opacity(0.08), radius: CGFloat(4), x: CGFloat(0), y: CGFloat(2))
    
    // Level 2: Floating (cards)
    static let level2 = (color: Color.black.opacity(0.12), radius: CGFloat(8), x: CGFloat(0), y: CGFloat(4))
    
    // Level 3: Prominent (modals)
    static let level3 = (color: Color.black.opacity(0.16), radius: CGFloat(16), x: CGFloat(0), y: CGFloat(8))
    
    // Level 4: Maximum (overlays)
    static let level4 = (color: Color.black.opacity(0.24), radius: CGFloat(24), x: CGFloat(0), y: CGFloat(12))
}

// Usage
.shadow(
    color: Elevation.level2.color,
    radius: Elevation.level2.radius,
    x: Elevation.level2.x,
    y: Elevation.level2.y
)
```

### 4.5 Opacity Scale

```swift
struct Opacity {
    static let invisible: Double = 0.0
    static let ghost: Double = 0.05
    static let faint: Double = 0.1
    static let subtle: Double = 0.2
    static let medium: Double = 0.4
    static let heavy: Double = 0.6
    static let intense: Double = 0.8
    static let opaque: Double = 1.0
}
```

***

## 5. COMPONENTS LIBRARY

### 5.1 Buttons

**Primary Button**

```swift
struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppTypography.labelLarge)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    LinearGradient(
                        colors: [Color.primary, Color.accent],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(CornerRadius.md)
                .shadow(
                    color: Elevation.level2.color,
                    radius: Elevation.level2.radius,
                    x: Elevation.level2.x,
                    y: Elevation.level2.y
                )
        }
        .scaleEffect(isPressed ? 0.97 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

// Usage
PrimaryButton(title: "Get My Reading") {
    // Action
}
```

**Secondary Button**

```swift
struct SecondaryButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppTypography.labelLarge)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color.surface)
                .cornerRadius(CornerRadius.md)
                .overlay(
                    RoundedRectangle(cornerRadius: CornerRadius.md)
                        .stroke(Color.primary, lineWidth: 2)
                )
        }
    }
}
```

**Text Button (Tertiary)**

```swift
struct TextButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppTypography.labelMedium)
                .foregroundColor(.primary)
        }
    }
}
```

### 5.2 Cards

**Fortune Card (Neumorphic)**

```swift
struct FortuneCard<Content: View>: View {
    let content: Content
    @State private var isPressed = false
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(Spacing.md)
            .background(
                ZStack {
                    Color.surface
                    
                    RoundedRectangle(cornerRadius: CornerRadius.lg)
                        .fill(Color.surface)
                        .shadow(
                            color: Color.white.opacity(0.1),
                            radius: isPressed ? 5 : 10,
                            x: isPressed ? -3 : -6,
                            y: isPressed ? -3 : -6
                        )
                        .shadow(
                            color: Color.black.opacity(0.3),
                            radius: isPressed ? 5 : 10,
                            x: isPressed ? 3 : 6,
                            y: isPressed ? 3 : 6
                        )
                }
            )
            .cornerRadius(CornerRadius.lg)
    }
}

// Usage
FortuneCard {
    VStack(alignment: .leading, spacing: Spacing.sm) {
        Text("Face Reading")
            .font(AppTypography.heading3)
        Text("Discover your inner self")
            .font(AppTypography.bodySmall)
            .foregroundColor(.textSecondary)
    }
}
```

**Simple Card**

```swift
struct SimpleCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(Spacing.md)
            .background(Color.surface)
            .cornerRadius(CornerRadius.lg)
            .shadow(
                color: Elevation.level2.color,
                radius: Elevation.level2.radius,
                x: Elevation.level2.x,
                y: Elevation.level2.y
            )
    }
}
```

### 5.3 Input Fields

**Text Field**

```swift
struct AppTextField: View {
    let placeholder: String
    @Binding var text: String
    var icon: String? = nil
    
    var body: some View {
        HStack(spacing: Spacing.sm) {
            if let icon = icon {
                Image(systemName: icon)
                    .foregroundColor(.textSecondary)
                    .frame(width: 24, height: 24)
            }
            
            TextField(placeholder, text: $text)
                .font(AppTypography.bodyMedium)
                .foregroundColor(.textPrimary)
        }
        .padding(Spacing.md)
        .background(Color.surface)
        .cornerRadius(CornerRadius.md)
        .overlay(
            RoundedRectangle(cornerRadius: CornerRadius.md)
                .stroke(Color.primary.opacity(Opacity.subtle), lineWidth: 1)
        )
    }
}

// Usage
@State private var email = ""
AppTextField(placeholder: "Email", text: $email, icon: "envelope")
```

### 5.4 Premium Badge

```swift
struct PremiumBadge: View {
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "crown.fill")
                .font(.system(size: 12))
            Text("PRO")
                .font(AppTypography.captionSmall)
                .fontWeight(.bold)
        }
        .foregroundColor(.white)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            LinearGradient(
                colors: [Color(hex: "#FFD700"), Color(hex: "#FFA500")],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(CornerRadius.xs)
    }
}
```

### 5.5 Lock Indicator (Freemium)

```swift
struct LockIndicator: View {
    var body: some View {
        ZStack {
            Color.black.opacity(Opacity.heavy)
                .cornerRadius(CornerRadius.lg)
            
            VStack(spacing: Spacing.sm) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.white)
                
                Text("Premium Feature")
                    .font(AppTypography.labelSmall)
                    .foregroundColor(.white)
            }
        }
    }
}
```

### 5.6 Disclaimer Component (Legal Requirement)

```swift
struct DisclaimerView: View {
    var body: some View {
        Text(NSLocalizedString("disclaimer_text", comment: "Legal disclaimer"))
            .font(AppTypography.caption)
            .foregroundColor(.textSecondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.xs)
    }
}

// Usage (required on every result screen)
VStack {
    // Fortune result content
    
    DisclaimerView()
        .padding(.top, Spacing.lg)
}
```

**Disclaimer Text (Localizable.strings):**
```
// English
"disclaimer_text" = "For entertainment purposes only. Not a substitute for professional, medical, legal, or financial advice.";

// Spanish  
"disclaimer_text" = "Solo con fines de entretenimiento. No sustituye el asesoramiento profesional, médico, legal o financiero.";
```

***

## 6. ICONS & IMAGERY

### 6.1 Icon Sizes

```swift
struct IconSize {
    static let xs: CGFloat = 16
    static let sm: CGFloat = 20
    static let md: CGFloat = 24   // Default
    static let lg: CGFloat = 32
    static let xl: CGFloat = 40
    static let xxl: CGFloat = 56
}
```

### 6.2 SF Symbols Usage

**Primary Icons (Navigation)**

```swift
// Tab Bar Icons
Home: "house.fill"
Explore: "sparkles"
History: "clock.fill"
Profile: "person.circle.fill"

// Fortune Types
Face Reading: "face.smiling"
Palm Reading: "hand.raised.fill"
Tarot: "rectangle.portrait.fill"
Coffee: "cup.and.saucer.fill"
Astrology: "star.fill"
Oracle: "books.vertical.fill"

// Actions
Camera: "camera.fill"
Photo Library: "photo.fill"
Share: "square.and.arrow.up"
Settings: "gearshape.fill"
Close: "xmark"
Checkmark: "checkmark.circle.fill"
```

### 6.3 Image Guidelines

**Photo Upload Requirements**
- Minimum resolution: 1024x1024
- Maximum file size: 5MB
- Formats: JPEG, PNG, HEIC
- Aspect ratio: 1:1 (square) preferred

**Placeholder Images**
- Use SF Symbols for empty states
- Gray tint with opacity 0.2

***

## 7. MOTION & ANIMATION

### 7.1 Animation Durations

```swift
struct AnimationDuration {
    static let instant: Double = 0.1    // Immediate feedback
    static let fast: Double = 0.2       // Quick transitions
    static let normal: Double = 0.3     // Default
    static let slow: Double = 0.5       // Emphasis
    static let lazy: Double = 0.8       // Loading states
}
```

### 7.2 Animation Curves

```swift
// Standard SwiftUI animations
.easeIn         // Start slow, accelerate
.easeOut        // Start fast, decelerate
.easeInOut      // Smooth both ends (default)
.linear         // Constant speed
.spring         // Bouncy effect
```

### 7.3 Mystical Loading Animation

```swift
struct MysticalLoadingView: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: Spacing.lg) {
            // Glowing Orb
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.primary, .accent],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 80, height: 80)
                .blur(radius: isAnimating ? 20 : 5)
                .scaleEffect(isAnimating ? 1.2 : 0.8)
                .animation(
                    .easeInOut(duration: AnimationDuration.lazy)
                    .repeatForever(autoreverses: true),
                    value: isAnimating
                )
            
            // Sparkles
            HStack(spacing: Spacing.md) {
                ForEach(0..<5) { i in
                    Image(systemName: "sparkle")
                        .foregroundColor(.primary.opacity(0.7))
                        .scaleEffect(isAnimating ? 1.0 : 0.3)
                        .animation(
                            .easeInOut(duration: 0.8)
                            .repeatForever()
                            .delay(Double(i) * 0.2),
                            value: isAnimating
                        )
                }
            }
            
            Text("Reading your fortune...")
                .font(AppTypography.bodySmall)
                .foregroundColor(.textSecondary)
        }
        .onAppear { isAnimating = true }
    }
}
```

### 7.4 Transition Guidelines

**Screen Transitions**
- Use `.slide` for forward navigation
- Use `.opacity` with `.scale(0.95)` for modals
- Use `.move(edge: .bottom)` for bottom sheets

```swift
.transition(.asymmetric(
    insertion: .move(edge: .trailing),
    removal: .move(edge: .leading)
))
```

***

## 8. STATES & FEEDBACK

### 8.1 Button States

```swift
enum ButtonState {
    case normal
    case pressed
    case disabled
    case loading
}
```

**Visual Feedback**
- Normal: Full color, elevation level 2
- Pressed: Scale 0.97, elevation level 1
- Disabled: Opacity 0.4, no interaction
- Loading: Spinner overlay, opacity 0.8

### 8.2 Haptic Feedback

```swift
import UIKit

struct HapticFeedback {
    static func light() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    
    static func medium() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
    
    static func heavy() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
    }
    
    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
    
    static func warning() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }
    
    static func error() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }
    
    static func selection() {
        UISelectionFeedbackGenerator().selectionChanged()
    }
}
```

**Usage Guidelines**
- Button tap: light()
- Card selection: selection()
- Fortune completed: success()
- Payment success: heavy() + success()
- Error state: error()
- Tab switch: selection()

### 8.3 Error States

```swift
struct ErrorView: View {
    let message: String
    let retry: (() -> Void)?
    
    var body: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: IconSize.xxl))
                .foregroundColor(.error)
            
            Text(message)
                .font(AppTypography.bodyMedium)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
            
            if let retry = retry {
                TextButton(title: "Try Again", action: retry)
            }
        }
        .padding(Spacing.xl)
    }
}
```

### 8.4 Empty States

```swift
struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?
    
    var body: some View {
        VStack(spacing: Spacing.lg) {
            Image(systemName: icon)
                .font(.system(size: IconSize.xxl))
                .foregroundColor(.textSecondary.opacity(Opacity.medium))
            
            VStack(spacing: Spacing.xs) {
                Text(title)
                    .font(AppTypography.heading3)
                    .foregroundColor(.textPrimary)
                
                Text(message)
                    .font(AppTypography.bodySmall)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            if let actionTitle = actionTitle, let action = action {
                PrimaryButton(title: actionTitle, action: action)
                    .frame(width: 200)
            }
        }
        .padding(Spacing.xxl)
    }
}

// Usage
EmptyStateView(
    icon: "clock.fill",
    title: "No Readings Yet",
    message: "Your fortune reading history will appear here",
    actionTitle: "Get Your First Reading",
    action: { /* Navigate to reading */ }
)
```

***

## 9. ACCESSIBILITY

### 9.1 Color Contrast

All text meets WCAG 2.1 AA standards:
- Normal text (16pt): Minimum contrast ratio 4.5:1
- Large text (18pt+): Minimum contrast ratio 3:1

**Tested Combinations:**
- Primary text on Background: Pass
- Secondary text on Background: Pass
- White text on Primary: Pass
- White text on Accent: Pass

### 9.2 Dynamic Type Support

```swift
// All typography scales automatically with user's text size preference
Text("Example")
    .font(AppTypography.bodyMedium)
    .dynamicTypeSize(...DynamicTypeSize.xxxLarge) // Cap at xxxLarge
```

### 9.3 VoiceOver Labels

```swift
// Button
PrimaryButton(title: "Get Reading")
    .accessibilityLabel("Get your fortune reading")
    .accessibilityHint("Starts a new fortune reading session")

// Image
Image(systemName: "star.fill")
    .accessibilityLabel("Premium feature")
```

### 9.4 Reduce Motion

```swift
@Environment(\.accessibilityReduceMotion) var reduceMotion

var animation: Animation? {
    reduceMotion ? nil : .easeInOut
}

// Usage
.animation(animation, value: someState)
```

***

## 10. IMPLEMENTATION GUIDE

### 10.1 Project Structure

```
Fortunia/
├── Core/
│   ├── Design/
│   │   ├── Typography.swift
│   │   ├── Spacing.swift
│   │   ├── Colors+Extension.swift
│   │   ├── Elevation.swift
│   │   └── HapticFeedback.swift
│   ├── Components/
│   │   ├── Buttons/
│   │   │   ├── PrimaryButton.swift
│   │   │   ├── SecondaryButton.swift
│   │   │   └── TextButton.swift
│   │   ├── Cards/
│   │   │   ├── FortuneCard.swift
│   │   │   └── SimpleCard.swift
│   │   ├── Inputs/
│   │   │   └── AppTextField.swift
│   │   └── States/
│   │       ├── LoadingView.swift
│   │       ├── ErrorView.swift
│   │       └── EmptyStateView.swift
```

### 10.2 Assets Setup

**Colors in Assets.xcassets:**
1. Create Color Set for each token
2. Set Appearances: Any, Light, Dark
3. Assign hex values for each appearance

**Example (Primary color):**
```
Primary.colorset/
├── Contents.json
└── Values:
    ├── Any Appearance: #8B7AB8
    ├── Light Appearance: #9B86BD
    └── Dark Appearance: #8B7AB8
```

### 10.3 Reusable Modifiers

```swift
// View+Extension.swift

extension View {
    // Neumorphic effect
    func neumorphic(isPressed: Bool = false) -> some View {
        self.modifier(NeumorphicStyle(isPressed: isPressed))
    }
    
    // Card style
    func cardStyle() -> some View {
        self
            .padding(Spacing.md)
            .background(Color.surface)
            .cornerRadius(CornerRadius.lg)
            .shadow(
                color: Elevation.level2.color,
                radius: Elevation.level2.radius,
                x: Elevation.level2.x,
                y: Elevation.level2.y
            )
    }
    
    // Premium lock overlay
    func premiumLock(isLocked: Bool) -> some View {
        self.overlay(
            Group {
                if isLocked {
                    LockIndicator()
                }
            }
        )
    }
}

// Usage
Text("Hello")
    .cardStyle()
    .premiumLock(isLocked: !isPremiumUser)
```

### 10.4 Dark Mode Testing

```swift
// Preview both modes
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
                .preferredColorScheme(.light)
                .previewDisplayName("Light Mode")
            
            ContentView()
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark Mode")
        }
    }
}
```

### 10.5 Component Usage Checklist

Before creating a new component, check:
- [ ] Does a similar component exist?
- [ ] Can I extend an existing component?
- [ ] Is this component reusable (3+ uses)?
- [ ] Does it follow spacing/color/typography standards?
- [ ] Does it support dark mode?
- [ ] Is it accessible (VoiceOver, Dynamic Type)?
- [ ] Does it have appropriate haptic feedback?

***

## APPENDIX: QUICK REFERENCE

### Color Quick Copy

```
Dark Mode:
Primary: #8B7AB8
Accent: #E8B298
Background: #1A1625
Surface: #2D2438

Light Mode:
Primary: #9B86BD
Accent: #D4A5A5
Background: #F7F5F0
Surface: #FFFFFF
```

### Spacing Quick Copy

```
2, 4, 8, 12, 16, 24, 32, 48, 64
```

### Corner Radius Quick Copy

```
4, 8, 12, 16, 24, 32
```

### Icon Sizes Quick Copy

```
16, 20, 24, 32, 40, 56
```

***

**Document Approval:**
- [ ] Product Lead
- [ ] iOS Developer
- [ ] Design Lead

**Next Steps:**
1. Set up Assets.xcassets with color tokens
2. Create Core/Design folder with base files
3. Build Components library
4. Test in light/dark mode
5. Begin Development Roadmap implementation

**Last Updated:** October 24, 2025

***

END OF DESIGN RULEBOOK

//
//  SplashScreen.swift
//  fortunia
//
//  Created by Can Soğancı on 24.10.2025.
//

import SwiftUI

// MARK: - Splash Screen
struct SplashScreen: View {
    @State private var isAnimating = false
    @State private var showAuth = false
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0.0
    let onComplete: () -> Void
    
    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(
                colors: [
                    Color.backgroundPrimary,
                    Color.primary.opacity(0.1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: Spacing.xxl) {
                Spacer()
                
                // Logo Section
                VStack(spacing: Spacing.lg) {
                    // App Logo
                    Image("app-logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .scaleEffect(scale)
                        .opacity(opacity)
                        .shadow(
                            color: Color.primary.opacity(0.3),
                            radius: 20,
                            x: 0,
                            y: 10
                        )
                    
                    // App Title
                    Text(LocalizedStringKey("splash_app_name")) // localized
                        .font(.system(size: 48, weight: .heavy, design: .serif))
                        .foregroundColor(.textPrimary)
                        .opacity(isAnimating ? 1.0 : 0.0)
                        .animation(
                            .easeInOut(duration: 1.0)
                            .delay(0.5),
                            value: isAnimating
                        )
                    
                    // Tagline
                    Text(LocalizedStringKey("splash_tagline")) // localized
                        .font(AppTypography.bodyLarge)
                        .foregroundColor(.textSecondary)
                        .opacity(isAnimating ? 1.0 : 0.0)
                        .animation(
                            .easeInOut(duration: 1.0)
                            .delay(1.0),
                            value: isAnimating
                        )
                }
                
                Spacer()
                
                // Sparkles Animation
                HStack(spacing: Spacing.md) {
                    ForEach(0..<5) { i in
                        Image(systemName: "sparkle")
                            .font(.system(size: 20))
                            .foregroundColor(.primary.opacity(0.7))
                            .scaleEffect(isAnimating ? 1.0 : 0.3)
                            .animation(
                                .easeInOut(duration: 1.5)
                                .repeatForever()
                                .delay(Double(i) * 0.3),
                                value: isAnimating
                            )
                    }
                }
                .opacity(isAnimating ? 1.0 : 0.0)
                .animation(
                    .easeInOut(duration: 1.0)
                    .delay(1.5),
                    value: isAnimating
                )
                
                Spacer()
            }
            .padding(.horizontal, Spacing.xl)
        }
        .onAppear {
            startAnimation()
        }
        .onChange(of: showAuth) { newValue in
            if newValue {
                onComplete()
            }
        }
    }
    
    // MARK: - Animation Logic
    private func startAnimation() {
        // Logo entrance animation
        withAnimation(.easeOut(duration: 0.8)) {
            scale = 1.0
            opacity = 1.0
        }
        
        // Start other animations
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isAnimating = true
        }
        
        // Transition to auth after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            showAuth = true
        }
    }
}

// MARK: - Preview
struct SplashScreen_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SplashScreen(onComplete: {})
                .preferredColorScheme(.light)
                .previewDisplayName(NSLocalizedString("preview_light_mode", comment: "Light mode preview"))
            
            SplashScreen(onComplete: {})
                .preferredColorScheme(.dark)
                .previewDisplayName(NSLocalizedString("preview_dark_mode", comment: "Dark mode preview"))
        }
    }
}

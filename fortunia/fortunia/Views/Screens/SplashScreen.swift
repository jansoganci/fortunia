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
                    // Mystical Orb
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.primary, .accent],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                        .blur(radius: isAnimating ? 30 : 10)
                        .scaleEffect(isAnimating ? 1.2 : 0.8)
                        .animation(
                            .easeInOut(duration: 2.0)
                            .repeatForever(autoreverses: true),
                            value: isAnimating
                        )
                        .overlay(
                            // Inner Glow
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [
                                            .white.opacity(0.3),
                                            .clear
                                        ],
                                        center: .center,
                                        startRadius: 0,
                                        endRadius: 60
                                    )
                                )
                                .frame(width: 120, height: 120)
                        )
                    
                    // App Title
                    Text("Fortunia")
                        .font(.system(size: 48, weight: .heavy, design: .serif))
                        .foregroundColor(.textPrimary)
                        .opacity(isAnimating ? 1.0 : 0.0)
                        .animation(
                            .easeInOut(duration: 1.0)
                            .delay(0.5),
                            value: isAnimating
                        )
                    
                    // Tagline
                    Text("Discover Your Fortune")
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
        isAnimating = true
        
        // 1 second delay before transitioning
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
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
                .previewDisplayName("Light Mode")
            
            SplashScreen(onComplete: {})
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark Mode")
        }
    }
}

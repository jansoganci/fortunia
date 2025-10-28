
//
//  MysticalLoadingView.swift
//  fortunia
//
//  Created by Gemini on October 26, 2025.
//

import SwiftUI

/// A reusable, elegant loading animation inspired by mystical energy.
///
/// This view features a central glowing orb with shimmering particles, designed
/// to be overlaid on any background. It loops continuously and includes
/// fade-in/out transitions for a smooth user experience.
///
/// - Parameter size: The diameter of the loading animation. Defaults to 120.
struct MysticalLoadingView: View {
    @State private var isAnimating = false
    let size: CGFloat

    init(size: CGFloat = 120) {
        self.size = size
    }

    var body: some View {
        ZStack {
            // Shimmering Particles
            ForEach(0..<8) { i in
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.white.opacity(0.7), .primary.opacity(0.5), .accent.opacity(0.8)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: size * 0.1, height: size * 0.1)
                    .scaleEffect(isAnimating ? 1.0 : 0.5)
                    .offset(x: size / 2.5)
                    .rotationEffect(.degrees(Double(i) * 45))
                    .animation(
                        .easeInOut(duration: 1.5)
                        .repeatForever(autoreverses: true)
                        .delay(Double(i) * 0.1),
                        value: isAnimating
                    )
            }

            // Central Pulsing Orb
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [.primary.opacity(0.8), .accent.opacity(0.4), .clear]),
                        center: .center,
                        startRadius: size * 0.05,
                        endRadius: size * 0.4
                    )
                )
                .frame(width: size * 0.8, height: size * 0.8)
                .scaleEffect(isAnimating ? 1.1 : 0.9)
                .animation(
                    .easeInOut(duration: 2.0)
                    .repeatForever(autoreverses: true),
                    value: isAnimating
                )
        }
        .frame(width: size, height: size)
        .rotationEffect(.degrees(isAnimating ? 360 : 0))
        .animation(
            .linear(duration: 10.0)
            .repeatForever(autoreverses: false),
            value: isAnimating
        )
        .onAppear {
            isAnimating = true
        }
        .transition(.opacity.animation(.easeInOut(duration: 0.4)))
    }
}

// MARK: - Preview
struct MysticalLoadingView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.backgroundPrimary.ignoresSafeArea()
            MysticalLoadingView(size: 150)
        }
        .preferredColorScheme(.dark)
    }
}

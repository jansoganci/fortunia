//
//  Buttons.swift
//  fortunia
//
//  Created by Can Soğancı on 24.10.2025.
//

import SwiftUI

// MARK: - Primary Button
struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var isLoading: Bool = false
    var isDisabled: Bool = false
    
    var body: some View {
        Button(action: action) {
            HStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else {
                    Text(title)
                        .font(AppTypography.button)
                        .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                LinearGradient(
                    colors: isDisabled ? [Color.gray, Color.gray.opacity(0.7)] : [Color.primary, Color.accent],
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
        .disabled(isDisabled || isLoading)
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Secondary Button
struct SecondaryButton: View {
    let title: String
    let action: () -> Void
    var isLoading: Bool = false
    var isDisabled: Bool = false
    
    var body: some View {
        Button(action: action) {
            HStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .primary))
                        .scaleEffect(0.8)
                } else {
                    Text(title)
                        .font(AppTypography.button)
                        .foregroundColor(.primary)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(Color.surface)
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.md)
                    .stroke(Color.primary, lineWidth: 1)
            )
            .cornerRadius(CornerRadius.md)
        }
        .disabled(isDisabled || isLoading)
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
struct Buttons_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            PrimaryButton(title: NSLocalizedString("test_primary_button", comment: "Primary button test"), action: {})
            
            SecondaryButton(title: NSLocalizedString("test_secondary_button", comment: "Secondary button test"), action: {})
            
            PrimaryButton(title: NSLocalizedString("test_loading_button", comment: "Loading button test"), action: {}, isLoading: true)
            
            PrimaryButton(title: NSLocalizedString("test_disabled_button", comment: "Disabled button test"), action: {}, isDisabled: true)
        }
        .padding()
    }
}

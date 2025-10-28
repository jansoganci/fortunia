//
//  ProfileRow.swift
//  fortunia
//
//  Created by Cursor AI on December 19, 2024
//

import SwiftUI

/// Reusable profile row component for settings lists
struct ProfileRow: View {
    let icon: String
    let title: String
    let showChevron: Bool
    var isDestructive: Bool = false
    var selectedValue: String? = nil
    var onTap: () -> Void = {}
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: Spacing.md) {
                Image(systemName: icon)
                    .foregroundColor(isDestructive ? .red : .primary)
                    .frame(width: 24)
                
                Text(title)
                    .font(AppTypography.bodyMedium)
                    .foregroundColor(isDestructive ? .red : .textPrimary)
                
                Spacer()
                
                if let value = selectedValue {
                    Text(value)
                        .font(AppTypography.bodyMedium)
                        .foregroundColor(.textSecondary)
                }
                
                if showChevron {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12))
                        .foregroundColor(.textSecondary)
                }
            }
            .padding(.vertical, Spacing.xs)
        }
    }
}

struct ProfileRow_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            List {
                Section {
                    ProfileRow(icon: "person.fill", title: "Profile", showChevron: true)
                    ProfileRow(icon: "hand.raised.fill", title: "Privacy Policy", showChevron: true)
                }
            }
            .preferredColorScheme(.light)
            
            List {
                Section {
                    ProfileRow(icon: "rectangle.portrait.and.arrow.right", title: "Sign Out", showChevron: false, isDestructive: true)
                }
            }
            .preferredColorScheme(.dark)
        }
    }
}


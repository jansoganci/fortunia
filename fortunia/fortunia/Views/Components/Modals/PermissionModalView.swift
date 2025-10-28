//
//  PermissionModalView.swift
//  fortunia
//
//  Created by Cursor AI on October 26, 2025.
//

import SwiftUI

enum PermissionType {
    case camera
    case photoLibrary
    
    var icon: String {
        switch self {
        case .camera:
            return "camera.fill"
        case .photoLibrary:
            return "photo.on.rectangle"
        }
    }
    
    var titleKey: String {
        switch self {
        case .camera:
            return "permission_camera_title"
        case .photoLibrary:
            return "permission_library_title"
        }
    }
    
    var messageKey: String {
        switch self {
        case .camera:
            return "permission_camera_message"
        case .photoLibrary:
            return "permission_library_message"
        }
    }
    
    var allowButtonKey: String {
        return "permission_allow_button"
    }
    
    var deniedTitleKey: String {
        switch self {
        case .camera:
            return "permission_camera_denied_title"
        case .photoLibrary:
            return "permission_library_denied_title"
        }
    }
    
    var deniedMessageKey: String {
        switch self {
        case .camera:
            return "permission_camera_denied_message"
        case .photoLibrary:
            return "permission_library_denied_message"
        }
    }
}

struct PermissionModalView: View {
    let permissionType: PermissionType
    let onAllow: () -> Void
    let onDeny: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Modal Content
            VStack(spacing: Spacing.lg) {
                // Icon
                Image(systemName: permissionType.icon)
                    .font(.system(size: 64, weight: .thin))
                    .foregroundColor(.accent)
                    .padding()
                    .background(
                        Circle()
                            .fill(Color.primary.opacity(0.1))
                    )
                
                // Title
                Text(LocalizedStringKey(permissionType.titleKey))
                    .font(AppTypography.heading2)
                    .foregroundColor(.textPrimary)
                    .multilineTextAlignment(.center)
                
                // Message
                Text(LocalizedStringKey(permissionType.messageKey))
                    .font(AppTypography.bodyMedium)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
                
                // Action Buttons
                VStack(spacing: Spacing.md) {
                    PrimaryButton(
                        title: NSLocalizedString(permissionType.allowButtonKey, comment: "Allow"),
                        action: onAllow
                    )
                    
                    Button(action: onDeny) {
                        Text(NSLocalizedString("permission_not_now_button", comment: "Not Now"))
                            .font(AppTypography.bodyMedium)
                            .foregroundColor(.textSecondary)
                    }
                }
                .padding(.horizontal, Spacing.xl)
            }
            .padding(Spacing.xl)
            .frame(maxWidth: 600)
            .background(Color.surface)
            .cornerRadius(CornerRadius.lg)
            .shadow(
                color: Elevation.level3.color,
                radius: Elevation.level3.radius,
                x: Elevation.level3.x,
                y: Elevation.level3.y
            )
            .padding(.horizontal, Spacing.xl)
            
            Spacer()
        }
    }
}

struct PermissionDeniedAlertView: View {
    let permissionType: PermissionType
    let onOpenSettings: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        VStack(spacing: Spacing.md) {
            // Icon
            Image(systemName: permissionType.icon)
                .font(.system(size: 48, weight: .medium))
                .foregroundColor(.accent)
            
            // Title
            Text(LocalizedStringKey(permissionType.deniedTitleKey))
                .font(AppTypography.heading3)
                .foregroundColor(.textPrimary)
                .multilineTextAlignment(.center)
            
            // Message
            Text(LocalizedStringKey(permissionType.deniedMessageKey))
                .font(AppTypography.bodyMedium)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
            
            // Action Buttons
            VStack(spacing: Spacing.sm) {
                PrimaryButton(
                    title: NSLocalizedString("permission_open_settings_button", comment: "Open Settings"),
                    action: onOpenSettings
                )
                
                Button(action: onCancel) {
                    Text(NSLocalizedString("permission_cancel_button", comment: "Cancel"))
                        .font(AppTypography.bodyMedium)
                        .foregroundColor(.textSecondary)
                }
            }
            .padding(.top, Spacing.md)
        }
        .padding(Spacing.xl)
    }
}

// MARK: - Preview
struct PermissionModalView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PermissionModalView(
                permissionType: .camera,
                onAllow: {},
                onDeny: {}
            )
            .preferredColorScheme(.dark)
            
            PermissionDeniedAlertView(
                permissionType: .photoLibrary,
                onOpenSettings: {},
                onCancel: {}
            )
            .preferredColorScheme(.dark)
        }
    }
}


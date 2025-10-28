
//
//  BirthInfoModalView.swift
//  fortunia
//
//  Created by Can Soğancı on 25.10.2025.
//

import SwiftUI

struct BirthInfoModalView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var authService = AuthService.shared
    
    // Form Data
    @State private var birthDate = Date()
    @State private var birthTime = Date()
    @State private var birthCity = ""
    @State private var birthCountry = ""
    
    // UI State
    @State private var currentPage = 0
    @State private var isLoading = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isSuccess = false

    let onComplete: () -> Void
    
    private let totalPages = 2

    var body: some View {
        ZStack {
            Color.backgroundPrimary.ignoresSafeArea()
            
            // X Button (Top Left)
            VStack {
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.textPrimary)
                            .frame(width: 28, height: 28)
                            .background(Color.surface.opacity(0.6))
                            .clipShape(Circle())
                    }
                    .padding(.leading, Spacing.md)
                    .padding(.top, Spacing.sm)
                    Spacer()
                }
                Spacer()
            }
            .zIndex(999)
            
            VStack(spacing: 0) {
                // Page Indicator
                PageIndicatorView(currentPage: currentPage, totalPages: totalPages)
                    .padding(.top, Spacing.lg)
                    .padding(.horizontal, Spacing.xl)
                
                // Page Content
                TabView(selection: $currentPage) {
                    // Page 1: Birth Date & Time
                    BirthDatePageView(
                        birthDate: $birthDate,
                        birthTime: $birthTime
                    )
                    .tag(0)
                    
                    // Page 2: Birth City & Country
                    BirthLocationPageView(
                        birthCity: $birthCity,
                        birthCountry: $birthCountry
                    )
                    .tag(1)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .gesture(DragGesture().onChanged { _ in }) // Disable swipe gestures only
                
                // Action Buttons
                VStack(spacing: Spacing.md) {
                    PrimaryButton(
                        title: getActionButtonTitle(),
                        action: handlePrimaryAction,
                        isLoading: isLoading,
                        isDisabled: isPrimaryButtonDisabled()
                    )
                    .padding(.horizontal, Spacing.xl)
                    .padding(.bottom, Spacing.md)
                }
                .background(Color.backgroundPrimary)
            }
        }
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text(isSuccess ? NSLocalizedString("alert_success_title", comment: "Success") : NSLocalizedString("alert_error_title", comment: "Error")),
                message: Text(alertMessage),
                dismissButton: .default(Text(NSLocalizedString("alert_ok_button", comment: "OK"))) {
                    if isSuccess {
                        onComplete()
                        dismiss()
                    }
                }
            )
        }
    }
    
    // MARK: - Helper Methods
    
    private func getActionButtonTitle() -> String {
        if isLoading {
            return NSLocalizedString("birth_loading", comment: "Saving...")
        }
        return currentPage == totalPages - 1 
            ? NSLocalizedString("birth_save_continue_button", comment: "Save & Continue")
            : NSLocalizedString("birth_next_button", comment: "Next")
    }
    
    private func isPrimaryButtonDisabled() -> Bool {
        if isLoading {
            return true
        }
        
        if currentPage == 0 {
            // Page 1: Date and time always have values (using default date)
            return false
        } else {
            // Page 2: City and country are required
            return birthCity.isEmpty || birthCountry.isEmpty
        }
    }
    
    private func handlePrimaryAction() {
        if currentPage < totalPages - 1 {
            // Go to next page
            withAnimation {
                currentPage += 1
            }
        } else {
            // Save and complete
            saveBirthInfo()
        }
    }
    
    private func saveBirthInfo() {
        print("🧩 [ONBOARDING] Save button tapped")
        print("🧩 [ONBOARDING] Birth date: \(birthDate)")
        print("🧩 [ONBOARDING] Birth time: \(birthTime)")
        print("🧩 [ONBOARDING] Birth city: \(birthCity)")
        print("🧩 [ONBOARDING] Birth country: \(birthCountry)")
        
        guard let userId = authService.currentUserId else {
            print("🧩 [ONBOARDING] ❌ ERROR: currentUserId is nil")
            print("🧩 [ONBOARDING] Current user ID from authService: \(authService.currentUserId ?? "nil")")
            print("🧩 [ONBOARDING] AuthService state: \(authService)")
            showAlert(message: NSLocalizedString("birth_save_error", comment: "Failed to save birth details"), isSuccess: false)
            return
        }
        
        print("🧩 [ONBOARDING] ✅ Got user ID: \(userId)")
        print("🧩 [ONBOARDING] Mode: Guest or Authenticated (checking authService.isAuthenticated)")
        
        isLoading = true
        
        Task {
            do {
                print("🧩 [ONBOARDING] [STEP 1/4] Starting save process")
                
                // Format the birth time
                let formatter = DateFormatter()
                formatter.dateFormat = "HH:mm"
                let birthTimeString = formatter.string(from: birthTime)
                
                print("🧩 [ONBOARDING] [STEP 1/4] Birth time formatted: \(birthTimeString)")
                
                // Check if Supabase client is available
                guard let supabase = SupabaseService.shared.supabase else {
                    print("🧩 [ONBOARDING] ❌ [STEP 1/4] Supabase client not configured")
                    throw NSError(domain: "Fortunia", code: -1, userInfo: [NSLocalizedDescriptionKey: "Supabase client not configured"])
                }
                
                print("🧩 [ONBOARDING] ✅ [STEP 1/4] Supabase client available")
                
                // Prepare payload
                let birthDateISO = ISO8601DateFormatter().string(from: birthDate)
                let payload1: [String: Any] = [
                    "birth_date": birthDateISO,
                    "birth_time": birthTimeString,
                    "birth_city": birthCity,
                    "birth_country": birthCountry
                ]
                print("🧩 [ONBOARDING] [STEP 2/4] Sending birth details to Supabase")
                print("🧩 [ONBOARDING] [STEP 2/4] Payload:", payload1)
                print("🧩 [ONBOARDING] [STEP 2/4] User ID:", userId)
                
                // Update user profile in Supabase including onboarding completion flag
                // Split updates to handle mixed types properly
                let response1 = try await supabase
                    .from("users")
                    .update([
                        "birth_date": ISO8601DateFormatter().string(from: birthDate),
                        "birth_time": birthTimeString,
                        "birth_city": birthCity,
                        "birth_country": birthCountry
                    ])
                    .eq("id", value: userId)
                    .execute()
                
                print("🧩 [ONBOARDING] ✅ [STEP 2/4] Birth details saved successfully")
                
                // Mark onboarding as complete
                print("🧩 [ONBOARDING] [STEP 3/4] Marking onboarding as complete")
                let response2 = try await supabase
                    .from("users")
                    .update(["onboarding_completed": true])
                    .eq("id", value: userId)
                    .execute()
                
                print("🧩 [ONBOARDING] ✅ [STEP 3/4] Onboarding marked as complete")
                print("🧩 [ONBOARDING] ✅ [STEP 4/4] All updates completed successfully")
                
                await MainActor.run {
                    isLoading = false
                    showAlert(message: NSLocalizedString("birth_save_success", comment: "Birth details saved successfully"), isSuccess: true)
                }
                
            } catch {
                print("🧩 [ONBOARDING] ❌ ERROR occurred during save")
                print("🧩 [ONBOARDING] ❌ Error type:", type(of: error))
                print("🧩 [ONBOARDING] ❌ Error description:", error.localizedDescription)
                
                if let nsError = error as NSError? {
                    print("🧩 [ONBOARDING] ❌ Error domain:", nsError.domain)
                    print("🧩 [ONBOARDING] ❌ Error code:", nsError.code)
                    print("🧩 [ONBOARDING] ❌ Error userInfo:", nsError.userInfo)
                }
                
                await MainActor.run {
                    isLoading = false
                    showAlert(message: NSLocalizedString("birth_save_error", comment: "Failed to save birth details"), isSuccess: false)
                }
            }
        }
    }
    
    private func showAlert(message: String, isSuccess: Bool) {
        alertMessage = message
        self.isSuccess = isSuccess
        showingAlert = true
    }
}

// MARK: - Page Indicator View
struct PageIndicatorView: View {
    let currentPage: Int
    let totalPages: Int
    
    var body: some View {
        HStack(spacing: Spacing.sm) {
            ForEach(0..<totalPages, id: \.self) { page in
                Circle()
                    .fill(page == currentPage ? Color.primary : Color.textSecondary.opacity(0.3))
                    .frame(width: 8, height: 8)
                    .animation(.easeInOut, value: currentPage)
            }
        }
    }
}

// MARK: - Birth Date Page View
struct BirthDatePageView: View {
    @Binding var birthDate: Date
    @Binding var birthTime: Date
    
    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.xl) {
                Spacer(minLength: Spacing.xxl)
                
                // Header
                VStack(spacing: Spacing.sm) {
                    Text(NSLocalizedString("birth_date_step_title", comment: "Birth Date & Time"))
                        .font(AppTypography.heading2)
                        .foregroundColor(.textPrimary)
                        .multilineTextAlignment(.center)
                    
                    Text(NSLocalizedString("birth_date_step_subtitle", comment: "When were you born?"))
                        .font(AppTypography.bodyMedium)
                        .foregroundColor(.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, Spacing.xl)
                
                // Date Picker Card
                VStack(spacing: Spacing.lg) {
                    Text(NSLocalizedString("birth_date_picker", comment: "Birth Date"))
                        .font(AppTypography.heading4)
                        .foregroundColor(.textPrimary)
                    
                    DatePicker(
                        "",
                        selection: $birthDate,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.graphical)
                    .accentColor(.primary)
                    
                    Divider()
                        .padding(.vertical, Spacing.sm)
                    
                    Text(NSLocalizedString("birth_time_picker", comment: "Birth Time"))
                        .font(AppTypography.heading4)
                        .foregroundColor(.textPrimary)
                    
                    DatePicker(
                        "",
                        selection: $birthTime,
                        displayedComponents: .hourAndMinute
                    )
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .frame(height: 150)
                }
                .padding(Spacing.lg)
                .background(Color.surface)
                .cornerRadius(CornerRadius.lg)
                .shadow(
                    color: Elevation.level2.color,
                    radius: Elevation.level2.radius,
                    x: Elevation.level2.x,
                    y: Elevation.level2.y
                )
                .padding(.horizontal, Spacing.xl)
                
                Spacer(minLength: Spacing.xxl)
            }
        }
    }
}

// MARK: - Birth Location Page View
struct BirthLocationPageView: View {
    @Binding var birthCity: String
    @Binding var birthCountry: String
    
    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.xl) {
                Spacer(minLength: Spacing.xxl)
                
                // Header
                VStack(spacing: Spacing.sm) {
                    Text(NSLocalizedString("birth_location_step_title", comment: "Birth Location"))
                        .font(AppTypography.heading2)
                        .foregroundColor(.textPrimary)
                        .multilineTextAlignment(.center)
                    
                    Text(NSLocalizedString("birth_location_step_subtitle", comment: "Where were you born?"))
                        .font(AppTypography.bodyMedium)
                        .foregroundColor(.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, Spacing.xl)
                
                // Location Input Card
                VStack(spacing: Spacing.lg) {
                    AppTextField(
                        placeholder: NSLocalizedString("birth_city_placeholder", comment: "City of Birth"),
                        text: $birthCity,
                        icon: "mappin.and.ellipse"
                    )
                    
                    AppTextField(
                        placeholder: NSLocalizedString("birth_country_placeholder", comment: "Country of Birth"),
                        text: $birthCountry,
                        icon: "globe"
                    )
                }
                .padding(Spacing.lg)
                .background(Color.surface)
                .cornerRadius(CornerRadius.lg)
                .shadow(
                    color: Elevation.level2.color,
                    radius: Elevation.level2.radius,
                    x: Elevation.level2.x,
                    y: Elevation.level2.y
                )
                .padding(.horizontal, Spacing.xl)
                
                Spacer(minLength: Spacing.xxl)
            }
        }
    }
}

struct BirthInfoModalView_Previews: PreviewProvider {
    static var previews: some View {
        BirthInfoModalView(onComplete: {})
            .preferredColorScheme(.dark)
    }
}

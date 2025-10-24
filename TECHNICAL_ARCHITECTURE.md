# 🏗️ TECHNICAL ARCHITECTURE - FORTUNIA

**Version:** 1.0  
**Date:** October 24, 2025  
**Document Type:** Technical Architecture Specification  
**Status:** Implementation Guide

---

## 📋 TABLE OF CONTENTS

1. System Overview
2. Tech Stack Details
3. Database Architecture
4. User Flow Diagram
5. Quota System
6. Error Logging & Debug System
7. API Endpoints
8. Security & Privacy
9. Performance Requirements
10. Multi-Language Implementation
11. Deployment Strategy
12. Monitoring & Analytics
13. Legal & Compliance

---

## 1. SYSTEM OVERVIEW

### **Architecture Pattern**
- **Frontend**: SwiftUI + MVVM + Combine
- **Backend**: Supabase (Serverless)
- **AI Processing**: Hybrid (On-device + Cloud)
- **Data Flow**: Event-driven with real-time sync

### **Core Principles**
- **Privacy First**: Photos processed on-device when possible
- **Offline Capable**: Core features work without internet
- **Multi-Language**: NSLocalizedString from Day 1
- **Cultural Respect**: Authentic fortune traditions

---

## 2. TECH STACK DETAILS

### **Frontend (iOS)**
```swift
// Core Technologies
- SwiftUI (iOS 15.0+)
- Combine (Reactive programming)
- Core Data (Local storage)
- Vision Framework (Face detection)
- Core ML (On-device AI)

// Dependencies (SPM)
- Supabase-Swift (Auth + Database)
- Adapty-iOS (Subscription management)
- Kingfisher (Image caching)
- Firebase-iOS-SDK (Analytics + Crashlytics)
```

### **Backend (Supabase)**
```typescript
// Runtime
- Deno 1.x + TypeScript
- Supabase Edge Functions
- PostgreSQL with RLS
- Supabase Storage

// AI Services
- fal.ai API (Image analysis)
- Google Gemini API (Text generation)
```

### **Third-Party Services**
```yaml
Analytics:
  - Firebase Analytics (Event tracking)
  - Firebase Crashlytics (Error reporting)

Payments:
  - Adapty (Subscription management)
  - StoreKit 2 (Apple IAP)

Push Notifications:
  - Firebase Cloud Messaging
  - Apple Push Notification Service

Image Processing:
  - iOS Native UIImage compression
  - Supabase Storage (Cloud backup)
```

---

## 3. DATABASE ARCHITECTURE

### **Supabase Schema**

```sql
-- ===========================================
-- USERS TABLE
-- ===========================================
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  email TEXT UNIQUE,
  birth_date DATE,
  birth_time TIME,
  birth_city TEXT,
  birth_country TEXT,
  timezone TEXT DEFAULT 'UTC',
  language TEXT DEFAULT 'en',
  notification_enabled BOOLEAN DEFAULT FALSE,
  notification_time TIME DEFAULT '09:00:00',
  created_at TIMESTAMP DEFAULT NOW(),
  last_active_at TIMESTAMP DEFAULT NOW()
);

-- ===========================================
-- READINGS TABLE
-- ===========================================
CREATE TABLE readings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id),
  reading_type TEXT NOT NULL, -- 'face', 'palm', 'tarot', 'coffee'
  cultural_origin TEXT NOT NULL, -- 'chinese', 'middle_eastern', 'european'
  image_url TEXT,
  result_text TEXT,
  share_card_url TEXT,
  is_premium BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT NOW()
);

-- ===========================================
-- DAILY QUOTAS TABLE
-- ===========================================
CREATE TABLE daily_quotas (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id),
  date DATE NOT NULL,
  free_readings_used INTEGER DEFAULT 0, -- Max 3 per day
  premium_readings_used INTEGER DEFAULT 0,
  created_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(user_id, date)
);

-- ===========================================
-- SUBSCRIPTIONS TABLE
-- ===========================================
CREATE TABLE subscriptions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id),
  adapty_customer_id TEXT UNIQUE,
  adapty_subscription_id TEXT,
  status TEXT NOT NULL, -- 'active', 'expired', 'cancelled', 'trial'
  product_id TEXT NOT NULL, -- 'weekly', 'monthly', 'yearly'
  expires_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW()
);
```

### **Row Level Security (RLS)**

```sql
-- Enable RLS on all tables
ALTER TABLE readings ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_quotas ENABLE ROW LEVEL SECURITY;
ALTER TABLE subscriptions ENABLE ROW LEVEL SECURITY;

-- Users can only access their own data
CREATE POLICY "Users can only access own readings"
ON readings FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users can only access own quotas"
ON daily_quotas FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users can only access own subscriptions"
ON subscriptions FOR ALL USING (auth.uid() = user_id);

-- Note: Admin policies removed for solo dev project

-- Public data policies (for app configuration)
CREATE POLICY "Public can read fortune types"
ON fortune_types FOR SELECT USING (true);

CREATE POLICY "Public can read cultural origins"
ON cultural_origins FOR SELECT USING (true);
```

### **Helper Functions**

```sql
-- Check daily quota
CREATE OR REPLACE FUNCTION check_daily_quota(p_user_id UUID)
RETURNS INTEGER AS $$
DECLARE
  quota_count INTEGER;
BEGIN
  SELECT free_readings_used INTO quota_count
  FROM daily_quotas
  WHERE user_id = p_user_id AND date = CURRENT_DATE;
  
  IF quota_count IS NULL THEN
    INSERT INTO daily_quotas (user_id, date, free_readings_used)
    VALUES (p_user_id, CURRENT_DATE, 0);
    RETURN 0;
  END IF;
  
  RETURN quota_count;
END;
$$ LANGUAGE plpgsql;

-- Increment quota
CREATE OR REPLACE FUNCTION increment_daily_quota(p_user_id UUID)
RETURNS VOID AS $$
BEGIN
  INSERT INTO daily_quotas (user_id, date, free_readings_used)
  VALUES (p_user_id, CURRENT_DATE, 1)
  ON CONFLICT (user_id, date)
  DO UPDATE SET free_readings_used = daily_quotas.free_readings_used + 1;
END;
$$ LANGUAGE plpgsql;

-- BananaUniverse'den adapte edilen quota sistemi
CREATE OR REPLACE FUNCTION get_quota(
  p_user_id UUID DEFAULT NULL,
  p_device_id TEXT DEFAULT NULL
)
RETURNS JSON AS $$
DECLARE
  v_quota_used INTEGER := 0;
  v_quota_limit INTEGER := 3; -- 3 daily limit for Fortunia
  v_is_premium BOOLEAN := FALSE;
  v_quota_remaining INTEGER;
BEGIN
  -- Premium user check
  IF p_user_id IS NOT NULL THEN
    SELECT EXISTS(
      SELECT 1 FROM subscriptions 
      WHERE user_id = p_user_id 
      AND status = 'active' 
      AND expires_at > NOW()
    ) INTO v_is_premium;
  END IF;
  
  -- Premium user ise unlimited
  IF v_is_premium THEN
    RETURN json_build_object(
      'quota_used', 0,
      'quota_limit', 999999,
      'quota_remaining', 999999,
      'is_premium', true
    );
  END IF;
  
  -- Quota check for authenticated user
  IF p_user_id IS NOT NULL THEN
    SELECT COALESCE(free_readings_used, 0) INTO v_quota_used
    FROM daily_quotas
    WHERE user_id = p_user_id AND date = CURRENT_DATE;
    
    -- Create record if not exists for today
    IF NOT FOUND THEN
      INSERT INTO daily_quotas (user_id, date, free_readings_used)
      VALUES (p_user_id, CURRENT_DATE, 0)
      ON CONFLICT (user_id, date) DO NOTHING;
      v_quota_used := 0;
    END IF;
  END IF;
  
  -- Check for anonymous user with device_id
  IF p_device_id IS NOT NULL THEN
    SELECT COALESCE(free_readings_used, 0) INTO v_quota_used
    FROM daily_quotas
    WHERE user_id IS NULL AND device_id = p_device_id AND date = CURRENT_DATE;
    
    -- Create record if not exists for today
    IF NOT FOUND THEN
      INSERT INTO daily_quotas (user_id, device_id, date, free_readings_used)
      VALUES (NULL, p_device_id, CURRENT_DATE, 0)
      ON CONFLICT (user_id, device_id, date) DO NOTHING;
      v_quota_used := 0;
    END IF;
  END IF;
  
  v_quota_remaining := GREATEST(0, v_quota_limit - v_quota_used);
  
  RETURN json_build_object(
    'quota_used', v_quota_used,
    'quota_limit', v_quota_limit,
    'quota_remaining', v_quota_remaining,
    'is_premium', v_is_premium
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Quota consume fonksiyonu
CREATE OR REPLACE FUNCTION consume_quota(
  p_user_id UUID DEFAULT NULL,
  p_device_id TEXT DEFAULT NULL,
  p_is_premium BOOLEAN DEFAULT FALSE
)
RETURNS JSON AS $$
DECLARE
  v_quota_info JSON;
  v_quota_used INTEGER;
  v_quota_limit INTEGER;
  v_quota_remaining INTEGER;
  v_is_premium BOOLEAN;
BEGIN
  -- Mevcut quota durumunu al
  SELECT get_quota(p_user_id, p_device_id) INTO v_quota_info;
  
  v_quota_used := (v_quota_info->>'quota_used')::INTEGER;
  v_quota_limit := (v_quota_info->>'quota_limit')::INTEGER;
  v_quota_remaining := (v_quota_info->>'quota_remaining')::INTEGER;
  v_is_premium := (v_quota_info->>'is_premium')::BOOLEAN;
  
  -- Premium user ise her zaman izin ver
  IF v_is_premium OR p_is_premium THEN
    RETURN json_build_object(
      'success', true,
      'quota_used', v_quota_used,
      'quota_limit', v_quota_limit,
      'quota_remaining', 999999,
      'is_premium', true
    );
  END IF;
  
  -- Quota check
  IF v_quota_remaining <= 0 THEN
    RETURN json_build_object(
      'success', false,
      'error', 'daily_quota_exceeded',
      'quota_used', v_quota_used,
      'quota_limit', v_quota_limit,
      'quota_remaining', 0,
      'is_premium', false
    );
  END IF;
  
  -- Increment quota
  IF p_user_id IS NOT NULL THEN
    INSERT INTO daily_quotas (user_id, date, free_readings_used)
    VALUES (p_user_id, CURRENT_DATE, 1)
    ON CONFLICT (user_id, date)
    DO UPDATE SET free_readings_used = daily_quotas.free_readings_used + 1;
  ELSE
    INSERT INTO daily_quotas (user_id, device_id, date, free_readings_used)
    VALUES (NULL, p_device_id, CURRENT_DATE, 1)
    ON CONFLICT (user_id, device_id, date)
    DO UPDATE SET free_readings_used = daily_quotas.free_readings_used + 1;
  END IF;
  
  -- Return updated quota information
  SELECT get_quota(p_user_id, p_device_id) INTO v_quota_info;
  
  RETURN json_build_object(
    'success', true,
    'quota_used', (v_quota_info->>'quota_used')::INTEGER,
    'quota_limit', (v_quota_info->>'quota_limit')::INTEGER,
    'quota_remaining', (v_quota_info->>'quota_remaining')::INTEGER,
    'is_premium', (v_quota_info->>'is_premium')::BOOLEAN
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

---

## 4. USER FLOW DIAGRAM

### **FORTUNIA USER FLOW**

```
[Splash 1s]
    ↓
[Auth Screen]
- Email/Password
- Apple Sign In  
- [Not Now] → Guest Mode
    ↓
[Home - TabView]
- Tab 1: Home (fortune types)
- Tab 2: Explore
- Tab 3: History
- Tab 4: Profile
    ↓
[Face Reading Tapped]
    ↓
[Birth Info Modal]
- Birth date
- Birth time
- Birth city/country
    ↓
[Camera Screen]
- Take photo / Upload
    ↓
[Processing 10s]
- Mystical animation
    ↓
[Result Screen]
- Fortune text
- Disclaimer (bottom)
- [Share] button
- [Get Another] button
    ↓
[30s delay]
    ↓
[Notification Permission]
- iOS native prompt
```

### **Flow Notes**
- **Splash**: 1 second brand exposure
- **Auth**: 3 options (Email, Apple, Guest)
- **Home**: TabView with 4 main sections
- **Birth Info**: Required for accurate readings
- **Camera**: Native iOS camera + photo library
- **Processing**: 10-second mystical animation
- **Result**: Shareable fortune with disclaimer
- **Notifications**: Delayed permission request (30s after first reading)

---

## 5. QUOTA SYSTEM (BananaUniverse'den Adapte)

### **QuotaManager (Swift)**

```swift
// QuotaManager.swift - BananaUniverse'den adapte edildi
@MainActor
class QuotaManager: ObservableObject {
    static let shared = QuotaManager()
    
    @Published var dailyQuotaUsed: Int = 0
    @Published var dailyQuotaLimit: Int = 3 // 3 daily limit for Fortunia
    @Published var isPremiumUser: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let supabase = SupabaseService.shared
    
    // MARK: - Quota Check & Consume
    func checkAndConsumeQuota() async throws -> QuotaInfo {
        let userState = AuthService.shared.userState
        
        let quotaInfo = try await supabase.consumeQuota(
            userId: userState.isAuthenticated ? userState.identifier : nil,
            deviceId: userState.isAuthenticated ? nil : userState.identifier,
            isPremium: isPremiumUser
        )
        
        // Update local state
        await updateFromBackendResponse(
            quotaUsed: quotaInfo.quotaUsed,
            quotaLimit: quotaInfo.quotaLimit,
            isPremium: quotaInfo.isPremium
        )
        
        return quotaInfo
    }
    
    // MARK: - Can Process Check
    func canProcessReading() -> Bool {
        if isPremiumUser {
            return true // Premium users bypass all limits
        }
        return dailyQuotaUsed < dailyQuotaLimit
    }
    
    // MARK: - Quota Reset (Midnight UTC)
    private func resetDailyQuotaIfNeeded() {
        let today = getLocalMidnightDate()
        let lastReset = UserDefaults.standard.string(forKey: "last_quota_reset") ?? ""
        
        if lastReset != today {
            dailyQuotaUsed = 0
            UserDefaults.standard.set(today, forKey: "last_quota_reset")
            UserDefaults.standard.set(dailyQuotaUsed, forKey: "daily_quota_used")
        }
    }
    
    private func getLocalMidnightDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone.current
        return formatter.string(from: Date())
    }
    
    // MARK: - Premium Status
    func refreshPremiumStatus() async {
        let hasActiveSubscription = await AdaptyService.shared.hasActiveSubscription()
        if isPremiumUser != hasActiveSubscription {
            isPremiumUser = hasActiveSubscription
            UserDefaults.standard.set(isPremiumUser, forKey: "is_premium_user")
            objectWillChange.send()
        }
    }
    
    // MARK: - Computed Properties
    var remainingQuota: Int {
        if isPremiumUser {
            return Int.max // Unlimited
        }
        return max(0, dailyQuotaLimit - dailyQuotaUsed)
    }
    
    var hasQuotaLeft: Bool {
        if isPremiumUser {
            return true
        }
        return remainingQuota > 0
    }
    
    var quotaDisplayText: String {
        if isPremiumUser {
            return "Unlimited"
        }
        return "\(dailyQuotaUsed)/\(dailyQuotaLimit)"
    }
    
    var shouldShowQuotaWarning: Bool {
        return !isPremiumUser && remainingQuota <= 1
    }
    
    var quotaWarningMessage: String {
        if remainingQuota == 1 {
            return "⚠️ Only 1 reading left today!"
        }
        return ""
    }
}
```

### **Quota UI Components**

```swift
// QuotaProgressView.swift
struct QuotaProgressView: View {
    @ObservedObject var quotaManager = QuotaManager.shared
    
    var body: some View {
        HStack(spacing: Spacing.sm) {
            // Progress bar
            ProgressView(value: Double(quotaManager.dailyQuotaUsed), 
                        total: Double(quotaManager.dailyQuotaLimit))
                .progressViewStyle(LinearProgressViewStyle(tint: .accent))
                .frame(height: 8)
            
            // Quota text
            Text(quotaManager.quotaDisplayText)
                .font(AppTypography.caption)
                .foregroundColor(.textSecondary)
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
        .background(Color.surface)
        .cornerRadius(CornerRadius.sm)
    }
}

// QuotaWarningView.swift
struct QuotaWarningView: View {
    @ObservedObject var quotaManager = QuotaManager.shared
    
    var body: some View {
        if quotaManager.shouldShowQuotaWarning {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                
                Text(quotaManager.quotaWarningMessage)
                    .font(AppTypography.caption)
                    .foregroundColor(.orange)
                
                Spacer()
                
                Button("Upgrade") {
                    // Show paywall
                }
                .font(AppTypography.caption)
                .foregroundColor(.accent)
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
            .background(Color.orange.opacity(0.1))
            .cornerRadius(CornerRadius.sm)
        }
    }
}

// QuotaExceededView.swift
struct QuotaExceededView: View {
    let onUpgrade: () -> Void
    
    var body: some View {
        VStack(spacing: Spacing.lg) {
            Image(systemName: "hourglass.tophalf.filled")
                .font(.system(size: 48))
                .foregroundColor(.accent)
            
            Text("Daily Quota Reached")
                .font(AppTypography.heading3)
                .foregroundColor(.textPrimary)
            
            Text("You've used all 3 free readings for today. Upgrade to Premium for unlimited access!")
                .font(AppTypography.bodyMedium)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
            
            PrimaryButton(title: "Upgrade to Premium", action: onUpgrade)
        }
        .padding(Spacing.xl)
    }
}
```

---

## 6. ERROR LOGGING & DEBUG SYSTEM

### **ErrorLogger (Production'da kalacak)**

```swift
// ErrorLogger.swift
import Foundation
import FirebaseCrashlytics

class ErrorLogger {
    static let shared = ErrorLogger()
    
    // MARK: - Error Logging
    func logError(_ error: Error, context: String, additionalInfo: [String: Any] = [:]) {
        let errorInfo = [
            "context": context,
            "error_description": error.localizedDescription,
            "error_type": String(describing: type(of: error)),
            "timestamp": ISO8601DateFormatter().string(from: Date()),
            "additional_info": additionalInfo
        ] as [String: Any]
        
        // Send to Firebase Crashlytics
        Crashlytics.crashlytics().record(error: error)
        Crashlytics.crashlytics().setCustomValue(context, forKey: "error_context")
        
        // Also write to console (for development)
        print("🚨 [ERROR] \(context): \(error.localizedDescription)")
        print("🚨 [ERROR] Additional Info: \(additionalInfo)")
    }
    
    // MARK: - Network Errors
    func logNetworkError(_ error: Error, endpoint: String, statusCode: Int? = nil) {
        var additionalInfo: [String: Any] = [
            "endpoint": endpoint,
            "error_type": "network"
        ]
        
        if let statusCode = statusCode {
            additionalInfo["status_code"] = statusCode
        }
        
        logError(error, context: "Network Error", additionalInfo: additionalInfo)
    }
    
    // MARK: - Auth Errors
    func logAuthError(_ error: Error, action: String) {
        let additionalInfo = [
            "auth_action": action,
            "error_type": "authentication"
        ]
        
        logError(error, context: "Authentication Error", additionalInfo: additionalInfo)
    }
    
    // MARK: - Quota Errors
    func logQuotaError(_ error: Error, userId: String?, deviceId: String?) {
        let additionalInfo = [
            "user_id": userId ?? "anonymous",
            "device_id": deviceId ?? "unknown",
            "error_type": "quota"
        ]
        
        logError(error, context: "Quota Error", additionalInfo: additionalInfo)
    }
    
    // MARK: - AI Processing Errors
    func logAIError(_ error: Error, readingType: String, culturalOrigin: String) {
        let additionalInfo = [
            "reading_type": readingType,
            "cultural_origin": culturalOrigin,
            "error_type": "ai_processing"
        ]
        
        logError(error, context: "AI Processing Error", additionalInfo: additionalInfo)
    }
    
    // MARK: - Payment Errors
    func logPaymentError(_ error: Error, productId: String, action: String) {
        let additionalInfo = [
            "product_id": productId,
            "payment_action": action,
            "error_type": "payment"
        ]
        
        logError(error, context: "Payment Error", additionalInfo: additionalInfo)
    }
}
```

### **DebugLogger (To be removed before TestFlight)**

```swift
// DebugLogger.swift
import Foundation

class DebugLogger {
    static let shared = DebugLogger()
    
    // Set this to false before TestFlight!
    private let isDebugMode = true
    
    // MARK: - Debug Prints
    func debug(_ message: String, category: String = "DEBUG") {
        guard isDebugMode else { return }
        print("🐛 [\(category)] \(message)")
    }
    
    func info(_ message: String, category: String = "INFO") {
        guard isDebugMode else { return }
        print("ℹ️ [\(category)] \(message)")
    }
    
    func success(_ message: String, category: String = "SUCCESS") {
        guard isDebugMode else { return }
        print("✅ [\(category)] \(message)")
    }
    
    func warning(_ message: String, category: String = "WARNING") {
        guard isDebugMode else { return }
        print("⚠️ [\(category)] \(message)")
    }
    
    // MARK: - Category Specific
    func auth(_ message: String) {
        debug(message, category: "AUTH")
    }
    
    func quota(_ message: String) {
        debug(message, category: "QUOTA")
    }
    
    func network(_ message: String) {
        debug(message, category: "NETWORK")
    }
    
    func ai(_ message: String) {
        debug(message, category: "AI")
    }
    
    func ui(_ message: String) {
        debug(message, category: "UI")
    }
    
    func payment(_ message: String) {
        debug(message, category: "PAYMENT")
    }
}
```

### **Updated AuthViewModel (With error logging)**

```swift
// AuthViewModel.swift - Updated with error logging
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var user: User?
    
    private let supabase = SupabaseService.shared
    
    // MARK: - Email/Password Sign Up
    func signUp(email: String, password: String) async {
        DebugLogger.shared.auth("Starting sign up for email: \(email)")
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await supabase.auth.signUp(
                email: email,
                password: password
            )
            
            DebugLogger.shared.success("Sign up successful for: \(email)")
            
            if let user = response.user {
                self.user = user
                self.isAuthenticated = true
                AnalyticsEvents.signupCompleted(method: "email")
            }
            
            isLoading = false
        } catch {
            ErrorLogger.shared.logAuthError(error, action: "sign_up")
            self.errorMessage = handleAuthError(error)
            DebugLogger.shared.warning("Sign up failed: \(error.localizedDescription)")
            isLoading = false
        }
    }
    
    // MARK: - Email/Password Sign In
    func signIn(email: String, password: String) async {
        DebugLogger.shared.auth("Starting sign in for email: \(email)")
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await supabase.auth.signIn(
                email: email,
                password: password
            )
            
            DebugLogger.shared.success("Sign in successful for: \(email)")
            
            self.user = response.user
            self.isAuthenticated = true
            AnalyticsEvents.signupCompleted(method: "email")
            
            isLoading = false
        } catch {
            ErrorLogger.shared.logAuthError(error, action: "sign_in")
            self.errorMessage = handleAuthError(error)
            DebugLogger.shared.warning("Sign in failed: \(error.localizedDescription)")
            isLoading = false
        }
    }
    
    // MARK: - Apple Sign In
    func signInWithApple() async {
        DebugLogger.shared.auth("Starting Apple Sign In")
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await supabase.auth.signInWithApple()
            
            DebugLogger.shared.success("Apple Sign In successful")
            
            self.user = response.user
            self.isAuthenticated = true
            AnalyticsEvents.signupCompleted(method: "apple")
            
            isLoading = false
        } catch {
            ErrorLogger.shared.logAuthError(error, action: "apple_sign_in")
            self.errorMessage = handleAuthError(error)
            DebugLogger.shared.warning("Apple Sign In failed: \(error.localizedDescription)")
            isLoading = false
        }
    }
    
    // MARK: - Guest Mode (Not Now)
    func continueAsGuest() {
        DebugLogger.shared.auth("User chose guest mode")
        isAuthenticated = false
        user = nil
        AnalyticsEvents.signupCompleted(method: "guest")
    }
    
    // MARK: - Sign Out
    func signOut() async {
        DebugLogger.shared.auth("Starting sign out")
        
        do {
            try await supabase.auth.signOut()
            DebugLogger.shared.success("Sign out successful")
            
            isAuthenticated = false
            user = nil
        } catch {
            ErrorLogger.shared.logAuthError(error, action: "sign_out")
            errorMessage = "Failed to sign out"
            DebugLogger.shared.warning("Sign out failed: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Error Handling
    private func handleAuthError(_ error: Error) -> String {
        if let authError = error as? AuthError {
            switch authError {
            case .invalidCredentials:
                return "Invalid email or password"
            case .emailAlreadyRegistered:
                return "Email already registered"
            case .weakPassword:
                return "Password is too weak"
            case .invalidEmail:
                return "Invalid email format"
            default:
                return "Authentication failed"
            }
        }
        return "An unexpected error occurred"
    }
    
    // MARK: - Validation Rules
    func validateEmail(_ email: String) -> Bool {
        let emailRegex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    func validatePassword(_ password: String) -> Bool {
        return password.count >= 8
    }
}
```

### **Updated QuotaManager (With debug prints)**

```swift
// QuotaManager.swift - Updated with debug prints
@MainActor
class QuotaManager: ObservableObject {
    static let shared = QuotaManager()
    
    @Published var dailyQuotaUsed: Int = 0
    @Published var dailyQuotaLimit: Int = 3 // 3 daily limit for Fortunia
    @Published var isPremiumUser: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let supabase = SupabaseService.shared
    
    // MARK: - Quota Check & Consume
    func checkAndConsumeQuota() async throws -> QuotaInfo {
        DebugLogger.shared.quota("Checking quota for user...")
        
        let userState = AuthService.shared.userState
        
        do {
            let quotaInfo = try await supabase.consumeQuota(
                userId: userState.isAuthenticated ? userState.identifier : nil,
                deviceId: userState.isAuthenticated ? nil : userState.identifier,
                isPremium: isPremiumUser
            )
            
            DebugLogger.shared.success("Quota consumed: \(quotaInfo.quotaUsed)/\(quotaInfo.quotaLimit)")
            
            // Update local state
            await updateFromBackendResponse(
                quotaUsed: quotaInfo.quotaUsed,
                quotaLimit: quotaInfo.quotaLimit,
                isPremium: quotaInfo.isPremium
            )
            
            return quotaInfo
        } catch {
            ErrorLogger.shared.logQuotaError(error, userId: userState.identifier, deviceId: userState.identifier)
            DebugLogger.shared.warning("Quota check failed: \(error.localizedDescription)")
            throw error
        }
    }
    
    // MARK: - Can Process Check
    func canProcessReading() -> Bool {
        DebugLogger.shared.quota("Checking if user can process reading...")
        
        if isPremiumUser {
            DebugLogger.shared.quota("Premium user - unlimited access")
            return true // Premium users bypass all limits
        }
        
        let canProcess = dailyQuotaUsed < dailyQuotaLimit
        DebugLogger.shared.quota("Can process: \(canProcess) (used: \(dailyQuotaUsed)/\(dailyQuotaLimit))")
        
        return canProcess
    }
    
    // MARK: - Quota Reset (Midnight UTC)
    private func resetDailyQuotaIfNeeded() {
        let today = getLocalMidnightDate()
        let lastReset = UserDefaults.standard.string(forKey: "last_quota_reset") ?? ""
        
        if lastReset != today {
            DebugLogger.shared.quota("Resetting daily quota for new day: \(today)")
            dailyQuotaUsed = 0
            UserDefaults.standard.set(today, forKey: "last_quota_reset")
            UserDefaults.standard.set(dailyQuotaUsed, forKey: "daily_quota_used")
        }
    }
    
    private func getLocalMidnightDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone.current
        return formatter.string(from: Date())
    }
    
    // MARK: - Premium Status
    func refreshPremiumStatus() async {
        DebugLogger.shared.quota("Refreshing premium status...")
        
        do {
            let hasActiveSubscription = await AdaptyService.shared.hasActiveSubscription()
            
            if isPremiumUser != hasActiveSubscription {
                DebugLogger.shared.quota("Premium status changed: \(isPremiumUser) -> \(hasActiveSubscription)")
                isPremiumUser = hasActiveSubscription
                UserDefaults.standard.set(isPremiumUser, forKey: "is_premium_user")
                objectWillChange.send()
            } else {
                DebugLogger.shared.quota("Premium status unchanged: \(isPremiumUser)")
            }
        } catch {
            ErrorLogger.shared.logQuotaError(error, userId: nil, deviceId: nil)
            DebugLogger.shared.warning("Premium status refresh failed: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Computed Properties
    var remainingQuota: Int {
        if isPremiumUser {
            return Int.max // Unlimited
        }
        return max(0, dailyQuotaLimit - dailyQuotaUsed)
    }
    
    var hasQuotaLeft: Bool {
        if isPremiumUser {
            return true
        }
        return remainingQuota > 0
    }
    
    var quotaDisplayText: String {
        if isPremiumUser {
            return "Unlimited"
        }
        return "\(dailyQuotaUsed)/\(dailyQuotaLimit)"
    }
    
    var shouldShowQuotaWarning: Bool {
        return !isPremiumUser && remainingQuota <= 1
    }
    
    var quotaWarningMessage: String {
        if remainingQuota == 1 {
            return "⚠️ Only 1 reading left today!"
        }
        return ""
    }
}
```

### **Updated SupabaseService (With network errors)**

```swift
// SupabaseService.swift - Updated with network error logging
class SupabaseService: ObservableObject {
    private let supabase = SupabaseClient(
        supabaseURL: URL(string: Config.supabaseURL)!,
        supabaseKey: Config.supabaseAnonKey
    )
    
    func processFaceReading(image: UIImage, culturalOrigin: String) async throws -> FortuneResult {
        DebugLogger.shared.ai("Starting face reading processing for cultural origin: \(culturalOrigin)")
        
        do {
            let imageUrl = try await uploadImage(image)
            DebugLogger.shared.network("Image uploaded successfully: \(imageUrl)")
            
            let response = try await supabase.functions.invoke(
                "process-face-reading",
                parameters: [
                    "imageUrl": imageUrl,
                    "userId": getCurrentUserId(),
                    "culturalOrigin": culturalOrigin
                ]
            )
            
            DebugLogger.shared.success("Face reading completed successfully")
            
            let result = try JSONDecoder().decode(FortuneResult.self, from: response.data)
            return result
        } catch {
            ErrorLogger.shared.logNetworkError(error, endpoint: "process-face-reading")
            DebugLogger.shared.warning("Face reading failed: \(error.localizedDescription)")
            throw error
        }
    }
    
    private func uploadImage(_ image: UIImage) async throws -> String {
        DebugLogger.shared.network("Starting image upload...")
        
        do {
            // Compress image
            let compressedImage = image.jpegData(compressionQuality: 0.8)!
            DebugLogger.shared.network("Image compressed: \(compressedImage.count) bytes")
            
            // Upload to Supabase Storage
            let fileName = "\(UUID().uuidString).jpg"
            let filePath = "readings/\(fileName)"
            
            try await supabase.storage
                .from("fortune-images-prod")
                .upload(path: filePath, file: compressedImage)
            
            let imageUrl = "\(Config.supabaseURL)/storage/v1/object/public/fortune-images-prod/\(filePath)"
            DebugLogger.shared.success("Image uploaded: \(imageUrl)")
            
            return imageUrl
        } catch {
            ErrorLogger.shared.logNetworkError(error, endpoint: "image-upload")
            DebugLogger.shared.warning("Image upload failed: \(error.localizedDescription)")
            throw error
        }
    }
}
```

### **Pre-TestFlight Cleanup**

⚠️ **CRITICAL: Before TestFlight submission:**

1. **Set DebugLogger.isDebugMode = false**
2. **Remove all print() statements from production code**
3. **Verify no API keys are hardcoded in source code**
4. **Test with debug logging disabled**

```swift
// DebugLogger.swift - This change is sufficient before TestFlight
class DebugLogger {
    static let shared = DebugLogger()
    
    // Set this to false before TestFlight!
    private let isDebugMode = false // ← This change will stop all debug prints
    
    // All debug functions will automatically not work
    func debug(_ message: String, category: String = "DEBUG") {
        guard isDebugMode else { return } // ← This line will stop debug prints
        print("🐛 [\(category)] \(message)")
    }
    
    // ... other functions will remain the same
}
```

**Additional Cleanup Checklist:**
- [ ] Remove all `print()` statements from production code
- [ ] Set `DebugLogger.isDebugMode = false`
- [ ] Verify no API keys in source code
- [ ] Test app with debug logging disabled
- [ ] Check for any hardcoded test values
- [ ] Ensure all error messages are user-friendly

---

## 7. API ENDPOINTS

### **Supabase Edge Functions**

```typescript
// POST /process-face-reading
export async function processFaceReading(request: Request) {
  const { imageUrl, userId, culturalOrigin } = await request.json();
  
  // 1. Check daily quota
  const quotaUsed = await checkDailyQuota(userId);
  if (quotaUsed >= 3) {
    return new Response(JSON.stringify({ error: "Daily quota exceeded" }), {
      status: 429
    });
  }
  
  // 2. Process image with fal.ai
  const analysisResult = await processWithFalAI(imageUrl);
  
  // 3. Generate fortune text with Gemini
  const fortuneText = await generateFortuneText(analysisResult, culturalOrigin);
  
  // 4. Create share card
  const shareCardUrl = await createShareCard(fortuneText, analysisResult);
  
  // 5. Save to database
  await saveReading(userId, 'face', culturalOrigin, imageUrl, fortuneText, shareCardUrl);
  
  // 6. Increment quota
  await incrementDailyQuota(userId);
  
  return new Response(JSON.stringify({
    success: true,
    result: fortuneText,
    shareCardUrl: shareCardUrl
  }));
}

// POST /process-palm-reading
export async function processPalmReading(request: Request) {
  // Similar flow for palm reading
}

// POST /process-tarot-reading
export async function processTarotReading(request: Request) {
  // Similar flow for tarot reading
}

// GET /user-quota
export async function getUserQuota(request: Request) {
  const { userId } = await request.json();
  const quota = await checkDailyQuota(userId);
  return new Response(JSON.stringify({ quota }));
}
```

### **Client-Side API Service**

```swift
// SupabaseService.swift
class SupabaseService: ObservableObject {
    private let supabase = SupabaseClient(
        supabaseURL: URL(string: Config.supabaseURL)!,
        supabaseKey: Config.supabaseAnonKey
    )
    
    func processFaceReading(image: UIImage, culturalOrigin: String) async throws -> FortuneResult {
        // 1. Upload image to Supabase Storage
        let imageUrl = try await uploadImage(image)
        
        // 2. Call Edge Function
        let response = try await supabase.functions.invoke(
            "process-face-reading",
            parameters: [
                "imageUrl": imageUrl,
                "userId": getCurrentUserId(),
                "culturalOrigin": culturalOrigin
            ]
        )
        
        // 3. Parse response
        let result = try JSONDecoder().decode(FortuneResult.self, from: response.data)
        return result
    }
    
    private func uploadImage(_ image: UIImage) async throws -> String {
        // Compress image
        let compressedImage = image.jpegData(compressionQuality: 0.8)!
        
        // Upload to Supabase Storage
        let fileName = "\(UUID().uuidString).jpg"
        let filePath = "readings/\(fileName)"
        
        try await supabase.storage
            .from("fortune-images-prod")
            .upload(path: filePath, file: compressedImage)
        
        return "\(Config.supabaseURL)/storage/v1/object/public/fortune-images-prod/\(filePath)"
    }
}
```

### **Authentication Flow (Detailed)**

```swift
// AuthViewModel.swift
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var user: User?
    
    private let supabase = SupabaseService.shared
    
    // MARK: - Email/Password Sign Up
    func signUp(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await supabase.auth.signUp(
                email: email,
                password: password
            )
            
            if let user = response.user {
                self.user = user
                self.isAuthenticated = true
                AnalyticsEvents.signupCompleted(method: "email")
            }
            
            isLoading = false
        } catch {
            errorMessage = handleAuthError(error)
            isLoading = false
        }
    }
    
    // MARK: - Email/Password Sign In
    func signIn(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await supabase.auth.signIn(
                email: email,
                password: password
            )
            
            self.user = response.user
            self.isAuthenticated = true
            AnalyticsEvents.signupCompleted(method: "email")
            
            isLoading = false
        } catch {
            errorMessage = handleAuthError(error)
            isLoading = false
        }
    }
    
    // MARK: - Apple Sign In
    func signInWithApple() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await supabase.auth.signInWithApple()
            
            self.user = response.user
            self.isAuthenticated = true
            AnalyticsEvents.signupCompleted(method: "apple")
            
            isLoading = false
        } catch {
            errorMessage = handleAuthError(error)
            isLoading = false
        }
    }
    
    // MARK: - Guest Mode (Not Now)
    func continueAsGuest() {
        isAuthenticated = false
        user = nil
        AnalyticsEvents.signupCompleted(method: "guest")
    }
    
    // MARK: - Sign Out
    func signOut() async {
        do {
            try await supabase.auth.signOut()
            isAuthenticated = false
            user = nil
        } catch {
            errorMessage = "Failed to sign out"
        }
    }
    
    // MARK: - Error Handling
    private func handleAuthError(_ error: Error) -> String {
        if let authError = error as? AuthError {
            switch authError {
            case .invalidCredentials:
                return "Invalid email or password"
            case .emailAlreadyRegistered:
                return "Email already registered"
            case .weakPassword:
                return "Password is too weak"
            case .invalidEmail:
                return "Invalid email format"
            default:
                return "Authentication failed"
            }
        }
        return "An unexpected error occurred"
    }
    
    // MARK: - Validation Rules
    func validateEmail(_ email: String) -> Bool {
        let emailRegex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    func validatePassword(_ password: String) -> Bool {
        return password.count >= 8
    }
}
```

---

## 8. SECURITY & PRIVACY

### **Data Protection**

```swift
// Privacy-first image processing
class ImageProcessor {
    func processImageOnDevice(_ image: UIImage) -> ProcessedImage {
        // Use Vision Framework for face detection (on-device)
        let faceDetectionRequest = VNDetectFaceRectanglesRequest()
        let handler = VNImageRequestHandler(cgImage: image.cgImage!)
        
        try? handler.perform([faceDetectionRequest])
        
        // Extract features without uploading
        let features = extractFacialFeatures(from: faceDetectionRequest.results)
        
        return ProcessedImage(features: features, originalImage: image)
    }
    
    func shouldUploadToCloud(_ image: UIImage) -> Bool {
        // Only upload if user explicitly requests cloud processing
        return UserDefaults.standard.bool(forKey: "allowCloudProcessing")
    }
}
```

### **Encryption & Storage**

```swift
// Secure data storage
class SecureStorage {
    private let keychain = Keychain(service: "com.fortunia.app")
    
    func storeUserData(_ data: UserData) {
        // Store sensitive data in Keychain
        keychain["userToken"] = data.authToken
        keychain["birthInfo"] = data.birthInfo.encryptedJSON
    }
    
    func retrieveUserData() -> UserData? {
        guard let token = keychain["userToken"],
              let birthInfo = keychain["birthInfo"] else { return nil }
        
        return UserData(
            authToken: token,
            birthInfo: BirthInfo.fromEncryptedJSON(birthInfo)
        )
    }
}
```

### **Privacy Controls**

```swift
// Privacy settings
struct PrivacySettings {
    var allowCloudProcessing: Bool = false
    var allowAnalytics: Bool = true
    var allowPushNotifications: Bool = false
    var dataRetentionDays: Int = 30
    
    func exportUserData() -> Data {
        // GDPR compliance - export all user data
        let userData = [
            "readings": getAllReadings(),
            "profile": getUserProfile(),
            "preferences": getPreferences()
        ]
        
        return try! JSONSerialization.data(withJSONObject: userData)
    }
    
    func deleteAllUserData() {
        // GDPR compliance - delete all user data
        deleteAllReadings()
        deleteUserProfile()
        clearKeychain()
    }
}
```

---

## 9. PERFORMANCE REQUIREMENTS

### **Response Time Targets**

```swift
// Performance benchmarks
struct PerformanceTargets {
    static let appLaunchTime: TimeInterval = 3.0      // Max 3 seconds
    static let readingGeneration: TimeInterval = 10.0 // Max 10 seconds
    static let imageUpload: TimeInterval = 5.0        // Max 5 seconds
    static let shareCardCreation: TimeInterval = 2.0  // Max 2 seconds
    static let memoryUsage: Int = 100 * 1024 * 1024  // Max 100MB
}
```

### **Optimization Strategies**

```swift
// Image optimization
class ImageOptimizer {
    func optimizeForUpload(_ image: UIImage) -> Data {
        // Resize to max 1024x1024
        let resizedImage = image.resized(to: CGSize(width: 1024, height: 1024))
        
        // Compress with quality 0.8
        return resizedImage.jpegData(compressionQuality: 0.8)!
    }
    
    func optimizeForDisplay(_ image: UIImage) -> UIImage {
        // Lazy loading with placeholder
        return image.resized(to: CGSize(width: 300, height: 300))
    }
}

// Memory management
class MemoryManager {
    func clearImageCache() {
        // Clear Kingfisher cache when memory pressure
        KingfisherManager.shared.cache.clearMemoryCache()
    }
    
    func optimizeMemoryUsage() {
        // Remove unused view controllers
        // Clear temporary data
        // Compress stored images
    }
}
```

---

## 10. MULTI-LANGUAGE IMPLEMENTATION

### **Localization Setup**

```swift
// Localizable.strings (English)
"welcome_title" = "Discover Your Fortune";
"auth_signup" = "Sign Up";
"auth_apple" = "Continue with Apple";
"auth_not_now" = "Not Now";
"disclaimer_text" = "For entertainment purposes only. Not a substitute for professional advice.";
"face_reading_title" = "Face Reading";
"palm_reading_title" = "Palm Reading";
"tarot_reading_title" = "Tarot Reading";
"coffee_reading_title" = "Coffee Reading";

// Localizable.strings (Spanish)
"welcome_title" = "Descubre Tu Fortuna";
"auth_signup" = "Registrarse";
"auth_apple" = "Continuar con Apple";
"auth_not_now" = "Ahora No";
"disclaimer_text" = "Solo con fines de entretenimiento. No sustituye el asesoramiento profesional.";
"face_reading_title" = "Lectura Facial";
"palm_reading_title" = "Lectura de Palma";
"tarot_reading_title" = "Lectura de Tarot";
"coffee_reading_title" = "Lectura de Café";
```

### **Dynamic Language Switching**

```swift
// Language manager
class LanguageManager: ObservableObject {
    @Published var currentLanguage: String = "en"
    
    func setLanguage(_ language: String) {
        currentLanguage = language
        UserDefaults.standard.set(language, forKey: "selectedLanguage")
        
        // Update Supabase user preference
        updateUserLanguagePreference(language)
    }
    
    func localizedString(_ key: String) -> String {
        return NSLocalizedString(key, comment: "")
    }
}

// Usage in views
struct FortuneCard: View {
    @EnvironmentObject var languageManager: LanguageManager
    
    var body: some View {
        Text(languageManager.localizedString("face_reading_title"))
            .font(AppTypography.heading3)
    }
}
```

---

## 11. DEPLOYMENT STRATEGY

### **Development Phases**

```yaml
Phase 1 (Weeks 1-2): Foundation
  - Project setup + dependencies
  - Color system + typography
  - Firebase + Supabase config
  - Splash + Auth screens
  - Basic navigation

Phase 2 (Weeks 3-4): Core Features
  - Face reading flow
  - Birth info modal
  - Camera integration
  - AI processing (fal.ai + Gemini)
  - Result screen + sharing

Phase 3 (Weeks 5-6): Monetization
  - Adapty integration
  - Daily quota system
  - Paywall UI
  - Analytics events
  - TestFlight beta

Phase 4 (Weeks 7-8): Polish
  - Loading animations
  - Error handling
  - Performance optimization
  - App Store submission
```

### **CI/CD Pipeline**

```yaml
# GitHub Actions workflow
name: Build and Deploy

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  build:
    runs-on: macos-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Xcode
      uses: maxim-lobanov/setup-xcode@v1
      with:
        xcode-version: '15.0'
    
    - name: Build iOS app
      run: |
        xcodebuild -workspace Fortunia.xcworkspace \
                   -scheme Fortunia \
                   -destination 'platform=iOS Simulator,name=iPhone 15' \
                   build
    
    - name: Run tests
      run: |
        xcodebuild test -workspace Fortunia.xcworkspace \
                        -scheme Fortunia \
                        -destination 'platform=iOS Simulator,name=iPhone 15'
    
    - name: Deploy to TestFlight
      if: github.ref == 'refs/heads/main'
      run: |
        # Deploy to TestFlight
        fastlane beta
```

---

## 12. MONITORING & ANALYTICS

### **Firebase Analytics Events**

```swift
// Analytics events
struct AnalyticsEvents {
    static func appOpened() {
        Analytics.logEvent("app_open", parameters: nil)
    }
    
    static func signupCompleted(method: String) {
        Analytics.logEvent("signup_completed", parameters: [
            "method": method
        ])
    }
    
    static func readingRequested(type: String, culturalOrigin: String) {
        Analytics.logEvent("reading_requested", parameters: [
            "type": type,
            "cultural_origin": culturalOrigin
        ])
    }
    
    static func readingCompleted(type: String, isPremium: Bool) {
        Analytics.logEvent("reading_completed", parameters: [
            "type": type,
            "is_premium": isPremium
        ])
    }
    
    static func shareTapped(platform: String) {
        Analytics.logEvent("share_tapped", parameters: [
            "platform": platform
        ])
    }
    
    static func subscriptionPurchased(tier: String) {
        Analytics.logEvent("subscription_purchased", parameters: [
            "tier": tier
        ])
    }
}
```

### **Performance Monitoring**

```swift
// Performance tracking
class PerformanceMonitor {
    static func trackAppLaunch() {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let launchTime = CFAbsoluteTimeGetCurrent() - startTime
            Analytics.logEvent("app_launch_time", parameters: [
                "duration": launchTime
            ])
        }
    }
    
    static func trackReadingGeneration(type: String, startTime: CFAbsoluteTime) {
        let duration = CFAbsoluteTimeGetCurrent() - startTime
        Analytics.logEvent("reading_generation_time", parameters: [
            "type": type,
            "duration": duration
        ])
    }
}
```

---

## 13. LEGAL & COMPLIANCE

### **Required Legal Pages**

```markdown
# Privacy Policy (AI-Generated)
- Data collection (email, birth info, photos)
- Data storage (Supabase)
- AI usage (fal.ai, Gemini)
- User rights (GDPR, CCPA)
- Contact information

# Terms of Service (AI-Generated)
- App usage terms
- Subscription terms
- User responsibilities
- Limitation of liability
- Dispute resolution

# Support Page
- FAQ section
- Contact email: support@fortunia.app
- Response time: 24-48 hours
- Bug reporting process
```

### **App Store Compliance**

```swift
// App Store metadata
struct AppStoreMetadata {
    static let appName = "Fortunia"
    static let subtitle = "AI Fortune Reading & Spiritual Guidance"
    static let description = """
    Discover your fortune through ancient divination practices reimagined for the digital age. 
    
    Features:
    • Face Reading (Chinese physiognomy)
    • Palm Reading (Traditional palmistry)
    • Tarot Cards (Classic tarot spreads)
    • Coffee Reading (Traditional tasseography)
    
    FORTUNIA is for entertainment purposes only. Results are AI-generated and should not be used as professional advice.
    """
    static let keywords = "fortune, tarot, astrology, face reading, palm reading, spiritual, guidance"
    static let category = "Lifestyle"
    static let ageRating = "4+" // 18+ for premium features
}
```

### **Disclaimer Implementation**

```swift
// Legal disclaimer (required on every result screen)
struct LegalDisclaimer: View {
    var body: some View {
        VStack(spacing: 8) {
            Text("For entertainment purposes only.")
                .font(AppTypography.caption)
                .foregroundColor(.textSecondary)
            
            Text("Not a substitute for professional, medical, legal, or financial advice.")
                .font(AppTypography.caption)
                .foregroundColor(.textSecondary)
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}
```

---

## 🎯 IMPLEMENTATION CHECKLIST

### **Week 1-2: Foundation**
- [ ] Xcode project setup
- [ ] SPM dependencies (Supabase, Adapty, Firebase)
- [ ] Assets.xcassets color system
- [ ] Typography + Spacing files
- [ ] Firebase configuration
- [ ] Supabase project + schema
- [ ] Splash screen + Auth screen
- [ ] Basic TabView navigation

### **Week 3-4: Core Features**
- [ ] Home screen UI
- [ ] Birth info modal
- [ ] Camera integration
- [ ] Image compression + upload
- [ ] fal.ai API integration
- [ ] Gemini API integration
- [ ] Result screen + disclaimer
- [ ] Share card generation

### **Week 5-6: Monetization**
- [ ] Adapty integration
- [ ] Daily quota system (3 free/day)
- [ ] Paywall UI
- [ ] Subscription management
- [ ] Firebase Analytics events
- [ ] Push notifications setup
- [ ] TestFlight beta

### **Week 7-8: Polish & Launch**
- [ ] Loading animations
- [ ] Error handling
- [ ] Performance optimization
- [ ] Multi-language testing
- [ ] App Store assets
- [ ] Legal pages (Privacy, Terms)
- [ ] App Store submission

---

**Document Approval:**
- [ ] Technical Lead
- [ ] iOS Developer
- [ ] Product Manager

**Last Updated:** October 24, 2025

---

*"The best way to predict the future is to create it." - Peter Drucker*

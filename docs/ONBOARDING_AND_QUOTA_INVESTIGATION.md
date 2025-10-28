# Onboarding & Quota Investigation Report

**Date:** January 27, 2025  
**Status:** 🔍 **DIAGNOSTIC ONLY - No Fixes Applied**

---

## Investigation Summary

Two issues identified in guest flow:
1. ❓ **Onboarding repeats after completion**
2. ❓ **Quota counter doesn't update after reading**

**Method:** Code trace analysis only (no modifications made)

---

## Issue 1: Onboarding Repetition

### Current Flow Analysis

#### ✅ What Works
1. **BirthInfoModalView.swift** (lines 214-220): Successfully saves `onboarding_completed = true` to database
2. **OnboardingService.swift** (lines 25-51): Has `hasCompletedOnboarding()` method to check status
3. **FaceReadingIntroView.swift** (lines 68-112): Checks onboarding status on view appear

#### ❌ What's Wrong
**Location:** `FaceReadingIntroView.swift` line 67-69  
**Issue:** Calls `checkOnboardingStatus()` inside `.onAppear` modifier

**Problem Flow:**
```swift
.onAppear {
    checkOnboardingStatus()  // ← Checks database every time view appears
}
```

### Root Cause Analysis

#### Scenario: Guest User Path
1. **First time:** User starts face reading → `checkOnboardingStatus()` → returns `false` → shows BirthInfoModal ✅
2. **BirthInfoModal completes:** Sets `onboarding_completed = true` in database ✅
3. **User takes photo:** Goes through photo capture → reading processing ✅
4. **User returns to home:** Goes back to HomeView ✅
5. **User taps face reading again:** FaceReadingIntroView appears → `.onAppear` fires
6. **checkOnboardingStatus() called AGAIN:** Queries database for `onboarding_completed`

**The Issue:**
- For **authenticated users:** Database query succeeds, returns `true`, skips modal ✅
- For **guest users:** May have RLS policy blocking, or guest `user_id` not found

### Potential Causes

#### Cause 1: RLS Policy Blocks Guest Query
**Location:** Supabase database RLS on `users` table  
**Evidence:** Guest users have no JWT token  
**Current RLS Policy:**
```sql
CREATE POLICY "Users can view their own profile"
ON users FOR SELECT USING (auth.uid() = id);  -- ❌ Guests have no auth.uid()
```

**Impact:**
- `hasCompletedOnboarding()` queries `users` table
- RLS blocks guest users (no `auth.uid()`)
- Query fails or returns empty array
- `hasCompletedOnboarding` defaults to `false`
- Modal shows again

#### Cause 2: Guest user_id Not Persisted
**Location:** `AuthViewModel.continueAsGuest()` (lines 141-176)  
**Check:** Does guest user get created BEFORE onboarding?  
**Evidence needed:**
- Is `create_guest_user()` called before first reading?
- Is `guest_user_id` stored in UserDefaults?

### Diagnostic Clues Needed

From logs, look for:
```
🧩 [ONBOARDING] User {uuid} hasCompletedOnboarding: false  ← Should be true after first completion
🧩 [ONBOARDING] ❌ [STEP 3/3] User not found in database  ← Guest user not created
🧩 [ONBOARDING] Database query completed. Found 0 user(s)  ← RLS blocking
```

**If you see:**
- "User not found" → Guest user not created
- "Found 0 user(s)" → RLS blocking query
- Always returns false → RLS or database issue

---

## Issue 2: Quota Counter Not Updating

### Current Flow Analysis

#### ✅ What Works
1. **Edge Functions** (lines 154-162): Quota is consumed server-side via `consume_quota()` RPC
2. **QuotaManager.swift** (line 96): Has `@Published var quotaRemaining` for UI updates

#### ❌ What's Missing
**Issue:** No quota refresh after reading completion

**Flow:**
1. User completes reading
2. Edge Function calls `consume_quota()` (server-side) ✅
3. Reading returns to result view
4. User navigates back to Home
5. **HomeView doesn't refresh quota** ❌

### Root Cause

**Location:** `ReadingResultView.swift`  
**Missing:** No call to refresh quota after reading completes

**Expected Flow (Missing):**
```swift
ReadingResultView.onAppear {
    // After reading completes and quota consumed:
    QuotaManager.shared.fetchQuota()  // ← Missing!
    // Or trigger UI refresh
}
```

**Current QuotaCard Implementation:**
- `MainTabView.swift` (lines 457-515): Has `.task { loadQuotaAsyncIfNeeded() }` 
- **BUT:** 5-minute cooldown prevents refresh
- **AND:** No refresh triggered after reading completes

### Specific Problems

#### Problem 1: Cooldown Prevents Refresh
**Location:** `MainTabView.swift` lines 476-479  
```swift
if Date().timeIntervalSince(lastLoadTime) < 300 {  // 5-minute cooldown
    return  // ← Skips refresh if loaded within 5 minutes
}
```

**Impact:**
- User starts at quota = 3
- Reads reading (quota consumed to 2 server-side)
- Returns to home within 5 minutes
- QuotaCard shows "skipping fetch (within cooldown)"
- UI still shows 3 instead of 2

#### Problem 2: No Notification/Trigger
**Location:** Anywhere after Edge Function completes  
**Missing:** Trigger to refresh quota UI

**Available but unused:**
- `QuotaCard.refreshQuota()` (lines 518-548) exists but never called
- Edge Functions consume quota successfully
- iOS app doesn't know to refresh

### Diagnostic Clues Needed

From logs, look for:
```
🧩 [ONBOARDING] ✅ [STEP 4/4] All updates completed successfully  ← Birth data saved
🧩 [ONBOARDING] User {uuid} hasCompletedOnboarding: {true/false}  ← Is it persisted?
QuotaCard: Skipping fetch (within cooldown period)  ← Prevents refresh
```

---

## Where Fixes Will Be Needed

### Onboarding Fix (Likely)

**File:** Supabase RLS policies  
**Location:** `supabase/migrations/fortunia.sql` lines 75-93  
**Action:** Add guest-friendly RLS policy:
```sql
-- Allow guest users to read their own profile
CREATE POLICY "Guest users can read their profile"
ON users FOR SELECT
TO anon
USING (id IN (
  SELECT id FROM users WHERE device_id IS NOT NULL
));
```

**OR** Add to `currentUserId` fallback:
- Already has guest_user_id fallback (lines 58-64 in AuthService.swift)
- But query may still fail if RLS blocks

### Quota Fix (Definite)

**File 1:** `ReadingResultView.swift` or wherever reading completes  
**Action:** Add quota refresh trigger:
```swift
.onAppear {
    // Refresh quota after reading completes
    Task {
        try? await QuotaManager.shared.fetchQuota(forceRefresh: true)
    }
}
```

**File 2:** `QuotaCard.swift` (in MainTabView) lines 457-514  
**Action:** Either:
1. Reduce cooldown from 5 minutes to 30 seconds, OR
2. Add notification listener for when readings complete

**File 3:** Edge Functions or iOS after reading  
**Action:** Post notification after quota consumption:
```swift
NotificationCenter.default.post(name: .quotaUpdated, object: nil)
```

---

## Summary Table

| Issue | Root Cause | File(s) to Fix | Priority |
|-------|------------|----------------|----------|
| Onboarding repeats | RLS blocks guest users from reading `users.onboarding_completed` | `supabase RLS policies` + possibly `AuthService` | 🔴 High |
| Quota doesn't update | No refresh triggered after edge function consumes quota | `ReadingResultView.swift` or `QuotaCard` | 🟡 Medium |
| Cooldown too long | 5-minute cooldown prevents timely updates | `MainTabView.swift` line 477 | 🟢 Low |

---

## Diagnostic Actions Needed

To confirm findings, run app and collect logs:

1. **Onboarding logs:**
```
🧩 [ONBOARDING] Starting save process
🧩 [ONBOARDING] ✅ [STEP 3/4] Onboarding marked as complete
🧩 [AUTH] currentUserId: Guest user_id from UserDefaults: {uuid}
🧩 [FACE READING INTRO] Calling OnboardingService.hasCompletedOnboarding...
🧩 [FACE READING INTRO] ✅ OnboardingService returned: {true/false}
```

2. **Quota logs:**
```
Edge Function: Consume quota for user {uuid}
QuotaCard: Skipping fetch (within cooldown period)
QuotaCard: Quota fetched: {number}
```

**Expected Outcomes:**
- If onboarding logs show "returned: false" after completion → RLS issue
- If quota logs show "skipping fetch" immediately after reading → cooldown issue
- If quota logs never appear after reading → refresh trigger missing

---

## Notes

✅ **Code changes made:** None (investigation only)  
✅ **Diagnostic logs added:** Yes (previous task)  
✅ **Build status:** Clean (no errors)

**Next step:** Run app, collect logs, share findings for targeted fixes.



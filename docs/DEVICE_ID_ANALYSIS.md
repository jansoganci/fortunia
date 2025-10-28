# Device ID Tracking - Codebase Analysis

## Executive Summary

The Device ID Tracking implementation plan has **been partially implemented** but has **critical gaps** that prevent it from working correctly. This analysis identifies the issues and provides recommendations.

---

## What's Already Implemented ✅

### 1. **Database Migration** ✅
- ✅ `device_id` column added to `users` table
- ✅ Index created on `device_id`
- ✅ `create_guest_user()` RPC function exists
- ⚠️ **BUT**: The function uses `SECURITY DEFINER` which should work

### 2. **iOS Services** ✅
- ✅ `DeviceIDManager` created and working
- ✅ `AuthService.createGuestUser()` implemented
- ✅ `AuthViewModel.continueAsGuest()` calls guest creation
- ✅ `QuotaManager` uses guest_user_id
- ✅ `AIProcessingService` passes user_id to edge functions

### 3. **Views** ✅
- ✅ `AuthScreen` handles async guest flow
- ✅ Guest button wired up correctly

---

## Critical Issues Found ❌

### 1. **Edge Functions Require JWT Authentication**

**Problem**: All edge functions require a JWT token, which guest users don't have.

**Files Affected**:
- `supabase/functions/process-face-reading/index.ts` (lines 36-56)
- `supabase/functions/process-palm-reading/index.ts` (lines 36-56)
- `supabase/functions/process-coffee-reading/index.ts` (lines 36-56)
- `supabase/functions/get_quota/index.ts` (lines 27-37)
- `supabase/functions/consume_quota/index.ts` (lines 27-37)

**Current Code**:
```typescript
// This WILL FAIL for guests because they have no JWT
const { data: { user }, error: authError } = await supabaseClient.auth.getUser()
if (authError || !user) {
  return new Response(JSON.stringify({ error: 'Unauthorized' }), { 
    status: 401
  })
}
```

**Impact**: 
- Guest users cannot process readings
- 401 Unauthorized errors will occur

### 2. **FunctionService Requires Session**

**Problem**: `FunctionService.invokeEdgeFunction()` checks for a session, which guests don't have.

**File**: `fortunia/fortunia/Services/Function/FunctionService.swift` (lines 75-79)

**Current Code**:
```swift
guard let session = try? await supabase.auth.session else {
    print("🔥 [EDGE FUNCTION] ❌ No valid session!")
    throw URLError(.userAuthenticationRequired)  // This will fail for guests
}
```

**Impact**:
- Guests cannot call ANY edge functions
- App will crash or show errors

### 3. **Database RPC Functions Work (But Not Used Correctly)**

**Status**: ✅ The database RPC functions `get_quota()` and `consume_quota()` are `SECURITY DEFINER` and should work for guests.

**However**, they still use the OLD approach with `device_id` parameter:
```sql
CREATE OR REPLACE FUNCTION get_quota(
  p_user_id UUID DEFAULT NULL,
  p_device_id TEXT DEFAULT NULL  -- ❌ Still supports old approach
)
```

**Issue**: The implementation plan wants to use ONLY `p_user_id` for a unified approach, but the database functions still support `device_id`.

### 4. **RLS Policies Block Guest Users**

**Problem**: Row Level Security policies require `auth.uid()` which guests don't have.

**File**: `supabase/migrations/fortunia.sql` (lines 75-93)

**Current Policies**:
```sql
CREATE POLICY "Users can view their own profile"
ON users FOR SELECT USING (auth.uid() = id);  -- ❌ Guests have no auth.uid()

CREATE POLICY "Users can only access their own readings"
ON readings FOR ALL USING (auth.uid() = user_id);  -- ❌ Blocks guests
```

**Impact**:
- Guest users cannot read their own data
- Quota tracking will fail
- Readings cannot be saved

---

## Root Cause Analysis

### Why This Doesn't Work

The implementation plan assumes a "unified user_id approach" where:
1. Guest users get a real `user_id` (UUID) in the `users` table
2. Everything uses `user_id` only
3. No special cases needed

**BUT** the current database schema still uses `device_id` as an alternative parameter in `daily_quotas` table:

```sql
CREATE TABLE daily_quotas (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES users(id),  -- For authenticated users
  device_id TEXT,                      -- ❌ For guests (old approach)
  date DATE,
  free_readings_used INTEGER,
  UNIQUE(user_id, date),
  UNIQUE(device_id, date)
);
```

This is a **conflict**: The plan says "unified approach with user_id only" but the database still tracks guests by device_id separately.

---

## What Needs to Be Fixed

### 1. **Fix Database Functions** (HIGH PRIORITY)

**Action**: Update `get_quota` and `consume_quota` to use ONLY `p_user_id`, not `device_id`.

**New Approach**:
- Guest users get a `user_id` (UUID) from `create_guest_user()`
- All quota functions use `user_id` only
- Remove `device_id` parameter from functions

### 2. **Remove JWT Requirements from Edge Functions** (HIGH PRIORITY)

**Action**: Edge functions should accept optional JWT for authenticated users, but allow `user_id` without JWT for guests.

**Change Required**:
- Make JWT validation optional
- Validate `user_id` against the database
- Allow service role for guest operations

### 3. **Fix RLS Policies** (HIGH PRIORITY)

**Action**: Update RLS policies to allow guest users to access their own data.

**Options**:
- Option A: Disable RLS for `daily_quotas` (use only SECURITY DEFINER functions)
- Option B: Add policies for guest users using a separate identifier
- Option C: Use SECURITY DEFINER functions exclusively

**Recommended**: Option A for `daily_quotas`, but keep RLS for `users` and `readings`.

### 4. **Update FunctionService** (MEDIUM PRIORITY)

**Action**: Make session check optional for edge function calls from guests.

**Change**: Don't require `session` if `user_id` is provided in parameters.

---

## Recommended Implementation Steps

### Phase 1: Database Updates

1. **Update `get_quota` function**
   - Remove `p_device_id` parameter
   - Use only `p_user_id`
   - Update `daily_quotas` queries to use `user_id` only

2. **Update `consume_quota` function**
   - Remove `p_device_id` parameter
   - Use only `p_user_id`

3. **Update RLS policies**
   - Add policy to allow SECURITY DEFINER functions
   - Or disable RLS on `daily_quotas`

### Phase 2: Edge Functions

1. **Make JWT optional**
   - Check if JWT exists
   - If JWT exists, validate it
   - If no JWT, use service role
   - Validate `user_id` in the request

2. **Update quota edge functions**
   - Remove JWT requirement
   - Use service role for database access

### Phase 3: iOS Code

1. **Update FunctionService**
   - Check if session exists
   - If no session, don't send JWT header
   - Allow edge functions to work without JWT

2. **Test complete flow**
   - Guest creation
   - Quota fetching
   - Reading processing
   - Quota consumption

---

## Current State vs. Target State

### Current State (Broken)
```
Guest User
  ↓
DeviceIDManager → "ABC-123"
  ↓
AuthService.createGuestUser("ABC-123")
  ↓
Database: Creates user with device_id="ABC-123"
  ↓
Returns: UUID "550e..."
  ↓
Store in UserDefaults as "guest_user_id"
  ↓
❌ FunctionService.invokeEdgeFunction() → Checks for session → FAILS
❌ Edge function checks JWT → FAILS
❌ RLS policies block access → FAILS
```

### Target State (Working)
```
Guest User
  ↓
DeviceIDManager → "ABC-123"
  ↓
AuthService.createGuestUser("ABC-123")
  ↓
Database: Creates user with user_id="550e...", device_id="ABC-123"
  ↓
Returns: UUID "550e..."
  ↓
Store in UserDefaults as "guest_user_id"
  ↓
✅ FunctionService.invokeEdgeFunction() → No JWT check for guests
✅ Edge function accepts user_id without JWT
✅ Database functions work with service role
✅ Reading completes successfully
```

---

## Migration Path

### Step 1: Update Database Functions
- Modify `get_quota` to use only `user_id`
- Modify `consume_quota` to use only `user_id`

### Step 2: Update RLS
- Add policies or disable RLS for guests

### Step 3: Update Edge Functions
- Make JWT optional
- Add service role fallback

### Step 4: Update FunctionService
- Skip JWT check for guests

### Step 5: Test
- Guest user creation
- Quota tracking
- Reading processing
- Multiple devices

---

## Files That Need Changes

### Database (Supabase)
- ✅ `supabase/migrations/20250126_add_device_id_to_users.sql` - Already done
- ❌ `supabase/migrations/fortunia.sql` - Need to update RPC functions
- ❌ `supabase/migrations/*.sql` - Need new migration to fix RLS

### Edge Functions
- ❌ `supabase/functions/process-face-reading/index.ts` - Make JWT optional
- ❌ `supabase/functions/process-palm-reading/index.ts` - Make JWT optional
- ❌ `supabase/functions/process-coffee-reading/index.ts` - Make JWT optional
- ❌ `supabase/functions/get_quota/index.ts` - Remove JWT requirement
- ❌ `supabase/functions/consume_quota/index.ts` - Remove JWT requirement

### iOS Code
- ✅ `fortunia/fortunia/Services/DeviceIDManager.swift` - Already done
- ✅ `fortunia/fortunia/Services/Auth/AuthService.swift` - Already done
- ✅ `fortunia/fortunia/ViewModels/AuthViewModel.swift` - Already done
- ✅ `fortunia/fortunia/Services/QuotaManager.swift` - Already done
- ✅ `fortunia/fortunia/Services/AI/AIProcessingService.swift` - Already done
- ❌ `fortunia/fortunia/Services/Function/FunctionService.swift` - Need to make session optional

---

## Conclusion

The implementation is **60% complete** with all iOS code written correctly, but the **backend (database + edge functions) still blocks guest users** due to:
1. JWT authentication requirements
2. RLS policy restrictions
3. Inconsistent database schema

**Recommendation**: Complete the backend fixes (Phases 1-2) before testing the iOS implementation.


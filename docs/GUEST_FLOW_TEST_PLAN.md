# Guest Flow Test Plan - Fortunia App

## Status: Edge Functions Not Yet Deployed

**Last Updated:** January 26, 2025  
**Issue:** Edge Functions require deployment to production before curl tests can run  
**Next Step:** Deploy Edge Functions to Supabase, then run these tests

---

## Test Environment Configuration

```bash
# Supabase Configuration (from AppConstants.swift)
BASE_URL="https://nnejcjbzspqxsowwnzvh.supabase.co/functions/v1"
ANON_KEY="YOUR_SUPABASE_ANON_KEY_HERE"
```

---

## Manual Test Sequence (Run After Deployment)

### STEP 1: Create Guest User (Database RPC)

**Note:** `create_guest_user` is a database RPC function, not an Edge Function.

This should be tested via iOS app or direct database connection.

Expected behavior:
- Call `create_guest_user(device_id)` RPC function
- Returns UUID for new or existing guest user
- Stores in `users` table with `device_id` column

---

### STEP 2: Get Quota (No JWT Required)

**Command:**
```bash
curl -X POST "$BASE_URL/get_quota" \
  -H "Content-Type: application/json" \
  -H "apikey: $ANON_KEY" \
  -d '{"user_id":"<UUID_FROM_STEP_1>"}'
```

**Expected Response:**
```json
{
  "success": true,
  "quota_used": 0,
  "quota_limit": 3,
  "quota_remaining": 3,
  "is_premium": false
}
```

**Success Criteria:**
- ✅ HTTP 200
- ✅ Returns JSON with quota info
- ✅ No JWT required (guest mode works)
- ✅ Response time < 2000ms

---

### STEP 3: Consume Quota (No JWT Required)

**Command:**
```bash
curl -X POST "$BASE_URL/consume_quota" \
  -H "Content-Type: application/json" \
  -H "apikey: $ANON_KEY" \
  -d '{"user_id":"<UUID_FROM_STEP_1>"}'
```

**Expected Response:**
```json
{
  "success": true,
  "message": "Quota consumed successfully.",
  "quota_used": 1,
  "quota_limit": 3,
  "quota_remaining": 2,
  "is_premium": false
}
```

**Success Criteria:**
- ✅ HTTP 200
- ✅ Quota incremented
- ✅ No JWT required
- ✅ Response time < 2000ms

---

### STEP 4: Process Face Reading (No JWT Required)

**Command:**
```bash
curl -X POST "$BASE_URL/process-face-reading" \
  -H "Content-Type: application/json" \
  -H "apikey: $ANON_KEY" \
  -d '{
    "user_id":"<UUID_FROM_STEP_1>",
    "image_url":"https://example.com/test.jpg",
    "reading_type":"face",
    "cultural_origin":"chinese"
  }'
```

**Expected Response:**
```json
{
  "success": true,
  "result": "<Fortune reading text>",
  "reading_type": "face",
  "cultural_origin": "chinese",
  "share_card_url": "https://...",
  "processing_time": 1500
}
```

**Success Criteria:**
- ✅ HTTP 200
- ✅ AI processing completes
- ✅ Reading saved to database
- ✅ Quota consumed
- ✅ Response time < 5000ms

---

### STEP 5: Error Case - Missing user_id

**Command:**
```bash
curl -X POST "$BASE_URL/get_quota" \
  -H "Content-Type: application/json" \
  -H "apikey: $ANON_KEY" \
  -d '{}'
```

**Expected Response:**
```json
{
  "error": "Unauthorized: missing JWT or user_id"
}
```

**Success Criteria:**
- ✅ HTTP 401
- ✅ Error message returned
- ✅ Prevents unauthorized access

---

### STEP 6: Error Case - Invalid user_id

**Command:**
```bash
curl -X POST "$BASE_URL/get_quota" \
  -H "Content-Type: application/json" \
  -H "apikey: $ANON_KEY" \
  -d '{"user_id":"invalid-uuid"}'
```

**Expected Response:**
```json
{
  "error": "Invalid user_id format"
}
```

**Success Criteria:**
- ✅ HTTP 400
- ✅ Validation error returned

---

## Test Results Summary Table

| Step | Endpoint | HTTP | Result | Notes |
|------|----------|------|--------|-------|
| 1 | create_guest_user (RPC) | N/A | ⏳ Pending | Database function, not Edge Function |
| 2 | get_quota | 404 | ❌ Not deployed | Edge Functions not yet deployed |
| 3 | consume_quota | 404 | ❌ Not deployed | Edge Functions not yet deployed |
| 4 | process-face-reading | 404 | ❌ Not deployed | Edge Functions not yet deployed |
| 5 | get_quota (error) | 404 | ❌ Not deployed | Edge Functions not yet deployed |
| 6 | get_quota (invalid) | 404 | ❌ Not deployed | Edge Functions not yet deployed |

**Status:** ⏳ WAITING FOR DEPLOYMENT

---

## Deployment Checklist

### Before Running Tests:

1. **Deploy Database Migration**
   ```bash
   # Apply the unified quota functions
   supabase db push
   # Or via Supabase Dashboard SQL Editor
   ```

2. **Deploy Edge Functions**
   ```bash
   cd supabase/functions
   supabase functions deploy create-share-card
   supabase functions deploy get_quota
   supabase functions deploy consume_quota
   supabase functions deploy process-face-reading
   supabase functions deploy process-palm-reading
   supabase functions deploy process-coffee-reading
   ```

3. **Verify Deployment**
   ```bash
   # Check that functions are accessible
   curl -X POST "$BASE_URL/get_quota" \
     -H "Content-Type: application/json" \
     -d '{"user_id":"test"}' \
     -w "\nHTTP: %{http_code}\n"
   # Should return 401 or 200 (not 404)
   ```

---

## Expected Behavior Summary

### ✅ Guest Flow Works When:
- No JWT token provided
- `user_id` present in request body
- Database has user record (guest or authenticated)

### ❌ Guest Flow Fails When:
- No JWT AND no `user_id` → 401 Unauthorized
- Invalid `user_id` format → 400 Bad Request
- Edge Functions not deployed → 404 Not Found

### 🔐 Security Validations:
- Guest users cannot access other users' data
- Quota tracking is user-specific
- AI processing respects daily limits
- Premium status checked server-side

---

## Notes

1. **create_guest_user is NOT an Edge Function**
   - It's a database RPC function
   - Must be called via `supabase.rpc()` in iOS app
   - Cannot be tested via curl without database access

2. **iOS app flow:**
   - User presses "Continue as Guest"
   - AuthService calls `create_guest_user(device_id)` → returns UUID
   - UUID stored in UserDefaults as "guest_user_id"
   - All Edge Function calls use this UUID

3. **Edge Functions Use Service Role Key:**
   - Functions bypass RLS by using service role
   - This allows guest users to access data
   - `SUPABASE_SERVICE_ROLE_KEY` environment variable required

---

## Next Steps

1. ✅ Code changes complete (Phase 1-3)
2. ✅ Build verification passed (Phase 4)
3. ⏳ Deploy Edge Functions to production
4. ⏳ Run curl tests (this document)
5. ⏳ Manual in-app guest flow testing
6. ⏳ Production deployment

---

**Ready for deployment and testing once Edge Functions are deployed to Supabase production.**


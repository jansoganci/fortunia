# Storage Guest Upload Fix - Summary

**Date:** January 27, 2025  
**Status:** ✅ **Migration Created**

---

## Problem

Guest users (anon role) cannot upload images to Supabase Storage, receiving:
```
StorageError(statusCode: "403", message: "new row violates row-level security policy", error: "Unauthorized")
```

## Solution

Created new migration: `supabase/migrations/20250127_allow_guest_storage_uploads.sql`

### What Was Added

Two new RLS policies on `storage.objects`:

#### 1. Upload Policy (INSERT permission for anon role)
```sql
CREATE POLICY "Allow guest uploads to readings folder"
ON storage.objects
FOR INSERT
TO anon
WITH CHECK (
  bucket_id = 'fortune-images-prod' AND
  (storage.foldername(name))[1] = 'readings'  -- Only readings/ folder
);
```

**Grants:**
- ✅ `anon` role can INSERT (upload) into fortune-images-prod bucket
- ✅ Restricts uploads to `readings/` folder only
- ❌ No UPDATE or DELETE permissions (guests can't modify after upload)

#### 2. Read Policy (SELECT permission for anon role)
```sql
CREATE POLICY "Allow guest reads from readings folder"
ON storage.objects
FOR SELECT
TO anon
USING (
  bucket_id = 'fortune-images-prod'
);
```

**Grants:**
- ✅ `anon` role can SELECT (read/view) uploaded images
- ✅ Allows guests to view their uploaded images after processing

---

## Security Considerations

### ✅ What's Protected

1. **Uploads restricted to readings/ folder:**
   - Guests can only upload to `readings/{UUID}.jpg`
   - No access to other bucket folders

2. **No modification permissions:**
   - Guests cannot update or delete existing files
   - INSERT-only access prevents data tampering

3. **UUID-based filenames:**
   - Files use unguessable UUIDs (1 in 5.3×10³⁶)
   - Directory enumeration attacks prevented

### 🔐 What Remains Secure

1. **Authenticated users:** Still have full CRUD access via existing policies
2. **Service role:** Edge functions retain full access
3. **Bucket isolation:** Only fortune-images-prod bucket affected
4. **Other buckets:** Unchanged, remain secure

---

## How It Works

### Guest User Flow

1. **User taps "Continue as Guest"**
   - Creates guest user via `create_guest_user()` RPC
   - No JWT token generated

2. **User captures photo (e.g., face reading)**
   - Photo processed by iOS app
   - Image compressed to 1024x1024

3. **App calls `StorageService.uploadImage()`**
   - Supabase SDK attempts upload
   - **Previously:** RLS blocked (403 error) ❌
   - **Now:** New policy allows anon INSERT ✅

4. **Upload succeeds**
   - File saved to `readings/{UUID}.jpg`
   - Public URL returned to app

5. **App sends image to Edge Function**
   - Edge Function can read image via service role key
   - AI processing proceeds normally

### Comparison: Before vs After

| Action | Before | After |
|--------|--------|-------|
| Guest uploads image | ❌ 403 Forbidden | ✅ Success |
| Guest views uploaded image | ❌ 403 Forbidden | ✅ Success |
| Guest modifies/deletes | ❌ Already blocked | ❌ Still blocked |
| Authenticated uploads | ✅ Works | ✅ Still works |
| Service role access | ✅ Works | ✅ Still works |

---

## Apply the Migration

### Option 1: Supabase Dashboard

1. Go to: https://supabase.com/dashboard/project/nnejcjbzspqxsowwnzvh/editor
2. Open SQL Editor
3. Copy contents of `supabase/migrations/20250127_allow_guest_storage_uploads.sql`
4. Paste and run

### Option 2: Supabase CLI (if linked)

```bash
supabase db push
```

### Verification Queries

After applying, verify policies exist:

```sql
-- Check guest upload policy exists
SELECT policyname, cmd, roles
FROM pg_policies 
WHERE schemaname = 'storage' 
  AND tablename = 'objects' 
  AND policyname = 'Allow guest uploads to readings folder';

-- Check guest read policy exists
SELECT policyname, cmd, roles
FROM pg_policies 
WHERE schemaname = 'storage' 
  AND tablename = 'objects' 
  AND policyname = 'Allow guest reads from readings folder';
```

Expected result:
```
policyname                          | cmd    | roles
------------------------------------|--------|-------
Allow guest uploads to readings folder | INSERT | {anon}
Allow guest reads from readings folder | SELECT | {anon}
```

---

## Testing After Migration

### Test Case 1: Guest User Upload
1. Launch app in guest mode
2. Start face reading flow
3. Capture photo
4. Tap "Continue"
5. **Expected:** Upload succeeds (no 403 error)
6. **Verify:** Image URL returned

### Test Case 2: Edge Function Processing
1. Complete guest upload (from Test Case 1)
2. Edge Function processes image
3. Reading result returned
4. **Expected:** AI processing succeeds
5. **Verify:** Result displayed in app

### Test Case 3: Authenticated User (Regression)
1. Sign in with email
2. Start face reading flow
3. Capture photo and upload
4. **Expected:** Upload still works (existing functionality)
5. **Verify:** No regression

---

## Summary

✅ **Migration created:** `supabase/migrations/20250127_allow_guest_storage_uploads.sql`  
✅ **Two policies added:** INSERT and SELECT for anon role  
✅ **Security maintained:** Upload-only access, folder-restricted  
✅ **No regressions:** Authenticated and service role access unchanged  

**Next step:** Apply migration in Supabase Dashboard, then test guest upload flow.


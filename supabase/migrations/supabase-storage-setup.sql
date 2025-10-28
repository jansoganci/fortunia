-- ============================================================================
-- FORTUNIA SUPABASE STORAGE BUCKET SETUP
-- ============================================================================
-- Project: Fortunia
-- Bucket: fortune-images-prod
-- Folder Structure: readings/{UUID}.jpg
-- 
-- This file contains TWO separate setup scripts:
-- - OPTION A: PUBLIC Bucket (for MVP - recommended)
-- - OPTION B: PRIVATE Bucket (for production with RLS)
--
-- Instructions:
-- 1. Choose your preferred option (A for MVP, B for production)
-- 2. Copy the relevant section (A or B)
-- 3. Execute in Supabase SQL Editor
-- ============================================================================


-- ============================================================================
-- OPTION A: PUBLIC BUCKET (MVP LAUNCH - RECOMMENDED)
-- ============================================================================
-- Use this option for quick MVP launch
-- - Simplest setup (no RLS policies required)
-- - Edge functions work immediately
-- - UUID-based security provides obscurity
-- - No code changes needed
-- ============================================================================

-- Step 1: Create the storage bucket as PUBLIC
INSERT INTO storage.buckets (id, name, public)
VALUES (
  'fortune-images-prod',
  'fortune-images-prod',
  true  -- Public bucket: allows direct URL access
)
ON CONFLICT (id) DO NOTHING;

-- Step 2: Create a helper comment (optional)
COMMENT ON TABLE storage.buckets IS 'Fortunia fortune reading images storage. Bucket is public for MVP simplicity. Files are stored with UUID-based naming for security.';

-- Done! No RLS policies needed for public bucket.
-- Edge functions can fetch images directly via URL.
-- 
-- To use:
-- 1. Upload via StorageService.swift (authenticated uploads only via SDK)
-- 2. Edge functions receive public URL and can fetch immediately
-- 3. Test upload via iOS app


-- ============================================================================
-- OPTION B: PRIVATE BUCKET (PRODUCTION - WITH RLS POLICIES)
-- ============================================================================
-- Use this option for production with enhanced security
-- - Enforces authenticated uploads via RLS
-- - Prevents enumeration attacks
-- - Better GDPR compliance
-- - Requires StorageService.swift update for signed URLs
-- ============================================================================

-- ============================================================================
-- WARNING: DO NOT RUN BOTH OPTIONS IN SAME SESSION
-- If you want to switch from PUBLIC to PRIVATE, drop the public bucket first:
-- DROP POLICY IF EXISTS "Allow authenticated uploads" ON storage.objects;
-- DROP POLICY IF EXISTS "Allow authenticated reads" ON storage.objects;
-- Then run the PRIVATE section below.
-- ============================================================================

/*
-- Step 1: Create the storage bucket as PRIVATE
INSERT INTO storage.buckets (id, name, public)
VALUES (
  'fortune-images-prod',
  'fortune-images-prod',
  false  -- Private bucket: requires RLS policies for access
)
ON CONFLICT (id) 
DO UPDATE SET public = false;  -- Ensure bucket stays private

-- Step 2: Policy 1 - Allow authenticated users to upload images
-- Purpose: Only logged-in users can upload to the readings/ folder
CREATE POLICY "Authenticated users can upload to readings folder"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'fortune-images-prod' AND
  (storage.foldername(name))[1] = 'readings'  -- Only allow uploads to readings/ folder
);

-- Step 3: Policy 2 - Allow authenticated users to read their uploaded images
-- Purpose: Authenticated users can view images they have access to
-- Note: UUID-based filenames make this permissive (unguessable URLs)
CREATE POLICY "Authenticated users can read uploaded images"
ON storage.objects
FOR SELECT
TO authenticated
USING (
  bucket_id = 'fortune-images-prod'
);

-- Step 4: Policy 3 - Allow service role (edge functions) to read all images
-- Purpose: Edge functions need to fetch images for AI processing
-- Implementation: Edge functions already use SERVICE_ROLE_KEY in code
CREATE POLICY "Service role can read all images for AI processing"
ON storage.objects
FOR SELECT
TO service_role
USING (
  bucket_id = 'fortune-images-prod'
);

-- Step 5 (OPTIONAL): Policy 4 - Admin full access for content moderation
-- Purpose: Admin users can manage all files (for future admin panel)
-- Note: Requires user metadata with 'role' = 'admin' in auth.users
-- Uncomment if you implement admin functionality:
/*
CREATE POLICY "Admins can manage all images"
ON storage.objects
FOR ALL  -- INSERT, SELECT, UPDATE, DELETE
TO authenticated
USING (
  bucket_id = 'fortune-images-prod' AND
  auth.jwt() ->> 'role' = 'admin'
);

-- Step 6: Enable RLS on storage.objects table (if not already enabled)
-- Note: RLS is enabled by default in Supabase, but included for safety
ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

-- Step 7: Create a helper comment
COMMENT ON POLICY "Authenticated users can upload to readings folder" ON storage.objects IS 
  'Allows authenticated Fortunia users to upload photos to readings/ folder';

COMMENT ON POLICY "Authenticated users can read uploaded images" ON storage.objects IS 
  'Allows authenticated Fortunia users to view uploaded images (UUID-based security)';

COMMENT ON POLICY "Service role can read all images for AI processing" ON storage.objects IS 
  'Allows edge functions to access images for AI processing via service role key';

-- Verification query (optional)
-- SELECT id, name, public, created_at 
-- FROM storage.buckets 
-- WHERE id = 'fortune-images-prod';

-- Done! Private bucket is now set up with RLS policies.
-- 
-- IMPORTANT: Update StorageService.swift to generate signed URLs:
-- 1. Replace getPublicURL() with createSignedURL()
-- 2. Signed URLs should expire in 1 hour (3600 seconds)
-- 3. Test edge function access to private bucket images
*/


-- ============================================================================
-- VERIFICATION & TESTING
-- ============================================================================

-- After running either option, verify the bucket exists:
SELECT 
  id,
  name,
  public,
  created_at
FROM storage.buckets 
WHERE id = 'fortune-images-prod';

-- If using PRIVATE bucket, verify policies exist:
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual
FROM pg_policies 
WHERE tablename = 'objects' 
  AND schemaname = 'storage'
  AND policyname LIKE '%fortune%';

-- Clean up (if needed):
-- DROP POLICY IF EXISTS "Authenticated users can upload to readings folder" ON storage.objects;
-- DROP POLICY IF EXISTS "Authenticated users can read uploaded images" ON storage.objects;
-- DROP POLICY IF EXISTS "Service role can read all images for AI processing" ON storage.objects;
-- DROP POLICY IF EXISTS "Admins can manage all images" ON storage.objects;
-- DELETE FROM storage.buckets WHERE id = 'fortune-images-prod';


-- ============================================================================
-- FOLDER STRUCTURE IN BUCKET
-- ============================================================================

-- Expected structure:
-- fortune-images-prod/
--   └── readings/
--       ├── 550e8400-e29b-41d4-a716-446655440000.jpg
--       ├── 6ba7b810-9dad-11d1-80b4-00c04fd430c8.jpg
--       └── ...

-- File naming pattern: {UUID}.jpg
-- Path: readings/{UUID}.jpg
-- 
-- Security: UUIDs are unguessable (1 in 5.3×10³⁶)
-- Both public and private buckets rely on UUID security


-- ============================================================================
-- NOTES & TROUBLESHOOTING
-- ============================================================================

-- Common Issues:
--
-- 1. "Bucket not found" error:
--    → Bucket doesn't exist: Run the appropriate option above
--    → Wrong bucket name: Verify 'fortune-images-prod' in code
--
-- 2. "Permission denied" when uploading:
--    → If using PRIVATE bucket: Ensure RLS policies are created
--    → Check user is authenticated via Supabase SDK
--
-- 3. Edge functions can't fetch images (PRIVATE bucket):
--    → Update StorageService.swift to generate signed URLs
--    → Or add service role policy (already included above)
--
-- 4. Migration from PUBLIC to PRIVATE:
--    1. Create new private bucket (or update public flag)
--    2. Run PRIVATE option policies
--    3. Update StorageService.swift
--    4. Test end-to-end flow
--
-- References:
-- - Supabase Storage Docs: https://supabase.com/docs/guides/storage
-- - RLS Policies: https://supabase.com/docs/guides/storage/security/access-control
-- - Signed URLs: https://supabase.com/docs/reference/swift/creating-signed-urls


-- ============================================================================
-- END OF SETUP SCRIPT
-- ============================================================================


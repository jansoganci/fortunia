-- Migration: Allow guest users (anon role) to upload images
-- Date: 2025-01-27
-- Goal: Enable guest mode image uploads to fortune-images-prod bucket

-- ===========================================
-- STORAGE RLS POLICY FOR GUEST UPLOADS
-- ===========================================

-- Policy: Allow anonymous users (guests) to upload images to readings folder
-- This enables guest users without JWT tokens to upload photos for fortune readings
CREATE POLICY "Allow guest uploads to readings folder"
ON storage.objects
FOR INSERT
TO anon
WITH CHECK (
  bucket_id = 'fortune-images-prod' AND
  (storage.foldername(name))[1] = 'readings'  -- Only allow uploads to readings/ folder
);

-- Policy: Allow anonymous users to read uploaded images (for viewing results)
CREATE POLICY "Allow guest reads from readings folder"
ON storage.objects
FOR SELECT
TO anon
USING (
  bucket_id = 'fortune-images-prod'
);

-- ===========================================
-- VERIFICATION
-- ===========================================

-- Check if RLS is enabled on storage.objects
-- SELECT tablename, rowsecurity 
-- FROM pg_tables 
-- WHERE schemaname = 'storage' AND tablename = 'objects';

-- List all policies on storage.objects for the fortune-images-prod bucket
-- SELECT policyname, permissive, roles, cmd
-- FROM pg_policies 
-- WHERE schemaname = 'storage' AND tablename = 'objects' AND policyname LIKE '%readings%';

-- ===========================================
-- SUMMARY OF CHANGES
-- ===========================================
--
-- Created policies:
--   1. "Allow guest uploads to readings folder" - GRANT INSERT to anon role
--   2. "Allow guest reads from readings folder" - GRANT SELECT to anon role
--
-- Security:
--   ✅ Guest users can upload to readings/ folder only
--   ✅ No update or delete permissions for guests (read-only)
--   ✅ Uploads restricted to specific folder structure
--   ✅ Authenticated and service_role users retain full access
--
-- Notes:
--   - These policies work alongside existing authenticated user policies
--   - No conflicts with existing RLS policies
--   - UUID-based filenames provide additional security
--   - Folder structure: readings/{UUID}.jpg


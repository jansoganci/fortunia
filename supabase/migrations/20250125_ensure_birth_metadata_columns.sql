-- Migration: Ensure Birth Metadata Columns Exist
-- Date: 2025-01-25
-- Purpose: Ensure users table has birth metadata columns for personalized fortune readings

-- Check if birth metadata columns exist, add them if they don't
-- This migration is idempotent and safe to run multiple times

DO $$ 
BEGIN
    -- Add birth_date column if it doesn't exist
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'users' AND column_name = 'birth_date'
    ) THEN
        ALTER TABLE users ADD COLUMN birth_date DATE;
    END IF;

    -- Add birth_time column if it doesn't exist
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'users' AND column_name = 'birth_time'
    ) THEN
        ALTER TABLE users ADD COLUMN birth_time TIME;
    END IF;

    -- Add birth_city column if it doesn't exist
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'users' AND column_name = 'birth_city'
    ) THEN
        ALTER TABLE users ADD COLUMN birth_city TEXT;
    END IF;

    -- Add birth_country column if it doesn't exist
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'users' AND column_name = 'birth_country'
    ) THEN
        ALTER TABLE users ADD COLUMN birth_country TEXT;
    END IF;
END $$;

-- Add comments to document the purpose of these columns
COMMENT ON COLUMN users.birth_date IS 'User birth date for personalized fortune readings and astrological calculations';
COMMENT ON COLUMN users.birth_time IS 'User birth time for detailed astrological analysis and destiny timing';
COMMENT ON COLUMN users.birth_city IS 'User birth city for geographic energy analysis in fortune readings';
COMMENT ON COLUMN users.birth_country IS 'User birth country for cultural context in personalized readings';

-- Verify the columns exist
SELECT 
    column_name, 
    data_type, 
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'users' 
    AND column_name IN ('birth_date', 'birth_time', 'birth_city', 'birth_country')
ORDER BY column_name;

-- Add device_id column to users table for guest user tracking
-- This allows tracking guests who use the app without email/apple signin

ALTER TABLE public.users
ADD COLUMN IF NOT EXISTS device_id TEXT UNIQUE;

-- Add index for faster lookups
CREATE INDEX IF NOT EXISTS idx_users_device_id ON public.users(device_id);

-- Update RLS policy to allow guest users to create their own records
-- Guest users will have no auth.uid(), so we need to allow anonymous inserts

-- Create a function to handle guest user creation
CREATE OR REPLACE FUNCTION public.create_guest_user(p_device_id TEXT)
RETURNS UUID AS $$
DECLARE
  v_user_id UUID;
BEGIN
  -- Check if user with this device_id already exists
  SELECT id INTO v_user_id
  FROM public.users
  WHERE device_id = p_device_id;
  
  -- If exists, return existing user_id
  IF v_user_id IS NOT NULL THEN
    RETURN v_user_id;
  END IF;
  
  -- Create new guest user
  INSERT INTO public.users (
    id,
    email,
    device_id,
    onboarding_completed,
    timezone,
    language,
    notification_enabled
  ) VALUES (
    gen_random_uuid(),
    NULL, -- No email for guests
    p_device_id,
    false,
    'UTC',
    'en',
    false
  ) RETURNING id INTO v_user_id;
  
  RETURN v_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Comment explaining the column
COMMENT ON COLUMN public.users.device_id IS 'Unique device identifier for guest users who use the app without email/apple signin. Used for quota tracking and account migration.';


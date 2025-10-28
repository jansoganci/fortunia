-- FORTUNIA SUPERBASE SETUP SCRIPT
-- Version 1.0
-- This script creates all necessary tables, enables Row Level Security,
-- sets access policies, and creates helper functions for the Fortunia app.

-- ===========================================
-- 1. TABLES
-- ===========================================

-- USERS TABLE - User profile information
CREATE TABLE users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT UNIQUE,
  birth_date DATE,
  birth_time TIME,
  birth_city TEXT,
  birth_country TEXT,
  timezone TEXT DEFAULT 'UTC',
  language TEXT DEFAULT 'en',
  notification_enabled BOOLEAN DEFAULT FALSE,
  notification_time TIME DEFAULT '09:00:00',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  last_active_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- READINGS TABLE - All fortune readings
CREATE TABLE readings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  reading_type TEXT NOT NULL, -- 'face', 'palm', 'tarot', 'coffee'
  cultural_origin TEXT NOT NULL, -- 'chinese', 'middle_eastern', 'european'
  image_url TEXT,
  result_text TEXT,
  share_card_url TEXT,
  is_premium BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- DAILY QUOTAS TABLE - Daily free fortune limit for both users and guests
CREATE TABLE daily_quotas (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  device_id TEXT, -- For guest users
  date DATE NOT NULL,
  free_readings_used INTEGER DEFAULT 0, -- Max 3 per day
  premium_readings_used INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, date),
  UNIQUE(device_id, date)
);

-- SUBSCRIPTIONS TABLE - Adapty subscription data
CREATE TABLE subscriptions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID UNIQUE REFERENCES users(id) ON DELETE CASCADE,
  adapty_customer_id TEXT UNIQUE,
  adapty_subscription_id TEXT,
  status TEXT NOT NULL, -- 'active', 'expired', 'cancelled', 'trial'
  product_id TEXT NOT NULL, -- 'weekly', 'monthly', 'yearly'
  expires_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);


-- ===========================================
-- 2. ROW LEVEL SECURITY (RLS)
-- ===========================================

-- Enable RLS on all user-specific tables
ALTER TABLE readings ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_quotas ENABLE ROW LEVEL SECURITY;
ALTER TABLE subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Policies for USERS table
CREATE POLICY "Users can view their own profile"
ON users FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update their own profile"
ON users FOR UPDATE USING (auth.uid() = id);

-- Policies for READINGS table
CREATE POLICY "Users can only access their own readings"
ON readings FOR ALL USING (auth.uid() = user_id);

-- Policies for DAILY_QUOTAS table
CREATE POLICY "Users can only access their own quotas"
ON daily_quotas FOR ALL USING (auth.uid() = user_id);
-- Allow access for guest users based on a secure token or session identifier if you implement that.
-- For now, guest quota logic is handled by SECURITY DEFINER functions.

-- Policies for SUBSCRIPTIONS table
CREATE POLICY "Users can only access their own subscriptions"
ON subscriptions FOR ALL USING (auth.uid() = user_id);


-- ===========================================
-- 3. HELPER FUNCTIONS
-- ===========================================

-- GET_QUOTA - Checks the current quota status for a user or device.
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
      SELECT 1 FROM public.subscriptions
      WHERE user_id = p_user_id
      AND status = 'active'
      AND expires_at > NOW()
    ) INTO v_is_premium;
  END IF;

  -- Premium users have unlimited quota
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
    FROM public.daily_quotas
    WHERE user_id = p_user_id AND date = CURRENT_DATE;

    -- Create record if not exists for today
    IF NOT FOUND THEN
      INSERT INTO public.daily_quotas (user_id, date, free_readings_used)
      VALUES (p_user_id, CURRENT_DATE, 0)
      ON CONFLICT (user_id, date) DO NOTHING;
      v_quota_used := 0;
    END IF;
  -- Check for anonymous user with device_id
  ELSIF p_device_id IS NOT NULL THEN
    SELECT COALESCE(free_readings_used, 0) INTO v_quota_used
    FROM public.daily_quotas
    WHERE user_id IS NULL AND device_id = p_device_id AND date = CURRENT_DATE;

    -- Create record if not exists for today
    IF NOT FOUND THEN
      INSERT INTO public.daily_quotas (user_id, device_id, date, free_readings_used)
      VALUES (NULL, p_device_id, CURRENT_DATE, 0)
      ON CONFLICT (device_id, date) DO NOTHING;
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


-- CONSUME_QUOTA - Attempts to use one reading quota and returns the result.
CREATE OR REPLACE FUNCTION consume_quota(
  p_user_id UUID DEFAULT NULL,
  p_device_id TEXT DEFAULT NULL
)
RETURNS JSON AS $$
DECLARE
  v_quota_info JSON;
  v_quota_remaining INTEGER;
  v_is_premium BOOLEAN;
BEGIN
  -- Get current quota status
  SELECT get_quota(p_user_id, p_device_id) INTO v_quota_info;

  v_is_premium := (v_quota_info->>'is_premium')::BOOLEAN;
  v_quota_remaining := (v_quota_info->>'quota_remaining')::INTEGER;

  -- Premium users can always proceed
  IF v_is_premium THEN
    RETURN json_build_object('success', true, 'message', 'Premium user, access granted.');
  END IF;

  -- Check if quota is exceeded
  IF v_quota_remaining <= 0 THEN
    RETURN json_build_object('success', false, 'message', 'Daily quota exceeded.');
  END IF;

  -- Increment quota for authenticated user
  IF p_user_id IS NOT NULL THEN
    INSERT INTO public.daily_quotas (user_id, date, free_readings_used)
    VALUES (p_user_id, CURRENT_DATE, 1)
    ON CONFLICT (user_id, date)
    DO UPDATE SET free_readings_used = daily_quotas.free_readings_used + 1;
  -- Increment quota for guest user
  ELSIF p_device_id IS NOT NULL THEN
    INSERT INTO public.daily_quotas (user_id, device_id, date, free_readings_used)
    VALUES (NULL, p_device_id, CURRENT_DATE, 1)
    ON CONFLICT (device_id, date)
    DO UPDATE SET free_readings_used = daily_quotas.free_readings_used + 1;
  ELSE
    RETURN json_build_object('success', false, 'message', 'User or device ID must be provided.');
  END IF;

  RETURN json_build_object('success', true, 'message', 'Quota consumed successfully.');
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ===========================================
-- 4. HANDLE NEW USER
-- ===========================================
-- Function to create a corresponding user profile when a new user signs up in Supabase Auth
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.users (id, email)
  VALUES (new.id, new.email);
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to call the function after a new user is created in the auth.users table
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();


-- Migration: Update quota functions to unify guest and authenticated users under user_id
-- Date: 2025-01-26
-- Goal: Remove device_id logic from quota functions and unify all users under user_id

-- ===========================================
-- UPDATED GET_QUOTA FUNCTION
-- ===========================================
-- Replaces the dual-parameter version with unified user_id-only logic
-- This function works for both guest users (who have a user_id via create_guest_user)
-- and authenticated users, all using the same user_id parameter.

CREATE OR REPLACE FUNCTION get_quota(p_user_id UUID)
RETURNS JSON AS $$
DECLARE
  v_quota_used INTEGER := 0;
  v_quota_limit INTEGER := 3; -- 3 daily limit for Fortunia
  v_is_premium BOOLEAN := FALSE;
  v_quota_remaining INTEGER;
BEGIN
  -- Premium user check
  SELECT EXISTS(
    SELECT 1 FROM public.subscriptions
    WHERE user_id = p_user_id
    AND status = 'active'
    AND expires_at > NOW()
  ) INTO v_is_premium;

  -- Premium users have unlimited quota
  IF v_is_premium THEN
    RETURN json_build_object(
      'quota_used', 0,
      'quota_limit', 999999,
      'quota_remaining', 999999,
      'is_premium', true
    );
  END IF;

  -- Get quota usage for today
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

  v_quota_remaining := GREATEST(0, v_quota_limit - v_quota_used);

  RETURN json_build_object(
    'quota_used', v_quota_used,
    'quota_limit', v_quota_limit,
    'quota_remaining', v_quota_remaining,
    'is_premium', v_is_premium
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ===========================================
-- UPDATED CONSUME_QUOTA FUNCTION
-- ===========================================
-- Replaces the dual-parameter version with unified user_id-only logic
-- Now accepts optional p_is_premium parameter for performance optimization
-- (to avoid re-checking subscription status)

CREATE OR REPLACE FUNCTION consume_quota(p_user_id UUID, p_is_premium BOOLEAN DEFAULT FALSE)
RETURNS JSON AS $$
DECLARE
  v_quota_info JSON;
  v_quota_remaining INTEGER;
  v_quota_used INTEGER;
  v_quota_limit INTEGER;
  v_is_premium BOOLEAN;
BEGIN
  -- If premium is passed as parameter, use it (performance optimization)
  -- Otherwise check via get_quota
  IF p_is_premium THEN
    RETURN json_build_object(
      'success', true,
      'message', 'Premium user, quota not consumed.',
      'quota_used', 0,
      'quota_limit', 999999,
      'quota_remaining', 999999,
      'is_premium', true
    );
  END IF;

  -- Get current quota status
  SELECT get_quota(p_user_id) INTO v_quota_info;

  v_is_premium := (v_quota_info->>'is_premium')::BOOLEAN;
  v_quota_remaining := (v_quota_info->>'quota_remaining')::INTEGER;
  v_quota_used := (v_quota_info->>'quota_used')::INTEGER;
  v_quota_limit := (v_quota_info->>'quota_limit')::INTEGER;

  -- Premium users can always proceed
  IF v_is_premium THEN
    RETURN json_build_object(
      'success', true,
      'message', 'Premium user, quota not consumed.',
      'quota_used', 0,
      'quota_limit', 999999,
      'quota_remaining', 999999,
      'is_premium', true
    );
  END IF;

  -- Check if quota is exceeded
  IF v_quota_remaining <= 0 THEN
    RETURN json_build_object(
      'success', false,
      'message', 'Daily quota exceeded.',
      'quota_used', v_quota_used,
      'quota_limit', v_quota_limit,
      'quota_remaining', 0,
      'is_premium', false
    );
  END IF;

  -- Increment quota usage for today
  INSERT INTO public.daily_quotas (user_id, date, free_readings_used)
  VALUES (p_user_id, CURRENT_DATE, 1)
  ON CONFLICT (user_id, date)
  DO UPDATE SET free_readings_used = daily_quotas.free_readings_used + 1;

  -- Calculate final quota remaining
  SELECT COALESCE(free_readings_used, 0) INTO v_quota_used
  FROM public.daily_quotas
  WHERE user_id = p_user_id AND date = CURRENT_DATE;

  v_quota_remaining := GREATEST(0, v_quota_limit - v_quota_used);

  RETURN json_build_object(
    'success', true,
    'message', 'Quota consumed successfully.',
    'quota_used', v_quota_used,
    'quota_limit', v_quota_limit,
    'quota_remaining', v_quota_remaining,
    'is_premium', false
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ===========================================
-- SUMMARY OF CHANGES
-- ===========================================
-- 
-- get_quota():
--   - BEFORE: p_user_id UUID DEFAULT NULL, p_device_id TEXT DEFAULT NULL
--   - AFTER:  p_user_id UUID (required, no defaults, no device_id)
--   - REMOVED: All device_id parameter handling and NULL user_id logic
--   - KEPT: SECURITY DEFINER, premium check, JSON return format
-- 
-- consume_quota():
--   - BEFORE: p_user_id UUID DEFAULT NULL, p_device_id TEXT DEFAULT NULL
--   - AFTER:  p_user_id UUID, p_is_premium BOOLEAN DEFAULT FALSE
--   - REMOVED: All device_id parameter handling and NULL user_id logic
--   - ADDED: Optional p_is_premium parameter for performance optimization
--   - KEPT: SECURITY DEFINER, premium check, quota increment logic
--   - IMPROVED: Returns full quota info in JSON response (consistent with get_quota)
-- 
-- IMPACT:
--   - Both authenticated and guest users now use unified user_id approach
--   - Guest users get user_id via create_guest_user() RPC function
--   - All quota tracking uses only user_id (no device_id branching)
--   - Functions remain SECURITY DEFINER (bypass RLS for accessibility)


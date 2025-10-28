-- ===========================================
-- MIGRATION: Add StoreKit 2 Sync Support
-- Date: 2025-01-26
-- Purpose: Enable subscription syncing from StoreKit 2 transactions
-- ===========================================

-- Add StoreKit-specific columns to subscriptions table
ALTER TABLE public.subscriptions
  ADD COLUMN IF NOT EXISTS transaction_id TEXT,
  ADD COLUMN IF NOT EXISTS purchase_date TIMESTAMP WITH TIME ZONE,
  ADD COLUMN IF NOT EXISTS environment TEXT;

-- Create index on transaction_id for faster lookups
CREATE INDEX IF NOT EXISTS idx_subscriptions_transaction_id 
  ON public.subscriptions(transaction_id);

-- ===========================================
-- UPSERT_SUBSCRIPTION - SQL RPC Function
-- ===========================================
CREATE OR REPLACE FUNCTION upsert_subscription(
  p_user_id UUID,
  p_product_id TEXT,
  p_status TEXT,
  p_expires_at TIMESTAMP WITH TIME ZONE,
  p_transaction_id TEXT,
  p_purchase_date TIMESTAMP WITH TIME ZONE,
  p_environment TEXT
) RETURNS JSON AS $$
BEGIN
  -- UPSERT into subscriptions table
  INSERT INTO public.subscriptions (
    user_id, product_id, status, expires_at,
    adapty_subscription_id, adapty_customer_id,
    transaction_id, purchase_date, environment, created_at
  )
  VALUES (
    p_user_id, p_product_id, p_status, p_expires_at,
    p_transaction_id, p_environment,
    p_transaction_id, p_purchase_date, p_environment, NOW()
  )
  ON CONFLICT (user_id)
  DO UPDATE SET
    product_id = EXCLUDED.product_id,
    status = EXCLUDED.status,
    expires_at = EXCLUDED.expires_at,
    transaction_id = EXCLUDED.transaction_id,
    purchase_date = EXCLUDED.purchase_date,
    environment = EXCLUDED.environment,
    adapty_subscription_id = EXCLUDED.adapty_subscription_id,
    adapty_customer_id = EXCLUDED.adapty_customer_id;

  RETURN json_build_object(
    'success', true,
    'status', p_status,
    'expires_at', p_expires_at
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ===========================================
-- GRANT EXECUTE PERMISSION
-- ===========================================
GRANT EXECUTE ON FUNCTION upsert_subscription TO authenticated;
GRANT EXECUTE ON FUNCTION upsert_subscription TO anon;

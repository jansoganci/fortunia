# StoreKit 2 → Supabase Sync Migration

## Overview
This migration adds StoreKit 2 transaction support to the Fortunia subscriptions system.

## Files Created

### 1. SQL Migration
**File:** `supabase/migrations/20251026_add_storekit_sync.sql`

**Changes:**
- Adds 3 new columns to `subscriptions` table:
  - `transaction_id` (TEXT) - StoreKit transaction UUID
  - `purchase_date` (TIMESTAMPTZ) - When the subscription was purchased
  - `environment` (TEXT) - 'production' or 'sandbox'

- Creates `upsert_subscription()` RPC function that:
  - Accepts StoreKit transaction data
  - UPSERTs into subscriptions table
  - Returns JSON with subscription status

### 2. Edge Function
**File:** `supabase/functions/update-subscription/index.ts`

**Purpose:** HTTP endpoint that:
- Authenticates user via JWT
- Validates StoreKit transaction data
- Calls `upsert_subscription()` SQL function
- Returns updated subscription status

## Database Changes

### Before Migration
```sql
subscriptions:
  - user_id (UUID, UNIQUE)
  - adapty_customer_id
  - adapty_subscription_id
  - status (TEXT)
  - product_id (TEXT)
  - expires_at (TIMESTAMPTZ)
  - created_at (TIMESTAMPTZ)
```

### After Migration
```sql
subscriptions:
  - user_id (UUID, UNIQUE)
  - adapty_customer_id
  - adapty_subscription_id
  - status (TEXT)
  - product_id (TEXT)
  - expires_at (TIMESTAMPTZ)
  - created_at (TIMESTAMPTZ)
  - transaction_id (TEXT) [NEW]
  - purchase_date (TIMESTAMPTZ) [NEW]
  - environment (TEXT) [NEW] - 'production' or 'sandbox'
```

## Testing the Migration

### 1. Apply the Migration
```bash
# Using Supabase CLI
supabase db push

# Or apply manually via SQL editor
psql -h <your-supabase-host> -U postgres -d postgres -f supabase/migrations/20251026_add_storekit_sync.sql
```

### 2. Test the SQL Function
```sql
-- Replace with a real user_id from your auth.users table
SELECT upsert_subscription(
  '2ecc9c81-197f-481f-908a-16661c483e93'::uuid,
  'monthly',
  'active',
  NOW() + INTERVAL '1 year',
  'storekit-test-001',
  NOW(),
  'sandbox'
);
```

**Expected Response:**
```json
{
  "success": true,
  "status": "active",
  "expires_at": "2026-01-26T..."
}
```

### 3. Verify Table Update
```sql
SELECT * FROM subscriptions 
WHERE transaction_id = 'storekit-test-001';
```

### 4. Test get_quota() Integration
```sql
SELECT get_quota('2ecc9c81-197f-481f-908a-16661c483e93'::uuid);
```

**Expected Response for Premium User:**
```json
{
  "quota_used": 0,
  "quota_limit": 999999,
  "quota_remaining": 999999,
  "is_premium": true
}
```

## Deployment Steps

1. **Apply Migration**
   ```bash
   supabase db push
   ```

2. **Deploy Edge Function**
   ```bash
   supabase functions deploy update-subscription
   ```

3. **Verify Function is Live**
   ```bash
   supabase functions list
   ```

## Integration with iOS App

Once deployed, the iOS app can call the Edge Function with StoreKit transaction data:

```swift
let payload: [String: Any] = [
    "product_id": "monthly",
    "status": "active",
    "expires_at": "2026-01-26T00:00:00Z",
    "transaction_id": "storekit-transaction-id",
    "purchase_date": "2025-01-26T10:00:00Z",
    "environment": "production"
]

let response = try await SupabaseService.shared.supabase
    .functions
    .invoke("update-subscription", body: payload)
    .execute()
```

## Security Notes

- ✅ JWT authentication required in Authorization header
- ✅ RLS policy restricts subscriptions to owning user
- ✅ SECURITY DEFINER function has elevated permissions (required for UPSERT)
- ✅ Edge Function validates all required fields
- ✅ Environment field distinguishes production vs sandbox transactions

## Rollback

If needed, rollback with:

```sql
-- Remove the new columns
ALTER TABLE subscriptions 
  DROP COLUMN IF EXISTS transaction_id,
  DROP COLUMN IF EXISTS purchase_date,
  DROP COLUMN IF EXISTS environment;

-- Drop the function
DROP FUNCTION IF EXISTS upsert_subscription;

-- Drop the index
DROP INDEX IF EXISTS idx_subscriptions_transaction_id;
```

## Next Steps

1. Deploy this migration to production
2. Update iOS app to call the Edge Function on purchase
3. Test with real StoreKit sandbox transactions
4. Monitor subscription sync in production

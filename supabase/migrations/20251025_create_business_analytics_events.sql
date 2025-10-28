CREATE TABLE IF NOT EXISTS business_analytics_events (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    event_name TEXT NOT NULL,
    user_id UUID REFERENCES auth.users(id),
    event_data JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Optional indexing for better BI performance
CREATE INDEX IF NOT EXISTS idx_business_event_name ON business_analytics_events(event_name);
CREATE INDEX IF NOT EXISTS idx_business_user_id ON business_analytics_events(user_id);
CREATE INDEX IF NOT EXISTS idx_business_created_at ON business_analytics_events(created_at);

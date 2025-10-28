#!/bin/bash

# Deploy Quota Management Functions to Supabase
# This script deploys the get_quota and consume_quota functions

echo "🚀 Deploying Quota Management Functions to Supabase..."

# Check if supabase CLI is installed
if ! command -v supabase &> /dev/null; then
    echo "❌ Supabase CLI not found. Please install it first:"
    echo "   npm install -g supabase"
    exit 1
fi

# Deploy get_quota function
echo "📦 Deploying get_quota function..."
supabase functions deploy get_quota

if [ $? -eq 0 ]; then
    echo "✅ get_quota function deployed successfully"
else
    echo "❌ Failed to deploy get_quota function"
    exit 1
fi

# Deploy consume_quota function
echo "📦 Deploying consume_quota function..."
supabase functions deploy consume_quota

if [ $? -eq 0 ]; then
    echo "✅ consume_quota function deployed successfully"
else
    echo "❌ Failed to deploy consume_quota function"
    exit 1
fi

echo "🎉 All quota functions deployed successfully!"
echo ""
echo "📋 Next steps:"
echo "1. Test the functions with curl commands"
echo "2. Verify quota enforcement in the app"
echo "3. Check Supabase dashboard for function logs"
echo ""
echo "🧪 Test commands:"
echo "curl -X POST 'https://YOUR_PROJECT_ID.functions.supabase.co/get_quota' \\"
echo "  -H 'Content-Type: application/json' \\"
echo "  -d '{\"user_id\":\"YOUR_TEST_USER_ID\"}'"
echo ""
echo "curl -X POST 'https://YOUR_PROJECT_ID.functions.supabase.co/consume_quota' \\"
echo "  -H 'Content-Type: application/json' \\"
echo "  -d '{\"user_id\":\"YOUR_TEST_USER_ID\"}'"

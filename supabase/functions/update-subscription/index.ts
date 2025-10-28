import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    // Create Supabase client
    const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? '';
    const supabaseAnonKey = Deno.env.get('SUPABASE_ANON_KEY') ?? '';
    
    const supabaseClient = createClient(
      supabaseUrl,
      supabaseAnonKey,
      {
        global: {
          headers: { Authorization: req.headers.get('Authorization')! },
        },
      }
    );

    // Get user from JWT
    const { data: { user }, error: authError } = await supabaseClient.auth.getUser();
    if (authError || !user) {
      return new Response(
        JSON.stringify({ success: false, error: 'Unauthorized' }),
        { 
          status: 401, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      );
    }

    // Parse request body
    const body = await req.json();
    const { 
      product_id, 
      status, 
      expires_at, 
      transaction_id, 
      purchase_date, 
      environment 
    } = body;

    // Validate required fields
    if (!product_id || !status || !expires_at || !transaction_id || !purchase_date || !environment) {
      return new Response(
        JSON.stringify({ 
          success: false, 
          error: 'Missing required fields: product_id, status, expires_at, transaction_id, purchase_date, environment' 
        }),
        { 
          status: 400, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      );
    }

    // Call the upsert_subscription RPC function
    const { data, error } = await supabaseClient.rpc('upsert_subscription', {
      p_user_id: user.id,
      p_product_id: product_id,
      p_status: status,
      p_expires_at: expires_at,
      p_transaction_id: transaction_id,
      p_purchase_date: purchase_date,
      p_environment: environment
    });

    if (error) {
      console.error('Error calling upsert_subscription:', error);
      return new Response(
        JSON.stringify({ 
          success: false, 
          error: 'Failed to update subscription', 
          details: error.message 
        }),
        { 
          status: 500, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      );
    }

    // Parse the JSON response from the function
    const subscriptionInfo = typeof data === 'string' ? JSON.parse(data) : data;

    return new Response(
      JSON.stringify({
        success: true,
        data: subscriptionInfo
      }),
      { 
        status: 200, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    );

  } catch (error) {
    console.error('Unexpected error:', error);
    return new Response(
      JSON.stringify({ 
        success: false, 
        error: 'Internal server error', 
        details: error.message 
      }),
      { 
        status: 500, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    );
  }
});

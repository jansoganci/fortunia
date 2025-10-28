import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // Guest-friendly authentication: try JWT first, but allow user_id fallback
    let authenticatedUserId: string | null = null
    const authHeader = req.headers.get("Authorization")
    
    if (authHeader) {
      const supabaseAuthClient = createClient(
        Deno.env.get('SUPABASE_URL') ?? '',
        Deno.env.get('SUPABASE_ANON_KEY') ?? '',
        {
          global: {
            headers: { Authorization: authHeader },
          },
        }
      )
      
      const { data: { user }, error: authError } = await supabaseAuthClient.auth.getUser()
      if (!authError && user) {
        authenticatedUserId = user.id
      }
    }

    // Parse request body
    const { user_id } = await req.json()
    
    // Guest-friendly validation: require user_id OR authenticated JWT
    if (!user_id && !authenticatedUserId) {
      return new Response(
        JSON.stringify({ error: 'Unauthorized: missing JWT or user_id' }),
        { 
          status: 401, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // If authenticated, verify user_id matches
    if (authenticatedUserId && user_id && user_id !== authenticatedUserId) {
      return new Response(
        JSON.stringify({ error: 'user_id does not match authenticated user' }),
        { 
          status: 403, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // Use authenticated user_id if available, otherwise use provided user_id
    const activeUserId = authenticatedUserId ?? user_id

    // Create Supabase client with service role key for database access
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const supabaseClient = createClient(supabaseUrl, serviceRoleKey)

    // Call the get_quota function
    const { data, error } = await supabaseClient.rpc('get_quota', {
      p_user_id: activeUserId
    })

    if (error) {
      console.error('Error calling get_quota:', error)
      return new Response(
        JSON.stringify({ error: 'Failed to get quota', details: error.message }),
        { 
          status: 500, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // Parse the JSON response from the function
    const quotaInfo = typeof data === 'string' ? JSON.parse(data) : data

    return new Response(
      JSON.stringify({
        success: true,
        quota_used: quotaInfo.quota_used || 0,
        quota_limit: quotaInfo.quota_limit || 3,
        quota_remaining: quotaInfo.quota_remaining || 0,
        is_premium: quotaInfo.is_premium || false
      }),
      { 
        status: 200, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )

  } catch (error) {
    console.error('Unexpected error:', error)
    return new Response(
      JSON.stringify({ error: 'Internal server error', details: error.message }),
      { 
        status: 500, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )
  }
})

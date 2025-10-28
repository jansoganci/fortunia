import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { fetchImageAsBase64, callGemini } from '../shared/gemini-rest-client.ts'
import { buildPersonalizedPrompt } from '../shared/prompts.ts'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
}

interface ProcessingRequest {
  image_url: string
  user_id: string  // Required - either authenticated or guest user_id
  reading_type: string
  cultural_origin: string
}

interface FortuneResult {
  success: boolean
  result: string
  reading_type: string
  cultural_origin: string
  share_card_url?: string
  processing_time?: number
  error?: string
}

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  const startTime = Date.now()

  // Guest-friendly authentication: try JWT first, but allow user_id fallback
  let authenticatedUserId: string | null = null
  const authHeader = req.headers.get("Authorization")
  
  if (authHeader && authHeader.startsWith("Bearer ")) {
    const token = authHeader.split(" ")[1]
    try {
      const supabaseAuthClient = createClient(
        Deno.env.get("SUPABASE_URL") ?? '',
        Deno.env.get("SUPABASE_ANON_KEY") ?? ''
      )
      const { data, error } = await supabaseAuthClient.auth.getUser(token)
      if (!error && data?.user) {
        authenticatedUserId = data.user.id
      }
    } catch (e) {
      console.log('JWT validation failed (guest mode may be used):', e)
    }
  }

  try {
    // Parse request body
    const { image_url, user_id, reading_type, cultural_origin }: ProcessingRequest = await req.json()

    // Guest-friendly validation: require user_id OR authenticated JWT
    if (!user_id && !authenticatedUserId) {
      return new Response(JSON.stringify({ 
        error: "Unauthorized: missing JWT or user_id" 
      }), { 
        status: 401,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      })
    }

    // Use authenticated user_id if available, otherwise use provided user_id
    const activeUserId = authenticatedUserId ?? user_id

    // Validate required fields
    if (!image_url || !activeUserId || !reading_type || !cultural_origin) {
      return new Response(JSON.stringify({
        success: false,
        error: 'Missing required fields: image_url, user_id, reading_type, cultural_origin'
      }), {
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      })
    }

    // Initialize Supabase client with service role key
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const supabase = createClient(supabaseUrl, serviceRoleKey)

    // 1. Check user quota
    const { data: quotaData, error: quotaError } = await supabase.rpc('get_quota', {
      p_user_id: activeUserId
    })

    if (quotaError) {
      throw new Error(`Quota check failed: ${quotaError.message}`)
    }

    const quotaInfo = quotaData as any
    if (!quotaInfo.is_premium && quotaInfo.quota_remaining <= 0) {
      return new Response(JSON.stringify({
        success: false,
        error: 'Daily quota exceeded. Upgrade to Premium for unlimited readings.'
      }), {
        status: 429,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      })
    }

    // 2. Check GEMINI_API_KEY environment variable
    const GEMINI_API_KEY = Deno.env.get("GEMINI_API_KEY")
    if (!GEMINI_API_KEY) {
      throw new Error("GEMINI_API_KEY not configured")
    }

    // 3. Fetch user profile for personalization
    const { data: userProfile } = await supabase
      .from('users')
      .select('birth_date, birth_time, birth_city, birth_country')
      .eq('id', activeUserId)
      .single()

    // 4. Fetch and convert image to base64
    const { mimeType, data: base64Image } = await fetchImageAsBase64(image_url)

    // 5. Build personalized prompt and call Gemini REST API
    const prompt = buildPersonalizedPrompt(reading_type, cultural_origin, userProfile)
    const fortuneText = await callGemini(
      GEMINI_API_KEY,
      prompt,
      { inlineData: { mimeType, data: base64Image } }
    )

    // 5. Generate share card URL (placeholder for now)
    const shareCardUrl = `https://fortunia.app/share-cards/${activeUserId}-${Date.now()}.png`

    // 6. Save reading to database
    const { error: saveError } = await supabase
      .from('readings')
      .insert({
        user_id: activeUserId,
        reading_type: reading_type,
        cultural_origin: cultural_origin,
        image_url: image_url,
        result_text: fortuneText,
        share_card_url: shareCardUrl,
        is_premium: quotaInfo.is_premium || false
      })

    if (saveError) {
      throw new Error(`Failed to save reading: ${saveError.message}`)
    }

    // 7. Consume quota
    const { error: consumeError } = await supabase.rpc('consume_quota', {
      p_user_id: activeUserId
    })

    if (consumeError) {
      // Log error but don't fail the request
      console.error('Failed to consume quota:', consumeError.message)
    }

    const processingTime = Date.now() - startTime

    const result: FortuneResult = {
      success: true,
      result: fortuneText,
      reading_type: reading_type,
      cultural_origin: cultural_origin,
      share_card_url: shareCardUrl,
      processing_time: processingTime
    }

    return new Response(JSON.stringify(result), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' }
    })

  } catch (error) {
    const processingTime = Date.now() - startTime
    
    const errorResult: FortuneResult = {
      success: false,
      result: '',
      reading_type: 'palm',
      cultural_origin: 'unknown',
      error: error.message,
      processing_time: processingTime
    }

    return new Response(JSON.stringify(errorResult), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' }
    })
  }
})

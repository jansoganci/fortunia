import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
}

interface ShareCardRequest {
  fortune_text: string
  reading_type: string
  cultural_origin: string
  user_id: string
}

interface ShareCardResponse {
  success: boolean
  share_card_url?: string
  error?: string
}

interface ShareCardData {
  fortuneText: string
  readingType: string
  culturalOrigin: string
  userId: string
  timestamp: number
}

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  // Validate Bearer token
  const authHeader = req.headers.get("Authorization")
  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    return new Response(JSON.stringify({ error: "Unauthorized" }), { 
      status: 401,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' }
    })
  }
  const token = authHeader.split(" ")[1]

  // Validate token with Supabase
  const supabase = createClient(
    Deno.env.get("SUPABASE_URL") ?? '',
    Deno.env.get("SUPABASE_ANON_KEY") ?? ''
  )
  const { data, error } = await supabase.auth.getUser(token)
  if (error || !data?.user) {
    return new Response(JSON.stringify({ error: "Invalid token" }), { 
      status: 401,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' }
    })
  }

  try {
    // Parse request body
    const { fortune_text, reading_type, cultural_origin, user_id }: ShareCardRequest = await req.json()

    // Validate required fields
    if (!fortune_text || !reading_type || !cultural_origin || !user_id) {
      return new Response(JSON.stringify({
        success: false,
        error: 'Missing required fields: fortune_text, reading_type, cultural_origin, user_id'
      }), {
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      })
    }

    // Initialize Supabase client with service role key
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const supabase = createClient(supabaseUrl, serviceRoleKey)

    // Generate share card
    const shareCardData: ShareCardData = {
      fortuneText: fortune_text,
      readingType: reading_type,
      culturalOrigin: cultural_origin,
      userId: user_id,
      timestamp: Date.now()
    }

    const shareCardUrl = await generateShareCard(shareCardData, supabase)

    const result: ShareCardResponse = {
      success: true,
      share_card_url: shareCardUrl
    }

    return new Response(JSON.stringify(result), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' }
    })

  } catch (error) {
    const errorResult: ShareCardResponse = {
      success: false,
      error: error.message
    }

    return new Response(JSON.stringify(errorResult), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' }
    })
  }
})

async function generateShareCard(data: ShareCardData, supabase: any): Promise<string> {
  try {
    // Generate HTML template for the share card
    const htmlTemplate = generateHTMLTemplate(data)
    
    // Convert HTML to image using a simple approach
    // For production, you might want to use a more sophisticated image generation service
    const imageBuffer = await generateImageFromHTML(htmlTemplate)
    
    // Generate unique filename
    const fileName = `${data.userId}-${data.timestamp}.png`
    const filePath = `share_cards/${fileName}`
    
    // Upload to Supabase Storage
    const { data: uploadData, error: uploadError } = await supabase.storage
      .from('fortune-images-prod')
      .upload(filePath, imageBuffer, {
        contentType: 'image/png',
        cacheControl: '3600'
      })

    if (uploadError) {
      throw new Error(`Failed to upload share card: ${uploadError.message}`)
    }

    // Generate public URL
    const { data: urlData } = supabase.storage
      .from('fortune-images-prod')
      .getPublicUrl(filePath)

    return urlData.publicUrl

  } catch (error) {
    // Fallback: return a placeholder URL if image generation fails
    console.error('Share card generation failed:', error.message)
    return `https://fortunia.app/share-cards/placeholder-${data.userId}-${data.timestamp}.png`
  }
}

function generateHTMLTemplate(data: ShareCardData): string {
  const culturalColors = {
    chinese: {
      primary: '#9B86BD',
      secondary: '#D4A5A5',
      accent: '#FFD700'
    },
    middle_eastern: {
      primary: '#8B4513',
      secondary: '#DAA520',
      accent: '#FF6347'
    },
    european: {
      primary: '#4B0082',
      secondary: '#9370DB',
      accent: '#FF69B4'
    }
  }

  const readingIcons = {
    face: '👤',
    palm: '✋',
    coffee: '☕',
    tarot: '🔮'
  }

  const culturalNames = {
    chinese: 'Chinese',
    middle_eastern: 'Middle Eastern',
    european: 'European'
  }

  const colors = culturalColors[data.culturalOrigin] || culturalColors.chinese
  const icon = readingIcons[data.readingType] || '🔮'
  const culturalName = culturalNames[data.culturalOrigin] || 'Mystical'

  return `
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Fortunia - ${culturalName} ${data.readingType.charAt(0).toUpperCase() + data.readingType.slice(1)} Reading</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Georgia', serif;
            background: linear-gradient(135deg, ${colors.primary}20, ${colors.secondary}20);
            width: 1080px;
            height: 1080px;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            position: relative;
            overflow: hidden;
        }
        
        .card {
            background: linear-gradient(135deg, #ffffff, #f8f9fa);
            width: 900px;
            height: 900px;
            border-radius: 40px;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            align-items: center;
            padding: 60px;
            position: relative;
            overflow: hidden;
        }
        
        .card::before {
            content: '';
            position: absolute;
            top: -50%;
            left: -50%;
            width: 200%;
            height: 200%;
            background: radial-gradient(circle, ${colors.primary}10, transparent 70%);
            animation: rotate 20s linear infinite;
        }
        
        @keyframes rotate {
            from { transform: rotate(0deg); }
            to { transform: rotate(360deg); }
        }
        
        .header {
            text-align: center;
            z-index: 2;
            position: relative;
        }
        
        .app-name {
            font-size: 48px;
            font-weight: bold;
            color: ${colors.primary};
            margin-bottom: 20px;
            text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.1);
        }
        
        .reading-type {
            font-size: 32px;
            color: ${colors.secondary};
            margin-bottom: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 15px;
        }
        
        .cultural-origin {
            font-size: 24px;
            color: ${colors.accent};
            font-style: italic;
        }
        
        .fortune-content {
            flex: 1;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            text-align: center;
            z-index: 2;
            position: relative;
            max-width: 700px;
        }
        
        .fortune-text {
            font-size: 28px;
            line-height: 1.6;
            color: #2c3e50;
            font-style: italic;
            text-shadow: 1px 1px 2px rgba(0, 0, 0, 0.1);
            margin-bottom: 40px;
        }
        
        .quote-marks {
            font-size: 80px;
            color: ${colors.primary};
            opacity: 0.3;
            font-family: 'Times New Roman', serif;
            line-height: 1;
        }
        
        .footer {
            text-align: center;
            z-index: 2;
            position: relative;
        }
        
        .app-tagline {
            font-size: 20px;
            color: #7f8c8d;
            margin-bottom: 10px;
        }
        
        .website {
            font-size: 18px;
            color: ${colors.primary};
            font-weight: bold;
        }
        
        .decorative-elements {
            position: absolute;
            width: 100%;
            height: 100%;
            pointer-events: none;
            z-index: 1;
        }
        
        .star {
            position: absolute;
            color: ${colors.accent};
            font-size: 24px;
            animation: twinkle 3s ease-in-out infinite;
        }
        
        .star:nth-child(1) { top: 10%; left: 10%; animation-delay: 0s; }
        .star:nth-child(2) { top: 20%; right: 15%; animation-delay: 1s; }
        .star:nth-child(3) { bottom: 20%; left: 20%; animation-delay: 2s; }
        .star:nth-child(4) { bottom: 10%; right: 10%; animation-delay: 0.5s; }
        .star:nth-child(5) { top: 50%; left: 5%; animation-delay: 1.5s; }
        .star:nth-child(6) { top: 50%; right: 5%; animation-delay: 2.5s; }
        
        @keyframes twinkle {
            0%, 100% { opacity: 0.3; transform: scale(1); }
            50% { opacity: 1; transform: scale(1.2); }
        }
    </style>
</head>
<body>
    <div class="card">
        <div class="decorative-elements">
            <div class="star">✨</div>
            <div class="star">⭐</div>
            <div class="star">✨</div>
            <div class="star">⭐</div>
            <div class="star">✨</div>
            <div class="star">⭐</div>
        </div>
        
        <div class="header">
            <div class="app-name">Fortunia</div>
            <div class="reading-type">
                <span>${icon}</span>
                <span>${data.readingType.charAt(0).toUpperCase() + data.readingType.slice(1)} Reading</span>
            </div>
            <div class="cultural-origin">${culturalName} Tradition</div>
        </div>
        
        <div class="fortune-content">
            <div class="quote-marks">"</div>
            <div class="fortune-text">${data.fortuneText}</div>
            <div class="quote-marks">"</div>
        </div>
        
        <div class="footer">
            <div class="app-tagline">Discover Your Fortune</div>
            <div class="website">fortunia.app</div>
        </div>
    </div>
</body>
</html>
  `
}

async function generateImageFromHTML(html: string): Promise<Uint8Array> {
  // For now, we'll create a simple placeholder image
  // In production, you would use a service like Puppeteer or a headless browser
  // to render the HTML to an actual image
  
  // Create a simple canvas-based image as a placeholder
  const canvas = new OffscreenCanvas(1080, 1080)
  const ctx = canvas.getContext('2d')
  
  if (!ctx) {
    throw new Error('Failed to get canvas context')
  }
  
  // Create a gradient background
  const gradient = ctx.createLinearGradient(0, 0, 1080, 1080)
  gradient.addColorStop(0, '#9B86BD')
  gradient.addColorStop(1, '#D4A5A5')
  
  ctx.fillStyle = gradient
  ctx.fillRect(0, 0, 1080, 1080)
  
  // Add text
  ctx.fillStyle = '#ffffff'
  ctx.font = 'bold 48px Georgia'
  ctx.textAlign = 'center'
  ctx.fillText('Fortunia', 540, 200)
  
  ctx.font = '32px Georgia'
  ctx.fillText('Your Fortune Reading', 540, 300)
  
  ctx.font = '24px Georgia'
  ctx.fillText('Share your mystical journey', 540, 400)
  
  ctx.font = '20px Georgia'
  ctx.fillText('fortunia.app', 540, 500)
  
  // Convert canvas to image
  const imageData = canvas.transferToImageBitmap()
  const blob = await canvas.convertToBlob({ type: 'image/png' })
  const arrayBuffer = await blob.arrayBuffer()
  
  return new Uint8Array(arrayBuffer)
}

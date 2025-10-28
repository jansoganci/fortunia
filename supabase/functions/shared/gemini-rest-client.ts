export async function fetchImageAsBase64(imageUrl: string) {
  const res = await fetch(imageUrl)
  if (!res.ok) throw new Error("Image fetch failed")
  const buffer = await res.arrayBuffer()
  const bytes = new Uint8Array(buffer)
  let binary = ''
  for (let i = 0; i < bytes.length; i++) {
    binary += String.fromCharCode(bytes[i])
  }
  const base64 = btoa(binary)
  const mimeType = res.headers.get("content-type") || "image/jpeg"
  return { mimeType, data: base64 }
}

export async function callGemini(apiKey: string, prompt: string, imageBase64Part: any) {
  const url = `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent?key=${encodeURIComponent(apiKey)}`
  const requestBody = {
    contents: [
      {
        parts: [ { text: prompt }, imageBase64Part ]
      }
    ],
    generationConfig: {
      temperature: 0.9,
      topK: 40,
      topP: 0.95,
      maxOutputTokens: 1024
    }
  }

  const maxRetries = 3
  const backoffDelays = [1000, 2000, 4000] // 1s, 2s, 4s

  for (let attempt = 0; attempt < maxRetries; attempt++) {
    const controller = new AbortController()
    const timeoutId = setTimeout(() => controller.abort(), 30000) // 30 second timeout

    try {
      const response = await fetch(url, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(requestBody),
        signal: controller.signal
      })

      clearTimeout(timeoutId)

      if (response.ok) {
        const data = await response.json()
        return data?.candidates?.[0]?.content?.parts?.[0]?.text || "No output from Gemini."
      }

      // Retry on 429 (rate limit) or 5xx (server errors)
      if ((response.status === 429 || response.status >= 500) && attempt < maxRetries - 1) {
        console.log(`Gemini API returned ${response.status}, retrying in ${backoffDelays[attempt]}ms (attempt ${attempt + 1}/${maxRetries})`)
        await new Promise(resolve => setTimeout(resolve, backoffDelays[attempt]))
        continue
      }

      // Don't retry on other errors (400, 401, 403, 404)
      throw new Error(`Gemini API error: ${response.status} ${response.statusText}`)

    } catch (error: any) {
      clearTimeout(timeoutId)

      // Handle timeout
      if (error.name === "AbortError") {
        throw new Error("Gemini API timeout after 30 seconds")
      }

      // Re-throw if not a retryable error or last attempt
      if (attempt === maxRetries - 1) {
        throw new Error(`Gemini API failed after ${maxRetries} attempts: ${error.message}`)
      }

      // Wait before retry
      console.log(`Gemini API error: ${error.message}, retrying in ${backoffDelays[attempt]}ms (attempt ${attempt + 1}/${maxRetries})`)
      await new Promise(resolve => setTimeout(resolve, backoffDelays[attempt]))
    }
  }

  throw new Error("Gemini API failed after all retry attempts")
}

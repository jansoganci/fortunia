// generate-daily-horoscope/index.ts
// Generate daily horoscope using Gemini AI

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

interface HoroscopeRequest {
  sign: string;
  prompt: string;
}

interface HoroscopeResponse {
  sign: string;
  prediction: string;
  ratings: {
    love: number;
    career: number;
    health: number;
  };
  date: string;
}

serve(async (req) => {
  try {
    const { sign, prompt }: HoroscopeRequest = await req.json();

    // Get Gemini API key
    const GEMINI_API_KEY = Deno.env.get("GEMINI_API_KEY");
    if (!GEMINI_API_KEY) {
      return new Response(
        JSON.stringify({ error: "GEMINI_API_KEY not configured" }),
        { status: 500, headers: { "Content-Type": "application/json" } }
      );
    }

    // Call Gemini API
    const response = await fetch(
      `https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=${GEMINI_API_KEY}`,
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          contents: [
            {
              parts: [
                {
                  text: prompt,
                },
              ],
            },
          ],
        }),
      }
    );

    if (!response.ok) {
      throw new Error(`Gemini API error: ${response.statusText}`);
    }

    const data = await response.json();
    const text = data.candidates[0].content.parts[0].text;

    // Parse JSON from Gemini response
    const horoscope: HoroscopeResponse = JSON.parse(text);
    horoscope.date = new Date().toISOString().split("T")[0];

    return new Response(JSON.stringify(horoscope), {
      status: 200,
      headers: { "Content-Type": "application/json" },
    });
  } catch (error) {
    console.error("Error generating horoscope:", error);
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { "Content-Type": "application/json" } }
    );
  }
});


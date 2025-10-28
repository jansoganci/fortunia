import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
}

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // Initialize Supabase client with service role key
    const supabaseUrl = Deno.env.get('SUPABASE_URL')
    const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')
    
    if (!supabaseUrl || !serviceRoleKey) {
      throw new Error('Missing required environment variables: SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY')
    }

    const supabase = createClient(supabaseUrl, serviceRoleKey)

    console.log('Starting data retention cleanup...')
    
    // Calculate cutoff date (30 days ago)
    const thirtyDaysAgo = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000)
    const cutoffISOString = thirtyDaysAgo.toISOString()
    
    console.log(`Cleaning up data older than: ${cutoffISOString}`)

    // 1. Delete readings older than 30 days
    console.log('Deleting old readings...')
    const { data: deletedReadings, error: deleteReadingsError } = await supabase
      .from("readings")
      .delete()
      .lt("created_at", cutoffISOString)
      .select('id')

    if (deleteReadingsError) {
      console.error('Error deleting readings:', deleteReadingsError.message)
      throw new Error(`Failed to delete readings: ${deleteReadingsError.message}`)
    }

    const deletedReadingsCount = deletedReadings?.length || 0
    console.log(`Deleted ${deletedReadingsCount} old readings`)

    // 2. Delete old share card images
    console.log('Cleaning up old share card images...')
    const { data: files, error: listFilesError } = await supabase.storage
      .from("fortune-images-prod")
      .list("share_cards", { 
        limit: 1000, // Process up to 1000 files per run
        sortBy: { column: 'created_at', order: 'asc' }
      })

    if (listFilesError) {
      console.error('Error listing share card files:', listFilesError.message)
      throw new Error(`Failed to list share card files: ${listFilesError.message}`)
    }

    let deletedFilesCount = 0
    const filesToDelete: string[] = []

    // Identify files older than 30 days
    for (const file of files || []) {
      if (file.created_at) {
        const fileCreatedAt = new Date(file.created_at).getTime()
        const cutoffTime = thirtyDaysAgo.getTime()
        
        if (fileCreatedAt < cutoffTime) {
          filesToDelete.push(`share_cards/${file.name}`)
        }
      }
    }

    // Delete old files in batches
    if (filesToDelete.length > 0) {
      console.log(`Found ${filesToDelete.length} old share card files to delete`)
      
      // Process files in batches of 100 to avoid overwhelming the API
      const batchSize = 100
      for (let i = 0; i < filesToDelete.length; i += batchSize) {
        const batch = filesToDelete.slice(i, i + batchSize)
        
        const { error: deleteFilesError } = await supabase.storage
          .from("fortune-images-prod")
          .remove(batch)

        if (deleteFilesError) {
          console.error(`Error deleting file batch ${i}-${i + batch.length}:`, deleteFilesError.message)
          // Continue with next batch instead of failing completely
        } else {
          deletedFilesCount += batch.length
          console.log(`Deleted batch of ${batch.length} files`)
        }
      }
    } else {
      console.log('No old share card files found')
    }

    // 3. Clean up orphaned share card URLs in readings table
    console.log('Cleaning up orphaned share card URLs...')
    const { data: orphanedReadings, error: orphanedError } = await supabase
      .from("readings")
      .select('id, share_card_url')
      .not('share_card_url', 'is', null)

    if (!orphanedError && orphanedReadings) {
      let orphanedCount = 0
      
      for (const reading of orphanedReadings) {
        if (reading.share_card_url) {
          // Check if the file still exists in storage
          const fileName = reading.share_card_url.split('/').pop()
          if (fileName) {
            const { data: fileExists } = await supabase.storage
              .from("fortune-images-prod")
              .list("share_cards", { 
                search: fileName,
                limit: 1
              })
            
            // If file doesn't exist, clear the URL
            if (!fileExists || fileExists.length === 0) {
              await supabase
                .from("readings")
                .update({ share_card_url: null })
                .eq('id', reading.id)
              
              orphanedCount++
            }
          }
        }
      }
      
      console.log(`Cleaned up ${orphanedCount} orphaned share card URLs`)
    }

    // 4. Log cleanup summary
    const cleanupSummary = {
      timestamp: new Date().toISOString(),
      deletedReadings: deletedReadingsCount,
      deletedShareCards: deletedFilesCount,
      cutoffDate: cutoffISOString,
      status: 'success'
    }

    console.log('Cleanup completed successfully:', cleanupSummary)

    return new Response(JSON.stringify({
      success: true,
      message: 'Data retention cleanup completed successfully',
      summary: cleanupSummary
    }), {
      status: 200,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' }
    })

  } catch (error) {
    console.error('Cleanup failed:', error.message)
    
    return new Response(JSON.stringify({
      success: false,
      error: error.message,
      timestamp: new Date().toISOString()
    }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' }
    })
  }
})

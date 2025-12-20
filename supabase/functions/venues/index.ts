// Venues Edge Function - WiesbadenAfterDark
// Replaces Railway FastAPI endpoints #11-14

import "jsr:@supabase/functions-js/edge-runtime.d.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
}

Deno.serve(async (req) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // Create Supabase client with service role for reading public data
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const authHeader = req.headers.get('Authorization')

    // Use service role key to bypass RLS for public read operations
    const supabase = createClient(supabaseUrl, serviceRoleKey, {
      global: {
        headers: authHeader ? { Authorization: authHeader } : {}
      }
    })

    const url = new URL(req.url)
    const pathParts = url.pathname.split('/').filter(p => p && p !== 'venues' && p !== 'functions' && p !== 'v1')

    // Parse venue_id from path (e.g., /venues/123 -> venueId = "123")
    const venueId = pathParts[0] || null
    const subResource = pathParts[1] || null // e.g., "products" or "tier-config"

    // GET /venues - List venues
    if (req.method === 'GET' && !venueId) {
      const type = url.searchParams.get('type')
      const hasEvents = url.searchParams.get('has_events')
      const limit = parseInt(url.searchParams.get('limit') || '20')
      const offset = parseInt(url.searchParams.get('offset') || '0')

      console.log('Fetching venues, pathParts:', pathParts, 'venueId:', venueId)

      let query = supabase
        .from('venues')
        .select('*')
        .eq('is_active', true)
        .order('name')
        .range(offset, offset + limit - 1)

      if (type) {
        query = query.eq('venue_type', type)
      }

      const { data: venues, error } = await query

      console.log('Venues query result:', { venues: venues?.length, error: error?.message })

      if (error) {
        console.error('Venues query error:', error)
        throw error
      }

      return new Response(
        JSON.stringify({
          venues: venues || [],
          total: venues?.length || 0,
          limit,
          offset,
        }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // GET /venues/:id - Get venue details
    if (req.method === 'GET' && venueId && !subResource) {
      const { data: venue, error } = await supabase
        .from('venues')
        .select(`
          *,
          wad_events (
            id, title, description, start_time, end_time,
            image_url, event_type, status, is_featured
          )
        `)
        .eq('id', venueId)
        .single()

      if (error || !venue) {
        return new Response(
          JSON.stringify({ error: 'Venue not found' }),
          { status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
      }

      return new Response(
        JSON.stringify(venue),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // GET /venues/:id/products - Get venue products
    if (req.method === 'GET' && venueId && subResource === 'products') {
      const hasBonus = url.searchParams.get('has_bonus')
      const category = url.searchParams.get('category')

      let query = supabase
        .from('products')
        .select('*')
        .eq('venue_id', venueId)
        .eq('is_available', true)

      if (hasBonus === 'true') {
        query = query.gt('bonus_points', 0)
      }
      if (category) {
        query = query.eq('category', category)
      }

      const { data: products, error } = await query

      if (error) throw error

      return new Response(
        JSON.stringify({
          products: products || [],
          total: products?.length || 0,
        }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // GET /venues/:id/tier-config - Get tier configuration (owner only)
    if (req.method === 'GET' && venueId && subResource === 'tier-config') {
      // Get current user
      const { data: { user }, error: authError } = await supabase.auth.getUser()

      if (authError || !user) {
        return new Response(
          JSON.stringify({ error: 'Authentication required' }),
          { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
      }

      // Check if user is venue owner
      const { data: ownership, error: ownerError } = await supabase
        .from('venue_owners')
        .select('*')
        .eq('venue_id', venueId)
        .eq('user_id', user.id)
        .single()

      if (ownerError || !ownership) {
        return new Response(
          JSON.stringify({ error: 'Access denied. Only venue owners can view tier configuration.' }),
          { status: 403, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
      }

      // Get tier config
      const { data: tierConfig, error } = await supabase
        .from('tier_configs')
        .select('*')
        .eq('venue_id', venueId)
        .single()

      if (error) throw error

      return new Response(
        JSON.stringify(tierConfig || { tiers: [] }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Method not allowed
    return new Response(
      JSON.stringify({ error: 'Method not allowed' }),
      { status: 405, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    console.error('Venues function error:', error)
    return new Response(
      JSON.stringify({ error: error.message || 'Internal server error' }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})

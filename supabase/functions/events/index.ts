// Events Edge Function - WiesbadenAfterDark
// Replaces Railway FastAPI events endpoints

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
    const pathParts = url.pathname.split('/').filter(p => p && p !== 'events' && p !== 'functions' && p !== 'v1')

    // Helper to get today's date range
    const getTodayRange = () => {
      const now = new Date()
      const startOfDay = new Date(now.getFullYear(), now.getMonth(), now.getDate()).toISOString()
      const endOfDay = new Date(now.getFullYear(), now.getMonth(), now.getDate() + 1).toISOString()
      return { startOfDay, endOfDay }
    }

    // GET /events/today - Today's events
    if (req.method === 'GET' && pathParts[0] === 'today') {
      const limit = parseInt(url.searchParams.get('limit') || '10')
      const { startOfDay, endOfDay } = getTodayRange()

      const { data: events, error } = await supabase
        .from('wad_events')
        .select('*, venues(name)')
        .gte('start_time', startOfDay)
        .lt('start_time', endOfDay)
        .eq('status', 'scheduled')
        .order('start_time')
        .limit(limit)

      if (error) throw error

      const eventResponses = (events || []).map(e => ({
        ...e,
        venue_name: e.venues?.name || null,
        venues: undefined
      }))

      return new Response(
        JSON.stringify({ events: eventResponses, total: eventResponses.length, limit, offset: 0 }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // GET /events/upcoming - Upcoming events
    if (req.method === 'GET' && pathParts[0] === 'upcoming') {
      const days = parseInt(url.searchParams.get('days') || '7')
      const limit = parseInt(url.searchParams.get('limit') || '20')
      const now = new Date().toISOString()
      const futureDate = new Date(Date.now() + days * 24 * 60 * 60 * 1000).toISOString()

      const { data: events, error } = await supabase
        .from('wad_events')
        .select('*, venues(name)')
        .gte('start_time', now)
        .lte('start_time', futureDate)
        .eq('status', 'scheduled')
        .order('start_time')
        .limit(limit)

      if (error) throw error

      const eventResponses = (events || []).map(e => ({
        ...e,
        venue_name: e.venues?.name || null,
        venues: undefined
      }))

      return new Response(
        JSON.stringify({ events: eventResponses, total: eventResponses.length, limit, offset: 0 }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // GET /events/featured - Featured events
    if (req.method === 'GET' && pathParts[0] === 'featured') {
      const limit = parseInt(url.searchParams.get('limit') || '5')
      const now = new Date().toISOString()

      const { data: events, error } = await supabase
        .from('wad_events')
        .select('*, venues(name)')
        .eq('is_featured', true)
        .gte('start_time', now)
        .eq('status', 'scheduled')
        .order('start_time')
        .limit(limit)

      if (error) throw error

      const eventResponses = (events || []).map(e => ({
        ...e,
        venue_name: e.venues?.name || null,
        venues: undefined
      }))

      return new Response(
        JSON.stringify({ events: eventResponses, total: eventResponses.length, limit, offset: 0 }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // GET /events/my-events - User's RSVPed events
    if (req.method === 'GET' && pathParts[0] === 'my-events') {
      const { data: { user }, error: authError } = await supabase.auth.getUser()

      if (authError || !user) {
        return new Response(
          JSON.stringify({ error: 'Authentication required' }),
          { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
      }

      const includePast = url.searchParams.get('include_past') === 'true'
      const now = new Date().toISOString()

      let query = supabase
        .from('event_rsvps')
        .select('*, wad_events(*, venues(name))')
        .eq('user_id', user.id)

      if (!includePast) {
        query = query.gte('wad_events.start_time', now)
      }

      const { data: rsvps, error } = await query

      if (error) throw error

      return new Response(
        JSON.stringify({ rsvps: rsvps || [], total: rsvps?.length || 0 }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // GET /events/venue/:venue_id - Get venue events
    if (req.method === 'GET' && pathParts[0] === 'venue' && pathParts[1]) {
      const venueId = pathParts[1]
      const includePast = url.searchParams.get('include_past') === 'true'
      const limit = parseInt(url.searchParams.get('limit') || '20')
      const offset = parseInt(url.searchParams.get('offset') || '0')
      const now = new Date().toISOString()

      let query = supabase
        .from('wad_events')
        .select('*')
        .eq('venue_id', venueId)
        .order('start_time')
        .range(offset, offset + limit - 1)

      if (!includePast) {
        query = query.gte('start_time', now)
      }

      const { data: events, error } = await query

      if (error) throw error

      return new Response(
        JSON.stringify({ events: events || [], total: events?.length || 0, limit, offset }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // POST /events/venue/:venue_id - Create event (owner only)
    if (req.method === 'POST' && pathParts[0] === 'venue' && pathParts[1]) {
      const venueId = pathParts[1]

      const { data: { user }, error: authError } = await supabase.auth.getUser()
      if (authError || !user) {
        return new Response(
          JSON.stringify({ error: 'Authentication required' }),
          { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
      }

      // Check ownership
      const { data: ownership } = await supabase
        .from('venue_owners')
        .select('*')
        .eq('venue_id', venueId)
        .eq('user_id', user.id)
        .single()

      if (!ownership) {
        return new Response(
          JSON.stringify({ error: 'Only venue owners can create events' }),
          { status: 403, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
      }

      const eventData = await req.json()
      const { data: event, error } = await supabase
        .from('wad_events')
        .insert({ ...eventData, venue_id: venueId })
        .select()
        .single()

      if (error) throw error

      return new Response(
        JSON.stringify(event),
        { status: 201, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // GET /events/:id - Get single event
    if (req.method === 'GET' && pathParts[0] && !['today', 'upcoming', 'featured', 'my-events', 'venue'].includes(pathParts[0])) {
      const eventId = pathParts[0]

      const { data: event, error } = await supabase
        .from('wad_events')
        .select('*, venues(name)')
        .eq('id', eventId)
        .single()

      if (error || !event) {
        return new Response(
          JSON.stringify({ error: 'Event not found' }),
          { status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
      }

      return new Response(
        JSON.stringify({ ...event, venue_name: event.venues?.name, venues: undefined }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // POST /events/:id/rsvp - RSVP to event
    if (req.method === 'POST' && pathParts[0] && pathParts[1] === 'rsvp') {
      const eventId = pathParts[0]

      const { data: { user }, error: authError } = await supabase.auth.getUser()
      if (authError || !user) {
        return new Response(
          JSON.stringify({ error: 'Authentication required' }),
          { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
      }

      // Check event exists and is valid
      const { data: event, error: eventError } = await supabase
        .from('wad_events')
        .select('*')
        .eq('id', eventId)
        .single()

      if (eventError || !event) {
        return new Response(
          JSON.stringify({ error: 'Event not found' }),
          { status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
      }

      if (event.status === 'cancelled') {
        return new Response(
          JSON.stringify({ error: 'Cannot RSVP to cancelled event' }),
          { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
      }

      // Create RSVP
      const { data: rsvp, error } = await supabase
        .from('event_rsvps')
        .insert({
          event_id: eventId,
          user_id: user.id,
          status: 'confirmed'
        })
        .select()
        .single()

      if (error) throw error

      return new Response(
        JSON.stringify(rsvp),
        { status: 201, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // DELETE /events/:id/rsvp - Cancel RSVP
    if (req.method === 'DELETE' && pathParts[0] && pathParts[1] === 'rsvp') {
      const eventId = pathParts[0]

      const { data: { user }, error: authError } = await supabase.auth.getUser()
      if (authError || !user) {
        return new Response(
          JSON.stringify({ error: 'Authentication required' }),
          { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
      }

      const { error } = await supabase
        .from('event_rsvps')
        .delete()
        .eq('event_id', eventId)
        .eq('user_id', user.id)

      if (error) throw error

      return new Response(null, { status: 204, headers: corsHeaders })
    }

    // PUT /events/:id - Update event (owner only)
    if (req.method === 'PUT' && pathParts[0] && !pathParts[1]) {
      const eventId = pathParts[0]

      const { data: { user }, error: authError } = await supabase.auth.getUser()
      if (authError || !user) {
        return new Response(
          JSON.stringify({ error: 'Authentication required' }),
          { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
      }

      // Get event and check ownership
      const { data: event } = await supabase
        .from('wad_events')
        .select('venue_id')
        .eq('id', eventId)
        .single()

      if (!event) {
        return new Response(
          JSON.stringify({ error: 'Event not found' }),
          { status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
      }

      const { data: ownership } = await supabase
        .from('venue_owners')
        .select('*')
        .eq('venue_id', event.venue_id)
        .eq('user_id', user.id)
        .single()

      if (!ownership) {
        return new Response(
          JSON.stringify({ error: 'Only venue owners can update events' }),
          { status: 403, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
      }

      const eventData = await req.json()
      const { data: updatedEvent, error } = await supabase
        .from('wad_events')
        .update(eventData)
        .eq('id', eventId)
        .select()
        .single()

      if (error) throw error

      return new Response(
        JSON.stringify(updatedEvent),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // DELETE /events/:id - Delete event (owner only)
    if (req.method === 'DELETE' && pathParts[0] && !pathParts[1]) {
      const eventId = pathParts[0]

      const { data: { user }, error: authError } = await supabase.auth.getUser()
      if (authError || !user) {
        return new Response(
          JSON.stringify({ error: 'Authentication required' }),
          { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
      }

      // Get event and check ownership
      const { data: event } = await supabase
        .from('wad_events')
        .select('venue_id')
        .eq('id', eventId)
        .single()

      if (!event) {
        return new Response(
          JSON.stringify({ error: 'Event not found' }),
          { status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
      }

      const { data: ownership } = await supabase
        .from('venue_owners')
        .select('*')
        .eq('venue_id', event.venue_id)
        .eq('user_id', user.id)
        .single()

      if (!ownership) {
        return new Response(
          JSON.stringify({ error: 'Only venue owners can delete events' }),
          { status: 403, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
      }

      const { error } = await supabase
        .from('wad_events')
        .delete()
        .eq('id', eventId)

      if (error) throw error

      return new Response(null, { status: 204, headers: corsHeaders })
    }

    // GET /events - List all events
    if (req.method === 'GET' && pathParts.length === 0) {
      const venueId = url.searchParams.get('venue_id')
      const eventType = url.searchParams.get('event_type')
      const status = url.searchParams.get('status')
      const startAfter = url.searchParams.get('start_after')
      const startBefore = url.searchParams.get('start_before')
      const isFeatured = url.searchParams.get('is_featured')
      const limit = parseInt(url.searchParams.get('limit') || '20')
      const offset = parseInt(url.searchParams.get('offset') || '0')

      let query = supabase
        .from('wad_events')
        .select('*, venues(name)')
        .order('start_time')
        .range(offset, offset + limit - 1)

      if (venueId) query = query.eq('venue_id', venueId)
      if (eventType) query = query.eq('event_type', eventType)
      if (status) query = query.eq('status', status)
      if (startAfter) query = query.gte('start_time', startAfter)
      if (startBefore) query = query.lte('start_time', startBefore)
      if (isFeatured === 'true') query = query.eq('is_featured', true)

      const { data: events, error } = await query

      if (error) throw error

      const eventResponses = (events || []).map(e => ({
        ...e,
        venue_name: e.venues?.name || null,
        venues: undefined
      }))

      return new Response(
        JSON.stringify({ events: eventResponses, total: eventResponses.length, limit, offset }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    return new Response(
      JSON.stringify({ error: 'Method not allowed' }),
      { status: 405, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    console.error('Events function error:', error)
    return new Response(
      JSON.stringify({ error: error.message || 'Internal server error' }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})

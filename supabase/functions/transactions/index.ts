// Transactions Edge Function - WiesbadenAfterDark
// Handles point/coin transaction history for users

import "jsr:@supabase/functions-js/edge-runtime.d.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
}

interface PointTransaction {
  id: string
  user_id: string
  venue_id: string | null
  venue_name: string
  type: 'earn' | 'redeem' | 'bonus' | 'refund'
  source: string
  amount: number
  description: string
  balance_before: number
  balance_after: number
  check_in_id: string | null
  reward_id: string | null
  event_id: string | null
  timestamp: string
  created_at: string
}

Deno.serve(async (req) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const authHeader = req.headers.get('Authorization')

    const supabase = createClient(supabaseUrl, serviceRoleKey, {
      global: {
        headers: authHeader ? { Authorization: authHeader } : {}
      }
    })

    const url = new URL(req.url)
    const pathParts = url.pathname.split('/').filter(p => p && p !== 'transactions' && p !== 'functions' && p !== 'v1')

    // Parse path: /transactions/user/{userId}
    const subResource = pathParts[0] // "user"
    const userId = pathParts[1] || null

    // GET /transactions/user/{userId} - Get user's transaction history
    if (req.method === 'GET' && subResource === 'user' && userId) {
      const page = parseInt(url.searchParams.get('page') || '1')
      const limit = parseInt(url.searchParams.get('limit') || '20')
      const offset = (page - 1) * limit

      console.log(`Fetching transactions for user ${userId}, page ${page}, limit ${limit}`)

      // Get user's wallet first
      const { data: wallet, error: walletError } = await supabase
        .from('coin_wallets')
        .select('id, balance')
        .eq('user_id', userId)
        .single()

      if (walletError && walletError.code !== 'PGRST116') {
        console.error('Error fetching wallet:', walletError)
      }

      // Query coin_transactions for this user's wallet
      let query = supabase
        .from('coin_transactions')
        .select(`
          id,
          amount,
          value_at_transaction,
          transaction_type,
          description,
          metadata,
          created_at,
          booking_id
        `, { count: 'exact' })

      // If user has a wallet, filter by it
      if (wallet?.id) {
        query = query.or(`from_wallet_id.eq.${wallet.id},to_wallet_id.eq.${wallet.id}`)
      } else {
        // No wallet = no transactions, return empty
        return new Response(JSON.stringify({
          transactions: [],
          pagination: {
            page,
            limit,
            total: 0,
            total_pages: 0
          }
        }), {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        })
      }

      const { data: transactions, error, count } = await query
        .order('created_at', { ascending: false })
        .range(offset, offset + limit - 1)

      if (error) {
        console.error('Error fetching transactions:', error)
        throw error
      }

      // Transform to iOS-expected format
      const transformedTransactions: PointTransaction[] = (transactions || []).map((t: any, index: number) => {
        const isEarning = t.amount > 0
        const metadata = t.metadata || {}

        return {
          id: t.id,
          user_id: userId,
          venue_id: metadata.venue_id || null,
          venue_name: metadata.venue_name || 'Das Wohnzimmer',
          type: isEarning ? 'earn' : 'redeem',
          source: t.transaction_type || 'check_in',
          amount: Math.abs(t.amount) * (isEarning ? 1 : -1),
          description: t.description || (isEarning ? 'Points earned' : 'Points redeemed'),
          balance_before: 0, // Would need running balance calculation
          balance_after: 0,
          check_in_id: metadata.check_in_id || null,
          reward_id: metadata.reward_id || null,
          event_id: metadata.event_id || null,
          timestamp: t.created_at,
          created_at: t.created_at
        }
      })

      const totalPages = Math.ceil((count || 0) / limit)

      return new Response(JSON.stringify({
        transactions: transformedTransactions,
        pagination: {
          page,
          limit,
          total: count || 0,
          total_pages: totalPages
        }
      }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      })
    }

    // POST /transactions - Create a new transaction
    if (req.method === 'POST' && !subResource) {
      const body = await req.json()

      const {
        user_id,
        amount,
        transaction_type,
        description,
        venue_id,
        venue_name,
        check_in_id,
        reward_id,
        event_id
      } = body

      if (!user_id || amount === undefined) {
        return new Response(JSON.stringify({ error: 'user_id and amount are required' }), {
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        })
      }

      // Get or create user's wallet
      let { data: wallet, error: walletError } = await supabase
        .from('coin_wallets')
        .select('id, balance')
        .eq('user_id', user_id)
        .single()

      if (walletError && walletError.code === 'PGRST116') {
        // Create wallet if doesn't exist
        const { data: newWallet, error: createError } = await supabase
          .from('coin_wallets')
          .insert({ user_id, balance: 0 })
          .select()
          .single()

        if (createError) throw createError
        wallet = newWallet
      } else if (walletError) {
        throw walletError
      }

      // Create transaction
      const { data: transaction, error: txError } = await supabase
        .from('coin_transactions')
        .insert({
          to_wallet_id: amount > 0 ? wallet.id : null,
          from_wallet_id: amount < 0 ? wallet.id : null,
          amount: Math.abs(amount),
          transaction_type: transaction_type || 'manual',
          description: description || '',
          metadata: {
            venue_id,
            venue_name,
            check_in_id,
            reward_id,
            event_id
          }
        })
        .select()
        .single()

      if (txError) throw txError

      // Update wallet balance
      const newBalance = (wallet.balance || 0) + amount
      await supabase
        .from('coin_wallets')
        .update({ balance: newBalance })
        .eq('id', wallet.id)

      return new Response(JSON.stringify({
        success: true,
        transaction: {
          id: transaction.id,
          amount,
          new_balance: newBalance
        }
      }), {
        status: 201,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      })
    }

    // 404 for unknown routes
    return new Response(JSON.stringify({ error: 'Not found' }), {
      status: 404,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' }
    })

  } catch (error) {
    console.error('Transaction function error:', error)
    return new Response(JSON.stringify({
      error: error.message || 'Internal server error'
    }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' }
    })
  }
})

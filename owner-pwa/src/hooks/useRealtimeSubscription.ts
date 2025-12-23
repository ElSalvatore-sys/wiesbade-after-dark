// useRealtimeSubscription - Hook for auto-refreshing UI when Supabase data changes
// Subscribes to Realtime channels and triggers refetch callbacks

import { useEffect, useRef, useCallback, useMemo } from 'react';
import { supabase } from '../lib/supabase';

// Tables that support Realtime subscriptions
export type RealtimeTable =
  | 'tasks'
  | 'shifts'
  | 'employees'
  | 'inventory_items'
  | 'inventory_transfers'
  | 'bookings'
  | 'events';

// Change event types
export type ChangeEvent = 'INSERT' | 'UPDATE' | 'DELETE' | '*';

interface SubscriptionConfig {
  table: RealtimeTable;
  event?: ChangeEvent;
  filter?: string; // e.g., 'venue_id=eq.{venueId}'
}

interface UseRealtimeSubscriptionOptions {
  subscriptions: SubscriptionConfig[];
  onDataChange: () => void | Promise<void>;
  venueId?: string;
  enabled?: boolean;
  debounceMs?: number;
}

/**
 * Hook that subscribes to Supabase Realtime and triggers refetch on data changes
 *
 * @example
 * ```tsx
 * useRealtimeSubscription({
 *   subscriptions: [
 *     { table: 'tasks', event: '*' },
 *     { table: 'shifts', event: '*' },
 *   ],
 *   onDataChange: () => fetchDashboard(true),
 *   venueId: 'venue-uuid',
 *   enabled: !loading,
 * });
 * ```
 */
export function useRealtimeSubscription({
  subscriptions,
  onDataChange,
  venueId,
  enabled = true,
  debounceMs = 500,
}: UseRealtimeSubscriptionOptions): void {
  const channelRef = useRef<ReturnType<typeof supabase.channel> | null>(null);
  const timeoutRef = useRef<ReturnType<typeof setTimeout> | null>(null);
  const lastChangeRef = useRef<number>(0);

  // Memoize subscriptions to prevent unnecessary re-renders
  const subscriptionKey = useMemo(
    () => subscriptions.map(s => `${s.table}:${s.event || '*'}`).join(','),
    [subscriptions]
  );

  // Debounced callback to prevent rapid-fire refetches
  const debouncedRefetch = useCallback(() => {
    const now = Date.now();

    // Clear any pending timeout
    if (timeoutRef.current) {
      clearTimeout(timeoutRef.current);
    }

    // If we just refetched, debounce the next one
    if (now - lastChangeRef.current < debounceMs) {
      timeoutRef.current = setTimeout(() => {
        lastChangeRef.current = Date.now();
        onDataChange();
      }, debounceMs);
    } else {
      lastChangeRef.current = now;
      onDataChange();
    }
  }, [onDataChange, debounceMs]);

  useEffect(() => {
    if (!enabled || subscriptions.length === 0) {
      return;
    }

    // Create unique channel name
    const channelName = `realtime-ui-${Date.now()}`;

    // Build the channel with all subscriptions
    // We use the same pattern as pushNotifications.ts - chain directly
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    let channel: any = supabase.channel(channelName);

    // Add subscriptions for each table
    subscriptions.forEach(({ table, event = '*', filter }) => {
      // Build filter string with venueId if provided
      let filterString = filter;
      if (!filterString && venueId) {
        filterString = `venue_id=eq.${venueId}`;
      }

      // For '*' event, we subscribe to all three types
      const events: Array<'INSERT' | 'UPDATE' | 'DELETE'> =
        event === '*' ? ['INSERT', 'UPDATE', 'DELETE'] : [event as 'INSERT' | 'UPDATE' | 'DELETE'];

      events.forEach(eventType => {
        const config = {
          event: eventType,
          schema: 'public',
          table: table,
          ...(filterString ? { filter: filterString } : {}),
        };

        channel = channel.on(
          'postgres_changes',
          config,
          // eslint-disable-next-line @typescript-eslint/no-explicit-any
          (payload: any) => {
            console.log(`🔄 [Realtime] ${table} ${payload.eventType}:`, payload.new || payload.old);
            debouncedRefetch();
          }
        );
      });
    });

    // Subscribe to channel
    channel.subscribe((status: string) => {
      if (status === 'SUBSCRIBED') {
        console.log(`✅ [Realtime] Subscribed to: ${subscriptions.map(s => s.table).join(', ')}`);
      } else if (status === 'CHANNEL_ERROR') {
        console.error('❌ [Realtime] Channel error');
      }
    });

    channelRef.current = channel;

    // Cleanup on unmount
    return () => {
      if (timeoutRef.current) {
        clearTimeout(timeoutRef.current);
      }
      if (channelRef.current) {
        console.log(`🔌 [Realtime] Unsubscribing from: ${subscriptions.map(s => s.table).join(', ')}`);
        supabase.removeChannel(channelRef.current);
        channelRef.current = null;
      }
    };
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [enabled, subscriptionKey, venueId, debouncedRefetch]);
}

/**
 * Simplified hook for single table subscription
 */
export function useRealtimeTable(
  table: RealtimeTable,
  onDataChange: () => void | Promise<void>,
  options?: { venueId?: string; enabled?: boolean }
): void {
  const subscriptions = useMemo(() => [{ table, event: '*' as const }], [table]);

  useRealtimeSubscription({
    subscriptions,
    onDataChange,
    venueId: options?.venueId,
    enabled: options?.enabled ?? true,
  });
}

export default useRealtimeSubscription;

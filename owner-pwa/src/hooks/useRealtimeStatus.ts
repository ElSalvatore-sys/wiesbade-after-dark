// useRealtimeStatus - Track Supabase Realtime connection status
// Shows a "LIVE" indicator in the UI when connected

import { useState, useEffect, useCallback } from 'react';
import { supabase } from '../lib/supabase';

export type RealtimeStatus = 'connecting' | 'connected' | 'disconnected' | 'error';

interface UseRealtimeStatusReturn {
  status: RealtimeStatus;
  isConnected: boolean;
  lastUpdate: Date | null;
  reconnect: () => void;
}

/**
 * Hook to track Supabase Realtime connection status
 *
 * @example
 * ```tsx
 * const { status, isConnected } = useRealtimeStatus();
 *
 * return (
 *   <div className={isConnected ? 'text-green-500' : 'text-gray-500'}>
 *     {isConnected ? 'LIVE' : 'OFFLINE'}
 *   </div>
 * );
 * ```
 */
export function useRealtimeStatus(): UseRealtimeStatusReturn {
  const [status, setStatus] = useState<RealtimeStatus>('connecting');
  const [lastUpdate, setLastUpdate] = useState<Date | null>(null);
  const [channel, setChannel] = useState<ReturnType<typeof supabase.channel> | null>(null);

  const setupChannel = useCallback(() => {
    // Clean up existing channel
    if (channel) {
      supabase.removeChannel(channel);
    }

    const newChannel = supabase.channel('status-check', {
      config: {
        presence: { key: 'owner-pwa' },
      },
    });

    newChannel
      .on('presence', { event: 'sync' }, () => {
        setStatus('connected');
        setLastUpdate(new Date());
      })
      .subscribe((status) => {
        switch (status) {
          case 'SUBSCRIBED':
            setStatus('connected');
            setLastUpdate(new Date());
            console.log('🟢 [Realtime] Connected');
            break;
          case 'CHANNEL_ERROR':
            setStatus('error');
            console.log('🔴 [Realtime] Error');
            break;
          case 'TIMED_OUT':
            setStatus('disconnected');
            console.log('🟡 [Realtime] Timed out');
            break;
          case 'CLOSED':
            setStatus('disconnected');
            console.log('⚪ [Realtime] Closed');
            break;
        }
      });

    // Track presence to keep connection alive
    newChannel.track({ online_at: new Date().toISOString() });

    setChannel(newChannel);
  }, []);

  const reconnect = useCallback(() => {
    setStatus('connecting');
    setupChannel();
  }, [setupChannel]);

  useEffect(() => {
    setupChannel();

    return () => {
      if (channel) {
        supabase.removeChannel(channel);
      }
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  return {
    status,
    isConnected: status === 'connected',
    lastUpdate,
    reconnect,
  };
}

export default useRealtimeStatus;

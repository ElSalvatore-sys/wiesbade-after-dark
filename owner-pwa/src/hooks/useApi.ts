import { useState, useCallback } from 'react';
import api from '../services/api';

export function useApi() {
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const call = useCallback(async <T>(
    apiCall: () => Promise<{ data?: T; error?: string }>
  ): Promise<T | null> => {
    setLoading(true);
    setError(null);

    const result = await apiCall();

    setLoading(false);

    if (result.error) {
      setError(result.error);
      return null;
    }

    return result.data || null;
  }, []);

  return { loading, error, call, api };
}

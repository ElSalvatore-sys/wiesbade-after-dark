import { createContext, useContext, useState, useEffect } from 'react';
import type { ReactNode } from 'react';
import api from '../services/api';

export type UserRole = 'owner' | 'manager' | 'bartender' | 'inventory' | 'cleaning';

interface User {
  id: string;
  email: string;
  name: string;
  role: UserRole;
  venueId?: string;
  venueName?: string;
}

interface AuthContextType {
  user: User | null;
  isAuthenticated: boolean;
  isLoading: boolean;
  login: (email: string, password: string) => Promise<{ success: boolean; error?: string }>;
  logout: () => void;
  hasPermission: (permission: string) => boolean;
}

const ROLE_PERMISSIONS: Record<UserRole, string[]> = {
  owner: ['dashboard', 'events', 'bookings', 'inventory', 'employees', 'tasks', 'reports', 'settings'],
  manager: ['dashboard', 'events', 'bookings', 'inventory', 'tasks', 'reports'],
  bartender: ['dashboard', 'tasks'],
  inventory: ['dashboard', 'inventory', 'tasks', 'reports'],
  cleaning: ['dashboard', 'tasks'],
};

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    // Check for existing session
    const savedUser = localStorage.getItem('user');
    if (savedUser) {
      try {
        setUser(JSON.parse(savedUser));
      } catch {
        localStorage.removeItem('user');
      }
    }
    setIsLoading(false);
  }, []);

  const login = async (email: string, password: string) => {
    // Demo accounts for testing
    const demoAccounts: Record<string, User> = {
      'owner@example.com': { id: '1', email: 'owner@example.com', name: 'Max Müller', role: 'owner', venueId: 'demo', venueName: 'Das Wohnzimmer' },
      'manager@example.com': { id: '2', email: 'manager@example.com', name: 'Sarah Schmidt', role: 'manager', venueId: 'demo', venueName: 'Das Wohnzimmer' },
      'bartender@example.com': { id: '3', email: 'bartender@example.com', name: 'Tom Weber', role: 'bartender', venueId: 'demo', venueName: 'Das Wohnzimmer' },
      'inventory@example.com': { id: '4', email: 'inventory@example.com', name: 'Lisa Fischer', role: 'inventory', venueId: 'demo', venueName: 'Das Wohnzimmer' },
      'cleaning@example.com': { id: '5', email: 'cleaning@example.com', name: 'Hans Becker', role: 'cleaning', venueId: 'demo', venueName: 'Das Wohnzimmer' },
    };

    // Check demo accounts (password: "password" for all)
    if (password === 'password' && demoAccounts[email]) {
      const demoUser = demoAccounts[email];
      setUser(demoUser);
      localStorage.setItem('user', JSON.stringify(demoUser));
      api.setToken('demo_token');
      api.setVenueId(demoUser.venueId || 'demo');
      return { success: true };
    }

    // Try real API login
    const result = await api.login(email, password);

    if (result.error) {
      return { success: false, error: result.error };
    }

    if (result.data) {
      const apiData = result.data as { user?: { id?: string; name?: string; role?: UserRole; venue_id?: string; venue_name?: string } };
      const userData: User = {
        id: apiData.user?.id || '1',
        email: email,
        name: apiData.user?.name || email.split('@')[0],
        role: apiData.user?.role || 'owner',
        venueId: apiData.user?.venue_id,
        venueName: apiData.user?.venue_name,
      };
      setUser(userData);
      localStorage.setItem('user', JSON.stringify(userData));
      return { success: true };
    }

    return { success: false, error: 'Login failed' };
  };

  const logout = () => {
    setUser(null);
    localStorage.removeItem('user');
    api.clearAuth();
  };

  const hasPermission = (permission: string) => {
    if (!user) return false;
    return ROLE_PERMISSIONS[user.role]?.includes(permission) || false;
  };

  return (
    <AuthContext.Provider value={{
      user,
      isAuthenticated: !!user,
      isLoading,
      login,
      logout,
      hasPermission,
    }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within AuthProvider');
  }
  return context;
}

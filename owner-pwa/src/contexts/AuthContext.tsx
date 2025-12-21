import { createContext, useContext, useState, useEffect } from 'react';
import type { ReactNode } from 'react';
import { supabase } from '../lib/supabase';
import { supabaseApi } from '../services/supabaseApi';

export type UserRole = 'owner' | 'manager' | 'bartender' | 'waiter' | 'security' | 'dj' | 'inventory' | 'cleaning';

interface User {
  id: string;
  email: string;
  name: string;
  role: UserRole;
  venueId?: string;
  venueName?: string;
  employeeId?: string;
}

interface AuthContextType {
  user: User | null;
  isAuthenticated: boolean;
  isLoading: boolean;
  login: (email: string, password: string) => Promise<{ success: boolean; error?: string }>;
  logout: () => Promise<void>;
  hasPermission: (permission: string) => boolean;
}

const ROLE_PERMISSIONS: Record<UserRole, string[]> = {
  owner: ['dashboard', 'events', 'bookings', 'inventory', 'employees', 'shifts', 'tasks', 'analytics', 'settings'],
  manager: ['dashboard', 'events', 'bookings', 'inventory', 'shifts', 'tasks', 'analytics'],
  bartender: ['dashboard', 'shifts', 'tasks', 'inventory'],
  waiter: ['dashboard', 'shifts', 'tasks'],
  security: ['dashboard', 'shifts', 'tasks', 'bookings'],
  dj: ['dashboard', 'shifts', 'events'],
  inventory: ['dashboard', 'inventory', 'shifts', 'tasks', 'analytics'],
  cleaning: ['dashboard', 'shifts', 'tasks'],
};

const AuthContext = createContext<AuthContextType | undefined>(undefined);

// Demo accounts for development/testing
const DEMO_ACCOUNTS: Record<string, User> = {
  'owner@example.com': { id: '1', email: 'owner@example.com', name: 'Max Müller', role: 'owner', venueId: 'a1b2c3d4-e5f6-7890-abcd-ef1234567890', venueName: 'Das Wohnzimmer' },
  'manager@example.com': { id: '2', email: 'manager@example.com', name: 'Sarah Schmidt', role: 'manager', venueId: 'a1b2c3d4-e5f6-7890-abcd-ef1234567890', venueName: 'Das Wohnzimmer' },
  'bartender@example.com': { id: '3', email: 'bartender@example.com', name: 'Tom Weber', role: 'bartender', venueId: 'a1b2c3d4-e5f6-7890-abcd-ef1234567890', venueName: 'Das Wohnzimmer' },
  'inventory@example.com': { id: '4', email: 'inventory@example.com', name: 'Lisa Fischer', role: 'inventory', venueId: 'a1b2c3d4-e5f6-7890-abcd-ef1234567890', venueName: 'Das Wohnzimmer' },
  'cleaning@example.com': { id: '5', email: 'cleaning@example.com', name: 'Hans Becker', role: 'cleaning', venueId: 'a1b2c3d4-e5f6-7890-abcd-ef1234567890', venueName: 'Das Wohnzimmer' },
};

// Helper to fetch employee data from Supabase by email
async function fetchEmployeeByEmail(email: string): Promise<User | null> {
  const { data, error } = await supabase
    .from('employees')
    .select('id, name, email, role, venue_id')
    .eq('email', email)
    .eq('is_active', true)
    .single();

  if (error || !data) return null;

  // Fetch venue name
  const { data: venue } = await supabase
    .from('venues')
    .select('name')
    .eq('id', data.venue_id)
    .single();

  return {
    id: data.id,
    email: data.email || email,
    name: data.name,
    role: data.role as UserRole,
    venueId: data.venue_id,
    venueName: venue?.name || 'Unknown Venue',
    employeeId: data.id,
  };
}

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  // Initialize auth state from Supabase session
  useEffect(() => {
    const initAuth = async () => {
      try {
        // Check for existing Supabase session
        const { data: { session } } = await supabase.auth.getSession();

        if (session?.user) {
          // Try to get employee data
          const employeeData = await fetchEmployeeByEmail(session.user.email || '');
          if (employeeData) {
            setUser(employeeData);
            supabaseApi.setVenueId(employeeData.venueId || '');
          }
        } else {
          // Check for demo user in localStorage (development mode)
          const savedUser = localStorage.getItem('user');
          if (savedUser) {
            try {
              const parsed = JSON.parse(savedUser);
              setUser(parsed);
              if (parsed.venueId) {
                supabaseApi.setVenueId(parsed.venueId);
              }
            } catch {
              localStorage.removeItem('user');
            }
          }
        }
      } catch (error) {
        console.error('Auth initialization error:', error);
      }
      setIsLoading(false);
    };

    initAuth();

    // Subscribe to auth state changes
    const { data: { subscription } } = supabase.auth.onAuthStateChange(async (event, session) => {
      if (event === 'SIGNED_IN' && session?.user) {
        const employeeData = await fetchEmployeeByEmail(session.user.email || '');
        if (employeeData) {
          setUser(employeeData);
          supabaseApi.setVenueId(employeeData.venueId || '');
        }
      } else if (event === 'SIGNED_OUT') {
        setUser(null);
        localStorage.removeItem('user');
      }
    });

    return () => subscription.unsubscribe();
  }, []);

  const login = async (email: string, password: string) => {
    // Check demo accounts first (password: "password" for all)
    if (password === 'password' && DEMO_ACCOUNTS[email]) {
      const demoUser = DEMO_ACCOUNTS[email];
      setUser(demoUser);
      localStorage.setItem('user', JSON.stringify(demoUser));
      supabaseApi.setVenueId(demoUser.venueId || '');
      return { success: true };
    }

    // Try Supabase Auth
    const { data, error } = await supabase.auth.signInWithPassword({
      email,
      password,
    });

    if (error) {
      return { success: false, error: error.message };
    }

    if (data.user) {
      // Fetch employee data from employees table
      const employeeData = await fetchEmployeeByEmail(email);

      if (employeeData) {
        setUser(employeeData);
        supabaseApi.setVenueId(employeeData.venueId || '');
        return { success: true };
      } else {
        // User authenticated but no employee record - likely first time setup
        // Create basic user without employee record
        setUser({
          id: data.user.id,
          email: data.user.email || email,
          name: data.user.user_metadata?.name || email.split('@')[0],
          role: 'owner', // Default role for new users
        });
        return { success: true };
      }
    }

    return { success: false, error: 'Login failed' };
  };

  const logout = async () => {
    // Sign out from Supabase
    await supabase.auth.signOut();

    // Clear local state
    setUser(null);
    localStorage.removeItem('user');
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

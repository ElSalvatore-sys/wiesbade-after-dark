import { createClient } from '@supabase/supabase-js';

// Supabase configuration
const SUPABASE_URL = import.meta.env.VITE_SUPABASE_URL || 'https://yyplbhrqtaeyzmcxpfli.supabase.co';
const SUPABASE_ANON_KEY = import.meta.env.VITE_SUPABASE_ANON_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inl5cGxiaHJxdGFleXptY3hwZmxpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ4NTMzMjcsImV4cCI6MjA4MDQyOTMyN30.qY10_JBCACxptGnrqS_ILhWsNsmMKgEitaXEtViBRQc';

export const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

// Database types for WiesbadenAfterDark
export interface Employee {
  id: string;
  venue_id: string;
  name: string;
  email: string | null;
  phone: string | null;
  role: 'owner' | 'manager' | 'bartender' | 'waiter' | 'security' | 'dj' | 'cleaning';
  pin_hash: string | null;
  hourly_rate: number;
  is_active: boolean;
  created_at: string;
  updated_at: string;
}

export interface Shift {
  id: string;
  venue_id: string;
  employee_id: string;
  employee_name: string;
  employee_role: string;
  started_at: string;
  ended_at: string | null;
  break_start: string | null;
  total_break_minutes: number;
  expected_hours: number;
  actual_hours: number | null;
  overtime_minutes: number;
  status: 'active' | 'completed' | 'cancelled';
  notes: string | null;
  created_at: string;
  updated_at: string;
  // Joined employee data
  employee?: Employee;
}

export interface Task {
  id: string;
  venue_id: string;
  title: string;
  description: string | null;
  category: 'cleaning' | 'inventory' | 'bar' | 'kitchen' | 'general' | 'closing';
  priority: 'low' | 'medium' | 'high' | 'urgent';
  assigned_to: string | null;
  shift_id: string | null;
  due_date: string | null;
  completed_at: string | null;
  status: 'pending' | 'in_progress' | 'completed' | 'approved' | 'rejected';
  photo_url: string | null;
  completion_notes: string | null;
  approved_by: string | null;
  rejection_reason: string | null;
  created_at: string;
  updated_at: string;
  // Joined data
  assigned_employee?: Employee;
}

export interface InventoryItem {
  id: string;
  venue_id: string;
  product_id: string | null;
  name: string;
  category: string;
  barcode: string | null;
  storage_quantity: number;
  bar_quantity: number;
  min_stock_level: number;
  cost_price: number | null;
  sell_price: number | null;
  last_counted_at: string | null;
  last_counted_by: string | null;
  is_active: boolean;
  created_at: string;
  updated_at: string;
}

export interface InventoryTransfer {
  id: string;
  venue_id: string;
  inventory_item_id: string;
  from_location: 'storage' | 'bar';
  to_location: 'storage' | 'bar';
  quantity: number;
  transferred_by: string | null;
  transferred_at: string;
  notes: string | null;
}

export interface VenueBooking {
  id: string;
  venue_id: string;
  user_id: string | null;
  user_name: string;
  user_phone: string;
  user_email: string | null;
  date: string;
  time: string;
  party_size: number;
  table_number: string | null;
  status: 'pending' | 'confirmed' | 'cancelled' | 'completed' | 'no_show';
  notes: string | null;
  created_at: string;
  updated_at: string;
}

export default supabase;

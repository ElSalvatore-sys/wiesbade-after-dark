import { supabase, type Employee, type Shift, type Task, type InventoryItem, type InventoryTransfer } from '../lib/supabase';

// Default venue ID for Das Wohnzimmer (from seed data)
const DEFAULT_VENUE_ID = 'a1b2c3d4-e5f6-7890-abcd-ef1234567890';

class SupabaseApiService {
  private venueId: string;

  constructor() {
    this.venueId = localStorage.getItem('venue_id') || DEFAULT_VENUE_ID;
  }

  setVenueId(venueId: string) {
    this.venueId = venueId;
    localStorage.setItem('venue_id', venueId);
  }

  getVenueId() {
    return this.venueId;
  }

  // ============ EMPLOYEES ============
  async getEmployees(): Promise<{ data: Employee[] | null; error: Error | null }> {
    const { data, error } = await supabase
      .from('employees')
      .select('*')
      .eq('venue_id', this.venueId)
      .eq('is_active', true)
      .order('name');

    return { data, error: error as Error | null };
  }

  async getEmployee(employeeId: string): Promise<{ data: Employee | null; error: Error | null }> {
    const { data, error } = await supabase
      .from('employees')
      .select('*')
      .eq('id', employeeId)
      .single();

    return { data, error: error as Error | null };
  }

  async verifyEmployeePin(employeeId: string, pin: string): Promise<{ valid: boolean; employee: Employee | null }> {
    const { data, error } = await supabase
      .from('employees')
      .select('*')
      .eq('id', employeeId)
      .eq('pin_hash', pin) // For now, compare directly (should be hashed in production)
      .single();

    if (error || !data) {
      return { valid: false, employee: null };
    }

    return { valid: true, employee: data };
  }

  // ============ SHIFTS ============
  async getActiveShifts(): Promise<{ data: (Shift & { employee: Employee })[] | null; error: Error | null }> {
    const { data, error } = await supabase
      .from('shifts')
      .select(`
        *,
        employee:employees(*)
      `)
      .eq('venue_id', this.venueId)
      .eq('status', 'active')
      .order('clock_in', { ascending: false });

    return { data: data as (Shift & { employee: Employee })[] | null, error: error as Error | null };
  }

  async getShiftsHistory(params?: {
    startDate?: string;
    endDate?: string;
    employeeId?: string;
    limit?: number;
  }): Promise<{ data: (Shift & { employee: Employee })[] | null; error: Error | null }> {
    let query = supabase
      .from('shifts')
      .select(`
        *,
        employee:employees(*)
      `)
      .eq('venue_id', this.venueId)
      .order('clock_in', { ascending: false });

    if (params?.startDate) {
      query = query.gte('clock_in', params.startDate);
    }
    if (params?.endDate) {
      query = query.lte('clock_in', params.endDate);
    }
    if (params?.employeeId) {
      query = query.eq('employee_id', params.employeeId);
    }
    if (params?.limit) {
      query = query.limit(params.limit);
    }

    const { data, error } = await query;
    return { data: data as (Shift & { employee: Employee })[] | null, error: error as Error | null };
  }

  async clockIn(employeeId: string, expectedHours: number = 8): Promise<{ data: Shift | null; error: Error | null }> {
    const { data, error } = await supabase
      .from('shifts')
      .insert({
        venue_id: this.venueId,
        employee_id: employeeId,
        clock_in: new Date().toISOString(),
        expected_hours: expectedHours,
        break_minutes: 0,
        overtime_minutes: 0,
        status: 'active',
      })
      .select()
      .single();

    return { data, error: error as Error | null };
  }

  async clockOut(shiftId: string, notes?: string): Promise<{ data: Shift | null; error: Error | null }> {
    // First get the shift to calculate actual hours
    const { data: shift } = await supabase
      .from('shifts')
      .select('clock_in, break_minutes, expected_hours')
      .eq('id', shiftId)
      .single();

    if (!shift) {
      return { data: null, error: new Error('Shift not found') };
    }

    const clockOut = new Date();
    const clockIn = new Date(shift.clock_in);
    const totalMinutes = Math.floor((clockOut.getTime() - clockIn.getTime()) / 60000);
    const workingMinutes = totalMinutes - (shift.break_minutes || 0);
    const actualHours = workingMinutes / 60;
    const overtimeMinutes = Math.max(0, workingMinutes - (shift.expected_hours * 60));

    const { data, error } = await supabase
      .from('shifts')
      .update({
        clock_out: clockOut.toISOString(),
        actual_hours: parseFloat(actualHours.toFixed(2)),
        overtime_minutes: overtimeMinutes,
        status: 'completed',
        notes: notes || null,
      })
      .eq('id', shiftId)
      .select()
      .single();

    return { data, error: error as Error | null };
  }

  async startBreak(shiftId: string): Promise<{ data: Shift | null; error: Error | null }> {
    const { data, error } = await supabase
      .from('shifts')
      .update({
        break_start: new Date().toISOString(),
      })
      .eq('id', shiftId)
      .select()
      .single();

    return { data, error: error as Error | null };
  }

  async endBreak(shiftId: string): Promise<{ data: Shift | null; error: Error | null }> {
    // Get current shift to calculate break duration
    const { data: shift } = await supabase
      .from('shifts')
      .select('break_start, break_minutes')
      .eq('id', shiftId)
      .single();

    if (!shift || !shift.break_start) {
      return { data: null, error: new Error('No active break found') };
    }

    const breakEnd = new Date();
    const breakStart = new Date(shift.break_start);
    const breakDuration = Math.floor((breakEnd.getTime() - breakStart.getTime()) / 60000);
    const totalBreakMinutes = (shift.break_minutes || 0) + breakDuration;

    const { data, error } = await supabase
      .from('shifts')
      .update({
        break_start: null,
        break_minutes: totalBreakMinutes,
      })
      .eq('id', shiftId)
      .select()
      .single();

    return { data, error: error as Error | null };
  }

  async getShiftsSummary(): Promise<{
    activeShifts: number;
    totalHoursToday: number;
    totalOvertimeToday: number;
    employeesOnBreak: number;
  }> {
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const { data: activeShifts } = await supabase
      .from('shifts')
      .select('*, employee:employees(*)')
      .eq('venue_id', this.venueId)
      .eq('status', 'active');

    const { data: todayShifts } = await supabase
      .from('shifts')
      .select('*')
      .eq('venue_id', this.venueId)
      .gte('clock_in', today.toISOString());

    let totalHoursToday = 0;
    let totalOvertimeToday = 0;
    let employeesOnBreak = 0;

    if (activeShifts) {
      for (const shift of activeShifts) {
        const clockIn = new Date(shift.clock_in);
        const now = new Date();
        const totalMinutes = Math.floor((now.getTime() - clockIn.getTime()) / 60000);
        const workingMinutes = totalMinutes - (shift.break_minutes || 0);
        totalHoursToday += workingMinutes / 60;

        if (workingMinutes > shift.expected_hours * 60) {
          totalOvertimeToday += workingMinutes - (shift.expected_hours * 60);
        }

        if (shift.break_start) {
          employeesOnBreak++;
        }
      }
    }

    // Add completed shifts from today
    if (todayShifts) {
      for (const shift of todayShifts) {
        if (shift.status === 'completed' && shift.actual_hours) {
          totalHoursToday += shift.actual_hours;
        }
        if (shift.overtime_minutes) {
          totalOvertimeToday += shift.overtime_minutes;
        }
      }
    }

    return {
      activeShifts: activeShifts?.length || 0,
      totalHoursToday: parseFloat(totalHoursToday.toFixed(1)),
      totalOvertimeToday,
      employeesOnBreak,
    };
  }

  // ============ TASKS ============
  async getTasks(params?: {
    status?: string;
    category?: string;
    assignedTo?: string;
  }): Promise<{ data: (Task & { assigned_employee: Employee | null })[] | null; error: Error | null }> {
    let query = supabase
      .from('tasks')
      .select(`
        *,
        assigned_employee:employees(*)
      `)
      .eq('venue_id', this.venueId)
      .order('created_at', { ascending: false });

    if (params?.status) {
      query = query.eq('status', params.status);
    }
    if (params?.category) {
      query = query.eq('category', params.category);
    }
    if (params?.assignedTo) {
      query = query.eq('assigned_to', params.assignedTo);
    }

    const { data, error } = await query;
    return { data: data as (Task & { assigned_employee: Employee | null })[] | null, error: error as Error | null };
  }

  async createTask(task: Partial<Task>): Promise<{ data: Task | null; error: Error | null }> {
    const { data, error } = await supabase
      .from('tasks')
      .insert({
        venue_id: this.venueId,
        ...task,
      })
      .select()
      .single();

    return { data, error: error as Error | null };
  }

  async updateTask(taskId: string, updates: Partial<Task>): Promise<{ data: Task | null; error: Error | null }> {
    const { data, error } = await supabase
      .from('tasks')
      .update(updates)
      .eq('id', taskId)
      .select()
      .single();

    return { data, error: error as Error | null };
  }

  async deleteTask(taskId: string): Promise<{ error: Error | null }> {
    const { error } = await supabase
      .from('tasks')
      .delete()
      .eq('id', taskId);

    return { error: error as Error | null };
  }

  // ============ INVENTORY ============
  async getInventoryItems(): Promise<{ data: InventoryItem[] | null; error: Error | null }> {
    const { data, error } = await supabase
      .from('inventory_items')
      .select('*')
      .eq('venue_id', this.venueId)
      .eq('is_active', true)
      .order('name');

    return { data, error: error as Error | null };
  }

  async updateInventoryQuantity(
    itemId: string,
    updates: { storage_quantity?: number; bar_quantity?: number }
  ): Promise<{ data: InventoryItem | null; error: Error | null }> {
    const { data, error } = await supabase
      .from('inventory_items')
      .update(updates)
      .eq('id', itemId)
      .select()
      .single();

    return { data, error: error as Error | null };
  }

  async createInventoryTransfer(
    itemId: string,
    fromLocation: 'storage' | 'bar',
    toLocation: 'storage' | 'bar',
    quantity: number,
    transferredBy?: string,
    notes?: string
  ): Promise<{ data: InventoryTransfer | null; error: Error | null }> {
    // First, get current quantities
    const { data: item } = await supabase
      .from('inventory_items')
      .select('storage_quantity, bar_quantity')
      .eq('id', itemId)
      .single();

    if (!item) {
      return { data: null, error: new Error('Item not found') };
    }

    // Calculate new quantities
    const newStorage = fromLocation === 'storage'
      ? item.storage_quantity - quantity
      : item.storage_quantity + quantity;
    const newBar = fromLocation === 'bar'
      ? item.bar_quantity - quantity
      : item.bar_quantity + quantity;

    // Validate
    if (newStorage < 0 || newBar < 0) {
      return { data: null, error: new Error('Insufficient quantity') };
    }

    // Update item quantities
    await supabase
      .from('inventory_items')
      .update({
        storage_quantity: newStorage,
        bar_quantity: newBar,
      })
      .eq('id', itemId);

    // Create transfer record
    const { data, error } = await supabase
      .from('inventory_transfers')
      .insert({
        venue_id: this.venueId,
        inventory_item_id: itemId,
        from_location: fromLocation,
        to_location: toLocation,
        quantity,
        transferred_by: transferredBy || null,
        notes: notes || null,
      })
      .select()
      .single();

    return { data, error: error as Error | null };
  }

  async getLowStockItems(): Promise<{ data: InventoryItem[] | null; error: Error | null }> {
    const { data, error } = await supabase
      .from('inventory_items')
      .select('*')
      .eq('venue_id', this.venueId)
      .eq('is_active', true);

    if (error || !data) {
      return { data: null, error: error as Error | null };
    }

    // Filter items where total quantity is below minimum
    const lowStock = data.filter(item =>
      (item.storage_quantity + item.bar_quantity) < item.min_stock_level
    );

    return { data: lowStock, error: null };
  }
}

export const supabaseApi = new SupabaseApiService();
export default supabaseApi;

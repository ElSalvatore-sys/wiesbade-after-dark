import { supabase, type Employee, type Shift, type Task, type InventoryItem, type InventoryTransfer, type VenueBooking } from '../lib/supabase';

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
  async getEmployees(includeInactive = false): Promise<{ data: Employee[] | null; error: Error | null }> {
    let query = supabase
      .from('employees')
      .select('*')
      .eq('venue_id', this.venueId)
      .order('name');

    if (!includeInactive) {
      query = query.eq('is_active', true);
    }

    const { data, error } = await query;
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

  async createEmployee(employee: Partial<Employee>): Promise<{ data: Employee | null; error: Error | null }> {
    const { data, error } = await supabase
      .from('employees')
      .insert({
        venue_id: this.venueId,
        ...employee,
        is_active: employee.is_active ?? true,
      })
      .select()
      .single();

    return { data, error: error as Error | null };
  }

  async updateEmployee(employeeId: string, updates: Partial<Employee>): Promise<{ data: Employee | null; error: Error | null }> {
    const { data, error } = await supabase
      .from('employees')
      .update({
        ...updates,
        updated_at: new Date().toISOString(),
      })
      .eq('id', employeeId)
      .select()
      .single();

    return { data, error: error as Error | null };
  }

  async deleteEmployee(employeeId: string): Promise<{ error: Error | null }> {
    // Soft delete by setting is_active to false
    const { error } = await supabase
      .from('employees')
      .update({ is_active: false, updated_at: new Date().toISOString() })
      .eq('id', employeeId);

    return { error: error as Error | null };
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
      .order('started_at', { ascending: false });

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
      .order('started_at', { ascending: false });

    if (params?.startDate) {
      query = query.gte('started_at', params.startDate);
    }
    if (params?.endDate) {
      query = query.lte('started_at', params.endDate);
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
        started_at: new Date().toISOString(),
        expected_hours: expectedHours,
        total_break_minutes: 0,
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
      .select('started_at, total_break_minutes, expected_hours')
      .eq('id', shiftId)
      .single();

    if (!shift) {
      return { data: null, error: new Error('Shift not found') };
    }

    const clockOut = new Date();
    const clockIn = new Date(shift.started_at);
    const totalMinutes = Math.floor((clockOut.getTime() - clockIn.getTime()) / 60000);
    const workingMinutes = totalMinutes - (shift.total_break_minutes || 0);
    const actualHours = workingMinutes / 60;
    const overtimeMinutes = Math.max(0, workingMinutes - (shift.expected_hours * 60));

    const { data, error } = await supabase
      .from('shifts')
      .update({
        ended_at: clockOut.toISOString(),
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
      .select('break_start, total_break_minutes')
      .eq('id', shiftId)
      .single();

    if (!shift || !shift.break_start) {
      return { data: null, error: new Error('No active break found') };
    }

    const breakEnd = new Date();
    const breakStart = new Date(shift.break_start);
    const breakDuration = Math.floor((breakEnd.getTime() - breakStart.getTime()) / 60000);
    const totalBreakMinutes = (shift.total_break_minutes || 0) + breakDuration;

    const { data, error } = await supabase
      .from('shifts')
      .update({
        break_start: null,
        total_break_minutes: totalBreakMinutes,
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
      .gte('started_at', today.toISOString());

    let totalHoursToday = 0;
    let totalOvertimeToday = 0;
    let employeesOnBreak = 0;

    if (activeShifts) {
      for (const shift of activeShifts) {
        const clockIn = new Date(shift.started_at);
        const now = new Date();
        const totalMinutes = Math.floor((now.getTime() - clockIn.getTime()) / 60000);
        const workingMinutes = totalMinutes - (shift.total_break_minutes || 0);
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

  // ============ VENUE BOOKINGS ============
  async getBookings(params?: {
    date?: string;
    status?: string;
    startDate?: string;
    endDate?: string;
  }): Promise<{ data: VenueBooking[] | null; error: Error | null }> {
    let query = supabase
      .from('venue_bookings')
      .select('*')
      .eq('venue_id', this.venueId)
      .order('date', { ascending: true })
      .order('time', { ascending: true });

    if (params?.date) {
      query = query.eq('date', params.date);
    }
    if (params?.status) {
      query = query.eq('status', params.status);
    }
    if (params?.startDate) {
      query = query.gte('date', params.startDate);
    }
    if (params?.endDate) {
      query = query.lte('date', params.endDate);
    }

    const { data, error } = await query;
    return { data, error: error as Error | null };
  }

  async getBooking(bookingId: string): Promise<{ data: VenueBooking | null; error: Error | null }> {
    const { data, error } = await supabase
      .from('venue_bookings')
      .select('*')
      .eq('id', bookingId)
      .single();

    return { data, error: error as Error | null };
  }

  async createBooking(booking: Partial<VenueBooking>): Promise<{ data: VenueBooking | null; error: Error | null }> {
    const { data, error } = await supabase
      .from('venue_bookings')
      .insert({
        venue_id: this.venueId,
        ...booking,
        status: booking.status ?? 'pending',
      })
      .select()
      .single();

    return { data, error: error as Error | null };
  }

  async updateBooking(bookingId: string, updates: Partial<VenueBooking>): Promise<{ data: VenueBooking | null; error: Error | null }> {
    const { data, error } = await supabase
      .from('venue_bookings')
      .update({
        ...updates,
        updated_at: new Date().toISOString(),
      })
      .eq('id', bookingId)
      .select()
      .single();

    return { data, error: error as Error | null };
  }

  async deleteBooking(bookingId: string): Promise<{ error: Error | null }> {
    const { error } = await supabase
      .from('venue_bookings')
      .delete()
      .eq('id', bookingId);

    return { error: error as Error | null };
  }

  async getBookingsSummary(date?: string): Promise<{
    total: number;
    pending: number;
    confirmed: number;
    cancelled: number;
    totalGuests: number;
  }> {
    const targetDate = date || new Date().toISOString().split('T')[0];

    const { data } = await supabase
      .from('venue_bookings')
      .select('*')
      .eq('venue_id', this.venueId)
      .eq('date', targetDate);

    if (!data) {
      return { total: 0, pending: 0, confirmed: 0, cancelled: 0, totalGuests: 0 };
    }

    return {
      total: data.length,
      pending: data.filter(b => b.status === 'pending').length,
      confirmed: data.filter(b => b.status === 'confirmed').length,
      cancelled: data.filter(b => b.status === 'cancelled').length,
      totalGuests: data.reduce((sum, b) => sum + b.party_size, 0),
    };
  }

  // ============ ANALYTICS ============
  async getLaborCostsByRole(params?: {
    startDate?: string;
    endDate?: string;
  }): Promise<{
    data: Array<{
      role: string;
      totalHours: number;
      totalCost: number;
      shiftCount: number;
    }> | null;
    error: Error | null;
  }> {
    let query = supabase
      .from('shifts')
      .select(`
        *,
        employee:employees(role, hourly_rate)
      `)
      .eq('venue_id', this.venueId)
      .eq('status', 'completed');

    if (params?.startDate) {
      query = query.gte('started_at', params.startDate);
    }
    if (params?.endDate) {
      query = query.lte('started_at', params.endDate);
    }

    const { data, error } = await query;

    if (error || !data) {
      return { data: null, error: error as Error | null };
    }

    // Group by role
    const roleMap = new Map<string, { totalHours: number; totalCost: number; shiftCount: number }>();

    for (const shift of data) {
      // Supabase joins return arrays, access first element
      const employeeData = shift.employee as { role: string; hourly_rate: number }[] | null;
      const role = employeeData?.[0]?.role || 'unknown';
      const hours = shift.actual_hours || 0;
      const hourlyRate = employeeData?.[0]?.hourly_rate || 0;
      const cost = hours * hourlyRate;

      const existing = roleMap.get(role) || { totalHours: 0, totalCost: 0, shiftCount: 0 };
      roleMap.set(role, {
        totalHours: existing.totalHours + hours,
        totalCost: existing.totalCost + cost,
        shiftCount: existing.shiftCount + 1,
      });
    }

    const result = Array.from(roleMap.entries()).map(([role, data]) => ({
      role,
      totalHours: parseFloat(data.totalHours.toFixed(1)),
      totalCost: parseFloat(data.totalCost.toFixed(2)),
      shiftCount: data.shiftCount,
    }));

    // Sort by cost descending
    result.sort((a, b) => b.totalCost - a.totalCost);

    return { data: result, error: null };
  }

  async getAnalyticsSummary(params?: {
    startDate?: string;
    endDate?: string;
  }): Promise<{
    totalLaborCost: number;
    totalHoursWorked: number;
    averageShiftLength: number;
    totalShifts: number;
    bookingsCount: number;
    totalGuests: number;
  }> {
    // Get shifts data
    let shiftQuery = supabase
      .from('shifts')
      .select(`
        actual_hours,
        employee:employees(hourly_rate)
      `)
      .eq('venue_id', this.venueId)
      .eq('status', 'completed');

    if (params?.startDate) {
      shiftQuery = shiftQuery.gte('started_at', params.startDate);
    }
    if (params?.endDate) {
      shiftQuery = shiftQuery.lte('started_at', params.endDate);
    }

    const { data: shifts } = await shiftQuery;

    // Get bookings data
    let bookingQuery = supabase
      .from('venue_bookings')
      .select('party_size')
      .eq('venue_id', this.venueId)
      .in('status', ['confirmed', 'completed']);

    if (params?.startDate) {
      bookingQuery = bookingQuery.gte('date', params.startDate);
    }
    if (params?.endDate) {
      bookingQuery = bookingQuery.lte('date', params.endDate);
    }

    const { data: bookings } = await bookingQuery;

    // Calculate metrics
    let totalLaborCost = 0;
    let totalHoursWorked = 0;

    if (shifts) {
      for (const shift of shifts) {
        const hours = shift.actual_hours || 0;
        // Supabase joins return arrays, access first element
        const employeeData = shift.employee as { hourly_rate: number }[] | null;
        const rate = employeeData?.[0]?.hourly_rate || 0;
        totalHoursWorked += hours;
        totalLaborCost += hours * rate;
      }
    }

    const totalShifts = shifts?.length || 0;
    const averageShiftLength = totalShifts > 0 ? totalHoursWorked / totalShifts : 0;

    const bookingsCount = bookings?.length || 0;
    const totalGuests = bookings?.reduce((sum, b) => sum + b.party_size, 0) || 0;

    return {
      totalLaborCost: parseFloat(totalLaborCost.toFixed(2)),
      totalHoursWorked: parseFloat(totalHoursWorked.toFixed(1)),
      averageShiftLength: parseFloat(averageShiftLength.toFixed(1)),
      totalShifts,
      bookingsCount,
      totalGuests,
    };
  }

  // ============ ADVANCED ANALYTICS ============

  /**
   * Get daily statistics for charts
   */
  async getDailyStats(params: {
    startDate: string;
    endDate: string;
  }): Promise<{
    data: {
      date: string;
      shifts: number;
      hoursWorked: number;
      laborCost: number;
      tasksCompleted: number;
      bookings: number;
    }[];
    error: Error | null;
  }> {
    // Get shifts with employee rates
    const { data: shifts } = await supabase
      .from('shifts')
      .select('started_at, ended_at, total_break_minutes, employee:employees(hourly_rate)')
      .eq('venue_id', this.venueId)
      .gte('started_at', params.startDate)
      .lte('started_at', params.endDate);

    // Get completed tasks
    const { data: tasks } = await supabase
      .from('tasks')
      .select('status, updated_at')
      .eq('venue_id', this.venueId)
      .in('status', ['completed', 'approved'])
      .gte('updated_at', params.startDate)
      .lte('updated_at', params.endDate);

    // Get bookings
    const { data: bookings } = await supabase
      .from('venue_bookings')
      .select('date')
      .eq('venue_id', this.venueId)
      .in('status', ['confirmed', 'completed'])
      .gte('date', params.startDate)
      .lte('date', params.endDate);

    // Group by date
    const dailyMap = new Map<string, {
      date: string;
      shifts: number;
      hoursWorked: number;
      laborCost: number;
      tasksCompleted: number;
      bookings: number;
    }>();

    // Initialize all dates in range
    const start = new Date(params.startDate);
    const end = new Date(params.endDate);
    const current = new Date(start);
    while (current <= end) {
      const dateKey = current.toISOString().split('T')[0];
      dailyMap.set(dateKey, {
        date: dateKey,
        shifts: 0,
        hoursWorked: 0,
        laborCost: 0,
        tasksCompleted: 0,
        bookings: 0,
      });
      current.setDate(current.getDate() + 1);
    }

    // Aggregate shifts
    (shifts || []).forEach(shift => {
      if (!shift.started_at) return;
      const dateKey = shift.started_at.split('T')[0];
      const stats = dailyMap.get(dateKey);
      if (!stats) return;

      stats.shifts++;

      if (shift.ended_at) {
        const clockIn = new Date(shift.started_at);
        const clockOut = new Date(shift.ended_at);
        const hours = (clockOut.getTime() - clockIn.getTime()) / (1000 * 60 * 60);
        const breakHours = (shift.total_break_minutes || 0) / 60;
        const netHours = Math.max(0, hours - breakHours);
        stats.hoursWorked += netHours;

        const employeeData = shift.employee as { hourly_rate: number }[] | null;
        const rate = employeeData?.[0]?.hourly_rate || 12;
        stats.laborCost += netHours * rate;
      }
    });

    // Aggregate tasks
    (tasks || []).forEach(task => {
      if (!task.updated_at) return;
      const dateKey = task.updated_at.split('T')[0];
      const stats = dailyMap.get(dateKey);
      if (stats) stats.tasksCompleted++;
    });

    // Aggregate bookings
    (bookings || []).forEach(booking => {
      if (!booking.date) return;
      const dateKey = booking.date.split('T')[0];
      const stats = dailyMap.get(dateKey);
      if (stats) stats.bookings++;
    });

    // Round values
    const result = Array.from(dailyMap.values()).map(stats => ({
      ...stats,
      hoursWorked: Math.round(stats.hoursWorked * 100) / 100,
      laborCost: Math.round(stats.laborCost * 100) / 100,
    }));

    return { data: result, error: null };
  }

  /**
   * Get per-employee statistics
   */
  async getEmployeePerformance(params: {
    startDate: string;
    endDate: string;
  }): Promise<{
    data: {
      id: string;
      name: string;
      role: string;
      totalShifts: number;
      totalHours: number;
      totalEarnings: number;
      avgShiftLength: number;
      tasksCompleted: number;
    }[];
    error: Error | null;
  }> {
    // Get employees with shifts in range
    const { data: employees } = await supabase
      .from('employees')
      .select('id, name, role, hourly_rate')
      .eq('venue_id', this.venueId)
      .eq('is_active', true);

    if (!employees) return { data: [], error: null };

    const result = await Promise.all(employees.map(async (emp) => {
      // Get shifts for this employee
      const { data: shifts } = await supabase
        .from('shifts')
        .select('started_at, ended_at, total_break_minutes')
        .eq('employee_id', emp.id)
        .gte('started_at', params.startDate)
        .lte('started_at', params.endDate);

      // Get tasks completed by this employee
      const { data: tasks } = await supabase
        .from('tasks')
        .select('id')
        .eq('assigned_to', emp.id)
        .in('status', ['completed', 'approved'])
        .gte('updated_at', params.startDate)
        .lte('updated_at', params.endDate);

      let totalHours = 0;
      (shifts || []).forEach(shift => {
        if (shift.started_at && shift.ended_at) {
          const clockIn = new Date(shift.started_at);
          const clockOut = new Date(shift.ended_at);
          const hours = (clockOut.getTime() - clockIn.getTime()) / (1000 * 60 * 60);
          const breakHours = (shift.total_break_minutes || 0) / 60;
          totalHours += Math.max(0, hours - breakHours);
        }
      });

      const totalEarnings = totalHours * (emp.hourly_rate || 12);
      const totalShifts = shifts?.length || 0;
      const avgShiftLength = totalShifts > 0 ? totalHours / totalShifts : 0;

      return {
        id: emp.id,
        name: emp.name,
        role: emp.role,
        totalShifts,
        totalHours: Math.round(totalHours * 100) / 100,
        totalEarnings: Math.round(totalEarnings * 100) / 100,
        avgShiftLength: Math.round(avgShiftLength * 100) / 100,
        tasksCompleted: tasks?.length || 0,
      };
    }));

    // Sort by total hours descending
    result.sort((a, b) => b.totalHours - a.totalHours);

    return { data: result, error: null };
  }

  /**
   * Get task statistics
   */
  async getTaskStats(params: {
    startDate: string;
    endDate: string;
  }): Promise<{
    data: {
      total: number;
      completed: number;
      pending: number;
      inProgress: number;
      overdue: number;
      completionRate: number;
      byPriority: { priority: string; count: number }[];
    };
    error: Error | null;
  }> {
    const { data: tasks } = await supabase
      .from('tasks')
      .select('status, priority, due_date')
      .eq('venue_id', this.venueId)
      .gte('created_at', params.startDate)
      .lte('created_at', params.endDate);

    const now = new Date();
    let completed = 0;
    let pending = 0;
    let inProgress = 0;
    let overdue = 0;
    const priorityMap = new Map<string, number>();

    (tasks || []).forEach(task => {
      if (task.status === 'completed' || task.status === 'approved') completed++;
      else if (task.status === 'pending') pending++;
      else if (task.status === 'in_progress') inProgress++;

      if (task.due_date && new Date(task.due_date) < now && task.status !== 'completed' && task.status !== 'approved') {
        overdue++;
      }

      const priority = task.priority || 'medium';
      priorityMap.set(priority, (priorityMap.get(priority) || 0) + 1);
    });

    const total = tasks?.length || 0;
    const completionRate = total > 0 ? Math.round((completed / total) * 100) : 0;

    return {
      data: {
        total,
        completed,
        pending,
        inProgress,
        overdue,
        completionRate,
        byPriority: Array.from(priorityMap.entries()).map(([priority, count]) => ({ priority, count })),
      },
      error: null,
    };
  }

  /**
   * Get inventory statistics
   */
  async getInventoryStats(): Promise<{
    data: {
      totalItems: number;
      totalValue: number;
      lowStockCount: number;
      outOfStockCount: number;
      categoryBreakdown: { category: string; count: number; value: number }[];
    };
    error: Error | null;
  }> {
    const { data: items } = await supabase
      .from('inventory_items')
      .select('*')
      .eq('venue_id', this.venueId);

    let totalValue = 0;
    let lowStockCount = 0;
    let outOfStockCount = 0;
    const categoryMap = new Map<string, { count: number; value: number }>();

    (items || []).forEach(item => {
      const total = (item.storage_quantity || 0) + (item.bar_quantity || 0);
      const value = total * (item.unit_price || 0);
      totalValue += value;

      if (total === 0) outOfStockCount++;
      else if (total <= (item.min_stock_level || 0)) lowStockCount++;

      const cat = item.category || 'Sonstige';
      const existing = categoryMap.get(cat) || { count: 0, value: 0 };
      categoryMap.set(cat, {
        count: existing.count + 1,
        value: existing.value + value,
      });
    });

    return {
      data: {
        totalItems: items?.length || 0,
        totalValue: Math.round(totalValue * 100) / 100,
        lowStockCount,
        outOfStockCount,
        categoryBreakdown: Array.from(categoryMap.entries())
          .map(([category, data]) => ({
            category,
            count: data.count,
            value: Math.round(data.value * 100) / 100,
          }))
          .sort((a, b) => b.value - a.value),
      },
      error: null,
    };
  }

  // ============ AUDIT LOGS ============

  /**
   * Get audit logs for the venue
   */
  async getAuditLogs(entityType?: string): Promise<{
    id: string;
    venue_id: string;
    user_id: string | null;
    user_name: string | null;
    action: string;
    entity_type: string;
    entity_id: string | null;
    details: Record<string, unknown> | null;
    created_at: string;
  }[]> {
    let query = supabase
      .from('audit_logs')
      .select('*')
      .eq('venue_id', this.venueId)
      .order('created_at', { ascending: false })
      .limit(100);

    if (entityType) {
      query = query.eq('entity_type', entityType);
    }

    const { data, error } = await query;

    if (error) {
      console.error('Error fetching audit logs:', error);
      throw error;
    }

    return data || [];
  }
}

// ============================================
// BOOKING CONFIRMATION EMAILS
// ============================================

export const sendBookingConfirmation = async (
  bookingId: string,
  action: 'accepted' | 'rejected' | 'reminder'
): Promise<{ success: boolean; message?: string; error?: string }> => {
  try {
    const response = await fetch(
      `${import.meta.env.VITE_SUPABASE_URL}/functions/v1/send-booking-confirmation`,
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${import.meta.env.VITE_SUPABASE_ANON_KEY}`,
        },
        body: JSON.stringify({ booking_id: bookingId, action }),
      }
    );

    const data = await response.json();
    return data;
  } catch (error) {
    console.error('Booking confirmation error:', error);
    return { success: false, error: 'Bestätigungs-E-Mail konnte nicht gesendet werden' };
  }
};

export const supabaseApi = new SupabaseApiService();

// ============================================
// PIN VERIFICATION (Secure Edge Functions)
// ============================================

const SUPABASE_URL = import.meta.env.VITE_SUPABASE_URL || 'https://yyplbhrqtaeyzmcxpfli.supabase.co';
const SUPABASE_ANON_KEY = import.meta.env.VITE_SUPABASE_ANON_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inl5cGxiaHJxdGFleXptY3hwZmxpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ4NTMzMjcsImV4cCI6MjA4MDQyOTMyN30.qY10_JBCACxptGnrqS_ILhWsNsmMKgEitaXEtViBRQc';

export const verifyEmployeePin = async (
  employeeId: string,
  pin: string
): Promise<{ valid: boolean; employee?: { id: string; name: string; role: string }; error?: string }> => {
  try {
    const response = await fetch(
      `${SUPABASE_URL}/functions/v1/verify-pin`,
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${SUPABASE_ANON_KEY}`,
        },
        body: JSON.stringify({ employee_id: employeeId, pin }),
      }
    );

    const data = await response.json();
    return data;
  } catch (error) {
    console.error('PIN verification error:', error);
    return { valid: false, error: 'Verifizierung fehlgeschlagen' };
  }
};

export const setEmployeePin = async (
  employeeId: string,
  newPin: string
): Promise<{ success: boolean; message?: string; error?: string }> => {
  try {
    const response = await fetch(
      `${SUPABASE_URL}/functions/v1/set-pin`,
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${SUPABASE_ANON_KEY}`,
        },
        body: JSON.stringify({ employee_id: employeeId, new_pin: newPin }),
      }
    );

    const data = await response.json();
    return data;
  } catch (error) {
    console.error('Set PIN error:', error);
    return { success: false, error: 'PIN konnte nicht gesetzt werden' };
  }
};

export default supabaseApi;

// Shift status types
export type ShiftStatus = 'active' | 'on_break' | 'completed' | 'cancelled';

// Break interface for tracking pauses during shifts
export interface ShiftBreak {
  id: string;
  shiftId: string;
  startedAt: string;
  endedAt?: string;
  durationMinutes?: number;
}

// Main Shift interface
export interface Shift {
  id: string;
  venueId: string;
  employeeId: string;
  employeeName: string;
  employeeRole: string;
  startedAt: string;
  endedAt?: string;
  expectedHours: number;
  actualHours?: number;
  overtimeMinutes?: number;
  status: ShiftStatus;
  breaks: ShiftBreak[];
  totalBreakMinutes: number;
  notes?: string;
  createdAt: string;
  updatedAt: string;
}

// Employee PIN for tablet authentication
export interface EmployeePin {
  id: string;
  venueId: string;
  employeeId: string;
  employeeName: string;
  employeeRole: string;
  pin: string; // 4-digit PIN (hashed in backend)
  isActive: boolean;
  createdAt: string;
  updatedAt: string;
}

// Clock-in request (tablet mode)
export interface ClockInRequest {
  employeeId: string;
  pin: string;
  expectedHours?: number;
}

// Clock-out request
export interface ClockOutRequest {
  shiftId: string;
  notes?: string;
}

// Break request
export interface BreakRequest {
  shiftId: string;
}

// Shift summary for dashboard
export interface ShiftSummary {
  activeShifts: number;
  totalHoursToday: number;
  totalOvertimeToday: number;
  employeesOnBreak: number;
}

// Shift history filters
export interface ShiftHistoryFilters {
  employeeId?: string;
  startDate?: string;
  endDate?: string;
  status?: ShiftStatus;
}

// Constants for shift management
export const SHIFT_STATUSES: { value: ShiftStatus; label: string; color: string }[] = [
  { value: 'active', label: 'Active', color: '#10B981' },
  { value: 'on_break', label: 'On Break', color: '#F59E0B' },
  { value: 'completed', label: 'Completed', color: '#6B7280' },
  { value: 'cancelled', label: 'Cancelled', color: '#EF4444' },
];

// Overtime threshold in hours (alert when exceeded)
export const OVERTIME_THRESHOLD_HOURS = 8;

// Maximum shift duration in hours (hard limit)
export const MAX_SHIFT_HOURS = 12;

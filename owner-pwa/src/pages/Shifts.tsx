import { useState, useEffect, useCallback } from 'react';
import {
  Clock,
  Play,
  Square,
  Coffee,
  AlertTriangle,
  History,
  ChevronDown,
  X,
  FileDown,
  RefreshCw,
  Loader2,
} from 'lucide-react';
import type { ShiftStatus, ShiftSummary } from '../types/shifts';
import { TimesheetExport, type ShiftRecord } from '../components/TimesheetExport';
import { supabaseApi } from '../services/supabaseApi';
import type { Employee, Shift } from '../lib/supabase';
import { useRealtimeSubscription } from '../hooks';

// Type for active shift with calculated fields
interface ActiveShift {
  id: string;
  employeeId: string;
  employeeName: string;
  employeeRole: string;
  startedAt: string;
  expectedHours: number;
  elapsedMinutes: number;
  isOnBreak: boolean;
  totalBreakMinutes: number;
  status: ShiftStatus;
}

const statusColors: Record<ShiftStatus, string> = {
  active: 'bg-success/20 text-success',
  on_break: 'bg-warning/20 text-warning',
  completed: 'bg-foreground-muted/20 text-foreground-muted',
  cancelled: 'bg-error/20 text-error',
};

function formatDuration(minutes: number): string {
  const hours = Math.floor(minutes / 60);
  const mins = minutes % 60;
  return `${hours}h ${mins.toString().padStart(2, '0')}m`;
}

function formatTime(date: Date | string): string {
  const d = typeof date === 'string' ? new Date(date) : date;
  return d.toLocaleTimeString('de-DE', { hour: '2-digit', minute: '2-digit' });
}

// Convert database shift to UI active shift
function toActiveShift(shift: Shift & { employee: Employee }): ActiveShift {
  const clockIn = new Date(shift.clock_in);
  const now = new Date();
  const elapsedMinutes = Math.floor((now.getTime() - clockIn.getTime()) / 60000);

  return {
    id: shift.id,
    employeeId: shift.employee_id,
    employeeName: shift.employee?.name || 'Unknown',
    employeeRole: shift.employee?.role || 'staff',
    startedAt: shift.clock_in,
    expectedHours: shift.expected_hours,
    elapsedMinutes,
    isOnBreak: !!shift.break_start,
    totalBreakMinutes: shift.break_minutes || 0,
    status: shift.break_start ? 'on_break' : (shift.status as ShiftStatus),
  };
}

// Convert database shift to export format
function toShiftRecord(shift: Shift & { employee: Employee }): ShiftRecord {
  const clockIn = new Date(shift.clock_in);
  const clockOut = shift.clock_out ? new Date(shift.clock_out) : null;

  return {
    id: shift.id,
    employeeId: shift.employee_id,
    employeeName: shift.employee?.name || 'Unknown',
    employeeRole: shift.employee?.role || 'staff',
    date: clockIn.toISOString().split('T')[0],
    clockIn: clockIn.toLocaleTimeString('de-DE', { hour: '2-digit', minute: '2-digit' }),
    clockOut: clockOut?.toLocaleTimeString('de-DE', { hour: '2-digit', minute: '2-digit' }) || '',
    breakMinutes: shift.break_minutes || 0,
    totalHours: shift.actual_hours || 0,
    overtime: Math.floor((shift.overtime_minutes || 0) / 60),
  };
}

export function Shifts() {
  const [activeShifts, setActiveShifts] = useState<ActiveShift[]>([]);
  const [employees, setEmployees] = useState<Employee[]>([]);
  const [shiftHistory, setShiftHistory] = useState<ShiftRecord[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [showClockIn, setShowClockIn] = useState(false);
  const [showHistory, setShowHistory] = useState(false);
  const [showExport, setShowExport] = useState(false);
  const [selectedEmployee, setSelectedEmployee] = useState<string>('');
  const [pin, setPin] = useState(['', '', '', '']);
  const [pinError, setPinError] = useState('');
  const [isClockingIn, setIsClockingIn] = useState(false);
  const [summary, setSummary] = useState<ShiftSummary>({
    activeShifts: 0,
    totalHoursToday: 0,
    totalOvertimeToday: 0,
    employeesOnBreak: 0,
  });

  // Load initial data
  const loadData = useCallback(async () => {
    try {
      setLoading(true);
      setError(null);

      // Load employees, active shifts, and summary in parallel
      const [employeesResult, shiftsResult, summaryResult] = await Promise.all([
        supabaseApi.getEmployees(),
        supabaseApi.getActiveShifts(),
        supabaseApi.getShiftsSummary(),
      ]);

      if (employeesResult.error) {
        console.error('Error loading employees:', employeesResult.error);
      } else if (employeesResult.data) {
        setEmployees(employeesResult.data);
      }

      if (shiftsResult.error) {
        console.error('Error loading shifts:', shiftsResult.error);
      } else if (shiftsResult.data) {
        setActiveShifts(shiftsResult.data.map(toActiveShift));
      }

      setSummary(summaryResult);

      // Load shift history for export (last 14 days)
      const twoWeeksAgo = new Date();
      twoWeeksAgo.setDate(twoWeeksAgo.getDate() - 14);
      const historyResult = await supabaseApi.getShiftsHistory({
        startDate: twoWeeksAgo.toISOString(),
      });

      if (historyResult.data) {
        setShiftHistory(historyResult.data.map(toShiftRecord));
      }
    } catch (err) {
      console.error('Error loading data:', err);
      setError('Failed to load data. Please try again.');
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    loadData();
  }, [loadData]);

  // Subscribe to Realtime for automatic UI updates (shifts and employees)
  useRealtimeSubscription({
    subscriptions: [
      { table: 'shifts', event: '*' },
      { table: 'employees', event: '*' },
    ],
    onDataChange: loadData,
    enabled: !loading,
    debounceMs: 500,
  });

  // Update timers every second
  useEffect(() => {
    const interval = setInterval(() => {
      setActiveShifts(shifts =>
        shifts.map(s => ({
          ...s,
          elapsedMinutes: Math.floor((Date.now() - new Date(s.startedAt).getTime()) / 60000)
        }))
      );
    }, 1000);
    return () => clearInterval(interval);
  }, []);

  // Handle PIN input
  const handlePinInput = useCallback((index: number, value: string) => {
    if (value.length > 1) value = value.slice(-1);
    if (!/^\d*$/.test(value)) return;

    const newPin = [...pin];
    newPin[index] = value;
    setPin(newPin);
    setPinError('');

    // Auto-focus next input
    if (value && index < 3) {
      const nextInput = document.getElementById(`pin-${index + 1}`);
      nextInput?.focus();
    }
  }, [pin]);

  // Handle PIN paste
  const handlePinPaste = useCallback((e: React.ClipboardEvent) => {
    e.preventDefault();
    const pasted = e.clipboardData.getData('text').replace(/\D/g, '').slice(0, 4);
    const newPin = pasted.split('').concat(['', '', '', '']).slice(0, 4);
    setPin(newPin);
    if (pasted.length === 4) {
      document.getElementById('pin-3')?.focus();
    }
  }, []);

  // Clock in with PIN verification
  const handleClockIn = async () => {
    const enteredPin = pin.join('');
    if (enteredPin.length !== 4) {
      setPinError('Please enter 4-digit PIN');
      return;
    }

    setIsClockingIn(true);
    setPinError('');

    try {
      // Verify PIN
      const { valid, employee } = await supabaseApi.verifyEmployeePin(selectedEmployee, enteredPin);

      if (!valid || !employee) {
        setPinError('Invalid PIN. Please try again.');
        setIsClockingIn(false);
        return;
      }

      // Clock in
      const { data: shift, error } = await supabaseApi.clockIn(selectedEmployee);

      if (error) {
        setPinError('Failed to clock in. Please try again.');
        setIsClockingIn(false);
        return;
      }

      if (shift) {
        // Add to active shifts
        setActiveShifts(prev => [...prev, {
          id: shift.id,
          employeeId: employee.id,
          employeeName: employee.name,
          employeeRole: employee.role,
          startedAt: shift.clock_in,
          expectedHours: shift.expected_hours,
          elapsedMinutes: 0,
          isOnBreak: false,
          totalBreakMinutes: 0,
          status: 'active',
        }]);

        // Update summary
        setSummary(prev => ({
          ...prev,
          activeShifts: prev.activeShifts + 1,
        }));
      }

      setShowClockIn(false);
      setSelectedEmployee('');
      setPin(['', '', '', '']);
    } catch (err) {
      console.error('Clock in error:', err);
      setPinError('An error occurred. Please try again.');
    } finally {
      setIsClockingIn(false);
    }
  };

  // Toggle break
  const toggleBreak = async (shiftId: string) => {
    const shift = activeShifts.find(s => s.id === shiftId);
    if (!shift) return;

    try {
      if (shift.isOnBreak) {
        // End break
        const { error } = await supabaseApi.endBreak(shiftId);
        if (error) {
          console.error('Error ending break:', error);
          return;
        }
      } else {
        // Start break
        const { error } = await supabaseApi.startBreak(shiftId);
        if (error) {
          console.error('Error starting break:', error);
          return;
        }
      }

      // Update UI
      setActiveShifts(shifts =>
        shifts.map(s =>
          s.id === shiftId
            ? { ...s, isOnBreak: !s.isOnBreak, status: s.isOnBreak ? 'active' : 'on_break' }
            : s
        )
      );

      // Update summary
      setSummary(prev => ({
        ...prev,
        employeesOnBreak: shift.isOnBreak ? prev.employeesOnBreak - 1 : prev.employeesOnBreak + 1,
      }));
    } catch (err) {
      console.error('Toggle break error:', err);
    }
  };

  // Clock out
  const clockOut = async (shiftId: string) => {
    try {
      const { error } = await supabaseApi.clockOut(shiftId);
      if (error) {
        console.error('Error clocking out:', error);
        return;
      }

      // Remove from active shifts
      setActiveShifts(shifts => shifts.filter(s => s.id !== shiftId));

      // Update summary
      setSummary(prev => ({
        ...prev,
        activeShifts: prev.activeShifts - 1,
      }));

      // Reload history
      const twoWeeksAgo = new Date();
      twoWeeksAgo.setDate(twoWeeksAgo.getDate() - 14);
      const historyResult = await supabaseApi.getShiftsHistory({
        startDate: twoWeeksAgo.toISOString(),
      });

      if (historyResult.data) {
        setShiftHistory(historyResult.data.map(toShiftRecord));
      }
    } catch (err) {
      console.error('Clock out error:', err);
    }
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-[50vh]">
        <Loader2 className="w-8 h-8 animate-spin text-primary-500" />
      </div>
    );
  }

  if (error) {
    return (
      <div className="max-w-2xl mx-auto p-6">
        <div className="glass-card p-6 rounded-xl text-center">
          <AlertTriangle className="w-12 h-12 mx-auto mb-4 text-error" />
          <p className="text-foreground mb-4">{error}</p>
          <button
            onClick={loadData}
            className="px-4 py-2 bg-primary-500 text-white rounded-xl hover:bg-primary-600 transition-all"
          >
            Try Again
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="max-w-2xl mx-auto space-y-6 animate-fade-in">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-foreground">Shifts</h1>
          <p className="text-foreground-muted">{summary.activeShifts} active now</p>
        </div>
        <div className="flex gap-2">
          <button
            onClick={loadData}
            className="p-2 bg-white/10 text-foreground rounded-xl hover:bg-white/20 transition-all"
            title="Refresh"
          >
            <RefreshCw size={20} />
          </button>
          <button
            onClick={() => setShowExport(true)}
            className="p-2 bg-white/10 text-foreground rounded-xl hover:bg-white/20 transition-all"
            title="Export Timesheet"
          >
            <FileDown size={20} />
          </button>
          <button
            onClick={() => setShowHistory(true)}
            className="p-2 bg-white/10 text-foreground rounded-xl hover:bg-white/20 transition-all"
            title="Shift History"
          >
            <History size={20} />
          </button>
          <button
            onClick={() => setShowClockIn(true)}
            className="flex items-center gap-2 px-4 py-2 bg-gradient-primary text-white rounded-xl hover:opacity-90 transition-all shadow-glow-sm"
          >
            <Play size={18} />
            <span>Clock In</span>
          </button>
        </div>
      </div>

      {/* Summary Cards */}
      <div className="grid grid-cols-2 gap-3">
        <div className="glass-card p-4 rounded-xl">
          <p className="text-foreground-muted text-sm">Active Shifts</p>
          <p className="text-2xl font-bold text-foreground">{summary.activeShifts}</p>
        </div>
        <div className="glass-card p-4 rounded-xl">
          <p className="text-foreground-muted text-sm">Hours Today</p>
          <p className="text-2xl font-bold text-foreground">{summary.totalHoursToday.toFixed(1)}h</p>
        </div>
        <div className="glass-card p-4 rounded-xl">
          <p className="text-foreground-muted text-sm">On Break</p>
          <p className="text-2xl font-bold text-warning">{summary.employeesOnBreak}</p>
        </div>
        <div className="glass-card p-4 rounded-xl">
          <p className="text-foreground-muted text-sm">Overtime</p>
          <p className={`text-2xl font-bold ${summary.totalOvertimeToday > 0 ? 'text-error' : 'text-foreground'}`}>
            {Math.floor(summary.totalOvertimeToday)}m
          </p>
        </div>
      </div>

      {/* Active Shifts */}
      <div className="space-y-3">
        <h2 className="text-sm font-medium text-foreground-muted uppercase tracking-wide">Active Shifts</h2>

        {activeShifts.length === 0 ? (
          <div className="text-center py-12 glass-card rounded-xl">
            <Clock size={48} className="mx-auto mb-3 text-foreground-dim opacity-50" />
            <p className="text-foreground-muted">No active shifts</p>
            <p className="text-foreground-dim text-sm">Tap "Clock In" to start a shift</p>
          </div>
        ) : (
          activeShifts.map((shift) => {
            const isOvertime = shift.elapsedMinutes / 60 > shift.expectedHours;
            const workingMinutes = shift.elapsedMinutes - shift.totalBreakMinutes;

            return (
              <div key={shift.id} className="glass-card rounded-xl overflow-hidden">
                {/* Shift Header */}
                <div className="p-4 flex items-center gap-4">
                  {/* Avatar */}
                  <div className="w-12 h-12 rounded-full bg-gradient-to-br from-primary-500 to-accent-pink flex items-center justify-center text-white font-bold text-lg">
                    {shift.employeeName.split(' ').map(n => n[0]).join('')}
                  </div>

                  {/* Info */}
                  <div className="flex-1 min-w-0">
                    <p className="text-foreground font-medium">{shift.employeeName}</p>
                    <div className="flex items-center gap-2">
                      <span className={`inline-block text-xs font-medium px-2 py-0.5 rounded-md ${statusColors[shift.status]}`}>
                        {shift.isOnBreak ? 'On Break' : 'Active'}
                      </span>
                      <span className="text-foreground-dim text-xs capitalize">
                        {shift.employeeRole}
                      </span>
                      <span className="text-foreground-dim text-xs">
                        • Started {formatTime(shift.startedAt)}
                      </span>
                    </div>
                  </div>

                  {/* Timer */}
                  <div className={`text-right ${isOvertime ? 'text-error' : 'text-foreground'}`}>
                    <p className="text-2xl font-mono font-bold">{formatDuration(workingMinutes)}</p>
                    {isOvertime && (
                      <div className="flex items-center gap-1 text-xs text-error">
                        <AlertTriangle size={12} />
                        <span>Overtime</span>
                      </div>
                    )}
                  </div>
                </div>

                {/* Actions */}
                <div className="flex border-t border-border">
                  <button
                    onClick={() => toggleBreak(shift.id)}
                    className={`flex-1 flex items-center justify-center gap-2 py-3 transition-all ${
                      shift.isOnBreak
                        ? 'bg-success/10 text-success hover:bg-success/20'
                        : 'text-foreground-muted hover:bg-white/5'
                    }`}
                  >
                    <Coffee size={18} />
                    <span>{shift.isOnBreak ? 'End Break' : 'Start Break'}</span>
                  </button>
                  <div className="w-px bg-border" />
                  <button
                    onClick={() => clockOut(shift.id)}
                    className="flex-1 flex items-center justify-center gap-2 py-3 text-error hover:bg-error/10 transition-all"
                  >
                    <Square size={18} />
                    <span>Clock Out</span>
                  </button>
                </div>
              </div>
            );
          })
        )}
      </div>

      {/* Clock In Modal */}
      {showClockIn && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
          <div className="absolute inset-0 bg-black/60 backdrop-blur-sm" onClick={() => setShowClockIn(false)} />
          <div className="relative w-full max-w-sm glass-card p-5 animate-scale-in space-y-4">
            <div className="flex items-center justify-between">
              <h2 className="text-lg font-bold text-foreground">Clock In</h2>
              <button onClick={() => setShowClockIn(false)} className="p-1 text-foreground-muted hover:text-foreground">
                <X size={20} />
              </button>
            </div>

            {/* Employee Select */}
            <div className="space-y-2">
              <label className="text-sm text-foreground-muted">Select Employee</label>
              <div className="relative">
                <select
                  value={selectedEmployee}
                  onChange={(e) => setSelectedEmployee(e.target.value)}
                  className="w-full px-4 py-3 bg-white/5 border border-border rounded-xl text-foreground appearance-none focus:outline-none focus:border-primary-500"
                >
                  <option value="">Choose employee...</option>
                  {employees.map((emp) => (
                    <option key={emp.id} value={emp.id}>
                      {emp.name} ({emp.role})
                    </option>
                  ))}
                </select>
                <ChevronDown className="absolute right-3 top-1/2 -translate-y-1/2 text-foreground-muted pointer-events-none" size={20} />
              </div>
            </div>

            {/* PIN Input */}
            {selectedEmployee && (
              <div className="space-y-2">
                <label className="text-sm text-foreground-muted">Enter 4-Digit PIN</label>
                <div className="flex gap-3 justify-center">
                  {[0, 1, 2, 3].map((i) => (
                    <input
                      key={i}
                      id={`pin-${i}`}
                      type="text"
                      inputMode="numeric"
                      maxLength={1}
                      value={pin[i]}
                      onChange={(e) => handlePinInput(i, e.target.value)}
                      onPaste={i === 0 ? handlePinPaste : undefined}
                      onKeyDown={(e) => {
                        if (e.key === 'Backspace' && !pin[i] && i > 0) {
                          document.getElementById(`pin-${i - 1}`)?.focus();
                        }
                      }}
                      className="w-14 h-14 text-center text-2xl font-mono bg-white/5 border border-border rounded-xl text-foreground focus:outline-none focus:border-primary-500"
                    />
                  ))}
                </div>
                {pinError && (
                  <p className="text-error text-sm text-center">{pinError}</p>
                )}
              </div>
            )}

            <div className="flex gap-2 pt-2">
              <button
                onClick={() => {
                  setShowClockIn(false);
                  setSelectedEmployee('');
                  setPin(['', '', '', '']);
                  setPinError('');
                }}
                className="flex-1 px-4 py-2 bg-white/10 text-foreground rounded-xl hover:bg-white/20 transition-all"
              >
                Cancel
              </button>
              <button
                onClick={handleClockIn}
                disabled={!selectedEmployee || pin.join('').length !== 4 || isClockingIn}
                className="flex-1 px-4 py-2 bg-gradient-primary text-white rounded-xl hover:opacity-90 transition-all disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center gap-2"
              >
                {isClockingIn ? (
                  <>
                    <Loader2 size={18} className="animate-spin" />
                    <span>Clocking In...</span>
                  </>
                ) : (
                  <span>Clock In</span>
                )}
              </button>
            </div>
          </div>
        </div>
      )}

      {/* History Modal */}
      {showHistory && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
          <div className="absolute inset-0 bg-black/60 backdrop-blur-sm" onClick={() => setShowHistory(false)} />
          <div className="relative w-full max-w-lg glass-card p-5 animate-scale-in max-h-[80vh] overflow-y-auto">
            <div className="flex items-center justify-between mb-4">
              <h2 className="text-lg font-bold text-foreground">Shift History</h2>
              <button onClick={() => setShowHistory(false)} className="p-1 text-foreground-muted hover:text-foreground">
                <X size={20} />
              </button>
            </div>

            <div className="space-y-3">
              {shiftHistory.length === 0 ? (
                <p className="text-center text-foreground-muted py-8">No shift history found</p>
              ) : (
                shiftHistory.slice(0, 20).map((shift) => (
                  <div key={shift.id} className="flex items-center gap-4 p-3 bg-white/5 rounded-xl">
                    <div className="w-10 h-10 rounded-full bg-gradient-to-br from-primary-500/50 to-accent-pink/50 flex items-center justify-center text-white font-bold">
                      {shift.employeeName.split(' ').map(n => n[0]).join('')}
                    </div>
                    <div className="flex-1">
                      <p className="text-foreground font-medium">{shift.employeeName}</p>
                      <p className="text-foreground-muted text-sm">
                        {new Date(shift.date).toLocaleDateString('de-DE', {
                          weekday: 'short',
                          day: 'numeric',
                          month: 'short',
                        })} • {shift.clockIn} - {shift.clockOut || 'Active'}
                      </p>
                    </div>
                    <div className="text-right">
                      <p className="text-foreground font-mono">{shift.totalHours.toFixed(1)}h</p>
                      {shift.overtime > 0 && (
                        <p className="text-error text-xs">+{shift.overtime}h OT</p>
                      )}
                    </div>
                  </div>
                ))
              )}
            </div>
          </div>
        </div>
      )}

      {/* Timesheet Export Modal */}
      <TimesheetExport
        isOpen={showExport}
        onClose={() => setShowExport(false)}
        shifts={shiftHistory}
      />
    </div>
  );
}

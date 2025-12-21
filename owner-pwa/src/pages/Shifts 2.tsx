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
} from 'lucide-react';
import type { ShiftStatus, ShiftSummary, EmployeePin } from '../types/shifts';
import { TimesheetExport, type ShiftRecord } from '../components/TimesheetExport';

// Mock employees for the dropdown (will be replaced with API call)
const mockEmployees: EmployeePin[] = [
  { id: '1', venueId: 'v1', employeeId: 'emp1', employeeName: 'Tom Weber', employeeRole: 'bartender', pin: '', isActive: true, createdAt: '', updatedAt: '' },
  { id: '2', venueId: 'v1', employeeId: 'emp2', employeeName: 'Lisa Fischer', employeeRole: 'bartender', pin: '', isActive: true, createdAt: '', updatedAt: '' },
  { id: '3', venueId: 'v1', employeeId: 'emp3', employeeName: 'Sarah Schmidt', employeeRole: 'manager', pin: '', isActive: true, createdAt: '', updatedAt: '' },
];

// Mock active shifts
const mockActiveShifts = [
  {
    id: '1',
    employeeId: 'emp1',
    employeeName: 'Tom Weber',
    employeeRole: 'bartender',
    startedAt: new Date(Date.now() - 3 * 60 * 60 * 1000).toISOString(), // 3 hours ago
    expectedHours: 8,
    elapsedMinutes: 180,
    isOnBreak: false,
    totalBreakMinutes: 15,
    status: 'active' as ShiftStatus,
  },
];

// Mock completed shifts for timesheet export (past 2 weeks)
const generateMockShiftHistory = (): ShiftRecord[] => {
  const shifts: ShiftRecord[] = [];
  const today = new Date();

  // Generate shifts for the past 14 days
  for (let dayOffset = 0; dayOffset < 14; dayOffset++) {
    const date = new Date(today);
    date.setDate(date.getDate() - dayOffset);
    const dateStr = date.toISOString().split('T')[0];

    // Skip some days randomly (employees don't work every day)
    if (dayOffset % 7 === 6) continue; // Skip Sundays

    // Tom Weber - bartender (works most days)
    if (dayOffset % 3 !== 2) {
      shifts.push({
        id: `shift-tom-${dayOffset}`,
        employeeId: 'emp1',
        employeeName: 'Tom Weber',
        employeeRole: 'Bartender',
        date: dateStr,
        clockIn: '18:00',
        clockOut: dayOffset % 4 === 0 ? '03:30' : '02:00',
        breakMinutes: 30,
        totalHours: dayOffset % 4 === 0 ? 9 : 7.5,
        overtime: dayOffset % 4 === 0 ? 1 : 0,
      });
    }

    // Lisa Fischer - bartender (weekends mainly)
    if (dayOffset % 7 <= 1 || dayOffset % 5 === 0) {
      shifts.push({
        id: `shift-lisa-${dayOffset}`,
        employeeId: 'emp2',
        employeeName: 'Lisa Fischer',
        employeeRole: 'Bartender',
        date: dateStr,
        clockIn: '19:00',
        clockOut: '03:00',
        breakMinutes: 15,
        totalHours: 7.75,
        overtime: 0,
      });
    }

    // Sarah Schmidt - manager (works most days)
    if (dayOffset % 2 === 0) {
      shifts.push({
        id: `shift-sarah-${dayOffset}`,
        employeeId: 'emp3',
        employeeName: 'Sarah Schmidt',
        employeeRole: 'Manager',
        date: dateStr,
        clockIn: '17:00',
        clockOut: '01:00',
        breakMinutes: 30,
        totalHours: 7.5,
        overtime: 0,
      });
    }
  }

  return shifts;
};

const mockShiftHistory = generateMockShiftHistory();

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

export function Shifts() {
  const [activeShifts, setActiveShifts] = useState(mockActiveShifts);
  const [employees] = useState(mockEmployees);
  const [showClockIn, setShowClockIn] = useState(false);
  const [showHistory, setShowHistory] = useState(false);
  const [showExport, setShowExport] = useState(false);
  const [selectedEmployee, setSelectedEmployee] = useState<string>('');
  const [pin, setPin] = useState(['', '', '', '']);
  const [pinError, setPinError] = useState('');
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
  const handleClockIn = () => {
    const enteredPin = pin.join('');
    if (enteredPin.length !== 4) {
      setPinError('Please enter 4-digit PIN');
      return;
    }
    // TODO: Call API to verify PIN and clock in
    // For now, mock success
    const employee = employees.find(e => e.employeeId === selectedEmployee);
    if (employee) {
      setActiveShifts([...activeShifts, {
        id: Date.now().toString(),
        employeeId: employee.employeeId,
        employeeName: employee.employeeName,
        employeeRole: employee.employeeRole,
        startedAt: new Date().toISOString(),
        expectedHours: 8,
        elapsedMinutes: 0,
        isOnBreak: false,
        totalBreakMinutes: 0,
        status: 'active',
      }]);
      setShowClockIn(false);
      setSelectedEmployee('');
      setPin(['', '', '', '']);
    }
  };

  // Toggle break
  const toggleBreak = (shiftId: string) => {
    setActiveShifts(shifts =>
      shifts.map(s =>
        s.id === shiftId
          ? { ...s, isOnBreak: !s.isOnBreak, status: s.isOnBreak ? 'active' : 'on_break' }
          : s
      )
    );
  };

  // Clock out
  const clockOut = (shiftId: string) => {
    // TODO: Call API
    setActiveShifts(shifts => shifts.filter(s => s.id !== shiftId));
  };

  // Summary stats
  const summary: ShiftSummary = {
    activeShifts: activeShifts.length,
    totalHoursToday: activeShifts.reduce((sum, s) => sum + s.elapsedMinutes / 60, 0),
    totalOvertimeToday: activeShifts.reduce((sum, s) => {
      const overtime = s.elapsedMinutes / 60 - s.expectedHours;
      return sum + (overtime > 0 ? overtime * 60 : 0);
    }, 0),
    employeesOnBreak: activeShifts.filter(s => s.isOnBreak).length,
  };

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
                      <span className="text-foreground-dim text-xs">
                        Started {formatTime(shift.startedAt)}
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
                    <option key={emp.employeeId} value={emp.employeeId}>
                      {emp.employeeName} ({emp.employeeRole})
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
                }}
                className="flex-1 px-4 py-2 bg-white/10 text-foreground rounded-xl hover:bg-white/20 transition-all"
              >
                Cancel
              </button>
              <button
                onClick={handleClockIn}
                disabled={!selectedEmployee || pin.join('').length !== 4}
                className="flex-1 px-4 py-2 bg-gradient-primary text-white rounded-xl hover:opacity-90 transition-all disabled:opacity-50 disabled:cursor-not-allowed"
              >
                Clock In
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

            {/* Mock history - will be replaced with API data */}
            <div className="space-y-3">
              {[
                { name: 'Tom Weber', date: 'Today', hours: '3h 45m', overtime: 0 },
                { name: 'Lisa Fischer', date: 'Yesterday', hours: '8h 30m', overtime: 30 },
                { name: 'Sarah Schmidt', date: 'Yesterday', hours: '7h 15m', overtime: 0 },
                { name: 'Tom Weber', date: '2 days ago', hours: '9h 15m', overtime: 75 },
              ].map((shift, i) => (
                <div key={i} className="flex items-center gap-4 p-3 bg-white/5 rounded-xl">
                  <div className="w-10 h-10 rounded-full bg-gradient-to-br from-primary-500/50 to-accent-pink/50 flex items-center justify-center text-white font-bold">
                    {shift.name.split(' ').map(n => n[0]).join('')}
                  </div>
                  <div className="flex-1">
                    <p className="text-foreground font-medium">{shift.name}</p>
                    <p className="text-foreground-muted text-sm">{shift.date}</p>
                  </div>
                  <div className="text-right">
                    <p className="text-foreground font-mono">{shift.hours}</p>
                    {shift.overtime > 0 && (
                      <p className="text-error text-xs">+{shift.overtime}m overtime</p>
                    )}
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>
      )}

      {/* Timesheet Export Modal */}
      <TimesheetExport
        isOpen={showExport}
        onClose={() => setShowExport(false)}
        shifts={mockShiftHistory}
      />
    </div>
  );
}

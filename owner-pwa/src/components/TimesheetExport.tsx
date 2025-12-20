import { useState } from 'react';
import {
  Download,
  FileSpreadsheet,
  FileText,
  Calendar,
  Clock,
  Users,
  ChevronLeft,
  ChevronRight,
  X,
} from 'lucide-react';
import { cn } from '../lib/utils';

export interface ShiftRecord {
  id: string;
  employeeId: string;
  employeeName: string;
  employeeRole: string;
  date: string;
  clockIn: string;
  clockOut: string;
  breakMinutes: number;
  totalHours: number;
  overtime: number;
}

interface TimesheetExportProps {
  isOpen: boolean;
  onClose: () => void;
  shifts: ShiftRecord[];
}

/**
 * TimesheetExport component for exporting shift history to CSV or PDF
 * Supports weekly date range selection and summary stats
 */
export function TimesheetExport({ isOpen, onClose, shifts }: TimesheetExportProps) {
  const [exporting, setExporting] = useState(false);
  const [exportFormat, setExportFormat] = useState<'csv' | 'pdf'>('csv');

  // Date range state (default to current week)
  const getWeekStart = (date: Date) => {
    const d = new Date(date);
    const day = d.getDay();
    const diff = d.getDate() - day + (day === 0 ? -6 : 1); // Monday start
    return new Date(d.setDate(diff));
  };

  const getWeekEnd = (startDate: Date) => {
    const d = new Date(startDate);
    d.setDate(d.getDate() + 6);
    return d;
  };

  const [weekStart, setWeekStart] = useState(() => getWeekStart(new Date()));
  const weekEnd = getWeekEnd(weekStart);

  const formatDate = (date: Date) => date.toISOString().split('T')[0];
  const formatDisplayDate = (date: Date) =>
    date.toLocaleDateString('de-DE', { day: '2-digit', month: '2-digit', year: 'numeric' });

  // Filter shifts for selected week
  const filteredShifts = shifts.filter(s => {
    const shiftDate = new Date(s.date);
    return shiftDate >= weekStart && shiftDate <= weekEnd;
  });

  // Calculate summary stats
  const totalShifts = filteredShifts.length;
  const totalHours = filteredShifts.reduce((sum, s) => sum + s.totalHours, 0);
  const totalOvertime = filteredShifts.reduce((sum, s) => sum + s.overtime, 0);
  const uniqueEmployees = new Set(filteredShifts.map(s => s.employeeId)).size;

  // Group shifts by employee for summary
  const employeeSummary = filteredShifts.reduce((acc, shift) => {
    if (!acc[shift.employeeId]) {
      acc[shift.employeeId] = {
        name: shift.employeeName,
        role: shift.employeeRole,
        totalHours: 0,
        overtime: 0,
        shifts: 0,
      };
    }
    acc[shift.employeeId].totalHours += shift.totalHours;
    acc[shift.employeeId].overtime += shift.overtime;
    acc[shift.employeeId].shifts += 1;
    return acc;
  }, {} as Record<string, { name: string; role: string; totalHours: number; overtime: number; shifts: number }>);

  // Navigation
  const goToPreviousWeek = () => {
    const newStart = new Date(weekStart);
    newStart.setDate(newStart.getDate() - 7);
    setWeekStart(newStart);
  };

  const goToNextWeek = () => {
    const newStart = new Date(weekStart);
    newStart.setDate(newStart.getDate() + 7);
    setWeekStart(newStart);
  };

  const goToCurrentWeek = () => {
    setWeekStart(getWeekStart(new Date()));
  };

  // Export to CSV
  const exportToCSV = () => {
    setExporting(true);

    const headers = [
      'Employee',
      'Role',
      'Date',
      'Clock In',
      'Clock Out',
      'Break (min)',
      'Total Hours',
      'Overtime',
    ];

    const rows = filteredShifts.map(s => [
      s.employeeName,
      s.employeeRole,
      new Date(s.date).toLocaleDateString('de-DE'),
      s.clockIn,
      s.clockOut,
      s.breakMinutes.toString(),
      s.totalHours.toFixed(2),
      s.overtime.toFixed(2),
    ]);

    // Add summary rows
    rows.push([]); // Empty row
    rows.push(['=== SUMMARY ===', '', '', '', '', '', '', '']);
    rows.push(['Total Shifts', totalShifts.toString(), '', '', '', '', '', '']);
    rows.push(['Total Hours', totalHours.toFixed(2), '', '', '', '', '', '']);
    rows.push(['Total Overtime', totalOvertime.toFixed(2), '', '', '', '', '', '']);

    const csv = [headers.join(';'), ...rows.map(r => r.join(';'))].join('\n');
    const blob = new Blob(['\ufeff' + csv], { type: 'text/csv;charset=utf-8' }); // BOM for Excel
    const url = URL.createObjectURL(blob);

    const a = document.createElement('a');
    a.href = url;
    a.download = `timesheet_${formatDate(weekStart)}_to_${formatDate(weekEnd)}.csv`;
    a.click();

    URL.revokeObjectURL(url);
    setExporting(false);
  };

  // Export to PDF (print-friendly HTML)
  const exportToPDF = () => {
    setExporting(true);

    const html = `
      <!DOCTYPE html>
      <html>
      <head>
        <title>Timesheet Report - WiesbadenAfterDark</title>
        <meta charset="utf-8">
        <style>
          * { box-sizing: border-box; }
          body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
            padding: 30px;
            color: #1a1a2e;
            line-height: 1.5;
          }
          .header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            margin-bottom: 30px;
            padding-bottom: 20px;
            border-bottom: 2px solid #7c3aed;
          }
          .logo { font-size: 24px; font-weight: bold; color: #7c3aed; }
          .period { color: #666; font-size: 14px; }
          .stats-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 15px;
            margin-bottom: 30px;
          }
          .stat-card {
            padding: 15px;
            background: #f8f9fa;
            border-radius: 8px;
            text-align: center;
          }
          .stat-value { font-size: 28px; font-weight: bold; color: #7c3aed; }
          .stat-label { font-size: 12px; color: #666; text-transform: uppercase; }
          table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
            font-size: 13px;
          }
          th, td {
            border: 1px solid #e0e0e0;
            padding: 10px 12px;
            text-align: left;
          }
          th {
            background-color: #7c3aed;
            color: white;
            font-weight: 600;
          }
          tr:nth-child(even) { background-color: #f8f9fa; }
          .overtime { color: #ef4444; font-weight: 500; }
          .summary-section {
            margin-top: 30px;
            padding-top: 20px;
            border-top: 1px solid #e0e0e0;
          }
          .summary-title { font-size: 16px; font-weight: 600; margin-bottom: 15px; }
          .employee-summary {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 10px;
          }
          .employee-card {
            padding: 12px;
            background: #f8f9fa;
            border-radius: 6px;
            border-left: 3px solid #7c3aed;
          }
          .employee-name { font-weight: 600; }
          .employee-stats { font-size: 12px; color: #666; margin-top: 4px; }
          .footer {
            margin-top: 40px;
            padding-top: 20px;
            border-top: 1px solid #e0e0e0;
            text-align: center;
            font-size: 11px;
            color: #888;
          }
          @media print {
            body { padding: 0; }
            .stats-grid { page-break-inside: avoid; }
            table { page-break-inside: auto; }
            tr { page-break-inside: avoid; }
          }
        </style>
      </head>
      <body>
        <div class="header">
          <div>
            <div class="logo">🌙 WiesbadenAfterDark</div>
            <div class="period">
              <strong>Timesheet Report</strong><br>
              ${formatDisplayDate(weekStart)} - ${formatDisplayDate(weekEnd)}
            </div>
          </div>
          <div style="text-align: right; font-size: 12px; color: #666;">
            Generated: ${new Date().toLocaleString('de-DE')}<br>
            Das Wohnzimmer
          </div>
        </div>

        <div class="stats-grid">
          <div class="stat-card">
            <div class="stat-value">${totalShifts}</div>
            <div class="stat-label">Total Shifts</div>
          </div>
          <div class="stat-card">
            <div class="stat-value">${totalHours.toFixed(1)}h</div>
            <div class="stat-label">Total Hours</div>
          </div>
          <div class="stat-card">
            <div class="stat-value">${uniqueEmployees}</div>
            <div class="stat-label">Employees</div>
          </div>
          <div class="stat-card">
            <div class="stat-value ${totalOvertime > 0 ? 'overtime' : ''}">${totalOvertime.toFixed(1)}h</div>
            <div class="stat-label">Overtime</div>
          </div>
        </div>

        <table>
          <thead>
            <tr>
              <th>Employee</th>
              <th>Role</th>
              <th>Date</th>
              <th>Clock In</th>
              <th>Clock Out</th>
              <th>Break</th>
              <th>Total</th>
              <th>Overtime</th>
            </tr>
          </thead>
          <tbody>
            ${filteredShifts.map(s => `
              <tr>
                <td>${s.employeeName}</td>
                <td>${s.employeeRole}</td>
                <td>${new Date(s.date).toLocaleDateString('de-DE')}</td>
                <td>${s.clockIn}</td>
                <td>${s.clockOut}</td>
                <td>${s.breakMinutes} min</td>
                <td>${s.totalHours.toFixed(2)}h</td>
                <td class="${s.overtime > 0 ? 'overtime' : ''}">${s.overtime > 0 ? '+' + s.overtime.toFixed(2) + 'h' : '-'}</td>
              </tr>
            `).join('')}
          </tbody>
        </table>

        <div class="summary-section">
          <div class="summary-title">Employee Summary</div>
          <div class="employee-summary">
            ${Object.entries(employeeSummary).map(([_, emp]) => `
              <div class="employee-card">
                <div class="employee-name">${emp.name}</div>
                <div class="employee-stats">
                  ${emp.role} • ${emp.shifts} shifts • ${emp.totalHours.toFixed(1)}h total
                  ${emp.overtime > 0 ? ` • <span class="overtime">+${emp.overtime.toFixed(1)}h OT</span>` : ''}
                </div>
              </div>
            `).join('')}
          </div>
        </div>

        <div class="footer">
          WiesbadenAfterDark Owner Portal • Timesheet Report • Confidential
        </div>
      </body>
      </html>
    `;

    const printWindow = window.open('', '_blank');
    if (printWindow) {
      printWindow.document.write(html);
      printWindow.document.close();
      setTimeout(() => {
        printWindow.print();
      }, 250);
    }

    setExporting(false);
  };

  const handleExport = () => {
    if (exportFormat === 'csv') {
      exportToCSV();
    } else {
      exportToPDF();
    }
  };

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
      <div className="absolute inset-0 bg-black/60 backdrop-blur-sm" onClick={onClose} />
      <div className="relative w-full max-w-lg glass-card animate-scale-in max-h-[90vh] overflow-y-auto">
        {/* Header */}
        <div className="sticky top-0 p-4 border-b border-border bg-card/95 backdrop-blur-sm flex items-center justify-between">
          <div className="flex items-center gap-2">
            <Download className="w-5 h-5 text-primary-400" />
            <span className="font-semibold text-foreground">Export Timesheet</span>
          </div>
          <button onClick={onClose} className="p-1 text-foreground-muted hover:text-foreground">
            <X size={20} />
          </button>
        </div>

        <div className="p-4 space-y-5">
          {/* Week Selector */}
          <div className="flex items-center justify-between">
            <button
              onClick={goToPreviousWeek}
              className="p-2 rounded-lg bg-white/5 hover:bg-white/10 transition-all"
            >
              <ChevronLeft size={20} className="text-foreground-muted" />
            </button>

            <div className="text-center">
              <div className="flex items-center justify-center gap-2 mb-1">
                <Calendar size={16} className="text-primary-400" />
                <span className="font-medium text-foreground">
                  {formatDisplayDate(weekStart)} - {formatDisplayDate(weekEnd)}
                </span>
              </div>
              <button
                onClick={goToCurrentWeek}
                className="text-xs text-primary-400 hover:underline"
              >
                Go to current week
              </button>
            </div>

            <button
              onClick={goToNextWeek}
              className="p-2 rounded-lg bg-white/5 hover:bg-white/10 transition-all"
            >
              <ChevronRight size={20} className="text-foreground-muted" />
            </button>
          </div>

          {/* Summary Stats */}
          <div className="grid grid-cols-4 gap-3">
            <div className="p-3 bg-white/5 rounded-xl text-center">
              <div className="text-xl font-bold text-foreground">{totalShifts}</div>
              <div className="text-xs text-foreground-muted">Shifts</div>
            </div>
            <div className="p-3 bg-white/5 rounded-xl text-center">
              <div className="text-xl font-bold text-success">{totalHours.toFixed(1)}h</div>
              <div className="text-xs text-foreground-muted">Total</div>
            </div>
            <div className="p-3 bg-white/5 rounded-xl text-center">
              <div className="text-xl font-bold text-foreground">{uniqueEmployees}</div>
              <div className="text-xs text-foreground-muted">Staff</div>
            </div>
            <div className="p-3 bg-white/5 rounded-xl text-center">
              <div className={cn(
                "text-xl font-bold",
                totalOvertime > 0 ? 'text-warning' : 'text-foreground'
              )}>
                {totalOvertime.toFixed(1)}h
              </div>
              <div className="text-xs text-foreground-muted">Overtime</div>
            </div>
          </div>

          {/* Employee Breakdown */}
          {Object.keys(employeeSummary).length > 0 && (
            <div className="space-y-2">
              <h4 className="text-sm font-medium text-foreground-muted flex items-center gap-2">
                <Users size={14} />
                Employee Breakdown
              </h4>
              <div className="space-y-2">
                {Object.entries(employeeSummary).map(([id, emp]) => (
                  <div key={id} className="flex items-center justify-between p-3 bg-white/5 rounded-xl">
                    <div>
                      <p className="font-medium text-foreground">{emp.name}</p>
                      <p className="text-xs text-foreground-muted">{emp.role} • {emp.shifts} shifts</p>
                    </div>
                    <div className="text-right">
                      <p className="font-medium text-foreground">{emp.totalHours.toFixed(1)}h</p>
                      {emp.overtime > 0 && (
                        <p className="text-xs text-warning">+{emp.overtime.toFixed(1)}h OT</p>
                      )}
                    </div>
                  </div>
                ))}
              </div>
            </div>
          )}

          {/* Empty State */}
          {filteredShifts.length === 0 && (
            <div className="text-center py-8 text-foreground-muted">
              <Clock size={40} className="mx-auto mb-3 opacity-30" />
              <p>No shifts recorded for this week</p>
              <p className="text-sm mt-1">Try selecting a different week</p>
            </div>
          )}

          {/* Export Format Selection */}
          <div className="space-y-2">
            <h4 className="text-sm font-medium text-foreground-muted">Export Format</h4>
            <div className="grid grid-cols-2 gap-3">
              <button
                onClick={() => setExportFormat('csv')}
                className={cn(
                  "flex items-center justify-center gap-2 p-3 rounded-xl border transition-all",
                  exportFormat === 'csv'
                    ? 'bg-success/20 border-success text-success'
                    : 'bg-white/5 border-border text-foreground-muted hover:border-foreground-muted'
                )}
              >
                <FileSpreadsheet size={20} />
                <span>CSV (Excel)</span>
              </button>
              <button
                onClick={() => setExportFormat('pdf')}
                className={cn(
                  "flex items-center justify-center gap-2 p-3 rounded-xl border transition-all",
                  exportFormat === 'pdf'
                    ? 'bg-primary-500/20 border-primary-500 text-primary-400'
                    : 'bg-white/5 border-border text-foreground-muted hover:border-foreground-muted'
                )}
              >
                <FileText size={20} />
                <span>PDF (Print)</span>
              </button>
            </div>
          </div>
        </div>

        {/* Actions */}
        <div className="sticky bottom-0 p-4 border-t border-border bg-card/95 backdrop-blur-sm flex gap-3">
          <button
            onClick={onClose}
            className="flex-1 py-3 bg-white/10 text-foreground rounded-xl hover:bg-white/20 transition-all"
          >
            Cancel
          </button>
          <button
            onClick={handleExport}
            disabled={exporting || filteredShifts.length === 0}
            className={cn(
              "flex-1 py-3 rounded-xl flex items-center justify-center gap-2 transition-all",
              "disabled:opacity-50 disabled:cursor-not-allowed",
              exportFormat === 'csv'
                ? 'bg-success text-white hover:opacity-90'
                : 'bg-primary-500 text-white hover:opacity-90'
            )}
          >
            <Download size={18} />
            {exporting ? 'Exporting...' : `Export ${exportFormat.toUpperCase()}`}
          </button>
        </div>
      </div>
    </div>
  );
}

export default TimesheetExport;

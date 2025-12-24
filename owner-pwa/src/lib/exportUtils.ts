/**
 * Export Utilities for WiesbadenAfterDark Owner PWA
 * Supports CSV and PDF export with German formatting
 */

// ============================================
// CSV EXPORT
// ============================================

interface CSVOptions {
  filename: string;
  headers: string[];
  data: (string | number | null | undefined)[][];
  delimiter?: string;
}

export const exportToCSV = ({ filename, headers, data, delimiter = ';' }: CSVOptions): void => {
  // Use semicolon delimiter for German Excel compatibility
  const BOM = '\uFEFF'; // UTF-8 BOM for Excel

  const csvContent = [
    headers.join(delimiter),
    ...data.map(row =>
      row.map(cell => {
        if (cell === null || cell === undefined) return '';
        const stringCell = String(cell);
        // Escape quotes and wrap in quotes if contains delimiter or quotes
        if (stringCell.includes(delimiter) || stringCell.includes('"') || stringCell.includes('\n')) {
          return '"' + stringCell.replace(/"/g, '""') + '"';
        }
        return stringCell;
      }).join(delimiter)
    )
  ].join('\n');

  const blob = new Blob([BOM + csvContent], { type: 'text/csv;charset=utf-8' });
  downloadBlob(blob, `${filename}.csv`);
};

// ============================================
// TIMESHEET EXPORT
// ============================================

interface ShiftData {
  employeeName: string;
  date: string;
  clockIn: string;
  clockOut: string | null;
  breakMinutes: number;
  totalHours: number;
  overtime: number;
  status: string;
}

export const exportTimesheetCSV = (
  shifts: ShiftData[],
  dateRange: { from: Date; to: Date },
  venueName: string
): void => {
  const formatDate = (date: Date) => date.toLocaleDateString('de-DE');

  const headers = [
    'Mitarbeiter',
    'Datum',
    'Eingestempelt',
    'Ausgestempelt',
    'Pause (Min)',
    'Arbeitsstunden',
    'Überstunden',
    'Status'
  ];

  const rows: (string | number)[][] = shifts.map(shift => [
    shift.employeeName,
    shift.date,
    shift.clockIn,
    shift.clockOut || '-',
    shift.breakMinutes,
    shift.totalHours.toFixed(2).replace('.', ','), // German decimal
    shift.overtime.toFixed(2).replace('.', ','),
    shift.status
  ]);

  // Add summary row
  const totalHours = shifts.reduce((sum, s) => sum + s.totalHours, 0);
  const totalOvertime = shifts.reduce((sum, s) => sum + s.overtime, 0);
  rows.push([]);
  rows.push(['GESAMT', '', '', '', '', totalHours.toFixed(2).replace('.', ','), totalOvertime.toFixed(2).replace('.', ','), '']);

  const filenameStr = `Arbeitszeitnachweis_${venueName}_${formatDate(dateRange.from)}_${formatDate(dateRange.to)}`;
  exportToCSV({ filename: filenameStr, headers, data: rows });
};

// ============================================
// INVENTORY EXPORT
// ============================================

interface InventoryItem {
  name: string;
  category: string;
  storageQuantity: number;
  barQuantity: number;
  unit: string;
  minStockLevel: number;
  price: number;
  barcode?: string;
}

export const exportInventoryCSV = (items: InventoryItem[], venueName: string): void => {
  const headers = [
    'Artikel',
    'Kategorie',
    'Lager',
    'Bar',
    'Gesamt',
    'Einheit',
    'Mindestbestand',
    'Status',
    'Preis (€)',
    'Barcode'
  ];

  const rows: (string | number)[][] = items.map(item => {
    const total = item.storageQuantity + item.barQuantity;
    const status = total <= item.minStockLevel ? 'Niedrig' : 'OK';
    return [
      item.name,
      item.category,
      item.storageQuantity,
      item.barQuantity,
      total,
      item.unit,
      item.minStockLevel,
      status,
      item.price.toFixed(2).replace('.', ','),
      item.barcode || ''
    ];
  });

  const date = new Date().toLocaleDateString('de-DE');
  const filenameStr = `Inventar_${venueName}_${date}`;
  exportToCSV({ filename: filenameStr, headers, data: rows });
};

// ============================================
// EMPLOYEE LIST EXPORT
// ============================================

interface Employee {
  name: string;
  role: string;
  email?: string;
  phone?: string;
  isActive: boolean;
  startDate?: string;
}

export const exportEmployeesCSV = (employees: Employee[], venueName: string): void => {
  const headers = [
    'Name',
    'Rolle',
    'E-Mail',
    'Telefon',
    'Status',
    'Eintrittsdatum'
  ];

  const roleTranslations: Record<string, string> = {
    owner: 'Inhaber',
    manager: 'Manager',
    bartender: 'Barkeeper',
    server: 'Service',
    waiter: 'Kellner',
    kitchen: 'Küche',
    security: 'Security',
    dj: 'DJ',
    cleaning: 'Reinigung',
  };

  const rows: (string | number)[][] = employees.map(emp => [
    emp.name,
    roleTranslations[emp.role] || emp.role,
    emp.email || '',
    emp.phone || '',
    emp.isActive ? 'Aktiv' : 'Inaktiv',
    emp.startDate || ''
  ]);

  const date = new Date().toLocaleDateString('de-DE');
  const filenameStr = `Mitarbeiter_${venueName}_${date}`;
  exportToCSV({ filename: filenameStr, headers, data: rows });
};

// ============================================
// TASKS EXPORT
// ============================================

interface Task {
  title: string;
  description?: string;
  assignedTo?: string;
  status: string;
  priority: string;
  dueDate?: string;
  createdAt: string;
}

export const exportTasksCSV = (tasks: Task[], venueName: string): void => {
  const headers = [
    'Aufgabe',
    'Beschreibung',
    'Zugewiesen an',
    'Status',
    'Priorität',
    'Fällig am',
    'Erstellt am'
  ];

  const statusTranslations: Record<string, string> = {
    pending: 'Ausstehend',
    in_progress: 'In Bearbeitung',
    completed: 'Erledigt',
    approved: 'Genehmigt',
    rejected: 'Abgelehnt',
  };

  const priorityTranslations: Record<string, string> = {
    low: 'Niedrig',
    medium: 'Mittel',
    high: 'Hoch',
    urgent: 'Dringend',
  };

  const rows: (string | number)[][] = tasks.map(task => [
    task.title,
    task.description || '',
    task.assignedTo || 'Nicht zugewiesen',
    statusTranslations[task.status] || task.status,
    priorityTranslations[task.priority] || task.priority,
    task.dueDate || '',
    task.createdAt
  ]);

  const date = new Date().toLocaleDateString('de-DE');
  const filenameStr = `Aufgaben_${venueName}_${date}`;
  exportToCSV({ filename: filenameStr, headers, data: rows });
};

// ============================================
// ANALYTICS EXPORT
// ============================================

interface AnalyticsData {
  date: string;
  revenue: number;
  laborCost: number;
  shifts: number;
  tasksCompleted: number;
}

export const exportAnalyticsCSV = (
  analyticsData: AnalyticsData[],
  dateRange: { from: Date; to: Date },
  venueName: string
): void => {
  const formatDate = (date: Date) => date.toLocaleDateString('de-DE');

  const headers = [
    'Datum',
    'Umsatz (€)',
    'Personalkosten (€)',
    'Schichten',
    'Erledigte Aufgaben'
  ];

  const rows: (string | number)[][] = analyticsData.map(d => [
    d.date,
    d.revenue.toFixed(2).replace('.', ','),
    d.laborCost.toFixed(2).replace('.', ','),
    d.shifts,
    d.tasksCompleted
  ]);

  // Add totals
  const totalRevenue = analyticsData.reduce((sum, d) => sum + d.revenue, 0);
  const totalLabor = analyticsData.reduce((sum, d) => sum + d.laborCost, 0);
  const totalShifts = analyticsData.reduce((sum, d) => sum + d.shifts, 0);
  const totalTasks = analyticsData.reduce((sum, d) => sum + d.tasksCompleted, 0);

  rows.push([]);
  rows.push([
    'GESAMT',
    totalRevenue.toFixed(2).replace('.', ','),
    totalLabor.toFixed(2).replace('.', ','),
    totalShifts,
    totalTasks
  ]);

  const filenameStr = `Statistik_${venueName}_${formatDate(dateRange.from)}_${formatDate(dateRange.to)}`;
  exportToCSV({ filename: filenameStr, headers, data: rows });
};

// ============================================
// HELPER FUNCTIONS
// ============================================

const downloadBlob = (blob: Blob, filename: string): void => {
  const url = URL.createObjectURL(blob);
  const link = document.createElement('a');
  link.href = url;
  link.download = filename;
  document.body.appendChild(link);
  link.click();
  document.body.removeChild(link);
  URL.revokeObjectURL(url);
};

// ============================================
// PDF EXPORT (using browser print)
// ============================================

export const printToPDF = (title: string, content: string): void => {
  const printWindow = window.open('', '_blank');
  if (!printWindow) {
    alert('Popup blockiert. Bitte erlauben Sie Popups für diese Seite.');
    return;
  }

  const now = new Date();
  const dateStr = now.toLocaleDateString('de-DE');
  const timeStr = now.toLocaleTimeString('de-DE');

  printWindow.document.write(`
    <!DOCTYPE html>
    <html lang="de">
    <head>
      <meta charset="UTF-8">
      <title>${title}</title>
      <style>
        body {
          font-family: 'Segoe UI', Arial, sans-serif;
          padding: 40px;
          max-width: 800px;
          margin: 0 auto;
        }
        h1 { color: #1a1a2e; border-bottom: 2px solid #6b21a8; padding-bottom: 10px; }
        h2 { color: #6b21a8; margin-top: 30px; }
        table { width: 100%; border-collapse: collapse; margin: 20px 0; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #6b21a8; color: white; }
        tr:nth-child(even) { background-color: #f9f9f9; }
        .footer { margin-top: 40px; text-align: center; color: #666; font-size: 12px; }
        @media print {
          body { padding: 20px; }
          .no-print { display: none; }
        }
      </style>
    </head>
    <body>
      ${content}
      <div class="footer">
        <p>Erstellt am ${dateStr} um ${timeStr}</p>
        <p>WiesbadenAfterDark - Venue Management</p>
      </div>
      <script>
        window.onload = function() { window.print(); }
      </script>
    </body>
    </html>
  `);
  printWindow.document.close();
};

export default {
  exportToCSV,
  exportTimesheetCSV,
  exportInventoryCSV,
  exportEmployeesCSV,
  exportTasksCSV,
  exportAnalyticsCSV,
  printToPDF,
};

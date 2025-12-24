import { useState, useMemo, useEffect, useCallback } from 'react';
import {
  TrendingUp,
  TrendingDown,
  DollarSign,
  Clock,
  ShoppingBag,
  ChevronLeft,
  ChevronRight,
  BarChart3,
  Users,
  Loader2,
  AlertCircle,
  Info,
} from 'lucide-react';
import { cn } from '../lib/utils';
import { supabaseApi } from '../services/supabaseApi';

type DateRange = 'week' | 'month' | 'quarter';

interface DailyStats {
  date: string;
  shifts: number;
  hoursWorked: number;
  laborCost: number;
  tasksCompleted: number;
  bookings: number;
}

interface PeakHour {
  hour: string;
  customers: number;
  revenue: number;
  percentage: number;
}

interface TopProduct {
  name: string;
  sold: number;
  revenue: number;
  trend: number;
}

interface LaborCostByRole {
  role: string;
  totalHours: number;
  totalCost: number;
  shiftCount: number;
}

interface TaskStats {
  total: number;
  completed: number;
  pending: number;
  inProgress: number;
  overdue: number;
  completionRate: number;
}

interface EmployeePerformance {
  id: string;
  name: string;
  role: string;
  totalShifts: number;
  totalHours: number;
  totalEarnings: number;
  avgShiftLength: number;
  tasksCompleted: number;
}

// Role name translations
const roleNames: Record<string, string> = {
  owner: 'Inhaber',
  manager: 'Manager',
  bartender: 'Barkeeper',
  waiter: 'Kellner',
  security: 'Security',
  dj: 'DJ',
  cleaning: 'Reinigung',
  unknown: 'Sonstige',
};

// Format date for chart label
const formatDateLabel = (dateStr: string, range: DateRange): string => {
  const date = new Date(dateStr);
  return range === 'week'
    ? date.toLocaleDateString('de-DE', { weekday: 'short' })
    : date.toLocaleDateString('de-DE', { day: 'numeric', month: 'short' });
};

// Simulated peak hours (would come from POS/orders data)
const mockPeakHours: PeakHour[] = [
  { hour: '18:00', customers: 25, revenue: 450, percentage: 40 },
  { hour: '19:00', customers: 42, revenue: 820, percentage: 67 },
  { hour: '20:00', customers: 58, revenue: 1150, percentage: 92 },
  { hour: '21:00', customers: 62, revenue: 1380, percentage: 100 },
  { hour: '22:00', customers: 55, revenue: 1250, percentage: 89 },
  { hour: '23:00', customers: 48, revenue: 1100, percentage: 77 },
  { hour: '00:00', customers: 38, revenue: 850, percentage: 61 },
  { hour: '01:00', customers: 28, revenue: 620, percentage: 45 },
  { hour: '02:00', customers: 15, revenue: 320, percentage: 24 },
];

// Simulated top products (would come from POS/orders data)
const mockTopProducts: TopProduct[] = [
  { name: 'Aperol Spritz', sold: 245, revenue: 2205, trend: 12 },
  { name: 'Gin Tonic', sold: 198, revenue: 1980, trend: 8 },
  { name: 'Long Island', sold: 156, revenue: 1716, trend: -5 },
  { name: 'Moscow Mule', sold: 134, revenue: 1340, trend: 22 },
  { name: 'Mojito', sold: 121, revenue: 1089, trend: 3 },
  { name: 'Espresso Martini', sold: 98, revenue: 1078, trend: 45 },
];

export function Analytics() {
  const [dateRange, setDateRange] = useState<DateRange>('week');
  const [weekOffset, setWeekOffset] = useState(0);
  const [laborCosts, setLaborCosts] = useState<LaborCostByRole[]>([]);
  const [realLaborTotal, setRealLaborTotal] = useState<number>(0);
  const [dailyStats, setDailyStats] = useState<DailyStats[]>([]);
  const [taskStats, setTaskStats] = useState<TaskStats | null>(null);
  // Employee performance data - reserved for future Employee section
  const [_employeePerformance, setEmployeePerformance] = useState<EmployeePerformance[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  // Get date range for API calls
  const getDateParams = useCallback(() => {
    const today = new Date();
    let startDate: Date;
    let endDate: Date = new Date(today);

    if (dateRange === 'week') {
      startDate = new Date(today);
      startDate.setDate(startDate.getDate() - 7 * (1 + weekOffset));
      endDate = new Date(today);
      endDate.setDate(endDate.getDate() - 7 * weekOffset);
    } else if (dateRange === 'month') {
      startDate = new Date(today);
      startDate.setDate(startDate.getDate() - 30);
    } else {
      startDate = new Date(today);
      startDate.setDate(startDate.getDate() - 90);
    }

    return {
      startDate: startDate.toISOString(),
      endDate: endDate.toISOString(),
    };
  }, [dateRange, weekOffset]);

  // Fetch all analytics data
  const fetchAnalyticsData = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const params = getDateParams();

      // Fetch all data in parallel
      const [laborResult, dailyResult, taskResult, employeeResult] = await Promise.all([
        supabaseApi.getLaborCostsByRole(params),
        supabaseApi.getDailyStats(params),
        supabaseApi.getTaskStats(params),
        supabaseApi.getEmployeePerformance(params),
      ]);

      // Set labor costs
      if (laborResult.error) throw laborResult.error;
      setLaborCosts(laborResult.data || []);
      setRealLaborTotal(laborResult.data?.reduce((sum, item) => sum + item.totalCost, 0) || 0);

      // Set daily stats
      if (dailyResult.error) throw dailyResult.error;
      setDailyStats(dailyResult.data || []);

      // Set task stats
      if (taskResult.error) throw taskResult.error;
      setTaskStats(taskResult.data);

      // Set employee performance
      if (employeeResult.error) throw employeeResult.error;
      setEmployeePerformance(employeeResult.data || []);

    } catch (err) {
      setError(err instanceof Error ? err.message : 'Fehler beim Laden der Daten');
    } finally {
      setLoading(false);
    }
  }, [getDateParams]);

  useEffect(() => {
    fetchAnalyticsData();
  }, [fetchAnalyticsData]);

  // Calculate summary stats from real data
  const stats = useMemo(() => {
    const totalHoursWorked = dailyStats.reduce((sum, d) => sum + d.hoursWorked, 0);
    const totalShifts = dailyStats.reduce((sum, d) => sum + d.shifts, 0);
    const totalTasksCompleted = dailyStats.reduce((sum, d) => sum + d.tasksCompleted, 0);
    const totalBookings = dailyStats.reduce((sum, d) => sum + d.bookings, 0);
    const avgDailyHours = dailyStats.length > 0 ? totalHoursWorked / dailyStats.length : 0;

    return {
      totalHoursWorked: Math.round(totalHoursWorked * 10) / 10,
      totalShifts,
      totalLaborCost: realLaborTotal,
      totalTasksCompleted,
      totalBookings,
      avgDailyHours: Math.round(avgDailyHours * 10) / 10,
      taskCompletionRate: taskStats?.completionRate || 0,
      overdueTasksCount: taskStats?.overdue || 0,
    };
  }, [dailyStats, realLaborTotal, taskStats]);

  // Calculate max values for chart scaling
  const maxHoursWorked = Math.max(...dailyStats.map(d => d.hoursWorked), 1);

  // Calculate total labor hours and max cost for percentage
  const totalLaborHours = laborCosts.reduce((sum, item) => sum + item.totalHours, 0);
  const maxLaborCost = Math.max(...laborCosts.map(item => item.totalCost), 1);

  // Date range navigation
  const getRangeLabel = () => {
    const today = new Date();
    if (dateRange === 'week') {
      const start = new Date(today);
      start.setDate(start.getDate() - 7 * (1 + weekOffset) + 1);
      const end = new Date(today);
      end.setDate(end.getDate() - 7 * weekOffset);
      return `${start.toLocaleDateString('de-DE', { day: 'numeric', month: 'short' })} - ${end.toLocaleDateString('de-DE', { day: 'numeric', month: 'short' })}`;
    }
    return dateRange === 'month' ? 'Letzte 30 Tage' : 'Letztes Quartal';
  };

  return (
    <div className="max-w-2xl mx-auto space-y-6 animate-fade-in">
      {/* Header */}
      <div>
        <h1 className="text-2xl font-bold text-foreground">Analysen</h1>
        <p className="text-foreground-muted">Geschäftseinblicke & Berichte</p>
      </div>

      {/* Data Source Info */}
      <div className="flex items-center gap-2 p-3 rounded-lg bg-accent-cyan/10 border border-accent-cyan/20 text-accent-cyan text-sm">
        <Info size={16} />
        <span>Personalkosten: Echte Daten | Umsatz & Produkte: Simuliert (Kassensystem-Integration ausstehend)</span>
      </div>

      {/* Error Toast */}
      {error && (
        <div className="flex items-center gap-2 p-3 rounded-lg bg-error/10 border border-error/20 text-error">
          <AlertCircle size={18} />
          <span className="text-sm">{error}</span>
        </div>
      )}

      {/* Date Range Selector */}
      <div className="flex items-center justify-between">
        <div className="flex bg-white/5 rounded-xl p-1">
          {(['week', 'month', 'quarter'] as DateRange[]).map((range) => (
            <button
              key={range}
              onClick={() => {
                setDateRange(range);
                setWeekOffset(0);
              }}
              className={cn(
                'px-4 py-2 rounded-lg text-sm font-medium transition-all',
                dateRange === range
                  ? 'bg-primary-500 text-white'
                  : 'text-foreground-muted hover:text-foreground'
              )}
            >
              {range === 'week' ? 'Woche' : range === 'month' ? 'Monat' : 'Quartal'}
            </button>
          ))}
        </div>

        {dateRange === 'week' && (
          <div className="flex items-center gap-2">
            <button
              onClick={() => setWeekOffset(weekOffset + 1)}
              className="p-2 bg-white/10 rounded-lg hover:bg-white/20 transition-all"
            >
              <ChevronLeft size={18} />
            </button>
            <span className="text-sm text-foreground-muted min-w-[140px] text-center">
              {getRangeLabel()}
            </span>
            <button
              onClick={() => setWeekOffset(Math.max(0, weekOffset - 1))}
              disabled={weekOffset === 0}
              className="p-2 bg-white/10 rounded-lg hover:bg-white/20 transition-all disabled:opacity-50"
            >
              <ChevronRight size={18} />
            </button>
          </div>
        )}
      </div>

      {/* Summary Stats */}
      <div className="grid grid-cols-2 gap-3">
        <div className="glass-card p-4 rounded-xl">
          <div className="flex items-center gap-2 mb-2">
            <div className="p-2 bg-primary-500/20 rounded-lg">
              <Clock size={16} className="text-primary-400" />
            </div>
            <span className="text-foreground-muted text-sm">Arbeitsstunden</span>
            <span className="text-[10px] px-1.5 py-0.5 rounded bg-success/20 text-success">Live</span>
          </div>
          <p className="text-2xl font-bold text-foreground">
            {stats.totalHoursWorked}h
          </p>
          <p className="text-xs text-foreground-muted mt-1">
            {stats.totalShifts} Schichten
          </p>
        </div>

        <div className="glass-card p-4 rounded-xl">
          <div className="flex items-center gap-2 mb-2">
            <div className="p-2 bg-error/20 rounded-lg">
              <DollarSign size={16} className="text-error" />
            </div>
            <span className="text-foreground-muted text-sm">Personalkosten</span>
            <span className="text-[10px] px-1.5 py-0.5 rounded bg-success/20 text-success">Live</span>
          </div>
          <p className="text-2xl font-bold text-foreground">
            €{stats.totalLaborCost.toLocaleString('de-DE')}
          </p>
          <p className="text-xs text-foreground-muted mt-1">
            Ø €{stats.totalHoursWorked > 0 ? Math.round(stats.totalLaborCost / stats.totalHoursWorked) : 0}/h
          </p>
        </div>

        <div className="glass-card p-4 rounded-xl">
          <div className="flex items-center gap-2 mb-2">
            <div className="p-2 bg-success/20 rounded-lg">
              <TrendingUp size={16} className="text-success" />
            </div>
            <span className="text-foreground-muted text-sm">Aufgaben</span>
            <span className="text-[10px] px-1.5 py-0.5 rounded bg-success/20 text-success">Live</span>
          </div>
          <p className="text-2xl font-bold text-foreground">
            {stats.totalTasksCompleted}
          </p>
          <p className="text-xs text-foreground-muted mt-1">
            {stats.taskCompletionRate}% erledigt
          </p>
        </div>

        <div className="glass-card p-4 rounded-xl">
          <div className="flex items-center gap-2 mb-2">
            <div className="p-2 bg-accent-cyan/20 rounded-lg">
              <Users size={16} className="text-accent-cyan" />
            </div>
            <span className="text-foreground-muted text-sm">Buchungen</span>
            <span className="text-[10px] px-1.5 py-0.5 rounded bg-success/20 text-success">Live</span>
          </div>
          <p className="text-2xl font-bold text-foreground">
            {stats.totalBookings}
          </p>
          <p className="text-xs text-foreground-muted mt-1">
            Im Zeitraum
          </p>
        </div>
      </div>

      {/* Daily Activity Chart */}
      <div className="glass-card p-4 rounded-xl">
        <div className="flex items-center justify-between mb-4">
          <div className="flex items-center gap-2">
            <h3 className="text-sm font-medium text-foreground">Tägliche Aktivität</h3>
            <span className="text-[10px] px-1.5 py-0.5 rounded bg-success/20 text-success">Live</span>
          </div>
          <div className="flex items-center gap-4 text-xs">
            <div className="flex items-center gap-1.5">
              <div className="w-3 h-3 rounded-sm bg-primary-500" />
              <span className="text-foreground-muted">Stunden</span>
            </div>
            <div className="flex items-center gap-1.5">
              <div className="w-3 h-3 rounded-sm bg-warning" />
              <span className="text-foreground-muted">Kosten</span>
            </div>
          </div>
        </div>

        {/* Bar Chart */}
        {loading ? (
          <div className="flex items-center justify-center h-40">
            <Loader2 size={24} className="animate-spin text-primary-400" />
          </div>
        ) : dailyStats.length > 0 ? (
          <div className="flex items-end gap-1 h-40">
            {dailyStats.slice(-14).map((data, i) => (
              <div key={i} className="flex-1 flex flex-col items-center gap-1">
                <div className="w-full flex flex-col items-center gap-0.5" style={{ height: '130px' }}>
                  {/* Hours worked bar */}
                  <div
                    className="w-full bg-gradient-to-t from-primary-500 to-primary-400 rounded-t-sm transition-all hover:opacity-80"
                    style={{ height: `${(data.hoursWorked / maxHoursWorked) * 100}%` }}
                    title={`${data.hoursWorked}h · €${data.laborCost.toLocaleString('de-DE')}`}
                  />
                </div>
                <span className="text-[10px] text-foreground-dim truncate">
                  {formatDateLabel(data.date, dateRange)}
                </span>
              </div>
            ))}
          </div>
        ) : (
          <div className="flex items-center justify-center h-40 text-foreground-muted">
            <div className="text-center">
              <BarChart3 size={32} className="mx-auto mb-2 opacity-50" />
              <p>Keine Daten im ausgewählten Zeitraum</p>
            </div>
          </div>
        )}

        {dailyStats.length > 0 && (
          <p className="text-xs text-foreground-dim mt-3 text-center">
            Ø {stats.avgDailyHours}h pro Tag · {stats.totalShifts} Schichten insgesamt
          </p>
        )}
      </div>

      {/* Peak Hours */}
      <div className="glass-card p-4 rounded-xl">
        <div className="flex items-center gap-2 mb-4">
          <Clock size={18} className="text-accent-cyan" />
          <h3 className="text-sm font-medium text-foreground">Stoßzeiten</h3>
          <span className="text-[10px] px-1.5 py-0.5 rounded bg-warning/20 text-warning">Simuliert</span>
        </div>

        <div className="space-y-2">
          {mockPeakHours.map((hour, i) => (
            <div key={i} className="flex items-center gap-3">
              <span className="w-12 text-xs text-foreground-muted font-mono">{hour.hour}</span>
              <div className="flex-1 h-6 bg-white/5 rounded-full overflow-hidden">
                <div
                  className={cn(
                    'h-full rounded-full transition-all',
                    hour.percentage === 100
                      ? 'bg-gradient-to-r from-primary-500 to-accent-pink'
                      : hour.percentage >= 70
                        ? 'bg-primary-500/80'
                        : 'bg-primary-500/50'
                  )}
                  style={{ width: `${hour.percentage}%` }}
                />
              </div>
              <span className="w-16 text-xs text-foreground-muted text-right">
                €{hour.revenue.toLocaleString('de-DE')}
              </span>
            </div>
          ))}
        </div>

        <p className="text-xs text-foreground-dim mt-3 text-center">
          Stoßzeit: <span className="text-accent-pink font-medium">21:00</span> mit 62 Gästen
        </p>
      </div>

      {/* Top Products */}
      <div className="glass-card p-4 rounded-xl">
        <div className="flex items-center gap-2 mb-4">
          <ShoppingBag size={18} className="text-accent-pink" />
          <h3 className="text-sm font-medium text-foreground">Top Produkte</h3>
          <span className="text-[10px] px-1.5 py-0.5 rounded bg-warning/20 text-warning">Simuliert</span>
        </div>

        <div className="space-y-3">
          {mockTopProducts.map((product, i) => (
            <div key={i} className="flex items-center gap-3">
              <span className="w-6 h-6 flex items-center justify-center bg-white/10 rounded-full text-xs font-bold text-foreground-muted">
                {i + 1}
              </span>
              <div className="flex-1">
                <p className="text-sm font-medium text-foreground">{product.name}</p>
                <p className="text-xs text-foreground-dim">{product.sold} verkauft</p>
              </div>
              <div className="text-right">
                <p className="text-sm font-medium text-foreground">€{product.revenue.toLocaleString('de-DE')}</p>
                <p className={cn(
                  'text-xs flex items-center justify-end gap-0.5',
                  product.trend >= 0 ? 'text-success' : 'text-error'
                )}>
                  {product.trend >= 0 ? <TrendingUp size={10} /> : <TrendingDown size={10} />}
                  {Math.abs(product.trend)}%
                </p>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Labor Cost Breakdown - REAL DATA */}
      <div className="glass-card p-4 rounded-xl">
        <div className="flex items-center gap-2 mb-4">
          <Users size={18} className="text-warning" />
          <h3 className="text-sm font-medium text-foreground">Personalkosten nach Rolle</h3>
          <span className="text-[10px] px-1.5 py-0.5 rounded bg-success/20 text-success">Live</span>
        </div>

        {loading ? (
          <div className="flex items-center justify-center py-8">
            <Loader2 size={24} className="animate-spin text-primary-400" />
          </div>
        ) : laborCosts.length > 0 ? (
          <div className="space-y-3">
            {laborCosts.map((item, i) => {
              const percentage = (item.totalCost / maxLaborCost) * 100;
              return (
                <div key={i}>
                  <div className="flex items-center justify-between mb-1">
                    <span className="text-sm text-foreground">{roleNames[item.role] || item.role}</span>
                    <span className="text-sm text-foreground-muted">
                      {item.totalHours}h · €{item.totalCost.toLocaleString('de-DE')}
                    </span>
                  </div>
                  <div className="h-2 bg-white/10 rounded-full overflow-hidden">
                    <div
                      className="h-full bg-gradient-to-r from-warning to-warning/60 rounded-full"
                      style={{ width: `${percentage}%` }}
                    />
                  </div>
                </div>
              );
            })}
          </div>
        ) : (
          <div className="text-center py-6 text-foreground-muted">
            <Users size={32} className="mx-auto mb-2 opacity-50" />
            <p>Keine abgeschlossenen Schichten im ausgewählten Zeitraum</p>
          </div>
        )}

        {laborCosts.length > 0 && (
          <div className="flex items-center justify-between mt-4 pt-3 border-t border-border">
            <span className="text-sm font-medium text-foreground">Gesamte Personalkosten</span>
            <span className="text-lg font-bold text-foreground">
              €{realLaborTotal.toLocaleString('de-DE')}
            </span>
          </div>
        )}

        {laborCosts.length > 0 && (
          <p className="text-xs text-foreground-dim mt-2 text-center">
            Gesamt: {totalLaborHours.toFixed(1)} Stunden in {laborCosts.reduce((sum, l) => sum + l.shiftCount, 0)} Schichten
          </p>
        )}
      </div>

      {/* Quick Insights */}
      <div className="glass-card p-4 rounded-xl bg-gradient-to-br from-primary-500/10 to-accent-pink/10 border-primary-500/20">
        <h3 className="text-sm font-medium text-foreground mb-3 flex items-center gap-2">
          <span className="text-lg">💡</span> Schnelle Einblicke
        </h3>
        <ul className="space-y-2 text-sm text-foreground-muted">
          <li className="flex items-start gap-2">
            <span className="text-success">✓</span>
            <span>Wochenendumsatz ist <strong className="text-foreground">2,1x höher</strong> als an Wochentagen</span>
          </li>
          <li className="flex items-start gap-2">
            <span className="text-success">✓</span>
            <span><strong className="text-foreground">Espresso Martini</strong> hat das höchste Wachstum (+45%)</span>
          </li>
          <li className="flex items-start gap-2">
            <span className="text-warning">!</span>
            <span>Personalkosten erreichten Spitzenwert am <strong className="text-foreground">Freitag</strong> - Schichtplanung überprüfen</span>
          </li>
          <li className="flex items-start gap-2">
            <span className="text-accent-cyan">→</span>
            <span>Beste ROI-Stunde: <strong className="text-foreground">21:00-22:00</strong> mit €22/Gast</span>
          </li>
        </ul>
      </div>
    </div>
  );
}

export default Analytics;

import { useState, useMemo } from 'react';
import {
  TrendingUp,
  TrendingDown,
  DollarSign,
  Clock,
  ShoppingBag,
  ChevronLeft,
  ChevronRight,
  BarChart3,
  PieChart,
  Users,
  ArrowUpRight,
  ArrowDownRight,
} from 'lucide-react';
import { cn } from '../lib/utils';

type DateRange = 'week' | 'month' | 'quarter';

interface RevenueDataPoint {
  date: string;
  label: string;
  revenue: number;
  costs: number;
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

// Generate mock data for revenue chart
const generateRevenueData = (range: DateRange): RevenueDataPoint[] => {
  const data: RevenueDataPoint[] = [];
  const today = new Date();
  const days = range === 'week' ? 7 : range === 'month' ? 30 : 90;

  for (let i = days - 1; i >= 0; i--) {
    const date = new Date(today);
    date.setDate(date.getDate() - i);

    // Simulate higher revenue on weekends
    const dayOfWeek = date.getDay();
    const isWeekend = dayOfWeek === 0 || dayOfWeek === 5 || dayOfWeek === 6;
    const baseRevenue = isWeekend ? 2500 : 1200;
    const revenue = baseRevenue + Math.random() * (isWeekend ? 1500 : 800);
    const costs = revenue * (0.25 + Math.random() * 0.1); // 25-35% costs

    data.push({
      date: date.toISOString().split('T')[0],
      label: range === 'week'
        ? date.toLocaleDateString('de-DE', { weekday: 'short' })
        : date.toLocaleDateString('de-DE', { day: 'numeric', month: 'short' }),
      revenue: Math.round(revenue),
      costs: Math.round(costs),
    });
  }

  return data;
};

// Mock peak hours data
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

// Mock top products
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

  // Generate revenue data based on selected range
  const revenueData = useMemo(() => generateRevenueData(dateRange), [dateRange]);

  // Calculate summary stats
  const stats = useMemo(() => {
    const totalRevenue = revenueData.reduce((sum, d) => sum + d.revenue, 0);
    const totalCosts = revenueData.reduce((sum, d) => sum + d.costs, 0);
    const avgDailyRevenue = totalRevenue / revenueData.length;
    const profitMargin = ((totalRevenue - totalCosts) / totalRevenue) * 100;

    return {
      totalRevenue,
      totalCosts,
      avgDailyRevenue,
      profitMargin,
      // Mock comparison data
      revenueChange: 12.5,
      costChange: -3.2,
      customerChange: 8.7,
    };
  }, [revenueData]);

  // Calculate max revenue for chart scaling
  const maxRevenue = Math.max(...revenueData.map(d => d.revenue));

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
    return dateRange === 'month' ? 'Last 30 Days' : 'Last Quarter';
  };

  return (
    <div className="max-w-2xl mx-auto space-y-6 animate-fade-in">
      {/* Header */}
      <div>
        <h1 className="text-2xl font-bold text-foreground">Analytics</h1>
        <p className="text-foreground-muted">Business insights & reports</p>
      </div>

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
                'px-4 py-2 rounded-lg text-sm font-medium transition-all capitalize',
                dateRange === range
                  ? 'bg-primary-500 text-white'
                  : 'text-foreground-muted hover:text-foreground'
              )}
            >
              {range}
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
            <div className="p-2 bg-success/20 rounded-lg">
              <DollarSign size={16} className="text-success" />
            </div>
            <span className="text-foreground-muted text-sm">Revenue</span>
          </div>
          <p className="text-2xl font-bold text-foreground">
            €{stats.totalRevenue.toLocaleString('de-DE')}
          </p>
          <div className={cn(
            'flex items-center gap-1 text-xs mt-1',
            stats.revenueChange >= 0 ? 'text-success' : 'text-error'
          )}>
            {stats.revenueChange >= 0 ? <ArrowUpRight size={12} /> : <ArrowDownRight size={12} />}
            <span>{Math.abs(stats.revenueChange)}% vs prev period</span>
          </div>
        </div>

        <div className="glass-card p-4 rounded-xl">
          <div className="flex items-center gap-2 mb-2">
            <div className="p-2 bg-error/20 rounded-lg">
              <TrendingDown size={16} className="text-error" />
            </div>
            <span className="text-foreground-muted text-sm">Labor Costs</span>
          </div>
          <p className="text-2xl font-bold text-foreground">
            €{stats.totalCosts.toLocaleString('de-DE')}
          </p>
          <div className={cn(
            'flex items-center gap-1 text-xs mt-1',
            stats.costChange <= 0 ? 'text-success' : 'text-error'
          )}>
            {stats.costChange <= 0 ? <ArrowDownRight size={12} /> : <ArrowUpRight size={12} />}
            <span>{Math.abs(stats.costChange)}% vs prev period</span>
          </div>
        </div>

        <div className="glass-card p-4 rounded-xl">
          <div className="flex items-center gap-2 mb-2">
            <div className="p-2 bg-accent-cyan/20 rounded-lg">
              <BarChart3 size={16} className="text-accent-cyan" />
            </div>
            <span className="text-foreground-muted text-sm">Avg Daily</span>
          </div>
          <p className="text-2xl font-bold text-foreground">
            €{Math.round(stats.avgDailyRevenue).toLocaleString('de-DE')}
          </p>
        </div>

        <div className="glass-card p-4 rounded-xl">
          <div className="flex items-center gap-2 mb-2">
            <div className="p-2 bg-primary-500/20 rounded-lg">
              <PieChart size={16} className="text-primary-400" />
            </div>
            <span className="text-foreground-muted text-sm">Profit Margin</span>
          </div>
          <p className="text-2xl font-bold text-foreground">
            {stats.profitMargin.toFixed(1)}%
          </p>
        </div>
      </div>

      {/* Revenue Chart */}
      <div className="glass-card p-4 rounded-xl">
        <div className="flex items-center justify-between mb-4">
          <h3 className="text-sm font-medium text-foreground">Revenue vs Costs</h3>
          <div className="flex items-center gap-4 text-xs">
            <div className="flex items-center gap-1.5">
              <div className="w-3 h-3 rounded-sm bg-primary-500" />
              <span className="text-foreground-muted">Revenue</span>
            </div>
            <div className="flex items-center gap-1.5">
              <div className="w-3 h-3 rounded-sm bg-error/60" />
              <span className="text-foreground-muted">Costs</span>
            </div>
          </div>
        </div>

        {/* Bar Chart */}
        <div className="flex items-end gap-1 h-40">
          {revenueData.slice(-14).map((data, i) => (
            <div key={i} className="flex-1 flex flex-col items-center gap-1">
              <div className="w-full flex flex-col items-center gap-0.5" style={{ height: '130px' }}>
                {/* Revenue bar */}
                <div
                  className="w-full bg-gradient-to-t from-primary-500 to-primary-400 rounded-t-sm transition-all hover:opacity-80"
                  style={{ height: `${(data.revenue / maxRevenue) * 100}%` }}
                  title={`€${data.revenue.toLocaleString('de-DE')}`}
                />
              </div>
              <span className="text-[10px] text-foreground-dim truncate">
                {data.label}
              </span>
            </div>
          ))}
        </div>
      </div>

      {/* Peak Hours */}
      <div className="glass-card p-4 rounded-xl">
        <div className="flex items-center gap-2 mb-4">
          <Clock size={18} className="text-accent-cyan" />
          <h3 className="text-sm font-medium text-foreground">Peak Hours</h3>
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
          Peak time: <span className="text-accent-pink font-medium">21:00</span> with 62 customers
        </p>
      </div>

      {/* Top Products */}
      <div className="glass-card p-4 rounded-xl">
        <div className="flex items-center gap-2 mb-4">
          <ShoppingBag size={18} className="text-accent-pink" />
          <h3 className="text-sm font-medium text-foreground">Top Products</h3>
        </div>

        <div className="space-y-3">
          {mockTopProducts.map((product, i) => (
            <div key={i} className="flex items-center gap-3">
              <span className="w-6 h-6 flex items-center justify-center bg-white/10 rounded-full text-xs font-bold text-foreground-muted">
                {i + 1}
              </span>
              <div className="flex-1">
                <p className="text-sm font-medium text-foreground">{product.name}</p>
                <p className="text-xs text-foreground-dim">{product.sold} sold</p>
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

      {/* Labor Cost Breakdown */}
      <div className="glass-card p-4 rounded-xl">
        <div className="flex items-center gap-2 mb-4">
          <Users size={18} className="text-warning" />
          <h3 className="text-sm font-medium text-foreground">Labor Cost Breakdown</h3>
        </div>

        <div className="space-y-3">
          {[
            { role: 'Bartenders', hours: 156, cost: 2340, percentage: 45 },
            { role: 'Security', hours: 84, cost: 1680, percentage: 32 },
            { role: 'Management', hours: 48, cost: 960, percentage: 18 },
            { role: 'Cleaning', hours: 21, cost: 252, percentage: 5 },
          ].map((item, i) => (
            <div key={i}>
              <div className="flex items-center justify-between mb-1">
                <span className="text-sm text-foreground">{item.role}</span>
                <span className="text-sm text-foreground-muted">{item.hours}h · €{item.cost.toLocaleString('de-DE')}</span>
              </div>
              <div className="h-2 bg-white/10 rounded-full overflow-hidden">
                <div
                  className="h-full bg-gradient-to-r from-warning to-warning/60 rounded-full"
                  style={{ width: `${item.percentage}%` }}
                />
              </div>
            </div>
          ))}
        </div>

        <div className="flex items-center justify-between mt-4 pt-3 border-t border-border">
          <span className="text-sm font-medium text-foreground">Total Labor Cost</span>
          <span className="text-lg font-bold text-foreground">€{stats.totalCosts.toLocaleString('de-DE')}</span>
        </div>
      </div>

      {/* Quick Insights */}
      <div className="glass-card p-4 rounded-xl bg-gradient-to-br from-primary-500/10 to-accent-pink/10 border-primary-500/20">
        <h3 className="text-sm font-medium text-foreground mb-3 flex items-center gap-2">
          <span className="text-lg">💡</span> Quick Insights
        </h3>
        <ul className="space-y-2 text-sm text-foreground-muted">
          <li className="flex items-start gap-2">
            <span className="text-success">✓</span>
            <span>Weekend revenue is <strong className="text-foreground">2.1x higher</strong> than weekdays</span>
          </li>
          <li className="flex items-start gap-2">
            <span className="text-success">✓</span>
            <span><strong className="text-foreground">Espresso Martini</strong> has the highest growth (+45%)</span>
          </li>
          <li className="flex items-start gap-2">
            <span className="text-warning">!</span>
            <span>Labor costs peaked on <strong className="text-foreground">Friday</strong> - consider scheduling adjustments</span>
          </li>
          <li className="flex items-start gap-2">
            <span className="text-accent-cyan">→</span>
            <span>Best ROI hour: <strong className="text-foreground">21:00-22:00</strong> with €22/customer</span>
          </li>
        </ul>
      </div>
    </div>
  );
}

export default Analytics;

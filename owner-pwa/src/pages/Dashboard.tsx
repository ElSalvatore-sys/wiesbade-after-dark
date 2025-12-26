import { useState, useEffect, useCallback } from 'react';
import { cn } from '../lib/utils';
import {
  Calendar,
  BookOpen,
  Package,
  TrendingUp,
  Plus,
  Eye,
  ScanLine,
  ArrowUpRight,
  ArrowDownRight,
  Sparkles,
  RefreshCw,
  Users,
  Clock,
} from 'lucide-react';
import { motion } from 'framer-motion';
import type { DashboardStats } from '../types';
import { supabaseApi } from '../services/supabaseApi';
import { api } from '../services/api';
import { SkeletonStatCard, Skeleton } from '../components/Skeleton';
import { useRealtimeSubscription } from '../hooks';

interface DashboardProps {
  onNavigate: (page: string) => void;
}

const defaultStats: DashboardStats = {
  todaysBookings: 12,
  activeEvents: 3,
  lowStockItems: 5,
  todaysRevenue: 2450,
  weeklyRevenue: 18500,
  monthlyRevenue: 72000,
  totalCustomers: 1234,
  averageRating: 4.8,
};

interface StatCardProps {
  title: string;
  value: string | number;
  icon: React.ReactNode;
  trend?: { value: number; isPositive: boolean };
  gradient: 'purple' | 'pink' | 'cyan' | 'green' | 'orange';
  delay?: number;
  onClick?: () => void;
  clickable?: boolean;
}

function StatCard({ title, value, icon, trend, gradient, delay = 0, onClick, clickable = false }: StatCardProps) {
  const gradients = {
    purple: 'from-accent-purple/20 via-accent-purple/5 to-transparent border-accent-purple/20',
    pink: 'from-accent-pink/20 via-accent-pink/5 to-transparent border-accent-pink/20',
    cyan: 'from-accent-cyan/20 via-accent-cyan/5 to-transparent border-accent-cyan/20',
    green: 'from-success/20 via-success/5 to-transparent border-success/20',
    orange: 'from-warning/20 via-warning/5 to-transparent border-warning/20',
  };

  const iconBg = {
    purple: 'bg-accent-purple/20 text-accent-purple',
    pink: 'bg-accent-pink/20 text-accent-pink',
    cyan: 'bg-accent-cyan/20 text-accent-cyan',
    green: 'bg-success/20 text-success',
    orange: 'bg-warning/20 text-warning',
  };

  const CardWrapper = clickable ? motion.button : motion.div;

  return (
    <CardWrapper
      onClick={clickable ? onClick : undefined}
      className={cn(
        'stat-card bg-gradient-to-br text-left w-full group',
        gradients[gradient],
        clickable && 'cursor-pointer transition-all duration-300 hover:scale-[1.02] active:scale-[0.98]'
      )}
      style={{ animationDelay: `${delay}ms` }}
      whileHover={clickable ? { y: -4 } : {}}
      whileTap={clickable ? { scale: 0.98 } : {}}
      transition={{ type: "spring", stiffness: 400, damping: 25 }}
    >
      {/* Glow effect */}
      <div className={cn(
        'absolute -top-20 -right-20 w-40 h-40 rounded-full blur-3xl opacity-30 transition-opacity duration-300',
        gradient === 'purple' && 'bg-accent-purple',
        gradient === 'pink' && 'bg-accent-pink',
        gradient === 'cyan' && 'bg-accent-cyan',
        gradient === 'green' && 'bg-success',
        gradient === 'orange' && 'bg-warning',
        clickable && 'group-hover:opacity-50'
      )} />

      <div className="relative flex items-start justify-between">
        <div>
          <p className="text-sm text-foreground-secondary">{title}</p>
          <p className="mt-2 text-3xl font-bold text-foreground">{value}</p>
          {trend && (
            <div className={cn(
              'flex items-center gap-1 mt-2 text-sm',
              trend.isPositive ? 'text-success' : 'text-error'
            )}>
              {trend.isPositive ? <ArrowUpRight size={16} /> : <ArrowDownRight size={16} />}
              <span>{Math.abs(trend.value)}% vs last week</span>
            </div>
          )}
        </div>
        <div className={cn('p-3 rounded-xl', iconBg[gradient])}>
          {icon}
        </div>
      </div>

      {/* Click indicator for clickable cards */}
      {clickable && (
        <div className="absolute top-3 right-3 opacity-0 transition-opacity duration-300 group-hover:opacity-100">
          <ArrowUpRight size={16} className="text-foreground-secondary" />
        </div>
      )}
    </CardWrapper>
  );
}

interface QuickActionProps {
  title: string;
  description: string;
  icon: React.ReactNode;
  onClick: () => void;
}

function QuickAction({ title, description, icon, onClick }: QuickActionProps) {
  return (
    <button
      onClick={onClick}
      className={cn(
        'group relative flex items-center gap-4 p-5 rounded-xl w-full text-left',
        'bg-card border border-border',
        'transition-all duration-300 ease-out',
        'hover:border-primary-500/30 hover:shadow-glow-sm hover:-translate-y-0.5'
      )}
    >
      <div className="p-3 rounded-xl bg-gradient-primary text-white shadow-glow-sm transition-transform duration-300 group-hover:scale-110">
        {icon}
      </div>
      <div>
        <p className="font-semibold text-foreground">{title}</p>
        <p className="text-sm text-foreground-muted mt-0.5">{description}</p>
      </div>
      <ArrowUpRight
        size={18}
        className="absolute top-4 right-4 text-foreground-dim opacity-0 transition-all duration-300 group-hover:opacity-100"
      />
    </button>
  );
}

export function Dashboard({ onNavigate }: DashboardProps) {
  const [stats, setStats] = useState<DashboardStats>(defaultStats);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);

  const [shiftStats, setShiftStats] = useState({
    activeShifts: 0,
    totalHoursToday: 0,
    totalOvertimeToday: 0,
    employeesOnBreak: 0,
  });
  const [pendingTasks, setPendingTasks] = useState(0);
  const [recentActivity, setRecentActivity] = useState<any[]>([]);

  const fetchDashboard = useCallback(async (isRefresh = false) => {
    if (isRefresh) setRefreshing(true);
    else setLoading(true);

    try {
      // Fetch real data from Supabase and Railway API in parallel
      const [lowStockResult, shiftSummary, tasksResult, bookingsSummary, eventsResult, auditLogs] = await Promise.all([
        supabaseApi.getLowStockItems(),
        supabaseApi.getShiftsSummary(),
        supabaseApi.getTasks({ status: 'pending' }),
        supabaseApi.getBookingsSummary(),
        api.getEvents({ status: 'upcoming', limit: 100 }),
        supabaseApi.getAuditLogs(),
      ]);

      // Count today's events
      const today = new Date().toISOString().split('T')[0];
      const todayEvents = eventsResult.data?.events?.filter((event: any) => {
        const eventDate = event.start_time?.split('T')[0];
        return eventDate === today;
      }) || [];

      // Update stats with real data
      setStats(prev => ({
        ...prev,
        lowStockItems: lowStockResult.data?.length ?? defaultStats.lowStockItems,
        todaysBookings: bookingsSummary.total,
        activeEvents: todayEvents.length,
        // Keep revenue stats as defaults (no revenue tracking yet)
        todaysRevenue: defaultStats.todaysRevenue,
        weeklyRevenue: defaultStats.weeklyRevenue,
        monthlyRevenue: defaultStats.monthlyRevenue,
        totalCustomers: defaultStats.totalCustomers,
        averageRating: defaultStats.averageRating,
      }));

      // Set shift-specific stats
      setShiftStats(shiftSummary);

      // Set pending tasks count
      setPendingTasks(tasksResult.data?.length ?? 0);

      // Set recent activity (limit to 5 most recent)
      setRecentActivity(auditLogs?.slice(0, 5) || []);

    } catch (error) {
      console.error('Error fetching dashboard data:', error);
      // Keep using default stats on error
    }

    setLoading(false);
    setRefreshing(false);
  }, []);

  useEffect(() => {
    fetchDashboard();
  }, [fetchDashboard]);

  // Subscribe to Realtime for automatic UI updates
  useRealtimeSubscription({
    subscriptions: [
      { table: 'tasks', event: '*' },
      { table: 'shifts', event: '*' },
      { table: 'inventory_items', event: '*' },
    ],
    onDataChange: () => fetchDashboard(true),
    enabled: !loading,
    debounceMs: 1000, // Wait 1s to batch rapid changes
  });

  const formatCurrency = (amount: number) =>
    new Intl.NumberFormat('de-DE', { style: 'currency', currency: 'EUR' }).format(amount);

  if (loading) {
    return (
      <div className="space-y-8">
        {/* Header Skeleton */}
        <div className="flex items-center justify-between">
          <div className="space-y-2">
            <Skeleton className="h-8 w-40" />
            <Skeleton className="h-4 w-64" />
          </div>
          <Skeleton className="h-10 w-24 rounded-xl" />
        </div>

        {/* Stats Grid Skeleton */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
          <SkeletonStatCard />
          <SkeletonStatCard />
          <SkeletonStatCard />
          <SkeletonStatCard />
        </div>

        {/* Quick Actions Skeleton */}
        <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
          {[1, 2, 3, 4].map((i) => (
            <Skeleton key={i} className="h-20 rounded-2xl" />
          ))}
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-8 animate-fade-in">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <div className="flex items-center gap-2">
            <h1 className="text-2xl font-bold text-foreground">Dashboard</h1>
            <Sparkles size={20} className="text-accent-purple" />
          </div>
          <p className="text-foreground-secondary mt-1">
            Here's what's happening at your venue today
          </p>
        </div>
        <div className="flex items-center gap-3">
          <button
            onClick={() => fetchDashboard(true)}
            disabled={refreshing}
            className="flex items-center gap-2 px-4 py-2 bg-card border border-border rounded-xl hover:border-primary-500/30 transition-all disabled:opacity-50"
          >
            <RefreshCw size={16} className={refreshing ? 'animate-spin' : ''} />
            <span className="hidden sm:inline">Refresh</span>
          </button>
          <div className="hidden sm:block">
            <span className="badge badge-purple">Live</span>
          </div>
        </div>
      </div>

      {/* Stats Grid - Real Data */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        <StatCard
          title="Staff On Shift"
          value={shiftStats.activeShifts}
          icon={<Users size={24} />}
          gradient="purple"
          delay={0}
        />
        <StatCard
          title="Hours Worked Today"
          value={`${shiftStats.totalHoursToday}h`}
          icon={<Clock size={24} />}
          gradient="pink"
          delay={50}
        />
        <StatCard
          title="Low Stock Items"
          value={stats.lowStockItems}
          icon={<Package size={24} />}
          gradient="orange"
          delay={100}
          clickable
          onClick={() => {
            // Set filter in sessionStorage for Inventory page to pick up
            sessionStorage.setItem('inventoryViewMode', 'low');
            onNavigate('inventory');
          }}
        />
        <StatCard
          title="Pending Tasks"
          value={pendingTasks}
          icon={<Calendar size={24} />}
          gradient="cyan"
          delay={150}
        />
      </div>

      {/* Secondary Stats Grid - Demo Data */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        <StatCard
          title="Today's Bookings"
          value={stats.todaysBookings}
          icon={<BookOpen size={24} />}
          trend={{ value: 12, isPositive: true }}
          gradient="green"
          delay={200}
          clickable
          onClick={() => onNavigate('bookings')}
        />
        <StatCard
          title="Active Events"
          value={stats.activeEvents}
          icon={<Calendar size={24} />}
          gradient="pink"
          delay={250}
          clickable
          onClick={() => onNavigate('events')}
        />
        <StatCard
          title="Today's Revenue"
          value={formatCurrency(stats.todaysRevenue)}
          icon={<TrendingUp size={24} />}
          trend={{ value: 8, isPositive: true }}
          gradient="green"
          delay={300}
        />
        <StatCard
          title="Overtime Today"
          value={`${Math.floor(shiftStats.totalOvertimeToday / 60)}h ${shiftStats.totalOvertimeToday % 60}m`}
          icon={<Clock size={24} />}
          gradient={shiftStats.totalOvertimeToday > 0 ? 'orange' : 'green'}
          delay={350}
        />
      </div>

      {/* Quick Actions */}
      <div>
        <h2 className="text-lg font-semibold text-foreground mb-4">Quick Actions</h2>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          <QuickAction
            title="Create Event"
            description="Add a new event"
            icon={<Plus size={20} />}
            onClick={() => onNavigate('events')}
          />
          <QuickAction
            title="View Bookings"
            description="See reservations"
            icon={<Eye size={20} />}
            onClick={() => onNavigate('bookings')}
          />
          <QuickAction
            title="Scan Inventory"
            description="Check stock levels"
            icon={<ScanLine size={20} />}
            onClick={() => onNavigate('inventory')}
          />
        </div>
      </div>

      {/* Bottom Grid */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Revenue Card */}
        <div className="glass-card p-6">
          <h3 className="text-lg font-semibold text-foreground mb-4">Revenue Overview</h3>
          <div className="space-y-4">
            {[
              { label: 'Weekly Revenue', value: formatCurrency(stats.weeklyRevenue) },
              { label: 'Monthly Revenue', value: formatCurrency(stats.monthlyRevenue) },
              { label: 'Average Rating', value: stats.averageRating, suffix: '★' },
            ].map((item, i) => (
              <div key={i} className="flex items-center justify-between py-3 border-b border-white/5 last:border-0">
                <span className="text-foreground-secondary">{item.label}</span>
                <span className="font-semibold text-foreground">
                  {item.value}
                  {item.suffix && <span className="ml-1 text-warning">{item.suffix}</span>}
                </span>
              </div>
            ))}
          </div>
        </div>

        {/* Activity Card */}
        <div className="glass-card p-6">
          <h3 className="text-lg font-semibold text-foreground mb-4">Recent Activity</h3>
          <div className="space-y-3">
            {recentActivity.length > 0 ? (
              recentActivity.map((log, i) => (
                <div key={log.id || i} className="flex items-start gap-3 py-2">
                  <div className={cn(
                    'w-2 h-2 rounded-full mt-2 flex-shrink-0',
                    log.entity_type === 'booking' && 'bg-accent-purple',
                    log.entity_type === 'event' && 'bg-accent-pink',
                    log.entity_type === 'inventory' && 'bg-accent-cyan',
                    log.entity_type === 'task' && 'bg-success'
                  )} />
                  <div className="flex-1 min-w-0">
                    <p className="text-sm text-foreground truncate">{log.description}</p>
                    <p className="text-xs text-foreground-dim">
                      {new Date(log.created_at).toLocaleString('de-DE', {
                        hour: '2-digit',
                        minute: '2-digit',
                        day: '2-digit',
                        month: '2-digit'
                      })}
                    </p>
                  </div>
                </div>
              ))
            ) : (
              <p className="text-sm text-foreground-muted text-center py-4">No recent activity</p>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}

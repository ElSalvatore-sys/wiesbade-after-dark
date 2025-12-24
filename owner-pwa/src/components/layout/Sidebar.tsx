import { cn } from '../../lib/utils';
import {
  LayoutDashboard,
  Calendar,
  BookOpen,
  Package,
  Users,
  Clock,
  ClipboardList,
  BarChart3,
  Settings,
  History,
  ChevronLeft,
  ChevronRight,
  LogOut,
} from 'lucide-react';

interface SidebarProps {
  currentPage: string;
  onNavigate: (page: string) => void;
  onLogout: () => void;
  isCollapsed: boolean;
  onToggleCollapse: () => void;
  userRole?: string;
  hasPermission?: (permission: string) => boolean;
}

interface NavItem {
  id: string;
  label: string;
  icon: React.ReactNode;
}

const navItems: NavItem[] = [
  { id: 'dashboard', label: 'Dashboard', icon: <LayoutDashboard size={20} /> },
  { id: 'events', label: 'Events', icon: <Calendar size={20} /> },
  { id: 'bookings', label: 'Bookings', icon: <BookOpen size={20} /> },
  { id: 'inventory', label: 'Inventory', icon: <Package size={20} /> },
  { id: 'employees', label: 'Employees', icon: <Users size={20} /> },
  { id: 'shifts', label: 'Shifts', icon: <Clock size={20} /> },
  { id: 'tasks', label: 'Tasks', icon: <ClipboardList size={20} /> },
  { id: 'analytics', label: 'Analytics', icon: <BarChart3 size={20} /> },
  { id: 'audit', label: 'Protokoll', icon: <History size={20} /> },
  { id: 'settings', label: 'Settings', icon: <Settings size={20} /> },
];

export function Sidebar({
  currentPage,
  onNavigate,
  onLogout,
  isCollapsed,
  onToggleCollapse,
  userRole,
  hasPermission,
}: SidebarProps) {
  // Filter navigation items based on permissions
  const visibleNavItems = hasPermission
    ? navItems.filter((item) => hasPermission(item.id))
    : navItems;
  return (
    <aside
      className={cn(
        'fixed left-0 top-0 z-40 h-screen transition-all duration-300 ease-out',
        'bg-card/95 backdrop-blur-xl border-r border-white/5 flex flex-col',
        isCollapsed ? 'w-[72px]' : 'w-[240px]'
      )}
    >
      {/* Logo */}
      <div className="flex items-center h-16 px-4 border-b border-white/5">
        <div className="flex items-center gap-3">
          <div className="relative">
            <div className="w-10 h-10 rounded-xl bg-gradient-primary flex items-center justify-center flex-shrink-0 shadow-glow-sm">
              <span className="text-white font-bold text-lg">W</span>
            </div>
            <div className="absolute inset-0 rounded-xl bg-gradient-primary opacity-30 blur-md" />
          </div>
          {!isCollapsed && (
            <div className="overflow-hidden">
              <h1 className="text-sm font-bold text-foreground truncate">
                Wiesbaden
              </h1>
              <p className="text-xs text-foreground-muted truncate">
                Owner Portal
              </p>
            </div>
          )}
        </div>
      </div>

      {/* Role Badge */}
      {userRole && !isCollapsed && (
        <div className="px-4 py-2">
          <div className={cn(
            'px-3 py-1.5 rounded-lg text-xs font-medium text-center',
            userRole === 'owner' && 'bg-purple-500/20 text-purple-400',
            userRole === 'manager' && 'bg-pink-500/20 text-pink-400',
            userRole === 'bartender' && 'bg-amber-500/20 text-amber-400',
            userRole === 'waiter' && 'bg-cyan-500/20 text-cyan-400',
            userRole === 'security' && 'bg-red-500/20 text-red-400',
            userRole === 'dj' && 'bg-violet-500/20 text-violet-400',
            userRole === 'inventory' && 'bg-orange-500/20 text-orange-400',
            userRole === 'cleaning' && 'bg-gray-500/20 text-gray-400'
          )}>
            {userRole.charAt(0).toUpperCase() + userRole.slice(1)}
          </div>
        </div>
      )}

      {/* Navigation */}
      <nav className="flex-1 py-4 px-3 space-y-1 overflow-y-auto no-scrollbar">
        {visibleNavItems.map((item) => {
          const isActive = currentPage === item.id;
          return (
            <button
              key={item.id}
              onClick={() => onNavigate(item.id)}
              className={cn(
                'w-full flex items-center gap-3 px-3 py-3 rounded-xl transition-all duration-200',
                isActive
                  ? 'bg-gradient-primary text-white shadow-glow'
                  : 'text-foreground-secondary hover:bg-white/5 hover:text-foreground'
              )}
            >
              <span className="flex-shrink-0">{item.icon}</span>
              {!isCollapsed && (
                <span className="text-sm font-medium truncate">{item.label}</span>
              )}
            </button>
          );
        })}
      </nav>

      {/* Bottom section */}
      <div className="p-3 border-t border-white/5 space-y-1">
        <button
          onClick={onLogout}
          className={cn(
            'w-full flex items-center gap-3 px-3 py-3 rounded-xl transition-all duration-200',
            'text-foreground-secondary hover:text-error hover:bg-error/10'
          )}
        >
          <LogOut size={20} className="flex-shrink-0" />
          {!isCollapsed && <span className="text-sm font-medium">Logout</span>}
        </button>

        <button
          onClick={onToggleCollapse}
          className={cn(
            'w-full flex items-center gap-3 px-3 py-3 rounded-xl transition-all duration-200',
            'text-foreground-dim hover:text-foreground hover:bg-white/5'
          )}
        >
          {isCollapsed ? (
            <ChevronRight size={20} className="flex-shrink-0" />
          ) : (
            <>
              <ChevronLeft size={20} className="flex-shrink-0" />
              <span className="text-sm font-medium">Collapse</span>
            </>
          )}
        </button>
      </div>
    </aside>
  );
}

import React from 'react';
import {
  LayoutDashboard,
  Clock,
  ClipboardList,
  Package,
  BarChart3
} from 'lucide-react';
import { cn } from '../../lib/utils';

interface NavItem {
  icon: React.ElementType;
  label: string;
  page: string;
}

const navItems: NavItem[] = [
  { icon: LayoutDashboard, label: 'Dashboard', page: 'dashboard' },
  { icon: Clock, label: 'Schichten', page: 'shifts' },
  { icon: ClipboardList, label: 'Aufgaben', page: 'tasks' },
  { icon: Package, label: 'Inventar', page: 'inventory' },
  { icon: BarChart3, label: 'Statistik', page: 'analytics' },
];

interface MobileNavProps {
  currentPage: string;
  onNavigate: (page: string) => void;
}

export const MobileNav: React.FC<MobileNavProps> = ({ currentPage, onNavigate }) => {
  return (
    <nav className="fixed bottom-0 left-0 right-0 bg-gray-900 border-t border-gray-800 z-50 md:hidden">
      <div className="flex justify-around items-center h-16 px-2">
        {navItems.map((item) => {
          const Icon = item.icon;
          const isActive = currentPage === item.page;

          return (
            <button
              key={item.page}
              onClick={() => onNavigate(item.page)}
              className={cn(
                'flex flex-col items-center justify-center flex-1 h-full py-2 transition-colors relative',
                isActive
                  ? 'text-purple-400'
                  : 'text-gray-400 hover:text-gray-200'
              )}
            >
              <Icon className={cn('w-5 h-5', isActive && 'scale-110')} />
              <span className="text-xs mt-1 truncate max-w-[60px]">{item.label}</span>
              {isActive && (
                <div className="absolute bottom-0 w-12 h-0.5 bg-purple-400 rounded-full" />
              )}
            </button>
          );
        })}
      </div>

      {/* Safe area for iPhone */}
      <div className="h-[env(safe-area-inset-bottom)] bg-gray-900" />
    </nav>
  );
};

export default MobileNav;

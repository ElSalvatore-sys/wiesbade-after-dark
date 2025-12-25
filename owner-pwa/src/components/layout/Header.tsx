import { useState } from 'react';
import { cn } from '../../lib/utils';
import { ChevronDown, User, Settings, LogOut, Menu } from 'lucide-react';
import { NotificationBell } from '../NotificationBell';
import { LiveIndicator, LiveDot } from '../ui/LiveIndicator';
import { useRealtimeStatus } from '../../hooks/useRealtimeStatus';
import type { Notification } from '../../types';

interface HeaderProps {
  venueName: string;
  userName: string;
  userAvatar?: string;
  notifications: Notification[];
  onMarkAsRead: (id: string) => void;
  onMarkAllAsRead: () => void;
  onClearNotifications: () => void;
  onLogout: () => void;
  onMenuClick: () => void;
  onNavigate?: (page: string) => void;
  isSidebarCollapsed: boolean;
}

export function Header({
  venueName,
  userName,
  userAvatar,
  notifications,
  onMarkAsRead,
  onMarkAllAsRead,
  onClearNotifications,
  onLogout,
  onMenuClick,
  onNavigate,
  isSidebarCollapsed,
}: HeaderProps) {
  const [showUserMenu, setShowUserMenu] = useState(false);
  const { isConnected, lastUpdate } = useRealtimeStatus();

  const handleProfileClick = () => {
    setShowUserMenu(false);
    if (onNavigate) {
      onNavigate('settings'); // Navigate to settings for profile
    }
  };

  const handleSettingsClick = () => {
    setShowUserMenu(false);
    if (onNavigate) {
      onNavigate('settings');
    }
  };

  const handleLogoutClick = () => {
    setShowUserMenu(false);
    onLogout();
  };

  return (
    <header
      className={cn(
        'fixed top-0 right-0 z-30 h-16',
        'bg-background/80 backdrop-blur-xl border-b border-white/5',
        'flex items-center justify-between px-4 md:px-6 transition-all duration-300',
        isSidebarCollapsed ? 'left-[72px]' : 'left-[240px]',
        'max-md:left-0'
      )}
    >
      {/* Left */}
      <div className="flex items-center gap-4">
        <button
          onClick={onMenuClick}
          className="md:hidden p-2 rounded-xl text-foreground-secondary hover:text-foreground hover:bg-white/5 transition-colors"
        >
          <Menu size={24} />
        </button>

        <div>
          <h2 className="text-lg font-semibold text-foreground">{venueName}</h2>
          <p className="text-xs text-foreground-muted">
            Welcome back, {userName}
          </p>
        </div>

        {/* Live Indicator - Desktop */}
        <LiveIndicator
          isConnected={isConnected}
          lastUpdate={lastUpdate}
          showLabel={true}
          className="hidden sm:flex"
        />

        {/* Live Dot - Mobile */}
        <div className="sm:hidden">
          <LiveDot isConnected={isConnected} />
        </div>
      </div>

      {/* Right */}
      <div className="flex items-center gap-2">
        {/* Notifications */}
        <NotificationBell
          notifications={notifications}
          onMarkAsRead={onMarkAsRead}
          onMarkAllAsRead={onMarkAllAsRead}
          onClearAll={onClearNotifications}
          onNavigate={onNavigate}
        />

        {/* User menu */}
        <div className="relative">
          <button
            onClick={() => setShowUserMenu(!showUserMenu)}
            className={cn(
              'flex items-center gap-2 p-1.5 pr-3 rounded-xl transition-all duration-200',
              'hover:bg-white/5',
              showUserMenu && 'bg-white/5'
            )}
          >
            {userAvatar ? (
              <img
                src={userAvatar}
                alt={userName}
                className="w-8 h-8 rounded-lg object-cover"
              />
            ) : (
              <div className="w-8 h-8 rounded-lg bg-gradient-primary flex items-center justify-center shadow-glow-sm">
                <span className="text-white text-sm font-semibold">
                  {userName.charAt(0).toUpperCase()}
                </span>
              </div>
            )}
            <ChevronDown
              size={16}
              className={cn(
                'text-foreground-muted transition-transform duration-200',
                showUserMenu && 'rotate-180'
              )}
            />
          </button>

          {showUserMenu && (
            <>
              <div
                className="fixed inset-0 z-40"
                onClick={() => setShowUserMenu(false)}
              />
              <div className="absolute right-0 top-full mt-2 w-48 glass-card overflow-hidden animate-slide-down z-50">
                <div className="px-4 py-3 border-b border-white/5">
                  <p className="text-sm font-medium text-foreground">{userName}</p>
                  <p className="text-xs text-foreground-muted">Owner</p>
                </div>
                <div className="py-1">
                  <button
                    onClick={handleProfileClick}
                    className="w-full flex items-center gap-3 px-4 py-2.5 text-sm text-foreground-secondary hover:text-foreground hover:bg-white/5 transition-all duration-200 active:scale-95"
                  >
                    <User size={16} />
                    Profile
                  </button>
                  <button
                    onClick={handleSettingsClick}
                    className="w-full flex items-center gap-3 px-4 py-2.5 text-sm text-foreground-secondary hover:text-foreground hover:bg-white/5 transition-all duration-200 active:scale-95"
                  >
                    <Settings size={16} />
                    Settings
                  </button>
                  <button
                    onClick={handleLogoutClick}
                    className="w-full flex items-center gap-3 px-4 py-2.5 text-sm text-error hover:bg-error/10 transition-all duration-200 active:scale-95"
                  >
                    <LogOut size={16} />
                    Logout
                  </button>
                </div>
              </div>
            </>
          )}
        </div>
      </div>
    </header>
  );
}

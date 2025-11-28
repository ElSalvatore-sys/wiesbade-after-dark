import { useState, useEffect } from 'react';
import { cn } from '../../lib/utils';
import { Sidebar } from './Sidebar';
import { Header } from './Header';
import type { Notification } from '../../types';
import { X } from 'lucide-react';

interface DashboardLayoutProps {
  children: React.ReactNode;
  currentPage: string;
  onNavigate: (page: string) => void;
  onLogout: () => void;
  venueName: string;
  userName: string;
  userAvatar?: string;
}

// Mock notifications with more variety
const initialNotifications: Notification[] = [
  {
    id: '1',
    type: 'booking',
    title: 'New Booking Request',
    message: 'Anna Schmidt requested a table for 4 at 20:00',
    isRead: false,
    createdAt: new Date(Date.now() - 5 * 60000).toISOString(), // 5 mins ago
  },
  {
    id: '2',
    type: 'inventory',
    title: 'Low Stock Alert',
    message: 'Grey Goose Vodka is running low (3 bottles remaining)',
    isRead: false,
    createdAt: new Date(Date.now() - 30 * 60000).toISOString(), // 30 mins ago
  },
  {
    id: '3',
    type: 'event',
    title: 'Event Starting Soon',
    message: 'DJ Night starts in 2 hours - 45 RSVPs confirmed',
    isRead: false,
    createdAt: new Date(Date.now() - 60 * 60000).toISOString(), // 1 hour ago
  },
  {
    id: '4',
    type: 'booking',
    title: 'Booking Confirmed',
    message: 'VIP reservation for Max Müller has been confirmed',
    isRead: true,
    createdAt: new Date(Date.now() - 2 * 60 * 60000).toISOString(), // 2 hours ago
  },
  {
    id: '5',
    type: 'system',
    title: 'Weekly Report Ready',
    message: 'Your venue performance report for this week is ready to view',
    isRead: true,
    createdAt: new Date(Date.now() - 24 * 60 * 60000).toISOString(), // 1 day ago
  },
];

export function DashboardLayout({
  children,
  currentPage,
  onNavigate,
  onLogout,
  venueName,
  userName,
  userAvatar,
}: DashboardLayoutProps) {
  const [isSidebarCollapsed, setIsSidebarCollapsed] = useState(false);
  const [isMobileSidebarOpen, setIsMobileSidebarOpen] = useState(false);
  const [notifications, setNotifications] = useState<Notification[]>(initialNotifications);

  // Close mobile sidebar on navigation
  useEffect(() => {
    setIsMobileSidebarOpen(false);
  }, [currentPage]);

  // Handle window resize
  useEffect(() => {
    const handleResize = () => {
      if (window.innerWidth >= 768) {
        setIsMobileSidebarOpen(false);
      }
    };
    window.addEventListener('resize', handleResize);
    return () => window.removeEventListener('resize', handleResize);
  }, []);

  // Notification handlers
  const handleMarkAsRead = (id: string) => {
    setNotifications((prev) =>
      prev.map((n) => (n.id === id ? { ...n, isRead: true } : n))
    );
  };

  const handleMarkAllAsRead = () => {
    setNotifications((prev) => prev.map((n) => ({ ...n, isRead: true })));
  };

  const handleClearNotifications = () => {
    setNotifications([]);
  };

  return (
    <div className="min-h-screen bg-background">
      {/* Desktop Sidebar */}
      <div className="hidden md:block">
        <Sidebar
          currentPage={currentPage}
          onNavigate={onNavigate}
          onLogout={onLogout}
          isCollapsed={isSidebarCollapsed}
          onToggleCollapse={() => setIsSidebarCollapsed(!isSidebarCollapsed)}
        />
      </div>

      {/* Mobile Sidebar Overlay */}
      {isMobileSidebarOpen && (
        <div className="md:hidden fixed inset-0 z-50">
          {/* Backdrop */}
          <div
            className="absolute inset-0 bg-black/60 backdrop-blur-sm"
            onClick={() => setIsMobileSidebarOpen(false)}
          />

          {/* Sidebar */}
          <div className="absolute left-0 top-0 h-full w-[280px] animate-slide-in-left">
            <Sidebar
              currentPage={currentPage}
              onNavigate={onNavigate}
              onLogout={onLogout}
              isCollapsed={false}
              onToggleCollapse={() => setIsMobileSidebarOpen(false)}
            />
          </div>

          {/* Close button */}
          <button
            onClick={() => setIsMobileSidebarOpen(false)}
            className="absolute top-4 right-4 p-2 rounded-full bg-background-card text-foreground"
          >
            <X size={24} />
          </button>
        </div>
      )}

      {/* Header */}
      <Header
        venueName={venueName}
        userName={userName}
        userAvatar={userAvatar}
        notifications={notifications}
        onMarkAsRead={handleMarkAsRead}
        onMarkAllAsRead={handleMarkAllAsRead}
        onClearNotifications={handleClearNotifications}
        onLogout={onLogout}
        onMenuClick={() => setIsMobileSidebarOpen(true)}
        isSidebarCollapsed={isSidebarCollapsed}
      />

      {/* Main Content */}
      <main
        className={cn(
          'pt-16 min-h-screen transition-all duration-standard',
          'md:pl-[240px]',
          isSidebarCollapsed && 'md:pl-[72px]'
        )}
      >
        <div className="p-4 md:p-6 lg:p-8">{children}</div>
      </main>
    </div>
  );
}

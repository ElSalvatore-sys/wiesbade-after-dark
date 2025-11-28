import { useState, useEffect } from 'react';
import { cn } from '../lib/utils';
import { Bell, CheckCheck, Calendar, Package, Sparkles, X } from 'lucide-react';
import {
  isNotificationSupported,
  getNotificationPermission,
  requestNotificationPermission,
  showNotification,
  NotificationTemplates,
} from '../services/notifications';
import type { Notification as AppNotification } from '../types';

type NotificationType = 'booking' | 'low_stock' | 'event' | 'system';

interface NotificationBellProps {
  notifications: AppNotification[];
  onMarkAsRead: (id: string) => void;
  onMarkAllAsRead: () => void;
  onClearAll: () => void;
}

const notificationIcons: Record<NotificationType, typeof Bell> = {
  booking: Calendar,
  low_stock: Package,
  event: Sparkles,
  system: Bell,
};

const notificationColors: Record<NotificationType, string> = {
  booking: 'text-accent-purple bg-accent-purple/20',
  low_stock: 'text-warning bg-warning/20',
  event: 'text-accent-pink bg-accent-pink/20',
  system: 'text-foreground-secondary bg-white/10',
};

export function NotificationBell({
  notifications,
  onMarkAsRead,
  onMarkAllAsRead,
  onClearAll,
}: NotificationBellProps) {
  const [isOpen, setIsOpen] = useState(false);
  const [permissionStatus, setPermissionStatus] = useState<NotificationPermission | 'unsupported'>('default');
  const [showPermissionPrompt, setShowPermissionPrompt] = useState(false);

  const unreadCount = notifications.filter((n) => !n.isRead).length;

  useEffect(() => {
    // Check notification permission on mount
    const status = getNotificationPermission();
    setPermissionStatus(status);

    // Show prompt if permission hasn't been requested yet
    if (status === 'default' && isNotificationSupported()) {
      setShowPermissionPrompt(true);
    }
  }, []);

  const handleRequestPermission = async () => {
    const permission = await requestNotificationPermission();
    setPermissionStatus(permission);
    setShowPermissionPrompt(false);

    if (permission === 'granted') {
      // Show a test notification
      showNotification(
        'Notifications Enabled',
        'You will now receive updates about bookings, events, and inventory.',
        { type: 'system' }
      );
    }
  };

  const handleDismissPrompt = () => {
    setShowPermissionPrompt(false);
  };

  const handleNotificationClick = (notification: AppNotification) => {
    if (!notification.isRead) {
      onMarkAsRead(notification.id);
    }
    // Here you could also navigate to the relevant page based on notification type
  };

  const getNotificationType = (notification: AppNotification): NotificationType => {
    const title = notification.title.toLowerCase();
    if (title.includes('booking') || title.includes('reservation')) return 'booking';
    if (title.includes('stock') || title.includes('inventory')) return 'low_stock';
    if (title.includes('event')) return 'event';
    return 'system';
  };

  const formatTime = (dateStr: string) => {
    const date = new Date(dateStr);
    const now = new Date();
    const diffMs = now.getTime() - date.getTime();
    const diffMins = Math.floor(diffMs / 60000);
    const diffHours = Math.floor(diffMins / 60);
    const diffDays = Math.floor(diffHours / 24);

    if (diffMins < 1) return 'Just now';
    if (diffMins < 60) return `${diffMins}m ago`;
    if (diffHours < 24) return `${diffHours}h ago`;
    if (diffDays < 7) return `${diffDays}d ago`;
    return date.toLocaleDateString('de-DE', { day: 'numeric', month: 'short' });
  };

  // Demo function to test notifications
  const sendTestNotification = () => {
    const template = NotificationTemplates.newBooking('Max Müller', '20:00', 4);
    showNotification(template.title, template.body, template.options);
  };

  return (
    <div className="relative">
      {/* Bell Button */}
      <button
        onClick={() => setIsOpen(!isOpen)}
        className={cn(
          'relative p-2.5 rounded-xl transition-all duration-200',
          'text-foreground-secondary hover:text-foreground hover:bg-white/5',
          isOpen && 'bg-white/5 text-foreground'
        )}
      >
        <Bell size={20} />
        {unreadCount > 0 && (
          <span className="absolute top-1.5 right-1.5 w-4 h-4 bg-gradient-primary text-white text-[10px] font-bold rounded-full flex items-center justify-center shadow-glow-sm animate-pulse">
            {unreadCount > 9 ? '9+' : unreadCount}
          </span>
        )}
      </button>

      {/* Permission Prompt Banner */}
      {showPermissionPrompt && isOpen && (
        <div className="absolute right-0 top-full mt-2 w-80 glass-card p-4 animate-fade-in z-50">
          <div className="flex items-start gap-3">
            <div className="p-2 rounded-lg bg-gradient-primary/20 text-primary-400">
              <Bell size={20} />
            </div>
            <div className="flex-1">
              <p className="text-sm font-medium text-foreground">Enable Notifications</p>
              <p className="text-xs text-foreground-muted mt-1">
                Get instant updates about new bookings, low stock alerts, and upcoming events.
              </p>
              <div className="flex gap-2 mt-3">
                <button
                  onClick={handleRequestPermission}
                  className="px-3 py-1.5 text-xs font-medium rounded-lg bg-gradient-primary text-white"
                >
                  Enable
                </button>
                <button
                  onClick={handleDismissPrompt}
                  className="px-3 py-1.5 text-xs font-medium rounded-lg text-foreground-muted hover:text-foreground"
                >
                  Not now
                </button>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Notifications Dropdown */}
      {isOpen && !showPermissionPrompt && (
        <>
          <div
            className="fixed inset-0 z-40"
            onClick={() => setIsOpen(false)}
          />
          <div className="absolute right-0 top-full mt-2 w-80 sm:w-96 glass-card overflow-hidden animate-fade-in z-50">
            {/* Header */}
            <div className="px-4 py-3 border-b border-white/5 flex items-center justify-between">
              <h3 className="font-semibold text-foreground">Notifications</h3>
              <div className="flex items-center gap-2">
                {unreadCount > 0 && (
                  <button
                    onClick={onMarkAllAsRead}
                    className="text-xs text-foreground-muted hover:text-foreground flex items-center gap-1"
                  >
                    <CheckCheck size={14} />
                    Mark all read
                  </button>
                )}
                {notifications.length > 0 && (
                  <button
                    onClick={onClearAll}
                    className="text-xs text-foreground-muted hover:text-error flex items-center gap-1"
                  >
                    <X size={14} />
                    Clear
                  </button>
                )}
              </div>
            </div>

            {/* Permission status indicator */}
            {permissionStatus !== 'granted' && permissionStatus !== 'unsupported' && (
              <div className="px-4 py-2 bg-warning/10 border-b border-warning/20">
                <button
                  onClick={handleRequestPermission}
                  className="text-xs text-warning hover:underline"
                >
                  Enable push notifications for real-time updates
                </button>
              </div>
            )}

            {/* Notifications List */}
            <div className="max-h-96 overflow-y-auto no-scrollbar">
              {notifications.length === 0 ? (
                <div className="px-4 py-12 text-center">
                  <Bell size={32} className="mx-auto text-foreground-dim mb-3" />
                  <p className="text-sm text-foreground-muted">No notifications yet</p>
                  <p className="text-xs text-foreground-dim mt-1">
                    You'll see booking requests, alerts, and updates here
                  </p>
                </div>
              ) : (
                notifications.map((notification) => {
                  const type = getNotificationType(notification);
                  const Icon = notificationIcons[type];
                  const colorClass = notificationColors[type];

                  return (
                    <div
                      key={notification.id}
                      onClick={() => handleNotificationClick(notification)}
                      className={cn(
                        'px-4 py-3 border-b border-white/5 last:border-b-0',
                        'hover:bg-white/5 cursor-pointer transition-colors',
                        'flex items-start gap-3',
                        !notification.isRead && 'bg-primary-500/5'
                      )}
                    >
                      <div className={cn('p-2 rounded-lg shrink-0', colorClass)}>
                        <Icon size={16} />
                      </div>
                      <div className="flex-1 min-w-0">
                        <div className="flex items-start justify-between gap-2">
                          <p className={cn(
                            'text-sm',
                            notification.isRead ? 'text-foreground-secondary' : 'text-foreground font-medium'
                          )}>
                            {notification.title}
                          </p>
                          {!notification.isRead && (
                            <span className="w-2 h-2 rounded-full bg-primary-500 shrink-0 mt-1.5" />
                          )}
                        </div>
                        <p className="text-xs text-foreground-muted mt-0.5 line-clamp-2">
                          {notification.message}
                        </p>
                        <p className="text-xs text-foreground-dim mt-1">
                          {formatTime(notification.createdAt)}
                        </p>
                      </div>
                    </div>
                  );
                })
              )}
            </div>

            {/* Footer with test button (dev only) */}
            {import.meta.env.DEV && permissionStatus === 'granted' && (
              <div className="px-4 py-2 border-t border-white/5">
                <button
                  onClick={sendTestNotification}
                  className="text-xs text-foreground-dim hover:text-foreground"
                >
                  Send test notification
                </button>
              </div>
            )}
          </div>
        </>
      )}
    </div>
  );
}

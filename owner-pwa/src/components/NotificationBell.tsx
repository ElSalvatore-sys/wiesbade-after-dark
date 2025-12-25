import { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
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

type NotificationType = 'booking' | 'inventory' | 'event' | 'system';

interface NotificationBellProps {
  notifications: AppNotification[];
  onMarkAsRead: (id: string) => void;
  onMarkAllAsRead: () => void;
  onClearAll: () => void;
  onNavigate?: (page: string) => void;
}

const notificationIcons: Record<NotificationType, typeof Bell> = {
  booking: Calendar,
  inventory: Package,
  event: Sparkles,
  system: Bell,
};

const notificationColors: Record<NotificationType, string> = {
  booking: 'text-accent-purple bg-accent-purple/20',
  inventory: 'text-warning bg-warning/20',
  event: 'text-accent-pink bg-accent-pink/20',
  system: 'text-blue-400 bg-blue-400/20',
};

// Navigation mapping based on notification type
const notificationRoutes: Record<NotificationType, string> = {
  booking: 'bookings',
  inventory: 'inventory',
  event: 'events',
  system: 'dashboard',
};

export function NotificationBell({
  notifications,
  onMarkAsRead,
  onMarkAllAsRead,
  onClearAll,
  onNavigate,
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

    // Navigate to relevant page based on notification type
    const type = getNotificationType(notification);
    const route = notificationRoutes[type];

    if (onNavigate && route) {
      onNavigate(route);
    }

    // Close the notification popup
    setIsOpen(false);
  };

  const getNotificationType = (notification: AppNotification): NotificationType => {
    // Use the notification type from the data if available
    if (notification.type === 'booking' || notification.type === 'inventory' || notification.type === 'event') {
      return notification.type as NotificationType;
    }

    // Fallback to title parsing
    const title = notification.title.toLowerCase();
    const message = notification.message.toLowerCase();
    const combined = `${title} ${message}`;

    if (combined.includes('booking') || combined.includes('reservation') || combined.includes('tisch')) return 'booking';
    if (combined.includes('stock') || combined.includes('inventory') || combined.includes('inventar') || combined.includes('bestand')) return 'inventory';
    if (combined.includes('event') || combined.includes('veranstaltung')) return 'event';
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
      <AnimatePresence>
        {showPermissionPrompt && isOpen && (
          <motion.div
            initial={{ opacity: 0, y: -10 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -10 }}
            transition={{ duration: 0.2 }}
            className="absolute right-0 top-full mt-2 w-80 bg-gray-900 border border-gray-800 rounded-xl p-4 shadow-2xl z-50"
          >
            <div className="flex items-start gap-3">
              <div className="p-2 rounded-lg bg-gradient-primary/20 text-primary-400">
                <Bell size={20} />
              </div>
              <div className="flex-1">
                <p className="text-sm font-medium text-white">Enable Notifications</p>
                <p className="text-xs text-gray-400 mt-1">
                  Get instant updates about new bookings, low stock alerts, and upcoming events.
                </p>
                <div className="flex gap-2 mt-3">
                  <button
                    onClick={handleRequestPermission}
                    className="px-3 py-1.5 text-xs font-medium rounded-lg bg-gradient-primary text-white hover:shadow-lg transition-shadow"
                  >
                    Enable
                  </button>
                  <button
                    onClick={handleDismissPrompt}
                    className="px-3 py-1.5 text-xs font-medium rounded-lg text-gray-400 hover:text-white transition-colors"
                  >
                    Not now
                  </button>
                </div>
              </div>
            </div>
          </motion.div>
        )}
      </AnimatePresence>

      {/* Notifications Dropdown */}
      <AnimatePresence>
        {isOpen && !showPermissionPrompt && (
          <>
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              transition={{ duration: 0.15 }}
              className="fixed inset-0 z-40"
              onClick={() => setIsOpen(false)}
            />
            <motion.div
              initial={{ opacity: 0, y: -10, scale: 0.95 }}
              animate={{ opacity: 1, y: 0, scale: 1 }}
              exit={{ opacity: 0, y: -10, scale: 0.95 }}
              transition={{ duration: 0.2, ease: 'easeOut' }}
              className="absolute right-0 top-full mt-2 w-80 sm:w-96 bg-gray-900 border border-gray-800 rounded-xl overflow-hidden shadow-2xl z-50"
            >
              {/* Header */}
              <div className="px-4 py-3 border-b border-gray-800 flex items-center justify-between bg-gray-900/95 backdrop-blur-sm">
                <h3 className="font-semibold text-white">Notifications</h3>
                <div className="flex items-center gap-2">
                  {unreadCount > 0 && (
                    <button
                      onClick={onMarkAllAsRead}
                      className="text-xs text-gray-400 hover:text-white flex items-center gap-1 transition-colors"
                    >
                      <CheckCheck size={14} />
                      Mark all read
                    </button>
                  )}
                  {notifications.length > 0 && (
                    <button
                      onClick={onClearAll}
                      className="text-xs text-gray-400 hover:text-red-400 flex items-center gap-1 transition-colors"
                    >
                      <X size={14} />
                      Clear
                    </button>
                  )}
                </div>
              </div>

              {/* Permission status indicator */}
              {permissionStatus !== 'granted' && permissionStatus !== 'unsupported' && (
                <div className="px-4 py-2 bg-orange-500/10 border-b border-orange-500/20">
                  <button
                    onClick={handleRequestPermission}
                    className="text-xs text-orange-400 hover:text-orange-300 hover:underline transition-colors"
                  >
                    Enable push notifications for real-time updates
                  </button>
                </div>
              )}

              {/* Notifications List */}
              <div className="max-h-96 overflow-y-auto no-scrollbar bg-gray-900">
                {notifications.length === 0 ? (
                  <div className="px-4 py-12 text-center">
                    <Bell size={32} className="mx-auto text-gray-600 mb-3" />
                    <p className="text-sm text-gray-400">No notifications yet</p>
                    <p className="text-xs text-gray-500 mt-1">
                      You'll see booking requests, alerts, and updates here
                    </p>
                  </div>
                ) : (
                  notifications.map((notification, index) => {
                    const type = getNotificationType(notification);
                    const Icon = notificationIcons[type];
                    const colorClass = notificationColors[type];

                    return (
                      <motion.div
                        key={notification.id}
                        initial={{ opacity: 0, x: -20 }}
                        animate={{ opacity: 1, x: 0 }}
                        transition={{ delay: index * 0.05, duration: 0.2 }}
                        onClick={() => handleNotificationClick(notification)}
                        className={cn(
                          'px-4 py-3 border-b border-gray-800 last:border-b-0',
                          'hover:bg-gray-800/50 active:bg-gray-800 cursor-pointer transition-all',
                          'flex items-start gap-3 group',
                          !notification.isRead && 'bg-purple-500/5 hover:bg-purple-500/10'
                        )}
                      >
                        <div className={cn('p-2 rounded-lg shrink-0 transition-transform group-hover:scale-110', colorClass)}>
                          <Icon size={16} />
                        </div>
                        <div className="flex-1 min-w-0">
                          <div className="flex items-start justify-between gap-2">
                            <p className={cn(
                              'text-sm',
                              notification.isRead ? 'text-gray-400' : 'text-white font-medium'
                            )}>
                              {notification.title}
                            </p>
                            {!notification.isRead && (
                              <motion.span
                                initial={{ scale: 0 }}
                                animate={{ scale: 1 }}
                                className="w-2 h-2 rounded-full bg-purple-500 shrink-0 mt-1.5"
                              />
                            )}
                          </div>
                          <p className="text-xs text-gray-400 mt-0.5 line-clamp-2">
                            {notification.message}
                          </p>
                          <p className="text-xs text-gray-500 mt-1">
                            {formatTime(notification.createdAt)}
                          </p>
                        </div>
                      </motion.div>
                    );
                  })
                )}
              </div>

              {/* Footer with test button (dev only) */}
              {import.meta.env.DEV && permissionStatus === 'granted' && (
                <div className="px-4 py-2 border-t border-gray-800 bg-gray-900/80">
                  <button
                    onClick={sendTestNotification}
                    className="text-xs text-gray-500 hover:text-gray-300 transition-colors"
                  >
                    Send test notification
                  </button>
                </div>
              )}
            </motion.div>
          </>
        )}
      </AnimatePresence>
    </div>
  );
}

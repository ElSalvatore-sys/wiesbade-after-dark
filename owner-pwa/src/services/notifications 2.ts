// Push Notification Service

export type NotificationType = 'booking' | 'low_stock' | 'event' | 'system' | 'shift' | 'task';

export interface NotificationOptions {
  type?: NotificationType;
  icon?: string;
  badge?: string;
  tag?: string;
  requireInteraction?: boolean;
  actions?: NotificationAction[];
  data?: Record<string, unknown>;
}

interface NotificationAction {
  action: string;
  title: string;
  icon?: string;
}

// Check if notifications are supported
export function isNotificationSupported(): boolean {
  return 'Notification' in window;
}

// Check if service worker is supported
export function isServiceWorkerSupported(): boolean {
  return 'serviceWorker' in navigator;
}

// Get current notification permission status
export function getNotificationPermission(): NotificationPermission | 'unsupported' {
  if (!isNotificationSupported()) {
    return 'unsupported';
  }
  return Notification.permission;
}

// Request notification permission
export async function requestNotificationPermission(): Promise<NotificationPermission | 'unsupported'> {
  if (!isNotificationSupported()) {
    console.warn('Notifications are not supported in this browser');
    return 'unsupported';
  }

  // If already granted or denied, return current status
  if (Notification.permission !== 'default') {
    return Notification.permission;
  }

  try {
    const permission = await Notification.requestPermission();
    return permission;
  } catch (error) {
    console.error('Error requesting notification permission:', error);
    return 'denied';
  }
}

// Show a browser notification
export async function showNotification(
  title: string,
  body: string,
  options: NotificationOptions = {}
): Promise<Notification | null> {
  if (!isNotificationSupported()) {
    console.warn('Notifications are not supported');
    return null;
  }

  if (Notification.permission !== 'granted') {
    console.warn('Notification permission not granted');
    return null;
  }

  const defaultIcon = '/icon-192.png';
  const defaultBadge = '/icon-192.png';

  try {
    // Try to use service worker notification (more reliable on mobile)
    if (isServiceWorkerSupported() && navigator.serviceWorker.controller) {
      const registration = await navigator.serviceWorker.ready;
      await registration.showNotification(title, {
        body,
        icon: options.icon || defaultIcon,
        badge: options.badge || defaultBadge,
        tag: options.tag,
        requireInteraction: options.requireInteraction,
        data: options.data,
      });
      return null; // Service worker notifications don't return Notification object
    }

    // Fallback to regular notification
    const notification = new Notification(title, {
      body,
      icon: options.icon || defaultIcon,
      badge: options.badge || defaultBadge,
      tag: options.tag,
      requireInteraction: options.requireInteraction,
    });

    // Auto-close after 5 seconds unless requireInteraction is true
    if (!options.requireInteraction) {
      setTimeout(() => notification.close(), 5000);
    }

    return notification;
  } catch (error) {
    console.error('Error showing notification:', error);
    return null;
  }
}

// Notification templates for common scenarios
export const NotificationTemplates = {
  newBooking: (guestName: string, time: string, partySize: number) => ({
    title: 'New Booking Request',
    body: `${guestName} requested a table for ${partySize} at ${time}`,
    options: {
      type: 'booking' as NotificationType,
      tag: 'booking-new',
      requireInteraction: true,
    },
  }),

  bookingConfirmed: (guestName: string, time: string) => ({
    title: 'Booking Confirmed',
    body: `Reservation for ${guestName} at ${time} has been confirmed`,
    options: {
      type: 'booking' as NotificationType,
      tag: 'booking-confirmed',
    },
  }),

  lowStock: (itemName: string, currentStock: number, minStock: number) => ({
    title: 'Low Stock Alert',
    body: `${itemName} is running low: ${currentStock}/${minStock} remaining`,
    options: {
      type: 'low_stock' as NotificationType,
      tag: 'stock-low',
      requireInteraction: true,
    },
  }),

  eventStartingSoon: (eventName: string, timeUntil: string) => ({
    title: 'Event Starting Soon',
    body: `${eventName} starts in ${timeUntil}`,
    options: {
      type: 'event' as NotificationType,
      tag: 'event-starting',
    },
  }),

  eventSoldOut: (eventName: string) => ({
    title: 'Event Sold Out!',
    body: `${eventName} has reached maximum capacity`,
    options: {
      type: 'event' as NotificationType,
      tag: 'event-soldout',
    },
  }),

  // ============ SHIFT NOTIFICATIONS ============

  shiftClockIn: (employeeName: string, time: string) => ({
    title: 'Employee Clocked In',
    body: `${employeeName} started their shift at ${time}`,
    options: {
      type: 'shift' as NotificationType,
      tag: 'shift-clockin',
    },
  }),

  shiftClockOut: (employeeName: string, hoursWorked: string) => ({
    title: 'Employee Clocked Out',
    body: `${employeeName} finished their shift (${hoursWorked} hours)`,
    options: {
      type: 'shift' as NotificationType,
      tag: 'shift-clockout',
    },
  }),

  shiftOvertimeWarning: (employeeName: string, minutesOver: number) => ({
    title: '⚠️ Overtime Alert',
    body: `${employeeName} is ${minutesOver} minutes over their scheduled shift`,
    options: {
      type: 'shift' as NotificationType,
      tag: 'shift-overtime',
      requireInteraction: true,
    },
  }),

  shiftBreakReminder: (employeeName: string, hoursWithoutBreak: number) => ({
    title: 'Break Reminder',
    body: `${employeeName} has been working for ${hoursWithoutBreak}h without a break`,
    options: {
      type: 'shift' as NotificationType,
      tag: 'shift-break',
    },
  }),

  // ============ TASK NOTIFICATIONS ============

  taskAssigned: (taskTitle: string, employeeName: string) => ({
    title: 'New Task Assigned',
    body: `"${taskTitle}" has been assigned to ${employeeName}`,
    options: {
      type: 'task' as NotificationType,
      tag: 'task-assigned',
    },
  }),

  taskStarted: (taskTitle: string, employeeName: string) => ({
    title: 'Task Started',
    body: `${employeeName} started working on "${taskTitle}"`,
    options: {
      type: 'task' as NotificationType,
      tag: 'task-started',
    },
  }),

  taskCompleted: (taskTitle: string, employeeName: string) => ({
    title: '✅ Task Completed',
    body: `${employeeName} completed "${taskTitle}" - awaiting approval`,
    options: {
      type: 'task' as NotificationType,
      tag: 'task-completed',
      requireInteraction: true,
    },
  }),

  taskApproved: (taskTitle: string) => ({
    title: 'Task Approved',
    body: `"${taskTitle}" has been approved`,
    options: {
      type: 'task' as NotificationType,
      tag: 'task-approved',
    },
  }),

  taskRejected: (taskTitle: string, reason: string) => ({
    title: '❌ Task Rejected',
    body: `"${taskTitle}" was rejected: ${reason}`,
    options: {
      type: 'task' as NotificationType,
      tag: 'task-rejected',
      requireInteraction: true,
    },
  }),

  taskOverdue: (taskTitle: string, employeeName: string) => ({
    title: '⏰ Task Overdue',
    body: `"${taskTitle}" assigned to ${employeeName} is past due`,
    options: {
      type: 'task' as NotificationType,
      tag: 'task-overdue',
      requireInteraction: true,
    },
  }),
};

// Register service worker
export async function registerServiceWorker(): Promise<ServiceWorkerRegistration | null> {
  if (!isServiceWorkerSupported()) {
    console.warn('Service workers are not supported');
    return null;
  }

  try {
    const registration = await navigator.serviceWorker.register('/sw.js', {
      scope: '/',
    });
    console.log('Service Worker registered:', registration.scope);
    return registration;
  } catch (error) {
    console.error('Service Worker registration failed:', error);
    return null;
  }
}

// Unregister all service workers
export async function unregisterServiceWorkers(): Promise<boolean> {
  if (!isServiceWorkerSupported()) {
    return false;
  }

  try {
    const registrations = await navigator.serviceWorker.getRegistrations();
    for (const registration of registrations) {
      await registration.unregister();
    }
    return true;
  } catch (error) {
    console.error('Error unregistering service workers:', error);
    return false;
  }
}

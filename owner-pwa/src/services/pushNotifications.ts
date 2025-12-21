// Enhanced Push Notification Service with Supabase Realtime
// Real-time alerts for shifts, tasks, inventory, and bookings

import { supabase } from '../lib/supabase';

// VAPID public key - Generate at https://vapidkeys.com/ for production
const VAPID_PUBLIC_KEY = import.meta.env.VITE_VAPID_PUBLIC_KEY || '';

export interface PushNotification {
  title: string;
  body: string;
  icon?: string;
  badge?: string;
  tag?: string;
  data?: Record<string, unknown>;
  actions?: { action: string; title: string; icon?: string }[];
  requireInteraction?: boolean;
}

class PushNotificationService {
  private subscription: PushSubscription | null = null;
  private realtimeCleanup: (() => void) | null = null;

  // Check if push notifications are supported
  get supported(): boolean {
    return 'serviceWorker' in navigator && 'PushManager' in window && 'Notification' in window;
  }

  // Get current permission status
  get permission(): NotificationPermission {
    if (!('Notification' in window)) return 'denied';
    return Notification.permission;
  }

  // Request notification permission
  async requestPermission(): Promise<boolean> {
    if (!this.supported) {
      console.warn('Push notifications not supported');
      return false;
    }

    try {
      const permission = await Notification.requestPermission();
      return permission === 'granted';
    } catch (error) {
      console.error('Error requesting permission:', error);
      return false;
    }
  }

  // Subscribe to push notifications
  async subscribe(): Promise<PushSubscription | null> {
    if (!this.supported || Notification.permission !== 'granted') {
      return null;
    }

    try {
      const registration = await navigator.serviceWorker.ready;

      // Check for existing subscription
      let subscription = await registration.pushManager.getSubscription();

      if (!subscription && VAPID_PUBLIC_KEY) {
        // Create new subscription
        const vapidKey = this.urlBase64ToUint8Array(VAPID_PUBLIC_KEY);
        subscription = await registration.pushManager.subscribe({
          userVisibleOnly: true,
          applicationServerKey: vapidKey.buffer as ArrayBuffer,
        });
      }

      this.subscription = subscription;

      // Save subscription to Supabase
      if (subscription) {
        await this.saveSubscription(subscription);
      }

      return subscription;
    } catch (error) {
      console.error('Error subscribing to push:', error);
      return null;
    }
  }

  // Unsubscribe from push notifications
  async unsubscribe(): Promise<boolean> {
    try {
      if (this.subscription) {
        await this.subscription.unsubscribe();
        await this.removeSubscription();
        this.subscription = null;
      }
      return true;
    } catch (error) {
      console.error('Error unsubscribing:', error);
      return false;
    }
  }

  // Show local notification (no server needed)
  async showLocalNotification(notification: PushNotification): Promise<void> {
    if (Notification.permission !== 'granted') {
      console.warn('Notification permission not granted');
      return;
    }

    try {
      const registration = await navigator.serviceWorker.ready;
      // Use extended options with vibrate (supported in service worker context)
      const options: NotificationOptions & { vibrate?: number[] } = {
        body: notification.body,
        icon: notification.icon || '/icon-192.png',
        badge: notification.badge || '/icon-192.png',
        tag: notification.tag || 'default',
        data: notification.data,
        vibrate: [200, 100, 200],
        requireInteraction: notification.requireInteraction || false,
      };
      await registration.showNotification(notification.title, options);
    } catch (error) {
      // Fallback to regular Notification API
      new Notification(notification.title, {
        body: notification.body,
        icon: notification.icon || '/icon-192.png',
        tag: notification.tag,
      });
    }
  }

  // Save subscription to Supabase
  private async saveSubscription(subscription: PushSubscription): Promise<void> {
    const userId = localStorage.getItem('user')
      ? JSON.parse(localStorage.getItem('user')!).id
      : null;
    if (!userId) return;

    const subscriptionData = subscription.toJSON();

    try {
      await supabase.from('push_subscriptions').upsert({
        user_id: userId,
        endpoint: subscriptionData.endpoint,
        p256dh: subscriptionData.keys?.p256dh,
        auth: subscriptionData.keys?.auth,
        updated_at: new Date().toISOString(),
      }, {
        onConflict: 'user_id',
      });
    } catch (error) {
      console.error('Error saving subscription:', error);
    }
  }

  // Remove subscription from Supabase
  private async removeSubscription(): Promise<void> {
    const userId = localStorage.getItem('user')
      ? JSON.parse(localStorage.getItem('user')!).id
      : null;
    if (!userId) return;

    try {
      await supabase.from('push_subscriptions').delete().eq('user_id', userId);
    } catch (error) {
      console.error('Error removing subscription:', error);
    }
  }

  // Convert VAPID key to Uint8Array
  private urlBase64ToUint8Array(base64String: string): Uint8Array {
    const padding = '='.repeat((4 - (base64String.length % 4)) % 4);
    const base64 = (base64String + padding).replace(/-/g, '+').replace(/_/g, '/');
    const rawData = window.atob(base64);
    const outputArray = new Uint8Array(rawData.length);
    for (let i = 0; i < rawData.length; ++i) {
      outputArray[i] = rawData.charCodeAt(i);
    }
    return outputArray;
  }

  // Setup realtime notifications
  setupRealtime(venueId: string, userRole: string): void {
    if (this.realtimeCleanup) {
      this.realtimeCleanup();
    }
    this.realtimeCleanup = setupRealtimeNotifications(venueId, userRole, this);
  }

  // Cleanup realtime subscriptions
  cleanupRealtime(): void {
    if (this.realtimeCleanup) {
      this.realtimeCleanup();
      this.realtimeCleanup = null;
    }
  }
}

export const pushNotificationService = new PushNotificationService();

// =============================================
// NOTIFICATION TRIGGERS (German)
// =============================================

export const NotificationTriggers = {
  // Task notifications
  taskAssigned: (taskTitle: string) => ({
    title: '📋 Neue Aufgabe',
    body: `"${taskTitle}" wurde dir zugewiesen`,
    tag: 'task-assigned',
    data: { type: 'task', action: 'assigned' },
  }),

  taskCompleted: (employeeName: string, taskTitle: string) => ({
    title: '✅ Aufgabe erledigt',
    body: `${employeeName} hat "${taskTitle}" abgeschlossen`,
    tag: 'task-completed',
    data: { type: 'task', action: 'completed' },
    requireInteraction: true,
  }),

  taskNeedsApproval: (taskTitle: string) => ({
    title: '🔔 Genehmigung erforderlich',
    body: `"${taskTitle}" wartet auf Genehmigung`,
    tag: 'task-approval',
    data: { type: 'task', action: 'needs-approval' },
    requireInteraction: true,
  }),

  taskApproved: (taskTitle: string) => ({
    title: '✓ Aufgabe genehmigt',
    body: `"${taskTitle}" wurde genehmigt`,
    tag: 'task-approved',
    data: { type: 'task', action: 'approved' },
  }),

  taskRejected: (taskTitle: string, reason: string) => ({
    title: '✗ Aufgabe abgelehnt',
    body: `"${taskTitle}": ${reason}`,
    tag: 'task-rejected',
    data: { type: 'task', action: 'rejected' },
    requireInteraction: true,
  }),

  // Shift notifications
  shiftClockIn: (employeeName: string) => ({
    title: '👋 Schichtbeginn',
    body: `${employeeName} hat eingecheckt`,
    tag: 'shift-clockin',
    data: { type: 'shift', action: 'clock-in' },
  }),

  shiftClockOut: (employeeName: string, hoursWorked: string) => ({
    title: '👋 Schichtende',
    body: `${employeeName} hat ausgecheckt (${hoursWorked}h)`,
    tag: 'shift-clockout',
    data: { type: 'shift', action: 'clock-out' },
  }),

  overtimeWarning: (employeeName: string, hours: number) => ({
    title: '⚠️ Überstunden-Warnung',
    body: `${employeeName} arbeitet seit ${hours}+ Stunden`,
    tag: 'shift-overtime',
    data: { type: 'shift', action: 'overtime' },
    requireInteraction: true,
  }),

  breakReminder: (employeeName: string, hours: number) => ({
    title: '☕ Pause empfohlen',
    body: `${employeeName} arbeitet seit ${hours}h ohne Pause`,
    tag: 'shift-break',
    data: { type: 'shift', action: 'break-reminder' },
  }),

  // Inventory notifications
  lowStock: (itemName: string, quantity: number) => ({
    title: '📦 Niedriger Bestand',
    body: `${itemName}: nur noch ${quantity} übrig`,
    tag: 'inventory-low',
    data: { type: 'inventory', action: 'low-stock' },
    requireInteraction: true,
  }),

  stockUpdated: (itemName: string, change: string) => ({
    title: '📦 Bestand aktualisiert',
    body: `${itemName}: ${change}`,
    tag: 'inventory-updated',
    data: { type: 'inventory', action: 'updated' },
  }),

  // Booking notifications (for future)
  newBooking: (guestName: string, time: string, partySize: number) => ({
    title: '📅 Neue Reservierung',
    body: `${guestName} für ${partySize} Personen um ${time}`,
    tag: 'booking-new',
    data: { type: 'booking', action: 'new' },
    requireInteraction: true,
  }),
};

// =============================================
// SUPABASE REALTIME LISTENER
// =============================================

export function setupRealtimeNotifications(
  venueId: string,
  userRole: string,
  notificationService: PushNotificationService
): () => void {
  const channels: ReturnType<typeof supabase.channel>[] = [];

  // Listen for task changes
  const tasksChannel = supabase
    .channel('tasks-realtime')
    .on(
      'postgres_changes',
      {
        event: 'INSERT',
        schema: 'public',
        table: 'tasks',
        filter: `venue_id=eq.${venueId}`,
      },
      (payload) => {
        const task = payload.new as { title: string; assigned_to: string | null };
        if (task.assigned_to) {
          notificationService.showLocalNotification(
            NotificationTriggers.taskAssigned(task.title)
          );
        }
      }
    )
    .on(
      'postgres_changes',
      {
        event: 'UPDATE',
        schema: 'public',
        table: 'tasks',
        filter: `venue_id=eq.${venueId}`,
      },
      (payload) => {
        const task = payload.new as { title: string; status: string };
        const oldTask = payload.old as { status: string };

        // Task completed - notify managers
        if (task.status === 'completed' && oldTask.status !== 'completed') {
          if (userRole === 'owner' || userRole === 'manager') {
            notificationService.showLocalNotification(
              NotificationTriggers.taskNeedsApproval(task.title)
            );
          }
        }

        // Task approved/rejected - notify assignee
        if (task.status === 'approved' && oldTask.status !== 'approved') {
          notificationService.showLocalNotification(
            NotificationTriggers.taskApproved(task.title)
          );
        }
      }
    )
    .subscribe();
  channels.push(tasksChannel);

  // Listen for shift changes (owners/managers only)
  if (userRole === 'owner' || userRole === 'manager') {
    const shiftsChannel = supabase
      .channel('shifts-realtime')
      .on(
        'postgres_changes',
        {
          event: 'INSERT',
          schema: 'public',
          table: 'shifts',
          filter: `venue_id=eq.${venueId}`,
        },
        async (payload) => {
          const shift = payload.new as { employee_id: string };
          // Get employee name
          const { data: employee } = await supabase
            .from('employees')
            .select('name')
            .eq('id', shift.employee_id)
            .single();

          if (employee) {
            notificationService.showLocalNotification(
              NotificationTriggers.shiftClockIn(employee.name)
            );
          }
        }
      )
      .on(
        'postgres_changes',
        {
          event: 'UPDATE',
          schema: 'public',
          table: 'shifts',
          filter: `venue_id=eq.${venueId}`,
        },
        async (payload) => {
          const shift = payload.new as {
            employee_id: string;
            clock_out: string | null;
            actual_hours: number | null;
          };
          const oldShift = payload.old as { clock_out: string | null };

          // Shift ended
          if (shift.clock_out && !oldShift.clock_out) {
            const { data: employee } = await supabase
              .from('employees')
              .select('name')
              .eq('id', shift.employee_id)
              .single();

            if (employee) {
              notificationService.showLocalNotification(
                NotificationTriggers.shiftClockOut(
                  employee.name,
                  shift.actual_hours?.toFixed(1) || '0'
                )
              );
            }
          }
        }
      )
      .subscribe();
    channels.push(shiftsChannel);
  }

  // Listen for low stock (owners/managers only)
  if (userRole === 'owner' || userRole === 'manager') {
    const inventoryChannel = supabase
      .channel('inventory-realtime')
      .on(
        'postgres_changes',
        {
          event: 'UPDATE',
          schema: 'public',
          table: 'inventory_items',
          filter: `venue_id=eq.${venueId}`,
        },
        (payload) => {
          const item = payload.new as {
            name: string;
            storage_quantity: number;
            bar_quantity: number;
            min_stock_level: number;
          };
          const totalStock = item.storage_quantity + item.bar_quantity;

          if (totalStock <= item.min_stock_level) {
            notificationService.showLocalNotification(
              NotificationTriggers.lowStock(item.name, totalStock)
            );
          }
        }
      )
      .subscribe();
    channels.push(inventoryChannel);
  }

  // Return cleanup function
  return () => {
    channels.forEach(channel => supabase.removeChannel(channel));
  };
}

export default pushNotificationService;

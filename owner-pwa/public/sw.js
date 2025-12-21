// Service Worker for WiesbadenAfterDark Owner PWA
const CACHE_NAME = 'wad-owner-v1';
const RUNTIME_CACHE = 'wad-owner-runtime';

// Resources to cache immediately on install
const PRECACHE_URLS = [
  '/',
  '/index.html',
  '/manifest.json',
  '/icon-192.png',
  '/icon-512.png',
];

// Install event - cache critical resources
self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then((cache) => {
        console.log('[SW] Precaching app shell');
        return cache.addAll(PRECACHE_URLS);
      })
      .then(() => {
        console.log('[SW] Install complete');
        return self.skipWaiting();
      })
      .catch((error) => {
        console.error('[SW] Precache failed:', error);
      })
  );
});

// Activate event - clean up old caches
self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys()
      .then((cacheNames) => {
        return Promise.all(
          cacheNames
            .filter((name) => name !== CACHE_NAME && name !== RUNTIME_CACHE)
            .map((name) => {
              console.log('[SW] Deleting old cache:', name);
              return caches.delete(name);
            })
        );
      })
      .then(() => {
        console.log('[SW] Activate complete');
        return self.clients.claim();
      })
  );
});

// Fetch event - network first, fallback to cache
self.addEventListener('fetch', (event) => {
  const { request } = event;
  const url = new URL(request.url);

  // Skip cross-origin requests
  if (url.origin !== location.origin) {
    return;
  }

  // Skip non-GET requests
  if (request.method !== 'GET') {
    return;
  }

  // For navigation requests, try network first
  if (request.mode === 'navigate') {
    event.respondWith(
      fetch(request)
        .then((response) => {
          // Cache successful responses
          if (response.ok) {
            const responseClone = response.clone();
            caches.open(RUNTIME_CACHE).then((cache) => {
              cache.put(request, responseClone);
            });
          }
          return response;
        })
        .catch(() => {
          // Fallback to cache
          return caches.match(request)
            .then((cached) => cached || caches.match('/index.html'));
        })
    );
    return;
  }

  // For static assets, use cache first
  if (
    request.destination === 'style' ||
    request.destination === 'script' ||
    request.destination === 'image' ||
    request.destination === 'font'
  ) {
    event.respondWith(
      caches.match(request)
        .then((cached) => {
          if (cached) {
            // Return cached, but update in background
            fetch(request)
              .then((response) => {
                if (response.ok) {
                  caches.open(RUNTIME_CACHE).then((cache) => {
                    cache.put(request, response);
                  });
                }
              })
              .catch(() => {});
            return cached;
          }

          // Not in cache, fetch from network
          return fetch(request)
            .then((response) => {
              if (response.ok) {
                const responseClone = response.clone();
                caches.open(RUNTIME_CACHE).then((cache) => {
                  cache.put(request, responseClone);
                });
              }
              return response;
            });
        })
    );
    return;
  }

  // Default: network first
  event.respondWith(
    fetch(request)
      .then((response) => {
        if (response.ok) {
          const responseClone = response.clone();
          caches.open(RUNTIME_CACHE).then((cache) => {
            cache.put(request, responseClone);
          });
        }
        return response;
      })
      .catch(() => caches.match(request))
  );
});

// Push notification event
self.addEventListener('push', (event) => {
  console.log('[SW] Push received');

  let data = {
    title: 'WiesbadenAfterDark',
    body: 'You have a new notification',
    icon: '/icon-192.png',
    badge: '/icon-192.png',
  };

  if (event.data) {
    try {
      data = { ...data, ...event.data.json() };
    } catch (e) {
      data.body = event.data.text();
    }
  }

  // Configure notification options
  const notificationOptions = {
    body: data.body,
    icon: data.icon,
    badge: data.badge,
    tag: data.tag || 'default',
    requireInteraction: data.requireInteraction || false,
    data: data.data || {},
    vibrate: [200, 100, 200], // Vibration pattern
  };

  // Add action buttons for task approval notifications
  if (data.tag === 'task-approval' || data.tag === 'task-completed') {
    notificationOptions.actions = [
      { action: 'approve-task', title: '✓ Genehmigen' },
      { action: 'view-task', title: 'Anzeigen' },
    ];
  }

  // Add action buttons for shift notifications
  if (data.tag === 'shift-overtime') {
    notificationOptions.actions = [
      { action: 'view-shift', title: 'Schicht anzeigen' },
      { action: 'dismiss', title: 'OK' },
    ];
  }

  // Add action buttons for inventory alerts
  if (data.tag === 'inventory-low' || data.tag === 'stock-low') {
    notificationOptions.actions = [
      { action: 'view-inventory', title: 'Inventar öffnen' },
      { action: 'dismiss', title: 'Später' },
    ];
  }

  event.waitUntil(
    self.registration.showNotification(data.title, notificationOptions)
  );
});

// Notification click event
self.addEventListener('notificationclick', (event) => {
  console.log('[SW] Notification clicked');
  event.notification.close();

  // Determine URL based on notification type
  let urlToOpen = '/';
  const notificationData = event.notification.data || {};
  const notificationTag = event.notification.tag || '';

  // Route based on notification type
  if (notificationTag.startsWith('shift-')) {
    urlToOpen = '/?page=shifts';
  } else if (notificationTag.startsWith('task-')) {
    urlToOpen = '/?page=tasks';
  } else if (notificationTag.startsWith('booking-')) {
    urlToOpen = '/?page=bookings';
  } else if (notificationTag.startsWith('stock-') || notificationTag.startsWith('inventory-')) {
    urlToOpen = '/?page=inventory';
  } else if (notificationTag.startsWith('event-')) {
    urlToOpen = '/?page=events';
  } else if (notificationData.url) {
    urlToOpen = notificationData.url;
  }

  // Handle action buttons if clicked
  if (event.action) {
    console.log('[SW] Notification action:', event.action);
    switch (event.action) {
      case 'approve-task':
        urlToOpen = `/?page=tasks&action=approve&taskId=${notificationData.taskId || ''}`;
        break;
      case 'view-task':
        urlToOpen = '/?page=tasks';
        break;
      case 'view-shift':
        urlToOpen = `/?page=shifts&shiftId=${notificationData.shiftId || ''}`;
        break;
      case 'view-inventory':
        urlToOpen = '/?page=inventory';
        break;
      case 'dismiss':
        return; // Just close the notification
    }
  }

  event.waitUntil(
    clients.matchAll({ type: 'window', includeUncontrolled: true })
      .then((clientList) => {
        // Check if there's already a window open
        for (const client of clientList) {
          if (client.url.includes(self.location.origin) && 'focus' in client) {
            client.focus();
            client.postMessage({
              type: 'NOTIFICATION_CLICKED',
              data: notificationData,
              action: event.action,
              tag: notificationTag,
            });
            return;
          }
        }
        // No window open, open a new one
        if (clients.openWindow) {
          return clients.openWindow(urlToOpen);
        }
      })
  );
});

// Background sync (for offline actions)
self.addEventListener('sync', (event) => {
  console.log('[SW] Sync event:', event.tag);

  if (event.tag === 'sync-bookings') {
    event.waitUntil(syncBookings());
  } else if (event.tag === 'sync-shifts') {
    event.waitUntil(syncShifts());
  } else if (event.tag === 'sync-tasks') {
    event.waitUntil(syncTasks());
  }
});

async function syncBookings() {
  // This would sync any offline booking changes when back online
  console.log('[SW] Syncing bookings...');
  // Implementation would go here
}

async function syncShifts() {
  // Sync offline shift actions (clock in/out) when back online
  console.log('[SW] Syncing shifts...');
  try {
    const cache = await caches.open('wad-owner-offline-actions');
    const offlineShifts = await cache.match('offline-shifts');
    if (offlineShifts) {
      const shifts = await offlineShifts.json();
      // Process each offline shift action
      for (const shift of shifts) {
        // Send to server
        console.log('[SW] Syncing shift action:', shift);
      }
      // Clear the offline queue
      await cache.delete('offline-shifts');
    }
  } catch (error) {
    console.error('[SW] Shift sync failed:', error);
  }
}

async function syncTasks() {
  // Sync offline task status changes when back online
  console.log('[SW] Syncing tasks...');
  try {
    const cache = await caches.open('wad-owner-offline-actions');
    const offlineTasks = await cache.match('offline-tasks');
    if (offlineTasks) {
      const tasks = await offlineTasks.json();
      // Process each offline task action
      for (const task of tasks) {
        console.log('[SW] Syncing task action:', task);
      }
      // Clear the offline queue
      await cache.delete('offline-tasks');
    }
  } catch (error) {
    console.error('[SW] Task sync failed:', error);
  }
}

// Message handler for communication with main app
self.addEventListener('message', (event) => {
  console.log('[SW] Message received:', event.data);

  if (event.data.type === 'SKIP_WAITING') {
    self.skipWaiting();
  }

  if (event.data.type === 'CLEAR_CACHE') {
    caches.keys().then((names) => {
      names.forEach((name) => caches.delete(name));
    });
  }
});

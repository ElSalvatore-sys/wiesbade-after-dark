import { useState, useEffect } from 'react';
import { Bell, BellOff, Check, X, Users, Package, ClipboardList, Calendar, RefreshCw } from 'lucide-react';
import { pushNotificationService, NotificationTriggers } from '../services/pushNotifications';

interface NotificationPreferences {
  shifts: boolean;
  tasks: boolean;
  inventory: boolean;
  bookings: boolean;
}

const STORAGE_KEY = 'notification_preferences';

export function NotificationSettings() {
  const [permission, setPermission] = useState<NotificationPermission | 'unsupported'>('default');
  const [testSent, setTestSent] = useState(false);
  const [preferences, setPreferences] = useState<NotificationPreferences>(() => {
    const saved = localStorage.getItem(STORAGE_KEY);
    return saved ? JSON.parse(saved) : {
      shifts: true,
      tasks: true,
      inventory: true,
      bookings: true,
    };
  });

  useEffect(() => {
    if (!pushNotificationService.supported) {
      setPermission('unsupported');
    } else {
      setPermission(pushNotificationService.permission);
    }
  }, []);

  useEffect(() => {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(preferences));
  }, [preferences]);

  const handleEnable = async () => {
    const granted = await pushNotificationService.requestPermission();
    setPermission(granted ? 'granted' : 'denied');

    if (granted) {
      // Subscribe to push notifications
      await pushNotificationService.subscribe();
    }
  };

  const handleTest = async () => {
    await pushNotificationService.showLocalNotification({
      title: '🔔 Test Notification',
      body: 'Push notifications are working correctly!',
      tag: 'test-notification',
    });
    setTestSent(true);
    setTimeout(() => setTestSent(false), 3000);
  };

  const handleTestCategory = async (category: keyof NotificationPreferences) => {
    const notifications = {
      shifts: NotificationTriggers.shiftClockIn('Max Müller'),
      tasks: NotificationTriggers.taskAssigned('Bar aufräumen'),
      inventory: NotificationTriggers.lowStock('Hendricks Gin', 3),
      bookings: NotificationTriggers.newBooking('Familie Schmidt', '20:00', 6),
    };

    await pushNotificationService.showLocalNotification(notifications[category]);
  };

  const togglePreference = (key: keyof NotificationPreferences) => {
    setPreferences(prev => ({ ...prev, [key]: !prev[key] }));
  };

  const isGranted = permission === 'granted';
  const isDenied = permission === 'denied';
  const isUnsupported = permission === 'unsupported';

  const categories = [
    {
      key: 'shifts' as const,
      label: 'Schichten',
      description: 'Ein-/Auschecken, Überstunden, Pausen',
      icon: Users,
      color: 'purple'
    },
    {
      key: 'tasks' as const,
      label: 'Aufgaben',
      description: 'Zuweisungen, Abschlüsse, Genehmigungen',
      icon: ClipboardList,
      color: 'cyan'
    },
    {
      key: 'inventory' as const,
      label: 'Inventar',
      description: 'Niedriger Bestand, Aktualisierungen',
      icon: Package,
      color: 'orange'
    },
    {
      key: 'bookings' as const,
      label: 'Reservierungen',
      description: 'Neue Buchungen, Stornierungen',
      icon: Calendar,
      color: 'pink'
    },
  ];

  return (
    <div className="space-y-4">
      {/* Main Permission Card */}
      <div className="glass-card p-5 rounded-xl space-y-4">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-3">
            {isGranted ? (
              <div className="w-12 h-12 rounded-xl bg-success/20 flex items-center justify-center">
                <Bell className="text-success" size={24} />
              </div>
            ) : (
              <div className="w-12 h-12 rounded-xl bg-foreground-dim/20 flex items-center justify-center">
                <BellOff className="text-foreground-dim" size={24} />
              </div>
            )}
            <div>
              <h3 className="font-semibold text-foreground">Push-Benachrichtigungen</h3>
              <p className="text-sm text-foreground-secondary">
                {isGranted && 'Aktiviert - Sie erhalten Echtzeit-Benachrichtigungen'}
                {isDenied && 'Blockiert - In Browser-Einstellungen aktivieren'}
                {isUnsupported && 'Nicht unterstützt in diesem Browser'}
                {permission === 'default' && 'Noch nicht aktiviert'}
              </p>
            </div>
          </div>

          {isGranted ? (
            <div className="flex items-center gap-2 px-3 py-1.5 bg-success/20 rounded-lg">
              <Check size={16} className="text-success" />
              <span className="text-sm text-success font-medium">Aktiv</span>
            </div>
          ) : isDenied ? (
            <div className="flex items-center gap-2 px-3 py-1.5 bg-error/20 rounded-lg">
              <X size={16} className="text-error" />
              <span className="text-sm text-error font-medium">Blockiert</span>
            </div>
          ) : !isUnsupported ? (
            <button
              onClick={handleEnable}
              className="px-4 py-2 bg-gradient-primary text-white rounded-xl hover:shadow-glow-sm transition-all text-sm font-medium"
            >
              Aktivieren
            </button>
          ) : null}
        </div>

        {isGranted && (
          <div className="pt-4 border-t border-border">
            <button
              onClick={handleTest}
              disabled={testSent}
              className="w-full py-2.5 bg-card border border-border text-foreground rounded-xl hover:border-primary-500/30 hover:bg-card/80 transition-all text-sm font-medium disabled:opacity-50 flex items-center justify-center gap-2"
            >
              <RefreshCw size={16} className={testSent ? 'animate-spin' : ''} />
              {testSent ? 'Benachrichtigung gesendet!' : 'Test-Benachrichtigung senden'}
            </button>
          </div>
        )}
      </div>

      {/* Category Toggles */}
      {isGranted && (
        <div className="glass-card p-5 rounded-xl">
          <h4 className="font-medium text-foreground mb-4">Benachrichtigungstypen</h4>
          <div className="space-y-3">
            {categories.map(({ key, label, description, icon: Icon, color }) => (
              <div
                key={key}
                className="flex items-center justify-between p-3 rounded-xl bg-card/50 border border-border hover:border-border/80 transition-all"
              >
                <div className="flex items-center gap-3">
                  <div className={`w-10 h-10 rounded-lg flex items-center justify-center ${
                    color === 'purple' ? 'bg-accent-purple/20 text-accent-purple' :
                    color === 'cyan' ? 'bg-accent-cyan/20 text-accent-cyan' :
                    color === 'orange' ? 'bg-warning/20 text-warning' :
                    'bg-accent-pink/20 text-accent-pink'
                  }`}>
                    <Icon size={20} />
                  </div>
                  <div>
                    <p className="font-medium text-foreground text-sm">{label}</p>
                    <p className="text-xs text-foreground-muted">{description}</p>
                  </div>
                </div>

                <div className="flex items-center gap-2">
                  <button
                    onClick={() => handleTestCategory(key)}
                    className="p-1.5 text-foreground-dim hover:text-foreground hover:bg-white/5 rounded-lg transition-all"
                    title="Test senden"
                  >
                    <Bell size={14} />
                  </button>

                  <button
                    onClick={() => togglePreference(key)}
                    className={`relative w-11 h-6 rounded-full transition-all duration-200 ${
                      preferences[key]
                        ? 'bg-gradient-primary'
                        : 'bg-foreground-dim/30'
                    }`}
                  >
                    <div
                      className={`absolute top-1 w-4 h-4 rounded-full bg-white shadow-sm transition-all duration-200 ${
                        preferences[key] ? 'left-6' : 'left-1'
                      }`}
                    />
                  </button>
                </div>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* Realtime Status */}
      {isGranted && (
        <div className="glass-card p-4 rounded-xl">
          <div className="flex items-center gap-3">
            <div className="w-2 h-2 rounded-full bg-success animate-pulse" />
            <p className="text-sm text-foreground-secondary">
              Supabase Realtime aktiv - Änderungen werden sofort angezeigt
            </p>
          </div>
        </div>
      )}
    </div>
  );
}

export function getNotificationPreferences(): NotificationPreferences {
  const saved = localStorage.getItem(STORAGE_KEY);
  return saved ? JSON.parse(saved) : {
    shifts: true,
    tasks: true,
    inventory: true,
    bookings: true,
  };
}

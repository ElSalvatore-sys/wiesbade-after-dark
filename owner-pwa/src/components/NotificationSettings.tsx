import { useState, useEffect } from 'react';
import { Bell, BellOff, Check, X } from 'lucide-react';
import { getNotificationPermission, requestNotificationPermission, showNotification } from '../services/notifications';

export function NotificationSettings() {
  const [permission, setPermission] = useState<NotificationPermission | 'unsupported'>('default');
  const [testSent, setTestSent] = useState(false);

  useEffect(() => {
    setPermission(getNotificationPermission());
  }, []);

  const handleEnable = async () => {
    const result = await requestNotificationPermission();
    setPermission(result);
  };

  const handleTest = async () => {
    await showNotification('Test Notification', 'Notifications are working!', {
      type: 'system',
    });
    setTestSent(true);
    setTimeout(() => setTestSent(false), 3000);
  };

  const isGranted = permission === 'granted';
  const isDenied = permission === 'denied';
  const isUnsupported = permission === 'unsupported';

  return (
    <div className="glass-card p-5 rounded-xl space-y-4">
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-3">
          {isGranted ? (
            <div className="w-10 h-10 rounded-lg bg-green-500/20 flex items-center justify-center">
              <Bell className="text-green-400" size={20} />
            </div>
          ) : (
            <div className="w-10 h-10 rounded-lg bg-gray-500/20 flex items-center justify-center">
              <BellOff className="text-gray-400" size={20} />
            </div>
          )}
          <div>
            <h3 className="font-medium text-white">Push Notifications</h3>
            <p className="text-sm text-gray-400">
              {isGranted && "Enabled - You'll receive alerts"}
              {isDenied && 'Blocked - Enable in browser settings'}
              {isUnsupported && 'Not supported in this browser'}
              {permission === 'default' && 'Not enabled yet'}
            </p>
          </div>
        </div>

        {isGranted ? (
          <div className="flex items-center gap-2 text-green-400">
            <Check size={18} />
            <span className="text-sm">Active</span>
          </div>
        ) : isDenied ? (
          <div className="flex items-center gap-2 text-red-400">
            <X size={18} />
            <span className="text-sm">Blocked</span>
          </div>
        ) : !isUnsupported ? (
          <button
            onClick={handleEnable}
            className="px-4 py-2 bg-primary text-white rounded-lg hover:bg-primary/80 transition-all text-sm"
          >
            Enable
          </button>
        ) : null}
      </div>

      {isGranted && (
        <div className="pt-3 border-t border-white/10">
          <button
            onClick={handleTest}
            disabled={testSent}
            className="w-full py-2 bg-white/10 text-white rounded-lg hover:bg-white/20 transition-all text-sm disabled:opacity-50"
          >
            {testSent ? 'Notification Sent!' : 'Send Test Notification'}
          </button>
        </div>
      )}

      {isGranted && (
        <div className="space-y-2 pt-3 border-t border-white/10">
          <p className="text-sm text-gray-400">You will be notified about:</p>
          <div className="grid grid-cols-2 gap-2 text-sm">
            <div className="flex items-center gap-2 text-gray-300">
              <span>New bookings</span>
            </div>
            <div className="flex items-center gap-2 text-gray-300">
              <span>Task updates</span>
            </div>
            <div className="flex items-center gap-2 text-gray-300">
              <span>Low stock alerts</span>
            </div>
            <div className="flex items-center gap-2 text-gray-300">
              <span>Event reminders</span>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

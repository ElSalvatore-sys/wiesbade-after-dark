import { NotificationSettings } from '../components/NotificationSettings';
import { useAuth } from '../contexts/AuthContext';
import { User, Building, Shield } from 'lucide-react';

export function Settings() {
  const { user } = useAuth();

  return (
    <div className="max-w-2xl mx-auto space-y-6 animate-fade-in">
      <div>
        <h1 className="text-2xl font-bold text-white">Settings</h1>
        <p className="text-gray-400">Manage your account and preferences</p>
      </div>

      {/* Profile Section */}
      <div className="glass-card p-5 rounded-xl">
        <div className="flex items-center gap-4 mb-4">
          <div className="w-12 h-12 rounded-xl bg-primary/20 flex items-center justify-center">
            <User className="text-primary" size={24} />
          </div>
          <div>
            <h2 className="font-semibold text-white">Profile</h2>
            <p className="text-sm text-gray-400">Your account information</p>
          </div>
        </div>
        <div className="space-y-3">
          <div className="flex justify-between py-2 border-b border-white/10">
            <span className="text-gray-400">Name</span>
            <span className="text-white">{user?.name || 'Not set'}</span>
          </div>
          <div className="flex justify-between py-2 border-b border-white/10">
            <span className="text-gray-400">Email</span>
            <span className="text-white">{user?.email || 'Not set'}</span>
          </div>
          <div className="flex justify-between py-2">
            <span className="text-gray-400">Role</span>
            <span className="text-white capitalize">{user?.role || 'Unknown'}</span>
          </div>
        </div>
      </div>

      {/* Venue Section */}
      <div className="glass-card p-5 rounded-xl">
        <div className="flex items-center gap-4 mb-4">
          <div className="w-12 h-12 rounded-xl bg-blue-500/20 flex items-center justify-center">
            <Building className="text-blue-400" size={24} />
          </div>
          <div>
            <h2 className="font-semibold text-white">Venue</h2>
            <p className="text-sm text-gray-400">Your venue details</p>
          </div>
        </div>
        <div className="space-y-3">
          <div className="flex justify-between py-2 border-b border-white/10">
            <span className="text-gray-400">Venue Name</span>
            <span className="text-white">{user?.venueName || 'Das Wohnzimmer'}</span>
          </div>
          <div className="flex justify-between py-2">
            <span className="text-gray-400">Venue ID</span>
            <span className="text-white font-mono text-sm">{user?.venueId || 'demo'}</span>
          </div>
        </div>
      </div>

      {/* Notifications Section */}
      <NotificationSettings />

      {/* Security Section */}
      <div className="glass-card p-5 rounded-xl">
        <div className="flex items-center gap-4 mb-4">
          <div className="w-12 h-12 rounded-xl bg-red-500/20 flex items-center justify-center">
            <Shield className="text-red-400" size={24} />
          </div>
          <div>
            <h2 className="font-semibold text-white">Security</h2>
            <p className="text-sm text-gray-400">Account security settings</p>
          </div>
        </div>
        <div className="space-y-3">
          <button className="w-full py-3 bg-white/10 text-white rounded-xl hover:bg-white/20 transition-all">
            Change Password
          </button>
          <button className="w-full py-3 bg-red-500/20 text-red-400 rounded-xl hover:bg-red-500/30 transition-all">
            Sign Out of All Devices
          </button>
        </div>
      </div>

      {/* App Info */}
      <div className="text-center text-gray-500 text-sm py-4">
        <p>WiesbadenAfterDark Owner Portal v2.0</p>
        <p className="mt-1">2025 WiesbadenAfterDark</p>
      </div>
    </div>
  );
}

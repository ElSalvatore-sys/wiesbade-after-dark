import { useState } from 'react';
import { Wine, Mail, Lock, Loader2, Users } from 'lucide-react';
import { useAuth } from '../contexts/AuthContext';

interface LoginProps {
  onLogin: () => void;
}

export function Login({ onLogin }: LoginProps) {
  const { login } = useAuth();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError('');

    const result = await login(email, password);

    setLoading(false);

    if (result.success) {
      onLogin();
    } else {
      setError(result.error || 'Invalid credentials');
    }
  };

  const demoAccounts = [
    { email: 'owner@example.com', role: 'Owner', color: 'bg-purple-500' },
    { email: 'manager@example.com', role: 'Manager', color: 'bg-blue-500' },
    { email: 'bartender@example.com', role: 'Bartender', color: 'bg-green-500' },
    { email: 'inventory@example.com', role: 'Inventory', color: 'bg-orange-500' },
    { email: 'cleaning@example.com', role: 'Cleaning', color: 'bg-gray-500' },
  ];

  const quickLogin = (demoEmail: string) => {
    setEmail(demoEmail);
    setPassword('password');
  };

  return (
    <div className="min-h-screen bg-background flex items-center justify-center p-4">
      {/* Background */}
      <div className="absolute inset-0 overflow-hidden">
        <div className="absolute top-1/4 left-1/4 w-96 h-96 bg-primary/20 rounded-full blur-3xl" />
        <div className="absolute bottom-1/4 right-1/4 w-96 h-96 bg-pink-500/20 rounded-full blur-3xl" />
      </div>

      <div className="relative glass-card p-8 rounded-2xl w-full max-w-md animate-scale-in">
        {/* Logo */}
        <div className="text-center mb-8">
          <div className="w-16 h-16 mx-auto mb-4 rounded-2xl bg-gradient-to-br from-primary to-pink-500 flex items-center justify-center">
            <Wine className="w-8 h-8 text-white" />
          </div>
          <h1 className="text-2xl font-bold text-white">Welcome Back</h1>
          <p className="text-gray-400 mt-1">Sign in to your account</p>
        </div>

        {/* Form */}
        <form onSubmit={handleSubmit} className="space-y-4">
          {error && (
            <div className="p-3 bg-red-500/20 border border-red-500/30 rounded-xl text-red-400 text-sm">
              {error}
            </div>
          )}

          <div className="relative">
            <Mail className="absolute left-4 top-1/2 -translate-y-1/2 text-gray-400" size={18} />
            <input
              type="email"
              placeholder="Email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              className="w-full pl-12 pr-4 py-3 bg-white/5 border border-white/10 rounded-xl text-white placeholder-gray-500 focus:outline-none focus:border-primary"
              required
            />
          </div>

          <div className="relative">
            <Lock className="absolute left-4 top-1/2 -translate-y-1/2 text-gray-400" size={18} />
            <input
              type="password"
              placeholder="Password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              className="w-full pl-12 pr-4 py-3 bg-white/5 border border-white/10 rounded-xl text-white placeholder-gray-500 focus:outline-none focus:border-primary"
              required
            />
          </div>

          <button
            type="submit"
            disabled={loading}
            className="w-full py-3 bg-gradient-to-r from-primary to-pink-500 text-white rounded-xl font-medium hover:opacity-90 transition-all disabled:opacity-50 flex items-center justify-center gap-2"
          >
            {loading ? (
              <>
                <Loader2 size={18} className="animate-spin" />
                Signing in...
              </>
            ) : (
              'Sign In'
            )}
          </button>
        </form>

        {/* Demo Accounts */}
        <div className="mt-6 pt-6 border-t border-white/10">
          <p className="text-gray-500 text-sm text-center mb-3 flex items-center justify-center gap-2">
            <Users size={14} />
            Quick Demo Login
          </p>
          <div className="flex flex-wrap gap-2 justify-center">
            {demoAccounts.map((account) => (
              <button
                key={account.email}
                type="button"
                onClick={() => quickLogin(account.email)}
                className={`px-3 py-1.5 ${account.color} text-white text-xs rounded-lg hover:opacity-80 transition-all`}
              >
                {account.role}
              </button>
            ))}
          </div>
          <p className="text-gray-600 text-xs text-center mt-2">
            Password: password
          </p>
        </div>
      </div>
    </div>
  );
}

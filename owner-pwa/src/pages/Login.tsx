import { useState } from 'react';
import { cn } from '../lib/utils';
import { Eye, EyeOff, Mail, Lock, Loader2 } from 'lucide-react';
import api from '../services/api';

interface LoginProps {
  onLogin: () => void;
}

export function Login({ onLogin }: LoginProps) {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState('');

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setIsLoading(true);

    // Demo mode - allow test credentials
    if (email === 'owner@example.com' && password === 'password') {
      api.setToken('demo_token');
      api.setVenueId('demo_venue');
      setIsLoading(false);
      onLogin();
      return;
    }

    // Real API login
    const result = await api.login(email, password);

    if (result.error) {
      setError(result.error);
      setIsLoading(false);
      return;
    }

    // Get user's venue (assuming owner has one venue)
    const venuesResult = await api.getVenues();
    if (venuesResult.data && Array.isArray(venuesResult.data) && venuesResult.data.length > 0) {
      const venue = venuesResult.data[0] as { id: string };
      api.setVenueId(venue.id);
    }

    setIsLoading(false);
    onLogin();
  };

  return (
    <div className="min-h-screen bg-background flex items-center justify-center p-4 relative overflow-hidden">
      {/* Background effects */}
      <div className="absolute inset-0 overflow-hidden">
        {/* Gradient orbs */}
        <div className="absolute -top-40 -right-40 w-80 h-80 bg-accent-purple/20 rounded-full blur-[100px]" />
        <div className="absolute -bottom-40 -left-40 w-80 h-80 bg-accent-pink/20 rounded-full blur-[100px]" />
        <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[600px] h-[600px] bg-gradient-glow opacity-50" />

        {/* Grid pattern */}
        <div
          className="absolute inset-0 opacity-[0.02]"
          style={{
            backgroundImage: `linear-gradient(rgba(255,255,255,0.1) 1px, transparent 1px),
                              linear-gradient(90deg, rgba(255,255,255,0.1) 1px, transparent 1px)`,
            backgroundSize: '50px 50px'
          }}
        />
      </div>

      {/* Login container */}
      <div className="w-full max-w-md relative z-10 animate-fade-in-up">
        {/* Logo */}
        <div className="text-center mb-10">
          <div className="relative inline-block">
            <div className="w-24 h-24 mx-auto rounded-2xl bg-gradient-primary flex items-center justify-center shadow-glow animate-pulse-glow">
              <span className="text-white font-bold text-4xl">W</span>
            </div>
            {/* Glow ring */}
            <div className="absolute inset-0 rounded-2xl bg-gradient-primary opacity-20 blur-xl scale-150" />
          </div>
          <h1 className="mt-8 text-3xl font-bold text-foreground">
            Owner Portal
          </h1>
          <p className="mt-2 text-foreground-secondary">
            Wiesbaden After Dark
          </p>
        </div>

        {/* Login card */}
        <div className="glass-card p-8">
          <form onSubmit={handleSubmit} className="space-y-6">
            {/* Email */}
            <div>
              <label className="block text-sm font-medium text-foreground-secondary mb-2">
                Email Address
              </label>
              <div className="relative">
                <Mail
                  size={18}
                  className="absolute left-4 top-1/2 -translate-y-1/2 text-foreground-dim"
                />
                <input
                  type="email"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  placeholder="owner@venue.com"
                  required
                  className="input-field pl-12"
                />
              </div>
            </div>

            {/* Password */}
            <div>
              <label className="block text-sm font-medium text-foreground-secondary mb-2">
                Password
              </label>
              <div className="relative">
                <Lock
                  size={18}
                  className="absolute left-4 top-1/2 -translate-y-1/2 text-foreground-dim"
                />
                <input
                  type={showPassword ? 'text' : 'password'}
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  placeholder="Enter your password"
                  required
                  className="input-field pl-12 pr-12"
                />
                <button
                  type="button"
                  onClick={() => setShowPassword(!showPassword)}
                  className="absolute right-4 top-1/2 -translate-y-1/2 text-foreground-dim hover:text-foreground transition-colors"
                >
                  {showPassword ? <EyeOff size={18} /> : <Eye size={18} />}
                </button>
              </div>
            </div>

            {/* Error */}
            {error && (
              <div className="p-4 rounded-xl bg-error/10 border border-error/20">
                <p className="text-sm text-error">{error}</p>
              </div>
            )}

            {/* Submit */}
            <button
              type="submit"
              disabled={isLoading}
              className={cn(
                'btn-primary w-full flex items-center justify-center gap-2',
                isLoading && 'opacity-70'
              )}
            >
              {isLoading ? (
                <>
                  <Loader2 size={20} className="animate-spin" />
                  Signing in...
                </>
              ) : (
                'Sign In'
              )}
            </button>
          </form>

          {/* Forgot password */}
          <div className="mt-6 text-center">
            <button className="text-sm text-foreground-secondary hover:text-primary-400 transition-colors">
              Forgot your password?
            </button>
          </div>
        </div>

        {/* Footer */}
        <p className="mt-8 text-center text-xs text-foreground-dim">
          Need help? Contact{' '}
          <a href="mailto:support@wiesbadenafterdark.de" className="text-primary-400 hover:underline">
            support@wiesbadenafterdark.de
          </a>
        </p>
      </div>
    </div>
  );
}

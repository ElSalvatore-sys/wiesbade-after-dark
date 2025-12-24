import { useState, useEffect } from 'react';
import { Wine, Mail, Lock, Loader2, Users, ArrowLeft, CheckCircle, Eye, EyeOff, AlertCircle } from 'lucide-react';
import { useAuth } from '../contexts/AuthContext';
import { supabase } from '../lib/supabase';

interface LoginProps {
  onLogin: () => void;
}

type AuthView = 'login' | 'forgot-password' | 'reset-password';

export function Login({ onLogin }: LoginProps) {
  const { login } = useAuth();
  const [view, setView] = useState<AuthView>('login');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [successMessage, setSuccessMessage] = useState('');

  // Check for password reset token in URL
  useEffect(() => {
    const handlePasswordReset = async () => {
      // Check for Supabase auth hash params (from email link)
      const hashParams = new URLSearchParams(window.location.hash.substring(1));
      const accessToken = hashParams.get('access_token');
      const type = hashParams.get('type');

      if (accessToken && type === 'recovery') {
        // Set session from recovery token
        const { error } = await supabase.auth.setSession({
          access_token: accessToken,
          refresh_token: hashParams.get('refresh_token') || '',
        });

        if (!error) {
          setView('reset-password');
          // Clean up URL
          window.history.replaceState(null, '', window.location.pathname);
        } else {
          setError('Der Link ist ungültig oder abgelaufen.');
        }
      }
    };

    handlePasswordReset();
  }, []);

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError('');

    const result = await login(email, password);

    setLoading(false);

    if (result.success) {
      onLogin();
    } else {
      setError(result.error || 'Ungültige Anmeldedaten');
    }
  };

  const handleForgotPassword = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError('');
    setSuccessMessage('');

    try {
      const { error: resetError } = await supabase.auth.resetPasswordForEmail(email, {
        redirectTo: `${window.location.origin}/`,
      });

      if (resetError) {
        throw resetError;
      }

      setSuccessMessage('E-Mail gesendet! Bitte überprüfen Sie Ihren Posteingang.');
    } catch (err: unknown) {
      console.error('Password reset error:', err);
      setError('Ein Fehler ist aufgetreten. Bitte versuchen Sie es später erneut.');
    } finally {
      setLoading(false);
    }
  };

  const handleResetPassword = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');

    if (password !== confirmPassword) {
      setError('Die Passwörter stimmen nicht überein.');
      return;
    }

    if (password.length < 8) {
      setError('Das Passwort muss mindestens 8 Zeichen lang sein.');
      return;
    }

    setLoading(true);

    try {
      const { error: updateError } = await supabase.auth.updateUser({
        password: password,
      });

      if (updateError) {
        throw updateError;
      }

      setSuccessMessage('Passwort erfolgreich geändert! Sie werden angemeldet...');

      // Sign out and redirect to login
      setTimeout(async () => {
        await supabase.auth.signOut();
        setView('login');
        setPassword('');
        setConfirmPassword('');
        setSuccessMessage('');
      }, 2000);
    } catch (err: unknown) {
      console.error('Password update error:', err);
      setError('Ein Fehler ist aufgetreten. Bitte versuchen Sie es erneut.');
    } finally {
      setLoading(false);
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

  const goBack = () => {
    setView('login');
    setError('');
    setSuccessMessage('');
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
          <h1 className="text-2xl font-bold text-white">
            {view === 'login' && 'Willkommen zurück'}
            {view === 'forgot-password' && 'Passwort vergessen?'}
            {view === 'reset-password' && 'Neues Passwort'}
          </h1>
          <p className="text-gray-400 mt-1">
            {view === 'login' && 'Melden Sie sich an'}
            {view === 'forgot-password' && 'Wir senden Ihnen einen Link zum Zurücksetzen'}
            {view === 'reset-password' && 'Geben Sie Ihr neues Passwort ein'}
          </p>
        </div>

        {/* Back button for non-login views */}
        {view !== 'login' && view !== 'reset-password' && (
          <button
            onClick={goBack}
            className="flex items-center gap-2 text-gray-400 hover:text-white mb-4 transition-colors"
          >
            <ArrowLeft size={16} />
            Zurück zur Anmeldung
          </button>
        )}

        {/* Success Message */}
        {successMessage && (
          <div className="p-4 mb-4 bg-green-500/20 border border-green-500/30 rounded-xl text-green-400 text-sm flex items-center gap-3">
            <CheckCircle size={18} className="flex-shrink-0" />
            {successMessage}
          </div>
        )}

        {/* Error Message */}
        {error && (
          <div className="p-3 mb-4 bg-red-500/20 border border-red-500/30 rounded-xl text-red-400 text-sm flex items-center gap-3">
            <AlertCircle size={18} className="flex-shrink-0" />
            {error}
          </div>
        )}

        {/* Login Form */}
        {view === 'login' && (
          <form onSubmit={handleLogin} className="space-y-4">
            <div className="relative">
              <Mail className="absolute left-4 top-1/2 -translate-y-1/2 text-gray-400" size={18} />
              <input
                type="email"
                placeholder="E-Mail"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                className="w-full pl-12 pr-4 py-3 bg-white/5 border border-white/10 rounded-xl text-white placeholder-gray-500 focus:outline-none focus:border-primary"
                required
              />
            </div>

            <div className="relative">
              <Lock className="absolute left-4 top-1/2 -translate-y-1/2 text-gray-400" size={18} />
              <input
                type={showPassword ? 'text' : 'password'}
                placeholder="Passwort"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                className="w-full pl-12 pr-12 py-3 bg-white/5 border border-white/10 rounded-xl text-white placeholder-gray-500 focus:outline-none focus:border-primary"
                required
              />
              <button
                type="button"
                onClick={() => setShowPassword(!showPassword)}
                className="absolute right-4 top-1/2 -translate-y-1/2 text-gray-400 hover:text-white"
              >
                {showPassword ? <EyeOff size={18} /> : <Eye size={18} />}
              </button>
            </div>

            {/* Forgot Password Link */}
            <div className="text-right">
              <button
                type="button"
                onClick={() => setView('forgot-password')}
                className="text-sm text-purple-400 hover:text-purple-300 transition-colors"
              >
                Passwort vergessen?
              </button>
            </div>

            <button
              type="submit"
              disabled={loading}
              className="w-full py-3 bg-gradient-to-r from-primary to-pink-500 text-white rounded-xl font-medium hover:opacity-90 transition-all disabled:opacity-50 flex items-center justify-center gap-2"
            >
              {loading ? (
                <>
                  <Loader2 size={18} className="animate-spin" />
                  Anmelden...
                </>
              ) : (
                'Anmelden'
              )}
            </button>
          </form>
        )}

        {/* Forgot Password Form */}
        {view === 'forgot-password' && !successMessage && (
          <form onSubmit={handleForgotPassword} className="space-y-4">
            <div className="relative">
              <Mail className="absolute left-4 top-1/2 -translate-y-1/2 text-gray-400" size={18} />
              <input
                type="email"
                placeholder="E-Mail-Adresse"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
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
                  Senden...
                </>
              ) : (
                'Link senden'
              )}
            </button>
          </form>
        )}

        {/* Reset Password Form */}
        {view === 'reset-password' && !successMessage && (
          <form onSubmit={handleResetPassword} className="space-y-4">
            <div className="relative">
              <Lock className="absolute left-4 top-1/2 -translate-y-1/2 text-gray-400" size={18} />
              <input
                type={showPassword ? 'text' : 'password'}
                placeholder="Neues Passwort (min. 8 Zeichen)"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                className="w-full pl-12 pr-12 py-3 bg-white/5 border border-white/10 rounded-xl text-white placeholder-gray-500 focus:outline-none focus:border-primary"
                required
                minLength={8}
              />
              <button
                type="button"
                onClick={() => setShowPassword(!showPassword)}
                className="absolute right-4 top-1/2 -translate-y-1/2 text-gray-400 hover:text-white"
              >
                {showPassword ? <EyeOff size={18} /> : <Eye size={18} />}
              </button>
            </div>

            <div className="relative">
              <Lock className="absolute left-4 top-1/2 -translate-y-1/2 text-gray-400" size={18} />
              <input
                type={showPassword ? 'text' : 'password'}
                placeholder="Passwort bestätigen"
                value={confirmPassword}
                onChange={(e) => setConfirmPassword(e.target.value)}
                className="w-full pl-12 pr-4 py-3 bg-white/5 border border-white/10 rounded-xl text-white placeholder-gray-500 focus:outline-none focus:border-primary"
                required
              />
            </div>

            {/* Password requirements */}
            <div className="text-sm text-gray-500 space-y-1">
              <p className={password.length >= 8 ? 'text-green-400' : ''}>
                • Mindestens 8 Zeichen
              </p>
              <p className={password === confirmPassword && password.length > 0 ? 'text-green-400' : ''}>
                • Passwörter stimmen überein
              </p>
            </div>

            <button
              type="submit"
              disabled={loading || password.length < 8 || password !== confirmPassword}
              className="w-full py-3 bg-gradient-to-r from-primary to-pink-500 text-white rounded-xl font-medium hover:opacity-90 transition-all disabled:opacity-50 flex items-center justify-center gap-2"
            >
              {loading ? (
                <>
                  <Loader2 size={18} className="animate-spin" />
                  Speichern...
                </>
              ) : (
                'Passwort speichern'
              )}
            </button>
          </form>
        )}

        {/* Demo Accounts - only show on login view */}
        {view === 'login' && (
          <div className="mt-6 pt-6 border-t border-white/10">
            <p className="text-gray-500 text-sm text-center mb-3 flex items-center justify-center gap-2">
              <Users size={14} />
              Demo-Anmeldung
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
              Passwort: password
            </p>
          </div>
        )}
      </div>
    </div>
  );
}

import { Component } from 'react';
import type { ErrorInfo, ReactNode } from 'react';
import { AlertTriangle, RefreshCw, Home } from 'lucide-react';

interface Props {
  children: ReactNode;
  fallback?: ReactNode;
}

interface State {
  hasError: boolean;
  error: Error | null;
}

/**
 * Error Boundary component to catch and display React errors gracefully
 */
class ErrorBoundary extends Component<Props, State> {
  public state: State = {
    hasError: false,
    error: null,
  };

  public static getDerivedStateFromError(error: Error): State {
    return { hasError: true, error };
  }

  public componentDidCatch(error: Error, errorInfo: ErrorInfo) {
    console.error('ErrorBoundary caught an error:', error, errorInfo);
  }

  private handleReload = () => {
    window.location.reload();
  };

  private handleGoHome = () => {
    window.location.href = '/';
  };

  public render() {
    if (this.state.hasError) {
      if (this.props.fallback) {
        return this.props.fallback;
      }

      return (
        <div className="min-h-screen bg-zinc-950 flex items-center justify-center p-4">
          <div className="max-w-md w-full bg-zinc-900 rounded-2xl p-8 text-center">
            <div className="w-16 h-16 bg-red-500/10 rounded-full flex items-center justify-center mx-auto mb-6">
              <AlertTriangle className="w-8 h-8 text-red-500" />
            </div>

            <h1 className="text-xl font-semibold text-white mb-2">
              Ein Fehler ist aufgetreten
            </h1>

            <p className="text-zinc-400 mb-6">
              Es ist ein unerwarteter Fehler aufgetreten. Bitte versuchen Sie, die Seite neu zu laden.
            </p>

            {import.meta.env.DEV && this.state.error && (
              <div className="bg-zinc-800 rounded-lg p-4 mb-6 text-left">
                <p className="text-red-400 text-sm font-mono break-all">
                  {this.state.error.message}
                </p>
              </div>
            )}

            <div className="flex gap-3">
              <button
                onClick={this.handleGoHome}
                className="flex-1 flex items-center justify-center gap-2 py-3 px-4 bg-zinc-800 hover:bg-zinc-700 text-white rounded-xl transition-colors"
              >
                <Home className="w-4 h-4" />
                Startseite
              </button>

              <button
                onClick={this.handleReload}
                className="flex-1 flex items-center justify-center gap-2 py-3 px-4 bg-purple-600 hover:bg-purple-500 text-white rounded-xl transition-colors"
              >
                <RefreshCw className="w-4 h-4" />
                Erneut versuchen
              </button>
            </div>
          </div>
        </div>
      );
    }

    return this.props.children;
  }
}

export default ErrorBoundary;

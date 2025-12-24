import { Component } from 'react';
import type { ErrorInfo, ReactNode } from 'react';
import { AlertTriangle, RefreshCw, ArrowLeft } from 'lucide-react';

interface Props {
  children: ReactNode;
  pageName?: string;
  onNavigateBack?: () => void;
}

interface State {
  hasError: boolean;
  error: Error | null;
}

/**
 * Page-level Error Boundary - catches errors in individual pages
 * Allows users to navigate away or retry without affecting the whole app
 */
class PageErrorBoundary extends Component<Props, State> {
  public state: State = {
    hasError: false,
    error: null,
  };

  public static getDerivedStateFromError(error: Error): State {
    return { hasError: true, error };
  }

  public componentDidCatch(error: Error, errorInfo: ErrorInfo) {
    console.error(`[PageError] ${this.props.pageName || 'Page'}:`, error, errorInfo);
  }

  private handleRetry = () => {
    this.setState({ hasError: false, error: null });
  };

  private handleGoBack = () => {
    if (this.props.onNavigateBack) {
      this.setState({ hasError: false, error: null });
      this.props.onNavigateBack();
    }
  };

  public render() {
    if (this.state.hasError) {
      return (
        <div className="flex-1 flex items-center justify-center p-6">
          <div className="max-w-sm w-full text-center">
            <div className="w-14 h-14 bg-red-500/10 rounded-full flex items-center justify-center mx-auto mb-4">
              <AlertTriangle className="w-7 h-7 text-red-500" />
            </div>

            <h2 className="text-lg font-semibold text-white mb-2">
              Seite konnte nicht geladen werden
            </h2>

            <p className="text-zinc-400 text-sm mb-4">
              Ein Fehler ist auf dieser Seite aufgetreten.
              {this.props.pageName && (
                <span className="block mt-1 text-zinc-500">
                  ({this.props.pageName})
                </span>
              )}
            </p>

            {import.meta.env.DEV && this.state.error && (
              <div className="bg-zinc-800/50 rounded-lg p-3 mb-4 text-left">
                <p className="text-red-400 text-xs font-mono break-all">
                  {this.state.error.message}
                </p>
              </div>
            )}

            <div className="flex gap-2">
              {this.props.onNavigateBack && (
                <button
                  onClick={this.handleGoBack}
                  className="flex-1 flex items-center justify-center gap-2 py-2.5 px-4 bg-zinc-800 hover:bg-zinc-700 text-white rounded-lg transition-colors text-sm"
                >
                  <ArrowLeft className="w-4 h-4" />
                  Zurück
                </button>
              )}

              <button
                onClick={this.handleRetry}
                className="flex-1 flex items-center justify-center gap-2 py-2.5 px-4 bg-purple-600 hover:bg-purple-500 text-white rounded-lg transition-colors text-sm"
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

export default PageErrorBoundary;

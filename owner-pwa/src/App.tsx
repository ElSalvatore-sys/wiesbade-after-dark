import { useState, useEffect } from 'react';
import { Login, Dashboard, Events, Bookings, Inventory, Employees, Shifts, Tasks, Analytics, Settings, AuditLog } from './pages';
import { DashboardLayout } from './components/layout';
import { AuthProvider, useAuth } from './contexts/AuthContext';
import { ThemeProvider } from './contexts/ThemeContext';
import { ToastProvider } from './contexts/ToastContext';
import ErrorBoundary from './components/ErrorBoundary';
import PageErrorBoundary from './components/PageErrorBoundary';
import OfflineBanner from './components/OfflineBanner';
import { pushNotificationService } from './services/pushNotifications';
import { registerServiceWorker } from './services/notifications';

type Page = 'dashboard' | 'events' | 'bookings' | 'inventory' | 'employees' | 'shifts' | 'tasks' | 'analytics' | 'settings' | 'audit';

function AppContent() {
  const { user, isAuthenticated, logout, hasPermission } = useAuth();
  const [currentPage, setCurrentPage] = useState<Page>('dashboard');

  // Initialize push notifications and realtime listeners when authenticated
  useEffect(() => {
    if (isAuthenticated && user?.venueId && user?.role) {
      // Register service worker
      registerServiceWorker();

      // Setup realtime notifications for venue
      pushNotificationService.setupRealtime(user.venueId, user.role);

      // Cleanup on logout
      return () => {
        pushNotificationService.cleanupRealtime();
      };
    }
  }, [isAuthenticated, user?.venueId, user?.role]);

  const handleLogin = () => {
    // Auth state is managed by context
  };

  const handleLogout = () => {
    logout();
    setCurrentPage('dashboard');
  };

  const handleNavigate = (page: string) => {
    setCurrentPage(page as Page);
  };

  if (!isAuthenticated) {
    return <Login onLogin={handleLogin} />;
  }

  const goToDashboard = () => setCurrentPage('dashboard');

  const renderPage = () => {
    switch (currentPage) {
      case 'dashboard':
        return (
          <PageErrorBoundary pageName="Dashboard">
            <Dashboard onNavigate={handleNavigate} />
          </PageErrorBoundary>
        );
      case 'events':
        return (
          <PageErrorBoundary pageName="Veranstaltungen" onNavigateBack={goToDashboard}>
            <Events />
          </PageErrorBoundary>
        );
      case 'bookings':
        return (
          <PageErrorBoundary pageName="Reservierungen" onNavigateBack={goToDashboard}>
            <Bookings />
          </PageErrorBoundary>
        );
      case 'inventory':
        return (
          <PageErrorBoundary pageName="Inventar" onNavigateBack={goToDashboard}>
            <Inventory />
          </PageErrorBoundary>
        );
      case 'employees':
        return (
          <PageErrorBoundary pageName="Mitarbeiter" onNavigateBack={goToDashboard}>
            <Employees />
          </PageErrorBoundary>
        );
      case 'shifts':
        return (
          <PageErrorBoundary pageName="Schichten" onNavigateBack={goToDashboard}>
            <Shifts />
          </PageErrorBoundary>
        );
      case 'tasks':
        return (
          <PageErrorBoundary pageName="Aufgaben" onNavigateBack={goToDashboard}>
            <Tasks />
          </PageErrorBoundary>
        );
      case 'analytics':
        return (
          <PageErrorBoundary pageName="Statistiken" onNavigateBack={goToDashboard}>
            <Analytics />
          </PageErrorBoundary>
        );
      case 'settings':
        return (
          <PageErrorBoundary pageName="Einstellungen" onNavigateBack={goToDashboard}>
            <Settings />
          </PageErrorBoundary>
        );
      case 'audit':
        return (
          <PageErrorBoundary pageName="Aktivitätsprotokoll" onNavigateBack={goToDashboard}>
            <AuditLog />
          </PageErrorBoundary>
        );
      default:
        return (
          <PageErrorBoundary pageName="Dashboard">
            <Dashboard onNavigate={handleNavigate} />
          </PageErrorBoundary>
        );
    }
  };

  // Filter navigation based on permissions
  const handleNavigateWithPermission = (page: string) => {
    if (hasPermission(page)) {
      setCurrentPage(page as Page);
    }
  };

  return (
    <DashboardLayout
      currentPage={currentPage}
      onNavigate={handleNavigateWithPermission}
      onLogout={handleLogout}
      venueName={user?.venueName || 'Das Wohnzimmer'}
      userName={user?.name || 'User'}
      userAvatar={undefined}
      userRole={user?.role}
      hasPermission={hasPermission}
    >
      {renderPage()}
    </DashboardLayout>
  );
}

function App() {
  return (
    <ErrorBoundary>
      <ThemeProvider>
        <ToastProvider>
          <AuthProvider>
            <OfflineBanner />
            <AppContent />
          </AuthProvider>
        </ToastProvider>
      </ThemeProvider>
    </ErrorBoundary>
  );
}

export default App;

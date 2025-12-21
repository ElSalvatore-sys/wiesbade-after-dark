import { useState, useEffect } from 'react';
import { Login, Dashboard, Events, Bookings, Inventory, Employees, Shifts, Tasks, Analytics, Settings } from './pages';
import { DashboardLayout } from './components/layout';
import { AuthProvider, useAuth } from './contexts/AuthContext';
import ErrorBoundary from './components/ErrorBoundary';
import OfflineBanner from './components/OfflineBanner';
import { pushNotificationService } from './services/pushNotifications';
import { registerServiceWorker } from './services/notifications';

type Page = 'dashboard' | 'events' | 'bookings' | 'inventory' | 'employees' | 'shifts' | 'tasks' | 'analytics' | 'settings';

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

  const renderPage = () => {
    switch (currentPage) {
      case 'dashboard':
        return <Dashboard onNavigate={handleNavigate} />;
      case 'events':
        return <Events />;
      case 'bookings':
        return <Bookings />;
      case 'inventory':
        return <Inventory />;
      case 'employees':
        return <Employees />;
      case 'shifts':
        return <Shifts />;
      case 'tasks':
        return <Tasks />;
      case 'analytics':
        return <Analytics />;
      case 'settings':
        return <Settings />;
      default:
        return <Dashboard onNavigate={handleNavigate} />;
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
      <AuthProvider>
        <OfflineBanner />
        <AppContent />
      </AuthProvider>
    </ErrorBoundary>
  );
}

export default App;

import { useState } from 'react';
import { Login, Dashboard, Events, Bookings, Inventory, Employees, Tasks, Settings } from './pages';
import { DashboardLayout } from './components/layout';
import { AuthProvider, useAuth } from './contexts/AuthContext';

type Page = 'dashboard' | 'events' | 'bookings' | 'inventory' | 'employees' | 'tasks' | 'settings';

function AppContent() {
  const { user, isAuthenticated, logout, hasPermission } = useAuth();
  const [currentPage, setCurrentPage] = useState<Page>('dashboard');

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
      case 'tasks':
        return <Tasks />;
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
    <AuthProvider>
      <AppContent />
    </AuthProvider>
  );
}

export default App;

import { useState } from 'react';
import { Login, Dashboard, Events, Bookings, Inventory, Employees, Tasks } from './pages';
import { DashboardLayout } from './components/layout';

// Mock user data
const mockUser = {
  name: 'Max Mustermann',
  email: 'owner@example.com',
  avatar: undefined,
};

const mockVenue = {
  name: 'Club Noir',
};

type Page = 'dashboard' | 'events' | 'bookings' | 'inventory' | 'employees' | 'tasks' | 'settings';

function App() {
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [currentPage, setCurrentPage] = useState<Page>('dashboard');

  const handleLogin = (_email: string, _password: string) => {
    setIsAuthenticated(true);
  };

  const handleLogout = () => {
    setIsAuthenticated(false);
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
        return (
          <PlaceholderPage
            title="Settings"
            description="Configure your venue and account settings"
          />
        );
      default:
        return <Dashboard onNavigate={handleNavigate} />;
    }
  };

  return (
    <DashboardLayout
      currentPage={currentPage}
      onNavigate={handleNavigate}
      onLogout={handleLogout}
      venueName={mockVenue.name}
      userName={mockUser.name}
      userAvatar={mockUser.avatar}
    >
      {renderPage()}
    </DashboardLayout>
  );
}

function PlaceholderPage({
  title,
  description,
}: {
  title: string;
  description: string;
}) {
  return (
    <div className="animate-fade-in">
      <h1 className="text-2xl font-bold text-foreground">{title}</h1>
      <p className="text-foreground-secondary mt-1">{description}</p>
      <div className="mt-8 glass-card p-12 text-center">
        <div className="w-16 h-16 mx-auto rounded-2xl bg-gradient-primary/20 flex items-center justify-center mb-4">
          <span className="text-3xl">🚧</span>
        </div>
        <h3 className="text-lg font-semibold text-foreground">Coming Soon</h3>
        <p className="text-foreground-muted mt-2">
          This feature is under development
        </p>
      </div>
    </div>
  );
}

export default App;

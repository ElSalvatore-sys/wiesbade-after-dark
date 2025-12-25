import React, { createContext, useContext, useState, useEffect, type ReactNode } from 'react';

type Theme = 'dark' | 'light' | 'system';

interface ThemeContextType {
  theme: Theme;
  resolvedTheme: 'dark' | 'light';
  setTheme: (theme: Theme) => void;
  toggleTheme: () => void;
}

const ThemeContext = createContext<ThemeContextType | undefined>(undefined);

export const ThemeProvider: React.FC<{ children: ReactNode }> = ({ children }) => {
  // App is dark-only - theme is always 'dark'
  const [theme] = useState<Theme>('dark');
  const [resolvedTheme] = useState<'dark' | 'light'>('dark');

  useEffect(() => {
    // Ensure dark mode is always applied
    const root = document.documentElement;
    root.classList.add('dark');
    root.classList.remove('light');
  }, []);

  // No-op functions for backward compatibility
  const setTheme = () => {
    // Dark-only app - theme cannot be changed
  };

  const toggleTheme = () => {
    // Dark-only app - theme cannot be toggled
  };

  return (
    <ThemeContext.Provider value={{ theme, resolvedTheme, setTheme, toggleTheme }}>
      {children}
    </ThemeContext.Provider>
  );
};

export const useTheme = () => {
  const context = useContext(ThemeContext);
  if (!context) {
    throw new Error('useTheme must be used within ThemeProvider');
  }
  return context;
};

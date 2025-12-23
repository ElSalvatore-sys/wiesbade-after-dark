import { useHotkeys } from 'react-hotkeys-hook';
import { useState } from 'react';

interface ShortcutConfig {
  key: string;
  description: string;
  action: () => void;
}

interface UseKeyboardShortcutsProps {
  onNavigate: (page: string) => void;
}

export const useKeyboardShortcuts = ({ onNavigate }: UseKeyboardShortcutsProps) => {
  const [showHelp, setShowHelp] = useState(false);
  const [showCommandPalette, setShowCommandPalette] = useState(false);

  // Navigation shortcuts
  useHotkeys('g+d', () => onNavigate('dashboard'), { description: 'Go to Dashboard' });
  useHotkeys('g+s', () => onNavigate('shifts'), { description: 'Go to Shifts' });
  useHotkeys('g+t', () => onNavigate('tasks'), { description: 'Go to Tasks' });
  useHotkeys('g+i', () => onNavigate('inventory'), { description: 'Go to Inventory' });
  useHotkeys('g+a', () => onNavigate('analytics'), { description: 'Go to Analytics' });
  useHotkeys('g+e', () => onNavigate('employees'), { description: 'Go to Employees' });
  useHotkeys('g+b', () => onNavigate('bookings'), { description: 'Go to Bookings' });
  useHotkeys('g+v', () => onNavigate('events'), { description: 'Go to Events' });

  // Quick actions
  useHotkeys('mod+k', (e) => {
    e.preventDefault();
    setShowCommandPalette(true);
  }, { description: 'Open command palette' });

  useHotkeys('shift+/', () => setShowHelp(true), { description: 'Show shortcuts' });
  useHotkeys('escape', () => {
    setShowHelp(false);
    setShowCommandPalette(false);
  }, { description: 'Close dialogs' });

  const shortcuts: ShortcutConfig[] = [
    { key: 'g d', description: 'Go to Dashboard', action: () => onNavigate('dashboard') },
    { key: 'g s', description: 'Go to Shifts', action: () => onNavigate('shifts') },
    { key: 'g t', description: 'Go to Tasks', action: () => onNavigate('tasks') },
    { key: 'g i', description: 'Go to Inventory', action: () => onNavigate('inventory') },
    { key: 'g a', description: 'Go to Analytics', action: () => onNavigate('analytics') },
    { key: 'g e', description: 'Go to Employees', action: () => onNavigate('employees') },
    { key: 'g b', description: 'Go to Bookings', action: () => onNavigate('bookings') },
    { key: 'g v', description: 'Go to Events', action: () => onNavigate('events') },
    { key: '⌘ K', description: 'Command Palette', action: () => setShowCommandPalette(true) },
    { key: '?', description: 'Show Shortcuts', action: () => setShowHelp(true) },
    { key: 'Esc', description: 'Close Dialog', action: () => {} },
  ];

  return {
    shortcuts,
    showHelp,
    setShowHelp,
    showCommandPalette,
    setShowCommandPalette,
  };
};

export default useKeyboardShortcuts;

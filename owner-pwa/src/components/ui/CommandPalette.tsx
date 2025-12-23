import React, { useState, useEffect, useMemo } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import {
  Search,
  LayoutDashboard,
  Clock,
  ClipboardList,
  Package,
  Users,
  BarChart3,
  Settings,
  Moon,
  Sun,
  Calendar,
  CalendarDays,
} from 'lucide-react';
import { backdropAnimation, modalAnimation } from '../../lib/animations';
import { useTheme } from '../../contexts/ThemeContext';

interface Command {
  id: string;
  icon: React.ElementType;
  title: string;
  description?: string;
  action: () => void;
  keywords?: string[];
}

interface CommandPaletteProps {
  isOpen: boolean;
  onClose: () => void;
  onNavigate: (page: string) => void;
}

export const CommandPalette: React.FC<CommandPaletteProps> = ({
  isOpen,
  onClose,
  onNavigate,
}) => {
  const [search, setSearch] = useState('');
  const [selectedIndex, setSelectedIndex] = useState(0);
  const { theme, setTheme } = useTheme();

  const commands: Command[] = useMemo(() => [
    {
      id: 'dashboard',
      icon: LayoutDashboard,
      title: 'Dashboard',
      description: 'Zur Übersicht',
      action: () => { onNavigate('dashboard'); onClose(); },
      keywords: ['home', 'übersicht', 'start'],
    },
    {
      id: 'shifts',
      icon: Clock,
      title: 'Schichten',
      description: 'Schichtverwaltung öffnen',
      action: () => { onNavigate('shifts'); onClose(); },
      keywords: ['zeit', 'uhr', 'arbeitszeit'],
    },
    {
      id: 'tasks',
      icon: ClipboardList,
      title: 'Aufgaben',
      description: 'Aufgabenliste öffnen',
      action: () => { onNavigate('tasks'); onClose(); },
      keywords: ['todo', 'liste', 'arbeit'],
    },
    {
      id: 'inventory',
      icon: Package,
      title: 'Inventar',
      description: 'Bestandsverwaltung öffnen',
      action: () => { onNavigate('inventory'); onClose(); },
      keywords: ['lager', 'bestand', 'produkte'],
    },
    {
      id: 'analytics',
      icon: BarChart3,
      title: 'Statistiken',
      description: 'Analysen und Berichte',
      action: () => { onNavigate('analytics'); onClose(); },
      keywords: ['berichte', 'charts', 'daten'],
    },
    {
      id: 'employees',
      icon: Users,
      title: 'Mitarbeiter',
      description: 'Team verwalten',
      action: () => { onNavigate('employees'); onClose(); },
      keywords: ['team', 'personal', 'staff'],
    },
    {
      id: 'bookings',
      icon: Calendar,
      title: 'Reservierungen',
      description: 'Buchungen verwalten',
      action: () => { onNavigate('bookings'); onClose(); },
      keywords: ['reservierung', 'tisch', 'buchung'],
    },
    {
      id: 'events',
      icon: CalendarDays,
      title: 'Events',
      description: 'Veranstaltungen verwalten',
      action: () => { onNavigate('events'); onClose(); },
      keywords: ['party', 'veranstaltung', 'event'],
    },
    {
      id: 'settings',
      icon: Settings,
      title: 'Einstellungen',
      description: 'App-Einstellungen',
      action: () => { onNavigate('settings'); onClose(); },
      keywords: ['config', 'optionen'],
    },
    {
      id: 'theme',
      icon: theme === 'dark' ? Sun : Moon,
      title: theme === 'dark' ? 'Helles Design' : 'Dunkles Design',
      description: 'Farbschema wechseln',
      action: () => { setTheme(theme === 'dark' ? 'light' : 'dark'); onClose(); },
      keywords: ['dark', 'light', 'mode', 'farbe'],
    },
  ], [onNavigate, onClose, theme, setTheme]);

  const filteredCommands = useMemo(() => {
    if (!search) return commands;
    const lower = search.toLowerCase();
    return commands.filter(cmd =>
      cmd.title.toLowerCase().includes(lower) ||
      cmd.description?.toLowerCase().includes(lower) ||
      cmd.keywords?.some(k => k.includes(lower))
    );
  }, [commands, search]);

  useEffect(() => {
    setSelectedIndex(0);
  }, [search]);

  useEffect(() => {
    if (!isOpen) {
      setSearch('');
      setSelectedIndex(0);
    }
  }, [isOpen]);

  const handleKeyDown = (e: React.KeyboardEvent) => {
    switch (e.key) {
      case 'ArrowDown':
        e.preventDefault();
        setSelectedIndex(i => Math.min(i + 1, filteredCommands.length - 1));
        break;
      case 'ArrowUp':
        e.preventDefault();
        setSelectedIndex(i => Math.max(i - 1, 0));
        break;
      case 'Enter':
        e.preventDefault();
        if (filteredCommands[selectedIndex]) {
          filteredCommands[selectedIndex].action();
        }
        break;
      case 'Escape':
        onClose();
        break;
    }
  };

  return (
    <AnimatePresence>
      {isOpen && (
        <>
          <motion.div
            className="fixed inset-0 bg-black/60 backdrop-blur-sm z-50"
            variants={backdropAnimation}
            initial="hidden"
            animate="visible"
            exit="exit"
            onClick={onClose}
          />

          <motion.div
            className="fixed inset-0 flex items-start justify-center pt-[20vh] z-50 pointer-events-none"
            variants={modalAnimation}
            initial="hidden"
            animate="visible"
            exit="exit"
          >
            <div className="bg-gray-800 rounded-xl shadow-2xl border border-gray-700 w-full max-w-lg mx-4 pointer-events-auto overflow-hidden">
              {/* Search Input */}
              <div className="flex items-center gap-3 p-4 border-b border-gray-700">
                <Search className="w-5 h-5 text-gray-400" />
                <input
                  type="text"
                  placeholder="Suche nach Befehlen..."
                  value={search}
                  onChange={(e) => setSearch(e.target.value)}
                  onKeyDown={handleKeyDown}
                  className="flex-1 bg-transparent text-white placeholder-gray-500 outline-none"
                  autoFocus
                />
                <kbd className="px-2 py-1 bg-gray-700 rounded text-xs text-gray-400">
                  esc
                </kbd>
              </div>

              {/* Commands List */}
              <div className="max-h-80 overflow-y-auto p-2">
                {filteredCommands.length === 0 ? (
                  <div className="py-8 text-center text-gray-500">
                    Keine Befehle gefunden
                  </div>
                ) : (
                  filteredCommands.map((cmd, index) => {
                    const Icon = cmd.icon;
                    return (
                      <button
                        key={cmd.id}
                        onClick={cmd.action}
                        onMouseEnter={() => setSelectedIndex(index)}
                        className={`w-full flex items-center gap-3 p-3 rounded-lg transition-colors ${
                          index === selectedIndex
                            ? 'bg-purple-600/20 text-white'
                            : 'text-gray-300 hover:bg-gray-700/50'
                        }`}
                      >
                        <Icon className={`w-5 h-5 ${index === selectedIndex ? 'text-purple-400' : 'text-gray-500'}`} />
                        <div className="flex-1 text-left">
                          <div className="font-medium">{cmd.title}</div>
                          {cmd.description && (
                            <div className="text-sm text-gray-500">{cmd.description}</div>
                          )}
                        </div>
                        {index === selectedIndex && (
                          <kbd className="px-2 py-1 bg-gray-700 rounded text-xs text-gray-400">
                            ↵
                          </kbd>
                        )}
                      </button>
                    );
                  })
                )}
              </div>

              {/* Footer */}
              <div className="flex items-center justify-between p-3 border-t border-gray-700 text-xs text-gray-500">
                <div className="flex items-center gap-4">
                  <span><kbd className="px-1 bg-gray-700 rounded">↑↓</kbd> Navigation</span>
                  <span><kbd className="px-1 bg-gray-700 rounded">↵</kbd> Auswählen</span>
                </div>
                <span><kbd className="px-1 bg-gray-700 rounded">⌘K</kbd> öffnen</span>
              </div>
            </div>
          </motion.div>
        </>
      )}
    </AnimatePresence>
  );
};

export default CommandPalette;

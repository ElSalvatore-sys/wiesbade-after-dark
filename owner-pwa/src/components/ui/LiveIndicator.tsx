/**
 * Live Indicator Component
 * Shows realtime connection status with pulse animation
 */

import React, { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { WifiOff, Zap } from 'lucide-react';
import { cn } from '../../lib/utils';

interface LiveIndicatorProps {
  isConnected: boolean;
  lastUpdate?: Date | null;
  showLabel?: boolean;
  className?: string;
}

export const LiveIndicator: React.FC<LiveIndicatorProps> = ({
  isConnected,
  lastUpdate,
  showLabel = true,
  className,
}) => {
  const [showPulse, setShowPulse] = useState(false);

  // Pulse animation when data updates
  useEffect(() => {
    if (lastUpdate) {
      setShowPulse(true);
      const timer = setTimeout(() => setShowPulse(false), 1000);
      return () => clearTimeout(timer);
    }
  }, [lastUpdate]);

  const formatLastUpdate = (date: Date) => {
    const now = new Date();
    const diffMs = now.getTime() - date.getTime();
    const diffSec = Math.floor(diffMs / 1000);
    const diffMin = Math.floor(diffSec / 60);

    if (diffSec < 10) return 'gerade eben';
    if (diffSec < 60) return `vor ${diffSec}s`;
    if (diffMin < 60) return `vor ${diffMin}m`;
    return date.toLocaleTimeString('de-DE', { hour: '2-digit', minute: '2-digit' });
  };

  return (
    <div className={cn('flex items-center gap-2', className)}>
      {/* Connection status dot */}
      <div className="relative">
        <motion.div
          className={cn(
            'w-2.5 h-2.5 rounded-full',
            isConnected ? 'bg-green-500' : 'bg-red-500'
          )}
          animate={showPulse ? { scale: [1, 1.5, 1] } : {}}
          transition={{ duration: 0.3 }}
        />

        {/* Pulse ring when connected */}
        {isConnected && (
          <motion.div
            className="absolute inset-0 w-2.5 h-2.5 rounded-full bg-green-500"
            animate={{ scale: [1, 2], opacity: [0.5, 0] }}
            transition={{ duration: 1.5, repeat: Infinity }}
          />
        )}
      </div>

      {/* Label */}
      {showLabel && (
        <div className="flex items-center gap-1.5">
          <span className={cn(
            'text-xs font-medium',
            isConnected ? 'text-green-400' : 'text-red-400'
          )}>
            {isConnected ? 'Live' : 'Offline'}
          </span>

          {/* Icon */}
          {isConnected ? (
            <Zap className="w-3 h-3 text-green-400" />
          ) : (
            <WifiOff className="w-3 h-3 text-red-400" />
          )}
        </div>
      )}

      {/* Last update tooltip on hover */}
      {lastUpdate && isConnected && (
        <span className="text-xs text-gray-500 hidden sm:inline">
          · {formatLastUpdate(lastUpdate)}
        </span>
      )}
    </div>
  );
};

// Compact version for mobile/header
export const LiveDot: React.FC<{ isConnected: boolean }> = ({ isConnected }) => (
  <div className="relative">
    <div className={cn(
      'w-2 h-2 rounded-full',
      isConnected ? 'bg-green-500' : 'bg-red-500'
    )} />
    {isConnected && (
      <motion.div
        className="absolute inset-0 w-2 h-2 rounded-full bg-green-500"
        animate={{ scale: [1, 2], opacity: [0.5, 0] }}
        transition={{ duration: 1.5, repeat: Infinity }}
      />
    )}
  </div>
);

// Update banner that slides in when data changes
export const UpdateBanner: React.FC<{
  show: boolean;
  message?: string;
  onClose?: () => void;
}> = ({ show, message = 'Daten aktualisiert', onClose }) => (
  <AnimatePresence>
    {show && (
      <motion.div
        initial={{ opacity: 0, y: -20 }}
        animate={{ opacity: 1, y: 0 }}
        exit={{ opacity: 0, y: -20 }}
        className="fixed top-4 left-1/2 -translate-x-1/2 z-50 bg-green-600 text-white px-4 py-2 rounded-lg shadow-lg flex items-center gap-2"
      >
        <Zap className="w-4 h-4" />
        <span className="text-sm font-medium">{message}</span>
        {onClose && (
          <button onClick={onClose} className="ml-2 hover:bg-green-700 rounded p-1">
            ×
          </button>
        )}
      </motion.div>
    )}
  </AnimatePresence>
);

export default LiveIndicator;

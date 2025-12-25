/**
 * Theme Notice Component
 * Explains why the app is dark-mode only
 */

import React from 'react';
import { Moon } from 'lucide-react';

export const ThemeNotice: React.FC = () => (
  <div className="flex items-center gap-3 p-4 bg-gray-800/50 rounded-lg border border-gray-700">
    <div className="p-2 bg-purple-500/20 rounded-lg">
      <Moon className="w-5 h-5 text-purple-400" />
    </div>
    <div>
      <p className="text-sm font-medium text-white">Dark Mode</p>
      <p className="text-xs text-gray-400">
        Diese App verwendet ausschließlich den Dark Mode für optimale Lesbarkeit in Bar- und Club-Umgebungen.
      </p>
    </div>
  </div>
);

export default ThemeNotice;

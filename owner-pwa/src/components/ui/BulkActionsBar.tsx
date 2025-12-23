/**
 * Floating action bar that appears when items are selected
 */

import React from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { X, Trash2, CheckCircle, XCircle, UserPlus, Tag } from 'lucide-react';
import { cn } from '../../lib/utils';

interface BulkAction {
  id: string;
  label: string;
  icon: React.ElementType;
  onClick: () => void;
  variant?: 'default' | 'danger' | 'success';
  disabled?: boolean;
}

interface BulkActionsBarProps {
  selectedCount: number;
  onDeselectAll: () => void;
  actions: BulkAction[];
  className?: string;
}

const variantStyles = {
  default: 'bg-gray-700 hover:bg-gray-600 text-white',
  danger: 'bg-red-600 hover:bg-red-700 text-white',
  success: 'bg-green-600 hover:bg-green-700 text-white',
};

export const BulkActionsBar: React.FC<BulkActionsBarProps> = ({
  selectedCount,
  onDeselectAll,
  actions,
  className,
}) => {
  return (
    <AnimatePresence>
      {selectedCount > 0 && (
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          exit={{ opacity: 0, y: 20 }}
          className={cn(
            'fixed bottom-20 md:bottom-6 left-1/2 -translate-x-1/2 z-40',
            'bg-gray-800 border border-gray-700 rounded-xl shadow-2xl',
            'flex items-center gap-2 p-2',
            className
          )}
        >
          {/* Selection count */}
          <div className="flex items-center gap-2 px-3 py-2 bg-purple-600/20 rounded-lg">
            <span className="text-purple-400 font-semibold">{selectedCount}</span>
            <span className="text-gray-300 text-sm">ausgewählt</span>
          </div>

          {/* Divider */}
          <div className="w-px h-8 bg-gray-700" />

          {/* Actions */}
          <div className="flex items-center gap-1">
            {actions.map((action) => {
              const Icon = action.icon;
              return (
                <button
                  key={action.id}
                  onClick={action.onClick}
                  disabled={action.disabled}
                  className={cn(
                    'flex items-center gap-2 px-3 py-2 rounded-lg transition-colors',
                    'disabled:opacity-50 disabled:cursor-not-allowed',
                    variantStyles[action.variant || 'default']
                  )}
                  title={action.label}
                >
                  <Icon className="w-4 h-4" />
                  <span className="hidden sm:inline text-sm">{action.label}</span>
                </button>
              );
            })}
          </div>

          {/* Divider */}
          <div className="w-px h-8 bg-gray-700" />

          {/* Deselect button */}
          <button
            onClick={onDeselectAll}
            className="p-2 rounded-lg hover:bg-gray-700 text-gray-400 hover:text-white transition-colors"
            title="Auswahl aufheben"
          >
            <X className="w-5 h-5" />
          </button>
        </motion.div>
      )}
    </AnimatePresence>
  );
};

// Pre-built action configurations
export const taskBulkActions = {
  markComplete: (onClick: () => void): BulkAction => ({
    id: 'complete',
    label: 'Erledigt',
    icon: CheckCircle,
    onClick,
    variant: 'success',
  }),
  markPending: (onClick: () => void): BulkAction => ({
    id: 'pending',
    label: 'Ausstehend',
    icon: XCircle,
    onClick,
  }),
  assign: (onClick: () => void): BulkAction => ({
    id: 'assign',
    label: 'Zuweisen',
    icon: UserPlus,
    onClick,
  }),
  delete: (onClick: () => void): BulkAction => ({
    id: 'delete',
    label: 'Löschen',
    icon: Trash2,
    onClick,
    variant: 'danger',
  }),
};

export const inventoryBulkActions = {
  updateCategory: (onClick: () => void): BulkAction => ({
    id: 'category',
    label: 'Kategorie',
    icon: Tag,
    onClick,
  }),
  delete: (onClick: () => void): BulkAction => ({
    id: 'delete',
    label: 'Löschen',
    icon: Trash2,
    onClick,
    variant: 'danger',
  }),
};

export default BulkActionsBar;

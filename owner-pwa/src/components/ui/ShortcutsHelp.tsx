import React from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { X, Keyboard } from 'lucide-react';
import { backdropAnimation, modalAnimation } from '../../lib/animations';

interface Shortcut {
  key: string;
  description: string;
}

interface ShortcutsHelpProps {
  isOpen: boolean;
  onClose: () => void;
  shortcuts: Shortcut[];
}

export const ShortcutsHelp: React.FC<ShortcutsHelpProps> = ({
  isOpen,
  onClose,
  shortcuts,
}) => {
  return (
    <AnimatePresence>
      {isOpen && (
        <>
          {/* Backdrop */}
          <motion.div
            className="fixed inset-0 bg-black/60 backdrop-blur-sm z-50"
            variants={backdropAnimation}
            initial="hidden"
            animate="visible"
            exit="exit"
            onClick={onClose}
          />

          {/* Modal */}
          <motion.div
            className="fixed inset-0 flex items-center justify-center z-50 pointer-events-none"
            variants={modalAnimation}
            initial="hidden"
            animate="visible"
            exit="exit"
          >
            <div className="bg-gray-800 rounded-xl shadow-2xl border border-gray-700 w-full max-w-md mx-4 pointer-events-auto">
              {/* Header */}
              <div className="flex items-center justify-between p-4 border-b border-gray-700">
                <div className="flex items-center gap-3">
                  <Keyboard className="w-5 h-5 text-purple-400" />
                  <h2 className="text-lg font-semibold text-white">Tastenkürzel</h2>
                </div>
                <button
                  onClick={onClose}
                  className="p-2 rounded-lg hover:bg-gray-700 transition-colors text-gray-400 hover:text-white"
                >
                  <X className="w-5 h-5" />
                </button>
              </div>

              {/* Shortcuts List */}
              <div className="p-4 space-y-2 max-h-96 overflow-y-auto">
                {shortcuts.map((shortcut, index) => (
                  <div
                    key={index}
                    className="flex items-center justify-between py-2 px-3 rounded-lg hover:bg-gray-700/50"
                  >
                    <span className="text-gray-300">{shortcut.description}</span>
                    <kbd className="px-2 py-1 bg-gray-700 rounded text-sm font-mono text-purple-300 border border-gray-600">
                      {shortcut.key}
                    </kbd>
                  </div>
                ))}
              </div>

              {/* Footer */}
              <div className="p-4 border-t border-gray-700 text-center">
                <p className="text-sm text-gray-500">
                  Drücke <kbd className="px-1.5 py-0.5 bg-gray-700 rounded text-xs">?</kbd> um diese Hilfe anzuzeigen
                </p>
              </div>
            </div>
          </motion.div>
        </>
      )}
    </AnimatePresence>
  );
};

export default ShortcutsHelp;

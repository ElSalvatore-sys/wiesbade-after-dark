import { useState } from 'react';
import { cn } from '../lib/utils';
import { X, Minus, Plus, Package } from 'lucide-react';
import type { InventoryItem } from '../types';

interface StockUpdateModalProps {
  isOpen: boolean;
  onClose: () => void;
  onSave: (itemId: string, newQuantity: number, reason: string) => void;
  item: InventoryItem | null;
}

const adjustmentReasons = [
  { value: 'sale', label: 'Sale' },
  { value: 'restock', label: 'Restock' },
  { value: 'waste', label: 'Waste / Spillage' },
  { value: 'adjustment', label: 'Inventory Adjustment' },
  { value: 'transfer', label: 'Transfer' },
];

export function StockUpdateModal({ isOpen, onClose, onSave, item }: StockUpdateModalProps) {
  const [adjustment, setAdjustment] = useState(0);
  const [reason, setReason] = useState('adjustment');

  if (!isOpen || !item) return null;

  const newQuantity = item.quantity + adjustment;
  const isLowStock = newQuantity <= item.minStock;

  const handleSave = () => {
    onSave(item.id, newQuantity, reason);
    setAdjustment(0);
    setReason('adjustment');
    onClose();
  };

  const quickAdjust = (amount: number) => {
    setAdjustment(adjustment + amount);
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
      {/* Backdrop */}
      <div
        className="absolute inset-0 bg-black/60 backdrop-blur-sm"
        onClick={onClose}
      />

      {/* Modal */}
      <div className="relative w-full max-w-sm glass-card p-0 animate-scale-in">
        {/* Header */}
        <div className="flex items-center justify-between p-5 border-b border-white/5">
          <h2 className="text-lg font-bold text-foreground">Update Stock</h2>
          <button
            onClick={onClose}
            className="p-2 rounded-lg text-foreground-muted hover:text-foreground hover:bg-white/5 transition-colors"
          >
            <X size={20} />
          </button>
        </div>

        {/* Content */}
        <div className="p-5 space-y-5">
          {/* Item info */}
          <div className="flex items-center gap-4 p-4 rounded-xl bg-card">
            <div className="p-3 rounded-xl bg-accent-purple/20 text-accent-purple">
              <Package size={24} />
            </div>
            <div>
              <p className="font-semibold text-foreground">{item.name}</p>
              <p className="text-sm text-foreground-muted capitalize">{item.category}</p>
            </div>
          </div>

          {/* Current stock */}
          <div className="text-center">
            <p className="text-sm text-foreground-muted mb-2">Current Stock</p>
            <p className="text-4xl font-bold text-foreground">
              {item.quantity} <span className="text-lg text-foreground-muted">{item.unit}</span>
            </p>
          </div>

          {/* Adjustment controls */}
          <div className="flex items-center justify-center gap-4">
            <button
              onClick={() => quickAdjust(-10)}
              className="px-3 py-2 rounded-lg bg-card border border-border text-foreground-secondary hover:text-foreground hover:border-border-light transition-colors"
            >
              -10
            </button>
            <button
              onClick={() => quickAdjust(-1)}
              className="p-3 rounded-xl bg-error/20 text-error hover:bg-error/30 transition-colors"
            >
              <Minus size={24} />
            </button>
            <div className="w-20 text-center">
              <p className={cn(
                'text-3xl font-bold',
                adjustment > 0 ? 'text-success' : adjustment < 0 ? 'text-error' : 'text-foreground-muted'
              )}>
                {adjustment > 0 ? '+' : ''}{adjustment}
              </p>
            </div>
            <button
              onClick={() => quickAdjust(1)}
              className="p-3 rounded-xl bg-success/20 text-success hover:bg-success/30 transition-colors"
            >
              <Plus size={24} />
            </button>
            <button
              onClick={() => quickAdjust(10)}
              className="px-3 py-2 rounded-lg bg-card border border-border text-foreground-secondary hover:text-foreground hover:border-border-light transition-colors"
            >
              +10
            </button>
          </div>

          {/* New quantity preview */}
          <div className={cn(
            'text-center p-3 rounded-xl',
            isLowStock ? 'bg-error/10 border border-error/20' : 'bg-success/10 border border-success/20'
          )}>
            <p className="text-sm text-foreground-muted mb-1">New Stock Level</p>
            <p className={cn(
              'text-2xl font-bold',
              isLowStock ? 'text-error' : 'text-success'
            )}>
              {newQuantity} {item.unit}
            </p>
            {isLowStock && (
              <p className="text-xs text-error mt-1">Below minimum ({item.minStock})</p>
            )}
          </div>

          {/* Reason */}
          <div>
            <label className="block text-sm font-medium text-foreground-secondary mb-2">
              Reason
            </label>
            <div className="flex flex-wrap gap-2">
              {adjustmentReasons.map((r) => (
                <button
                  key={r.value}
                  onClick={() => setReason(r.value)}
                  className={cn(
                    'px-3 py-1.5 rounded-lg text-sm font-medium transition-all',
                    reason === r.value
                      ? 'bg-gradient-primary text-white shadow-glow-sm'
                      : 'bg-card border border-border text-foreground-secondary hover:border-border-light'
                  )}
                >
                  {r.label}
                </button>
              ))}
            </div>
          </div>
        </div>

        {/* Footer */}
        <div className="flex gap-3 p-5 border-t border-white/5">
          <button onClick={onClose} className="btn-secondary flex-1">
            Cancel
          </button>
          <button
            onClick={handleSave}
            disabled={adjustment === 0}
            className={cn(
              'btn-primary flex-1',
              adjustment === 0 && 'opacity-50 cursor-not-allowed'
            )}
          >
            Save
          </button>
        </div>
      </div>
    </div>
  );
}

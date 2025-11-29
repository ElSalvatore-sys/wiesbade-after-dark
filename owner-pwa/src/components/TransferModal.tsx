import { useState, useEffect } from 'react';
import { cn } from '../lib/utils';
import { X, ArrowRightLeft, Warehouse, Wine, Package, Search } from 'lucide-react';

interface InventoryItem {
  id: string;
  name: string;
  barcode: string;
  category: string;
  storageCount: number;
  barCount: number;
  minStock: number;
  price: number;
  costPrice: number;
  imageUrl?: string;
  lastMovement?: string;
}

interface TransferModalProps {
  inventory: InventoryItem[];
  selectedItem: InventoryItem | null;
  onClose: () => void;
  onTransfer: (itemId: string, quantity: number, from: 'storage' | 'bar', to: 'storage' | 'bar') => void;
}

export function TransferModal({ inventory, selectedItem, onClose, onTransfer }: TransferModalProps) {
  const [searchQuery, setSearchQuery] = useState('');
  const [item, setItem] = useState<InventoryItem | null>(selectedItem);
  const [quantity, setQuantity] = useState(1);
  const [direction, setDirection] = useState<'to_bar' | 'to_storage'>('to_bar');

  useEffect(() => {
    if (selectedItem) {
      setItem(selectedItem);
    }
  }, [selectedItem]);

  const filteredItems = inventory.filter(i =>
    i.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
    i.barcode.includes(searchQuery)
  );

  const maxQuantity = item
    ? direction === 'to_bar' ? item.storageCount : item.barCount
    : 0;

  const handleSubmit = () => {
    if (item && quantity > 0 && quantity <= maxQuantity) {
      onTransfer(
        item.id,
        quantity,
        direction === 'to_bar' ? 'storage' : 'bar',
        direction === 'to_bar' ? 'bar' : 'storage'
      );
    }
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
      <div className="absolute inset-0 bg-black/60 backdrop-blur-sm" onClick={onClose} />

      <div className="relative w-full max-w-md glass-card p-0 animate-scale-in max-h-[90vh] overflow-hidden flex flex-col">
        {/* Header */}
        <div className="flex items-center justify-between p-5 border-b border-white/5">
          <h2 className="text-xl font-bold text-foreground flex items-center gap-2">
            <ArrowRightLeft size={20} className="text-primary-400" />
            Transfer Stock
          </h2>
          <button
            onClick={onClose}
            className="p-2 rounded-lg text-foreground-muted hover:text-foreground hover:bg-white/5 transition-colors"
          >
            <X size={20} />
          </button>
        </div>

        <div className="flex-1 overflow-y-auto p-5 space-y-5">
          {/* Item Selection */}
          {!item ? (
            <>
              <div className="relative">
                <Search size={18} className="absolute left-3 top-1/2 -translate-y-1/2 text-foreground-dim" />
                <input
                  type="text"
                  value={searchQuery}
                  onChange={(e) => setSearchQuery(e.target.value)}
                  placeholder="Search item to transfer..."
                  className="w-full pl-10 pr-4 py-3 rounded-xl bg-card border border-border text-foreground placeholder:text-foreground-dim focus:border-primary-500 transition-all"
                />
              </div>

              <div className="space-y-2 max-h-60 overflow-y-auto">
                {filteredItems.map((i) => (
                  <button
                    key={i.id}
                    onClick={() => setItem(i)}
                    className="w-full p-3 rounded-xl bg-card border border-border hover:border-primary-500/50 transition-all flex items-center gap-3 text-left"
                  >
                    <div className="p-2 rounded-lg bg-accent-purple/20">
                      <Package size={18} className="text-accent-purple" />
                    </div>
                    <div className="flex-1 min-w-0">
                      <p className="font-medium text-foreground truncate">{i.name}</p>
                      <p className="text-xs text-foreground-muted">
                        Storage: {i.storageCount} • Bar: {i.barCount}
                      </p>
                    </div>
                  </button>
                ))}
              </div>
            </>
          ) : (
            <>
              {/* Selected Item */}
              <div className="flex items-center gap-4 p-4 rounded-xl bg-card">
                <div className="p-3 rounded-xl bg-accent-purple/20 text-accent-purple">
                  <Package size={24} />
                </div>
                <div className="flex-1">
                  <p className="font-semibold text-foreground">{item.name}</p>
                  <p className="text-sm text-foreground-muted">
                    Storage: {item.storageCount} • Bar: {item.barCount}
                  </p>
                </div>
                <button
                  onClick={() => setItem(null)}
                  className="text-xs text-primary-400 hover:underline"
                >
                  Change
                </button>
              </div>

              {/* Direction */}
              <div>
                <label className="block text-sm font-medium text-foreground-secondary mb-2">
                  Direction
                </label>
                <div className="grid grid-cols-2 gap-2">
                  <button
                    onClick={() => {
                      setDirection('to_bar');
                      setQuantity(1);
                    }}
                    className={cn(
                      'p-4 rounded-xl border text-sm font-medium transition-all flex flex-col items-center gap-2',
                      direction === 'to_bar'
                        ? 'bg-gradient-primary text-white border-transparent shadow-glow-sm'
                        : 'bg-card border-border text-foreground-secondary hover:border-border-light'
                    )}
                  >
                    <div className="flex items-center gap-2">
                      <Warehouse size={18} />
                      <span>→</span>
                      <Wine size={18} />
                    </div>
                    <span>Storage → Bar</span>
                    <span className="text-xs opacity-70">Available: {item.storageCount}</span>
                  </button>
                  <button
                    onClick={() => {
                      setDirection('to_storage');
                      setQuantity(1);
                    }}
                    className={cn(
                      'p-4 rounded-xl border text-sm font-medium transition-all flex flex-col items-center gap-2',
                      direction === 'to_storage'
                        ? 'bg-gradient-primary text-white border-transparent shadow-glow-sm'
                        : 'bg-card border-border text-foreground-secondary hover:border-border-light'
                    )}
                  >
                    <div className="flex items-center gap-2">
                      <Wine size={18} />
                      <span>→</span>
                      <Warehouse size={18} />
                    </div>
                    <span>Bar → Storage</span>
                    <span className="text-xs opacity-70">Available: {item.barCount}</span>
                  </button>
                </div>
              </div>

              {/* Quantity */}
              <div>
                <label className="block text-sm font-medium text-foreground-secondary mb-2">
                  Quantity (max: {maxQuantity})
                </label>
                <div className="flex items-center gap-3">
                  <button
                    onClick={() => setQuantity(Math.max(1, quantity - 1))}
                    disabled={quantity <= 1}
                    className="p-3 rounded-xl bg-card border border-border text-foreground-secondary hover:text-foreground hover:border-border-light disabled:opacity-50"
                  >
                    −
                  </button>
                  <input
                    type="number"
                    min={1}
                    max={maxQuantity}
                    value={quantity}
                    onChange={(e) => setQuantity(Math.min(maxQuantity, Math.max(1, parseInt(e.target.value) || 1)))}
                    className="flex-1 text-center text-2xl font-bold bg-card border border-border rounded-xl py-3 text-foreground"
                  />
                  <button
                    onClick={() => setQuantity(Math.min(maxQuantity, quantity + 1))}
                    disabled={quantity >= maxQuantity}
                    className="p-3 rounded-xl bg-card border border-border text-foreground-secondary hover:text-foreground hover:border-border-light disabled:opacity-50"
                  >
                    +
                  </button>
                </div>

                {/* Quick select buttons */}
                <div className="flex gap-2 mt-2">
                  {[1, 5, 10, maxQuantity].filter((v, i, arr) => arr.indexOf(v) === i && v <= maxQuantity).map((val) => (
                    <button
                      key={val}
                      onClick={() => setQuantity(val)}
                      className={cn(
                        'flex-1 py-2 rounded-lg text-sm font-medium transition-all',
                        quantity === val
                          ? 'bg-primary-500/20 text-primary-400 border border-primary-500/30'
                          : 'bg-card border border-border text-foreground-muted hover:text-foreground'
                      )}
                    >
                      {val === maxQuantity ? 'All' : val}
                    </button>
                  ))}
                </div>
              </div>

              {/* Preview */}
              <div className="p-4 rounded-xl bg-success/10 border border-success/20">
                <p className="text-sm text-foreground-muted mb-3">After Transfer:</p>
                <div className="grid grid-cols-2 gap-4">
                  <div className="text-center">
                    <div className="flex items-center justify-center gap-2 mb-1">
                      <Warehouse size={14} className="text-foreground-muted" />
                      <span className="text-xs text-foreground-muted">Storage</span>
                    </div>
                    <p className="text-lg font-bold text-foreground">
                      {direction === 'to_bar' ? item.storageCount - quantity : item.storageCount + quantity}
                    </p>
                  </div>
                  <div className="text-center">
                    <div className="flex items-center justify-center gap-2 mb-1">
                      <Wine size={14} className="text-foreground-muted" />
                      <span className="text-xs text-foreground-muted">Bar</span>
                    </div>
                    <p className="text-lg font-bold text-foreground">
                      {direction === 'to_bar' ? item.barCount + quantity : item.barCount - quantity}
                    </p>
                  </div>
                </div>
              </div>
            </>
          )}
        </div>

        {/* Footer */}
        <div className="flex gap-3 p-5 border-t border-white/5">
          <button onClick={onClose} className="btn-secondary flex-1">
            Cancel
          </button>
          <button
            onClick={handleSubmit}
            disabled={!item || quantity <= 0 || quantity > maxQuantity}
            className={cn(
              'btn-primary flex-1',
              (!item || quantity <= 0 || quantity > maxQuantity) && 'opacity-50 cursor-not-allowed'
            )}
          >
            Transfer
          </button>
        </div>
      </div>
    </div>
  );
}

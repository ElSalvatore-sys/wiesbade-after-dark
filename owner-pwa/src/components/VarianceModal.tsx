import { useState } from 'react';
import { cn } from '../lib/utils';
import { X, BarChart3, AlertTriangle, TrendingDown, TrendingUp, CheckCircle, Package } from 'lucide-react';

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
}

interface VarianceEntry {
  itemId: string;
  itemName: string;
  expectedStorage: number;
  expectedBar: number;
  actualStorage: number;
  actualBar: number;
  varianceStorage: number;
  varianceBar: number;
  varianceValue: number;
  status: 'pending' | 'investigated' | 'resolved';
}

interface VarianceModalProps {
  inventory: InventoryItem[];
  onClose: () => void;
}

export function VarianceModal({ inventory, onClose }: VarianceModalProps) {
  const [mode, setMode] = useState<'view' | 'count'>('view');
  const [countData, setCountData] = useState<Record<string, { storage: string; bar: string }>>({});
  const [variances, setVariances] = useState<VarianceEntry[]>([]);

  // Mock historical variance data
  const mockVariances: VarianceEntry[] = [
    {
      itemId: '1',
      itemName: 'Corona Extra',
      expectedStorage: 50,
      expectedBar: 10,
      actualStorage: 48,
      actualBar: 12,
      varianceStorage: -2,
      varianceBar: 2,
      varianceValue: -3.60,
      status: 'resolved',
    },
    {
      itemId: '2',
      itemName: 'Hendricks Gin',
      expectedStorage: 8,
      expectedBar: 2,
      actualStorage: 6,
      actualBar: 2,
      varianceStorage: -2,
      varianceBar: 0,
      varianceValue: -56.00,
      status: 'pending',
    },
    {
      itemId: '5',
      itemName: 'Red Bull',
      expectedStorage: 40,
      expectedBar: 15,
      actualStorage: 36,
      actualBar: 18,
      varianceStorage: -4,
      varianceBar: 3,
      varianceValue: -1.50,
      status: 'investigated',
    },
  ];

  const displayVariances = variances.length > 0 ? variances : mockVariances;

  const handleStartCount = () => {
    const initial: Record<string, { storage: string; bar: string }> = {};
    inventory.forEach(item => {
      initial[item.id] = { storage: '', bar: '' };
    });
    setCountData(initial);
    setMode('count');
  };

  const handleCountChange = (itemId: string, location: 'storage' | 'bar', value: string) => {
    setCountData(prev => ({
      ...prev,
      [itemId]: {
        ...prev[itemId],
        [location]: value,
      },
    }));
  };

  const handleSubmitCount = () => {
    const newVariances: VarianceEntry[] = [];

    inventory.forEach(item => {
      const count = countData[item.id];
      if (!count) return;

      const actualStorage = count.storage ? parseInt(count.storage) : item.storageCount;
      const actualBar = count.bar ? parseInt(count.bar) : item.barCount;
      const varianceStorage = actualStorage - item.storageCount;
      const varianceBar = actualBar - item.barCount;

      if (varianceStorage !== 0 || varianceBar !== 0) {
        newVariances.push({
          itemId: item.id,
          itemName: item.name,
          expectedStorage: item.storageCount,
          expectedBar: item.barCount,
          actualStorage,
          actualBar,
          varianceStorage,
          varianceBar,
          varianceValue: (varianceStorage + varianceBar) * item.costPrice,
          status: 'pending',
        });
      }
    });

    setVariances(newVariances);
    setMode('view');
  };

  const totalVarianceValue = displayVariances.reduce((sum, v) => sum + v.varianceValue, 0);
  const pendingCount = displayVariances.filter(v => v.status === 'pending').length;

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'pending': return 'bg-warning/10 text-warning border-warning/20';
      case 'investigated': return 'bg-primary-500/10 text-primary-400 border-primary-500/20';
      case 'resolved': return 'bg-success/10 text-success border-success/20';
      default: return 'bg-foreground-dim/10 text-foreground-muted border-foreground-dim/20';
    }
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
      <div className="absolute inset-0 bg-black/60 backdrop-blur-sm" onClick={onClose} />

      <div className="relative w-full max-w-2xl glass-card p-0 animate-scale-in max-h-[90vh] overflow-hidden flex flex-col">
        {/* Header */}
        <div className="flex items-center justify-between p-5 border-b border-white/5">
          <h2 className="text-xl font-bold text-foreground flex items-center gap-2">
            <BarChart3 size={20} className="text-primary-400" />
            Inventory Variance
          </h2>
          <button
            onClick={onClose}
            className="p-2 rounded-lg text-foreground-muted hover:text-foreground hover:bg-white/5 transition-colors"
          >
            <X size={20} />
          </button>
        </div>

        {mode === 'view' ? (
          <>
            {/* Summary Stats */}
            <div className="p-5 border-b border-white/5">
              <div className="grid grid-cols-3 gap-4">
                <div className="p-3 rounded-xl bg-card border border-border">
                  <p className="text-xs text-foreground-muted mb-1">Total Variance</p>
                  <p className={cn(
                    'text-xl font-bold',
                    totalVarianceValue < 0 ? 'text-error' : totalVarianceValue > 0 ? 'text-success' : 'text-foreground'
                  )}>
                    {totalVarianceValue >= 0 ? '+' : ''}{totalVarianceValue.toFixed(2)}€
                  </p>
                </div>
                <div className="p-3 rounded-xl bg-card border border-border">
                  <p className="text-xs text-foreground-muted mb-1">Items with Variance</p>
                  <p className="text-xl font-bold text-foreground">{displayVariances.length}</p>
                </div>
                <div className="p-3 rounded-xl bg-card border border-border">
                  <p className="text-xs text-foreground-muted mb-1">Pending Review</p>
                  <p className="text-xl font-bold text-warning">{pendingCount}</p>
                </div>
              </div>
            </div>

            {/* Variance List */}
            <div className="flex-1 overflow-y-auto p-5 space-y-3">
              {displayVariances.length === 0 ? (
                <div className="text-center py-12">
                  <CheckCircle size={48} className="mx-auto text-success mb-4" />
                  <p className="text-foreground font-medium">No variances detected</p>
                  <p className="text-foreground-muted text-sm mt-1">All inventory counts match</p>
                </div>
              ) : (
                displayVariances.map((v) => (
                  <div
                    key={v.itemId}
                    className="p-4 rounded-xl bg-card border border-border"
                  >
                    <div className="flex items-start justify-between mb-3">
                      <div className="flex items-center gap-3">
                        <div className="p-2 rounded-lg bg-accent-purple/20">
                          <Package size={16} className="text-accent-purple" />
                        </div>
                        <div>
                          <p className="font-medium text-foreground">{v.itemName}</p>
                          <span className={cn(
                            'inline-block text-xs font-medium px-2 py-0.5 rounded-md border mt-1',
                            getStatusColor(v.status)
                          )}>
                            {v.status.charAt(0).toUpperCase() + v.status.slice(1)}
                          </span>
                        </div>
                      </div>
                      <div className="text-right">
                        <p className={cn(
                          'text-lg font-bold',
                          v.varianceValue < 0 ? 'text-error' : 'text-success'
                        )}>
                          {v.varianceValue >= 0 ? '+' : ''}{v.varianceValue.toFixed(2)}€
                        </p>
                      </div>
                    </div>

                    <div className="grid grid-cols-2 gap-3 text-sm">
                      <div className="p-2 rounded-lg bg-background">
                        <p className="text-xs text-foreground-dim mb-1">Storage</p>
                        <div className="flex items-center justify-between">
                          <span className="text-foreground-muted">
                            {v.expectedStorage} → {v.actualStorage}
                          </span>
                          <span className={cn(
                            'font-medium flex items-center gap-1',
                            v.varianceStorage < 0 ? 'text-error' : v.varianceStorage > 0 ? 'text-success' : 'text-foreground-muted'
                          )}>
                            {v.varianceStorage < 0 ? <TrendingDown size={12} /> : v.varianceStorage > 0 ? <TrendingUp size={12} /> : null}
                            {v.varianceStorage >= 0 ? '+' : ''}{v.varianceStorage}
                          </span>
                        </div>
                      </div>
                      <div className="p-2 rounded-lg bg-background">
                        <p className="text-xs text-foreground-dim mb-1">Bar</p>
                        <div className="flex items-center justify-between">
                          <span className="text-foreground-muted">
                            {v.expectedBar} → {v.actualBar}
                          </span>
                          <span className={cn(
                            'font-medium flex items-center gap-1',
                            v.varianceBar < 0 ? 'text-error' : v.varianceBar > 0 ? 'text-success' : 'text-foreground-muted'
                          )}>
                            {v.varianceBar < 0 ? <TrendingDown size={12} /> : v.varianceBar > 0 ? <TrendingUp size={12} /> : null}
                            {v.varianceBar >= 0 ? '+' : ''}{v.varianceBar}
                          </span>
                        </div>
                      </div>
                    </div>
                  </div>
                ))
              )}
            </div>

            {/* Footer */}
            <div className="flex gap-3 p-5 border-t border-white/5">
              <button onClick={onClose} className="btn-secondary flex-1">
                Close
              </button>
              <button onClick={handleStartCount} className="btn-primary flex-1">
                Start New Count
              </button>
            </div>
          </>
        ) : (
          <>
            {/* Count Mode */}
            <div className="p-5 border-b border-white/5">
              <div className="flex items-center gap-4 p-4 rounded-xl bg-warning/10 border border-warning/20">
                <AlertTriangle size={20} className="text-warning shrink-0" />
                <div>
                  <p className="font-medium text-foreground">Physical Count Mode</p>
                  <p className="text-sm text-foreground-muted">
                    Enter the actual counts. Leave blank to use current system count.
                  </p>
                </div>
              </div>
            </div>

            {/* Count Form */}
            <div className="flex-1 overflow-y-auto p-5 space-y-3">
              {inventory.map((item) => (
                <div key={item.id} className="p-4 rounded-xl bg-card border border-border">
                  <p className="font-medium text-foreground mb-3">{item.name}</p>
                  <div className="grid grid-cols-2 gap-4">
                    <div>
                      <label className="block text-xs text-foreground-muted mb-1">
                        Storage (System: {item.storageCount})
                      </label>
                      <input
                        type="number"
                        value={countData[item.id]?.storage || ''}
                        onChange={(e) => handleCountChange(item.id, 'storage', e.target.value)}
                        placeholder={item.storageCount.toString()}
                        className="w-full px-3 py-2 rounded-lg bg-background border border-border text-foreground placeholder:text-foreground-dim focus:border-primary-500 transition-colors"
                      />
                    </div>
                    <div>
                      <label className="block text-xs text-foreground-muted mb-1">
                        Bar (System: {item.barCount})
                      </label>
                      <input
                        type="number"
                        value={countData[item.id]?.bar || ''}
                        onChange={(e) => handleCountChange(item.id, 'bar', e.target.value)}
                        placeholder={item.barCount.toString()}
                        className="w-full px-3 py-2 rounded-lg bg-background border border-border text-foreground placeholder:text-foreground-dim focus:border-primary-500 transition-colors"
                      />
                    </div>
                  </div>
                </div>
              ))}
            </div>

            {/* Footer */}
            <div className="flex gap-3 p-5 border-t border-white/5">
              <button onClick={() => setMode('view')} className="btn-secondary flex-1">
                Cancel
              </button>
              <button onClick={handleSubmitCount} className="btn-primary flex-1">
                Submit Count
              </button>
            </div>
          </>
        )}
      </div>
    </div>
  );
}

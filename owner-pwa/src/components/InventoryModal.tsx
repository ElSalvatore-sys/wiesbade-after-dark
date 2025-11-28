import { useState, useEffect } from 'react';
import { cn } from '../lib/utils';
import { X, Barcode, ImagePlus, ScanLine } from 'lucide-react';
import type { InventoryItem, InventoryCategory } from '../types';

interface InventoryModalProps {
  isOpen: boolean;
  onClose: () => void;
  onSave: (item: Partial<InventoryItem>) => void;
  onOpenScanner: () => void;
  item?: InventoryItem | null;
  scannedBarcode?: string | null;
}

const categories: { value: InventoryCategory; label: string }[] = [
  { value: 'spirits', label: 'Spirits' },
  { value: 'beer', label: 'Beer' },
  { value: 'wine', label: 'Wine' },
  { value: 'mixers', label: 'Mixers' },
  { value: 'food', label: 'Food' },
  { value: 'supplies', label: 'Supplies' },
  { value: 'other', label: 'Other' },
];

const units = ['bottles', 'cans', 'kegs', 'cases', 'units', 'kg', 'liters'];

export function InventoryModal({
  isOpen,
  onClose,
  onSave,
  onOpenScanner,
  item,
  scannedBarcode,
}: InventoryModalProps) {
  const [formData, setFormData] = useState({
    name: '',
    category: 'spirits' as InventoryCategory,
    quantity: '',
    minStock: '',
    unit: 'bottles',
    costPrice: '',
    sellPrice: '',
    sku: '',
    supplier: '',
  });

  useEffect(() => {
    if (item) {
      setFormData({
        name: item.name,
        category: item.category,
        quantity: item.quantity.toString(),
        minStock: item.minStock.toString(),
        unit: item.unit,
        costPrice: item.costPrice?.toString() || '',
        sellPrice: item.sellPrice?.toString() || '',
        sku: item.sku || '',
        supplier: item.supplier || '',
      });
    } else {
      setFormData({
        name: '',
        category: 'spirits',
        quantity: '',
        minStock: '5',
        unit: 'bottles',
        costPrice: '',
        sellPrice: '',
        sku: scannedBarcode || '',
        supplier: '',
      });
    }
  }, [item, isOpen, scannedBarcode]);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    onSave({
      name: formData.name,
      category: formData.category,
      quantity: parseInt(formData.quantity) || 0,
      minStock: parseInt(formData.minStock) || 0,
      unit: formData.unit,
      costPrice: formData.costPrice ? parseFloat(formData.costPrice) : undefined,
      sellPrice: formData.sellPrice ? parseFloat(formData.sellPrice) : undefined,
      sku: formData.sku || undefined,
      supplier: formData.supplier || undefined,
    });
    onClose();
  };

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
      {/* Backdrop */}
      <div
        className="absolute inset-0 bg-black/60 backdrop-blur-sm"
        onClick={onClose}
      />

      {/* Modal */}
      <div className="relative w-full max-w-lg glass-card p-0 animate-scale-in max-h-[90vh] overflow-hidden flex flex-col">
        {/* Header */}
        <div className="flex items-center justify-between p-5 border-b border-white/5">
          <h2 className="text-xl font-bold text-foreground">
            {item ? 'Edit Item' : 'Add Item'}
          </h2>
          <button
            onClick={onClose}
            className="p-2 rounded-lg text-foreground-muted hover:text-foreground hover:bg-white/5 transition-colors"
          >
            <X size={20} />
          </button>
        </div>

        {/* Form */}
        <form onSubmit={handleSubmit} className="flex-1 overflow-y-auto p-5 space-y-5">
          {/* Image placeholder */}
          <div className="relative aspect-square w-32 mx-auto rounded-xl bg-card border-2 border-dashed border-border hover:border-primary-500/50 transition-colors cursor-pointer group">
            <div className="absolute inset-0 flex flex-col items-center justify-center gap-1">
              <ImagePlus size={24} className="text-foreground-dim group-hover:text-primary-400 transition-colors" />
              <p className="text-xs text-foreground-dim">Add photo</p>
            </div>
          </div>

          {/* Name */}
          <div>
            <label className="block text-sm font-medium text-foreground-secondary mb-2">
              Item Name *
            </label>
            <input
              type="text"
              value={formData.name}
              onChange={(e) => setFormData({ ...formData, name: e.target.value })}
              placeholder="e.g., Grey Goose Vodka 1L"
              required
              className="input-field"
            />
          </div>

          {/* Category */}
          <div>
            <label className="block text-sm font-medium text-foreground-secondary mb-2">
              Category
            </label>
            <div className="flex flex-wrap gap-2">
              {categories.map((cat) => (
                <button
                  key={cat.value}
                  type="button"
                  onClick={() => setFormData({ ...formData, category: cat.value })}
                  className={cn(
                    'px-3 py-1.5 rounded-lg text-sm font-medium transition-all',
                    formData.category === cat.value
                      ? 'bg-gradient-primary text-white shadow-glow-sm'
                      : 'bg-card border border-border text-foreground-secondary hover:border-border-light'
                  )}
                >
                  {cat.label}
                </button>
              ))}
            </div>
          </div>

          {/* Stock & Min Stock */}
          <div className="grid grid-cols-3 gap-3">
            <div>
              <label className="block text-sm font-medium text-foreground-secondary mb-2">
                Current Stock *
              </label>
              <input
                type="number"
                value={formData.quantity}
                onChange={(e) => setFormData({ ...formData, quantity: e.target.value })}
                placeholder="0"
                required
                className="input-field"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-foreground-secondary mb-2">
                Min Stock
              </label>
              <input
                type="number"
                value={formData.minStock}
                onChange={(e) => setFormData({ ...formData, minStock: e.target.value })}
                placeholder="5"
                className="input-field"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-foreground-secondary mb-2">
                Unit
              </label>
              <select
                value={formData.unit}
                onChange={(e) => setFormData({ ...formData, unit: e.target.value })}
                className="input-field"
              >
                {units.map((unit) => (
                  <option key={unit} value={unit}>{unit}</option>
                ))}
              </select>
            </div>
          </div>

          {/* Prices */}
          <div className="grid grid-cols-2 gap-3">
            <div>
              <label className="block text-sm font-medium text-foreground-secondary mb-2">
                Cost Price (€)
              </label>
              <input
                type="number"
                step="0.01"
                value={formData.costPrice}
                onChange={(e) => setFormData({ ...formData, costPrice: e.target.value })}
                placeholder="0.00"
                className="input-field"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-foreground-secondary mb-2">
                Sell Price (€)
              </label>
              <input
                type="number"
                step="0.01"
                value={formData.sellPrice}
                onChange={(e) => setFormData({ ...formData, sellPrice: e.target.value })}
                placeholder="0.00"
                className="input-field"
              />
            </div>
          </div>

          {/* Barcode */}
          <div>
            <label className="block text-sm font-medium text-foreground-secondary mb-2">
              <Barcode size={14} className="inline mr-1" />
              Barcode / SKU
            </label>
            <div className="flex gap-2">
              <input
                type="text"
                value={formData.sku}
                onChange={(e) => setFormData({ ...formData, sku: e.target.value })}
                placeholder="Scan or enter barcode"
                className="input-field flex-1"
              />
              <button
                type="button"
                onClick={onOpenScanner}
                className="px-4 rounded-xl bg-accent-purple/20 text-accent-purple hover:bg-accent-purple/30 transition-colors flex items-center gap-2"
              >
                <ScanLine size={18} />
                Scan
              </button>
            </div>
          </div>

          {/* Supplier */}
          <div>
            <label className="block text-sm font-medium text-foreground-secondary mb-2">
              Supplier
            </label>
            <input
              type="text"
              value={formData.supplier}
              onChange={(e) => setFormData({ ...formData, supplier: e.target.value })}
              placeholder="e.g., Metro, Getränke Hoffmann"
              className="input-field"
            />
          </div>
        </form>

        {/* Footer */}
        <div className="flex gap-3 p-5 border-t border-white/5">
          <button type="button" onClick={onClose} className="btn-secondary flex-1">
            Cancel
          </button>
          <button type="submit" onClick={handleSubmit} className="btn-primary flex-1">
            {item ? 'Save Changes' : 'Add Item'}
          </button>
        </div>
      </div>
    </div>
  );
}

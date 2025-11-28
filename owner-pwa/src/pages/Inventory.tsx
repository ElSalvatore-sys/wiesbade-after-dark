import { useState } from 'react';
import { cn } from '../lib/utils';
import {
  Search,
  Plus,
  ScanLine,
  Package,
  AlertTriangle,
  MoreVertical,
  Edit,
  Trash2,
  TrendingDown,
} from 'lucide-react';
import { BarcodeScanner } from '../components/BarcodeScanner';
import { InventoryModal } from '../components/InventoryModal';
import { StockUpdateModal } from '../components/StockUpdateModal';
import type { InventoryItem, InventoryCategory } from '../types';

// Mock inventory data
const mockInventory: InventoryItem[] = [
  {
    id: '1',
    venueId: '1',
    name: 'Grey Goose Vodka 1L',
    category: 'spirits',
    sku: '5010677850209',
    quantity: 8,
    unit: 'bottles',
    minStock: 5,
    costPrice: 28.50,
    sellPrice: 45.00,
    supplier: 'Metro',
    isLowStock: false,
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
  },
  {
    id: '2',
    venueId: '1',
    name: 'Hendricks Gin 700ml',
    category: 'spirits',
    sku: '5010327705118',
    quantity: 3,
    unit: 'bottles',
    minStock: 5,
    costPrice: 26.00,
    sellPrice: 42.00,
    supplier: 'Metro',
    isLowStock: true,
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
  },
  {
    id: '3',
    venueId: '1',
    name: 'Corona Extra',
    category: 'beer',
    sku: '7501064199493',
    quantity: 48,
    unit: 'bottles',
    minStock: 24,
    costPrice: 1.20,
    sellPrice: 4.50,
    supplier: 'Getränke Hoffmann',
    isLowStock: false,
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
  },
  {
    id: '4',
    venueId: '1',
    name: 'Red Bull 250ml',
    category: 'mixers',
    sku: '9002490100070',
    quantity: 12,
    unit: 'cans',
    minStock: 24,
    costPrice: 1.10,
    sellPrice: 4.00,
    supplier: 'Metro',
    isLowStock: true,
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
  },
  {
    id: '5',
    venueId: '1',
    name: 'Prosecco DOC',
    category: 'wine',
    sku: '8003625002512',
    quantity: 15,
    unit: 'bottles',
    minStock: 10,
    costPrice: 6.50,
    sellPrice: 24.00,
    supplier: 'Weinhandel Schmidt',
    isLowStock: false,
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
  },
  {
    id: '6',
    venueId: '1',
    name: 'Lime Juice 1L',
    category: 'mixers',
    sku: '5060429860012',
    quantity: 2,
    unit: 'bottles',
    minStock: 4,
    costPrice: 3.50,
    sellPrice: 0,
    supplier: 'Metro',
    isLowStock: true,
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
  },
];

type FilterCategory = 'all' | InventoryCategory;

const categoryConfig: Record<InventoryCategory, { label: string; color: string; bg: string }> = {
  spirits: { label: 'Spirits', color: 'text-accent-purple', bg: 'bg-accent-purple/15' },
  beer: { label: 'Beer', color: 'text-warning', bg: 'bg-warning/15' },
  wine: { label: 'Wine', color: 'text-error', bg: 'bg-error/15' },
  mixers: { label: 'Mixers', color: 'text-accent-cyan', bg: 'bg-accent-cyan/15' },
  food: { label: 'Food', color: 'text-success', bg: 'bg-success/15' },
  supplies: { label: 'Supplies', color: 'text-primary-400', bg: 'bg-primary-400/15' },
  other: { label: 'Other', color: 'text-foreground-muted', bg: 'bg-foreground-dim/15' },
};

export function Inventory() {
  const [inventory, setInventory] = useState<InventoryItem[]>(mockInventory);
  const [filter, setFilter] = useState<FilterCategory>('all');
  const [searchQuery, setSearchQuery] = useState('');
  const [showLowStockOnly, setShowLowStockOnly] = useState(false);
  const [isScannerOpen, setIsScannerOpen] = useState(false);
  const [isItemModalOpen, setIsItemModalOpen] = useState(false);
  const [isStockModalOpen, setIsStockModalOpen] = useState(false);
  const [selectedItem, setSelectedItem] = useState<InventoryItem | null>(null);
  const [scannedBarcode, setScannedBarcode] = useState<string | null>(null);
  const [menuOpen, setMenuOpen] = useState<string | null>(null);

  const filteredInventory = inventory.filter((item) => {
    const matchesFilter = filter === 'all' || item.category === filter;
    const matchesSearch = item.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
      item.sku?.includes(searchQuery);
    const matchesLowStock = !showLowStockOnly || item.quantity <= item.minStock;
    return matchesFilter && matchesSearch && matchesLowStock;
  });

  const lowStockCount = inventory.filter((i) => i.quantity <= i.minStock).length;

  const handleBarcodeScan = (barcode: string) => {
    setScannedBarcode(barcode);
    const existingItem = inventory.find((i) => i.sku === barcode);

    if (existingItem) {
      setSelectedItem(existingItem);
      setIsStockModalOpen(true);
    } else {
      setSelectedItem(null);
      setIsItemModalOpen(true);
    }
  };

  const handleAddItem = () => {
    setSelectedItem(null);
    setScannedBarcode(null);
    setIsItemModalOpen(true);
  };

  const handleEditItem = (item: InventoryItem) => {
    setSelectedItem(item);
    setScannedBarcode(null);
    setIsItemModalOpen(true);
    setMenuOpen(null);
  };

  const handleQuickStock = (item: InventoryItem) => {
    setSelectedItem(item);
    setIsStockModalOpen(true);
  };

  const handleSaveItem = (itemData: Partial<InventoryItem>) => {
    if (selectedItem) {
      setInventory(inventory.map((i) =>
        i.id === selectedItem.id ? { ...i, ...itemData } : i
      ));
    } else {
      const newItem: InventoryItem = {
        id: Date.now().toString(),
        venueId: '1',
        name: itemData.name || '',
        category: itemData.category || 'other',
        sku: itemData.sku,
        quantity: itemData.quantity || 0,
        unit: itemData.unit || 'units',
        minStock: itemData.minStock || 5,
        costPrice: itemData.costPrice,
        sellPrice: itemData.sellPrice,
        supplier: itemData.supplier,
        isLowStock: (itemData.quantity || 0) <= (itemData.minStock || 5),
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString(),
      };
      setInventory([...inventory, newItem]);
    }
  };

  const handleStockUpdate = (itemId: string, newQuantity: number, _reason: string) => {
    setInventory(inventory.map((i) =>
      i.id === itemId
        ? { ...i, quantity: newQuantity, isLowStock: newQuantity <= i.minStock }
        : i
    ));
  };

  const formatCurrency = (amount?: number) => {
    if (amount === undefined || amount === 0) return '-';
    return new Intl.NumberFormat('de-DE', { style: 'currency', currency: 'EUR' }).format(amount);
  };

  return (
    <div className="space-y-6 animate-fade-in">
      {/* Header Section */}
      <div className="flex flex-col gap-4 sm:flex-row sm:items-start sm:justify-between">
        <div>
          <h1 className="text-2xl font-bold text-foreground">Inventory</h1>
          <p className="text-foreground-secondary mt-1">
            Track and manage your stock levels
          </p>
        </div>

        {/* Action Buttons - Grouped */}
        <div className="flex items-center gap-2">
          <button
            onClick={() => setIsScannerOpen(true)}
            className="flex items-center gap-2 px-4 py-2.5 rounded-xl bg-card border border-border text-foreground-secondary hover:text-foreground hover:border-border-light transition-colors"
          >
            <ScanLine size={18} />
            <span className="hidden sm:inline">Scan</span>
          </button>
          <button
            onClick={handleAddItem}
            className="flex items-center gap-2 px-4 py-2.5 rounded-xl bg-gradient-primary text-white font-medium shadow-glow-sm hover:shadow-glow transition-all"
          >
            <Plus size={18} />
            <span>Add Item</span>
          </button>
        </div>
      </div>

      {/* Low Stock Alert Banner */}
      {lowStockCount > 0 && (
        <button
          onClick={() => setShowLowStockOnly(!showLowStockOnly)}
          className={cn(
            'w-full p-4 rounded-xl flex items-center gap-4 transition-all',
            showLowStockOnly
              ? 'bg-error/15 border border-error/30 shadow-[0_0_20px_rgba(239,68,68,0.1)]'
              : 'bg-warning/10 border border-warning/20 hover:bg-warning/15'
          )}
        >
          <div className={cn(
            'p-2 rounded-lg',
            showLowStockOnly ? 'bg-error/20' : 'bg-warning/20'
          )}>
            <AlertTriangle size={20} className={showLowStockOnly ? 'text-error' : 'text-warning'} />
          </div>
          <div className="flex-1 text-left">
            <p className="font-medium text-foreground">
              {lowStockCount} item{lowStockCount !== 1 ? 's' : ''} below minimum stock
            </p>
            <p className="text-sm text-foreground-muted">
              {showLowStockOnly ? 'Showing low stock items only' : 'Click to filter'}
            </p>
          </div>
          <span className={cn(
            'px-3 py-1 rounded-lg text-sm font-medium',
            showLowStockOnly
              ? 'bg-error/20 text-error'
              : 'bg-warning/20 text-warning'
          )}>
            {showLowStockOnly ? 'Clear' : 'Filter'}
          </span>
        </button>
      )}

      {/* Search Bar */}
      <div className="relative">
        <Search size={18} className="absolute left-4 top-1/2 -translate-y-1/2 text-foreground-dim" />
        <input
          type="text"
          value={searchQuery}
          onChange={(e) => setSearchQuery(e.target.value)}
          placeholder="Search by name or barcode..."
          className="w-full pl-12 pr-4 py-3 rounded-xl bg-card border border-border text-foreground placeholder:text-foreground-dim focus:border-primary-500 focus:ring-2 focus:ring-primary-500/20 transition-all"
        />
      </div>

      {/* Category Filter Chips */}
      <div className="flex gap-2 overflow-x-auto no-scrollbar -mx-4 px-4 sm:mx-0 sm:px-0">
        <button
          onClick={() => setFilter('all')}
          className={cn(
            'px-4 py-2 rounded-xl text-sm font-medium whitespace-nowrap transition-all shrink-0',
            filter === 'all'
              ? 'bg-gradient-primary text-white shadow-glow-sm'
              : 'bg-card border border-border text-foreground-secondary hover:border-border-light hover:text-foreground'
          )}
        >
          All Items
        </button>
        {(Object.keys(categoryConfig) as InventoryCategory[]).map((cat) => (
          <button
            key={cat}
            onClick={() => setFilter(cat)}
            className={cn(
              'px-4 py-2 rounded-xl text-sm font-medium whitespace-nowrap transition-all shrink-0',
              filter === cat
                ? 'bg-gradient-primary text-white shadow-glow-sm'
                : 'bg-card border border-border text-foreground-secondary hover:border-border-light hover:text-foreground'
            )}
          >
            {categoryConfig[cat].label}
          </button>
        ))}
      </div>

      {/* Inventory Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 2xl:grid-cols-4 gap-4">
        {filteredInventory.map((item) => {
          const isLow = item.quantity <= item.minStock;
          const stockPercent = item.minStock > 0
            ? Math.min((item.quantity / item.minStock) * 100, 100)
            : 100;

          return (
            <div
              key={item.id}
              className={cn(
                'glass-card p-5 flex flex-col hover:shadow-card-hover transition-all duration-300',
                isLow && 'ring-1 ring-error/30'
              )}
            >
              {/* Card Header */}
              <div className="flex items-start justify-between gap-3 mb-4">
                <div className="flex items-center gap-3 min-w-0">
                  <div className={cn(
                    'p-2.5 rounded-xl shrink-0',
                    categoryConfig[item.category].bg
                  )}>
                    <Package size={18} className={categoryConfig[item.category].color} />
                  </div>
                  <div className="min-w-0">
                    <h3 className="font-semibold text-foreground truncate leading-tight">
                      {item.name}
                    </h3>
                    <span className={cn(
                      'inline-block text-xs font-medium mt-1 px-2 py-0.5 rounded-md',
                      categoryConfig[item.category].bg,
                      categoryConfig[item.category].color
                    )}>
                      {categoryConfig[item.category].label}
                    </span>
                  </div>
                </div>

                {/* Menu */}
                <div className="relative shrink-0">
                  <button
                    onClick={() => setMenuOpen(menuOpen === item.id ? null : item.id)}
                    className="p-1.5 rounded-lg text-foreground-dim hover:text-foreground hover:bg-white/5 transition-colors"
                  >
                    <MoreVertical size={16} />
                  </button>
                  {menuOpen === item.id && (
                    <>
                      <div
                        className="fixed inset-0 z-10"
                        onClick={() => setMenuOpen(null)}
                      />
                      <div className="absolute right-0 top-full mt-1 w-32 glass-card py-1 z-20 animate-fade-in">
                        <button
                          onClick={() => handleEditItem(item)}
                          className="w-full flex items-center gap-2 px-3 py-2 text-sm text-foreground-secondary hover:text-foreground hover:bg-white/5 transition-colors"
                        >
                          <Edit size={14} />
                          Edit
                        </button>
                        <button className="w-full flex items-center gap-2 px-3 py-2 text-sm text-error hover:bg-error/10 transition-colors">
                          <Trash2 size={14} />
                          Delete
                        </button>
                      </div>
                    </>
                  )}
                </div>
              </div>

              {/* Stock Level */}
              <div className="mb-4">
                <div className="flex items-baseline justify-between mb-2">
                  <div className="flex items-baseline gap-1.5">
                    <span className={cn(
                      'text-2xl font-bold tabular-nums',
                      isLow ? 'text-error' : 'text-foreground'
                    )}>
                      {item.quantity}
                    </span>
                    <span className="text-sm text-foreground-muted">{item.unit}</span>
                  </div>
                  {isLow && (
                    <span className="flex items-center gap-1 text-xs font-medium text-error bg-error/10 px-2 py-1 rounded-md">
                      <TrendingDown size={12} />
                      Low Stock
                    </span>
                  )}
                </div>

                {/* Stock Bar - Fixed Width */}
                <div className="h-2 bg-card rounded-full overflow-hidden">
                  <div
                    className={cn(
                      'h-full rounded-full transition-all duration-500',
                      stockPercent <= 50 ? 'bg-error' :
                      stockPercent <= 100 ? 'bg-warning' : 'bg-success'
                    )}
                    style={{ width: `${stockPercent}%` }}
                  />
                </div>
                <p className="text-xs text-foreground-dim mt-1.5">
                  Min. stock: {item.minStock} {item.unit}
                </p>
              </div>

              {/* Price Row */}
              <div className="flex items-center justify-between py-3 border-t border-white/5">
                <div>
                  <p className="text-xs text-foreground-dim">Sell Price</p>
                  <p className="text-sm font-semibold text-foreground">
                    {formatCurrency(item.sellPrice)}
                  </p>
                </div>
                <div className="text-right">
                  <p className="text-xs text-foreground-dim">Cost</p>
                  <p className="text-sm text-foreground-muted">
                    {formatCurrency(item.costPrice)}
                  </p>
                </div>
              </div>

              {/* Update Button */}
              <button
                onClick={() => handleQuickStock(item)}
                className="w-full mt-3 py-2.5 rounded-xl text-sm font-medium bg-card border border-border text-foreground-secondary hover:border-primary-500/50 hover:text-foreground hover:bg-primary-500/5 transition-all"
              >
                Update Stock
              </button>
            </div>
          );
        })}
      </div>

      {/* Empty State */}
      {filteredInventory.length === 0 && (
        <div className="text-center py-16">
          <div className="w-16 h-16 mx-auto rounded-2xl bg-card flex items-center justify-center mb-4">
            <Package size={32} className="text-foreground-dim" />
          </div>
          <h3 className="text-lg font-semibold text-foreground">No items found</h3>
          <p className="text-foreground-muted mt-1 max-w-sm mx-auto">
            {searchQuery
              ? 'Try a different search term'
              : showLowStockOnly
              ? 'No items are currently low on stock'
              : 'Add your first inventory item to get started'}
          </p>
          {!searchQuery && !showLowStockOnly && (
            <button
              onClick={handleAddItem}
              className="mt-4 inline-flex items-center gap-2 px-4 py-2 rounded-xl bg-gradient-primary text-white font-medium"
            >
              <Plus size={18} />
              Add First Item
            </button>
          )}
        </div>
      )}

      {/* Modals */}
      <BarcodeScanner
        isOpen={isScannerOpen}
        onClose={() => setIsScannerOpen(false)}
        onScan={handleBarcodeScan}
      />

      <InventoryModal
        isOpen={isItemModalOpen}
        onClose={() => {
          setIsItemModalOpen(false);
          setScannedBarcode(null);
        }}
        onSave={handleSaveItem}
        onOpenScanner={() => {
          setIsItemModalOpen(false);
          setIsScannerOpen(true);
        }}
        item={selectedItem}
        scannedBarcode={scannedBarcode}
      />

      <StockUpdateModal
        isOpen={isStockModalOpen}
        onClose={() => setIsStockModalOpen(false)}
        onSave={handleStockUpdate}
        item={selectedItem}
      />
    </div>
  );
}

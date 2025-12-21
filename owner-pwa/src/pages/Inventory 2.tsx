import { useState } from 'react';
import { cn } from '../lib/utils';
import {
  Search,
  Plus,
  ScanLine,
  Package,
  AlertTriangle,
  ArrowRightLeft,
  Warehouse,
  Wine,
  TrendingDown,
  History,
  BarChart3,
  MoreVertical,
  Edit,
  Trash2,
} from 'lucide-react';
import { InventoryModal } from '../components/InventoryModal';
import { BarcodeScanner } from '../components/BarcodeScanner';
import { StockUpdateModal } from '../components/StockUpdateModal';
import { TransferModal } from '../components/TransferModal';
import { VarianceModal } from '../components/VarianceModal';
import type { InventoryItem as LegacyInventoryItem, InventoryCategory } from '../types';

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

const CATEGORIES = ['All', 'Spirits', 'Beer', 'Wine', 'Mixers', 'Soft Drinks', 'Food', 'Supplies'];

// Mock inventory data with dual locations
const mockInventory: InventoryItem[] = [
  { id: '1', name: 'Corona Extra', barcode: '7501064191091', category: 'Beer', storageCount: 48, barCount: 12, minStock: 24, price: 4.50, costPrice: 1.80, lastMovement: '2 hours ago' },
  { id: '2', name: 'Hendricks Gin', barcode: '5010327755014', category: 'Spirits', storageCount: 6, barCount: 2, minStock: 4, price: 12.00, costPrice: 28.00, lastMovement: '1 hour ago' },
  { id: '3', name: 'Grey Goose Vodka', barcode: '3700103831402', category: 'Spirits', storageCount: 8, barCount: 3, minStock: 4, price: 14.00, costPrice: 32.00, lastMovement: '3 hours ago' },
  { id: '4', name: 'Coca Cola', barcode: '5449000000996', category: 'Soft Drinks', storageCount: 120, barCount: 24, minStock: 48, price: 3.50, costPrice: 0.80, lastMovement: '30 min ago' },
  { id: '5', name: 'Red Bull', barcode: '9002490100070', category: 'Mixers', storageCount: 36, barCount: 18, minStock: 24, price: 4.00, costPrice: 1.50, lastMovement: '1 hour ago' },
  { id: '6', name: 'Prosecco DOC', barcode: '8002270018527', category: 'Wine', storageCount: 12, barCount: 4, minStock: 8, price: 8.00, costPrice: 6.50, lastMovement: '4 hours ago' },
  { id: '7', name: 'Jack Daniels', barcode: '5099873089798', category: 'Spirits', storageCount: 3, barCount: 1, minStock: 4, price: 10.00, costPrice: 22.00, lastMovement: '5 hours ago' },
  { id: '8', name: 'Tonic Water', barcode: '5000196004528', category: 'Mixers', storageCount: 60, barCount: 20, minStock: 30, price: 3.00, costPrice: 0.60, lastMovement: '2 hours ago' },
];

export function Inventory() {
  const [inventory, setInventory] = useState<InventoryItem[]>(mockInventory);
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedCategory, setSelectedCategory] = useState('All');
  const [viewMode, setViewMode] = useState<'all' | 'storage' | 'bar' | 'low'>('all');
  const [showScanner, setShowScanner] = useState(false);
  const [showAddModal, setShowAddModal] = useState(false);
  const [showTransferModal, setShowTransferModal] = useState(false);
  const [showVarianceModal, setShowVarianceModal] = useState(false);
  const [selectedItem, setSelectedItem] = useState<InventoryItem | null>(null);
  const [showStockUpdate, setShowStockUpdate] = useState(false);
  const [menuOpen, setMenuOpen] = useState<string | null>(null);

  // Filter inventory
  const filteredInventory = inventory.filter(item => {
    const matchesSearch = item.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
                         item.barcode.includes(searchQuery);
    const matchesCategory = selectedCategory === 'All' || item.category === selectedCategory;

    let matchesView = true;
    if (viewMode === 'low') {
      matchesView = (item.storageCount + item.barCount) < item.minStock;
    }

    return matchesSearch && matchesCategory && matchesView;
  });

  // Stats
  const totalItems = inventory.length;
  const lowStockItems = inventory.filter(i => (i.storageCount + i.barCount) < i.minStock).length;
  const storageValue = inventory.reduce((sum, i) => sum + (i.storageCount * i.costPrice), 0);
  const barValue = inventory.reduce((sum, i) => sum + (i.barCount * i.costPrice), 0);

  const handleScan = (barcode: string) => {
    const item = inventory.find(i => i.barcode === barcode);
    if (item) {
      setSelectedItem(item);
      setShowStockUpdate(true);
    } else {
      // New item - open add modal with barcode pre-filled
      setShowAddModal(true);
    }
    setShowScanner(false);
  };

  const handleQuickTransfer = (item: InventoryItem) => {
    setSelectedItem(item);
    setShowTransferModal(true);
  };

  // Convert to legacy format for existing modals
  const toLegacyItem = (item: InventoryItem): LegacyInventoryItem => ({
    id: item.id,
    venueId: '1',
    name: item.name,
    category: item.category.toLowerCase() as InventoryCategory,
    sku: item.barcode,
    quantity: item.storageCount + item.barCount,
    unit: 'units',
    minStock: item.minStock,
    costPrice: item.costPrice,
    sellPrice: item.price,
    isLowStock: (item.storageCount + item.barCount) < item.minStock,
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
  });

  const handleSaveItem = (itemData: Partial<LegacyInventoryItem>) => {
    const newItem: InventoryItem = {
      id: Date.now().toString(),
      name: itemData.name || '',
      barcode: itemData.sku || '',
      category: itemData.category || 'Supplies',
      storageCount: itemData.quantity || 0,
      barCount: 0,
      minStock: itemData.minStock || 5,
      price: itemData.sellPrice || 0,
      costPrice: itemData.costPrice || 0,
    };
    setInventory([...inventory, newItem]);
  };

  const handleStockUpdate = (itemId: string, newQuantity: number, _reason: string) => {
    const item = inventory.find(i => i.id === itemId);
    if (!item) return;

    const currentTotal = item.storageCount + item.barCount;
    const diff = newQuantity - currentTotal;

    setInventory(inventory.map(i =>
      i.id === itemId
        ? { ...i, storageCount: i.storageCount + diff, lastMovement: 'Just now' }
        : i
    ));
  };

  const handleTransfer = (itemId: string, quantity: number, from: 'storage' | 'bar', _to: 'storage' | 'bar') => {
    setInventory(inventory.map(i => {
      if (i.id === itemId) {
        return {
          ...i,
          storageCount: from === 'storage' ? i.storageCount - quantity : i.storageCount + quantity,
          barCount: from === 'bar' ? i.barCount - quantity : i.barCount + quantity,
          lastMovement: 'Just now',
        };
      }
      return i;
    }));
    setShowTransferModal(false);
    setSelectedItem(null);
  };

  const formatCurrency = (amount: number) => {
    return new Intl.NumberFormat('de-DE', { style: 'currency', currency: 'EUR' }).format(amount);
  };

  return (
    <div className="space-y-6 animate-fade-in">
      {/* Header */}
      <div className="flex flex-col lg:flex-row lg:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-foreground">Inventory</h1>
          <p className="text-foreground-secondary">Track stock across storage and bar</p>
        </div>
        <div className="flex flex-wrap gap-2">
          {/* PROMINENT SCAN BUTTON */}
          <button
            onClick={() => setShowScanner(true)}
            className="flex items-center gap-2 px-6 py-3 bg-gradient-primary text-white rounded-xl font-semibold hover:opacity-90 transition-all shadow-glow animate-pulse-slow"
          >
            <ScanLine size={20} />
            <span>Quick Scan</span>
          </button>
          <button
            onClick={() => {
              setSelectedItem(null);
              setShowTransferModal(true);
            }}
            className="flex items-center gap-2 px-4 py-3 bg-card text-foreground rounded-xl hover:bg-card/80 transition-all border border-border"
          >
            <ArrowRightLeft size={18} />
            <span className="hidden sm:inline">Transfer</span>
          </button>
          <button
            onClick={() => setShowVarianceModal(true)}
            className="flex items-center gap-2 px-4 py-3 bg-card text-foreground rounded-xl hover:bg-card/80 transition-all border border-border"
          >
            <BarChart3 size={18} />
            <span className="hidden sm:inline">Variance</span>
          </button>
          <button
            onClick={() => setShowAddModal(true)}
            className="flex items-center gap-2 px-4 py-3 bg-card text-foreground rounded-xl hover:bg-card/80 transition-all border border-border"
          >
            <Plus size={18} />
            <span className="hidden sm:inline">Add Item</span>
          </button>
        </div>
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
        <div className="glass-card p-4 rounded-xl">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-foreground-muted text-sm">Total Items</p>
              <p className="text-2xl font-bold text-foreground">{totalItems}</p>
            </div>
            <div className="w-10 h-10 rounded-lg bg-primary-500/20 flex items-center justify-center">
              <Package size={20} className="text-primary-400" />
            </div>
          </div>
        </div>
        <div className="glass-card p-4 rounded-xl">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-foreground-muted text-sm">Low Stock</p>
              <p className="text-2xl font-bold text-error">{lowStockItems}</p>
            </div>
            <div className="w-10 h-10 rounded-lg bg-error/20 flex items-center justify-center">
              <AlertTriangle size={20} className="text-error" />
            </div>
          </div>
        </div>
        <div className="glass-card p-4 rounded-xl">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-foreground-muted text-sm">Storage Value</p>
              <p className="text-2xl font-bold text-foreground">{formatCurrency(storageValue)}</p>
            </div>
            <div className="w-10 h-10 rounded-lg bg-accent-cyan/20 flex items-center justify-center">
              <Warehouse size={20} className="text-accent-cyan" />
            </div>
          </div>
        </div>
        <div className="glass-card p-4 rounded-xl">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-foreground-muted text-sm">Bar Value</p>
              <p className="text-2xl font-bold text-foreground">{formatCurrency(barValue)}</p>
            </div>
            <div className="w-10 h-10 rounded-lg bg-accent-purple/20 flex items-center justify-center">
              <Wine size={20} className="text-accent-purple" />
            </div>
          </div>
        </div>
      </div>

      {/* Location Tabs */}
      <div className="flex gap-2 p-1 bg-card rounded-xl w-fit border border-border">
        {[
          { id: 'all', label: 'All', icon: Package },
          { id: 'storage', label: 'Storage', icon: Warehouse },
          { id: 'bar', label: 'Bar', icon: Wine },
          { id: 'low', label: 'Low Stock', icon: AlertTriangle },
        ].map((tab) => (
          <button
            key={tab.id}
            onClick={() => setViewMode(tab.id as typeof viewMode)}
            className={cn(
              'flex items-center gap-2 px-4 py-2 rounded-lg transition-all',
              viewMode === tab.id
                ? 'bg-gradient-primary text-white shadow-glow-sm'
                : 'text-foreground-muted hover:text-foreground'
            )}
          >
            <tab.icon size={16} />
            <span>{tab.label}</span>
            {tab.id === 'low' && lowStockItems > 0 && (
              <span className="ml-1 px-1.5 py-0.5 text-xs bg-error rounded-full text-white">{lowStockItems}</span>
            )}
          </button>
        ))}
      </div>

      {/* Search & Filter */}
      <div className="flex flex-col sm:flex-row gap-4">
        <div className="relative flex-1">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-foreground-dim" size={18} />
          <input
            type="text"
            placeholder="Search by name or barcode..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="w-full pl-10 pr-4 py-3 bg-card border border-border rounded-xl text-foreground placeholder-foreground-dim focus:outline-none focus:border-primary-500 transition-colors"
          />
        </div>
        <div className="flex gap-2 overflow-x-auto no-scrollbar pb-2">
          {CATEGORIES.map((cat) => (
            <button
              key={cat}
              onClick={() => setSelectedCategory(cat)}
              className={cn(
                'px-4 py-2 rounded-lg whitespace-nowrap transition-all',
                selectedCategory === cat
                  ? 'bg-gradient-primary text-white shadow-glow-sm'
                  : 'bg-card text-foreground-muted hover:text-foreground border border-border'
              )}
            >
              {cat}
            </button>
          ))}
        </div>
      </div>

      {/* Inventory Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-4">
        {filteredInventory.map((item) => {
          const totalStock = item.storageCount + item.barCount;
          const isLowStock = totalStock < item.minStock;
          const stockPercent = Math.min((totalStock / item.minStock) * 100, 100);

          return (
            <div
              key={item.id}
              className={cn(
                'glass-card p-4 rounded-xl transition-all hover:border-primary-500/50',
                isLowStock && 'border-error/50 ring-1 ring-error/20'
              )}
            >
              {/* Header */}
              <div className="flex items-start justify-between mb-3">
                <div className="flex-1 min-w-0">
                  <h3 className="font-semibold text-foreground truncate">{item.name}</h3>
                  <p className="text-xs text-foreground-dim">{item.barcode}</p>
                </div>
                <div className="flex items-center gap-2">
                  <span className="px-2 py-1 text-xs rounded-lg bg-white/10 text-foreground-muted">
                    {item.category}
                  </span>
                  <div className="relative">
                    <button
                      onClick={() => setMenuOpen(menuOpen === item.id ? null : item.id)}
                      className="p-1.5 rounded-lg text-foreground-dim hover:text-foreground hover:bg-white/5 transition-colors"
                    >
                      <MoreVertical size={16} />
                    </button>
                    {menuOpen === item.id && (
                      <>
                        <div className="fixed inset-0 z-10" onClick={() => setMenuOpen(null)} />
                        <div className="absolute right-0 top-full mt-1 w-32 glass-card py-1 z-20 animate-fade-in">
                          <button className="w-full flex items-center gap-2 px-3 py-2 text-sm text-foreground-secondary hover:text-foreground hover:bg-white/5">
                            <Edit size={14} />
                            Edit
                          </button>
                          <button className="w-full flex items-center gap-2 px-3 py-2 text-sm text-error hover:bg-error/10">
                            <Trash2 size={14} />
                            Delete
                          </button>
                        </div>
                      </>
                    )}
                  </div>
                </div>
              </div>

              {/* Stock Levels */}
              <div className="grid grid-cols-2 gap-3 mb-3">
                <div className="p-2.5 rounded-lg bg-accent-cyan/10 border border-accent-cyan/20">
                  <div className="flex items-center gap-2 mb-1">
                    <Warehouse size={14} className="text-accent-cyan" />
                    <span className="text-xs text-accent-cyan">Storage</span>
                  </div>
                  <p className="text-xl font-bold text-foreground">{item.storageCount}</p>
                </div>
                <div className="p-2.5 rounded-lg bg-accent-purple/10 border border-accent-purple/20">
                  <div className="flex items-center gap-2 mb-1">
                    <Wine size={14} className="text-accent-purple" />
                    <span className="text-xs text-accent-purple">Bar</span>
                  </div>
                  <p className="text-xl font-bold text-foreground">{item.barCount}</p>
                </div>
              </div>

              {/* Stock Bar */}
              <div className="mb-3">
                <div className="flex justify-between text-xs mb-1">
                  <span className="text-foreground-muted">Total: {totalStock}</span>
                  <span className={isLowStock ? 'text-error' : 'text-foreground-muted'}>
                    Min: {item.minStock}
                  </span>
                </div>
                <div className="h-2 bg-white/10 rounded-full overflow-hidden">
                  <div
                    className={cn(
                      'h-full rounded-full transition-all',
                      stockPercent < 50 ? 'bg-error' : stockPercent < 75 ? 'bg-warning' : 'bg-success'
                    )}
                    style={{ width: `${stockPercent}%` }}
                  />
                </div>
              </div>

              {/* Low Stock Warning */}
              {isLowStock && (
                <div className="flex items-center gap-1 text-xs text-error mb-3">
                  <TrendingDown size={12} />
                  <span>Below minimum stock level</span>
                </div>
              )}

              {/* Last Movement */}
              {item.lastMovement && (
                <p className="text-xs text-foreground-dim mb-3 flex items-center gap-1">
                  <History size={12} />
                  Last movement: {item.lastMovement}
                </p>
              )}

              {/* Actions */}
              <div className="flex gap-2">
                <button
                  onClick={() => handleQuickTransfer(item)}
                  className="flex-1 flex items-center justify-center gap-1 px-3 py-2.5 bg-primary-500/20 text-primary-400 rounded-xl hover:bg-primary-500/30 transition-all text-sm font-medium"
                >
                  <ArrowRightLeft size={14} />
                  Transfer
                </button>
                <button
                  onClick={() => {
                    setSelectedItem(item);
                    setShowStockUpdate(true);
                  }}
                  className="flex-1 flex items-center justify-center gap-1 px-3 py-2.5 bg-white/10 text-foreground rounded-xl hover:bg-white/20 transition-all text-sm font-medium"
                >
                  <ScanLine size={14} />
                  Update
                </button>
              </div>
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
          <p className="text-foreground-muted mt-1">
            {searchQuery ? 'Try a different search term' : 'Add your first inventory item'}
          </p>
          {!searchQuery && (
            <button
              onClick={() => setShowAddModal(true)}
              className="mt-4 inline-flex items-center gap-2 px-4 py-2 rounded-xl bg-gradient-primary text-white font-medium"
            >
              <Plus size={18} />
              Add First Item
            </button>
          )}
        </div>
      )}

      {/* Modals */}
      {showScanner && (
        <BarcodeScanner
          isOpen={showScanner}
          onClose={() => setShowScanner(false)}
          onScan={handleScan}
        />
      )}

      {showAddModal && (
        <InventoryModal
          isOpen={showAddModal}
          onClose={() => setShowAddModal(false)}
          onSave={handleSaveItem}
          onOpenScanner={() => {
            setShowAddModal(false);
            setShowScanner(true);
          }}
          item={null}
          scannedBarcode={null}
        />
      )}

      {showStockUpdate && selectedItem && (
        <StockUpdateModal
          isOpen={showStockUpdate}
          onClose={() => {
            setShowStockUpdate(false);
            setSelectedItem(null);
          }}
          onSave={handleStockUpdate}
          item={toLegacyItem(selectedItem)}
        />
      )}

      {showTransferModal && (
        <TransferModal
          inventory={inventory}
          selectedItem={selectedItem}
          onClose={() => {
            setShowTransferModal(false);
            setSelectedItem(null);
          }}
          onTransfer={handleTransfer}
        />
      )}

      {showVarianceModal && (
        <VarianceModal
          inventory={inventory}
          onClose={() => setShowVarianceModal(false)}
        />
      )}
    </div>
  );
}

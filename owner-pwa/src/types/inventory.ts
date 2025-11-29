export type InventoryLocation = 'storage' | 'bar';
export type MovementType = 'transfer_out' | 'transfer_in' | 'sold' | 'waste' | 'adjustment' | 'restock';

export interface InventoryItem {
  id: string;
  name: string;
  barcode: string;
  category: string;
  unit: string; // 'bottle', 'case', 'kg', 'liter'
  storageCount: number;
  barCount: number;
  minStock: number;
  maxStock: number;
  price: number;
  costPrice: number;
  supplier?: string;
  imageUrl?: string;
  isActive: boolean;
  lastScannedAt?: string;
  createdAt: string;
  updatedAt: string;
}

export interface InventoryMovement {
  id: string;
  itemId: string;
  itemName: string;
  type: MovementType;
  quantity: number;
  fromLocation?: InventoryLocation;
  toLocation?: InventoryLocation;
  performedBy: string; // Employee ID
  performedByName: string;
  reason?: string;
  timestamp: string;
}

export interface InventoryVariance {
  id: string;
  itemId: string;
  itemName: string;
  date: string;
  expectedCount: number;
  actualCount: number;
  variance: number; // negative = missing
  varianceValue: number; // monetary value
  status: 'pending' | 'investigated' | 'resolved';
  notes?: string;
  investigatedBy?: string;
}

export interface DailyInventoryReport {
  date: string;
  totalTransfersOut: number;
  totalTransfersIn: number;
  totalSold: number;
  totalWaste: number;
  varianceItems: number;
  varianceValue: number;
}

export const MOVEMENT_TYPES: { value: MovementType; label: string; icon: string; color: string }[] = [
  { value: 'transfer_out', label: 'Transfer to Bar', icon: '📤', color: '#F59E0B' },
  { value: 'transfer_in', label: 'Received at Bar', icon: '📥', color: '#10B981' },
  { value: 'sold', label: 'Sold', icon: '💰', color: '#3B82F6' },
  { value: 'waste', label: 'Waste/Broken', icon: '🗑️', color: '#EF4444' },
  { value: 'adjustment', label: 'Adjustment', icon: '📝', color: '#6B7280' },
  { value: 'restock', label: 'Restock', icon: '📦', color: '#8B5CF6' },
];

export const INVENTORY_CATEGORIES = [
  { value: 'spirits', label: 'Spirits', icon: '🥃' },
  { value: 'beer', label: 'Beer', icon: '🍺' },
  { value: 'wine', label: 'Wine', icon: '🍷' },
  { value: 'mixers', label: 'Mixers', icon: '🧃' },
  { value: 'soft_drinks', label: 'Soft Drinks', icon: '🥤' },
  { value: 'garnishes', label: 'Garnishes', icon: '🍋' },
  { value: 'supplies', label: 'Supplies', icon: '📦' },
];

// Core types matching iOS app models

export interface User {
  id: string;
  email: string;
  firstName: string;
  lastName: string;
  phone?: string;
  avatarUrl?: string;
  role: 'owner' | 'manager' | 'staff';
  venueIds: string[];
  createdAt: string;
  updatedAt: string;
}

export interface Venue {
  id: string;
  name: string;
  description: string;
  address: string;
  city: string;
  postalCode: string;
  phone?: string;
  email?: string;
  website?: string;
  imageUrl?: string;
  logoUrl?: string;
  category: VenueCategory;
  openingHours: OpeningHours[];
  amenities: string[];
  rating: number;
  reviewCount: number;
  isActive: boolean;
  ownerId: string;
  createdAt: string;
  updatedAt: string;
}

export type VenueCategory = 'bar' | 'club' | 'lounge' | 'restaurant' | 'rooftop';

export interface OpeningHours {
  dayOfWeek: number; // 0 = Sunday, 6 = Saturday
  openTime: string;  // "18:00"
  closeTime: string; // "02:00"
  isClosed: boolean;
}

export interface Event {
  id: string;
  venueId: string;
  title: string;
  description: string;
  imageUrl?: string;
  startDate: string;
  endDate: string;
  ticketPrice?: number;
  maxCapacity?: number;
  currentAttendees: number;
  category: EventCategory;
  isActive: boolean;
  isFeatured: boolean;
  createdAt: string;
  updatedAt: string;
}

export type EventCategory = 'music' | 'party' | 'special' | 'private' | 'promotion';

export interface Booking {
  id: string;
  venueId: string;
  userId: string;
  eventId?: string;
  userName: string;
  userPhone: string;
  userEmail: string;
  date: string;
  time: string;
  partySize: number;
  tableNumber?: string;
  status: BookingStatus;
  notes?: string;
  totalAmount?: number;
  depositPaid?: number;
  createdAt: string;
  updatedAt: string;
}

export type BookingStatus = 'pending' | 'confirmed' | 'cancelled' | 'completed' | 'no_show';

export interface InventoryItem {
  id: string;
  venueId: string;
  name: string;
  category: InventoryCategory;
  sku?: string;
  quantity: number;
  unit: string;
  minStock: number;
  maxStock?: number;
  costPrice?: number;
  sellPrice?: number;
  supplier?: string;
  lastRestocked?: string;
  expiryDate?: string;
  isLowStock: boolean;
  createdAt: string;
  updatedAt: string;
}

export type InventoryCategory = 'spirits' | 'beer' | 'wine' | 'mixers' | 'food' | 'supplies' | 'other';

export interface DashboardStats {
  todaysBookings: number;
  activeEvents: number;
  lowStockItems: number;
  todaysRevenue: number;
  weeklyRevenue: number;
  monthlyRevenue: number;
  totalCustomers: number;
  averageRating: number;
}

export interface Notification {
  id: string;
  type: 'booking' | 'event' | 'inventory' | 'system';
  title: string;
  message: string;
  isRead: boolean;
  createdAt: string;
}

// Employee & Task types
export * from './employees';
export * from './tasks';

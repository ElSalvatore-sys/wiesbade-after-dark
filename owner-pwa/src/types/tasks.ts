export type TaskStatus = 'pending' | 'in_progress' | 'completed' | 'approved' | 'rejected';
export type TaskPriority = 'low' | 'medium' | 'high' | 'urgent';
export type TaskCategory = 'cleaning' | 'inventory' | 'bar' | 'kitchen' | 'general' | 'closing';

export interface Task {
  id: string;
  title: string;
  description?: string;
  category: TaskCategory;
  priority: TaskPriority;
  status: TaskStatus;
  assignedTo: string; // Employee ID
  assignedBy: string; // Employee ID (owner/manager)
  dueDate?: string;
  dueTime?: string;
  shiftId?: string;
  completedAt?: string;
  completedPhoto?: string; // URL to completion photo
  approvedAt?: string;
  approvedBy?: string;
  rejectionReason?: string;
  createdAt: string;
  updatedAt: string;
}

export interface TaskTemplate {
  id: string;
  title: string;
  description?: string;
  category: TaskCategory;
  priority: TaskPriority;
  estimatedMinutes: number;
  isRecurring: boolean;
  recurringDays?: number[]; // 0=Sunday, 1=Monday, etc.
}

export const TASK_CATEGORIES: { value: TaskCategory; label: string; icon: string; color: string }[] = [
  { value: 'cleaning', label: 'Cleaning', icon: '🧹', color: '#10B981' },
  { value: 'inventory', label: 'Inventory', icon: '📦', color: '#3B82F6' },
  { value: 'bar', label: 'Bar', icon: '🍸', color: '#8B5CF6' },
  { value: 'kitchen', label: 'Kitchen', icon: '🍳', color: '#F59E0B' },
  { value: 'general', label: 'General', icon: '📋', color: '#6B7280' },
  { value: 'closing', label: 'Closing', icon: '🔒', color: '#EF4444' },
];

export const TASK_PRIORITIES: { value: TaskPriority; label: string; color: string }[] = [
  { value: 'low', label: 'Low', color: '#6B7280' },
  { value: 'medium', label: 'Medium', color: '#3B82F6' },
  { value: 'high', label: 'High', color: '#F59E0B' },
  { value: 'urgent', label: 'Urgent', color: '#EF4444' },
];

export const TASK_STATUSES: { value: TaskStatus; label: string; color: string }[] = [
  { value: 'pending', label: 'Pending', color: '#6B7280' },
  { value: 'in_progress', label: 'In Progress', color: '#3B82F6' },
  { value: 'completed', label: 'Completed', color: '#10B981' },
  { value: 'approved', label: 'Approved', color: '#8B5CF6' },
  { value: 'rejected', label: 'Rejected', color: '#EF4444' },
];

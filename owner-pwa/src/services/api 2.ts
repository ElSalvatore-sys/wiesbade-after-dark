// API Configuration - connects to Railway backend
const API_BASE_URL = import.meta.env.VITE_API_URL || 'https://wiesbade-after-dark-production.up.railway.app';

interface ApiResponse<T> {
  data?: T;
  error?: string;
}

class ApiService {
  private baseUrl: string;
  private token: string | null = null;
  private venueId: string | null = null;

  constructor() {
    this.baseUrl = API_BASE_URL;
    this.token = localStorage.getItem('auth_token');
    this.venueId = localStorage.getItem('venue_id');
  }

  setToken(token: string) {
    this.token = token;
    localStorage.setItem('auth_token', token);
  }

  setVenueId(venueId: string) {
    this.venueId = venueId;
    localStorage.setItem('venue_id', venueId);
  }

  getVenueId() {
    return this.venueId;
  }

  clearAuth() {
    this.token = null;
    this.venueId = null;
    localStorage.removeItem('auth_token');
    localStorage.removeItem('venue_id');
  }

  private async request<T>(
    endpoint: string,
    options: RequestInit = {}
  ): Promise<ApiResponse<T>> {
    try {
      const headers: Record<string, string> = {
        'Content-Type': 'application/json',
      };

      if (this.token) {
        headers['Authorization'] = `Bearer ${this.token}`;
      }

      const response = await fetch(`${this.baseUrl}${endpoint}`, {
        ...options,
        headers,
      });

      if (!response.ok) {
        const error = await response.json().catch(() => ({ detail: 'Request failed' }));
        return { error: error.detail || `Error ${response.status}` };
      }

      const data = await response.json();
      return { data };
    } catch (error) {
      console.error('API Error:', error);
      return { error: 'Network error. Please try again.' };
    }
  }

  // ============ AUTH ============
  async login(email: string, password: string) {
    const result = await this.request<{ access_token: string; user: unknown }>('/api/auth/login', {
      method: 'POST',
      body: JSON.stringify({ email, password }),
    });
    if (result.data && typeof result.data === 'object' && 'access_token' in result.data) {
      this.setToken(result.data.access_token);
    }
    return result;
  }

  async register(email: string, password: string, name: string) {
    return this.request<unknown>('/api/auth/register-email', {
      method: 'POST',
      body: JSON.stringify({ email, password, name }),
    });
  }

  async getMe() {
    return this.request<unknown>('/api/users/me');
  }

  // ============ VENUES ============
  async getVenues() {
    return this.request<unknown[]>('/api/venues');
  }

  async getVenue(id: string) {
    return this.request<unknown>(`/api/venues/${id}`);
  }

  // ============ DASHBOARD (Admin) ============
  async getDashboard() {
    if (!this.venueId) return { error: 'No venue selected' };
    return this.request<unknown>(`/api/venues/${this.venueId}/dashboard`);
  }

  // ============ PRODUCTS (Inventory) ============
  async getProducts() {
    if (!this.venueId) return { error: 'No venue selected' };
    return this.request<unknown[]>(`/api/venues/${this.venueId}/products`);
  }

  async createProduct(data: unknown) {
    if (!this.venueId) return { error: 'No venue selected' };
    return this.request<unknown>(`/api/venues/${this.venueId}/products`, {
      method: 'POST',
      body: JSON.stringify(data),
    });
  }

  async updateProduct(productId: string, data: unknown) {
    if (!this.venueId) return { error: 'No venue selected' };
    return this.request<unknown>(`/api/venues/${this.venueId}/products/${productId}`, {
      method: 'PUT',
      body: JSON.stringify(data),
    });
  }

  async deleteProduct(productId: string) {
    if (!this.venueId) return { error: 'No venue selected' };
    return this.request<void>(`/api/venues/${this.venueId}/products/${productId}`, {
      method: 'DELETE',
    });
  }

  // ============ ANALYTICS ============
  async getAnalytics() {
    if (!this.venueId) return { error: 'No venue selected' };
    return this.request<unknown>(`/api/venues/${this.venueId}/analytics`);
  }

  // ============ CUSTOMERS ============
  async getCustomers() {
    if (!this.venueId) return { error: 'No venue selected' };
    return this.request<unknown[]>(`/api/venues/${this.venueId}/customers`);
  }

  // ============ TRANSACTIONS ============
  async getTransactions(limit?: number) {
    const query = limit ? `?limit=${limit}` : '';
    return this.request<unknown[]>(`/api/transactions${query}`);
  }

  // ============ SHIFTS ============
  async getEmployeePins() {
    if (!this.venueId) return { error: 'No venue selected' };
    return this.request<unknown[]>(`/api/venues/${this.venueId}/pins`);
  }

  async createEmployeePin(data: { employee_id: string; employee_name: string; pin: string }) {
    if (!this.venueId) return { error: 'No venue selected' };
    return this.request<unknown>(`/api/venues/${this.venueId}/pins`, {
      method: 'POST',
      body: JSON.stringify(data),
    });
  }

  async clockIn(data: { employee_id: string; pin: string; expected_hours?: number }) {
    if (!this.venueId) return { error: 'No venue selected' };
    return this.request<unknown>(`/api/venues/${this.venueId}/shifts/clock-in`, {
      method: 'POST',
      body: JSON.stringify(data),
    });
  }

  async clockOut(shiftId: string, data?: { notes?: string }) {
    if (!this.venueId) return { error: 'No venue selected' };
    return this.request<unknown>(`/api/venues/${this.venueId}/shifts/${shiftId}/clock-out`, {
      method: 'POST',
      body: JSON.stringify(data || {}),
    });
  }

  async startBreak(shiftId: string) {
    if (!this.venueId) return { error: 'No venue selected' };
    return this.request<unknown>(`/api/venues/${this.venueId}/shifts/${shiftId}/break/start`, {
      method: 'POST',
    });
  }

  async endBreak(shiftId: string) {
    if (!this.venueId) return { error: 'No venue selected' };
    return this.request<unknown>(`/api/venues/${this.venueId}/shifts/${shiftId}/break/end`, {
      method: 'POST',
    });
  }

  async getActiveShifts() {
    if (!this.venueId) return { error: 'No venue selected' };
    return this.request<unknown[]>(`/api/venues/${this.venueId}/shifts/active`);
  }

  async getShiftsSummary() {
    if (!this.venueId) return { error: 'No venue selected' };
    return this.request<unknown>(`/api/venues/${this.venueId}/shifts/summary`);
  }

  async getShiftsHistory(params?: { start_date?: string; end_date?: string; employee_id?: string }) {
    if (!this.venueId) return { error: 'No venue selected' };
    const queryParams = new URLSearchParams();
    if (params?.start_date) queryParams.append('start_date', params.start_date);
    if (params?.end_date) queryParams.append('end_date', params.end_date);
    if (params?.employee_id) queryParams.append('employee_id', params.employee_id);
    const query = queryParams.toString() ? `?${queryParams.toString()}` : '';
    return this.request<unknown[]>(`/api/venues/${this.venueId}/shifts/history${query}`);
  }

  // ============ TASKS ============
  async getTasks(params?: { status?: string; category?: string; assigned_to?: string; shift_id?: string }) {
    if (!this.venueId) return { error: 'No venue selected' };
    const queryParams = new URLSearchParams();
    if (params?.status) queryParams.append('status', params.status);
    if (params?.category) queryParams.append('category', params.category);
    if (params?.assigned_to) queryParams.append('assigned_to', params.assigned_to);
    if (params?.shift_id) queryParams.append('shift_id', params.shift_id);
    const query = queryParams.toString() ? `?${queryParams.toString()}` : '';
    return this.request<unknown[]>(`/api/venues/${this.venueId}/tasks${query}`);
  }

  async getTask(taskId: string) {
    if (!this.venueId) return { error: 'No venue selected' };
    return this.request<unknown>(`/api/venues/${this.venueId}/tasks/${taskId}`);
  }

  async createTask(data: {
    title: string;
    description?: string;
    category: string;
    priority: string;
    assigned_to?: string;
    assigned_to_name?: string;
    due_date?: string;
    due_time?: string;
    shift_id?: string;
  }) {
    if (!this.venueId) return { error: 'No venue selected' };
    return this.request<unknown>(`/api/venues/${this.venueId}/tasks`, {
      method: 'POST',
      body: JSON.stringify(data),
    });
  }

  async updateTask(taskId: string, data: Partial<{
    title: string;
    description: string;
    category: string;
    priority: string;
    status: string;
    assigned_to: string;
    assigned_to_name: string;
    due_date: string;
    due_time: string;
    shift_id: string;
  }>) {
    if (!this.venueId) return { error: 'No venue selected' };
    return this.request<unknown>(`/api/venues/${this.venueId}/tasks/${taskId}`, {
      method: 'PUT',
      body: JSON.stringify(data),
    });
  }

  async deleteTask(taskId: string) {
    if (!this.venueId) return { error: 'No venue selected' };
    return this.request<void>(`/api/venues/${this.venueId}/tasks/${taskId}`, {
      method: 'DELETE',
    });
  }

  async startTask(taskId: string) {
    if (!this.venueId) return { error: 'No venue selected' };
    return this.request<unknown>(`/api/venues/${this.venueId}/tasks/${taskId}/start`, {
      method: 'POST',
    });
  }

  async completeTask(taskId: string, data?: { completed_photo?: string }) {
    if (!this.venueId) return { error: 'No venue selected' };
    return this.request<unknown>(`/api/venues/${this.venueId}/tasks/${taskId}/complete`, {
      method: 'POST',
      body: JSON.stringify(data || {}),
    });
  }

  async approveTask(taskId: string) {
    if (!this.venueId) return { error: 'No venue selected' };
    return this.request<unknown>(`/api/venues/${this.venueId}/tasks/${taskId}/approve`, {
      method: 'POST',
    });
  }

  async rejectTask(taskId: string, data: { rejection_reason: string }) {
    if (!this.venueId) return { error: 'No venue selected' };
    return this.request<unknown>(`/api/venues/${this.venueId}/tasks/${taskId}/reject`, {
      method: 'POST',
      body: JSON.stringify(data),
    });
  }

  // Task Templates
  async getTaskTemplates() {
    if (!this.venueId) return { error: 'No venue selected' };
    return this.request<unknown[]>(`/api/venues/${this.venueId}/task-templates`);
  }

  async createTaskFromTemplate(templateId: string, data?: { assigned_to?: string; assigned_to_name?: string; due_date?: string; due_time?: string; shift_id?: string }) {
    if (!this.venueId) return { error: 'No venue selected' };
    return this.request<unknown>(`/api/venues/${this.venueId}/task-templates/${templateId}/create-task`, {
      method: 'POST',
      body: JSON.stringify(data || {}),
    });
  }

  // ============ EVENTS ============
  async getEvents(params?: { status?: string; is_featured?: boolean; limit?: number; offset?: number }) {
    const queryParams = new URLSearchParams();
    if (params?.status) queryParams.append('status', params.status);
    if (params?.is_featured !== undefined) queryParams.append('is_featured', String(params.is_featured));
    if (params?.limit) queryParams.append('limit', String(params.limit));
    if (params?.offset) queryParams.append('offset', String(params.offset));
    const query = queryParams.toString() ? `?${queryParams.toString()}` : '';
    return this.request<{ events: unknown[]; total: number }>(`/api/v1/events${query}`);
  }

  async getVenueEvents(params?: { include_past?: boolean; limit?: number; offset?: number }) {
    if (!this.venueId) return { error: 'No venue selected' };
    const queryParams = new URLSearchParams();
    if (params?.include_past) queryParams.append('include_past', 'true');
    if (params?.limit) queryParams.append('limit', String(params.limit));
    if (params?.offset) queryParams.append('offset', String(params.offset));
    const query = queryParams.toString() ? `?${queryParams.toString()}` : '';
    return this.request<{ events: unknown[]; total: number }>(`/api/v1/events/venue/${this.venueId}${query}`);
  }

  async getEvent(eventId: string) {
    return this.request<unknown>(`/api/v1/events/${eventId}`);
  }

  async createEvent(data: {
    title: string;
    description?: string;
    event_type: string;
    image_url?: string;
    start_time: string;
    end_time: string;
    max_capacity?: number;
    ticket_price?: number;
    is_free?: boolean;
    attendance_points?: number;
    bonus_points_multiplier?: number;
    is_featured?: boolean;
  }) {
    if (!this.venueId) return { error: 'No venue selected' };
    return this.request<unknown>(`/api/v1/events/venue/${this.venueId}`, {
      method: 'POST',
      body: JSON.stringify(data),
    });
  }

  async updateEvent(eventId: string, data: Partial<{
    title: string;
    description: string;
    event_type: string;
    image_url: string;
    start_time: string;
    end_time: string;
    max_capacity: number;
    ticket_price: number;
    is_free: boolean;
    attendance_points: number;
    bonus_points_multiplier: number;
    is_featured: boolean;
    status: string;
  }>) {
    return this.request<unknown>(`/api/v1/events/${eventId}`, {
      method: 'PUT',
      body: JSON.stringify(data),
    });
  }

  async deleteEvent(eventId: string) {
    return this.request<void>(`/api/v1/events/${eventId}`, {
      method: 'DELETE',
    });
  }

  async getTodayEvents(limit?: number) {
    const query = limit ? `?limit=${limit}` : '';
    return this.request<{ events: unknown[]; total: number }>(`/api/v1/events/today${query}`);
  }

  async getUpcomingEvents(days?: number, limit?: number) {
    const queryParams = new URLSearchParams();
    if (days) queryParams.append('days', String(days));
    if (limit) queryParams.append('limit', String(limit));
    const query = queryParams.toString() ? `?${queryParams.toString()}` : '';
    return this.request<{ events: unknown[]; total: number }>(`/api/v1/events/upcoming${query}`);
  }

  async getFeaturedEvents(limit?: number) {
    const query = limit ? `?limit=${limit}` : '';
    return this.request<{ events: unknown[]; total: number }>(`/api/v1/events/featured${query}`);
  }
}

export const api = new ApiService();
export default api;

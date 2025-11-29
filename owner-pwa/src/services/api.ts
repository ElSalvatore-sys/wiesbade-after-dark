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
}

export const api = new ApiService();
export default api;

import { useState, useEffect, useCallback } from 'react';
import {
  Plus,
  Phone,
  Mail,
  X,
  Edit2,
  Trash2,
  Shield,
  Key,
  Clock,
  ChevronDown,
  Check,
  Wine,
  Music,
  Sparkles,
  UserCog,
  Users,
  Loader2,
  AlertCircle,
  Download,
} from 'lucide-react';
import { cn } from '../lib/utils';
import { supabaseApi } from '../services/supabaseApi';
import type { Employee as DbEmployee } from '../lib/supabase';
import { exportEmployeesCSV } from '../lib/exportUtils';

// Granular roles for bar/club operations
export type EmployeeRole = 'owner' | 'manager' | 'bartender' | 'waiter' | 'security' | 'dj' | 'cleaning';

// UI-friendly employee interface (maps from database)
interface Employee {
  id: string;
  name: string;
  role: EmployeeRole;
  phone?: string;
  email?: string;
  pin?: string; // 4-digit PIN for clock-in
  hourlyRate?: number;
  isActive: boolean;
  createdAt: string;
}

// Map database employee to UI employee
const mapDbToUi = (db: DbEmployee): Employee => ({
  id: db.id,
  name: db.name,
  role: db.role,
  phone: db.phone || undefined,
  email: db.email || undefined,
  pin: db.pin_hash || undefined,
  hourlyRate: db.hourly_rate || undefined,
  isActive: db.is_active,
  createdAt: db.created_at,
});

// Role configuration with colors and icons
const roleConfig: Record<EmployeeRole, { color: string; icon: React.ReactNode; label: string; permissions: string[] }> = {
  owner: {
    color: 'bg-purple-500/20 text-purple-400 border-purple-500/30',
    icon: <UserCog size={14} />,
    label: 'Owner',
    permissions: ['All access', 'Financial reports', 'Employee management'],
  },
  manager: {
    color: 'bg-pink-500/20 text-pink-400 border-pink-500/30',
    icon: <Users size={14} />,
    label: 'Manager',
    permissions: ['Shift management', 'Task assignment', 'Inventory view', 'Analytics'],
  },
  bartender: {
    color: 'bg-amber-500/20 text-amber-400 border-amber-500/30',
    icon: <Wine size={14} />,
    label: 'Bartender',
    permissions: ['Clock in/out', 'Task completion', 'Inventory alerts'],
  },
  waiter: {
    color: 'bg-cyan-500/20 text-cyan-400 border-cyan-500/30',
    icon: <Sparkles size={14} />,
    label: 'Waiter',
    permissions: ['Clock in/out', 'Task completion'],
  },
  security: {
    color: 'bg-red-500/20 text-red-400 border-red-500/30',
    icon: <Shield size={14} />,
    label: 'Security',
    permissions: ['Clock in/out', 'Incident reports', 'Guest list'],
  },
  dj: {
    color: 'bg-violet-500/20 text-violet-400 border-violet-500/30',
    icon: <Music size={14} />,
    label: 'DJ',
    permissions: ['Clock in/out', 'Event schedule'],
  },
  cleaning: {
    color: 'bg-gray-500/20 text-gray-400 border-gray-500/30',
    icon: <Sparkles size={14} />,
    label: 'Cleaning',
    permissions: ['Clock in/out', 'Task completion'],
  },
};

const roleOrder: EmployeeRole[] = ['owner', 'manager', 'bartender', 'waiter', 'security', 'dj', 'cleaning'];

export function Employees() {
  const [employees, setEmployees] = useState<Employee[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [saving, setSaving] = useState(false);
  const [showModal, setShowModal] = useState(false);
  const [editingEmployee, setEditingEmployee] = useState<Employee | null>(null);
  const [showDeleteConfirm, setShowDeleteConfirm] = useState<string | null>(null);
  const [filterRole, setFilterRole] = useState<EmployeeRole | 'all'>('all');
  const [showInactive, setShowInactive] = useState(false);

  const [formData, setFormData] = useState({
    name: '',
    role: 'bartender' as EmployeeRole,
    phone: '',
    email: '',
    pin: '',
    hourlyRate: '',
  });

  // Fetch employees from Supabase
  const fetchEmployees = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const { data, error } = await supabaseApi.getEmployees(true); // Include inactive
      if (error) throw error;
      setEmployees((data || []).map(mapDbToUi));
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Fehler beim Laden der Mitarbeiter');
    } finally {
      setLoading(false);
    }
  }, []);

  // Load employees on mount
  useEffect(() => {
    fetchEmployees();
  }, [fetchEmployees]);

  // Reset form
  const resetForm = () => {
    setFormData({ name: '', role: 'bartender', phone: '', email: '', pin: '', hourlyRate: '' });
    setEditingEmployee(null);
  };

  // Open add modal
  const openAddModal = () => {
    resetForm();
    setShowModal(true);
  };

  // Open edit modal
  const openEditModal = (employee: Employee) => {
    setEditingEmployee(employee);
    setFormData({
      name: employee.name,
      role: employee.role,
      phone: employee.phone || '',
      email: employee.email || '',
      pin: employee.pin || '',
      hourlyRate: employee.hourlyRate?.toString() || '',
    });
    setShowModal(true);
  };

  // Save employee (add or update)
  const saveEmployee = async () => {
    if (!formData.name.trim()) return;
    setSaving(true);

    try {
      if (editingEmployee) {
        // Update existing
        const { error } = await supabaseApi.updateEmployee(editingEmployee.id, {
          name: formData.name,
          role: formData.role,
          phone: formData.phone || null,
          email: formData.email || null,
          pin_hash: formData.pin || null,
          hourly_rate: formData.hourlyRate ? parseFloat(formData.hourlyRate) : 0,
        });
        if (error) throw error;
      } else {
        // Add new
        const { error } = await supabaseApi.createEmployee({
          name: formData.name,
          role: formData.role,
          phone: formData.phone || null,
          email: formData.email || null,
          pin_hash: formData.pin || null,
          hourly_rate: formData.hourlyRate ? parseFloat(formData.hourlyRate) : 0,
        });
        if (error) throw error;
      }

      await fetchEmployees(); // Refresh list
      setShowModal(false);
      resetForm();
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Fehler beim Speichern');
    } finally {
      setSaving(false);
    }
  };

  // Toggle active status
  const toggleActive = async (id: string) => {
    const employee = employees.find(e => e.id === id);
    if (!employee) return;

    try {
      const { error } = await supabaseApi.updateEmployee(id, {
        is_active: !employee.isActive,
      });
      if (error) throw error;
      await fetchEmployees();
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Fehler beim Aktualisieren');
    }
  };

  // Delete employee (soft delete)
  const deleteEmployee = async (id: string) => {
    try {
      const { error } = await supabaseApi.deleteEmployee(id);
      if (error) throw error;
      await fetchEmployees();
      setShowDeleteConfirm(null);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Fehler beim Löschen');
    }
  };

  // Generate random PIN
  const generatePin = () => {
    const pin = Math.floor(1000 + Math.random() * 9000).toString();
    setFormData({ ...formData, pin });
  };

  // Filter employees
  const filteredEmployees = employees.filter(e => {
    if (!showInactive && !e.isActive) return false;
    if (filterRole !== 'all' && e.role !== filterRole) return false;
    return true;
  });

  // Group by role
  const groupedByRole = roleOrder.reduce((acc, role) => {
    acc[role] = filteredEmployees.filter(e => e.role === role);
    return acc;
  }, {} as Record<EmployeeRole, Employee[]>);

  // Stats
  const activeCount = employees.filter(e => e.isActive).length;
  const totalHourlyRate = employees.filter(e => e.isActive && e.hourlyRate).reduce((sum, e) => sum + (e.hourlyRate || 0), 0);

  // Export employees to CSV
  const handleExport = () => {
    const exportData = employees.map(emp => ({
      name: emp.name,
      role: emp.role,
      email: emp.email,
      phone: emp.phone,
      isActive: emp.isActive,
      startDate: emp.createdAt ? new Date(emp.createdAt).toLocaleDateString('de-DE') : undefined,
    }));
    exportEmployeesCSV(exportData, 'Das Wohnzimmer');
  };

  // Loading state
  if (loading) {
    return (
      <div className="max-w-2xl mx-auto flex items-center justify-center py-20">
        <Loader2 className="w-8 h-8 animate-spin text-primary-500" />
        <span className="ml-3 text-foreground-muted">Lade Mitarbeiter...</span>
      </div>
    );
  }

  return (
    <div className="max-w-2xl mx-auto space-y-6 animate-fade-in">
      {/* Error Banner */}
      {error && (
        <div className="flex items-center gap-3 p-4 bg-error/10 border border-error/30 rounded-xl text-error">
          <AlertCircle size={20} />
          <span>{error}</span>
          <button onClick={() => setError(null)} className="ml-auto p-1 hover:bg-error/20 rounded">
            <X size={16} />
          </button>
        </div>
      )}

      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-foreground">Team</h1>
          <p className="text-foreground-muted">{activeCount} aktive Mitarbeiter</p>
        </div>
        <div className="flex items-center gap-2">
          <button
            onClick={handleExport}
            className="flex items-center gap-2 px-4 py-2 bg-white/10 text-foreground rounded-xl hover:bg-white/20 transition-all border border-border"
            title="Export als CSV"
          >
            <Download size={18} />
            <span className="hidden sm:inline">Export</span>
          </button>
          <button
            onClick={openAddModal}
            className="flex items-center gap-2 px-4 py-2 bg-gradient-primary text-white rounded-xl hover:opacity-90 transition-all shadow-glow-sm"
          >
            <Plus size={18} />
            <span>Hinzufügen</span>
          </button>
        </div>
      </div>

      {/* Filters */}
      <div className="flex items-center gap-3 flex-wrap">
        <div className="relative">
          <select
            value={filterRole}
            onChange={(e) => setFilterRole(e.target.value as EmployeeRole | 'all')}
            className="appearance-none pl-4 pr-10 py-2 bg-white/5 border border-border rounded-xl text-foreground focus:outline-none focus:border-primary-500"
          >
            <option value="all">Alle Rollen</option>
            {roleOrder.map(role => (
              <option key={role} value={role}>{roleConfig[role].label}</option>
            ))}
          </select>
          <ChevronDown className="absolute right-3 top-1/2 -translate-y-1/2 text-foreground-muted pointer-events-none" size={16} />
        </div>

        <label className="flex items-center gap-2 text-sm text-foreground-muted cursor-pointer">
          <input
            type="checkbox"
            checked={showInactive}
            onChange={(e) => setShowInactive(e.target.checked)}
            className="w-4 h-4 rounded border-border bg-white/5 text-primary-500 focus:ring-primary-500"
          />
          Inaktive anzeigen
        </label>
      </div>

      {/* Summary Cards */}
      <div className="grid grid-cols-3 gap-3">
        <div className="glass-card p-3 rounded-xl text-center">
          <p className="text-2xl font-bold text-foreground">{activeCount}</p>
          <p className="text-xs text-foreground-muted">Aktiv</p>
        </div>
        <div className="glass-card p-3 rounded-xl text-center">
          <p className="text-2xl font-bold text-foreground">{employees.length - activeCount}</p>
          <p className="text-xs text-foreground-muted">Inaktiv</p>
        </div>
        <div className="glass-card p-3 rounded-xl text-center">
          <p className="text-2xl font-bold text-foreground">€{totalHourlyRate}</p>
          <p className="text-xs text-foreground-muted">Gesamt/Std</p>
        </div>
      </div>

      {/* Employee List by Role */}
      {roleOrder.map((role) => (
        groupedByRole[role].length > 0 && (
          <div key={role} className="space-y-2">
            <div className="flex items-center gap-2">
              <span className={cn('p-1.5 rounded-lg', roleConfig[role].color)}>
                {roleConfig[role].icon}
              </span>
              <h2 className="text-sm font-medium text-foreground-muted uppercase tracking-wide">
                {roleConfig[role].label}s ({groupedByRole[role].length})
              </h2>
            </div>

            <div className="space-y-2">
              {groupedByRole[role].map((employee) => (
                <div
                  key={employee.id}
                  className={cn(
                    'glass-card rounded-xl overflow-hidden transition-all',
                    !employee.isActive && 'opacity-60'
                  )}
                >
                  <div className="flex items-center gap-4 p-4">
                    {/* Avatar */}
                    <div className={cn(
                      'w-12 h-12 rounded-full flex items-center justify-center text-white font-bold text-lg',
                      employee.isActive
                        ? 'bg-gradient-to-br from-primary-500 to-accent-pink'
                        : 'bg-gray-500'
                    )}>
                      {employee.name.split(' ').map(n => n[0]).join('')}
                    </div>

                    {/* Info */}
                    <div className="flex-1 min-w-0">
                      <div className="flex items-center gap-2">
                        <p className="text-foreground font-medium">{employee.name}</p>
                        {!employee.isActive && (
                          <span className="text-xs bg-gray-500/20 text-gray-400 px-2 py-0.5 rounded">
                            Inactive
                          </span>
                        )}
                      </div>
                      <div className="flex items-center gap-2 mt-1">
                        <span className={cn('inline-flex items-center gap-1 text-xs font-medium px-2 py-0.5 rounded-md border', roleConfig[employee.role].color)}>
                          {roleConfig[employee.role].icon}
                          {roleConfig[employee.role].label}
                        </span>
                        {employee.hourlyRate && (
                          <span className="text-xs text-foreground-dim">
                            €{employee.hourlyRate}/hr
                          </span>
                        )}
                        {employee.pin && (
                          <span className="flex items-center gap-1 text-xs text-foreground-dim">
                            <Key size={10} />
                            PIN set
                          </span>
                        )}
                      </div>
                    </div>

                    {/* Actions */}
                    <div className="flex gap-1">
                      {employee.phone && (
                        <a
                          href={`tel:${employee.phone}`}
                          className="p-2 rounded-lg bg-success/20 text-success hover:bg-success/30 transition-all"
                        >
                          <Phone size={16} />
                        </a>
                      )}
                      {employee.email && (
                        <a
                          href={`mailto:${employee.email}`}
                          className="p-2 rounded-lg bg-primary-500/20 text-primary-400 hover:bg-primary-500/30 transition-all"
                        >
                          <Mail size={16} />
                        </a>
                      )}
                      <button
                        onClick={() => openEditModal(employee)}
                        className="p-2 rounded-lg bg-white/10 text-foreground-muted hover:text-foreground hover:bg-white/20 transition-all"
                      >
                        <Edit2 size={16} />
                      </button>
                      <button
                        onClick={() => setShowDeleteConfirm(employee.id)}
                        className="p-2 rounded-lg bg-error/10 text-error/70 hover:text-error hover:bg-error/20 transition-all"
                      >
                        <Trash2 size={16} />
                      </button>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </div>
        )
      ))}

      {/* Empty State */}
      {filteredEmployees.length === 0 && (
        <div className="text-center py-12 glass-card rounded-xl">
          <Users size={48} className="mx-auto mb-3 text-foreground-dim opacity-50" />
          <p className="text-foreground-muted">Keine Mitarbeiter gefunden</p>
          <p className="text-foreground-dim text-sm">Filter anpassen oder neue Mitarbeiter hinzufügen</p>
        </div>
      )}

      {/* Add/Edit Modal */}
      {showModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
          <div className="absolute inset-0 bg-black/60 backdrop-blur-sm" onClick={() => setShowModal(false)} />
          <div className="relative w-full max-w-md glass-card p-5 animate-scale-in space-y-4 max-h-[85vh] overflow-y-auto">
            <div className="flex items-center justify-between">
              <h2 className="text-lg font-bold text-foreground">
                {editingEmployee ? 'Mitarbeiter bearbeiten' : 'Neuer Mitarbeiter'}
              </h2>
              <button onClick={() => setShowModal(false)} className="p-1 text-foreground-muted hover:text-foreground">
                <X size={20} />
              </button>
            </div>

            {/* Name */}
            <div className="space-y-1">
              <label className="text-sm text-foreground-muted">Name *</label>
              <input
                type="text"
                placeholder="Full name"
                value={formData.name}
                onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                className="w-full px-4 py-3 bg-white/5 border border-border rounded-xl text-foreground placeholder-foreground-dim focus:outline-none focus:border-primary-500"
                autoFocus
              />
            </div>

            {/* Role */}
            <div className="space-y-1">
              <label className="text-sm text-foreground-muted">Role *</label>
              <div className="relative">
                <select
                  value={formData.role}
                  onChange={(e) => setFormData({ ...formData, role: e.target.value as EmployeeRole })}
                  className="w-full px-4 py-3 bg-white/5 border border-border rounded-xl text-foreground appearance-none focus:outline-none focus:border-primary-500"
                >
                  {roleOrder.map(role => (
                    <option key={role} value={role}>{roleConfig[role].label}</option>
                  ))}
                </select>
                <ChevronDown className="absolute right-3 top-1/2 -translate-y-1/2 text-foreground-muted pointer-events-none" size={20} />
              </div>
              {/* Role permissions hint */}
              <p className="text-xs text-foreground-dim mt-1">
                Permissions: {roleConfig[formData.role].permissions.join(', ')}
              </p>
            </div>

            {/* Phone */}
            <div className="space-y-1">
              <label className="text-sm text-foreground-muted">Phone</label>
              <input
                type="tel"
                placeholder="+49 611 1234567"
                value={formData.phone}
                onChange={(e) => setFormData({ ...formData, phone: e.target.value })}
                className="w-full px-4 py-3 bg-white/5 border border-border rounded-xl text-foreground placeholder-foreground-dim focus:outline-none focus:border-primary-500"
              />
            </div>

            {/* Email */}
            <div className="space-y-1">
              <label className="text-sm text-foreground-muted">Email</label>
              <input
                type="email"
                placeholder="email@example.com"
                value={formData.email}
                onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                className="w-full px-4 py-3 bg-white/5 border border-border rounded-xl text-foreground placeholder-foreground-dim focus:outline-none focus:border-primary-500"
              />
            </div>

            {/* PIN for clock-in */}
            {formData.role !== 'owner' && (
              <div className="space-y-1">
                <label className="text-sm text-foreground-muted flex items-center gap-2">
                  <Key size={14} />
                  Clock-in PIN
                </label>
                <div className="flex gap-2">
                  <input
                    type="text"
                    placeholder="4-digit PIN"
                    value={formData.pin}
                    onChange={(e) => {
                      const val = e.target.value.replace(/\D/g, '').slice(0, 4);
                      setFormData({ ...formData, pin: val });
                    }}
                    maxLength={4}
                    className="flex-1 px-4 py-3 bg-white/5 border border-border rounded-xl text-foreground placeholder-foreground-dim focus:outline-none focus:border-primary-500 font-mono text-center tracking-widest"
                  />
                  <button
                    type="button"
                    onClick={generatePin}
                    className="px-4 py-3 bg-white/10 text-foreground-muted rounded-xl hover:bg-white/20 transition-all"
                  >
                    Generate
                  </button>
                </div>
              </div>
            )}

            {/* Hourly Rate */}
            {formData.role !== 'owner' && formData.role !== 'dj' && (
              <div className="space-y-1">
                <label className="text-sm text-foreground-muted flex items-center gap-2">
                  <Clock size={14} />
                  Hourly Rate (€)
                </label>
                <input
                  type="number"
                  placeholder="15.00"
                  value={formData.hourlyRate}
                  onChange={(e) => setFormData({ ...formData, hourlyRate: e.target.value })}
                  min="0"
                  step="0.50"
                  className="w-full px-4 py-3 bg-white/5 border border-border rounded-xl text-foreground placeholder-foreground-dim focus:outline-none focus:border-primary-500"
                />
              </div>
            )}

            {/* Active Toggle for editing */}
            {editingEmployee && (
              <div className="flex items-center justify-between p-3 bg-white/5 rounded-xl">
                <span className="text-sm text-foreground-muted">Active Status</span>
                <button
                  type="button"
                  onClick={() => toggleActive(editingEmployee.id)}
                  className={cn(
                    'flex items-center gap-2 px-3 py-1.5 rounded-lg text-sm font-medium transition-all',
                    employees.find(e => e.id === editingEmployee.id)?.isActive
                      ? 'bg-success/20 text-success'
                      : 'bg-gray-500/20 text-gray-400'
                  )}
                >
                  <Check size={14} />
                  {employees.find(e => e.id === editingEmployee.id)?.isActive ? 'Active' : 'Inactive'}
                </button>
              </div>
            )}

            {/* Submit Buttons */}
            <div className="flex gap-2 pt-2">
              <button
                onClick={() => setShowModal(false)}
                disabled={saving}
                className="flex-1 px-4 py-3 bg-white/10 text-foreground rounded-xl hover:bg-white/20 transition-all disabled:opacity-50"
              >
                Abbrechen
              </button>
              <button
                onClick={saveEmployee}
                disabled={!formData.name.trim() || saving}
                className="flex-1 px-4 py-3 bg-gradient-primary text-white rounded-xl hover:opacity-90 transition-all disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center gap-2"
              >
                {saving && <Loader2 size={16} className="animate-spin" />}
                {editingEmployee ? 'Speichern' : 'Hinzufügen'}
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Delete Confirmation */}
      {showDeleteConfirm && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
          <div className="absolute inset-0 bg-black/60 backdrop-blur-sm" onClick={() => setShowDeleteConfirm(null)} />
          <div className="relative w-full max-w-sm glass-card p-5 animate-scale-in space-y-4">
            <h2 className="text-lg font-bold text-foreground">Mitarbeiter deaktivieren?</h2>
            <p className="text-foreground-muted">
              Der Mitarbeiter wird als inaktiv markiert. Die Schichthistorie bleibt erhalten.
            </p>
            <div className="flex gap-2 pt-2">
              <button
                onClick={() => setShowDeleteConfirm(null)}
                className="flex-1 px-4 py-3 bg-white/10 text-foreground rounded-xl hover:bg-white/20 transition-all"
              >
                Abbrechen
              </button>
              <button
                onClick={() => deleteEmployee(showDeleteConfirm)}
                className="flex-1 px-4 py-3 bg-error text-white rounded-xl hover:opacity-90 transition-all"
              >
                Deaktivieren
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

export default Employees;

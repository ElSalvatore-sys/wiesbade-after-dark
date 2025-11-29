import { useState } from 'react';
import { cn } from '../lib/utils';
import {
  Users,
  Plus,
  Search,
  MoreVertical,
  Mail,
  Phone,
  Shield,
  Clock,
  Trash2,
  Edit,
  UserCheck,
  UserX,
  X,
} from 'lucide-react';
import type { Employee, EmployeeRole } from '../types';
import { ROLE_ACCESS } from '../types';

// Mock employees
const mockEmployees: Employee[] = [
  {
    id: '1',
    email: 'owner@daswohnzimmer.de',
    firstName: 'Max',
    lastName: 'Müller',
    role: 'owner',
    phone: '+49 611 1234567',
    isActive: true,
    createdAt: '2024-01-01T00:00:00Z',
    lastLogin: '2024-11-29T10:30:00Z',
  },
  {
    id: '2',
    email: 'sarah@daswohnzimmer.de',
    firstName: 'Sarah',
    lastName: 'Schmidt',
    role: 'manager',
    phone: '+49 611 2345678',
    isActive: true,
    createdAt: '2024-03-15T00:00:00Z',
    lastLogin: '2024-11-29T08:15:00Z',
  },
  {
    id: '3',
    email: 'tom@daswohnzimmer.de',
    firstName: 'Tom',
    lastName: 'Weber',
    role: 'bartender',
    phone: '+49 611 3456789',
    isActive: true,
    createdAt: '2024-06-01T00:00:00Z',
    lastLogin: '2024-11-28T22:00:00Z',
  },
  {
    id: '4',
    email: 'lisa@daswohnzimmer.de',
    firstName: 'Lisa',
    lastName: 'Fischer',
    role: 'inventory',
    phone: '+49 611 4567890',
    isActive: true,
    createdAt: '2024-08-10T00:00:00Z',
    lastLogin: '2024-11-29T09:00:00Z',
  },
  {
    id: '5',
    email: 'hans@daswohnzimmer.de',
    firstName: 'Hans',
    lastName: 'Becker',
    role: 'cleaning',
    isActive: false,
    createdAt: '2024-09-01T00:00:00Z',
    lastLogin: '2024-11-15T06:00:00Z',
  },
];

const roleColors: Record<EmployeeRole, string> = {
  owner: 'bg-accent-purple/20 text-accent-purple border-accent-purple/30',
  manager: 'bg-accent-pink/20 text-accent-pink border-accent-pink/30',
  bartender: 'bg-accent-cyan/20 text-accent-cyan border-accent-cyan/30',
  inventory: 'bg-warning/20 text-warning border-warning/30',
  cleaning: 'bg-success/20 text-success border-success/30',
};

export function Employees() {
  const [employees, setEmployees] = useState<Employee[]>(mockEmployees);
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedRole, setSelectedRole] = useState<EmployeeRole | 'all'>('all');
  const [showAddModal, setShowAddModal] = useState(false);
  const [editingEmployee, setEditingEmployee] = useState<Employee | null>(null);

  const filteredEmployees = employees.filter((emp) => {
    const matchesSearch =
      emp.firstName.toLowerCase().includes(searchQuery.toLowerCase()) ||
      emp.lastName.toLowerCase().includes(searchQuery.toLowerCase()) ||
      emp.email.toLowerCase().includes(searchQuery.toLowerCase());
    const matchesRole = selectedRole === 'all' || emp.role === selectedRole;
    return matchesSearch && matchesRole;
  });

  const activeCount = employees.filter((e) => e.isActive).length;

  const toggleEmployeeStatus = (id: string) => {
    setEmployees((prev) =>
      prev.map((emp) =>
        emp.id === id ? { ...emp, isActive: !emp.isActive } : emp
      )
    );
  };

  const deleteEmployee = (id: string) => {
    if (confirm('Are you sure you want to remove this employee?')) {
      setEmployees((prev) => prev.filter((emp) => emp.id !== id));
    }
  };

  const formatLastLogin = (dateStr?: string) => {
    if (!dateStr) return 'Never';
    const date = new Date(dateStr);
    const now = new Date();
    const diffMs = now.getTime() - date.getTime();
    const diffHours = Math.floor(diffMs / (1000 * 60 * 60));
    const diffDays = Math.floor(diffHours / 24);

    if (diffHours < 1) return 'Just now';
    if (diffHours < 24) return `${diffHours}h ago`;
    if (diffDays < 7) return `${diffDays}d ago`;
    return date.toLocaleDateString('de-DE');
  };

  return (
    <div className="space-y-6 animate-fade-in">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-foreground">Employees</h1>
          <p className="text-foreground-secondary">
            {activeCount} active of {employees.length} total
          </p>
        </div>
        <button
          onClick={() => setShowAddModal(true)}
          className="btn-primary flex items-center gap-2"
        >
          <Plus size={20} />
          Add Employee
        </button>
      </div>

      {/* Filters */}
      <div className="flex flex-col sm:flex-row gap-4">
        {/* Search */}
        <div className="relative flex-1">
          <Search
            className="absolute left-3 top-1/2 -translate-y-1/2 text-foreground-secondary"
            size={20}
          />
          <input
            type="text"
            placeholder="Search employees..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="w-full pl-10 pr-4 py-2.5 bg-background-elevated border border-border rounded-lg text-foreground placeholder:text-foreground-secondary focus:outline-none focus:ring-2 focus:ring-primary/50"
          />
        </div>

        {/* Role Filter */}
        <select
          value={selectedRole}
          onChange={(e) => setSelectedRole(e.target.value as EmployeeRole | 'all')}
          className="px-4 py-2.5 bg-background-elevated border border-border rounded-lg text-foreground focus:outline-none focus:ring-2 focus:ring-primary/50"
        >
          <option value="all">All Roles</option>
          {Object.values(ROLE_ACCESS).map((role) => (
            <option key={role.role} value={role.role}>
              {role.label}
            </option>
          ))}
        </select>
      </div>

      {/* Employee Cards */}
      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
        {filteredEmployees.map((employee) => (
          <EmployeeCard
            key={employee.id}
            employee={employee}
            onToggleStatus={() => toggleEmployeeStatus(employee.id)}
            onEdit={() => setEditingEmployee(employee)}
            onDelete={() => deleteEmployee(employee.id)}
            formatLastLogin={formatLastLogin}
          />
        ))}
      </div>

      {filteredEmployees.length === 0 && (
        <div className="text-center py-12 text-foreground-secondary">
          <Users size={48} className="mx-auto mb-4 opacity-50" />
          <p>No employees found</p>
        </div>
      )}

      {/* Add/Edit Modal */}
      {(showAddModal || editingEmployee) && (
        <EmployeeModal
          employee={editingEmployee}
          onClose={() => {
            setShowAddModal(false);
            setEditingEmployee(null);
          }}
          onSave={(emp) => {
            if (editingEmployee) {
              setEmployees((prev) =>
                prev.map((e) => (e.id === emp.id ? emp : e))
              );
            } else {
              setEmployees((prev) => [...prev, { ...emp, id: Date.now().toString() }]);
            }
            setShowAddModal(false);
            setEditingEmployee(null);
          }}
        />
      )}
    </div>
  );
}

interface EmployeeCardProps {
  employee: Employee;
  onToggleStatus: () => void;
  onEdit: () => void;
  onDelete: () => void;
  formatLastLogin: (dateStr?: string) => string;
}

function EmployeeCard({
  employee,
  onToggleStatus,
  onEdit,
  onDelete,
  formatLastLogin,
}: EmployeeCardProps) {
  const [showMenu, setShowMenu] = useState(false);
  const roleInfo = ROLE_ACCESS[employee.role];

  return (
    <div
      className={cn(
        'relative p-4 bg-background-elevated border rounded-xl transition-all',
        employee.isActive ? 'border-border' : 'border-border/50 opacity-60'
      )}
    >
      {/* Status Indicator */}
      <div
        className={cn(
          'absolute top-4 right-4 w-2 h-2 rounded-full',
          employee.isActive ? 'bg-success' : 'bg-foreground-secondary'
        )}
      />

      {/* Avatar & Name */}
      <div className="flex items-center gap-3 mb-4">
        <div className="w-12 h-12 rounded-full bg-gradient-to-br from-accent-purple to-accent-pink flex items-center justify-center text-white font-bold">
          {employee.firstName[0]}
          {employee.lastName[0]}
        </div>
        <div className="flex-1 min-w-0">
          <h3 className="font-semibold text-foreground truncate">
            {employee.firstName} {employee.lastName}
          </h3>
          <span
            className={cn(
              'inline-flex px-2 py-0.5 text-xs font-medium rounded-full border',
              roleColors[employee.role]
            )}
          >
            {roleInfo.label}
          </span>
        </div>

        {/* Menu */}
        <div className="relative">
          <button
            onClick={() => setShowMenu(!showMenu)}
            className="p-1.5 rounded-lg hover:bg-background-card text-foreground-secondary"
          >
            <MoreVertical size={18} />
          </button>
          {showMenu && (
            <>
              <div
                className="fixed inset-0 z-10"
                onClick={() => setShowMenu(false)}
              />
              <div className="absolute right-0 top-full mt-1 w-40 bg-background-card border border-border rounded-lg shadow-xl z-20 py-1">
                <button
                  onClick={() => {
                    onEdit();
                    setShowMenu(false);
                  }}
                  className="w-full px-3 py-2 text-left text-sm text-foreground hover:bg-background-elevated flex items-center gap-2"
                >
                  <Edit size={14} />
                  Edit
                </button>
                <button
                  onClick={() => {
                    onToggleStatus();
                    setShowMenu(false);
                  }}
                  className="w-full px-3 py-2 text-left text-sm text-foreground hover:bg-background-elevated flex items-center gap-2"
                >
                  {employee.isActive ? (
                    <>
                      <UserX size={14} />
                      Deactivate
                    </>
                  ) : (
                    <>
                      <UserCheck size={14} />
                      Activate
                    </>
                  )}
                </button>
                {employee.role !== 'owner' && (
                  <button
                    onClick={() => {
                      onDelete();
                      setShowMenu(false);
                    }}
                    className="w-full px-3 py-2 text-left text-sm text-error hover:bg-background-elevated flex items-center gap-2"
                  >
                    <Trash2 size={14} />
                    Remove
                  </button>
                )}
              </div>
            </>
          )}
        </div>
      </div>

      {/* Contact Info */}
      <div className="space-y-2 text-sm">
        <div className="flex items-center gap-2 text-foreground-secondary">
          <Mail size={14} />
          <span className="truncate">{employee.email}</span>
        </div>
        {employee.phone && (
          <div className="flex items-center gap-2 text-foreground-secondary">
            <Phone size={14} />
            <span>{employee.phone}</span>
          </div>
        )}
        <div className="flex items-center gap-2 text-foreground-secondary">
          <Clock size={14} />
          <span>Last login: {formatLastLogin(employee.lastLogin)}</span>
        </div>
      </div>

      {/* Permissions Preview */}
      <div className="mt-4 pt-4 border-t border-border">
        <div className="flex items-center gap-1.5 text-xs text-foreground-secondary">
          <Shield size={12} />
          <span>Access:</span>
          <span className="text-foreground">
            {Object.entries(roleInfo.permissions)
              .filter(([, v]) => v)
              .map(([k]) => k.charAt(0).toUpperCase() + k.slice(1))
              .join(', ')}
          </span>
        </div>
      </div>
    </div>
  );
}

interface EmployeeModalProps {
  employee: Employee | null;
  onClose: () => void;
  onSave: (employee: Employee) => void;
}

function EmployeeModal({ employee, onClose, onSave }: EmployeeModalProps) {
  const [form, setForm] = useState<Partial<Employee>>(
    employee || {
      firstName: '',
      lastName: '',
      email: '',
      phone: '',
      role: 'bartender',
      isActive: true,
      createdAt: new Date().toISOString(),
    }
  );

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    onSave(form as Employee);
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
      <div className="fixed inset-0 bg-black/60" onClick={onClose} />
      <div className="relative bg-background-card border border-border rounded-2xl w-full max-w-md p-6 animate-scale-up">
        <button
          onClick={onClose}
          className="absolute top-4 right-4 p-1.5 rounded-lg hover:bg-background-elevated text-foreground-secondary"
        >
          <X size={20} />
        </button>

        <h2 className="text-xl font-bold text-foreground mb-6">
          {employee ? 'Edit Employee' : 'Add Employee'}
        </h2>

        <form onSubmit={handleSubmit} className="space-y-4">
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-foreground-secondary mb-1">
                First Name
              </label>
              <input
                type="text"
                value={form.firstName || ''}
                onChange={(e) => setForm({ ...form, firstName: e.target.value })}
                className="w-full px-3 py-2 bg-background-elevated border border-border rounded-lg text-foreground"
                required
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-foreground-secondary mb-1">
                Last Name
              </label>
              <input
                type="text"
                value={form.lastName || ''}
                onChange={(e) => setForm({ ...form, lastName: e.target.value })}
                className="w-full px-3 py-2 bg-background-elevated border border-border rounded-lg text-foreground"
                required
              />
            </div>
          </div>

          <div>
            <label className="block text-sm font-medium text-foreground-secondary mb-1">
              Email
            </label>
            <input
              type="email"
              value={form.email || ''}
              onChange={(e) => setForm({ ...form, email: e.target.value })}
              className="w-full px-3 py-2 bg-background-elevated border border-border rounded-lg text-foreground"
              required
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-foreground-secondary mb-1">
              Phone
            </label>
            <input
              type="tel"
              value={form.phone || ''}
              onChange={(e) => setForm({ ...form, phone: e.target.value })}
              className="w-full px-3 py-2 bg-background-elevated border border-border rounded-lg text-foreground"
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-foreground-secondary mb-1">
              Role
            </label>
            <select
              value={form.role || 'bartender'}
              onChange={(e) => setForm({ ...form, role: e.target.value as EmployeeRole })}
              className="w-full px-3 py-2 bg-background-elevated border border-border rounded-lg text-foreground"
              disabled={employee?.role === 'owner'}
            >
              {Object.values(ROLE_ACCESS).map((role) => (
                <option key={role.role} value={role.role}>
                  {role.label} - {role.description}
                </option>
              ))}
            </select>
          </div>

          {/* Role Permissions Preview */}
          {form.role && (
            <div className="p-3 bg-background-elevated rounded-lg">
              <p className="text-xs font-medium text-foreground-secondary mb-2">
                Permissions for {ROLE_ACCESS[form.role].label}:
              </p>
              <div className="flex flex-wrap gap-1">
                {Object.entries(ROLE_ACCESS[form.role].permissions).map(
                  ([perm, allowed]) => (
                    <span
                      key={perm}
                      className={cn(
                        'px-2 py-0.5 text-xs rounded',
                        allowed
                          ? 'bg-success/20 text-success'
                          : 'bg-foreground-secondary/20 text-foreground-secondary'
                      )}
                    >
                      {perm}
                    </span>
                  )
                )}
              </div>
            </div>
          )}

          <div className="flex gap-3 pt-4">
            <button
              type="button"
              onClick={onClose}
              className="flex-1 py-2.5 border border-border rounded-lg text-foreground hover:bg-background-elevated"
            >
              Cancel
            </button>
            <button type="submit" className="flex-1 btn-primary">
              {employee ? 'Save Changes' : 'Add Employee'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}

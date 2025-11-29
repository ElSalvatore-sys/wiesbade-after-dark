// Employee roles with access levels
export type EmployeeRole = 'owner' | 'manager' | 'bartender' | 'inventory' | 'cleaning';

export interface Employee {
  id: string;
  email: string;
  firstName: string;
  lastName: string;
  role: EmployeeRole;
  phone?: string;
  avatar?: string;
  isActive: boolean;
  createdAt: string;
  lastLogin?: string;
}

export interface EmployeeAccess {
  role: EmployeeRole;
  label: string;
  description: string;
  permissions: {
    dashboard: boolean;
    events: boolean;
    bookings: boolean;
    inventory: boolean;
    employees: boolean;
    tasks: boolean;
    reports: boolean;
    settings: boolean;
  };
}

export const ROLE_ACCESS: Record<EmployeeRole, EmployeeAccess> = {
  owner: {
    role: 'owner',
    label: 'Owner',
    description: 'Full access to everything',
    permissions: {
      dashboard: true,
      events: true,
      bookings: true,
      inventory: true,
      employees: true,
      tasks: true,
      reports: true,
      settings: true,
    },
  },
  manager: {
    role: 'manager',
    label: 'Manager',
    description: 'Manage shifts, tasks, and view reports',
    permissions: {
      dashboard: true,
      events: true,
      bookings: true,
      inventory: true,
      employees: false,
      tasks: true,
      reports: true,
      settings: false,
    },
  },
  bartender: {
    role: 'bartender',
    label: 'Bartender',
    description: 'View shifts, complete tasks',
    permissions: {
      dashboard: true,
      events: false,
      bookings: false,
      inventory: false,
      employees: false,
      tasks: true,
      reports: false,
      settings: false,
    },
  },
  inventory: {
    role: 'inventory',
    label: 'Inventory Manager',
    description: 'Full inventory access, scanning, ordering',
    permissions: {
      dashboard: true,
      events: false,
      bookings: false,
      inventory: true,
      employees: false,
      tasks: true,
      reports: true,
      settings: false,
    },
  },
  cleaning: {
    role: 'cleaning',
    label: 'Cleaning Staff',
    description: 'View and complete cleaning tasks',
    permissions: {
      dashboard: true,
      events: false,
      bookings: false,
      inventory: false,
      employees: false,
      tasks: true,
      reports: false,
      settings: false,
    },
  },
};

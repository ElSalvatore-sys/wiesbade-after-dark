-- =============================================
-- WiesbadenAfterDark Production Database Schema
-- =============================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =============================================
-- 1. EMPLOYEES TABLE
-- =============================================
CREATE TABLE IF NOT EXISTS employees (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    venue_id UUID NOT NULL REFERENCES venues(id) ON DELETE CASCADE,
    
    -- Basic Info
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255),
    phone VARCHAR(50),
    
    -- Role & Access
    role VARCHAR(50) NOT NULL DEFAULT 'staff',
    -- Roles: owner, manager, bartender, waiter, security, dj, cleaning
    
    -- Authentication
    pin_hash VARCHAR(255), -- Hashed 4-digit PIN for clock-in
    
    -- Employment
    hourly_rate DECIMAL(10,2) DEFAULT 12.50,
    is_active BOOLEAN DEFAULT true,
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    -- Constraints
    CONSTRAINT valid_role CHECK (role IN ('owner', 'manager', 'bartender', 'waiter', 'security', 'dj', 'cleaning'))
);

-- Index for faster lookups
CREATE INDEX idx_employees_venue ON employees(venue_id);
CREATE INDEX idx_employees_role ON employees(role);

-- =============================================
-- 2. SHIFTS TABLE
-- =============================================
CREATE TABLE IF NOT EXISTS shifts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    venue_id UUID NOT NULL REFERENCES venues(id) ON DELETE CASCADE,
    employee_id UUID NOT NULL REFERENCES employees(id) ON DELETE CASCADE,
    
    -- Timing
    clock_in TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    clock_out TIMESTAMPTZ,
    
    -- Break tracking
    break_start TIMESTAMPTZ,
    break_minutes INTEGER DEFAULT 0,
    
    -- Calculated
    expected_hours DECIMAL(4,2) DEFAULT 8.0,
    actual_hours DECIMAL(4,2),
    overtime_minutes INTEGER DEFAULT 0,
    
    -- Status
    status VARCHAR(20) DEFAULT 'active',
    -- Status: active, completed, cancelled
    
    notes TEXT,
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    CONSTRAINT valid_shift_status CHECK (status IN ('active', 'completed', 'cancelled'))
);

-- Indexes
CREATE INDEX idx_shifts_venue ON shifts(venue_id);
CREATE INDEX idx_shifts_employee ON shifts(employee_id);
CREATE INDEX idx_shifts_status ON shifts(status);
CREATE INDEX idx_shifts_date ON shifts(clock_in);

-- =============================================
-- 3. TASKS TABLE
-- =============================================
CREATE TABLE IF NOT EXISTS tasks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    venue_id UUID NOT NULL REFERENCES venues(id) ON DELETE CASCADE,
    
    -- Task Info
    title VARCHAR(255) NOT NULL,
    description TEXT,
    category VARCHAR(50) DEFAULT 'general',
    -- Categories: cleaning, inventory, bar, kitchen, general, closing
    
    priority VARCHAR(20) DEFAULT 'medium',
    -- Priority: low, medium, high, urgent
    
    -- Assignment
    assigned_to UUID REFERENCES employees(id) ON DELETE SET NULL,
    shift_id UUID REFERENCES shifts(id) ON DELETE SET NULL,
    
    -- Timing
    due_date TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    
    -- Status workflow
    status VARCHAR(20) DEFAULT 'pending',
    -- Status: pending, in_progress, completed, approved, rejected
    
    -- Completion proof
    photo_url TEXT,
    completion_notes TEXT,
    
    -- Approval
    approved_by UUID REFERENCES employees(id) ON DELETE SET NULL,
    rejection_reason TEXT,
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    CONSTRAINT valid_task_status CHECK (status IN ('pending', 'in_progress', 'completed', 'approved', 'rejected')),
    CONSTRAINT valid_task_priority CHECK (priority IN ('low', 'medium', 'high', 'urgent')),
    CONSTRAINT valid_task_category CHECK (category IN ('cleaning', 'inventory', 'bar', 'kitchen', 'general', 'closing'))
);

-- Indexes
CREATE INDEX idx_tasks_venue ON tasks(venue_id);
CREATE INDEX idx_tasks_assigned ON tasks(assigned_to);
CREATE INDEX idx_tasks_status ON tasks(status);
CREATE INDEX idx_tasks_due ON tasks(due_date);

-- =============================================
-- 4. INVENTORY ITEMS TABLE
-- =============================================
CREATE TABLE IF NOT EXISTS inventory_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    venue_id UUID NOT NULL REFERENCES venues(id) ON DELETE CASCADE,
    product_id UUID REFERENCES products(id) ON DELETE SET NULL,
    
    -- If no product reference, store details directly
    name VARCHAR(255) NOT NULL,
    category VARCHAR(50) DEFAULT 'other',
    barcode VARCHAR(100),
    
    -- Stock levels
    storage_quantity INTEGER DEFAULT 0,
    bar_quantity INTEGER DEFAULT 0,
    min_stock_level INTEGER DEFAULT 5,
    
    -- Pricing
    cost_price DECIMAL(10,2),
    sell_price DECIMAL(10,2),
    
    -- Tracking
    last_counted_at TIMESTAMPTZ,
    last_counted_by UUID REFERENCES employees(id),
    
    -- Status
    is_active BOOLEAN DEFAULT true,
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_inventory_venue ON inventory_items(venue_id);
CREATE INDEX idx_inventory_barcode ON inventory_items(barcode);
CREATE INDEX idx_inventory_category ON inventory_items(category);

-- =============================================
-- 5. INVENTORY TRANSFERS TABLE
-- =============================================
CREATE TABLE IF NOT EXISTS inventory_transfers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    venue_id UUID NOT NULL REFERENCES venues(id) ON DELETE CASCADE,
    inventory_item_id UUID NOT NULL REFERENCES inventory_items(id) ON DELETE CASCADE,
    
    -- Transfer details
    from_location VARCHAR(20) NOT NULL,
    to_location VARCHAR(20) NOT NULL,
    quantity INTEGER NOT NULL,
    
    -- Who & When
    transferred_by UUID REFERENCES employees(id),
    transferred_at TIMESTAMPTZ DEFAULT NOW(),
    
    notes TEXT,
    
    CONSTRAINT valid_locations CHECK (
        from_location IN ('storage', 'bar') AND 
        to_location IN ('storage', 'bar') AND
        from_location != to_location
    )
);

-- Index
CREATE INDEX idx_transfers_venue ON inventory_transfers(venue_id);
CREATE INDEX idx_transfers_item ON inventory_transfers(inventory_item_id);

-- =============================================
-- 6. INVENTORY COUNTS (Variance Tracking)
-- =============================================
CREATE TABLE IF NOT EXISTS inventory_counts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    venue_id UUID NOT NULL REFERENCES venues(id) ON DELETE CASCADE,
    inventory_item_id UUID NOT NULL REFERENCES inventory_items(id) ON DELETE CASCADE,
    
    -- Count details
    expected_quantity INTEGER NOT NULL,
    actual_quantity INTEGER NOT NULL,
    variance INTEGER GENERATED ALWAYS AS (actual_quantity - expected_quantity) STORED,
    
    location VARCHAR(20) NOT NULL,
    
    -- Who & When
    counted_by UUID REFERENCES employees(id),
    counted_at TIMESTAMPTZ DEFAULT NOW(),
    
    notes TEXT,
    
    CONSTRAINT valid_count_location CHECK (location IN ('storage', 'bar'))
);

-- Index
CREATE INDEX idx_counts_venue ON inventory_counts(venue_id);
CREATE INDEX idx_counts_item ON inventory_counts(inventory_item_id);

-- =============================================
-- 7. VENUE USERS (Auth linking)
-- =============================================
CREATE TABLE IF NOT EXISTS venue_users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    venue_id UUID NOT NULL REFERENCES venues(id) ON DELETE CASCADE,
    employee_id UUID REFERENCES employees(id) ON DELETE SET NULL,
    
    role VARCHAR(50) NOT NULL DEFAULT 'staff',
    is_owner BOOLEAN DEFAULT false,
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    
    UNIQUE(user_id, venue_id)
);

-- Index
CREATE INDEX idx_venue_users_user ON venue_users(user_id);
CREATE INDEX idx_venue_users_venue ON venue_users(venue_id);

-- =============================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- =============================================

-- Enable RLS on all tables
ALTER TABLE employees ENABLE ROW LEVEL SECURITY;
ALTER TABLE shifts ENABLE ROW LEVEL SECURITY;
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE inventory_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE inventory_transfers ENABLE ROW LEVEL SECURITY;
ALTER TABLE inventory_counts ENABLE ROW LEVEL SECURITY;
ALTER TABLE venue_users ENABLE ROW LEVEL SECURITY;

-- Policy: Users can only see data for their venues
CREATE POLICY "Users can view their venue employees"
    ON employees FOR SELECT
    USING (venue_id IN (SELECT venue_id FROM venue_users WHERE user_id = auth.uid()));

CREATE POLICY "Users can view their venue shifts"
    ON shifts FOR SELECT
    USING (venue_id IN (SELECT venue_id FROM venue_users WHERE user_id = auth.uid()));

CREATE POLICY "Users can view their venue tasks"
    ON tasks FOR SELECT
    USING (venue_id IN (SELECT venue_id FROM venue_users WHERE user_id = auth.uid()));

CREATE POLICY "Users can view their venue inventory"
    ON inventory_items FOR SELECT
    USING (venue_id IN (SELECT venue_id FROM venue_users WHERE user_id = auth.uid()));

-- Insert/Update/Delete policies for owners and managers
CREATE POLICY "Managers can manage employees"
    ON employees FOR ALL
    USING (venue_id IN (
        SELECT venue_id FROM venue_users 
        WHERE user_id = auth.uid() 
        AND role IN ('owner', 'manager')
    ));

CREATE POLICY "Staff can manage their shifts"
    ON shifts FOR ALL
    USING (venue_id IN (SELECT venue_id FROM venue_users WHERE user_id = auth.uid()));

CREATE POLICY "Staff can manage tasks"
    ON tasks FOR ALL
    USING (venue_id IN (SELECT venue_id FROM venue_users WHERE user_id = auth.uid()));

CREATE POLICY "Staff can manage inventory"
    ON inventory_items FOR ALL
    USING (venue_id IN (SELECT venue_id FROM venue_users WHERE user_id = auth.uid()));

-- =============================================
-- TRIGGERS FOR updated_at
-- =============================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_employees_updated_at BEFORE UPDATE ON employees
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_shifts_updated_at BEFORE UPDATE ON shifts
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_tasks_updated_at BEFORE UPDATE ON tasks
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_inventory_updated_at BEFORE UPDATE ON inventory_items
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();


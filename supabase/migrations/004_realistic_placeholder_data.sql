-- Update fake employee names to realistic German placeholders
-- (Owner should replace these with real staff)

UPDATE employees SET name = 'Inhaber (bitte anpassen)' WHERE role = 'owner' AND name = 'Max Müller';
UPDATE employees SET name = 'Manager (bitte anpassen)' WHERE role = 'manager' AND name = 'Sarah Schmidt';
UPDATE employees SET name = 'Barkeeper 1' WHERE role = 'bartender' AND name = 'Tom Weber';
UPDATE employees SET name = 'Service 1' WHERE role = 'waiter' AND name = 'Lisa Fischer';
UPDATE employees SET name = 'Security 1' WHERE role = 'security' AND name = 'Hans Becker';
UPDATE employees SET name = 'DJ 1' WHERE role = 'dj' AND name = 'DJ Mike';
UPDATE employees SET name = 'Reinigung 1' WHERE role = 'cleaning' AND name = 'Anna Klein';

-- Update task titles to be clearly placeholder
UPDATE tasks SET title = '[Demo] ' || title WHERE title NOT LIKE '[Demo]%' AND title NOT LIKE '\[Demo\]%';

-- Add comment to inventory items that they're samples
COMMENT ON TABLE inventory_items IS 'Sample data - replace with real venue inventory';

-- Create a setup_status table to track onboarding
CREATE TABLE IF NOT EXISTS setup_status (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  venue_id UUID REFERENCES venues(id),
  employees_imported BOOLEAN DEFAULT false,
  inventory_imported BOOLEAN DEFAULT false,
  tasks_configured BOOLEAN DEFAULT false,
  training_completed BOOLEAN DEFAULT false,
  go_live_date DATE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS on setup_status
ALTER TABLE setup_status ENABLE ROW LEVEL SECURITY;

-- Allow authenticated users to view and manage setup_status
CREATE POLICY "Allow all access to setup_status" ON setup_status FOR ALL USING (true) WITH CHECK (true);

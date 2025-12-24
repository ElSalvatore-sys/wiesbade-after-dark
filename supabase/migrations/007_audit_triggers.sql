-- Audit Log Triggers Migration
-- Applied: 2025-12-24 19:08:41 UTC
-- Creates audit logging system for shifts and tasks

-- Ensure audit_logs table exists
CREATE TABLE IF NOT EXISTS audit_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  venue_id UUID,
  user_id UUID,
  user_name TEXT,
  action TEXT NOT NULL,
  entity_type TEXT NOT NULL,
  entity_id UUID,
  details JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_audit_logs_venue ON audit_logs(venue_id);
CREATE INDEX IF NOT EXISTS idx_audit_logs_created ON audit_logs(created_at DESC);

-- Enable RLS
ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;

-- RLS Policies
DROP POLICY IF EXISTS "Anyone can view audit logs" ON audit_logs;
CREATE POLICY "Anyone can view audit logs" ON audit_logs FOR SELECT USING (true);

DROP POLICY IF EXISTS "Anyone can insert audit logs" ON audit_logs;
CREATE POLICY "Anyone can insert audit logs" ON audit_logs FOR INSERT WITH CHECK (true);

-- Shift audit trigger function
CREATE OR REPLACE FUNCTION audit_shift_changes()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO audit_logs (venue_id, user_id, user_name, action, entity_type, entity_id, details)
    VALUES (
      NEW.venue_id,
      NEW.employee_id,
      (SELECT name FROM employees WHERE id = NEW.employee_id),
      'clock_in',
      'shift',
      NEW.id,
      jsonb_build_object('clock_in', NEW.clock_in)
    );
  ELSIF TG_OP = 'UPDATE' AND OLD.clock_out IS NULL AND NEW.clock_out IS NOT NULL THEN
    INSERT INTO audit_logs (venue_id, user_id, user_name, action, entity_type, entity_id, details)
    VALUES (
      NEW.venue_id,
      NEW.employee_id,
      (SELECT name FROM employees WHERE id = NEW.employee_id),
      'clock_out',
      'shift',
      NEW.id,
      jsonb_build_object('clock_out', NEW.clock_out)
    );
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Attach shift trigger
DROP TRIGGER IF EXISTS trg_audit_shifts ON shifts;
CREATE TRIGGER trg_audit_shifts
AFTER INSERT OR UPDATE ON shifts
FOR EACH ROW EXECUTE FUNCTION audit_shift_changes();

-- Task audit trigger function
CREATE OR REPLACE FUNCTION audit_task_changes()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'UPDATE' AND OLD.status IS DISTINCT FROM NEW.status THEN
    INSERT INTO audit_logs (venue_id, user_id, user_name, action, entity_type, entity_id, details)
    VALUES (
      NEW.venue_id,
      NEW.assigned_to,
      COALESCE((SELECT name FROM employees WHERE id = NEW.assigned_to), 'System'),
      'task_' || NEW.status,
      'task',
      NEW.id,
      jsonb_build_object('title', NEW.title, 'old_status', OLD.status, 'new_status', NEW.status)
    );
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Attach task trigger
DROP TRIGGER IF EXISTS trg_audit_tasks ON tasks;
CREATE TRIGGER trg_audit_tasks
AFTER UPDATE ON tasks
FOR EACH ROW EXECUTE FUNCTION audit_task_changes();

SELECT 'Audit triggers created!' as status;

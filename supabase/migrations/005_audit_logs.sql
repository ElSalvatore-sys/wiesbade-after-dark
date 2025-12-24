-- Audit Logs Table Enhancement
-- Note: Table already existed, added venue_id and user_name columns

-- Add missing columns to existing audit_logs table
ALTER TABLE audit_logs ADD COLUMN IF NOT EXISTS venue_id UUID REFERENCES venues(id);
ALTER TABLE audit_logs ADD COLUMN IF NOT EXISTS user_name TEXT;

-- Index for fast queries
CREATE INDEX IF NOT EXISTS idx_audit_logs_venue ON audit_logs(venue_id);
CREATE INDEX IF NOT EXISTS idx_audit_logs_action ON audit_logs(action);
CREATE INDEX IF NOT EXISTS idx_audit_logs_created ON audit_logs(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_audit_logs_entity ON audit_logs(entity_type, entity_id);

-- RLS Policies
ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view their venue's audit logs" ON audit_logs;
CREATE POLICY "Users can view their venue's audit logs"
ON audit_logs FOR SELECT
USING (
  venue_id IN (
    SELECT venue_id FROM venue_users WHERE user_id = auth.uid()
  )
);

DROP POLICY IF EXISTS "System can insert audit logs" ON audit_logs;
CREATE POLICY "System can insert audit logs"
ON audit_logs FOR INSERT
WITH CHECK (true);

-- Function to log actions
CREATE OR REPLACE FUNCTION log_audit(
  p_venue_id UUID,
  p_user_id UUID,
  p_user_name TEXT,
  p_action TEXT,
  p_entity_type TEXT,
  p_entity_id UUID DEFAULT NULL,
  p_details JSONB DEFAULT NULL
) RETURNS UUID AS $$
DECLARE
  v_log_id UUID;
BEGIN
  INSERT INTO audit_logs (venue_id, user_id, user_name, action, entity_type, entity_id, details)
  VALUES (p_venue_id, p_user_id, p_user_name, p_action, p_entity_type, p_entity_id, p_details)
  RETURNING id INTO v_log_id;

  RETURN v_log_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Automatic triggers for key tables
CREATE OR REPLACE FUNCTION audit_shift_changes()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    PERFORM log_audit(
      NEW.venue_id,
      NEW.employee_id,
      (SELECT name FROM employees WHERE id = NEW.employee_id),
      'clock_in',
      'shift',
      NEW.id,
      jsonb_build_object('clock_in', NEW.clock_in)
    );
  ELSIF TG_OP = 'UPDATE' AND OLD.clock_out IS NULL AND NEW.clock_out IS NOT NULL THEN
    PERFORM log_audit(
      NEW.venue_id,
      NEW.employee_id,
      (SELECT name FROM employees WHERE id = NEW.employee_id),
      'clock_out',
      'shift',
      NEW.id,
      jsonb_build_object('clock_out', NEW.clock_out, 'total_hours',
        EXTRACT(EPOCH FROM (NEW.clock_out - NEW.clock_in)) / 3600)
    );
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trg_audit_shifts ON shifts;
CREATE TRIGGER trg_audit_shifts
AFTER INSERT OR UPDATE ON shifts
FOR EACH ROW EXECUTE FUNCTION audit_shift_changes();

-- Trigger for task status changes
CREATE OR REPLACE FUNCTION audit_task_changes()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'UPDATE' AND OLD.status != NEW.status THEN
    PERFORM log_audit(
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

DROP TRIGGER IF EXISTS trg_audit_tasks ON tasks;
CREATE TRIGGER trg_audit_tasks
AFTER UPDATE ON tasks
FOR EACH ROW EXECUTE FUNCTION audit_task_changes();

-- Trigger for inventory changes
CREATE OR REPLACE FUNCTION audit_inventory_changes()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'UPDATE' AND OLD.current_stock != NEW.current_stock THEN
    PERFORM log_audit(
      NEW.venue_id,
      NULL,
      'System',
      CASE WHEN NEW.current_stock > OLD.current_stock THEN 'stock_added' ELSE 'stock_removed' END,
      'inventory',
      NEW.id,
      jsonb_build_object(
        'product', NEW.name,
        'old_stock', OLD.current_stock,
        'new_stock', NEW.current_stock,
        'change', NEW.current_stock - OLD.current_stock
      )
    );
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trg_audit_inventory ON inventory;
CREATE TRIGGER trg_audit_inventory
AFTER UPDATE ON inventory
FOR EACH ROW EXECUTE FUNCTION audit_inventory_changes();

COMMENT ON TABLE audit_logs IS 'Tracks all important actions for compliance and debugging';

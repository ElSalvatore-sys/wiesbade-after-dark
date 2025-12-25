-- ============================================
-- DAS WOHNZIMMER - REAL DATA IMPORT
-- ============================================
-- Run this in Supabase Dashboard > SQL Editor
-- Replace placeholder values with real data

-- Get the venue ID first
DO $$
DECLARE
  v_venue_id UUID;
BEGIN
  SELECT id INTO v_venue_id FROM venues WHERE name ILIKE '%wohnzimmer%' LIMIT 1;

  IF v_venue_id IS NULL THEN
    RAISE EXCEPTION 'Das Wohnzimmer venue not found';
  END IF;

  RAISE NOTICE 'Venue ID: %', v_venue_id;
END $$;

-- ============================================
-- STEP 1: UPDATE VENUE INFO
-- ============================================

UPDATE venues
SET
  name = 'Das Wohnzimmer',
  description = 'Gemütliche Bar & Lounge in Wiesbaden',
  address = 'Adresse hier einfügen',
  city = 'Wiesbaden',
  phone = 'Telefonnummer',
  email = 'email@daswohnzimmer.de',
  opening_hours = '{"monday": "18:00-01:00", "tuesday": "18:00-01:00", "wednesday": "18:00-01:00", "thursday": "18:00-02:00", "friday": "18:00-03:00", "saturday": "18:00-03:00", "sunday": "closed"}',
  updated_at = NOW()
WHERE name ILIKE '%wohnzimmer%';

-- ============================================
-- STEP 2: UPDATE/ADD EMPLOYEES
-- ============================================

-- First, clear placeholder names and update with real staff
-- REPLACE THESE WITH REAL EMPLOYEE DATA

-- Owner
UPDATE employees
SET
  name = 'INHABER NAME HIER',
  email = 'inhaber@daswohnzimmer.de',
  role = 'owner',
  hourly_rate = 0,
  pin_hash = '1234' -- They should change this
WHERE role = 'owner'
AND venue_id = (SELECT id FROM venues WHERE name ILIKE '%wohnzimmer%' LIMIT 1);

-- Manager
UPDATE employees
SET
  name = 'MANAGER NAME HIER',
  email = 'manager@daswohnzimmer.de',
  role = 'manager',
  hourly_rate = 15.00,
  pin_hash = '2345'
WHERE role = 'manager'
AND venue_id = (SELECT id FROM venues WHERE name ILIKE '%wohnzimmer%' LIMIT 1);

-- Add more employees as needed:
/*
INSERT INTO employees (venue_id, name, role, email, phone, hourly_rate, pin_hash, is_active)
VALUES
  ((SELECT id FROM venues WHERE name ILIKE '%wohnzimmer%' LIMIT 1),
   'Mitarbeiter Name',
   'bartender', -- or 'server', 'security', 'dj', 'cleaning'
   'email@example.com',
   '0123456789',
   12.50,
   '1234',
   true);
*/

-- ============================================
-- STEP 3: UPDATE INVENTORY
-- ============================================

-- Update existing items or add new ones
-- REPLACE WITH REAL INVENTORY DATA

-- Example: Update beer prices
UPDATE inventory_items
SET
  unit_price = 3.50,
  min_stock_level = 24
WHERE name ILIKE '%corona%'
AND venue_id = (SELECT id FROM venues WHERE name ILIKE '%wohnzimmer%' LIMIT 1);

-- Add new inventory items:
/*
INSERT INTO inventory_items (venue_id, name, category, unit, unit_price, storage_quantity, bar_quantity, min_stock_level, barcode)
VALUES
  ((SELECT id FROM venues WHERE name ILIKE '%wohnzimmer%' LIMIT 1),
   'Produkt Name',
   'Spirituosen', -- or 'Bier', 'Wein', 'Softdrinks', 'Snacks', 'Sonstiges'
   'Flasche', -- or 'Dose', 'Liter', 'Stück'
   25.00,
   10, -- storage quantity
   2,  -- bar quantity
   5,  -- min stock level (reorder point)
   '4012345678901'); -- barcode (optional)
*/

-- ============================================
-- STEP 4: ADD RECURRING TASKS
-- ============================================

-- Clear demo tasks
DELETE FROM tasks
WHERE title LIKE '[Demo]%'
AND venue_id = (SELECT id FROM venues WHERE name ILIKE '%wohnzimmer%' LIMIT 1);

-- Add real recurring tasks
INSERT INTO tasks (venue_id, title, description, priority, status, is_recurring, recurrence_pattern)
VALUES
  ((SELECT id FROM venues WHERE name ILIKE '%wohnzimmer%' LIMIT 1),
   'Öffnungs-Checkliste',
   'Lichter an, Musik an, Kasse vorbereiten, Tische prüfen',
   'high',
   'pending',
   true,
   'daily'),

  ((SELECT id FROM venues WHERE name ILIKE '%wohnzimmer%' LIMIT 1),
   'Schließ-Checkliste',
   'Kasse abrechnen, Lichter aus, Türen abschließen, Kühlschränke prüfen',
   'high',
   'pending',
   true,
   'daily'),

  ((SELECT id FROM venues WHERE name ILIKE '%wohnzimmer%' LIMIT 1),
   'Inventur Kühlschrank',
   'Alle Getränke im Kühlschrank zählen und im System eintragen',
   'medium',
   'pending',
   true,
   'weekly'),

  ((SELECT id FROM venues WHERE name ILIKE '%wohnzimmer%' LIMIT 1),
   'Toiletten-Check',
   'Toiletten prüfen, auffüllen, reinigen wenn nötig',
   'medium',
   'pending',
   true,
   'daily');

-- ============================================
-- VERIFICATION
-- ============================================

SELECT 'Employees' as table_name, COUNT(*) as count FROM employees WHERE venue_id = (SELECT id FROM venues WHERE name ILIKE '%wohnzimmer%' LIMIT 1)
UNION ALL
SELECT 'Inventory', COUNT(*) FROM inventory_items WHERE venue_id = (SELECT id FROM venues WHERE name ILIKE '%wohnzimmer%' LIMIT 1)
UNION ALL
SELECT 'Tasks', COUNT(*) FROM tasks WHERE venue_id = (SELECT id FROM venues WHERE name ILIKE '%wohnzimmer%' LIMIT 1);

-- ============================================
-- DAS WOHNZIMMER - GENERIC DATA IMPORT
-- ============================================
-- Use this now, update names later
-- Run in: https://supabase.com/dashboard/project/yyplbhrqtaeyzmcxpfli/sql

-- Step 1: Delete demo tasks
DELETE FROM tasks WHERE title LIKE '[Demo]%';

-- Step 2: Update employees with role-based names
-- (Replace with real names when you have them)

UPDATE employees SET
  name = 'Inhaber',
  updated_at = NOW()
WHERE role = 'owner';

UPDATE employees SET
  name = 'Manager',
  updated_at = NOW()
WHERE role = 'manager';

UPDATE employees SET
  name = 'Barkeeper 1',
  updated_at = NOW()
WHERE role = 'bartender' AND id = (
  SELECT id FROM employees WHERE role = 'bartender' ORDER BY created_at LIMIT 1
);

UPDATE employees SET
  name = 'Barkeeper 2',
  updated_at = NOW()
WHERE role = 'bartender' AND id = (
  SELECT id FROM employees WHERE role = 'bartender' ORDER BY created_at LIMIT 1 OFFSET 1
);

UPDATE employees SET
  name = 'Service',
  updated_at = NOW()
WHERE role = 'server';

UPDATE employees SET
  name = 'Security',
  updated_at = NOW()
WHERE role = 'security';

UPDATE employees SET
  name = 'DJ',
  updated_at = NOW()
WHERE role = 'dj';

UPDATE employees SET
  name = 'Reinigung',
  updated_at = NOW()
WHERE role = 'cleaning';

-- Step 3: Add production tasks
INSERT INTO tasks (venue_id, title, description, priority, status, is_recurring, recurrence_pattern, created_at)
SELECT
  v.id,
  'Öffnungs-Checkliste',
  '• Lichter einschalten
- Musik starten
- Kasse vorbereiten
- Tische prüfen
- Kühlschränke Temperatur checken',
  'high',
  'pending',
  true,
  'daily',
  NOW()
FROM venues v
WHERE NOT EXISTS (SELECT 1 FROM tasks WHERE title = 'Öffnungs-Checkliste');

INSERT INTO tasks (venue_id, title, description, priority, status, is_recurring, recurrence_pattern, created_at)
SELECT
  v.id,
  'Schließ-Checkliste',
  '• Kasse abrechnen
- Lichter aus
- Türen abschließen
- Kühlschränke prüfen
- Alarm aktivieren',
  'high',
  'pending',
  true,
  'daily',
  NOW()
FROM venues v
WHERE NOT EXISTS (SELECT 1 FROM tasks WHERE title = 'Schließ-Checkliste');

INSERT INTO tasks (venue_id, title, description, priority, status, is_recurring, recurrence_pattern, created_at)
SELECT
  v.id,
  'Toiletten-Check',
  '• Papier auffüllen
- Seife prüfen
- Sauberkeit kontrollieren',
  'medium',
  'pending',
  true,
  'daily',
  NOW()
FROM venues v
WHERE NOT EXISTS (SELECT 1 FROM tasks WHERE title = 'Toiletten-Check');

INSERT INTO tasks (venue_id, title, description, priority, status, is_recurring, recurrence_pattern, created_at)
SELECT
  v.id,
  'Wöchentliche Inventur',
  '• Alle Getränke zählen
- Bestand aktualisieren
- Nachbestellungen notieren',
  'high',
  'pending',
  true,
  'weekly',
  NOW()
FROM venues v
WHERE NOT EXISTS (SELECT 1 FROM tasks WHERE title = 'Wöchentliche Inventur');

-- Step 4: Verify
SELECT 'Employees' as table_name, name, role FROM employees ORDER BY role;
SELECT 'Tasks' as table_name, title, is_recurring FROM tasks ORDER BY priority DESC;

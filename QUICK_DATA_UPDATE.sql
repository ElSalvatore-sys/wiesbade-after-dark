-- ============================================
-- DAS WOHNZIMMER - QUICK DATA UPDATE
-- ============================================
-- This script cleans up placeholder data and adds production-ready content
-- Run in: https://supabase.com/dashboard/project/yyplbhrqtaeyzmcxpfli/sql
--
-- Time: ~2 minutes
-- ============================================

-- ============================================
-- STEP 1: DELETE DEMO TASKS
-- ============================================

-- Remove all [Demo] tasks
DELETE FROM tasks WHERE title LIKE '%[Demo]%' OR title LIKE '%Demo%';

-- Verify deletion
SELECT COUNT(*) as deleted_demo_tasks FROM tasks WHERE title LIKE '%[Demo]%';

-- ============================================
-- STEP 2: UPDATE EMPLOYEE NAMES
-- ============================================

-- Get venue ID for Das Wohnzimmer
DO $
DECLARE
  v_venue_id UUID;
BEGIN
  SELECT id INTO v_venue_id FROM venues WHERE name = 'Das Wohnzimmer';

  -- Update Owner (replace "ACTUAL NAME" with real name)
  UPDATE employees SET
    name = 'Max Mustermann', -- 👈 CHANGE THIS to real owner name
    phone = '+49 176 1234567' -- 👈 CHANGE THIS if needed
  WHERE venue_id = v_venue_id AND role = 'owner';

  -- Update Manager
  UPDATE employees SET
    name = 'Sarah Schmidt', -- 👈 CHANGE THIS
    phone = '+49 176 2345678' -- 👈 CHANGE THIS if needed
  WHERE venue_id = v_venue_id AND role = 'manager';

  -- Update Bartender
  UPDATE employees SET
    name = 'Tom Weber', -- 👈 CHANGE THIS
    email = 'bartender@daswohnzimmer.de', -- 👈 CHANGE THIS if needed
    phone = '+49 176 3456789'
  WHERE venue_id = v_venue_id AND role = 'bartender';

  -- Update Server/Waiter
  UPDATE employees SET
    name = 'Lisa Fischer', -- 👈 CHANGE THIS
    email = 'service@daswohnzimmer.de',
    phone = '+49 176 4567890'
  WHERE venue_id = v_venue_id AND role = 'waiter';

  -- Update Security
  UPDATE employees SET
    name = 'Hans Becker', -- 👈 CHANGE THIS
    email = 'security@daswohnzimmer.de',
    phone = '+49 176 5678901'
  WHERE venue_id = v_venue_id AND role = 'security';

  -- Update DJ
  UPDATE employees SET
    name = 'Mike Johnson', -- 👈 CHANGE THIS
    email = 'dj@daswohnzimmer.de',
    phone = '+49 176 6789012'
  WHERE venue_id = v_venue_id AND role = 'dj';

  -- Update Cleaning Staff
  UPDATE employees SET
    name = 'Anna Müller', -- 👈 CHANGE THIS
    email = 'cleaning@daswohnzimmer.de',
    phone = '+49 176 7890123'
  WHERE venue_id = v_venue_id AND role = 'cleaning';

  RAISE NOTICE 'Employees updated for Das Wohnzimmer';
END $;

-- ============================================
-- STEP 3: ADD RECURRING TASKS
-- ============================================

DO $
DECLARE
  v_venue_id UUID;
BEGIN
  SELECT id INTO v_venue_id FROM venues WHERE name = 'Das Wohnzimmer';

  -- Opening Checklist
  INSERT INTO tasks (venue_id, title, description, category, priority, status, created_at)
  VALUES (
    v_venue_id,
    'Öffnungs-Checkliste',
    E'☐ Lichter einschalten\n☐ Musik/Sound-System starten\n☐ Kasse vorbereiten und zählen\n☐ Tische und Stühle prüfen\n☐ Gläser kontrollieren\n☐ Kühlschränke Temperatur prüfen\n☐ Toiletten prüfen\n☐ Bar aufräumen',
    'opening',
    'high',
    'pending',
    NOW()
  )
  ON CONFLICT DO NOTHING;

  -- Closing Checklist
  INSERT INTO tasks (venue_id, title, description, category, priority, status, created_at)
  VALUES (
    v_venue_id,
    'Schließ-Checkliste',
    E'☐ Kasse abrechnen und dokumentieren\n☐ Alle Lichter ausschalten\n☐ Alle Türen und Fenster schließen\n☐ Kühlschränke prüfen\n☐ Müll entsorgen\n☐ Bar aufräumen\n☐ Alarmsystem aktivieren',
    'closing',
    'high',
    'pending',
    NOW()
  )
  ON CONFLICT DO NOTHING;

  -- Toilet Check
  INSERT INTO tasks (venue_id, title, description, category, priority, status, created_at)
  VALUES (
    v_venue_id,
    'Toiletten-Check',
    E'☐ Papier auffüllen\n☐ Seife prüfen\n☐ Sauberkeit kontrollieren\n☐ Mülleimer leeren\n☐ Boden wischen',
    'cleaning',
    'medium',
    'pending',
    NOW()
  )
  ON CONFLICT DO NOTHING;

  -- Bar Cleanup
  INSERT INTO tasks (venue_id, title, description, category, priority, status, created_at)
  VALUES (
    v_venue_id,
    'Bar aufräumen',
    E'☐ Gläser spülen und polieren\n☐ Theke abwischen\n☐ Flaschen auffüllen\n☐ Eis vorbereiten\n☐ Zitronen/Limetten schneiden',
    'bar',
    'medium',
    'pending',
    NOW()
  )
  ON CONFLICT DO NOTHING;

  -- Weekly Inventory
  INSERT INTO tasks (venue_id, title, description, category, priority, status, created_at)
  VALUES (
    v_venue_id,
    'Wöchentliche Inventur',
    E'☐ Lagerbestand zählen (storage_quantity)\n☐ Bar-Bestand zählen (bar_quantity)\n☐ Im System aktualisieren\n☐ Nachbestellungen notieren\n☐ Ablaufdaten prüfen\n☐ Beschädigte Artikel aussortieren',
    'inventory',
    'high',
    'pending',
    NOW()
  )
  ON CONFLICT DO NOTHING;

  -- Deep Cleaning
  INSERT INTO tasks (venue_id, title, description, category, priority, status, created_at)
  VALUES (
    v_venue_id,
    'Tiefenreinigung',
    E'☐ Böden gründlich wischen\n☐ Fenster putzen\n☐ Möbel abwischen\n☐ Kühlschränke ausräumen und putzen\n☐ Lüftung prüfen\n☐ Lagerraum aufräumen',
    'cleaning',
    'medium',
    'pending',
    NOW()
  )
  ON CONFLICT DO NOTHING;

  RAISE NOTICE 'Recurring tasks created for Das Wohnzimmer';
END $;

-- ============================================
-- STEP 4: UPDATE VENUE INFO (OPTIONAL)
-- ============================================

-- Uncomment and edit if you need to update venue details

/*
UPDATE venues SET
  phone = '+49 611 NEW_NUMBER', -- 👈 Update if different
  email = 'newemail@daswohnzimmer.de', -- 👈 Update if different
  website = 'https://daswohnzimmer.de', -- 👈 Add if you have one
  description = 'Gemütliche Bar & Lounge im Herzen von Wiesbaden',
  updated_at = NOW()
WHERE name = 'Das Wohnzimmer';
*/

-- ============================================
-- STEP 5: VERIFY CHANGES
-- ============================================

-- Show updated employees
SELECT
  name,
  role,
  email,
  CASE WHEN name LIKE '%(bitte anpassen)%' THEN '❌ Still placeholder' ELSE '✅ Updated' END as status
FROM employees
WHERE venue_id = (SELECT id FROM venues WHERE name = 'Das Wohnzimmer')
ORDER BY
  CASE role
    WHEN 'owner' THEN 1
    WHEN 'manager' THEN 2
    WHEN 'bartender' THEN 3
    WHEN 'waiter' THEN 4
    ELSE 5
  END;

-- Show new tasks
SELECT title, category, priority, status
FROM tasks
WHERE venue_id = (SELECT id FROM venues WHERE name = 'Das Wohnzimmer')
ORDER BY priority DESC, created_at DESC;

-- Show inventory summary
SELECT
  category,
  COUNT(*) as items,
  SUM(storage_quantity) as total_storage,
  SUM(bar_quantity) as total_at_bar,
  SUM(CASE WHEN (storage_quantity + bar_quantity) <= min_stock_level THEN 1 ELSE 0 END) as low_stock_items
FROM inventory_items
WHERE venue_id = (SELECT id FROM venues WHERE name = 'Das Wohnzimmer')
GROUP BY category
ORDER BY category;

-- ============================================
-- SUMMARY
-- ============================================

SELECT
  '✅ Demo tasks deleted' as action,
  (SELECT COUNT(*) FROM tasks WHERE title LIKE '%[Demo]%') as remaining_demo_tasks
UNION ALL
SELECT
  '✅ Employees updated',
  (SELECT COUNT(*) FROM employees WHERE name NOT LIKE '%(bitte anpassen)%')
UNION ALL
SELECT
  '✅ Tasks created',
  (SELECT COUNT(*) FROM tasks WHERE venue_id = (SELECT id FROM venues WHERE name = 'Das Wohnzimmer'))
UNION ALL
SELECT
  '✅ Inventory items',
  (SELECT COUNT(*) FROM inventory_items WHERE venue_id = (SELECT id FROM venues WHERE name = 'Das Wohnzimmer'));

RAISE NOTICE 'Data update complete! Check results above.';

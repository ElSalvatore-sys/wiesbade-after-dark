-- =============================================
-- SEED DATA FOR DAS WOHNZIMMER
-- Run after 001_production_tables.sql
-- =============================================

-- First, ensure Das Wohnzimmer exists in venues table
INSERT INTO venues (id, name, address, description, image_url, category)
VALUES (
    'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
    'Das Wohnzimmer',
    'Taunusstraße 45, 65183 Wiesbaden',
    'Gemütliche Bar & Club im Herzen von Wiesbaden. Cocktails, Live-Musik und eine entspannte Atmosphäre.',
    'https://images.unsplash.com/photo-1572116469696-31de0f17cc34?w=800',
    'bar'
)
ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    address = EXCLUDED.address;

-- Insert employees for Das Wohnzimmer
INSERT INTO employees (venue_id, name, email, phone, role, pin_hash, hourly_rate, is_active)
VALUES
    ('a1b2c3d4-e5f6-7890-abcd-ef1234567890', 'Max Müller', 'max@daswohnzimmer.de', '+49 176 1234567', 'owner', '1234', 0, true),
    ('a1b2c3d4-e5f6-7890-abcd-ef1234567890', 'Sarah Schmidt', 'sarah@daswohnzimmer.de', '+49 176 2345678', 'manager', '2345', 15.00, true),
    ('a1b2c3d4-e5f6-7890-abcd-ef1234567890', 'Tom Weber', 'tom@daswohnzimmer.de', '+49 176 3456789', 'bartender', '3456', 12.50, true),
    ('a1b2c3d4-e5f6-7890-abcd-ef1234567890', 'Lisa Fischer', 'lisa@daswohnzimmer.de', '+49 176 4567890', 'waiter', '4567', 12.00, true),
    ('a1b2c3d4-e5f6-7890-abcd-ef1234567890', 'Hans Becker', 'hans@daswohnzimmer.de', '+49 176 5678901', 'security', '5678', 14.00, true),
    ('a1b2c3d4-e5f6-7890-abcd-ef1234567890', 'DJ Mike', 'mike@daswohnzimmer.de', '+49 176 6789012', 'dj', '6789', 20.00, true),
    ('a1b2c3d4-e5f6-7890-abcd-ef1234567890', 'Anna Klein', 'anna@daswohnzimmer.de', '+49 176 7890123', 'cleaning', '7890', 11.00, true)
ON CONFLICT DO NOTHING;

-- Insert inventory items
INSERT INTO inventory_items (venue_id, name, category, barcode, storage_quantity, bar_quantity, min_stock_level, cost_price, sell_price)
VALUES
    -- Beer
    ('a1b2c3d4-e5f6-7890-abcd-ef1234567890', 'Corona Extra 0.33L', 'beer', '4006824000185', 48, 12, 10, 0.85, 4.00),
    ('a1b2c3d4-e5f6-7890-abcd-ef1234567890', 'Heineken 0.33L', 'beer', '8714800000000', 36, 8, 10, 0.75, 3.50),
    ('a1b2c3d4-e5f6-7890-abcd-ef1234567890', 'Beck''s 0.33L', 'beer', '4100060000000', 48, 12, 10, 0.65, 3.00),
    ('a1b2c3d4-e5f6-7890-abcd-ef1234567890', 'Bitburger 0.5L', 'beer', '4012100000000', 24, 6, 8, 0.90, 4.50),
    
    -- Spirits
    ('a1b2c3d4-e5f6-7890-abcd-ef1234567890', 'Absolut Vodka 0.7L', 'spirits', '7312040017508', 6, 2, 2, 12.00, 0),
    ('a1b2c3d4-e5f6-7890-abcd-ef1234567890', 'Bombay Sapphire 0.7L', 'spirits', '5010677710008', 4, 1, 2, 18.00, 0),
    ('a1b2c3d4-e5f6-7890-abcd-ef1234567890', 'Jack Daniels 0.7L', 'spirits', '5099873089798', 5, 2, 2, 20.00, 0),
    ('a1b2c3d4-e5f6-7890-abcd-ef1234567890', 'Bacardi Superior 0.7L', 'spirits', '5010677014007', 4, 2, 2, 14.00, 0),
    ('a1b2c3d4-e5f6-7890-abcd-ef1234567890', 'Jägermeister 0.7L', 'spirits', '4067700015006', 6, 2, 2, 12.00, 0),
    ('a1b2c3d4-e5f6-7890-abcd-ef1234567890', 'Havana Club 3 Anos 0.7L', 'spirits', '8501110080842', 4, 1, 2, 16.00, 0),
    
    -- Wine
    ('a1b2c3d4-e5f6-7890-abcd-ef1234567890', 'Prosecco', 'wine', '8002550000000', 24, 6, 5, 4.50, 6.00),
    ('a1b2c3d4-e5f6-7890-abcd-ef1234567890', 'Hauswein Weiß 0.75L', 'wine', '4001234567890', 12, 4, 4, 3.50, 18.00),
    ('a1b2c3d4-e5f6-7890-abcd-ef1234567890', 'Hauswein Rot 0.75L', 'wine', '4001234567891', 12, 4, 4, 3.50, 18.00),
    
    -- Soft Drinks
    ('a1b2c3d4-e5f6-7890-abcd-ef1234567890', 'Red Bull 0.25L', 'soft_drinks', '9002490100070', 48, 12, 15, 0.95, 3.50),
    ('a1b2c3d4-e5f6-7890-abcd-ef1234567890', 'Coca Cola 0.33L', 'soft_drinks', '5449000000996', 48, 24, 20, 0.45, 2.50),
    ('a1b2c3d4-e5f6-7890-abcd-ef1234567890', 'Sprite 0.33L', 'soft_drinks', '5449000014535', 24, 12, 10, 0.45, 2.50),
    ('a1b2c3d4-e5f6-7890-abcd-ef1234567890', 'Fanta 0.33L', 'soft_drinks', '5449000008459', 24, 12, 10, 0.45, 2.50),
    ('a1b2c3d4-e5f6-7890-abcd-ef1234567890', 'Mineralwasser 0.5L', 'soft_drinks', '4022840000000', 48, 24, 20, 0.25, 2.00),
    
    -- Mixers
    ('a1b2c3d4-e5f6-7890-abcd-ef1234567890', 'Orangensaft 1L', 'mixers', '4001475000000', 12, 4, 5, 1.20, 0),
    ('a1b2c3d4-e5f6-7890-abcd-ef1234567890', 'Tonic Water 0.2L', 'mixers', '5000112000000', 24, 12, 10, 0.60, 0),
    ('a1b2c3d4-e5f6-7890-abcd-ef1234567890', 'Ginger Ale 0.2L', 'mixers', '5000112000001', 24, 12, 10, 0.60, 0),
    ('a1b2c3d4-e5f6-7890-abcd-ef1234567890', 'Cranberry Saft 1L', 'mixers', '4001475000001', 6, 2, 3, 2.00, 0),
    ('a1b2c3d4-e5f6-7890-abcd-ef1234567890', 'Limettensaft 0.5L', 'mixers', '4001475000002', 6, 2, 2, 2.50, 0)
ON CONFLICT DO NOTHING;

-- Create some sample tasks
INSERT INTO tasks (venue_id, title, description, category, priority, status, due_date)
VALUES
    ('a1b2c3d4-e5f6-7890-abcd-ef1234567890', 'Gläser polieren', 'Alle Cocktailgläser polieren und ins Regal stellen', 'bar', 'medium', 'pending', NOW() + INTERVAL '2 hours'),
    ('a1b2c3d4-e5f6-7890-abcd-ef1234567890', 'Toiletten reinigen', 'Beide Toiletten gründlich reinigen', 'cleaning', 'high', 'pending', NOW() + INTERVAL '1 hour'),
    ('a1b2c3d4-e5f6-7890-abcd-ef1234567890', 'Getränke auffüllen', 'Kühlschrank mit Bier und Softdrinks auffüllen', 'inventory', 'high', 'pending', NOW() + INTERVAL '30 minutes'),
    ('a1b2c3d4-e5f6-7890-abcd-ef1234567890', 'DJ Pult vorbereiten', 'Anlage testen und Equipment bereitstellen', 'general', 'medium', 'pending', NOW() + INTERVAL '3 hours'),
    ('a1b2c3d4-e5f6-7890-abcd-ef1234567890', 'Garderobe einrichten', 'Kleiderbügel sortieren und Bereich vorbereiten', 'general', 'low', 'pending', NOW() + INTERVAL '4 hours')
ON CONFLICT DO NOTHING;


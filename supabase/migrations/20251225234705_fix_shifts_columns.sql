-- =============================================
-- Migration: Fix Shifts Table Column Names
-- Created: 2025-12-25 23:47:05
-- Purpose: Rename shift tracking columns to match convention
--          started_at → clock_in
--          ended_at → clock_out
--          total_break_minutes → break_minutes
--          Add break_start column if missing
-- =============================================

-- =============================================
-- VERIFICATION QUERIES (BEFORE)
-- =============================================
-- Run these queries to check current state before migration:
-- SELECT column_name, data_type
-- FROM information_schema.columns
-- WHERE table_name = 'shifts'
-- ORDER BY ordinal_position;

-- =============================================
-- FORWARD MIGRATION
-- =============================================

-- Step 1: Rename started_at → clock_in (if exists)
DO $$
BEGIN
    -- Check if old column exists and new column doesn't
    IF EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'shifts' AND column_name = 'started_at'
    ) AND NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'shifts' AND column_name = 'clock_in'
    ) THEN
        -- Rename the column
        ALTER TABLE shifts RENAME COLUMN started_at TO clock_in;
        RAISE NOTICE 'Renamed started_at → clock_in';
    ELSIF EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'shifts' AND column_name = 'clock_in'
    ) THEN
        RAISE NOTICE 'Column clock_in already exists, skipping rename';
    ELSE
        RAISE NOTICE 'Column started_at not found, skipping rename';
    END IF;
END $$;

-- Step 2: Rename ended_at → clock_out (if exists)
DO $$
BEGIN
    -- Check if old column exists and new column doesn't
    IF EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'shifts' AND column_name = 'ended_at'
    ) AND NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'shifts' AND column_name = 'clock_out'
    ) THEN
        -- Rename the column
        ALTER TABLE shifts RENAME COLUMN ended_at TO clock_out;
        RAISE NOTICE 'Renamed ended_at → clock_out';
    ELSIF EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'shifts' AND column_name = 'clock_out'
    ) THEN
        RAISE NOTICE 'Column clock_out already exists, skipping rename';
    ELSE
        RAISE NOTICE 'Column ended_at not found, skipping rename';
    END IF;
END $$;

-- Step 3: Rename total_break_minutes → break_minutes (if exists)
DO $$
BEGIN
    -- Check if old column exists and new column doesn't
    IF EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'shifts' AND column_name = 'total_break_minutes'
    ) AND NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'shifts' AND column_name = 'break_minutes'
    ) THEN
        -- Rename the column
        ALTER TABLE shifts RENAME COLUMN total_break_minutes TO break_minutes;
        RAISE NOTICE 'Renamed total_break_minutes → break_minutes';
    ELSIF EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'shifts' AND column_name = 'break_minutes'
    ) THEN
        RAISE NOTICE 'Column break_minutes already exists, skipping rename';
    ELSE
        RAISE NOTICE 'Column total_break_minutes not found, skipping rename';
    END IF;
END $$;

-- Step 4: Add break_start column if missing
DO $$
BEGIN
    -- Check if break_start column exists
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'shifts' AND column_name = 'break_start'
    ) THEN
        -- Add the column
        ALTER TABLE shifts ADD COLUMN break_start TIMESTAMPTZ;
        RAISE NOTICE 'Added break_start column';
    ELSE
        RAISE NOTICE 'Column break_start already exists, skipping';
    END IF;
END $$;

-- Step 5: Update index on clock_in if it was referencing started_at
DO $$
BEGIN
    -- Drop old index if it exists
    IF EXISTS (
        SELECT 1 FROM pg_indexes
        WHERE tablename = 'shifts' AND indexname = 'idx_shifts_date'
    ) THEN
        -- Check if the index references the old column name
        -- We'll just recreate it to be safe
        DROP INDEX IF EXISTS idx_shifts_date;
        RAISE NOTICE 'Dropped old idx_shifts_date index';
    END IF;

    -- Recreate index on clock_in
    IF NOT EXISTS (
        SELECT 1 FROM pg_indexes
        WHERE tablename = 'shifts' AND indexname = 'idx_shifts_date'
    ) THEN
        CREATE INDEX idx_shifts_date ON shifts(clock_in);
        RAISE NOTICE 'Created idx_shifts_date on clock_in';
    END IF;
END $$;

-- =============================================
-- VERIFICATION QUERIES (AFTER)
-- =============================================
-- Run these queries to verify migration success:
--
-- 1. Check all columns exist with correct names:
-- SELECT column_name, data_type, is_nullable
-- FROM information_schema.columns
-- WHERE table_name = 'shifts'
-- AND column_name IN ('clock_in', 'clock_out', 'break_start', 'break_minutes')
-- ORDER BY column_name;
--
-- Expected output (4 rows):
-- break_minutes    | integer                  | YES
-- break_start      | timestamp with time zone | YES
-- clock_in         | timestamp with time zone | NO
-- clock_out        | timestamp with time zone | YES
--
-- 2. Verify old columns are gone:
-- SELECT column_name
-- FROM information_schema.columns
-- WHERE table_name = 'shifts'
-- AND column_name IN ('started_at', 'ended_at', 'total_break_minutes');
--
-- Expected output: (0 rows)
--
-- 3. Check index exists:
-- SELECT indexname, indexdef
-- FROM pg_indexes
-- WHERE tablename = 'shifts' AND indexname = 'idx_shifts_date';
--
-- Expected output:
-- idx_shifts_date | CREATE INDEX idx_shifts_date ON public.shifts USING btree (clock_in)

-- =============================================
-- TEST QUERIES
-- =============================================
-- Test inserting a new shift with new column names:
-- INSERT INTO shifts (venue_id, employee_id, clock_in, break_minutes)
-- SELECT
--     v.id,
--     e.id,
--     NOW(),
--     0
-- FROM venues v
-- CROSS JOIN employees e
-- LIMIT 1
-- RETURNING id, clock_in, clock_out, break_start, break_minutes;
--
-- Test updating a shift (clock out):
-- UPDATE shifts
-- SET clock_out = NOW(),
--     break_minutes = 30
-- WHERE id = (SELECT id FROM shifts ORDER BY created_at DESC LIMIT 1)
-- RETURNING id, clock_in, clock_out, break_minutes;

-- =============================================
-- ROLLBACK SCRIPT
-- =============================================
-- Save this in a separate file: 20251225234705_fix_shifts_columns_rollback.sql
--
-- DO $$
-- BEGIN
--     -- Rollback Step 1: Rename clock_in → started_at (if needed)
--     IF EXISTS (
--         SELECT 1 FROM information_schema.columns
--         WHERE table_name = 'shifts' AND column_name = 'clock_in'
--     ) AND NOT EXISTS (
--         SELECT 1 FROM information_schema.columns
--         WHERE table_name = 'shifts' AND column_name = 'started_at'
--     ) THEN
--         ALTER TABLE shifts RENAME COLUMN clock_in TO started_at;
--         RAISE NOTICE 'Rolled back: clock_in → started_at';
--     END IF;
--
--     -- Rollback Step 2: Rename clock_out → ended_at (if needed)
--     IF EXISTS (
--         SELECT 1 FROM information_schema.columns
--         WHERE table_name = 'shifts' AND column_name = 'clock_out'
--     ) AND NOT EXISTS (
--         SELECT 1 FROM information_schema.columns
--         WHERE table_name = 'shifts' AND column_name = 'ended_at'
--     ) THEN
--         ALTER TABLE shifts RENAME COLUMN clock_out TO ended_at;
--         RAISE NOTICE 'Rolled back: clock_out → ended_at';
--     END IF;
--
--     -- Rollback Step 3: Rename break_minutes → total_break_minutes (if needed)
--     IF EXISTS (
--         SELECT 1 FROM information_schema.columns
--         WHERE table_name = 'shifts' AND column_name = 'break_minutes'
--     ) AND NOT EXISTS (
--         SELECT 1 FROM information_schema.columns
--         WHERE table_name = 'shifts' AND column_name = 'total_break_minutes'
--     ) THEN
--         ALTER TABLE shifts RENAME COLUMN break_minutes TO total_break_minutes;
--         RAISE NOTICE 'Rolled back: break_minutes → total_break_minutes';
--     END IF;
--
--     -- Rollback Step 4: Remove break_start column
--     -- WARNING: This will delete data! Only run if absolutely necessary
--     -- IF EXISTS (
--     --     SELECT 1 FROM information_schema.columns
--     --     WHERE table_name = 'shifts' AND column_name = 'break_start'
--     -- ) THEN
--     --     ALTER TABLE shifts DROP COLUMN break_start;
--     --     RAISE NOTICE 'Rolled back: Removed break_start column';
--     -- END IF;
--
--     -- Rollback Step 5: Recreate index on started_at
--     DROP INDEX IF EXISTS idx_shifts_date;
--     CREATE INDEX idx_shifts_date ON shifts(started_at);
--     RAISE NOTICE 'Rolled back: Recreated index on started_at';
-- END $$;

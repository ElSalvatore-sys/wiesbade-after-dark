-- =============================================
-- ROLLBACK Migration: Fix Shifts Table Column Names
-- Created: 2025-12-25 23:47:05
-- Purpose: Rollback column renames to original state
--          clock_in → started_at
--          clock_out → ended_at
--          break_minutes → total_break_minutes
--          Remove break_start column (WARNING: Data loss!)
-- =============================================

-- =============================================
-- ROLLBACK SCRIPT
-- =============================================
-- WARNING: Running this will revert the changes made by the forward migration.
-- Only run this if you need to undo the migration.

DO $$
BEGIN
    -- Rollback Step 1: Rename clock_in → started_at (if needed)
    IF EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'shifts' AND column_name = 'clock_in'
    ) AND NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'shifts' AND column_name = 'started_at'
    ) THEN
        ALTER TABLE shifts RENAME COLUMN clock_in TO started_at;
        RAISE NOTICE 'Rolled back: clock_in → started_at';
    ELSE
        RAISE NOTICE 'Rollback not needed for clock_in/started_at';
    END IF;

    -- Rollback Step 2: Rename clock_out → ended_at (if needed)
    IF EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'shifts' AND column_name = 'clock_out'
    ) AND NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'shifts' AND column_name = 'ended_at'
    ) THEN
        ALTER TABLE shifts RENAME COLUMN clock_out TO ended_at;
        RAISE NOTICE 'Rolled back: clock_out → ended_at';
    ELSE
        RAISE NOTICE 'Rollback not needed for clock_out/ended_at';
    END IF;

    -- Rollback Step 3: Rename break_minutes → total_break_minutes (if needed)
    IF EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'shifts' AND column_name = 'break_minutes'
    ) AND NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'shifts' AND column_name = 'total_break_minutes'
    ) THEN
        ALTER TABLE shifts RENAME COLUMN break_minutes TO total_break_minutes;
        RAISE NOTICE 'Rolled back: break_minutes → total_break_minutes';
    ELSE
        RAISE NOTICE 'Rollback not needed for break_minutes/total_break_minutes';
    END IF;

    -- Rollback Step 4: Remove break_start column
    -- WARNING: This will DELETE ALL DATA in the break_start column!
    -- Uncomment the following block ONLY if you are absolutely sure you want to remove this column
    /*
    IF EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'shifts' AND column_name = 'break_start'
    ) THEN
        ALTER TABLE shifts DROP COLUMN break_start;
        RAISE NOTICE 'Rolled back: Removed break_start column (DATA DELETED)';
    ELSE
        RAISE NOTICE 'break_start column does not exist, skipping';
    END IF;
    */
    RAISE NOTICE 'Skipping break_start column removal (commented out to prevent data loss)';

    -- Rollback Step 5: Recreate index on started_at
    IF EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'shifts' AND column_name = 'started_at'
    ) THEN
        DROP INDEX IF EXISTS idx_shifts_date;
        CREATE INDEX idx_shifts_date ON shifts(started_at);
        RAISE NOTICE 'Rolled back: Recreated index on started_at';
    ELSE
        RAISE NOTICE 'Cannot recreate index on started_at (column does not exist)';
    END IF;
END $$;

-- =============================================
-- VERIFICATION AFTER ROLLBACK
-- =============================================
-- Run these queries to verify rollback was successful:
--
-- 1. Check old columns exist:
-- SELECT column_name, data_type
-- FROM information_schema.columns
-- WHERE table_name = 'shifts'
-- AND column_name IN ('started_at', 'ended_at', 'total_break_minutes')
-- ORDER BY column_name;
--
-- Expected output (3 rows):
-- ended_at             | timestamp with time zone
-- started_at           | timestamp with time zone
-- total_break_minutes  | integer
--
-- 2. Verify new columns are gone (or still exist if renamed back):
-- SELECT column_name
-- FROM information_schema.columns
-- WHERE table_name = 'shifts'
-- AND column_name IN ('clock_in', 'clock_out', 'break_minutes');
--
-- Expected output: (0 rows) if rollback successful

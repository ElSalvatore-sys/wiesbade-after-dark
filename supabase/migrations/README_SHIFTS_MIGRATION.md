# Shifts Table Migration Guide

## Overview

This migration fixes the shifts table column names to follow consistent naming conventions:

| Old Name | New Name |
|----------|----------|
| `started_at` | `clock_in` |
| `ended_at` | `clock_out` |
| `total_break_minutes` | `break_minutes` |
| N/A | `break_start` (new column) |

## Files

1. **20251225234705_fix_shifts_columns.sql** - Forward migration
2. **20251225234705_fix_shifts_columns_rollback.sql** - Rollback script

## Running the Migration

### Using Supabase CLI

```bash
# Apply the migration
supabase db push

# Or apply a specific migration
supabase migration up
```

### Using psql or SQL Editor

```sql
-- Run the forward migration
\i supabase/migrations/20251225234705_fix_shifts_columns.sql
```

### Using Supabase Dashboard

1. Go to SQL Editor
2. Copy the contents of `20251225234705_fix_shifts_columns.sql`
3. Paste and run

## Verification

### Before Migration

```sql
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'shifts'
ORDER BY ordinal_position;
```

### After Migration

Run these queries to verify success:

#### 1. Check new columns exist
```sql
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'shifts'
AND column_name IN ('clock_in', 'clock_out', 'break_start', 'break_minutes')
ORDER BY column_name;
```

**Expected output (4 rows):**
```
break_minutes    | integer                  | YES
break_start      | timestamp with time zone | YES
clock_in         | timestamp with time zone | NO
clock_out        | timestamp with time zone | YES
```

#### 2. Verify old columns are gone
```sql
SELECT column_name
FROM information_schema.columns
WHERE table_name = 'shifts'
AND column_name IN ('started_at', 'ended_at', 'total_break_minutes');
```

**Expected output:** (0 rows)

#### 3. Check index exists
```sql
SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'shifts' AND indexname = 'idx_shifts_date';
```

**Expected output:**
```
idx_shifts_date | CREATE INDEX idx_shifts_date ON public.shifts USING btree (clock_in)
```

## Testing

### Test Insert
```sql
-- Test inserting a new shift with new column names
INSERT INTO shifts (venue_id, employee_id, clock_in, break_minutes)
SELECT
    v.id,
    e.id,
    NOW(),
    0
FROM venues v
CROSS JOIN employees e
LIMIT 1
RETURNING id, clock_in, clock_out, break_start, break_minutes;
```

### Test Update
```sql
-- Test updating a shift (clock out)
UPDATE shifts
SET clock_out = NOW(),
    break_minutes = 30
WHERE id = (SELECT id FROM shifts ORDER BY created_at DESC LIMIT 1)
RETURNING id, clock_in, clock_out, break_minutes;
```

### Test Break Tracking
```sql
-- Test break tracking
UPDATE shifts
SET break_start = NOW()
WHERE id = (SELECT id FROM shifts ORDER BY created_at DESC LIMIT 1)
RETURNING id, break_start, break_minutes;

-- Complete break
UPDATE shifts
SET break_minutes = EXTRACT(EPOCH FROM (NOW() - break_start)) / 60
WHERE id = (SELECT id FROM shifts ORDER BY created_at DESC LIMIT 1)
RETURNING id, break_start, break_minutes;
```

## Rollback

If you need to revert the migration:

```sql
\i supabase/migrations/20251225234705_fix_shifts_columns_rollback.sql
```

**WARNING:** The rollback script has the `break_start` column removal commented out to prevent data loss. Uncomment only if you're sure you want to delete that data.

## Features

### Idempotent Design
- Safe to run multiple times
- Checks if columns exist before renaming
- Skips operations if already completed
- No errors if run on already-migrated database

### Safety Features
- DO blocks with conditional logic
- RAISE NOTICE for visibility
- No data loss during rename operations
- Rollback script for emergency use

### Integration
- Updates audit triggers automatically
- Maintains RLS policies
- Preserves indexes
- Compatible with existing application code

## Impact on Application Code

After running this migration, update your application code to use the new column names:

### Old Code
```typescript
const shift = {
  started_at: new Date(),
  ended_at: null,
  total_break_minutes: 0
};
```

### New Code
```typescript
const shift = {
  clock_in: new Date(),
  clock_out: null,
  break_start: null,
  break_minutes: 0
};
```

## Notes

- The migration is designed to work whether the old columns exist or the new ones are already in place
- All NOTICE messages are logged during execution for debugging
- The index on `clock_in` is recreated to ensure optimal query performance
- No data is lost during the migration process

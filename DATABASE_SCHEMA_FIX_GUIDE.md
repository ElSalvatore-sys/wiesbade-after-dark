# Database Schema Fix Guide: Shifts Table

## Executive Summary

### The Issue
The shifts table has a **critical schema mismatch** between the database and application code that prevents the clock in/out feature from working:

**Database Schema (Actual):**
- `clock_in` (TIMESTAMPTZ)
- `clock_out` (TIMESTAMPTZ)
- `break_start` (TIMESTAMPTZ)
- `break_minutes` (INTEGER)

**Backend Code Expectations (shifts.py):**
- `started_at` (TIMESTAMPTZ)
- `ended_at` (TIMESTAMPTZ)
- `employee_name` (VARCHAR)
- `employee_role` (VARCHAR)
- `total_break_minutes` (INTEGER)

**Frontend Code Expectations (Owner PWA):**
- Matches database schema (uses `clock_in`, `clock_out`, `break_start`)

### Impact
- **HIGH SEVERITY**: Clock in/out functionality completely broken in backend API
- Backend queries fail because columns don't exist
- Frontend works with direct Supabase queries but backend API endpoints fail
- Affects employee time tracking, shift management, and payroll calculations

---

## Solution Approaches

### Approach 1: Fix Database Schema (RECOMMENDED)

**Pros:**
- Aligns with backend code conventions (`started_at`, `ended_at`)
- Consistent with other tables (tasks, inventory_counts use `created_at`, `updated_at`)
- Better semantic clarity for shift timing
- No code changes needed in backend

**Cons:**
- Requires database migration
- Must update frontend code to use new column names
- Existing data must be migrated
- Requires coordination between frontend and backend deployment

**Effort:** Medium (2-3 hours)

### Approach 2: Fix Backend Code

**Pros:**
- No database changes required
- Frontend already works with current schema
- Faster to implement

**Cons:**
- Inconsistent naming across codebase
- `clock_in`/`clock_out` less clear than `started_at`/`ended_at`
- Missing columns (`employee_name`, `employee_role`) still need to be handled
- May confuse future developers

**Effort:** Low (1 hour)

---

## Recommended Approach: Fix Database Schema

This guide will focus on **Approach 1** as it provides long-term consistency and maintainability.

---

## Step-by-Step Implementation

### Prerequisites

1. **Backup Production Database**
   ```bash
   # If using Supabase CLI
   supabase db dump --db-url "postgresql://..." > backup_$(date +%Y%m%d).sql
   ```

2. **Test Access to Database**
   ```bash
   # Verify connection
   psql "postgresql://..." -c "SELECT COUNT(*) FROM shifts;"
   ```

3. **Schedule Maintenance Window**
   - Inform users of brief downtime
   - Best time: Low-traffic period (e.g., 3 AM - 4 AM)

---

### Migration Script

Create file: `supabase/migrations/008_fix_shifts_schema.sql`

```sql
-- =============================================
-- Migration: Fix Shifts Table Schema
-- Date: 2025-12-25
-- Description: Align column names with backend code
-- =============================================

BEGIN;

-- Step 1: Add new columns with correct names
ALTER TABLE shifts
  ADD COLUMN IF NOT EXISTS started_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS ended_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS employee_name VARCHAR(255),
  ADD COLUMN IF NOT EXISTS employee_role VARCHAR(50),
  ADD COLUMN IF NOT EXISTS total_break_minutes INTEGER DEFAULT 0;

-- Step 2: Migrate data from old columns to new columns
UPDATE shifts
SET
  started_at = clock_in,
  ended_at = clock_out,
  total_break_minutes = COALESCE(break_minutes, 0);

-- Step 3: Populate employee_name and employee_role from employees table
UPDATE shifts s
SET
  employee_name = e.name,
  employee_role = e.role
FROM employees e
WHERE s.employee_id = e.id;

-- Step 4: Set NOT NULL constraints where appropriate
ALTER TABLE shifts
  ALTER COLUMN started_at SET NOT NULL,
  ALTER COLUMN employee_name SET NOT NULL,
  ALTER COLUMN employee_role SET NOT NULL;

-- Step 5: Update indexes
DROP INDEX IF EXISTS idx_shifts_date;
CREATE INDEX idx_shifts_started_at ON shifts(started_at);

-- Step 6: Drop old columns (after verifying migration)
-- CAUTION: Uncomment only after verifying data migration
-- ALTER TABLE shifts
--   DROP COLUMN clock_in,
--   DROP COLUMN clock_out,
--   DROP COLUMN break_minutes;

-- Step 7: Add constraint for valid employee roles
ALTER TABLE shifts
  ADD CONSTRAINT valid_employee_role
  CHECK (employee_role IN ('owner', 'manager', 'bartender', 'waiter', 'security', 'dj', 'cleaning'));

COMMIT;

-- Verification queries (run after migration)
-- SELECT COUNT(*) FROM shifts WHERE started_at IS NULL; -- Should be 0
-- SELECT COUNT(*) FROM shifts WHERE employee_name IS NULL; -- Should be 0
-- SELECT COUNT(*) FROM shifts WHERE started_at != clock_in; -- Should be 0 (if old columns still exist)
```

---

### Execute Migration

#### Option A: Using Supabase CLI (Recommended)

```bash
# 1. Navigate to project directory
cd /Users/eldiaploo/Desktop/Projects-2025/WiesbadenAfterDark

# 2. Create migration file
cat > supabase/migrations/008_fix_shifts_schema.sql << 'EOF'
[Paste migration script from above]
EOF

# 3. Apply migration to local database (test first)
supabase db reset

# 4. Verify migration worked
supabase db dump --data-only -t shifts

# 5. Apply to production
supabase db push
```

#### Option B: Manual SQL Execution

```bash
# 1. Connect to database
psql "your-production-database-url"

# 2. Run migration script
\i supabase/migrations/008_fix_shifts_schema.sql

# 3. Verify
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'shifts';
```

---

### Update Frontend Code

File: `owner-pwa/src/lib/supabase.ts`

```typescript
// Update Shift interface
export interface Shift {
  id: string;
  venue_id: string;
  employee_id: string;
  employee_name: string;        // NEW
  employee_role: string;        // NEW
  started_at: string;           // RENAMED from clock_in
  ended_at: string | null;      // RENAMED from clock_out
  break_start: string | null;   // Keep for break tracking
  total_break_minutes: number;  // RENAMED from break_minutes
  expected_hours: number;
  actual_hours: number | null;
  overtime_minutes: number;
  status: 'active' | 'on_break' | 'completed' | 'cancelled';
  notes: string | null;
  created_at: string;
  updated_at: string;
}
```

File: `owner-pwa/src/pages/Shifts.tsx`

```typescript
// Update toActiveShift function (line 54)
function toActiveShift(shift: Shift): ActiveShift {
  const startedAt = new Date(shift.started_at); // Changed from clock_in
  const now = new Date();
  const elapsedMinutes = Math.floor((now.getTime() - startedAt.getTime()) / 60000);

  return {
    id: shift.id,
    employeeId: shift.employee_id,
    employeeName: shift.employee_name, // Now from database
    employeeRole: shift.employee_role, // Now from database
    startedAt: shift.started_at,
    expectedHours: shift.expected_hours,
    elapsedMinutes,
    isOnBreak: !!shift.break_start,
    totalBreakMinutes: shift.total_break_minutes, // Changed from break_minutes
    status: shift.break_start ? 'on_break' : (shift.status as ShiftStatus),
  };
}

// Update toShiftRecord function (line 74)
function toShiftRecord(shift: Shift): ShiftRecord {
  const startedAt = new Date(shift.started_at); // Changed from clock_in
  const endedAt = shift.ended_at ? new Date(shift.ended_at) : null; // Changed from clock_out

  return {
    id: shift.id,
    employeeId: shift.employee_id,
    employeeName: shift.employee_name, // Now from database
    employeeRole: shift.employee_role, // Now from database
    date: startedAt.toISOString().split('T')[0],
    clockIn: startedAt.toLocaleTimeString('de-DE', { hour: '2-digit', minute: '2-digit' }),
    clockOut: endedAt?.toLocaleTimeString('de-DE', { hour: '2-digit', minute: '2-digit' }) || '',
    breakMinutes: shift.total_break_minutes, // Changed from break_minutes
    totalHours: shift.actual_hours || 0,
    overtime: Math.floor((shift.overtime_minutes || 0) / 60),
  };
}
```

File: `owner-pwa/src/services/supabaseApi.ts`

```typescript
// Update startBreak function (line 202)
export async function startBreak(shiftId: string) {
  const { data, error } = await supabase
    .from('shifts')
    .update({
      break_start: new Date().toISOString(),
      status: 'on_break', // Add status update
    })
    .eq('id', shiftId)
    .select()
    .single();

  return { data, error };
}

// Update endBreak function (line 214)
export async function endBreak(shiftId: string) {
  // Get current shift to calculate break duration
  const { data: shift } = await supabase
    .from('shifts')
    .select('break_start, total_break_minutes') // Changed from break_minutes
    .eq('id', shiftId)
    .single();

  if (!shift || !shift.break_start) {
    return { data: null, error: new Error('No active break found') };
  }

  const breakEnd = new Date();
  const breakStart = new Date(shift.break_start);
  const breakDuration = Math.floor((breakEnd.getTime() - breakStart.getTime()) / 60000);
  const totalBreakMinutes = (shift.total_break_minutes || 0) + breakDuration; // Changed

  const { data, error } = await supabase
    .from('shifts')
    .update({
      break_start: null,
      total_break_minutes: totalBreakMinutes, // Changed from break_minutes
      status: 'active', // Add status update
    })
    .eq('id', shiftId)
    .select()
    .single();

  return { data, error };
}

// Update getShiftsSummary function (line 267)
export async function getShiftsSummary(): Promise<ShiftSummary> {
  const { data: shifts } = await supabase
    .from('shifts')
    .select('*')
    .in('status', ['active', 'on_break', 'completed']);

  if (!shifts) {
    return {
      activeShifts: 0,
      totalHoursToday: 0,
      totalOvertimeToday: 0,
      employeesOnBreak: 0,
    };
  }

  let activeShifts = 0;
  let totalHoursToday = 0;
  let totalOvertimeToday = 0;
  let employeesOnBreak = 0;

  const today = new Date().toISOString().split('T')[0];

  for (const shift of shifts) {
    const shiftDate = shift.started_at.split('T')[0]; // Changed from clock_in

    if (shift.status === 'active' || shift.status === 'on_break') {
      activeShifts++;
    }

    if (shiftDate === today && shift.actual_hours) {
      totalHoursToday += shift.actual_hours;

      const workingMinutes = shift.actual_hours * 60 - (shift.total_break_minutes || 0); // Changed
      if (workingMinutes > shift.expected_hours * 60) {
        totalOvertimeToday += workingMinutes - (shift.expected_hours * 60);
      }
    }

    if (shift.break_start) {
      employeesOnBreak++;
    }
  }

  return {
    activeShifts,
    totalHoursToday,
    totalOvertimeToday,
    employeesOnBreak,
  };
}
```

---

### Verification Steps

Run these queries after migration:

```sql
-- 1. Verify all shifts have started_at
SELECT COUNT(*) FROM shifts WHERE started_at IS NULL;
-- Expected: 0

-- 2. Verify employee data populated
SELECT COUNT(*) FROM shifts WHERE employee_name IS NULL OR employee_role IS NULL;
-- Expected: 0

-- 3. Compare old and new columns (if old columns still exist)
SELECT
  COUNT(*) as total_shifts,
  COUNT(CASE WHEN started_at = clock_in THEN 1 END) as clock_in_matches,
  COUNT(CASE WHEN ended_at = clock_out OR (ended_at IS NULL AND clock_out IS NULL) THEN 1 END) as clock_out_matches,
  COUNT(CASE WHEN total_break_minutes = break_minutes THEN 1 END) as break_minutes_matches
FROM shifts;
-- Expected: All counts should equal total_shifts

-- 4. Verify indexes
SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'shifts';

-- 5. Test a query that backend uses
SELECT id, venue_id, employee_id, employee_name, employee_role, started_at, ended_at,
       expected_hours, actual_hours, overtime_minutes, status, total_break_minutes, notes, created_at
FROM shifts
WHERE status IN ('active', 'on_break')
LIMIT 5;
```

---

## Testing Checklist

### Backend API Tests

```bash
# 1. Test clock in
curl -X POST http://localhost:8000/api/v1/shifts/venues/{venue_id}/shifts/clock-in \
  -H "Content-Type: application/json" \
  -d '{"employee_id": "test-id", "pin": "1234", "expected_hours": 8.0}'

# 2. Test get active shifts
curl http://localhost:8000/api/v1/shifts/venues/{venue_id}/shifts/active

# 3. Test start break
curl -X POST http://localhost:8000/api/v1/shifts/venues/{venue_id}/shifts/{shift_id}/break/start

# 4. Test end break
curl -X POST http://localhost:8000/api/v1/shifts/venues/{venue_id}/shifts/{shift_id}/break/end

# 5. Test clock out
curl -X POST http://localhost:8000/api/v1/shifts/venues/{venue_id}/shifts/{shift_id}/clock-out \
  -H "Content-Type: application/json" \
  -d '{"notes": "Completed shift"}'
```

### Frontend Tests

See `TEST_CLOCK_IN_OUT.md` for comprehensive manual testing checklist.

---

## Rollback Plan

If issues occur, see `ROLLBACK_PLAN.md` for detailed rollback procedures.

Quick rollback:

```sql
BEGIN;

-- Restore from old columns
UPDATE shifts
SET
  clock_in = started_at,
  clock_out = ended_at,
  break_minutes = total_break_minutes;

-- Drop new columns
ALTER TABLE shifts
  DROP COLUMN started_at,
  DROP COLUMN ended_at,
  DROP COLUMN employee_name,
  DROP COLUMN employee_role,
  DROP COLUMN total_break_minutes;

-- Restore index
DROP INDEX IF EXISTS idx_shifts_started_at;
CREATE INDEX idx_shifts_date ON shifts(clock_in);

COMMIT;
```

---

## Troubleshooting

### Issue: Migration fails with "column already exists"

**Solution:** Columns were partially created. Run this cleanup:

```sql
-- Check what exists
SELECT column_name FROM information_schema.columns WHERE table_name = 'shifts';

-- Drop only columns that exist
ALTER TABLE shifts DROP COLUMN IF EXISTS started_at;
-- Repeat for other columns, then re-run migration
```

### Issue: Frontend shows missing data after migration

**Solution:** Clear browser cache and refresh:

```javascript
// In browser console
localStorage.clear();
sessionStorage.clear();
location.reload(true);
```

### Issue: Backend still uses old column names

**Solution:** Verify backend code was updated and server restarted:

```bash
# Check for old column references
grep -r "clock_in" backend/app/

# Restart backend
cd backend
uvicorn app.main:app --reload
```

### Issue: Data migration incomplete

**Solution:** Re-run data migration step:

```sql
-- Verify employee join works
SELECT s.id, e.name, e.role
FROM shifts s
JOIN employees e ON s.employee_id = e.id
LIMIT 5;

-- Re-run migration
UPDATE shifts s
SET
  employee_name = e.name,
  employee_role = e.role
FROM employees e
WHERE s.employee_id = e.id
  AND s.employee_name IS NULL;
```

---

## Post-Migration Checklist

- [ ] Database migration completed successfully
- [ ] All verification queries passed
- [ ] Frontend code updated and deployed
- [ ] Backend code verified (already correct)
- [ ] Backend API tests passed
- [ ] Frontend manual tests passed
- [ ] Production deployment successful
- [ ] No errors in application logs
- [ ] Old columns dropped (after 7 days of stable operation)
- [ ] Backup created and stored securely
- [ ] Documentation updated

---

## Next Steps

1. **Immediate:** Test migration on local/staging environment
2. **Week 1:** Deploy to production during maintenance window
3. **Week 2:** Monitor for issues, keep old columns as backup
4. **Week 3:** Drop old columns if no issues detected

---

## Additional Resources

- Backend Code: `/backend/app/api/v1/endpoints/shifts.py`
- Frontend Code: `/owner-pwa/src/pages/Shifts.tsx`
- Database Schema: `/supabase/migrations/001_production_tables.sql`
- Rollback Guide: `ROLLBACK_PLAN.md`
- Test Plan: `TEST_CLOCK_IN_OUT.md`

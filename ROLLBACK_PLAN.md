# Rollback Plan: Shifts Table Schema Fix

## Overview

This document provides detailed procedures for rolling back the shifts table schema migration if issues are encountered during or after deployment.

---

## When to Rollback

Execute a rollback if you encounter any of these situations:

### Critical Issues (Immediate Rollback)
- Data loss detected (shift records missing or corrupted)
- Clock in/out functionality completely broken in production
- Database errors preventing application from starting
- Cascading failures affecting other tables

### Major Issues (Rollback within 1 hour)
- More than 50% of shift operations failing
- Incorrect shift data being displayed to users
- Performance degradation (queries taking 10x longer)
- RLS policies broken, causing unauthorized access

### Minor Issues (Consider rollback)
- Intermittent failures (less than 10% error rate)
- UI display issues
- Non-critical features broken
- Migration not fully complete but application still functional

---

## Pre-Rollback Checklist

Before executing rollback, complete these steps:

1. **Document the Issue**
   ```bash
   # Capture error logs
   tail -n 200 /var/log/application.log > rollback_reason_$(date +%Y%m%d_%H%M%S).log

   # Screenshot errors in UI
   # Take database snapshots
   ```

2. **Verify Rollback is Necessary**
   ```sql
   -- Check if data exists in new columns
   SELECT COUNT(*) FROM shifts WHERE started_at IS NOT NULL;

   -- Check if old columns still exist
   SELECT column_name FROM information_schema.columns
   WHERE table_name = 'shifts' AND column_name IN ('clock_in', 'clock_out', 'break_minutes');
   ```

3. **Notify Stakeholders**
   - Inform technical team
   - Notify users of temporary service disruption
   - Set status page to "Incident in progress"

4. **Create Emergency Backup**
   ```bash
   pg_dump -t shifts "postgresql://..." > emergency_backup_$(date +%Y%m%d_%H%M%S).sql
   ```

---

## Rollback Scenarios

### Scenario 1: Old Columns Still Exist (SAFEST)

**When:** Migration completed but old columns not yet dropped

**Risk:** LOW

**Steps:**

```sql
BEGIN;

-- Step 1: Verify old columns have data
SELECT COUNT(*) FROM shifts WHERE clock_in IS NOT NULL;
-- Should match total shifts

-- Step 2: Update application tables to use old columns again
-- (This reverses any changes to data in new columns)

-- Step 3: Drop new columns
ALTER TABLE shifts
  DROP COLUMN IF EXISTS started_at,
  DROP COLUMN IF EXISTS ended_at,
  DROP COLUMN IF EXISTS employee_name,
  DROP COLUMN IF EXISTS employee_role,
  DROP COLUMN IF EXISTS total_break_minutes;

-- Step 4: Restore original index
DROP INDEX IF EXISTS idx_shifts_started_at;
CREATE INDEX idx_shifts_date ON shifts(clock_in);

-- Step 5: Verify schema
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'shifts'
ORDER BY ordinal_position;

COMMIT;
```

**Verification:**

```sql
-- Confirm old structure restored
SELECT id, clock_in, clock_out, break_start, break_minutes
FROM shifts
LIMIT 5;
```

---

### Scenario 2: Old Columns Dropped (MEDIUM RISK)

**When:** Old columns already dropped, data only in new columns

**Risk:** MEDIUM

**Steps:**

```sql
BEGIN;

-- Step 1: Rename new columns back to old names
ALTER TABLE shifts
  RENAME COLUMN started_at TO clock_in;

ALTER TABLE shifts
  RENAME COLUMN ended_at TO clock_out;

ALTER TABLE shifts
  RENAME COLUMN total_break_minutes TO break_minutes;

-- Step 2: Handle employee data (these columns didn't exist before)
-- Option A: Keep them (recommended, won't break anything)
-- Option B: Drop them if causing issues
ALTER TABLE shifts
  DROP COLUMN IF EXISTS employee_name,
  DROP COLUMN IF EXISTS employee_role;

-- Step 3: Restore index
DROP INDEX IF EXISTS idx_shifts_started_at;
CREATE INDEX idx_shifts_date ON shifts(clock_in);

-- Step 4: Drop any new constraints
ALTER TABLE shifts
  DROP CONSTRAINT IF EXISTS valid_employee_role;

-- Step 5: Verify schema
\d shifts

COMMIT;
```

**Verification:**

```sql
-- Confirm renamed columns work
SELECT id, clock_in, clock_out, break_minutes
FROM shifts
WHERE clock_in IS NOT NULL
LIMIT 5;
```

---

### Scenario 3: Data Corruption Detected (HIGH RISK)

**When:** Data in new columns is incorrect or lost

**Risk:** HIGH

**Steps:**

```sql
BEGIN;

-- Step 1: Restore from backup
-- IMPORTANT: Replace with your actual backup file
\i emergency_backup_YYYYMMDD_HHMMSS.sql

-- Step 2: Verify data restored
SELECT COUNT(*) FROM shifts;
-- Should match count before migration

-- Step 3: Check data integrity
SELECT id, clock_in, clock_out
FROM shifts
WHERE clock_in IS NOT NULL
ORDER BY created_at DESC
LIMIT 10;

COMMIT;
```

**Alternative: Restore from automated backup:**

```bash
# For Supabase
supabase db restore --project-ref your-project-ref --backup-id your-backup-id

# For PostgreSQL managed service
# Use provider's restore interface (AWS RDS, DigitalOcean, etc.)
```

---

### Scenario 4: Application Already Updated (CRITICAL)

**When:** Frontend code already deployed with new column names

**Risk:** CRITICAL (requires coordinated rollback)

**Steps:**

1. **Revert Frontend Code**
   ```bash
   cd owner-pwa

   # Option A: Revert git commit
   git log --oneline  # Find commit hash before migration
   git revert <commit-hash>
   git push

   # Option B: Redeploy previous version
   vercel rollback
   ```

2. **Revert Database** (choose scenario 1, 2, or 3 above)

3. **Verify Backend** (backend code should already be compatible)

4. **Clear CDN Cache** (if using Vercel/Cloudflare)
   ```bash
   # Vercel
   vercel --prod --force

   # Cloudflare
   curl -X POST "https://api.cloudflare.com/client/v4/zones/{zone_id}/purge_cache" \
     -H "Authorization: Bearer {api_token}" \
     -d '{"purge_everything":true}'
   ```

---

## Backend Code Rollback (if modified)

If backend code was changed to use new column names, revert to old version:

File: `backend/app/api/v1/endpoints/shifts.py`

```python
# Find these references and change back:

# OLD (working): clock_in, clock_out, break_minutes
# NEW (broken): started_at, ended_at, total_break_minutes

# Example query to revert:
result = await db.execute(
    text("""
        SELECT id, venue_id, employee_id, clock_in, clock_out,  -- REVERTED
               expected_hours, actual_hours, overtime_minutes, status, break_minutes, notes, created_at
        FROM shifts
        WHERE id = :shift_id AND venue_id = :venue_id
    """),
    {"shift_id": str(shift_id), "venue_id": str(venue_id)}
)
```

Then restart backend:

```bash
cd backend
pkill -f uvicorn  # Stop server
uvicorn app.main:app --reload  # Restart
```

---

## Frontend Code Rollback

File: `owner-pwa/src/lib/supabase.ts`

```typescript
// Revert Shift interface
export interface Shift {
  id: string;
  venue_id: string;
  employee_id: string;
  clock_in: string;              // REVERTED from started_at
  clock_out: string | null;      // REVERTED from ended_at
  break_start: string | null;
  break_minutes: number;         // REVERTED from total_break_minutes
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
// Revert toActiveShift function
function toActiveShift(shift: Shift & { employee: Employee }): ActiveShift {
  const clockIn = new Date(shift.clock_in);  // REVERTED
  const now = new Date();
  const elapsedMinutes = Math.floor((now.getTime() - clockIn.getTime()) / 60000);

  return {
    id: shift.id,
    employeeId: shift.employee_id,
    employeeName: shift.employee?.name || 'Unknown',  // REVERTED (join with employee)
    employeeRole: shift.employee?.role || 'staff',
    startedAt: shift.clock_in,  // REVERTED
    expectedHours: shift.expected_hours,
    elapsedMinutes,
    isOnBreak: !!shift.break_start,
    totalBreakMinutes: shift.break_minutes || 0,  // REVERTED
    status: shift.break_start ? 'on_break' : (shift.status as ShiftStatus),
  };
}
```

Deploy:

```bash
cd owner-pwa
npm run build
vercel --prod
```

---

## Post-Rollback Verification

### Database Verification

```sql
-- 1. Verify schema reverted
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'shifts'
ORDER BY ordinal_position;

-- Expected columns:
-- id, venue_id, employee_id, clock_in, clock_out, break_start, break_minutes,
-- expected_hours, actual_hours, overtime_minutes, status, notes, created_at, updated_at

-- 2. Verify data integrity
SELECT COUNT(*) FROM shifts;
SELECT COUNT(*) FROM shifts WHERE clock_in IS NULL;  -- Should be 0

-- 3. Verify indexes
SELECT indexname FROM pg_indexes WHERE tablename = 'shifts';
-- Should include: idx_shifts_date
```

### Application Verification

```bash
# 1. Test backend API
curl http://localhost:8000/api/v1/shifts/venues/{venue_id}/shifts/active

# 2. Check logs for errors
tail -f /var/log/application.log | grep -i error

# 3. Test frontend
# Open browser to owner PWA
# Navigate to Shifts page
# Verify active shifts display correctly
```

### User Acceptance Testing

- [ ] Clock in works
- [ ] Clock out works
- [ ] Break start works
- [ ] Break end works
- [ ] Shift history loads
- [ ] Export timesheet works
- [ ] No console errors
- [ ] No database errors in logs

---

## Communication Templates

### Internal Team Notification

```
Subject: URGENT - Shifts Migration Rollback Initiated

Team,

We are rolling back the shifts table schema migration due to [REASON].

Status: In Progress
ETA: [TIME]
Impact: Shift tracking may be unavailable during rollback

Will update in 15 minutes.

- [Your Name]
```

### User Notification

```
Subject: Brief Service Interruption - Shift Tracking

Dear Venue Owners,

We are experiencing a technical issue with shift tracking and are working to resolve it.

Expected Resolution: [TIME]
What You Can Do: Manual time tracking for now

We apologize for the inconvenience.

- WiesbadenAfterDark Support Team
```

---

## Lessons Learned Template

After rollback, document what happened:

```markdown
## Rollback Incident Report

**Date:** YYYY-MM-DD
**Duration:** HH:MM
**Affected Users:** X

### What Happened
[Description of issue that triggered rollback]

### Root Cause
[Technical reason for failure]

### What Went Wrong
-
-

### What Went Right
-
-

### Action Items
1. [ ]
2. [ ]

### Prevention Measures
-
-
```

---

## Emergency Contacts

| Role | Name | Contact |
|------|------|---------|
| Database Admin | [Name] | [Phone/Email] |
| Backend Lead | [Name] | [Phone/Email] |
| Frontend Lead | [Name] | [Phone/Email] |
| DevOps | [Name] | [Phone/Email] |
| Product Owner | [Name] | [Phone/Email] |

---

## Recovery Timeline

| Phase | Duration | Actions |
|-------|----------|---------|
| Detection | 0-5 min | Identify issue, verify severity |
| Decision | 5-10 min | Decide to rollback, notify team |
| Preparation | 10-15 min | Create backup, gather rollback scripts |
| Execution | 15-25 min | Run rollback SQL, verify database |
| Deployment | 25-35 min | Redeploy frontend/backend if needed |
| Verification | 35-45 min | Test all functionality |
| Monitoring | 45-60 min | Watch for errors, confirm stability |
| Communication | 60+ min | Notify users, write incident report |

**Total Expected Time:** 60-90 minutes

---

## Testing After Rollback

Use the manual test plan in `TEST_CLOCK_IN_OUT.md` to verify all functionality works after rollback.

Focus on:
- Clock in/out operations
- Break tracking
- Data accuracy
- Performance
- Error handling

---

## Prevention for Next Attempt

Before retrying the migration:

1. **Better Testing**
   - Test on exact production data copy
   - Run migration on staging for 48 hours
   - Load test with realistic traffic

2. **Phased Rollout**
   - Deploy to single venue first
   - Monitor for 24 hours
   - Gradually expand if successful

3. **Better Monitoring**
   - Add alerting for shift operations
   - Monitor error rates in real-time
   - Set up automatic rollback triggers

4. **Improved Migration**
   - Keep old columns for 30 days
   - Use database triggers for dual-write
   - Implement feature flags for gradual switchover

---

## Appendix: Useful Commands

### Check Table Size
```sql
SELECT pg_size_pretty(pg_total_relation_size('shifts'));
```

### Find Long-Running Queries
```sql
SELECT pid, now() - pg_stat_activity.query_start AS duration, query
FROM pg_stat_activity
WHERE state = 'active'
ORDER BY duration DESC;
```

### Kill Blocking Queries
```sql
SELECT pg_terminate_backend(pid)
FROM pg_stat_activity
WHERE datname = 'your_database' AND state = 'active' AND pid <> pg_backend_pid();
```

### Vacuum After Large Changes
```sql
VACUUM ANALYZE shifts;
```

---

**Remember:** It's better to rollback and try again later than to leave broken functionality in production. Don't hesitate to rollback if you're unsure.

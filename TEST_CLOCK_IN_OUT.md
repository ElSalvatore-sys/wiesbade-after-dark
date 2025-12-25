# Test Plan: Clock In/Out Feature

## Overview

This document provides a comprehensive manual testing checklist for the employee shift clock in/out feature after applying the database schema fix.

---

## Test Environment Setup

### Prerequisites

- [ ] Database migration completed successfully
- [ ] Frontend code deployed
- [ ] Backend server running
- [ ] Test venue created in database
- [ ] At least 3 test employees created with different roles
- [ ] Employee PINs configured

### Test Data Setup

```sql
-- Create test venue (if not exists)
INSERT INTO venues (id, name, location, type)
VALUES ('test-venue-001', 'Test Venue', 'Wiesbaden', 'bar')
ON CONFLICT (id) DO NOTHING;

-- Create test employees
INSERT INTO employees (id, venue_id, name, email, role, pin_hash, is_active)
VALUES
  ('emp-001', 'test-venue-001', 'Test Bartender', 'bartender@test.com', 'bartender', '$2b$12$...', true),
  ('emp-002', 'test-venue-001', 'Test Waiter', 'waiter@test.com', 'waiter', '$2b$12$...', true),
  ('emp-003', 'test-venue-001', 'Test Manager', 'manager@test.com', 'manager', '$2b$12$...', true)
ON CONFLICT (id) DO NOTHING;

-- Verify test data
SELECT id, name, role FROM employees WHERE venue_id = 'test-venue-001';
```

**Test PINs:**
- Bartender: 1234
- Waiter: 5678
- Manager: 9999

---

## Test Cases

### 1. Clock In Functionality

#### TC-001: Successful Clock In

**Objective:** Verify employee can clock in with valid credentials

**Prerequisites:**
- Employee not currently clocked in
- Valid PIN configured

**Steps:**
1. Open Owner PWA
2. Navigate to Shifts page
3. Click "Clock In" button
4. Select employee from dropdown (Test Bartender)
5. Enter PIN: 1-2-3-4
6. Click "Clock In" button

**Expected Results:**
- [ ] PIN input accepts numeric values only
- [ ] Each PIN digit auto-focuses to next box
- [ ] Clock In button enables when PIN complete
- [ ] Success: New shift appears in Active Shifts list
- [ ] Shift shows employee name correctly
- [ ] Shift shows "Active" status badge (green)
- [ ] Timer starts at 0h 00m
- [ ] Clock in modal closes automatically
- [ ] Summary card updates: Active Shifts count +1

**Actual Results:**
```
[ Pass / Fail ]
Notes: _______________
```

---

#### TC-002: Clock In with Wrong PIN

**Objective:** Verify invalid PIN is rejected

**Steps:**
1. Click "Clock In"
2. Select employee (Test Bartender)
3. Enter incorrect PIN: 0-0-0-0
4. Click "Clock In"

**Expected Results:**
- [ ] Error message displays: "Invalid PIN. Please try again."
- [ ] PIN fields remain visible
- [ ] Modal stays open
- [ ] No shift created
- [ ] Can retry with correct PIN

**Actual Results:**
```
[ Pass / Fail ]
Notes: _______________
```

---

#### TC-003: Clock In Without Selecting Employee

**Objective:** Verify validation prevents clock in without employee selection

**Steps:**
1. Click "Clock In"
2. Leave employee dropdown at "Choose employee..."
3. Try to enter PIN

**Expected Results:**
- [ ] PIN inputs are disabled or hidden
- [ ] Clock In button is disabled
- [ ] No error message (graceful prevention)

**Actual Results:**
```
[ Pass / Fail ]
Notes: _______________
```

---

#### TC-004: Clock In - Already Active Shift

**Objective:** Verify employee cannot clock in twice

**Steps:**
1. Clock in employee (Test Bartender) successfully
2. Try to clock in same employee again

**Expected Results:**
- [ ] Error message: "Employee already has an active shift"
- [ ] No duplicate shift created
- [ ] Original shift remains active

**Actual Results:**
```
[ Pass / Fail ]
Notes: _______________
```

---

#### TC-005: Clock In - PIN Paste Functionality

**Objective:** Verify PIN can be pasted

**Steps:**
1. Click "Clock In"
2. Select employee
3. Copy "1234" to clipboard
4. Click first PIN input
5. Paste (Cmd+V or Ctrl+V)

**Expected Results:**
- [ ] All 4 digits fill automatically
- [ ] Focus moves to last digit
- [ ] Can proceed to clock in
- [ ] Non-numeric characters are stripped

**Actual Results:**
```
[ Pass / Fail ]
Notes: _______________
```

---

#### TC-006: Clock In - Multiple Employees

**Objective:** Verify multiple employees can be active simultaneously

**Steps:**
1. Clock in Test Bartender (PIN: 1234)
2. Clock in Test Waiter (PIN: 5678)
3. Clock in Test Manager (PIN: 9999)

**Expected Results:**
- [ ] All 3 employees appear in Active Shifts
- [ ] Each has independent timer
- [ ] Summary shows "3" active shifts
- [ ] Shifts are ordered by clock in time (newest first)

**Actual Results:**
```
[ Pass / Fail ]
Notes: _______________
```

---

### 2. Break Tracking

#### TC-007: Start Break

**Objective:** Verify employee can start a break

**Prerequisites:**
- Employee clocked in and active

**Steps:**
1. Locate active shift in list
2. Click "Start Break" button

**Expected Results:**
- [ ] Status changes to "On Break" (yellow badge)
- [ ] Button changes to "End Break"
- [ ] Timer continues running
- [ ] Summary card: Employees on Break = 1
- [ ] Shift card highlights differently (yellow tint)

**Actual Results:**
```
[ Pass / Fail ]
Notes: _______________
```

---

#### TC-008: End Break

**Objective:** Verify employee can end a break

**Prerequisites:**
- Employee on break

**Steps:**
1. Locate shift with "On Break" status
2. Click "End Break" button
3. Wait 5 seconds
4. Check timer

**Expected Results:**
- [ ] Status changes back to "Active" (green badge)
- [ ] Button changes back to "Start Break"
- [ ] Break minutes tracked correctly
- [ ] Summary: Employees on Break = 0
- [ ] Timer continues from where it left off

**Actual Results:**
```
[ Pass / Fail ]
Notes: _______________
```

---

#### TC-009: Multiple Breaks

**Objective:** Verify employee can take multiple breaks in one shift

**Steps:**
1. Start break (wait 2 minutes)
2. End break
3. Start another break (wait 3 minutes)
4. End break
5. Check total break minutes

**Expected Results:**
- [ ] First break duration recorded
- [ ] Second break duration recorded
- [ ] Total break minutes = sum of both breaks (5 min)
- [ ] Working time excludes break time

**Actual Results:**
```
[ Pass / Fail ]
Notes: _______________
```

---

#### TC-010: Break During Clock Out

**Objective:** Verify break is automatically ended when clocking out

**Steps:**
1. Start break
2. Immediately click "Clock Out"

**Expected Results:**
- [ ] Break ends automatically
- [ ] Break duration recorded (even if short)
- [ ] Shift completes successfully
- [ ] Total break minutes included in history

**Actual Results:**
```
[ Pass / Fail ]
Notes: _______________
```

---

### 3. Clock Out Functionality

#### TC-011: Normal Clock Out

**Objective:** Verify employee can clock out successfully

**Prerequisites:**
- Employee clocked in with active shift

**Steps:**
1. Click "Clock Out" button on active shift
2. Observe changes

**Expected Results:**
- [ ] Shift removed from Active Shifts list
- [ ] Summary: Active Shifts count -1
- [ ] Shift appears in History
- [ ] Actual hours calculated correctly
- [ ] Total break time recorded
- [ ] Overtime calculated if applicable

**Actual Results:**
```
[ Pass / Fail ]
Notes: _______________
```

---

#### TC-012: Clock Out with Overtime

**Objective:** Verify overtime is calculated correctly

**Steps:**
1. Clock in employee with expected_hours = 8.0
2. Wait or manually set started_at to 9 hours ago
3. Clock out

**Expected Results:**
- [ ] Actual hours = 9.0
- [ ] Overtime = 60 minutes (1 hour)
- [ ] Overtime indicator shows (red alert icon)
- [ ] Summary: Total Overtime Today updated

**Actual Results:**
```
[ Pass / Fail ]
Notes: _______________
```

---

#### TC-013: Clock Out Under Expected Hours

**Objective:** Verify normal clock out for short shift

**Steps:**
1. Clock in employee (expected 8 hours)
2. Clock out after 4 hours

**Expected Results:**
- [ ] Actual hours = 4.0
- [ ] Overtime = 0 minutes
- [ ] No overtime indicator
- [ ] Shift marked as "Completed"

**Actual Results:**
```
[ Pass / Fail ]
Notes: _______________
```

---

### 4. Timer Accuracy

#### TC-014: Timer Updates

**Objective:** Verify timer updates in real-time

**Steps:**
1. Clock in employee
2. Watch timer for 60 seconds

**Expected Results:**
- [ ] Timer updates every second
- [ ] Format is correct: "0h 01m" after 1 minute
- [ ] No jumping or flickering
- [ ] Multiple shift timers update independently

**Actual Results:**
```
[ Pass / Fail ]
Notes: _______________
```

---

#### TC-015: Timer After Page Refresh

**Objective:** Verify timer accuracy persists after reload

**Steps:**
1. Clock in employee
2. Note current timer value
3. Refresh page (F5)
4. Check timer value

**Expected Results:**
- [ ] Timer continues from correct time
- [ ] No reset to 00:00
- [ ] Break time preserved
- [ ] Status preserved

**Actual Results:**
```
[ Pass / Fail ]
Notes: _______________
```

---

#### TC-016: Break Time Exclusion

**Objective:** Verify break time excluded from working time

**Steps:**
1. Clock in employee
2. Wait 10 minutes
3. Start break, wait 5 minutes
4. End break
5. Check timer

**Expected Results:**
- [ ] Elapsed time = 15 minutes total
- [ ] Working time = 10 minutes (excluding 5-min break)
- [ ] Timer shows working time, not total elapsed
- [ ] Break minutes tracked separately

**Actual Results:**
```
[ Pass / Fail ]
Notes: _______________
```

---

### 5. Shift History

#### TC-017: View Shift History

**Objective:** Verify completed shifts appear in history

**Prerequisites:**
- At least 3 completed shifts exist

**Steps:**
1. Click History icon (clock with arrow)
2. Review shift list

**Expected Results:**
- [ ] Modal opens with shift history
- [ ] Shows last 20 shifts
- [ ] Displays: employee name, date, times, hours
- [ ] Sorted by date (newest first)
- [ ] Clock in and clock out times formatted correctly
- [ ] Overtime shown in red if applicable

**Actual Results:**
```
[ Pass / Fail ]
Notes: _______________
```

---

#### TC-018: Filter History by Date

**Objective:** Verify history shows correct date range

**Steps:**
1. Create shifts on different days
2. Open history
3. Check date range

**Expected Results:**
- [ ] Shows shifts from last 14 days
- [ ] Older shifts not displayed
- [ ] Date format is German (DD.MM.YYYY)

**Actual Results:**
```
[ Pass / Fail ]
Notes: _______________
```

---

### 6. Summary Dashboard

#### TC-019: Summary Cards Update

**Objective:** Verify summary statistics update correctly

**Steps:**
1. Note initial summary values
2. Clock in an employee
3. Start a break
4. Clock out

**Expected Results:**

**After Clock In:**
- [ ] Active Shifts: +1
- [ ] Hours Today: unchanged (shift not complete)
- [ ] On Break: 0
- [ ] Overtime: unchanged

**After Start Break:**
- [ ] Active Shifts: unchanged
- [ ] On Break: +1

**After Clock Out:**
- [ ] Active Shifts: -1
- [ ] Hours Today: +actual hours
- [ ] On Break: 0
- [ ] Overtime: updated if applicable

**Actual Results:**
```
[ Pass / Fail ]
Notes: _______________
```

---

#### TC-020: Summary Calculations

**Objective:** Verify summary totals are accurate

**Setup:**
1. Clock in Employee A at 8:00 AM
2. Clock in Employee B at 9:00 AM
3. Clock out Employee A at 5:00 PM (9 hours, 1 hr overtime)
4. Employee B still active

**Expected Results:**
- [ ] Active Shifts: 1 (Employee B)
- [ ] Hours Today: 9.0 (only completed shifts count)
- [ ] Overtime: 60 minutes
- [ ] On Break: 0

**Actual Results:**
```
[ Pass / Fail ]
Notes: _______________
```

---

### 7. Export Functionality

#### TC-021: Export Timesheet

**Objective:** Verify timesheet export works

**Prerequisites:**
- At least 5 completed shifts in last 14 days

**Steps:**
1. Click Export icon (file download)
2. Select date range
3. Click "Export to CSV"
4. Open downloaded file

**Expected Results:**
- [ ] Export modal opens
- [ ] Date range selector works
- [ ] CSV file downloads
- [ ] File contains all shifts in range
- [ ] Columns: Date, Employee, Clock In, Clock Out, Break, Hours, Overtime
- [ ] Data formatted correctly
- [ ] Can open in Excel/Google Sheets

**Actual Results:**
```
[ Pass / Fail ]
Notes: _______________
```

---

### 8. Real-Time Updates (Supabase Realtime)

#### TC-022: Multi-Device Sync

**Objective:** Verify changes sync across devices

**Setup:**
- Open Owner PWA on two different browsers/devices

**Steps:**
1. On Device A: Clock in employee
2. On Device B: Observe shifts page

**Expected Results:**
- [ ] Device B shows new shift within 2 seconds
- [ ] No manual refresh needed
- [ ] Timer starts on both devices
- [ ] Summary updates on both devices

**Actual Results:**
```
[ Pass / Fail ]
Notes: _______________
```

---

#### TC-023: Concurrent Operations

**Objective:** Verify concurrent actions don't conflict

**Steps:**
1. On Device A: Start break for Employee 1
2. On Device B: Clock out Employee 2 (at same time)

**Expected Results:**
- [ ] Both operations succeed
- [ ] No conflicts or errors
- [ ] Both devices show correct states
- [ ] No data loss

**Actual Results:**
```
[ Pass / Fail ]
Notes: _______________
```

---

### 9. Edge Cases

#### TC-024: Midnight Shift

**Objective:** Verify shifts spanning midnight work correctly

**Steps:**
1. Clock in at 11:00 PM
2. Clock out at 2:00 AM next day

**Expected Results:**
- [ ] Shift duration = 3 hours
- [ ] Both dates shown in history
- [ ] Hours counted in correct day
- [ ] Summary calculations correct

**Actual Results:**
```
[ Pass / Fail ]
Notes: _______________
```

---

#### TC-025: Very Long Shift

**Objective:** Verify system handles 12+ hour shifts

**Steps:**
1. Clock in employee
2. Manually set started_at to 15 hours ago
3. Clock out

**Expected Results:**
- [ ] Actual hours = 15.0
- [ ] Overtime = 7 hours (420 min)
- [ ] No errors or overflow
- [ ] Red overtime warning displayed

**Actual Results:**
```
[ Pass / Fail ]
Notes: _______________
```

---

#### TC-026: Zero Duration Break

**Objective:** Verify immediate break end works

**Steps:**
1. Start break
2. Immediately (within 1 second) end break

**Expected Results:**
- [ ] Break duration = 0 or 1 minute
- [ ] No error
- [ ] Can start another break

**Actual Results:**
```
[ Pass / Fail ]
Notes: _______________
```

---

#### TC-027: Database Connection Loss

**Objective:** Verify graceful handling of connection issues

**Steps:**
1. Disconnect internet/stop Supabase
2. Try to clock in
3. Reconnect
4. Retry

**Expected Results:**
- [ ] Error message displays
- [ ] No data loss
- [ ] Can retry when connection restored
- [ ] Appropriate user feedback

**Actual Results:**
```
[ Pass / Fail ]
Notes: _______________
```

---

### 10. UI/UX Testing

#### TC-028: Responsive Design

**Objective:** Verify UI works on different screen sizes

**Steps:**
1. Test on desktop (1920x1080)
2. Test on tablet (768x1024)
3. Test on mobile (375x667)

**Expected Results:**
- [ ] All elements visible and usable
- [ ] No horizontal scrolling
- [ ] Buttons are tappable (44x44px minimum)
- [ ] Text is readable
- [ ] Modals fit screen

**Actual Results:**
```
Desktop: [ Pass / Fail ]
Tablet: [ Pass / Fail ]
Mobile: [ Pass / Fail ]
Notes: _______________
```

---

#### TC-029: Accessibility

**Objective:** Verify keyboard navigation works

**Steps:**
1. Navigate to Shifts page using Tab key only
2. Clock in using keyboard
3. Tab through PIN inputs

**Expected Results:**
- [ ] All interactive elements reachable via Tab
- [ ] Focus indicators visible
- [ ] Enter key triggers actions
- [ ] PIN inputs support arrow keys
- [ ] Escape closes modals

**Actual Results:**
```
[ Pass / Fail ]
Notes: _______________
```

---

#### TC-030: Loading States

**Objective:** Verify appropriate loading indicators

**Steps:**
1. Slow down network (Chrome DevTools: Network > Slow 3G)
2. Navigate to Shifts
3. Click "Clock In"

**Expected Results:**
- [ ] Loading spinner on initial page load
- [ ] "Clocking In..." shown during clock in
- [ ] Disabled buttons during operations
- [ ] Skeleton loaders for shift cards
- [ ] No blank screens

**Actual Results:**
```
[ Pass / Fail ]
Notes: _______________
```

---

### 11. Data Integrity

#### TC-031: Database Consistency

**Objective:** Verify database data matches UI

**Steps:**
1. Clock in employee
2. Query database directly
3. Compare with UI

**SQL Query:**
```sql
SELECT id, employee_id, employee_name, employee_role,
       started_at, ended_at, break_start, total_break_minutes,
       status, actual_hours, overtime_minutes
FROM shifts
WHERE status IN ('active', 'on_break')
ORDER BY started_at DESC;
```

**Expected Results:**
- [ ] All active shifts in database match UI
- [ ] Timestamps accurate
- [ ] Status matches UI badge
- [ ] Break tracking consistent
- [ ] Employee data populated correctly

**Actual Results:**
```
[ Pass / Fail ]
Notes: _______________
```

---

#### TC-032: Audit Trail

**Objective:** Verify shift changes are logged

**Steps:**
1. Clock in employee
2. Start break
3. End break
4. Clock out
5. Check audit_logs table

**SQL Query:**
```sql
SELECT table_name, action, old_data, new_data, changed_by
FROM audit_logs
WHERE table_name = 'shifts'
ORDER BY created_at DESC
LIMIT 10;
```

**Expected Results:**
- [ ] INSERT log for clock in
- [ ] UPDATE logs for break start/end
- [ ] UPDATE log for clock out
- [ ] All changes tracked
- [ ] Timestamps accurate

**Actual Results:**
```
[ Pass / Fail ]
Notes: _______________
```

---

## Performance Testing

### PT-001: Page Load Time

**Objective:** Verify shifts page loads quickly

**Steps:**
1. Clear browser cache
2. Open DevTools Network tab
3. Navigate to Shifts page
4. Measure load time

**Expected Results:**
- [ ] Initial load: < 2 seconds
- [ ] Active shifts query: < 500ms
- [ ] Summary calculation: < 300ms

**Actual Results:**
```
Load Time: _____ ms
[ Pass / Fail ]
```

---

### PT-002: Timer Performance

**Objective:** Verify timers don't slow down UI with many shifts

**Steps:**
1. Create 20 active shifts
2. Monitor CPU usage
3. Check timer accuracy

**Expected Results:**
- [ ] CPU usage < 10%
- [ ] No lag when typing
- [ ] Timers remain accurate
- [ ] UI remains responsive

**Actual Results:**
```
CPU: _____%
[ Pass / Fail ]
```

---

## Test Summary Report Template

```markdown
## Test Execution Summary

**Date:** YYYY-MM-DD
**Tester:** [Name]
**Environment:** [Local/Staging/Production]
**Database:** [Supabase Project]

### Results

| Category | Total | Passed | Failed | Skipped |
|----------|-------|--------|--------|---------|
| Clock In | 6 | | | |
| Break Tracking | 4 | | | |
| Clock Out | 3 | | | |
| Timer Accuracy | 3 | | | |
| Shift History | 2 | | | |
| Summary Dashboard | 2 | | | |
| Export | 1 | | | |
| Real-Time Updates | 2 | | | |
| Edge Cases | 4 | | | |
| UI/UX | 3 | | | |
| Data Integrity | 2 | | | |
| Performance | 2 | | | |
| **TOTAL** | **32** | | | |

### Critical Issues Found
1.
2.

### Minor Issues Found
1.
2.

### Notes
-
-

### Recommendation
[ ] Deploy to Production
[ ] Fix issues and retest
[ ] Rollback migration

**Sign-off:** _______________
```

---

## Automated Testing (Future)

Once manual testing passes, consider these automated tests:

```javascript
// Example Playwright test
test('should clock in employee successfully', async ({ page }) => {
  await page.goto('/shifts');
  await page.click('button:has-text("Clock In")');
  await page.selectOption('select', 'emp-001');
  await page.fill('#pin-0', '1');
  await page.fill('#pin-1', '2');
  await page.fill('#pin-2', '3');
  await page.fill('#pin-3', '4');
  await page.click('button:has-text("Clock In")');

  await expect(page.locator('.active-shift')).toBeVisible();
  await expect(page.locator('text=Test Bartender')).toBeVisible();
});
```

---

**Remember:** Complete ALL test cases before marking the feature as production-ready. Document any failures and retest after fixes.

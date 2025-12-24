# WiesbadenAfterDark - Final Setup Guide
## Run These Steps to Complete Setup

---

## Step 1: Storage Buckets (5 minutes)

1. Open [Supabase Dashboard](https://supabase.com/dashboard/project/yyplbhrqtaeyzmcxpfli)
2. Go to **SQL Editor**
3. Copy and run `FIX_STORAGE_BUCKETS.sql`
4. Verify in **Storage** tab that `photos` and `documents` buckets exist

---

## Step 2: Audit Log Triggers (5 minutes)

1. In SQL Editor, run `FIX_AUDIT_TRIGGERS.sql`
2. Go to **Database > Triggers**
3. Verify these triggers exist:
   - `trg_audit_shifts` on `shifts` table
   - `trg_audit_tasks` on `tasks` table

---

## Step 3: SMTP for Password Reset (10 minutes)

### Option A: Use Supabase Built-in (Limited)
- By default, Supabase sends 4 emails/hour on free tier
- Good enough for testing

### Option B: Configure Custom SMTP
1. Go to **Authentication > Email Templates**
2. Scroll to **SMTP Settings**
3. Enable **Custom SMTP**
4. Enter your SMTP credentials:
   - Host: smtp.gmail.com (or your provider)
   - Port: 587
   - Username: your email
   - Password: app password
5. Save and test

---

## Step 4: Verify Everything Works

### Test Storage:
```bash
# In PWA, try uploading an employee photo
# It should work without errors
```

### Test Audit Log:
```bash
# In PWA:
# 1. Clock in an employee
# 2. Complete a task
# 3. Go to Protokoll page
# 4. Should see the actions logged
```

### Test Password Reset:
```bash
# 1. Go to /login
# 2. Click "Passwort vergessen?"
# 3. Enter email
# 4. Check inbox for reset link
```

---

## Verification Checklist

- [x] Storage buckets created ✅
- [x] Audit triggers active ✅
- [x] PWA loads without errors ✅
- [x] All exports work (Shifts, Inventory, Employees) ✅
- [x] Keyboard shortcuts work (⌘K, ?) ✅
- [x] Theme toggle works ✅
- [ ] Password reset email works (Optional - Supabase built-in SMTP sufficient for pilot)

**Status:** All critical items complete! See [PRODUCTION_READINESS_VERIFICATION.md](./PRODUCTION_READINESS_VERIFICATION.md) for full details.

---

## SQL Files to Run

| File | Purpose |
|------|---------|
| `FIX_STORAGE_BUCKETS.sql` | Create photo/document storage |
| `FIX_AUDIT_TRIGGERS.sql` | Enable automatic action logging |

---

## Support

If issues arise:
1. Check Supabase Dashboard > Logs
2. Check browser console for errors
3. Verify RLS policies allow access

---

## Ready for Pilot! 🚀

Once all steps complete, the PWA is ready for Das Wohnzimmer.


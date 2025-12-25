# Quick Fix: Photo Upload .env Variables
## 2-Minute Critical Fix

**Issue:** Photo uploads will fail because frontend .env is missing Supabase credentials

**Root Cause:** `owner-pwa/.env` only has `VITE_API_URL` but PhotoUpload component needs Supabase Storage access

---

## Solution (2 minutes)

### Step 1: Edit `.env` file

```bash
cd ~/Desktop/Projects-2025/WiesbadenAfterDark/owner-pwa
nano .env  # or use VS Code
```

### Step 2: Add these lines

```bash
# Existing line (keep this)
VITE_API_URL=https://wiesbade-after-dark-production.up.railway.app

# ADD THESE TWO LINES:
VITE_SUPABASE_URL=https://exjowhbyrdjnhmkmkvmf.supabase.co
VITE_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImV4am93aGJ5cmRqbmhta21rdm1mIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzE1MzU4MTAsImV4cCI6MjA0NzExMTgxMH0._VrTxWb-vX2Yx8bSzZcnYFGcR-M5y-D1o5Eoao4Y5Oo
```

### Step 3: Restart dev server

```bash
# Stop current dev server (Ctrl+C if running)
npm run dev
```

### Step 4: Test photo upload

1. Go to http://localhost:5174
2. Login
3. Navigate to Employees
4. Try uploading a photo
5. Should now work! ✅

---

## Why This Works

The `PhotoUpload.tsx` component uses:
```typescript
const { data, error: uploadError } = await supabase.storage
  .from(bucket)
  .upload(filePath, file);
```

**Problem:** `supabase` client was initialized but couldn't connect because frontend didn't have credentials

**Solution:** Now frontend can access backend Supabase Storage buckets that already exist:
- `employee-photos` (bucket for employee headshots)
- Storage is already configured in backend Supabase project

---

## Verification

After fix, you should be able to:
- ✅ Upload employee photos
- ✅ See photos appear in Supabase Dashboard → Storage
- ✅ Photos display in employee list

If still failing:
1. Check browser console for errors
2. Verify .env variables loaded (check Network tab for Supabase requests)
3. Verify storage buckets exist in Supabase Dashboard

---

**Fix Time:** 2 minutes
**Impact:** Critical feature now working
**Complexity:** Very simple

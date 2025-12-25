# Mobile Testing Guide - WiesbadenAfterDark Owner PWA
## Test on Your Real Phone

---

## PWA URL
https://owner-6xdb541ae-l3lim3d-2348s-projects.vercel.app

---

## Test 1: Barcode Scanner 📱

### Steps:
1. Open PWA on your phone
2. Login with test credentials
3. Go to **Inventar** (Inventory)
4. Click **"Barcode scannen"** button
5. Point camera at any barcode (beer bottle, product, etc.)

### Expected Results:
- ✅ Camera permission prompt appears
- ✅ Camera opens with scanning frame
- ✅ Barcode is detected and read
- ✅ If barcode matches inventory → Edit modal opens
- ✅ If barcode is new → Add Item modal with barcode pre-filled

### If It Fails:
- Check camera permissions in browser settings
- Try Chrome instead of Safari
- Ensure HTTPS (not HTTP)
- Try a clearer/larger barcode

---

## Test 2: Mobile Navigation 📱

### Steps:
1. Open PWA on phone (portrait mode)
2. Look at bottom of screen

### Expected Results:
- ✅ Bottom navigation bar appears with 5 icons
- ✅ Icons: Dashboard, Shifts, Tasks, Inventory, Analytics
- ✅ Tapping each icon navigates correctly
- ✅ Active icon is highlighted

### If It Fails:
- Check if sidebar is showing instead (might be tablet breakpoint)
- Try rotating phone to portrait
- Clear cache and reload

---

## Test 3: Photo Upload 📱

### Steps:
1. Go to **Mitarbeiter** (Employees)
2. Click **"+ Neuer Mitarbeiter"**
3. Click the photo upload circle
4. Take a photo or select from gallery

### Expected Results:
- ✅ Camera/gallery picker appears
- ✅ Selected image shows as preview
- ✅ Image uploads to Supabase
- ✅ Saving employee shows photo in list

---

## Test 4: Offline Mode 📱

### Steps:
1. Open PWA and load Dashboard
2. Turn on **Airplane Mode**
3. Navigate to different pages

### Expected Results:
- ✅ "Sie sind offline" banner appears
- ✅ Previously loaded data still shows
- ✅ Navigation still works
- ✅ Actions are queued (not lost)

---

## Test 5: Password Reset 📱

### Steps:
1. Go to Login page
2. Click **"Passwort vergessen?"**
3. Enter your email
4. Check email on phone
5. Click reset link
6. Set new password

### Expected Results:
- ✅ "E-Mail gesendet" success message
- ✅ Email arrives within 2 minutes
- ✅ Link opens in PWA
- ✅ Can set new password
- ✅ Can login with new password

---

## Test 6: PWA Installation 📱

### On iPhone (Safari):
1. Open PWA URL in Safari
2. Tap Share button (square with arrow)
3. Scroll down, tap "Add to Home Screen"
4. Name it "WAD Owner"
5. Tap Add

### On Android (Chrome):
1. Open PWA URL in Chrome
2. Tap menu (3 dots)
3. Tap "Add to Home Screen" or "Install App"
4. Tap Add

### Expected Results:
- ✅ App icon appears on home screen
- ✅ Opens without browser chrome
- ✅ Feels like native app

---

## Quick Test Checklist

| Test | Status | Notes |
|------|--------|-------|
| Login | ☐ | |
| Dashboard loads | ☐ | |
| Bottom navigation | ☐ | |
| Barcode scanner | ☐ | |
| Photo upload | ☐ | |
| Offline banner | ☐ | |
| Password reset | ☐ | |
| PWA install | ☐ | |

---

## Test Credentials
Email: owner@example.com
Password: password

(Or use your own test account)

---

## Report Issues

After testing, note:
1. What worked ✅
2. What failed ❌
3. Device model (iPhone 15, Pixel 7, etc.)
4. Browser (Safari, Chrome)
5. Any error messages

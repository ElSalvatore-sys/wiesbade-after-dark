# 🚀 Das Wohnzimmer - Launch Day Checklist
## January 1, 2025 - WiesbadenAfterDark Owner PWA

---

## 📅 Pre-Launch (December 27-31)

### Technical Setup
- [ ] **SMTP Configured** - Emails working (SMTP_SETUP_SUMMARY.md)
- [ ] **Data Imported** - Real employee names (QUICK_DATA_UPDATE.sql)
- [ ] **Mobile Tested** - All 10 tests passed (MOBILE_QUICK_CHECKLIST.md)
- [ ] **Production Verified** - https://owner-pwa.vercel.app works

### Staff Preparation
- [ ] **Owner Account Created** - Real owner login credentials
- [ ] **Employee PINs Set** - Each employee has unique 4-digit PIN
- [ ] **Training Completed** - Staff knows how to clock in/out
- [ ] **Devices Ready** - Phones/tablets charged, app installed

### Data Preparation
- [ ] **Demo Tasks Deleted** - No [Demo] tasks visible
- [ ] **Real Tasks Created** - Opening/closing checklists ready
- [ ] **Inventory Updated** - Current stock levels entered
- [ ] **Barcodes Tested** - Scanner works with venue products

---

## 🌅 Launch Day Morning (Before Opening)

### System Check (15 min)
Time: : (2 hours before opening)

| Check | Status | Notes |
|-------|--------|-------|
| [ ] Open https://owner-pwa.vercel.app | | |
| [ ] Login with owner credentials | | |
| [ ] Dashboard shows data | | |
| [ ] Check employee list is correct | | |
| [ ] Verify today's tasks are visible | | |
| [ ] Test barcode scanner (1 item) | | |
| [ ] Test clock in (owner or test) | | |
| [ ] Check internet connection stable | | |

### Device Setup (10 min)
Time: :

| Device | PWA Installed | Logged In | Battery |
|--------|---------------|-----------|---------|
| [ ] Owner phone | ☐ | ☐ | ___% |
| [ ] Backup tablet | ☐ | ☐ | ___% |
| [ ] Bar iPad (if any) | ☐ | ☐ | ___% |

### Staff Briefing (10 min)
Time: :

- [ ] Show staff how to clock in (PIN entry)
- [ ] Show where to find tasks
- [ ] Explain break start/end
- [ ] Show clock out process
- [ ] Emergency contact if issues

---

## 🔓 Opening Time

### First Clock In
Time: : (Opening)
Staff Member: ________________

1. [ ] Open PWA on device
2. [ ] Navigate to **Schichten** (Shifts)
3. [ ] Tap **"Mitarbeiter einchecken"**
4. [ ] Select employee from dropdown
5. [ ] Enter 4-digit PIN
6. [ ] Verify shift appears in "Active Shifts"
7. [ ] Timer counting up ✓

### Opening Tasks
Time: :

1. [ ] Navigate to **Aufgaben** (Tasks)
2. [ ] Find "Öffnungs-Checkliste"
3. [ ] Complete each item
4. [ ] Mark task as **Erledigt** (Done)

---

## 📊 During Service

### Hourly Checks
Every hour, verify:

| Time | Active Shifts | Issues |
|------|---------------|--------|
| ___:___ | ___ employees | |
| ___:___ | ___ employees | |
| ___:___ | ___ employees | |
| ___:___ | ___ employees | |

### Break Management
When staff takes break:

1. [ ] Find employee's active shift
2. [ ] Tap **"Pause starten"**
3. [ ] When returning: Tap **"Pause beenden"**

### If Booking Comes In
Time: :
Guest: ________________

1. [ ] Navigate to **Reservierungen**
2. [ ] Find the pending booking
3. [ ] Tap ✓ to confirm OR ✗ to decline
4. [ ] Email sent automatically (if SMTP configured)

### If Inventory Needed
Item: ________________

1. [ ] Navigate to **Inventar**
2. [ ] Tap **"Barcode scannen"**
3. [ ] Scan product
4. [ ] Update stock quantity
5. [ ] Save changes

---

## 🔒 Closing Time

### Staff Clock Out
Time: : (Closing)

For each employee:
1. [ ] Find their active shift
2. [ ] Tap **"Auschecken"**
3. [ ] Verify hours calculated correctly
4. [ ] Repeat for all staff

| Employee | Hours Worked | Break Time | Overtime |
|----------|--------------|------------|----------|
| | h m | m | |
| | h m | m | |
| | h m | m | |
| | h m | m | |

### Closing Tasks
Time: :

1. [ ] Navigate to **Aufgaben**
2. [ ] Find "Schließ-Checkliste"
3. [ ] Complete each item
4. [ ] Mark as **Erledigt**

### End of Day Review
Time: :

1. [ ] Check Dashboard for daily stats
2. [ ] Review any incomplete tasks
3. [ ] Note any issues for tomorrow
4. [ ] Log out of all devices

---

## 🆘 Emergency Procedures

### If App Won't Load
1. Check internet connection
2. Try different browser (Safari/Chrome)
3. Clear browser cache
4. Restart device
5. Contact: Ali @ _______________

### If Clock In Fails
1. Verify PIN is correct (4 digits)
2. Try different employee
3. Check internet connection
4. Use backup device
5. Manual time tracking as fallback

### If Barcode Won't Scan
1. Ensure good lighting
2. Clean camera lens
3. Use **"Manuell eingeben"** button
4. Enter barcode numbers manually

### If Booking Email Fails
1. Check Supabase Dashboard for errors
2. Manually call/text guest
3. Document for later fix

### Emergency Contacts
Developer (Ali): _______________
Backup Contact: _______________

---

## 📝 Issue Log

Document any problems for post-launch fixes:

| Time | Issue | Severity | Resolution |
|------|-------|----------|------------|
| | | Low/Med/High | |
| | | | |
| | | | |
| | | | |
| | | | |

---

## ✅ End of Day Summary
Date: January 1, 2025

### Stats
- Total shifts logged: ___
- Total hours tracked: ___ h
- Tasks completed: ___/___
- Bookings processed: ___
- Inventory scans: ___

### System Performance
- [ ] **Excellent** - No issues
- [ ] **Good** - Minor issues, workarounds used
- [ ] **Fair** - Some issues, manual backup needed
- [ ] **Poor** - Major issues, need immediate fixes

### Staff Feedback




### Priority Fixes Needed












---

## 📞 Support

**Production URL:** https://owner-pwa.vercel.app

**Quick Links:**
- Supabase Dashboard: https://supabase.com/dashboard/project/yyplbhrqtaeyzmcxpfli
- GitHub Repo: https://github.com/ElSalvatore-sys/wiesbade-after-dark

**Documentation:**
- SMTP Setup: SMTP_SETUP_SUMMARY.md
- Data Import: DATA_IMPORT_README.md
- Mobile Testing: MOBILE_QUICK_CHECKLIST.md

---

*Print this checklist and have it ready on launch day!*

**Good luck with the launch! 🍺🌙**

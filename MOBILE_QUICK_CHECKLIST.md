# 📱 Mobile Testing Quick Checklist
## 10-Minute Speed Test

---

**URL:** https://owner-pwa.vercel.app
**Login:** owner@example.com / password

---

## ⚡ Quick Tests (Do in Order)

| # | Test | Action | Pass? |
|---|------|--------|-------|
| 1 | **Open URL** | Load in Safari/Chrome | ☐ |
| 2 | **Login** | Enter credentials, tap Login | ☐ |
| 3 | **Dashboard** | See 4 stat cards with data | ☐ |
| 4 | **Navigation** | Tap all 5 bottom icons | ☐ |
| 5 | **Barcode** | Inventory → Scan → Camera opens | ☐ |
| 6 | **Manual Input** | Scanner → "Manuell" → Enter code | ☐ |
| 7 | **Clock In** | Shifts → Check in → Enter PIN 1234 | ☐ |
| 8 | **Break** | Start/End break on active shift | ☐ |
| 9 | **Clock Out** | End the shift | ☐ |
| 10 | **Offline** | Airplane mode → Banner shows | ☐ |

---

## 🔴 Critical Tests

Must pass before pilot:

- [ ] Barcode scanner opens camera
- [ ] Manual barcode entry works
- [ ] Clock in with PIN works
- [ ] Clock out calculates hours
- [ ] Dashboard shows real data

---

## 📱 Device Info
Device: _________________
OS: _____________________
Browser: ________________
Date: ___________________
Tester: _________________

---

## 🐛 Issues Found
Issue 1: ________________
Issue 2: ________________
Issue 3: ________________

---

## ✅ Result

- **Tests Passed:** ___/10
- **Ready for Pilot:** YES / NO
- **Blocking Issues:** _______________

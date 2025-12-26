# Das Wohnzimmer - Data Cleanup Guide
## Current Database Status

**Date:** December 26, 2025
**Venue:** Das Wohnzimmer (Taunusstraße 42, Wiesbaden)

---

## ✅ What's Already Good

### Venue Information ✅
- **Name:** Das Wohnzimmer
- **Address:** Taunusstraße 42, Wiesbaden
- **Phone:** +49 611 123456
- **Email:** info@daswohnzimmer-wiesbaden.de

**Status:** Ready to use! (Update phone/email if needed)

### Inventory ✅
Already has **excellent example data** with real barcodes:

**Beer:**
- Corona Extra, Heineken, Becks (with proper barcodes)

**Spirits:**
- Absolut Vodka, Bombay Sapphire, Jack Daniels, Jägermeister

**Wine:**
- Prosecco

**Soft Drinks:**
- Red Bull, Coca Cola

**Storage System:**
- `storage_quantity`: Items in storage/cellar
- `bar_quantity`: Items at the bar ready to serve
- `min_stock_level`: Minimum before reorder alert

**Status:** Already populated! Just add/remove items as needed.

---

## ⚠️ What Needs Update

### 1. Employee Names (7 employees)

Current placeholder employees:

| Current Name | Role | Email | Action Needed |
|--------------|------|-------|---------------|
| Inhaber (bitte anpassen) | owner | max@daswohnzimmer.de | ✏️ Update name |
| Manager (bitte anpassen) | manager | sarah@daswohnzimmer.de | ✏️ Update name |
| Barkeeper 1 | bartender | tom@daswohnzimmer.de | ✏️ Update name/email |
| Service 1 | waiter | lisa@daswohnzimmer.de | ✏️ Update name/email |
| Security 1 | security | hans@daswohnzimmer.de | ✏️ Update name/email |
| DJ 1 | dj | mike@daswohnzimmer.de | ✏️ Update name/email |
| Reinigung 1 | cleaning | anna@daswohnzimmer.de | ✏️ Update name/email |

**Note:** Names with "(bitte anpassen)" mean "please customize" in German

### 2. Demo Tasks (Delete These)

Current demo tasks to remove:
- [Demo] Toiletten reinigen
- [Demo] Getränke auffüllen
- [Demo] DJ Pult vorbereiten
- [Demo] Garderobe einrichten
- [Demo] Gläser polieren

**All tasks are prefixed with [Demo]** - these should be deleted before pilot.

---

## 🎯 Quick Update Options

### Option A: Manual Update (Supabase Dashboard)

**5-10 minutes** - Best for small changes

1. Go to: https://supabase.com/dashboard/project/yyplbhrqtaeyzmcxpfli/editor
2. Select `employees` table
3. Click each row and edit names/emails
4. Select `tasks` table
5. Delete rows with "[Demo]" prefix

### Option B: SQL Script (Recommended)

**2-3 minutes** - Run one SQL script

Use `QUICK_DATA_UPDATE.sql` (see below)
- Updates employee names
- Deletes demo tasks
- Adds useful recurring tasks

---

## 📋 What to Prepare

Before running the update, decide on:

### Employee Information

Fill in real names and emails:

**Owner:**
- Name: _______________________
- Email: ______________________
- PIN: 1234 (default, can change in app)

**Manager:**
- Name: _______________________
- Email: ______________________
- PIN: 2345

**Bartender:**
- Name: _______________________
- Email: ______________________
- PIN: 3456

**Server:**
- Name: _______________________
- Email: ______________________
- PIN: 4567

**Security:**
- Name: _______________________
- Email: ______________________
- PIN: 5678

**DJ:**
- Name: _______________________
- Email: ______________________
- PIN: 6789

**Cleaning:**
- Name: _______________________
- Email: ______________________
- PIN: 7890

---

## 🔄 Recommended Tasks

These will replace the [Demo] tasks:

### Daily Tasks:
- Öffnungs-Checkliste (Opening checklist)
- Schließ-Checkliste (Closing checklist)
- Toiletten-Check
- Bar aufräumen

### Weekly Tasks:
- Inventur (Inventory count)
- Tiefenreinigung (Deep cleaning)
- Bestellungen prüfen (Check orders)

---

## ⏱️ Time Estimate

| Task | Time | Difficulty |
|------|------|------------|
| Update employee names | 2 min | Easy |
| Delete demo tasks | 1 min | Easy |
| Add recurring tasks | 1 min | Easy |
| Test changes in PWA | 2 min | Easy |

**Total:** 5-10 minutes

---

## 🚀 After Update

Test in Owner PWA:
1. Open https://owner-pwa.vercel.app
2. Go to Employees → Check names updated
3. Go to Tasks → Check demo tasks gone
4. Go to Inventory → Review stock levels

---

## ✅ Optional Enhancements

### Add More Inventory

Use the PWA's barcode scanner to add items:
1. Go to Inventory page
2. Click "Scan Barcode"
3. Scan product barcode
4. Enter stock levels
5. Set minimum stock alert

### Update Venue Hours

If opening hours are different:
1. Edit in Supabase Dashboard
2. Update `opening_hours` JSON field

---

*Next: See QUICK_DATA_UPDATE.sql for the automated update script*

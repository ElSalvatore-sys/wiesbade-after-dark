# Data Import - Quick Start Guide
## Das Wohnzimmer Production Data

**Status:** Database has good example data! Just needs customization.
**Time Needed:** 5-10 minutes

---

## 🎯 Current Database Status

### ✅ Already Good

**Venue Information:**
- Name: Das Wohnzimmer ✅
- Address: Taunusstraße 42, Wiesbaden ✅
- Phone & Email: Set (update if needed)

**Inventory:**
- 10+ items with real barcodes ✅
- Beer: Corona, Heineken, Becks
- Spirits: Absolut, Bombay, Jack Daniels, Jägermeister
- Soft Drinks: Red Bull, Coca Cola, Prosecco
- **Dual tracking:** Storage quantity + Bar quantity

### ⚠️ Needs Update

**Employees (7 total):**
- Names contain "(bitte anpassen)" = "please customize"
- Need real names and emails

**Tasks:**
- 5 demo tasks with "[Demo]" prefix
- Need to be deleted and replaced with real tasks

---

## 🚀 Quick Update (Recommended)

### Step 1: Edit the SQL Script (2 min)

Open: `QUICK_DATA_UPDATE.sql`

Find and replace these placeholder names:

```sql
-- Line ~30: Owner
name = 'Max Mustermann', -- 👈 CHANGE THIS to real owner name

-- Line ~37: Manager
name = 'Sarah Schmidt', -- 👈 CHANGE THIS

-- Line ~44: Bartender
name = 'Tom Weber', -- 👈 CHANGE THIS

-- Line ~51: Server
name = 'Lisa Fischer', -- 👈 CHANGE THIS

-- And so on...
```

### Step 2: Run in Supabase (1 min)

1. Copy the edited SQL script
2. Go to: https://supabase.com/dashboard/project/yyplbhrqtaeyzmcxpfli/sql
3. Paste and click "Run"

### Step 3: Verify (2 min)

Check in Owner PWA:
- Employees page → Names updated
- Tasks page → Demo tasks gone, new tasks added
- Inventory page → Items ready to use

---

## 📋 What the Script Does

**Automatically:**
1. ✅ Deletes all [Demo] tasks
2. ✅ Updates employee names (to your customizations)
3. ✅ Adds 6 useful recurring tasks:
   - Öffnungs-Checkliste (Opening)
   - Schließ-Checkliste (Closing)
   - Toiletten-Check
   - Bar aufräumen
   - Wöchentliche Inventur
   - Tiefenreinigung

**Preserves:**
- All inventory items ✅
- Venue information ✅
- Employee PINs ✅
- Database structure ✅

---

## 📁 Files Reference

| File | Purpose | When to Use |
|------|---------|-------------|
| **DATA_IMPORT_README.md** (this file) | Quick start guide | Start here |
| **QUICK_DATA_UPDATE.sql** | Automated update script | Run in Supabase SQL editor |
| **DATA_CLEANUP_GUIDE.md** | Detailed explanation | Reference guide |

---

## 🎯 Tasks Added by Script

### Daily Tasks
1. **Öffnungs-Checkliste** (Opening checklist)
   - Turn on lights
   - Start sound system
   - Prepare cash register
   - Check tables and chairs
   - Check glasses
   - Check refrigerators
   - Check toilets

2. **Schließ-Checkliste** (Closing checklist)
   - Cash register accounting
   - Turn off all lights
   - Close all doors and windows
   - Check refrigerators
   - Take out trash
   - Clean bar
   - Activate alarm

3. **Toiletten-Check** (Toilet check)
   - Refill paper
   - Check soap
   - Check cleanliness
   - Empty trash bins
   - Mop floor

4. **Bar aufräumen** (Bar cleanup)
   - Wash and polish glasses
   - Wipe counter
   - Refill bottles
   - Prepare ice
   - Cut lemons/limes

### Weekly Tasks
5. **Wöchentliche Inventur** (Weekly inventory)
   - Count storage stock
   - Count bar stock
   - Update in system
   - Note reorders
   - Check expiration dates
   - Sort out damaged items

6. **Tiefenreinigung** (Deep cleaning)
   - Thoroughly mop floors
   - Clean windows
   - Wipe furniture
   - Clean out refrigerators
   - Check ventilation
   - Organize storage room

---

## 🔍 Current Employee List

**Will be updated to your customizations:**

| Role | Default Name | Email | PIN |
|------|--------------|-------|-----|
| Owner | Max Mustermann | max@daswohnzimmer.de | 1234 |
| Manager | Sarah Schmidt | sarah@daswohnzimmer.de | 2345 |
| Bartender | Tom Weber | tom@daswohnzimmer.de | 3456 |
| Server | Lisa Fischer | lisa@daswohnzimmer.de | 4567 |
| Security | Hans Becker | hans@daswohnzimmer.de | 5678 |
| DJ | Mike Johnson | mike@daswohnzimmer.de | 6789 |
| Cleaning | Anna Müller | anna@daswohnzimmer.de | 7890 |

**Note:** PINs can be changed later in the Owner PWA settings.

---

## ⚙️ Advanced: Manual Updates

If you prefer manual updates instead of SQL:

### Update Employees Manually
1. Go to: https://supabase.com/dashboard/project/yyplbhrqtaeyzmcxpfli/editor
2. Select `employees` table
3. Click each row to edit name and email
4. Save changes

### Delete Demo Tasks Manually
1. Select `tasks` table
2. Filter by: title contains "[Demo]"
3. Select all rows
4. Click Delete

### Add Tasks Manually
1. Select `tasks` table
2. Click "Insert row"
3. Fill in: title, description, category, priority
4. Set venue_id to Das Wohnzimmer's ID
5. Save

---

## ✅ After Update Checklist

- [ ] All employee names updated (no more "bitte anpassen")
- [ ] All demo tasks deleted
- [ ] New recurring tasks added
- [ ] Tested login with employee PINs
- [ ] Checked inventory in PWA
- [ ] Verified venue information

---

## 🚀 Ready for Pilot

Once data is updated:
- ✅ Employees can clock in/out
- ✅ Tasks are assigned and tracked
- ✅ Inventory is managed with barcode scanner
- ✅ Bookings can be confirmed (emails sent)

**Next Steps:**
1. Test all features in PWA
2. Train staff on PIN usage
3. Show barcode scanner to staff
4. Launch pilot on January 1!

---

## 🆘 Need Help?

**SQL not working?**
- Check you edited the placeholder names
- Verify Das Wohnzimmer venue exists
- Check SQL editor for error messages

**Want different tasks?**
- Edit the QUICK_DATA_UPDATE.sql file
- Add/remove task INSERT statements
- Customize descriptions

**Need more inventory?**
- Use PWA barcode scanner to add items
- Or add via Supabase table editor

---

**Time Investment:** 5-10 minutes
**Difficulty:** Easy
**Impact:** Production-ready database

*Last Updated: December 26, 2025*

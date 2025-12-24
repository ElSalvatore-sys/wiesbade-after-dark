# Data Cleanup Checklist

## Before Das Wohnzimmer Pilot

### Employees Table
- [ ] Replace "Max Müller" with real owner name
- [ ] Replace "Lisa Schmidt" with real manager name
- [ ] Add all real bartenders
- [ ] Add all real servers
- [ ] Add kitchen staff if applicable
- [ ] Set correct PINs (they choose)
- [ ] Set correct roles

### Inventory Table
- [ ] Delete sample items OR
- [ ] Update with their actual products
- [ ] Set correct prices
- [ ] Set correct min_stock_level
- [ ] Add barcodes if they have them

### Tasks Table
- [ ] Delete "[Demo]" tasks
- [ ] Add their recurring tasks:
  - Opening checklist
  - Closing checklist
  - Daily cleaning
  - Inventory count

### Venues Table
- [ ] Update Das Wohnzimmer description
- [ ] Add real opening hours
- [ ] Add real address
- [ ] Upload real photos

## After Pilot Day 1
- [ ] Review any data issues found
- [ ] Add missing categories
- [ ] Adjust workflows based on feedback

## SQL Queries to Run

### Clear all demo data:
```sql
DELETE FROM tasks WHERE title LIKE '[Demo]%';
DELETE FROM shifts WHERE clock_out IS NOT NULL;
DELETE FROM inventory_transfers;
```

### Reset employee PINs:
```sql
UPDATE employees SET pin_hash = '1234' WHERE venue_id = 'YOUR_VENUE_ID';
```

### Check data status:
```sql
SELECT 
  (SELECT COUNT(*) FROM employees) as employee_count,
  (SELECT COUNT(*) FROM inventory_items) as inventory_count,
  (SELECT COUNT(*) FROM tasks) as task_count;
```

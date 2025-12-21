# API Documentation

## Supabase Tables

### employees
```sql
CREATE TABLE employees (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  venue_id uuid REFERENCES venues(id),
  name text NOT NULL,
  email text,
  phone text,
  role text NOT NULL, -- owner, manager, bartender, waiter, security, dj, cleaning
  pin_hash text,
  hourly_rate decimal,
  is_active boolean DEFAULT true,
  created_at timestamptz DEFAULT now()
);
```

### shifts
```sql
CREATE TABLE shifts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  venue_id uuid REFERENCES venues(id),
  employee_id uuid REFERENCES employees(id),
  clock_in timestamptz NOT NULL,
  clock_out timestamptz,
  break_minutes integer DEFAULT 0,
  actual_hours decimal,
  status text DEFAULT 'active', -- active, completed, no-show
  notes text,
  created_at timestamptz DEFAULT now()
);
```

### tasks
```sql
CREATE TABLE tasks (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  venue_id uuid REFERENCES venues(id),
  title text NOT NULL,
  description text,
  assigned_to uuid REFERENCES employees(id),
  status text DEFAULT 'pending', -- pending, in-progress, completed, approved
  priority text DEFAULT 'medium', -- low, medium, high, urgent
  due_date timestamptz,
  photo_url text,
  approved_by uuid REFERENCES employees(id),
  approved_at timestamptz,
  created_at timestamptz DEFAULT now()
);
```

### inventory_items
```sql
CREATE TABLE inventory_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  venue_id uuid REFERENCES venues(id),
  product_id uuid REFERENCES products(id),
  name text NOT NULL,
  category text,
  storage_quantity integer DEFAULT 0,
  bar_quantity integer DEFAULT 0,
  min_stock_level integer DEFAULT 5,
  unit text DEFAULT 'bottles',
  last_counted timestamptz,
  created_at timestamptz DEFAULT now()
);
```

### push_subscriptions
```sql
CREATE TABLE push_subscriptions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  endpoint text NOT NULL,
  p256dh text,
  auth text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  UNIQUE(user_id)
);
```

## Row Level Security (RLS)

All tables have RLS enabled with policies:
- Venue-scoped access (users can only see their venue's data)
- Role-based permissions (owners see all, employees see assigned)

## Realtime Subscriptions

The PWA subscribes to realtime changes on:
- `tasks` - New assignments, status changes
- `shifts` - Clock in/out events
- `inventory_items` - Stock level changes

## Edge Functions

### get-events
Returns events for a venue with ticket information.

### get-venues
Returns venue details with operating hours.

## Storage Buckets

### task-photos
Stores photo proof for completed tasks.
- Public read access
- Authenticated write access

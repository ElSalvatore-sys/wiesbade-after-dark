# Alembic Database Migrations

This directory contains database migrations for the Wiesbaden After Dark backend.

## Running Migrations

### Local Development

```bash
# Upgrade to latest version
alembic upgrade head

# Downgrade one version
alembic downgrade -1

# Show current revision
alembic current

# Show migration history
alembic history
```

### Production (Railway)

Migrations run automatically on deployment via `start.sh`:
```bash
alembic upgrade head && uvicorn app.main:app --host 0.0.0.0 --port $PORT
```

## Creating New Migrations

### Auto-generate from model changes
```bash
alembic revision --autogenerate -m "Description of changes"
```

### Manual migration
```bash
alembic revision -m "Description of changes"
```

## Migration Files

- `env.py` - Alembic environment configuration
- `script.py.mako` - Template for new migrations
- `versions/` - Migration files

## Current Migrations

1. `001_add_phone_authentication.py` - Add phone authentication columns
   - Add phone_number, phone_country_code, phone_verified to users
   - Make email and password_hash nullable
   - Create verification_codes table

## Important Notes

- Always review auto-generated migrations before applying
- Test migrations on development database first
- Migrations run automatically on Railway deployment
- Use `alembic downgrade` to revert if needed

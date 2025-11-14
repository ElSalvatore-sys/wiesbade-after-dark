# Railway Deployment Guide - WiesbadenAfterDark Backend

## Quick Start Checklist

- [ ] Deploy backend to Railway
- [ ] Set environment variables
- [ ] Generate public domain
- [ ] Run database migrations
- [ ] Test health endpoint
- [ ] Test API documentation
- [ ] Update iOS app with production URL

---

## Step 1: Deploy to Railway

### Option A: Via Railway Dashboard (Recommended)

1. Visit: https://railway.app/dashboard
2. Select "generous-harmony" project
3. Click "+ New" → "GitHub Repo"
4. Select repository: **ElSalvatore-sys/wiesbade-after-dark**
5. Set **Root Directory**: `/backend`
6. Click "Deploy"

### Option B: Via Railway CLI

```bash
cd ~/Desktop/Projects-2025/WiesbadenAfterDark/backend
railway link
railway up
```

---

## Step 2: Configure Environment Variables

In Railway dashboard → Your Service → Variables tab, add:

```bash
# Database
DATABASE_URL=postgresql://postgres.exjowhbyrdjnhmkmkvmf:LOLEalmasri998%21@aws-0-eu-central-1.pooler.supabase.com:6543/postgres

# Supabase
SUPABASE_URL=https://exjowhbyrdjnhmkmkvmf.supabase.co
SUPABASE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImV4am93aGJ5cmRqbmhta21rdm1mIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzE1MzU4MTAsImV4cCI6MjA0NzExMTgxMH0._VrTxWb-vX2Yx8bSzZcnYFGcR-M5y-D1o5Eoao4Y5Oo
SUPABASE_JWT_SECRET=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImV4am93aGJ5cmRqbmhta21rdm1mIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2MjYxMjIxMCwiZXhwIjoyMDc4MTg4MjEwfQ.ZpkOEL7lybi3eby3Lk89WEkCYyjzWFuyHP_sOH1AkOc

# Security
SECRET_KEY=ESy8MscRf1PAVDI7eOdLa0yWNDdulffgtJQfxYXG7O0
ALGORITHM=HS256

# App Config
PROJECT_NAME=Wiesbaden After Dark API
PORT=8000
RAILWAY_ENVIRONMENT=production
DEBUG=False
```

### Copy-Paste Format (one per line)

```
DATABASE_URL=postgresql://postgres.exjowhbyrdjnhmkmkvmf:LOLEalmasri998%21@aws-0-eu-central-1.pooler.supabase.com:6543/postgres
SUPABASE_URL=https://exjowhbyrdjnhmkmkvmf.supabase.co
SUPABASE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImV4am93aGJ5cmRqbmhta21rdm1mIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzE1MzU4MTAsImV4cCI6MjA0NzExMTgxMH0._VrTxWb-vX2Yx8bSzZcnYFGcR-M5y-D1o5Eoao4Y5Oo
SUPABASE_JWT_SECRET=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImV4am93aGJ5cmRqbmhta21rdm1mIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2MjYxMjIxMCwiZXhwIjoyMDc4MTg4MjEwfQ.ZpkOEL7lybi3eby3Lk89WEkCYyjzWFuyHP_sOH1AkOc
SECRET_KEY=ESy8MscRf1PAVDI7eOdLa0yWNDdulffgtJQfxYXG7O0
ALGORITHM=HS256
PROJECT_NAME=Wiesbaden After Dark API
PORT=8000
RAILWAY_ENVIRONMENT=production
DEBUG=False
```

---

## Step 3: Generate Public Domain

1. In Railway dashboard → Settings tab
2. Click "Generate Domain"
3. Copy the domain (format: `xxx.up.railway.app`)
4. Save this URL - you'll need it for iOS app

**Example:** `https://generous-harmony-production.up.railway.app`

---

## Step 4: Run Database Migrations

After deployment completes, you need to create the database tables.

### Option A: Automatic (via Railway)

Railway will automatically run migrations on first deploy if you add this to your start command:

```bash
alembic upgrade head && uvicorn app.main:app --host 0.0.0.0 --port $PORT --workers 4
```

### Option B: Manual (via local machine)

```bash
# Set your Railway domain as DATABASE_URL
export DATABASE_URL="postgresql://postgres.exjowhbyrdjnhmkmkvmf:LOLEalmasri998%21@aws-0-eu-central-1.pooler.supabase.com:6543/postgres"

# Run migrations
cd ~/Desktop/Projects-2025/WiesbadenAfterDark/backend
source venv/bin/activate  # If you have venv
alembic upgrade head
```

This creates 14 tables:
- users
- venues
- venue_memberships
- venue_tier_configs
- products
- check_ins
- point_transactions
- transactions
- referral_chains
- events
- event_rsvps
- badges
- wallet_passes
- verification_codes

---

## Step 5: Verify Deployment

### Check Health Endpoint

```bash
curl https://YOUR-DOMAIN.up.railway.app/health
```

Expected response:
```json
{
  "status": "healthy",
  "timestamp": "2025-11-14T03:00:00.000000",
  "version": "1.0.0"
}
```

### Check API Documentation

Visit: `https://YOUR-DOMAIN.up.railway.app/docs`

You should see interactive Swagger/OpenAPI documentation for all 19 endpoints.

### Test Authentication

```bash
curl -X POST https://YOUR-DOMAIN.up.railway.app/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "phoneNumber": "+4915299999999",
    "firstName": "Test",
    "lastName": "User",
    "email": "test@example.com",
    "dateOfBirth": "1990-01-01"
  }'
```

Expected: User created with referral code

---

## Step 6: Seed Production Data (Optional)

### Create Test Venues

Use the API to create venues via the admin endpoints, or run this script locally:

```python
import requests

API_URL = "https://YOUR-DOMAIN.up.railway.app"

venues = [
    {
        "name": "Das Wohnzimmer",
        "type": "bar_restaurant",
        "address": "Wilhelmstraße 24, 65183 Wiesbaden",
        "latitude": 50.0825,
        "longitude": 8.2403,
        "foodMarginPercent": 30.0,
        "beverageMarginPercent": 80.0,
        "defaultMarginPercent": 50.0
    }
]

for venue in venues:
    response = requests.post(f"{API_URL}/api/v1/venues", json=venue)
    print(f"Created: {response.json()}")
```

---

## Step 7: Update iOS App

### Update Backend URL in iOS Code

1. Open Xcode project
2. Find `RealAuthService.swift` or equivalent
3. Update base URL:

```swift
private let baseURL = "https://YOUR-DOMAIN.up.railway.app/api/v1"
```

4. Rebuild iOS app
5. Test registration flow
6. Test venue listing
7. Test check-in flow

---

## Troubleshooting

### Deployment fails

**Check Railway logs:**
```bash
railway logs
```

**Common issues:**
- Missing environment variables
- Python version mismatch (should be 3.11)
- Database connection failed

### Health check fails

**Check:**
1. Environment variables are set correctly
2. DATABASE_URL is accessible
3. Port is set to 8000
4. Railway container is running

**View logs:**
```bash
railway logs --tail 100
```

### Database migrations fail

**Check:**
1. DATABASE_URL is correct
2. Supabase database is accessible
3. Alembic is installed

**Re-run migrations:**
```bash
alembic downgrade -1
alembic upgrade head
```

---

## Post-Deployment Checklist

- [ ] Health endpoint responding
- [ ] API docs accessible
- [ ] Can register new user
- [ ] Can list venues
- [ ] Database tables created
- [ ] iOS app updated with production URL
- [ ] iOS app can connect to backend
- [ ] Full user flow tested (register → login → browse → check-in)

---

## Railway Dashboard Quick Links

- **Dashboard:** https://railway.app/dashboard
- **Project:** generous-harmony
- **Service Logs:** Click on service → Logs tab
- **Environment Variables:** Click on service → Variables tab
- **Deployments:** Click on service → Deployments tab
- **Settings:** Click on service → Settings tab

---

## Production URL

Once deployed, your backend will be available at:

**Format:** `https://generous-harmony-production.up.railway.app`

**Key Endpoints:**
- Health: `/health`
- API Docs: `/docs`
- OpenAPI Schema: `/openapi.json`
- Authentication: `/api/v1/auth/*`
- Users: `/api/v1/users/*`
- Venues: `/api/v1/venues/*`
- Check-ins: `/api/routes/check-ins/*`
- Transactions: `/api/routes/transactions/*`

---

## Next Steps After Deployment

1. **Test API endpoints** via Postman or curl
2. **Seed production venues** with real Wiesbaden locations
3. **Update iOS app** with production URL
4. **Test complete user flow** end-to-end
5. **Monitor Railway logs** for any errors
6. **Set up monitoring** (optional: Sentry, LogRocket)
7. **Configure custom domain** (optional)
8. **Enable HTTPS** (automatic on Railway)

---

## Support

If you encounter issues:

1. Check Railway logs: `railway logs`
2. Check Supabase dashboard for database connectivity
3. Verify environment variables in Railway dashboard
4. Test endpoints with curl/Postman
5. Check GitHub Actions for CI/CD status

---

**Deployment Date:** November 14, 2025
**Backend Version:** v1.0.0-backend-mvp
**Status:** Ready for production deployment 🚀

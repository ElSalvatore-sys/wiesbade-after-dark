# WiesbadenAfterDark Backend API

FastAPI backend for the WiesbadenAfterDark iOS application, deployed on Railway.

## Features

- FastAPI web framework
- PostgreSQL database (Supabase)
- JWT authentication
- SMS verification (Twilio)
- Automatic API documentation
- Health check endpoint
- CI/CD with GitHub Actions

## Local Development

### Prerequisites

- Python 3.11+
- PostgreSQL (or Supabase account)
- Twilio account (for SMS verification)

### Setup

1. Install dependencies:
```bash
pip install -r requirements.txt
```

2. Create `.env` file from template:
```bash
cp .env.example .env
```

3. Update `.env` with your credentials:
   - Database connection string
   - JWT secret key
   - Twilio credentials

4. Run the development server:
```bash
uvicorn app.main:app --reload
```

The API will be available at `http://localhost:8000`

### Testing

Run tests with pytest:
```bash
pytest tests/ -v --cov=app
```

### API Documentation

- Swagger UI: `http://localhost:8000/docs`
- ReDoc: `http://localhost:8000/redoc`
- OpenAPI JSON: `http://localhost:8000/api/v1/openapi.json`

## Railway Deployment

### Prerequisites

- Railway account
- Railway CLI installed: `npm install -g @railway/cli`

### Environment Variables

Set these in Railway dashboard:

```
DATABASE_URL=postgresql+asyncpg://...
JWT_SECRET_KEY=<generate-strong-key>
TWILIO_ACCOUNT_SID=<from-twilio>
TWILIO_AUTH_TOKEN=<from-twilio>
TWILIO_VERIFY_SERVICE_SID=<from-twilio>
ALLOWED_ORIGINS=https://wiesbade-after-dark-production.up.railway.app
```

### Deploy

1. Login to Railway:
```bash
railway login
```

2. Link your project:
```bash
railway link
```

3. Deploy:
```bash
railway up
```

### Production URL

https://wiesbade-after-dark-production.up.railway.app

## CI/CD

GitHub Actions automatically:
- Runs tests on PR and push to main
- Checks code quality (black, flake8)
- Deploys to Railway on main branch push

### Required GitHub Secrets

- `RAILWAY_TOKEN`: Railway API token
- `RAILWAY_PROJECT_ID`: Railway project ID

## Health Check

Check deployment status:
```bash
curl https://wiesbade-after-dark-production.up.railway.app/health
```

Expected response:
```json
{
  "status": "healthy",
  "environment": "production",
  "version": "1.0.0"
}
```

## Architecture

```
backend/
├── app/
│   ├── api/
│   │   └── v1/
│   │       └── api.py          # API routes
│   ├── core/
│   │   └── config.py           # Configuration
│   └── main.py                 # FastAPI app
├── tests/
│   └── test_main.py            # Tests
├── requirements.txt            # Dependencies
├── railway.json                # Railway config
├── Procfile                    # Process definition
└── runtime.txt                 # Python version
```

## Production Configuration

- **Workers**: 4 uvicorn workers
- **Health Check**: `/health` endpoint
- **Timeout**: 100s
- **Restart Policy**: On failure, max 10 retries
- **Platform**: Railway (Nixpacks builder)

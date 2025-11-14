# Missing Railway Variables

Add these to Railway dashboard → Variables tab:

## Critical (Add Now):
```bash
SUPABASE_JWT_SECRET=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImV4am93aGJ5cmRqbmhta21rdm1mIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2MjYxMjIxMCwiZXhwIjoyMDc4MTg4MjEwfQ.ZpkOEL7lybi3eby3Lk89WEkCYyjzWFuyHP_sOH1AkOc
```

## Already Set (Verify):
- DATABASE_URL
- SUPABASE_URL  
- SUPABASE_KEY
- SECRET_KEY
- ALGORITHM
- PROJECT_NAME
- PORT
- DEBUG
- ENVIRONMENT
- ALLOWED_ORIGINS
- TWILIO_ACCOUNT_SID
- TWILIO_AUTH_TOKEN
- TWILIO_PHONE_NUMBER

## Instructions:
1. Go to: https://railway.app/project/generous-harmony
2. Click "Variables" tab
3. Click "+ New Variable"
4. Add: SUPABASE_JWT_SECRET with value above
5. Save (auto-redeploys)

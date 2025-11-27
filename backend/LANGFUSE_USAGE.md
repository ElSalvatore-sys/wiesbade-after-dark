# LangFuse Observability Integration

## Overview

LangFuse is now integrated into WiesbadenAfterDark backend to provide comprehensive observability for all API requests, service operations, and database queries.

## Configuration

### Environment Variables

The following environment variables are configured in `.env`:

```bash
LANGFUSE_PUBLIC_KEY=pk-lf-9e9c3d42-a19d-4031-85f9-b9dd46dfc8f1
LANGFUSE_SECRET_KEY=sk-lf-ef116a33-1f15-4cb1-acac-d92784414d12
LANGFUSE_HOST=http://localhost:3100
```

### Access LangFuse UI

- **URL**: http://localhost:3100
- **Project**: WiesbadenAfterDark

## Automatic Tracing

### HTTP Request Tracing

All HTTP requests are automatically traced via the `LangfuseMiddleware`. Each request creates a trace with:

- Request metadata (method, path, query params, headers)
- Response metadata (status code, headers)
- Execution duration
- User context (if authenticated)
- Error information (if any)

**No code changes needed** - all API endpoints are automatically instrumented!

### Viewing Traces

1. Open http://localhost:3100
2. Navigate to "Traces" section
3. Filter by:
   - Time range
   - HTTP method (GET, POST, PUT, DELETE)
   - Status code
   - User ID
   - Tags

## Manual Instrumentation

### Service Layer Operations

Use the `@observe_service` decorator to track service operations:

```python
from app.core.observability import observe_service

class UserService:
    @observe_service(name="create_user")
    async def create_user(self, db: AsyncSession, user_data: UserCreate):
        """Create a new user - automatically tracked in LangFuse"""
        # Your logic here
        user = User(**user_data.dict())
        db.add(user)
        await db.commit()
        return user

    @observe_service(name="authenticate_user")
    async def authenticate(self, db: AsyncSession, phone: str, code: str):
        """Authenticate user - automatically tracked"""
        # Your logic here
        pass
```

### Database Operations

Use the `@observe_db` decorator to track database queries:

```python
from app.core.observability import observe_db

class UserRepository:
    @observe_db(name="get_user_by_phone")
    async def get_by_phone(self, db: AsyncSession, phone: str):
        """Find user by phone - tracked in LangFuse"""
        result = await db.execute(
            select(User).where(User.phone == phone)
        )
        return result.scalar_one_or_none()

    @observe_db(name="create_user_transaction")
    async def create_with_transaction(self, db: AsyncSession, user_data: dict):
        """Create user with transaction - tracked"""
        async with db.begin():
            # Your transactional logic
            pass
```

### API Endpoints

Use the `@observe_api` decorator for specific endpoint tracking:

```python
from app.core.observability import observe_api
from fastapi import APIRouter

router = APIRouter()

@router.post("/users/register")
@observe_api(name="user_registration")
async def register_user(user_data: UserCreate):
    """
    Register new user
    - Automatically traced by middleware
    - Additional observation added by decorator
    """
    # Your logic here
    pass
```

### Custom Operations

Use the `@observe_operation` decorator for custom tracking:

```python
from app.core.observability import observe_operation

@observe_operation(
    name="calculate_loyalty_points",
    capture_input=True,
    capture_output=True,
    metadata={"service": "points", "version": "2.0"}
)
async def calculate_points(transaction_amount: float, user_tier: str):
    """Custom operation tracking with metadata"""
    # Your calculation logic
    points = transaction_amount * get_multiplier(user_tier)
    return points
```

## Best Practices

### 1. Service Layer Pattern

Add observability to service methods:

```python
# ✅ GOOD - Service methods tracked
class VenueService:
    @observe_service()
    async def create_venue(self, data: VenueCreate):
        # Business logic
        pass

    @observe_service()
    async def get_venue_stats(self, venue_id: int):
        # Stats calculation
        pass
```

### 2. Database Layer Pattern

Track database operations separately:

```python
# ✅ GOOD - Database operations tracked
class TransactionRepository:
    @observe_db(name="get_user_transactions")
    async def get_by_user(self, db: AsyncSession, user_id: int):
        # Query logic
        pass

    @observe_db(name="create_transaction")
    async def create(self, db: AsyncSession, data: dict):
        # Insert logic
        pass
```

### 3. Avoid Over-Instrumentation

```python
# ❌ BAD - Too granular
@observe_operation()
def validate_email(email: str):
    return "@" in email

# ✅ GOOD - Right level of granularity
@observe_service()
async def register_user(user_data: UserCreate):
    # Includes email validation inside
    validate_email(user_data.email)
    # ... rest of registration
```

### 4. Meaningful Names

```python
# ❌ BAD - Generic name
@observe_service(name="process")
async def process_payment(amount: float):
    pass

# ✅ GOOD - Descriptive name
@observe_service(name="process_payment_transaction")
async def process_payment(amount: float):
    pass
```

## Monitoring & Debugging

### Common Use Cases

1. **Performance Analysis**
   - Identify slow API endpoints
   - Find bottleneck database queries
   - Optimize service layer operations

2. **Error Tracking**
   - View all failed requests
   - Trace error propagation through layers
   - Correlate errors with user actions

3. **User Journey Tracking**
   - Follow user flow through the app
   - Identify drop-off points
   - Analyze user behavior patterns

4. **API Usage Analytics**
   - Most called endpoints
   - Request/response patterns
   - Geographic distribution

### Example Queries in LangFuse

1. **Find slow requests**:
   - Filter: duration > 1000ms
   - Sort: by duration (descending)

2. **User-specific traces**:
   - Filter: user_id = "specific_user_id"
   - Time range: Last 24 hours

3. **Error analysis**:
   - Filter: level = "ERROR"
   - Group by: error type

## Testing the Integration

### 1. Start the Backend

```bash
cd ~/Desktop/Projects-2025/WiesbadenAfterDark/backend
uvicorn app.main:app --reload
```

### 2. Make Test Requests

```bash
# Health check
curl http://localhost:8000/health

# Create user (example)
curl -X POST http://localhost:8000/api/v1/users/register \
  -H "Content-Type: application/json" \
  -d '{"phone": "+491234567890", "name": "Test User"}'
```

### 3. View in LangFuse

1. Open http://localhost:3100
2. Navigate to "Traces"
3. You should see traces for your requests!

## Troubleshooting

### LangFuse Not Showing Traces

1. **Check credentials**:
   ```bash
   # Verify .env has correct keys
   cat backend/.env | grep LANGFUSE
   ```

2. **Check LangFuse is running**:
   ```bash
   curl http://localhost:3100/api/public/health
   ```

3. **Check backend logs**:
   Look for: `✅ LangFuse initialized: http://localhost:3100`

### LangFuse Shows "Disabled"

- Verify environment variables are loaded
- Check `backend/.env` file exists
- Restart the backend server

### Traces Not Appearing

- Check network connectivity to LangFuse
- Verify public/secret keys match
- Check for errors in backend console

## Production Deployment

### Railway Environment Variables

When deploying to Railway, add these environment variables:

```bash
LANGFUSE_PUBLIC_KEY=pk-lf-9e9c3d42-a19d-4031-85f9-b9dd46dfc8f1
LANGFUSE_SECRET_KEY=sk-lf-ef116a33-1f15-4cb1-acac-d92784414d12
LANGFUSE_HOST=https://your-langfuse-cloud-url.com  # Or self-hosted URL
```

### Cloud LangFuse (Optional)

Instead of self-hosting, you can use LangFuse Cloud:

1. Sign up at https://cloud.langfuse.com
2. Create a project "WiesbadenAfterDark"
3. Get cloud API keys
4. Update `LANGFUSE_HOST` to cloud URL

## Resources

- **LangFuse Docs**: https://langfuse.com/docs
- **LangFuse Dashboard**: http://localhost:3100
- **API Docs**: http://localhost:8000/docs
- **Backend Code**: `app/core/observability.py`

## Support

For issues or questions:
1. Check the troubleshooting section above
2. Review LangFuse documentation
3. Check backend console logs for errors

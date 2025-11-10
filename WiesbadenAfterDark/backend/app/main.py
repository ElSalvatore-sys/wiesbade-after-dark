"""
Wiesbaden After Dark API
FastAPI application for loyalty platform backend.
"""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

from app.core.config import settings
from app.db.session import init_db

# Create FastAPI app
app = FastAPI(
    title="Wiesbaden After Dark API",
    description="Loyalty platform for nightlife venues in Wiesbaden, Germany",
    version=settings.APP_VERSION,
    docs_url="/api/docs",
    redoc_url="/api/redoc",
    openapi_url="/api/openapi.json",
)

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.ALLOWED_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.on_event("startup")
async def startup_event():
    """Initialize database on application startup."""
    print("🚀 Starting Wiesbaden After Dark API...")
    print(f"📦 Environment: {'DEBUG' if settings.DEBUG else 'PRODUCTION'}")

    try:
        await init_db()
        print("✅ Database initialized successfully")
    except Exception as e:
        print(f"⚠️ Database initialization skipped (connection error): {e}")
        print("⚠️ Server will run without database connectivity")


@app.on_event("shutdown")
async def shutdown_event():
    """Cleanup on application shutdown."""
    print("👋 Shutting down Wiesbaden After Dark API...")


@app.get("/", tags=["Root"])
async def root():
    """Root endpoint."""
    return {
        "message": "Welcome to Wiesbaden After Dark API",
        "version": settings.APP_VERSION,
        "docs": "/api/docs",
    }


@app.get("/health", tags=["Health"])
async def health_check():
    """Health check endpoint for monitoring."""
    return {
        "status": "healthy",
        "version": settings.APP_VERSION,
        "timestamp": "2025-01-01T00:00:00Z",
    }


# Import and include routers
from app.api.routes import auth, users, venues, transactions, admin

# Authentication routes
app.include_router(auth.router, prefix="/api/v1/auth", tags=["Authentication"])

# User management routes
app.include_router(users.router, prefix="/api/v1/users", tags=["Users"])

# Venue discovery routes
app.include_router(venues.router, prefix="/api/v1/venues", tags=["Venues"])

# Transaction processing routes
app.include_router(transactions.router, prefix="/api/v1/transactions", tags=["Transactions"])

# Admin/owner management routes
app.include_router(admin.router, prefix="/api/v1/admin", tags=["Admin"])


@app.exception_handler(404)
async def not_found_handler(request, exc):
    """Custom 404 handler."""
    return JSONResponse(
        status_code=404,
        content={"detail": "Resource not found"},
    )


@app.exception_handler(500)
async def server_error_handler(request, exc):
    """Custom 500 handler."""
    return JSONResponse(
        status_code=500,
        content={"detail": "Internal server error"},
    )


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(
        "app.main:app",
        host="0.0.0.0",
        port=8000,
        reload=settings.DEBUG,
    )

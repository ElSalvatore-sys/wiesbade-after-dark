"""
WiesbadenAfterDark API - Main Application
"""
from datetime import datetime
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

from app.core.config import settings
from app.api.v1.api import api_router


# Create FastAPI application
app = FastAPI(
    title=settings.PROJECT_NAME,
    version=settings.VERSION,
    description="Backend API for WiesbadenAfterDark - Nightlife loyalty platform",
    docs_url="/docs",
    redoc_url="/redoc",
    openapi_url="/openapi.json",
)

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.BACKEND_CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# Health check endpoint
@app.get("/health", tags=["health"])
async def health_check():
    """Enhanced health check with config validation"""
    return JSONResponse(
        content={
            "status": "healthy",
            "environment": getattr(settings, "ENVIRONMENT", "unknown"),
            "version": settings.VERSION,
            "timestamp": datetime.utcnow().isoformat(),
            "config": {
                "database": "connected" if settings.DATABASE_URL else "missing",
                "supabase": "configured" if settings.SUPABASE_URL else "not configured",
                "twilio": "configured" if getattr(settings, "TWILIO_ACCOUNT_SID", None) else "not configured",
                "jwt_secret": "set" if settings.SECRET_KEY else "missing",
            },
        }
    )


# Root endpoint
@app.get("/", tags=["root"])
async def root():
    """Root endpoint with API information"""
    return JSONResponse(
        content={
            "message": "WiesbadenAfterDark API",
            "version": settings.VERSION,
            "docs": "/docs",
            "health": "/health",
        }
    )


# Include API router
app.include_router(api_router, prefix=settings.API_V1_STR)


# Startup event
@app.on_event("startup")
async def startup_event():
    """Execute on application startup"""
    print(f"🚀 {settings.PROJECT_NAME} v{settings.VERSION} starting up...")
    print(f"📚 API Documentation: http://localhost:8000/docs")


# Shutdown event
@app.on_event("shutdown")
async def shutdown_event():
    """Execute on application shutdown"""
    print(f"👋 {settings.PROJECT_NAME} shutting down...")


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(
        "app.main:app",
        host="0.0.0.0",
        port=8000,
        reload=True,
        log_level="info",
    )

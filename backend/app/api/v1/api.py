from fastapi import APIRouter

api_router = APIRouter()


@api_router.get("/")
async def root():
    """Root endpoint for API v1"""
    return {
        "message": "WiesbadenAfterDark API v1",
        "status": "operational"
    }


# Additional routers can be included here
# Example:
# from app.api.v1.endpoints import users, venues, offers
# api_router.include_router(users.router, prefix="/users", tags=["users"])
# api_router.include_router(venues.router, prefix="/venues", tags=["venues"])
# api_router.include_router(offers.router, prefix="/offers", tags=["offers"])

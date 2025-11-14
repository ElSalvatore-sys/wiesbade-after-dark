"""
Test fixtures for authentication endpoint testing.

This module provides fixtures for:
- Database session management
- HTTP client setup
- Test data generation
- Event loop configuration
"""
import pytest
import asyncio
from typing import AsyncGenerator, Generator
from httpx import AsyncClient, ASGITransport
from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine, async_sessionmaker
from sqlalchemy.pool import NullPool

# Note: These imports would come from your actual app
# from app.main import app
# from app.core.config import settings
# from app.core.deps import get_db
# from app.models.base import Base

# Test database configuration
# Using SQLite for testing (can be changed to PostgreSQL)
TEST_DATABASE_URL = "sqlite+aiosqlite:///./test.db"

# For PostgreSQL testing:
# TEST_DATABASE_URL = "postgresql+asyncpg://test_user:test_pass@localhost:5432/test_db"


@pytest.fixture(scope="session")
def event_loop() -> Generator:
    """
    Create an event loop for the test session.

    This fixture ensures proper async test execution across the entire test session.
    """
    loop = asyncio.get_event_loop_policy().new_event_loop()
    yield loop
    loop.close()


@pytest.fixture(scope="session")
async def test_engine():
    """
    Create and configure the test database engine.

    This fixture:
    - Creates the test database engine with proper async support
    - Sets up all database tables before tests
    - Tears down tables after all tests complete
    - Disposes of the engine properly
    """
    engine = create_async_engine(
        TEST_DATABASE_URL,
        echo=True,  # Set to False to reduce log noise
        poolclass=NullPool,  # Disable connection pooling for tests
    )

    # Create all tables
    # Uncomment when Base is available:
    # async with engine.begin() as conn:
    #     await conn.run_sync(Base.metadata.create_all)

    yield engine

    # Drop all tables
    # Uncomment when Base is available:
    # async with engine.begin() as conn:
    #     await conn.run_sync(Base.metadata.drop_all)

    await engine.dispose()


@pytest.fixture
async def db_session(test_engine) -> AsyncGenerator[AsyncSession, None]:
    """
    Provide a clean database session for each test.

    This fixture:
    - Creates a new session for each test
    - Automatically rolls back changes after each test
    - Ensures test isolation
    """
    async_session_maker = async_sessionmaker(
        test_engine,
        class_=AsyncSession,
        expire_on_commit=False,
        autocommit=False,
        autoflush=False,
    )

    async with async_session_maker() as session:
        yield session
        await session.rollback()


@pytest.fixture
async def client(db_session) -> AsyncGenerator[AsyncClient, None]:
    """
    Provide an HTTP client for testing API endpoints.

    This fixture:
    - Creates an HTTPX AsyncClient configured for testing
    - Overrides the database dependency to use the test session
    - Clears overrides after each test
    """
    # Mock app for testing (replace with actual app import)
    from fastapi import FastAPI
    app = FastAPI()

    # Override database dependency
    # Uncomment when app is available:
    # async def override_get_db():
    #     yield db_session
    # app.dependency_overrides[get_db] = override_get_db

    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as ac:
        yield ac

    # Clear overrides
    # Uncomment when app is available:
    # app.dependency_overrides.clear()


@pytest.fixture
def test_user_data() -> dict:
    """
    Provide standard test user data.

    Returns a dictionary with valid user registration data that can be
    used across multiple tests.
    """
    return {
        "phoneNumber": "+4915234567890",
        "firstName": "Test",
        "lastName": "User",
        "email": "test@example.com",
        "dateOfBirth": "1990-01-01"
    }


@pytest.fixture
def test_user_data_2() -> dict:
    """
    Provide alternative test user data for multi-user tests.
    """
    return {
        "phoneNumber": "+4915234567891",
        "firstName": "Jane",
        "lastName": "Doe",
        "email": "jane@example.com",
        "dateOfBirth": "1992-05-15"
    }


@pytest.fixture
def auth_headers():
    """
    Factory fixture for creating authorization headers.

    Usage:
        headers = auth_headers(access_token)
    """
    def _auth_headers(token: str) -> dict:
        return {"Authorization": f"Bearer {token}"}
    return _auth_headers

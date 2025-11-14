# Authentication Endpoints Test Suite

Comprehensive test suite for FastAPI authentication endpoints testing all 5 core auth endpoints with 35+ test cases.

## 📋 Table of Contents

- [Overview](#overview)
- [Test Coverage](#test-coverage)
- [Installation](#installation)
- [Running Tests](#running-tests)
- [Test Structure](#test-structure)
- [Writing New Tests](#writing-new-tests)
- [CI/CD Integration](#cicd-integration)

## 🎯 Overview

This test suite provides comprehensive coverage for the authentication system, including:

- **Unit Tests**: Individual endpoint testing with edge cases
- **Integration Tests**: Complete authentication flows
- **Error Handling**: Validation and error recovery scenarios
- **Security Tests**: Token management and invalidation

### Tested Endpoints

1. **POST /auth/register** - User registration with phone verification
2. **POST /auth/verify-phone** - Phone number verification via SMS
3. **POST /auth/login** - User login with SMS verification
4. **POST /auth/refresh** - Access token refresh
5. **POST /auth/logout** - User logout and token invalidation

## 📊 Test Coverage

### Unit Tests (`test_auth.py`)

| Endpoint | Test Cases | Coverage |
|----------|-----------|----------|
| /auth/register | 8 tests | Registration, validation, referrals, duplicates |
| /auth/verify-phone | 5 tests | Verification success/failure, expiration |
| /auth/login | 4 tests | Login flow, unregistered users, validation |
| /auth/refresh | 5 tests | Token refresh, rotation, expiration |
| /auth/logout | 4 tests | Logout, token invalidation |

**Total Unit Tests**: 26 test cases

### Integration Tests (`test_integration.py`)

| Test Suite | Test Cases | Coverage |
|------------|-----------|----------|
| AuthenticationFlow | 4 tests | End-to-end user journeys |
| ReferralFlow | 2 tests | Multi-user referral chains |
| ErrorRecovery | 2 tests | Retry mechanisms, error handling |
| ConcurrentUsers | 2 tests | Multi-user scenarios |
| EdgeCases | 2 tests | Boundary conditions, race conditions |

**Total Integration Tests**: 12 test cases

### Overall Statistics

- ✅ **38+ comprehensive test cases**
- 🎯 **90%+ code coverage target**
- 🔄 **Async/await support**
- 🏗️ **Isolated test database**
- 📝 **Parametrized tests** for multiple scenarios

## 🚀 Installation

### 1. Install Dependencies

```bash
cd backend
pip install -r requirements-test.txt
```

### 2. Set Up Test Environment

```bash
# Copy test environment variables
cp .env.test .env

# Or set environment variables
export TESTING=true
export DATABASE_URL=sqlite+aiosqlite:///./test.db
```

### 3. Verify Installation

```bash
pytest --version
pytest --collect-only
```

## 🧪 Running Tests

### Run All Tests

```bash
# Basic run
pytest

# Verbose output
pytest -v

# With coverage
pytest --cov=app --cov-report=html
```

### Run Specific Test Files

```bash
# Unit tests only
pytest tests/test_auth.py -v

# Integration tests only
pytest tests/test_integration.py -v
```

### Run Specific Test Classes

```bash
# Test registration endpoint
pytest tests/test_auth.py::TestUserRegistration -v

# Test login flow
pytest tests/test_integration.py::TestAuthenticationFlow -v
```

### Run Specific Test Cases

```bash
# Test single case
pytest tests/test_auth.py::TestUserRegistration::test_register_new_user_success -v

# Test parametrized cases
pytest tests/test_auth.py::TestUserRegistration::test_register_invalid_phone_fails -v
```

### Run Tests by Marker

```bash
# Run only integration tests
pytest -m integration

# Run only unit tests
pytest -m unit

# Skip slow tests
pytest -m "not slow"
```

### Parallel Execution

```bash
# Run tests in parallel (faster)
pytest -n auto

# Run with specific number of workers
pytest -n 4
```

### Generate Coverage Report

```bash
# HTML report
pytest --cov=app --cov-report=html
open htmlcov/index.html

# Terminal report
pytest --cov=app --cov-report=term-missing

# XML report (for CI)
pytest --cov=app --cov-report=xml
```

## 🏗️ Test Structure

### Directory Layout

```
backend/
├── tests/
│   ├── __init__.py
│   ├── conftest.py              # Shared fixtures
│   ├── test_auth.py             # Unit tests for auth endpoints
│   ├── test_integration.py      # Integration tests
│   └── README.md               # This file
├── pytest.ini                   # Pytest configuration
├── requirements-test.txt        # Test dependencies
└── .env.test                    # Test environment variables
```

### Fixtures (`conftest.py`)

The test suite uses pytest fixtures for setup:

- **`event_loop`**: Async event loop for test session
- **`test_engine`**: Database engine with auto-cleanup
- **`db_session`**: Isolated database session per test
- **`client`**: HTTP client for API requests
- **`test_user_data`**: Standard test user data
- **`test_user_data_2`**: Alternative test user data
- **`auth_headers`**: Helper for authorization headers

### Test Organization

Tests are organized by endpoint and scenario:

```python
class TestUserRegistration:
    """Tests for POST /auth/register"""

    async def test_register_new_user_success(self, client, test_user_data):
        """Test successful registration"""
        # Arrange
        # Act
        # Assert

    async def test_register_duplicate_phone_fails(self, client, test_user_data):
        """Test duplicate prevention"""
        # ...
```

## ✍️ Writing New Tests

### Template for Unit Tests

```python
import pytest
from httpx import AsyncClient


class TestNewEndpoint:
    """Tests for POST /api/v1/new-endpoint"""

    @pytest.mark.asyncio
    async def test_new_endpoint_success(
        self,
        client: AsyncClient,
        test_user_data: dict
    ):
        """
        Test successful endpoint call.

        Expected behavior:
        - Returns 200 status
        - Returns expected data structure
        """
        response = await client.post(
            "/api/v1/new-endpoint",
            json=test_user_data
        )

        assert response.status_code == 200
        assert "expectedField" in response.json()

    @pytest.mark.asyncio
    async def test_new_endpoint_validation_error(
        self,
        client: AsyncClient
    ):
        """Test validation error handling"""
        response = await client.post(
            "/api/v1/new-endpoint",
            json={}  # Missing required fields
        )

        assert response.status_code == 422
```

### Template for Integration Tests

```python
class TestNewFlow:
    """Integration tests for new workflow"""

    @pytest.mark.asyncio
    async def test_complete_new_flow(
        self,
        client: AsyncClient,
        test_user_data: dict
    ):
        """
        Test complete workflow.

        Flow:
        1. Step one
        2. Step two
        3. Step three

        Expected behavior:
        - All steps succeed
        - Data flows correctly
        """
        # Step 1
        step1_response = await client.post(
            "/api/v1/step1",
            json=test_user_data
        )
        assert step1_response.status_code == 200

        # Step 2
        data_from_step1 = step1_response.json()
        step2_response = await client.post(
            "/api/v1/step2",
            json={"data": data_from_step1["id"]}
        )
        assert step2_response.status_code == 200

        # Verify final state
        # ...
```

### Best Practices

1. **Use descriptive test names**: Test names should clearly describe what is being tested
2. **Follow AAA pattern**: Arrange, Act, Assert
3. **Test one thing**: Each test should verify one specific behavior
4. **Use fixtures**: Leverage shared fixtures from `conftest.py`
5. **Add docstrings**: Explain expected behavior in docstrings
6. **Parametrize**: Use `@pytest.mark.parametrize` for similar test cases
7. **Mark tests**: Use markers like `@pytest.mark.integration` for organization

## 🔄 CI/CD Integration

### GitHub Actions Example

```yaml
name: Test Auth Endpoints

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3

      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'

      - name: Install dependencies
        run: |
          cd backend
          pip install -r requirements-test.txt

      - name: Run tests
        run: |
          cd backend
          pytest --cov=app --cov-report=xml

      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          file: ./backend/coverage.xml
```

### Docker Testing

```dockerfile
FROM python:3.11-slim

WORKDIR /app
COPY requirements-test.txt .
RUN pip install -r requirements-test.txt

COPY . .
CMD ["pytest", "-v", "--cov=app"]
```

Run with:
```bash
docker build -t auth-tests .
docker run auth-tests
```

## 🐛 Debugging Tests

### Run with Debug Output

```bash
# Show print statements
pytest -s

# Show detailed output
pytest -vv

# Show local variables on failure
pytest -l

# Drop into debugger on failure
pytest --pdb
```

### Common Issues

**Issue**: Tests fail with database errors
```bash
# Solution: Reset test database
rm test.db
pytest
```

**Issue**: Async tests not running
```bash
# Solution: Check pytest-asyncio is installed
pip install pytest-asyncio
# Verify pytest.ini has: asyncio_mode = auto
```

**Issue**: Import errors
```bash
# Solution: Install package in editable mode
pip install -e .
```

## 📈 Success Criteria

- ✅ 38+ test cases covering all auth endpoints
- ✅ All edge cases and error scenarios tested
- ✅ Integration tests for complete user flows
- ✅ 90%+ code coverage achieved
- ✅ All tests passing
- ✅ Test fixtures for easy setup
- ✅ Parametrized tests for multiple scenarios
- ✅ Clear documentation and examples

## 🤝 Contributing

When adding new tests:

1. Follow existing test structure and naming
2. Add docstrings explaining expected behavior
3. Update this README if adding new test categories
4. Ensure tests are isolated and don't depend on execution order
5. Run full test suite before committing: `pytest -v --cov=app`

## 📚 Resources

- [Pytest Documentation](https://docs.pytest.org/)
- [FastAPI Testing Guide](https://fastapi.tiangolo.com/tutorial/testing/)
- [Pytest-asyncio](https://pytest-asyncio.readthedocs.io/)
- [HTTPX Testing](https://www.python-httpx.org/advanced/#calling-into-python-web-apps)

---

**Last Updated**: 2025-11-14
**Test Suite Version**: 1.0.0
**Maintainer**: Development Team

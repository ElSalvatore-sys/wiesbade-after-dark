"""
Comprehensive test suite for authentication endpoints.

This module tests all 5 core authentication endpoints:
1. POST /auth/register - User registration
2. POST /auth/verify-phone - Phone verification
3. POST /auth/login - Login (sends SMS)
4. POST /auth/refresh - Token refresh
5. POST /auth/logout - Logout

Each test class focuses on a specific endpoint with multiple test cases
covering success scenarios, edge cases, and error conditions.
"""
import pytest
from httpx import AsyncClient


class TestUserRegistration:
    """
    Test suite for endpoint #1: POST /auth/register

    This endpoint handles new user registration with phone number verification.
    """

    @pytest.mark.asyncio
    async def test_register_new_user_success(
        self,
        client: AsyncClient,
        test_user_data: dict
    ):
        """
        Test successful registration of a new user.

        Expected behavior:
        - Returns 200 status code
        - Returns user object with phone number
        - Generates unique referral code
        - Sends verification SMS (returns verification SID)
        - Returns success message
        """
        response = await client.post("/api/v1/auth/register", json=test_user_data)

        assert response.status_code == 200
        data = response.json()

        # Verify response structure
        assert "user" in data
        assert data["user"]["phoneNumber"] == test_user_data["phoneNumber"]
        assert data["user"]["firstName"] == test_user_data["firstName"]
        assert data["user"]["lastName"] == test_user_data["lastName"]
        assert data["user"]["email"] == test_user_data["email"]

        # Verify referral code generation
        assert "referralCode" in data["user"]
        assert len(data["user"]["referralCode"]) > 0

        # Verify SMS verification was sent
        assert "verificationSid" in data
        assert "message" in data

    @pytest.mark.asyncio
    async def test_register_duplicate_phone_fails(
        self,
        client: AsyncClient,
        test_user_data: dict
    ):
        """
        Test that duplicate phone number registration is rejected.

        Expected behavior:
        - First registration succeeds
        - Second registration with same phone fails with 400
        - Error message indicates phone already registered
        """
        # First registration
        first_response = await client.post(
            "/api/v1/auth/register",
            json=test_user_data
        )
        assert first_response.status_code == 200

        # Second registration (duplicate)
        second_response = await client.post(
            "/api/v1/auth/register",
            json=test_user_data
        )

        assert second_response.status_code == 400
        error_detail = second_response.json()["detail"].lower()
        assert "already registered" in error_detail or "already exists" in error_detail

    @pytest.mark.asyncio
    @pytest.mark.parametrize("invalid_phone,reason", [
        ("123", "Too short"),
        ("abcdefghijk", "Not a number"),
        ("+1234567890123456789", "Too long"),
        ("", "Empty string"),
        ("+49152345678", "Missing digits"),
    ])
    async def test_register_invalid_phone_fails(
        self,
        client: AsyncClient,
        test_user_data: dict,
        invalid_phone: str,
        reason: str
    ):
        """
        Test that invalid phone numbers are rejected.

        Expected behavior:
        - Returns 422 Unprocessable Entity
        - Validation error indicates phone number issue
        """
        test_user_data["phoneNumber"] = invalid_phone
        response = await client.post("/api/v1/auth/register", json=test_user_data)

        assert response.status_code == 422, f"Failed for: {reason}"

    @pytest.mark.asyncio
    async def test_register_with_valid_referral_code(
        self,
        client: AsyncClient,
        test_user_data: dict,
        test_user_data_2: dict
    ):
        """
        Test registration with a valid referral code.

        Expected behavior:
        - Creates referrer user first
        - New user registers with referrer's code
        - New user is linked to referrer
        - Both users may receive referral bonuses
        """
        # Create referrer
        referrer_response = await client.post(
            "/api/v1/auth/register",
            json=test_user_data
        )
        assert referrer_response.status_code == 200
        referral_code = referrer_response.json()["user"]["referralCode"]

        # Register with referral
        test_user_data_2["referralCode"] = referral_code
        response = await client.post("/api/v1/auth/register", json=test_user_data_2)

        assert response.status_code == 200
        new_user = response.json()["user"]
        assert "referredBy" in new_user
        assert new_user["referredBy"] == referral_code

    @pytest.mark.asyncio
    async def test_register_invalid_referral_code_fails(
        self,
        client: AsyncClient,
        test_user_data: dict
    ):
        """
        Test that invalid referral code is rejected.

        Expected behavior:
        - Returns 400 Bad Request
        - Error indicates invalid referral code
        """
        test_user_data["referralCode"] = "INVALID123XYZ"
        response = await client.post("/api/v1/auth/register", json=test_user_data)

        assert response.status_code == 400
        assert "invalid" in response.json()["detail"].lower()

    @pytest.mark.asyncio
    @pytest.mark.parametrize("missing_field", [
        "phoneNumber",
        "firstName",
        "lastName",
        "email",
        "dateOfBirth"
    ])
    async def test_register_missing_required_fields(
        self,
        client: AsyncClient,
        test_user_data: dict,
        missing_field: str
    ):
        """
        Test that all required fields are validated.

        Expected behavior:
        - Returns 422 for missing required fields
        """
        incomplete_data = test_user_data.copy()
        del incomplete_data[missing_field]

        response = await client.post("/api/v1/auth/register", json=incomplete_data)
        assert response.status_code == 422

    @pytest.mark.asyncio
    async def test_register_invalid_email_format(
        self,
        client: AsyncClient,
        test_user_data: dict
    ):
        """
        Test that invalid email format is rejected.

        Expected behavior:
        - Returns 422 for malformed email
        """
        test_user_data["email"] = "not-an-email"
        response = await client.post("/api/v1/auth/register", json=test_user_data)

        assert response.status_code == 422


class TestPhoneVerification:
    """
    Test suite for endpoint #2: POST /auth/verify-phone

    This endpoint verifies phone numbers using SMS codes.
    """

    @pytest.mark.asyncio
    async def test_verify_phone_success(
        self,
        client: AsyncClient,
        test_user_data: dict
    ):
        """
        Test successful phone verification.

        Expected behavior:
        - User registers first
        - Verification with correct code succeeds
        - Returns access token, refresh token, and user data
        """
        # Register user
        await client.post("/api/v1/auth/register", json=test_user_data)

        # Verify (using test code for development)
        verify_data = {
            "phoneNumber": test_user_data["phoneNumber"],
            "code": "123456"  # Test code for development
        }
        response = await client.post("/api/v1/auth/verify-phone", json=verify_data)

        assert response.status_code == 200
        data = response.json()

        # Verify token structure
        assert "accessToken" in data
        assert "refreshToken" in data
        assert len(data["accessToken"]) > 0
        assert len(data["refreshToken"]) > 0

        # Verify user data returned
        assert "user" in data
        assert data["user"]["phoneNumber"] == test_user_data["phoneNumber"]

    @pytest.mark.asyncio
    async def test_verify_invalid_code_fails(
        self,
        client: AsyncClient,
        test_user_data: dict
    ):
        """
        Test that incorrect verification code is rejected.

        Expected behavior:
        - Returns 400 Bad Request
        - Error indicates invalid code
        """
        await client.post("/api/v1/auth/register", json=test_user_data)

        verify_data = {
            "phoneNumber": test_user_data["phoneNumber"],
            "code": "000000"  # Invalid code
        }
        response = await client.post("/api/v1/auth/verify-phone", json=verify_data)

        assert response.status_code == 400
        assert "invalid" in response.json()["detail"].lower() or \
               "incorrect" in response.json()["detail"].lower()

    @pytest.mark.asyncio
    async def test_verify_unregistered_phone_fails(
        self,
        client: AsyncClient
    ):
        """
        Test verification attempt for unregistered phone number.

        Expected behavior:
        - Returns 404 Not Found
        - Error indicates user not found
        """
        verify_data = {
            "phoneNumber": "+4915299999999",
            "code": "123456"
        }
        response = await client.post("/api/v1/auth/verify-phone", json=verify_data)

        assert response.status_code == 404

    @pytest.mark.asyncio
    async def test_verify_expired_code_fails(
        self,
        client: AsyncClient,
        test_user_data: dict
    ):
        """
        Test that expired verification codes are rejected.

        Note: This test may require time manipulation or mocking.
        """
        await client.post("/api/v1/auth/register", json=test_user_data)

        # In a real scenario, we'd wait or mock time passage
        # For now, we test the endpoint structure
        verify_data = {
            "phoneNumber": test_user_data["phoneNumber"],
            "code": "999999"  # Simulating expired code
        }
        response = await client.post("/api/v1/auth/verify-phone", json=verify_data)

        # Should fail (either 400 for invalid or 404)
        assert response.status_code in [400, 404]

    @pytest.mark.asyncio
    async def test_verify_missing_code_fails(
        self,
        client: AsyncClient,
        test_user_data: dict
    ):
        """
        Test that missing verification code is rejected.

        Expected behavior:
        - Returns 422 Unprocessable Entity
        """
        verify_data = {
            "phoneNumber": test_user_data["phoneNumber"]
            # Missing "code" field
        }
        response = await client.post("/api/v1/auth/verify-phone", json=verify_data)

        assert response.status_code == 422


class TestLogin:
    """
    Test suite for endpoint #3: POST /auth/login

    This endpoint sends verification codes to registered users for login.
    """

    @pytest.mark.asyncio
    async def test_login_sends_verification(
        self,
        client: AsyncClient,
        test_user_data: dict
    ):
        """
        Test that login sends verification code to registered user.

        Expected behavior:
        - User must be registered and verified first
        - Login sends SMS with verification code
        - Returns verification SID and message
        """
        # Register and verify user first
        await client.post("/api/v1/auth/register", json=test_user_data)
        await client.post("/api/v1/auth/verify-phone", json={
            "phoneNumber": test_user_data["phoneNumber"],
            "code": "123456"
        })

        # Login
        login_data = {"phoneNumber": test_user_data["phoneNumber"]}
        response = await client.post("/api/v1/auth/login", json=login_data)

        assert response.status_code == 200
        data = response.json()

        assert "verificationSid" in data
        assert "message" in data
        assert len(data["verificationSid"]) > 0

    @pytest.mark.asyncio
    async def test_login_unregistered_fails(
        self,
        client: AsyncClient
    ):
        """
        Test that login fails for unregistered phone number.

        Expected behavior:
        - Returns 404 Not Found
        - Error indicates user not found
        """
        login_data = {"phoneNumber": "+4915299999999"}
        response = await client.post("/api/v1/auth/login", json=login_data)

        assert response.status_code == 404

    @pytest.mark.asyncio
    async def test_login_unverified_user_fails(
        self,
        client: AsyncClient,
        test_user_data: dict
    ):
        """
        Test that unverified users cannot login.

        Expected behavior:
        - User registered but not verified
        - Login attempt fails with 403 Forbidden
        """
        # Register but don't verify
        await client.post("/api/v1/auth/register", json=test_user_data)

        login_data = {"phoneNumber": test_user_data["phoneNumber"]}
        response = await client.post("/api/v1/auth/login", json=login_data)

        # May return 403 or 400 depending on implementation
        assert response.status_code in [400, 403]

    @pytest.mark.asyncio
    async def test_login_invalid_phone_format(
        self,
        client: AsyncClient
    ):
        """
        Test that invalid phone format is rejected.

        Expected behavior:
        - Returns 422 Unprocessable Entity
        """
        login_data = {"phoneNumber": "invalid"}
        response = await client.post("/api/v1/auth/login", json=login_data)

        assert response.status_code == 422


class TestTokenRefresh:
    """
    Test suite for endpoint #4: POST /auth/refresh

    This endpoint refreshes access tokens using refresh tokens.
    """

    @pytest.mark.asyncio
    async def test_refresh_token_success(
        self,
        client: AsyncClient,
        test_user_data: dict
    ):
        """
        Test successful token refresh.

        Expected behavior:
        - User logs in and gets tokens
        - Refresh token can be used to get new tokens
        - Returns new access and refresh tokens
        """
        # Register, verify, get tokens
        await client.post("/api/v1/auth/register", json=test_user_data)
        verify_response = await client.post("/api/v1/auth/verify-phone", json={
            "phoneNumber": test_user_data["phoneNumber"],
            "code": "123456"
        })
        refresh_token = verify_response.json()["refreshToken"]

        # Refresh
        response = await client.post("/api/v1/auth/refresh", json={
            "refreshToken": refresh_token
        })

        assert response.status_code == 200
        data = response.json()

        assert "accessToken" in data
        assert "refreshToken" in data
        assert len(data["accessToken"]) > 0
        assert len(data["refreshToken"]) > 0

        # New tokens should be different from original
        assert data["refreshToken"] != refresh_token

    @pytest.mark.asyncio
    async def test_refresh_invalid_token_fails(
        self,
        client: AsyncClient
    ):
        """
        Test that invalid refresh token is rejected.

        Expected behavior:
        - Returns 401 Unauthorized
        - Error indicates invalid token
        """
        response = await client.post("/api/v1/auth/refresh", json={
            "refreshToken": "invalid.token.here"
        })

        assert response.status_code == 401

    @pytest.mark.asyncio
    async def test_refresh_expired_token_fails(
        self,
        client: AsyncClient
    ):
        """
        Test that expired refresh token is rejected.

        Note: This test may require time manipulation or mocking.
        """
        # Using a malformed token to simulate expiration
        response = await client.post("/api/v1/auth/refresh", json={
            "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjB9.invalid"
        })

        assert response.status_code == 401

    @pytest.mark.asyncio
    async def test_refresh_missing_token_fails(
        self,
        client: AsyncClient
    ):
        """
        Test that missing refresh token is rejected.

        Expected behavior:
        - Returns 422 Unprocessable Entity
        """
        response = await client.post("/api/v1/auth/refresh", json={})

        assert response.status_code == 422

    @pytest.mark.asyncio
    async def test_refresh_token_reuse_prevention(
        self,
        client: AsyncClient,
        test_user_data: dict
    ):
        """
        Test that refresh tokens cannot be reused.

        Expected behavior:
        - First refresh succeeds
        - Second refresh with same token fails (token rotation)
        """
        # Register, verify, get tokens
        await client.post("/api/v1/auth/register", json=test_user_data)
        verify_response = await client.post("/api/v1/auth/verify-phone", json={
            "phoneNumber": test_user_data["phoneNumber"],
            "code": "123456"
        })
        refresh_token = verify_response.json()["refreshToken"]

        # First refresh
        first_refresh = await client.post("/api/v1/auth/refresh", json={
            "refreshToken": refresh_token
        })
        assert first_refresh.status_code == 200

        # Second refresh with same token
        second_refresh = await client.post("/api/v1/auth/refresh", json={
            "refreshToken": refresh_token
        })
        assert second_refresh.status_code == 401


class TestLogout:
    """
    Test suite for endpoint #5: POST /auth/logout

    This endpoint logs out authenticated users and invalidates tokens.
    """

    @pytest.mark.asyncio
    async def test_logout_success(
        self,
        client: AsyncClient,
        test_user_data: dict,
        auth_headers
    ):
        """
        Test successful logout.

        Expected behavior:
        - User is authenticated
        - Logout invalidates tokens
        - Returns success message
        """
        # Register, verify, get token
        await client.post("/api/v1/auth/register", json=test_user_data)
        verify_response = await client.post("/api/v1/auth/verify-phone", json={
            "phoneNumber": test_user_data["phoneNumber"],
            "code": "123456"
        })
        access_token = verify_response.json()["accessToken"]

        # Logout
        response = await client.post(
            "/api/v1/auth/logout",
            headers=auth_headers(access_token)
        )

        assert response.status_code == 200
        assert "success" in response.json()["message"].lower() or \
               "logged out" in response.json()["message"].lower()

    @pytest.mark.asyncio
    async def test_logout_no_token_fails(
        self,
        client: AsyncClient
    ):
        """
        Test that logout without token is rejected.

        Expected behavior:
        - Returns 401 Unauthorized
        - Error indicates missing authentication
        """
        response = await client.post("/api/v1/auth/logout")

        assert response.status_code == 401

    @pytest.mark.asyncio
    async def test_logout_invalid_token_fails(
        self,
        client: AsyncClient,
        auth_headers
    ):
        """
        Test that logout with invalid token is rejected.

        Expected behavior:
        - Returns 401 Unauthorized
        """
        response = await client.post(
            "/api/v1/auth/logout",
            headers=auth_headers("invalid.token.here")
        )

        assert response.status_code == 401

    @pytest.mark.asyncio
    async def test_logout_token_invalidation(
        self,
        client: AsyncClient,
        test_user_data: dict,
        auth_headers
    ):
        """
        Test that token is invalidated after logout.

        Expected behavior:
        - User logs out successfully
        - Subsequent requests with same token fail
        """
        # Register, verify, get token
        await client.post("/api/v1/auth/register", json=test_user_data)
        verify_response = await client.post("/api/v1/auth/verify-phone", json={
            "phoneNumber": test_user_data["phoneNumber"],
            "code": "123456"
        })
        access_token = verify_response.json()["accessToken"]
        user_id = verify_response.json()["user"]["id"]

        # Logout
        logout_response = await client.post(
            "/api/v1/auth/logout",
            headers=auth_headers(access_token)
        )
        assert logout_response.status_code == 200

        # Try to access protected endpoint with logged-out token
        profile_response = await client.get(
            f"/api/v1/users/{user_id}",
            headers=auth_headers(access_token)
        )
        assert profile_response.status_code == 401

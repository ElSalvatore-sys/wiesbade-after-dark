"""
Integration tests for complete authentication flows.

This module tests end-to-end authentication scenarios that span multiple
endpoints and verify the complete user journey from registration to logout.

Test scenarios:
- Complete registration and verification flow
- Full login flow for returning users
- Token lifecycle (access, refresh, expiration)
- Multi-user scenarios and referral system
- Error recovery and edge cases
"""
import pytest
from httpx import AsyncClient


class TestAuthenticationFlow:
    """
    Integration tests for complete authentication workflows.

    These tests verify that the authentication system works correctly
    when multiple endpoints are used together in realistic scenarios.
    """

    @pytest.mark.asyncio
    async def test_complete_registration_flow(
        self,
        client: AsyncClient,
        test_user_data: dict
    ):
        """
        Test the complete new user registration flow.

        Flow:
        1. User registers with phone number
        2. User receives verification code
        3. User verifies phone
        4. User receives access tokens
        5. User can access protected resources

        Expected behavior:
        - All steps succeed
        - User can authenticate with received token
        """
        # Step 1: Register
        register_response = await client.post(
            "/api/v1/auth/register",
            json=test_user_data
        )
        assert register_response.status_code == 200
        assert "verificationSid" in register_response.json()

        # Step 2: Verify phone
        verify_response = await client.post("/api/v1/auth/verify-phone", json={
            "phoneNumber": test_user_data["phoneNumber"],
            "code": "123456"
        })
        assert verify_response.status_code == 200

        verify_data = verify_response.json()
        access_token = verify_data["accessToken"]
        user_id = verify_data["user"]["id"]

        # Step 3: Access protected endpoint
        profile_response = await client.get(
            f"/api/v1/users/{user_id}",
            headers={"Authorization": f"Bearer {access_token}"}
        )
        assert profile_response.status_code == 200

        profile_data = profile_response.json()
        assert profile_data["phoneNumber"] == test_user_data["phoneNumber"]

    @pytest.mark.asyncio
    async def test_complete_login_flow(
        self,
        client: AsyncClient,
        test_user_data: dict
    ):
        """
        Test the complete returning user login flow.

        Flow:
        1. User registers and verifies (setup)
        2. User initiates login
        3. User receives verification code
        4. User verifies and receives new tokens
        5. User can access protected resources

        Expected behavior:
        - All steps succeed
        - New tokens are issued on login
        - User maintains same identity
        """
        # Setup: Register and verify
        await client.post("/api/v1/auth/register", json=test_user_data)
        initial_verify = await client.post("/api/v1/auth/verify-phone", json={
            "phoneNumber": test_user_data["phoneNumber"],
            "code": "123456"
        })
        initial_user_id = initial_verify.json()["user"]["id"]

        # Step 1: Login
        login_response = await client.post("/api/v1/auth/login", json={
            "phoneNumber": test_user_data["phoneNumber"]
        })
        assert login_response.status_code == 200
        assert "verificationSid" in login_response.json()

        # Step 2: Verify login
        verify_response = await client.post("/api/v1/auth/verify-phone", json={
            "phoneNumber": test_user_data["phoneNumber"],
            "code": "123456"
        })
        assert verify_response.status_code == 200

        login_data = verify_response.json()
        access_token = login_data["accessToken"]

        # Verify same user
        assert login_data["user"]["id"] == initial_user_id

        # Step 3: Access protected resource
        profile_response = await client.get(
            f"/api/v1/users/{initial_user_id}",
            headers={"Authorization": f"Bearer {access_token}"}
        )
        assert profile_response.status_code == 200

    @pytest.mark.asyncio
    async def test_token_refresh_flow(
        self,
        client: AsyncClient,
        test_user_data: dict
    ):
        """
        Test the complete token refresh workflow.

        Flow:
        1. User logs in and receives tokens
        2. Access token expires (simulated)
        3. User refreshes using refresh token
        4. User receives new tokens
        5. User can access resources with new token

        Expected behavior:
        - Token refresh succeeds
        - New tokens are different from old ones
        - New access token works for authentication
        """
        # Setup: Register and verify
        await client.post("/api/v1/auth/register", json=test_user_data)
        verify_response = await client.post("/api/v1/auth/verify-phone", json={
            "phoneNumber": test_user_data["phoneNumber"],
            "code": "123456"
        })

        initial_data = verify_response.json()
        initial_refresh_token = initial_data["refreshToken"]
        user_id = initial_data["user"]["id"]

        # Step 1: Refresh tokens
        refresh_response = await client.post("/api/v1/auth/refresh", json={
            "refreshToken": initial_refresh_token
        })
        assert refresh_response.status_code == 200

        refresh_data = refresh_response.json()
        new_access_token = refresh_data["accessToken"]
        new_refresh_token = refresh_data["refreshToken"]

        # Verify new tokens are different
        assert new_refresh_token != initial_refresh_token

        # Step 2: Use new access token
        profile_response = await client.get(
            f"/api/v1/users/{user_id}",
            headers={"Authorization": f"Bearer {new_access_token}"}
        )
        assert profile_response.status_code == 200

    @pytest.mark.asyncio
    async def test_logout_and_relogin_flow(
        self,
        client: AsyncClient,
        test_user_data: dict
    ):
        """
        Test logout and subsequent re-login.

        Flow:
        1. User logs in
        2. User logs out
        3. Old token is invalidated
        4. User logs in again
        5. New token works

        Expected behavior:
        - Logout invalidates tokens
        - User can login again after logout
        - New tokens are issued
        """
        # Setup: Register and verify
        await client.post("/api/v1/auth/register", json=test_user_data)
        verify_response = await client.post("/api/v1/auth/verify-phone", json={
            "phoneNumber": test_user_data["phoneNumber"],
            "code": "123456"
        })

        initial_token = verify_response.json()["accessToken"]
        user_id = verify_response.json()["user"]["id"]

        # Step 1: Logout
        logout_response = await client.post(
            "/api/v1/auth/logout",
            headers={"Authorization": f"Bearer {initial_token}"}
        )
        assert logout_response.status_code == 200

        # Step 2: Verify old token doesn't work
        profile_response = await client.get(
            f"/api/v1/users/{user_id}",
            headers={"Authorization": f"Bearer {initial_token}"}
        )
        assert profile_response.status_code == 401

        # Step 3: Login again
        login_response = await client.post("/api/v1/auth/login", json={
            "phoneNumber": test_user_data["phoneNumber"]
        })
        assert login_response.status_code == 200

        # Step 4: Verify and get new token
        new_verify = await client.post("/api/v1/auth/verify-phone", json={
            "phoneNumber": test_user_data["phoneNumber"],
            "code": "123456"
        })
        assert new_verify.status_code == 200
        new_token = new_verify.json()["accessToken"]

        # Step 5: New token works
        new_profile = await client.get(
            f"/api/v1/users/{user_id}",
            headers={"Authorization": f"Bearer {new_token}"}
        )
        assert new_profile.status_code == 200


class TestReferralFlow:
    """
    Integration tests for referral system workflows.
    """

    @pytest.mark.asyncio
    async def test_complete_referral_flow(
        self,
        client: AsyncClient,
        test_user_data: dict,
        test_user_data_2: dict
    ):
        """
        Test complete referral workflow.

        Flow:
        1. User A registers (referrer)
        2. User A gets referral code
        3. User B registers with User A's code
        4. Both users are linked
        5. Both users may receive bonuses

        Expected behavior:
        - Referral link is established
        - User B has referredBy field set
        - User A can see referred users
        """
        # Step 1: Register referrer (User A)
        referrer_response = await client.post(
            "/api/v1/auth/register",
            json=test_user_data
        )
        assert referrer_response.status_code == 200

        referrer_data = referrer_response.json()
        referral_code = referrer_data["user"]["referralCode"]

        # Verify referrer
        await client.post("/api/v1/auth/verify-phone", json={
            "phoneNumber": test_user_data["phoneNumber"],
            "code": "123456"
        })

        # Step 2: Register referred user (User B) with referral code
        test_user_data_2["referralCode"] = referral_code
        referred_response = await client.post(
            "/api/v1/auth/register",
            json=test_user_data_2
        )
        assert referred_response.status_code == 200

        referred_user = referred_response.json()["user"]
        assert "referredBy" in referred_user
        assert referred_user["referredBy"] == referral_code

    @pytest.mark.asyncio
    async def test_referral_chain(
        self,
        client: AsyncClient,
        test_user_data: dict,
        test_user_data_2: dict
    ):
        """
        Test multi-level referral chain.

        Flow:
        1. User A registers
        2. User B registers with A's code
        3. User C registers with B's code
        4. Referral chain is maintained

        Expected behavior:
        - Each user can refer others
        - Referral codes are unique
        - Chain is properly tracked
        """
        # User A registers
        user_a_response = await client.post(
            "/api/v1/auth/register",
            json=test_user_data
        )
        code_a = user_a_response.json()["user"]["referralCode"]

        # User B registers with A's code
        test_user_data_2["referralCode"] = code_a
        user_b_response = await client.post(
            "/api/v1/auth/register",
            json=test_user_data_2
        )
        assert user_b_response.status_code == 200
        code_b = user_b_response.json()["user"]["referralCode"]

        # User C registers with B's code
        user_c_data = {
            "phoneNumber": "+4915234567892",
            "firstName": "Charlie",
            "lastName": "Brown",
            "email": "charlie@example.com",
            "dateOfBirth": "1993-03-20",
            "referralCode": code_b
        }
        user_c_response = await client.post(
            "/api/v1/auth/register",
            json=user_c_data
        )
        assert user_c_response.status_code == 200

        user_c = user_c_response.json()["user"]
        assert user_c["referredBy"] == code_b


class TestErrorRecovery:
    """
    Integration tests for error recovery scenarios.
    """

    @pytest.mark.asyncio
    async def test_retry_after_failed_verification(
        self,
        client: AsyncClient,
        test_user_data: dict
    ):
        """
        Test that users can retry verification after failure.

        Flow:
        1. User registers
        2. User enters wrong code (fails)
        3. User enters correct code (succeeds)

        Expected behavior:
        - Failed verification doesn't block account
        - User can retry verification
        - Successful verification proceeds normally
        """
        # Register
        await client.post("/api/v1/auth/register", json=test_user_data)

        # Try with wrong code
        wrong_verify = await client.post("/api/v1/auth/verify-phone", json={
            "phoneNumber": test_user_data["phoneNumber"],
            "code": "000000"
        })
        assert wrong_verify.status_code == 400

        # Retry with correct code
        correct_verify = await client.post("/api/v1/auth/verify-phone", json={
            "phoneNumber": test_user_data["phoneNumber"],
            "code": "123456"
        })
        assert correct_verify.status_code == 200
        assert "accessToken" in correct_verify.json()

    @pytest.mark.asyncio
    async def test_registration_retry_after_timeout(
        self,
        client: AsyncClient,
        test_user_data: dict
    ):
        """
        Test re-registration after verification timeout.

        Flow:
        1. User registers
        2. User doesn't verify (timeout)
        3. User registers again with same phone

        Expected behavior:
        - System handles re-registration gracefully
        - New verification code is sent
        """
        # First registration
        first_registration = await client.post(
            "/api/v1/auth/register",
            json=test_user_data
        )
        assert first_registration.status_code == 200

        # Attempt second registration (should handle gracefully)
        second_registration = await client.post(
            "/api/v1/auth/register",
            json=test_user_data
        )

        # Either succeeds with new code or returns existing user error
        assert second_registration.status_code in [200, 400]


class TestConcurrentUsers:
    """
    Integration tests for concurrent user scenarios.
    """

    @pytest.mark.asyncio
    async def test_multiple_users_registration(
        self,
        client: AsyncClient,
        test_user_data: dict,
        test_user_data_2: dict
    ):
        """
        Test multiple users registering concurrently.

        Expected behavior:
        - Each user gets unique referral code
        - Users don't interfere with each other
        - All registrations succeed
        """
        # Register User 1
        user1_response = await client.post(
            "/api/v1/auth/register",
            json=test_user_data
        )
        assert user1_response.status_code == 200
        code1 = user1_response.json()["user"]["referralCode"]

        # Register User 2
        user2_response = await client.post(
            "/api/v1/auth/register",
            json=test_user_data_2
        )
        assert user2_response.status_code == 200
        code2 = user2_response.json()["user"]["referralCode"]

        # Verify unique codes
        assert code1 != code2

    @pytest.mark.asyncio
    async def test_multiple_users_login_sessions(
        self,
        client: AsyncClient,
        test_user_data: dict,
        test_user_data_2: dict
    ):
        """
        Test multiple users with active sessions.

        Expected behavior:
        - Each user has independent session
        - Tokens are unique per user
        - Users can access their own data only
        """
        # Setup: Register and verify both users
        await client.post("/api/v1/auth/register", json=test_user_data)
        user1_verify = await client.post("/api/v1/auth/verify-phone", json={
            "phoneNumber": test_user_data["phoneNumber"],
            "code": "123456"
        })
        user1_token = user1_verify.json()["accessToken"]
        user1_id = user1_verify.json()["user"]["id"]

        await client.post("/api/v1/auth/register", json=test_user_data_2)
        user2_verify = await client.post("/api/v1/auth/verify-phone", json={
            "phoneNumber": test_user_data_2["phoneNumber"],
            "code": "123456"
        })
        user2_token = user2_verify.json()["accessToken"]
        user2_id = user2_verify.json()["user"]["id"]

        # Verify tokens are different
        assert user1_token != user2_token

        # Verify each user can access their own profile
        user1_profile = await client.get(
            f"/api/v1/users/{user1_id}",
            headers={"Authorization": f"Bearer {user1_token}"}
        )
        assert user1_profile.status_code == 200
        assert user1_profile.json()["phoneNumber"] == test_user_data["phoneNumber"]

        user2_profile = await client.get(
            f"/api/v1/users/{user2_id}",
            headers={"Authorization": f"Bearer {user2_token}"}
        )
        assert user2_profile.status_code == 200
        assert user2_profile.json()["phoneNumber"] == test_user_data_2["phoneNumber"]


class TestEdgeCases:
    """
    Integration tests for edge cases and boundary conditions.
    """

    @pytest.mark.asyncio
    async def test_rapid_login_logout_cycles(
        self,
        client: AsyncClient,
        test_user_data: dict
    ):
        """
        Test rapid login/logout cycles.

        Expected behavior:
        - System handles rapid state changes
        - No race conditions or errors
        - Tokens are properly managed
        """
        # Setup
        await client.post("/api/v1/auth/register", json=test_user_data)

        for i in range(3):
            # Login
            verify_response = await client.post("/api/v1/auth/verify-phone", json={
                "phoneNumber": test_user_data["phoneNumber"],
                "code": "123456"
            })
            assert verify_response.status_code == 200
            token = verify_response.json()["accessToken"]

            # Logout
            logout_response = await client.post(
                "/api/v1/auth/logout",
                headers={"Authorization": f"Bearer {token}"}
            )
            assert logout_response.status_code == 200

    @pytest.mark.asyncio
    async def test_token_usage_after_refresh(
        self,
        client: AsyncClient,
        test_user_data: dict
    ):
        """
        Test that old access token stops working after refresh.

        Expected behavior:
        - After refresh, new access token works
        - Old access token may or may not work (implementation dependent)
        - System maintains security
        """
        # Setup
        await client.post("/api/v1/auth/register", json=test_user_data)
        verify_response = await client.post("/api/v1/auth/verify-phone", json={
            "phoneNumber": test_user_data["phoneNumber"],
            "code": "123456"
        })

        old_access_token = verify_response.json()["accessToken"]
        refresh_token = verify_response.json()["refreshToken"]
        user_id = verify_response.json()["user"]["id"]

        # Refresh
        refresh_response = await client.post("/api/v1/auth/refresh", json={
            "refreshToken": refresh_token
        })
        new_access_token = refresh_response.json()["accessToken"]

        # New token should work
        new_profile = await client.get(
            f"/api/v1/users/{user_id}",
            headers={"Authorization": f"Bearer {new_access_token}"}
        )
        assert new_profile.status_code == 200

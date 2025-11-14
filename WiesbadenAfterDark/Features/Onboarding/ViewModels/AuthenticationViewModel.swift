//
//  AuthenticationViewModel.swift
//  WiesbadenAfterDark
//
//  ViewModel for managing authentication flow and state
//

import Foundation
import SwiftUI
import SwiftData

/// Main authentication view model
/// Manages the entire auth flow from phone input to account creation
@MainActor
@Observable
final class AuthenticationViewModel {
    // MARK: - Dependencies

    private let authService: AuthServiceProtocol
    private let keychainService: KeychainServiceProtocol
    private let modelContext: ModelContext?

    // MARK: - Published State

    var authState: AuthenticationState = .initializing
    var currentPhoneNumber: String = ""
    var currentReferralCode: String?
    var isLoading: Bool = false
    var error: AppError?
    var showError: Bool = false
    var currentUser: User?

    // MARK: - Initialization

    init(
        authService: AuthServiceProtocol = RealAuthService.shared,
        keychainService: KeychainServiceProtocol = KeychainService.shared,
        modelContext: ModelContext? = nil
    ) {
        self.authService = authService
        self.keychainService = keychainService
        self.modelContext = modelContext

        print("🔐 [AuthViewModel] Initialized")
    }

    // MARK: - Authentication Flow Methods

    /// Step 1: Send verification code to phone number
    func sendVerificationCode(to phoneNumber: String) async {
        print("📱 [AuthViewModel] Sending verification code to: \(phoneNumber)")

        // Normalize phone number
        guard let normalized = phoneNumber.normalizedPhoneNumber() else {
            error = .invalidPhoneNumber
            showError = true
            print("❌ [AuthViewModel] Invalid phone number format")
            return
        }

        currentPhoneNumber = normalized
        isLoading = true
        error = nil
        showError = false

        do {
            try await authService.sendVerificationCode(to: normalized)
            print("✅ [AuthViewModel] Verification code sent successfully")
        } catch {
            self.error = AppError.from(error)
            showError = true
            print("❌ [AuthViewModel] Failed to send code: \(error)")
        }

        isLoading = false
    }

    /// Step 2: Verify the SMS code
    func verifyCode(_ code: String) async -> Bool {
        print("🔐 [AuthViewModel] Verifying code: \(code)")

        isLoading = true
        error = nil
        showError = false

        do {
            // Verify the code and get token
            let token = try await authService.verifyCode(code, for: currentPhoneNumber)
            print("✅ [AuthViewModel] Code verified, token received")

            // Save token to keychain
            try keychainService.saveToken(token)
            print("✅ [AuthViewModel] Token saved to keychain")

            // STEP 4: Try to fetch existing user (multiple attempts with retry)
            print("🔍 [AuthViewModel] Checking if user already exists...")

            var existingUser: User?
            var attemptCount = 0
            let maxAttempts = 3
            var lastError: Error?

            while existingUser == nil && attemptCount < maxAttempts {
                attemptCount += 1
                print("   Attempt \(attemptCount)/\(maxAttempts)...")

                do {
                    existingUser = try await authService.fetchCurrentUser()
                    print("✅ [AuthViewModel] User found on attempt \(attemptCount)!")
                } catch {
                    print("⚠️ Attempt \(attemptCount) failed: \(error)")
                    lastError = error
                    if attemptCount < maxAttempts {
                        print("   Retrying in 1 second...")
                        try? await Task.sleep(nanoseconds: 1_000_000_000)
                    }
                }
            }

            if let user = existingUser {
                // USER EXISTS - AUTO LOGIN
                print("✅ [AuthViewModel] Existing user confirmed - auto-logging in")
                print("   User ID: \(user.id)")
                print("   Phone: \(user.phoneNumber)")
                print("   Name: \(user.firstName ?? "nil") \(user.lastName ?? "nil")")

                currentUser = user

                // Save to database
                if let context = modelContext {
                    print("💾 [AuthViewModel] Saving user to local database...")
                    context.insert(user)
                    do {
                        try context.save()
                        print("✅ [AuthViewModel] User saved to local database")
                    } catch {
                        print("⚠️ [AuthViewModel] Database save failed (might already exist): \(error)")
                    }
                }

                // CRITICAL: Set auth state BEFORE returning (ensure main thread)
                await MainActor.run {
                    authState = .authenticated(user)
                    isLoading = false
                }

                print("🏠 [AuthViewModel] AUTH STATE SET - SHOULD GO TO HOME NOW")
                return true

            } else {
                // NEW USER - Show registration
                print("🆕 [AuthViewModel] No existing user found after \(maxAttempts) attempts")
                print("   Proceeding to registration flow")

                // Log the last error for debugging
                if let error = lastError {
                    print("   Last error was: \(error)")

                    // Set user-friendly error based on error type
                    let appError = AppError.from(error)

                    // Only show error for actual network/server issues
                    // User not found is expected for new users, so don't show error
                    switch appError {
                    case .noInternet, .serverError, .networkTimeout:
                        self.error = appError
                        showError = true
                    default:
                        // Other errors are expected for new users
                        break
                    }
                }

                await MainActor.run {
                    isLoading = false
                }
                return true
            }

        } catch {
            self.error = AppError.from(error)
            showError = true
            print("❌ [AuthViewModel] Code verification failed: \(error)")
            authState = .error(self.error?.message ?? "Unknown error")
            isLoading = false
            return false
        }
    }

    /// Step 3: Validate referral code (optional)
    func validateReferralCode(_ code: String) async -> Bool {
        guard !code.isEmpty else {
            return true // Empty code is valid (optional field)
        }

        print("🎁 [AuthViewModel] Validating referral code: \(code)")

        isLoading = true
        error = nil
        showError = false

        do {
            let isValid = try await authService.validateReferralCode(code)
            isLoading = false

            if isValid {
                currentReferralCode = code
                print("✅ [AuthViewModel] Referral code is valid")
            } else {
                error = .invalidReferralCode
                showError = true
                print("❌ [AuthViewModel] Referral code is invalid")
            }

            return isValid

        } catch {
            self.error = AppError.from(error)
            showError = true
            print("❌ [AuthViewModel] Referral code validation failed: \(error)")
            isLoading = false
            return false
        }
    }

    /// Step 4: Complete account creation
    func completeAccountCreation(firstName: String? = nil, lastName: String? = nil) async -> Bool {
        print("👤 [AuthViewModel] Completing account creation")

        isLoading = true
        error = nil
        showError = false

        do {
            // Create account
            let user = try await authService.createAccount(
                phoneNumber: currentPhoneNumber,
                firstName: firstName,
                lastName: lastName,
                referralCode: currentReferralCode
            )
            print("✅ [AuthViewModel] Account created: \(user.id)")

            // Save user to SwiftData
            if let context = modelContext {
                context.insert(user)
                try context.save()
                print("✅ [AuthViewModel] User saved to SwiftData")
            }

            // Update auth state
            authState = .authenticated(user)
            isLoading = false

            return true

        } catch {
            self.error = AppError.from(error)
            showError = true
            print("❌ [AuthViewModel] Account creation failed: \(error)")
            authState = .error(self.error?.message ?? "Unknown error")
            isLoading = false
            return false
        }
    }

    /// Check for existing session (auto-login)
    func checkExistingSession() async {
        print("🔍 [AuthViewModel] Checking for existing session")

        authState = .initializing

        // Simulate splash screen minimum duration
        try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds

        // Check if token exists
        guard let token = try? keychainService.getToken() else {
            print("ℹ️ [AuthViewModel] No token found")
            authState = .unauthenticated
            return
        }

        // Check if token is expired
        if token.isExpired {
            print("⚠️ [AuthViewModel] Token expired, attempting refresh...")
            do {
                // Attempt to refresh the token
                let refreshedToken = try await authService.refreshAccessToken()
                try keychainService.saveToken(refreshedToken)
                print("✅ [AuthViewModel] Token refreshed successfully")
            } catch {
                print("❌ [AuthViewModel] Token refresh failed: \(error)")
                authState = .unauthenticated
                return
            }
        } else {
            print("✅ [AuthViewModel] Valid token found")
        }

        // Try to load user from SwiftData or fetch from API
        if let user = loadUserFromDatabase() {
            print("✅ [AuthViewModel] User loaded from database")
            authState = .authenticated(user)
        } else {
            // User not in local database, fetch from API
            print("ℹ️ [AuthViewModel] User not in database, fetching from API...")
            do {
                let user = try await authService.fetchCurrentUser()
                if let context = modelContext {
                    context.insert(user)
                    try context.save()
                }
                print("✅ [AuthViewModel] User fetched and saved")
                authState = .authenticated(user)
            } catch {
                print("❌ [AuthViewModel] Failed to fetch user: \(error)")
                authState = .unauthenticated
            }
        }
    }

    /// Sign out the current user
    func signOut() {
        print("👋 [AuthViewModel] Signing out")

        do {
            try keychainService.deleteToken()
            print("✅ [AuthViewModel] Token deleted")
        } catch {
            print("⚠️ [AuthViewModel] Failed to delete token: \(error)")
        }

        authState = .unauthenticated
        currentPhoneNumber = ""
        currentReferralCode = nil
        error = nil
        showError = false
    }

    // MARK: - Helper Methods

    /// Loads user from SwiftData database
    private func loadUserFromDatabase() -> User? {
        guard let context = modelContext else {
            return nil
        }

        let descriptor = FetchDescriptor<User>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )

        do {
            let users = try context.fetch(descriptor)
            return users.first
        } catch {
            print("❌ [AuthViewModel] Failed to fetch user: \(error)")
            return nil
        }
    }

    /// Clears error message
    func clearError() {
        error = nil
        showError = false
    }
}

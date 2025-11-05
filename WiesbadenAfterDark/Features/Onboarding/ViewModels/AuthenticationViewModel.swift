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
    var errorMessage: String?

    // MARK: - Initialization

    init(
        authService: AuthServiceProtocol = MockAuthService.shared,
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
            errorMessage = "Invalid phone number format"
            print("❌ [AuthViewModel] Invalid phone number format")
            return
        }

        currentPhoneNumber = normalized
        isLoading = true
        errorMessage = nil

        do {
            try await authService.sendVerificationCode(to: normalized)
            print("✅ [AuthViewModel] Verification code sent successfully")
        } catch {
            errorMessage = error.localizedDescription
            print("❌ [AuthViewModel] Failed to send code: \(error)")
        }

        isLoading = false
    }

    /// Step 2: Verify the SMS code
    func verifyCode(_ code: String) async -> Bool {
        print("🔐 [AuthViewModel] Verifying code: \(code)")

        isLoading = true
        errorMessage = nil
        // Keep authState unchanged during verification to maintain navigation flow

        do {
            // Verify the code and get token
            let token = try await authService.verifyCode(code, for: currentPhoneNumber)
            print("✅ [AuthViewModel] Code verified, token received")

            // Save token to keychain
            try keychainService.saveToken(token)
            print("✅ [AuthViewModel] Token saved to keychain")

            // Navigation will proceed via callback in VerificationCodeView
            // authState will transition to .authenticated when account creation completes
            print("✅ [AuthViewModel] Code verified, proceeding to next step")

            isLoading = false
            return true

        } catch {
            errorMessage = error.localizedDescription
            print("❌ [AuthViewModel] Code verification failed: \(error)")
            authState = .error(error.localizedDescription)
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
        errorMessage = nil

        do {
            let isValid = try await authService.validateReferralCode(code)
            isLoading = false

            if isValid {
                currentReferralCode = code
                print("✅ [AuthViewModel] Referral code is valid")
            } else {
                errorMessage = "Invalid referral code"
                print("❌ [AuthViewModel] Referral code is invalid")
            }

            return isValid

        } catch {
            errorMessage = error.localizedDescription
            print("❌ [AuthViewModel] Referral code validation failed: \(error)")
            isLoading = false
            return false
        }
    }

    /// Step 4: Complete account creation
    func completeAccountCreation() async -> Bool {
        print("👤 [AuthViewModel] Completing account creation")

        isLoading = true
        errorMessage = nil

        do {
            // Create account
            let user = try await authService.createAccount(
                phoneNumber: currentPhoneNumber,
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
            errorMessage = error.localizedDescription
            print("❌ [AuthViewModel] Account creation failed: \(error)")
            authState = .error(error.localizedDescription)
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

        // Check if valid token exists
        guard keychainService.hasValidToken() else {
            print("ℹ️ [AuthViewModel] No valid token found")
            authState = .unauthenticated
            return
        }

        print("✅ [AuthViewModel] Valid token found")

        // Try to load user from SwiftData
        if let user = loadUserFromDatabase() {
            print("✅ [AuthViewModel] User loaded from database")
            authState = .authenticated(user)
        } else {
            print("⚠️ [AuthViewModel] Token exists but no user in database")
            authState = .unauthenticated
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
        errorMessage = nil
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
        errorMessage = nil
    }
}

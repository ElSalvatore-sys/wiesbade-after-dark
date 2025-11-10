//
//  KeychainService.swift
//  WiesbadenAfterDark
//
//  Secure storage for authentication tokens using iOS Keychain
//

import Foundation
import Security

/// Implementation of KeychainServiceProtocol for secure token storage
final class KeychainService: KeychainServiceProtocol {
    // MARK: - Properties

    /// Service identifier for keychain queries
    private let service = "com.ea-solutions.WiesbadenAfterDark"

    /// Account identifier for storing the auth token
    private let account = "authToken"

    // MARK: - Singleton
    static let shared = KeychainService()

    private init() {}

    // MARK: - KeychainServiceProtocol Implementation

    /// Saves an authentication token securely to Keychain
    func saveToken(_ token: AuthToken) throws {
        // Encode the token to JSON data
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(token)

        // Check if item already exists
        let existingItemQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]

        // Delete existing item if present
        SecItemDelete(existingItemQuery as CFDictionary)

        // Prepare the new item
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]

        // Add the new item
        let status = SecItemAdd(query as CFDictionary, nil)

        guard status == errSecSuccess else {
            SecureLogger.shared.logKeychainOperation("save token", success: false)
            throw KeychainError.saveFailed
        }

        SecureLogger.shared.logKeychainOperation("save token", success: true)
    }

    /// Retrieves the stored authentication token from Keychain
    func getToken() throws -> AuthToken? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        // Handle no item found (not an error, just no token stored)
        guard status != errSecItemNotFound else {
            #if DEBUG
            SecureLogger.shared.info("No token found in Keychain", category: "Keychain")
            #endif
            return nil
        }

        // Handle other errors
        guard status == errSecSuccess else {
            throw KeychainError.loadFailed
        }

        // Decode the token from JSON data
        guard let data = result as? Data else {
            throw KeychainError.invalidData
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let token = try decoder.decode(AuthToken.self, from: data)

        SecureLogger.shared.logKeychainOperation("retrieve token", success: true)
        return token
    }

    /// Deletes the stored authentication token from Keychain
    func deleteToken() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]

        let status = SecItemDelete(query as CFDictionary)

        // Success or item not found are both acceptable
        guard status == errSecSuccess || status == errSecItemNotFound else {
            SecureLogger.shared.logKeychainOperation("delete token", success: false)
            throw KeychainError.deleteFailed
        }

        SecureLogger.shared.logKeychainOperation("delete token", success: true)
    }

    /// Checks if a valid (non-expired) token exists
    func hasValidToken() -> Bool {
        do {
            guard let token = try getToken() else {
                return false
            }
            return !token.isExpired
        } catch {
            SecureLogger.shared.error("Error checking for valid token", error: error, category: "Keychain")
            return false
        }
    }
}

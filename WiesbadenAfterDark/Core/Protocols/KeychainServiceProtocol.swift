//
//  KeychainServiceProtocol.swift
//  WiesbadenAfterDark
//
//  Protocol for secure token storage in Keychain
//

import Foundation

/// Defines the contract for keychain storage operations
/// Provides secure storage for JWT tokens and sensitive data
protocol KeychainServiceProtocol {
    /// Saves an authentication token securely
    /// - Parameter token: The AuthToken to save
    /// - Throws: KeychainError if save operation fails
    func saveToken(_ token: AuthToken) throws

    /// Retrieves the stored authentication token
    /// - Returns: AuthToken if found, nil otherwise
    /// - Throws: KeychainError if retrieval fails
    func getToken() throws -> AuthToken?

    /// Deletes the stored authentication token
    /// - Throws: KeychainError if deletion fails
    func deleteToken() throws

    /// Checks if a valid token exists
    /// - Returns: True if a token exists and is not expired
    func hasValidToken() -> Bool
}

/// Custom errors for keychain operations
enum KeychainError: LocalizedError {
    case saveFailed
    case loadFailed
    case deleteFailed
    case itemNotFound
    case invalidData
    case unexpectedError(OSStatus)

    var errorDescription: String? {
        switch self {
        case .saveFailed:
            return "Failed to save data to Keychain"
        case .loadFailed:
            return "Failed to load data from Keychain"
        case .deleteFailed:
            return "Failed to delete data from Keychain"
        case .itemNotFound:
            return "Item not found in Keychain"
        case .invalidData:
            return "Invalid data format"
        case .unexpectedError(let status):
            return "Keychain error: \(status)"
        }
    }
}

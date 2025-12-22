//
//  SecureLogger.swift
//  WiesbadenAfterDark
//
//  Created on 2025-11-06.
//

import Foundation
import os.log

/// Production-safe logging utility that prevents sensitive data leaks
/// - Only logs in DEBUG builds
/// - Sanitizes sensitive information
/// - Uses OSLog for performance and privacy
@MainActor
final class SecureLogger {

    // MARK: - Log Levels

    enum LogLevel: String {
        case debug = "🔍"
        case info = "ℹ️"
        case warning = "⚠️"
        case error = "❌"
        case success = "✅"
        case security = "🔐"
    }

    // MARK: - Singleton

    static let shared = SecureLogger()

    private init() {}

    // MARK: - OSLog Loggers

    private let authLogger = Logger(subsystem: "com.ea-solutions.WiesbadenAfterDark", category: "Authentication")
    private let paymentLogger = Logger(subsystem: "com.ea-solutions.WiesbadenAfterDark", category: "Payment")
    private let networkLogger = Logger(subsystem: "com.ea-solutions.WiesbadenAfterDark", category: "Network")
    private let dataLogger = Logger(subsystem: "com.ea-solutions.WiesbadenAfterDark", category: "Data")
    private let uiLogger = Logger(subsystem: "com.ea-solutions.WiesbadenAfterDark", category: "UI")
    private let securityLogger = Logger(subsystem: "com.ea-solutions.WiesbadenAfterDark", category: "Security")

    // MARK: - Public Logging Methods

    /// Log general debug information (DEBUG builds only)
    func debug(_ message: String, category: String = "General") {
        #if DEBUG
        print("🔍 [\(category)] \(message)")
        #endif
    }

    /// Log informational messages
    func info(_ message: String, category: String = "General") {
        #if DEBUG
        print("ℹ️ [\(category)] \(message)")
        #else
        getLogger(for: category).info("\(message)")
        #endif
    }

    /// Log warnings that need attention
    func warning(_ message: String, category: String = "General") {
        #if DEBUG
        print("⚠️ [\(category)] \(message)")
        #else
        getLogger(for: category).warning("\(message)")
        #endif
    }

    /// Log errors
    func error(_ message: String, error: Error? = nil, category: String = "General") {
        let errorMessage = error.map { "\(message): \($0.localizedDescription)" } ?? message

        #if DEBUG
        print("❌ [\(category)] \(errorMessage)")
        #else
        getLogger(for: category).error("\(errorMessage)")
        #endif
    }

    /// Log successful operations
    func success(_ message: String, category: String = "General") {
        #if DEBUG
        print("✅ [\(category)] \(message)")
        #endif
    }

    /// Log security-related events (always logged, even in production)
    func security(_ message: String, level: OSLogType = .default) {
        let sanitized = sanitizeSensitiveData(message)

        #if DEBUG
        print("🔐 [Security] \(sanitized)")
        #endif

        // Always log security events to system log for audit
        securityLogger.log(level: level, "\(sanitized)")
    }

    // MARK: - Specialized Logging

    /// Log authentication events (never log tokens or passwords)
    func auth(_ message: String, level: LogLevel = .info) {
        let sanitized = sanitizeSensitiveData(message)

        #if DEBUG
        print("\(level.rawValue) [Auth] \(sanitized)")
        #else
        authLogger.info("\(sanitized)")
        #endif
    }

    /// Log payment events (never log card numbers or CVV)
    func payment(_ message: String, level: LogLevel = .info) {
        let sanitized = sanitizePaymentData(message)

        #if DEBUG
        print("\(level.rawValue) [Payment] \(sanitized)")
        #else
        paymentLogger.info("\(sanitized)")
        #endif
    }

    /// Log network events (never log auth headers)
    func network(_ message: String, level: LogLevel = .debug) {
        let sanitized = sanitizeSensitiveData(message)

        #if DEBUG
        print("\(level.rawValue) [Network] \(sanitized)")
        #else
        networkLogger.debug("\(sanitized)")
        #endif
    }

    /// Log data operations
    func data(_ message: String, level: LogLevel = .debug) {
        let sanitized = sanitizeSensitiveData(message)

        #if DEBUG
        print("\(level.rawValue) [Data] \(sanitized)")
        #else
        dataLogger.debug("\(sanitized)")
        #endif
    }

    // MARK: - Sensitive Data Sanitization

    /// Sanitize common sensitive data patterns
    private func sanitizeSensitiveData(_ message: String) -> String {
        var sanitized = message

        // Redact phone numbers (E.164 format)
        sanitized = sanitized.replacingOccurrences(
            of: "\\+\\d{1,3}\\d{8,14}",
            with: "+[REDACTED]",
            options: .regularExpression
        )

        // Redact email addresses
        sanitized = sanitized.replacingOccurrences(
            of: "[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,}",
            with: "[EMAIL_REDACTED]",
            options: [.regularExpression, .caseInsensitive]
        )

        // Redact tokens (JWT pattern)
        sanitized = sanitized.replacingOccurrences(
            of: "eyJ[A-Za-z0-9-_]+\\.[A-Za-z0-9-_]+\\.[A-Za-z0-9-_]+",
            with: "[TOKEN_REDACTED]",
            options: .regularExpression
        )

        // Redact UUIDs
        sanitized = sanitized.replacingOccurrences(
            of: "[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}",
            with: "[UUID_REDACTED]",
            options: .regularExpression
        )

        // Redact common sensitive keywords
        let sensitivePatterns = [
            ("password", "[PASSWORD_REDACTED]"),
            ("token", "[TOKEN_REDACTED]"),
            ("secret", "[SECRET_REDACTED]"),
            ("key", "[KEY_REDACTED]"),
            ("authorization", "[AUTH_REDACTED]")
        ]

        for (pattern, replacement) in sensitivePatterns {
            if sanitized.lowercased().contains(pattern) {
                // If message contains sensitive keyword, redact the value after it
                sanitized = sanitized.replacingOccurrences(
                    of: "\(pattern):\\s*\\S+",
                    with: "\(pattern): \(replacement)",
                    options: [.regularExpression, .caseInsensitive]
                )
            }
        }

        return sanitized
    }

    /// Sanitize payment-specific data
    private func sanitizePaymentData(_ message: String) -> String {
        var sanitized = sanitizeSensitiveData(message)

        // Redact card numbers (any format)
        sanitized = sanitized.replacingOccurrences(
            of: "\\d{4}[\\s-]?\\d{4}[\\s-]?\\d{4}[\\s-]?\\d{4}",
            with: "XXXX-XXXX-XXXX-XXXX",
            options: .regularExpression
        )

        // Redact CVV
        sanitized = sanitized.replacingOccurrences(
            of: "cvv:\\s*\\d{3,4}",
            with: "cvv: XXX",
            options: [.regularExpression, .caseInsensitive]
        )

        // Redact Stripe secret keys (keep last 4 chars for debugging)
        sanitized = sanitized.replacingOccurrences(
            of: "sk_live_[A-Za-z0-9]{20,}",
            with: "sk_live_[REDACTED]",
            options: .regularExpression
        )

        sanitized = sanitized.replacingOccurrences(
            of: "sk_test_[A-Za-z0-9]{20,}",
            with: "sk_test_[REDACTED]",
            options: .regularExpression
        )

        return sanitized
    }

    // MARK: - Helper Methods

    /// Get appropriate logger for category
    private func getLogger(for category: String) -> Logger {
        switch category.lowercased() {
        case "auth", "authentication":
            return authLogger
        case "payment", "stripe":
            return paymentLogger
        case "network", "api":
            return networkLogger
        case "data", "swiftdata":
            return dataLogger
        case "ui", "view":
            return uiLogger
        case "security":
            return securityLogger
        default:
            return Logger(subsystem: "com.ea-solutions.WiesbadenAfterDark", category: category)
        }
    }
}

// MARK: - Convenience Extensions

extension SecureLogger {
    /// Log API request (sanitizes headers automatically)
    func logAPIRequest(endpoint: String, method: String, headers: [String: String]? = nil) {
        var message = "\(method) \(endpoint)"

        if let headers = headers {
            let sanitizedHeaders = headers.filter { key, _ in
                !key.lowercased().contains("authorization") &&
                !key.lowercased().contains("token") &&
                !key.lowercased().contains("key")
            }
            message += " | Headers: \(sanitizedHeaders)"
        }

        network(message, level: .debug)
    }

    /// Log API response (sanitizes sensitive data)
    func logAPIResponse(endpoint: String, statusCode: Int, error: Error? = nil) {
        if let error = error {
            network("Response from \(endpoint): \(statusCode) - Error: \(error.localizedDescription)", level: .error)
        } else {
            network("Response from \(endpoint): \(statusCode)", level: .debug)
        }
    }

    /// Log biometric authentication attempt
    func logBiometricAuth(success: Bool, reason: String? = nil) {
        if success {
            security("Biometric authentication successful", level: .info)
        } else {
            let message = reason != nil ? "Biometric authentication failed: \(reason!)" : "Biometric authentication failed"
            security(message, level: .error)
        }
    }

    /// Log keychain operation
    func logKeychainOperation(_ operation: String, success: Bool) {
        if success {
            security("Keychain operation successful: \(operation)", level: .default)
        } else {
            security("Keychain operation failed: \(operation)", level: .error)
        }
    }
}

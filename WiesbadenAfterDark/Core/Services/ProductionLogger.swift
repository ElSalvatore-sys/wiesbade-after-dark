//
//  ProductionLogger.swift
//  WiesbadenAfterDark
//
//  Production-safe logging that never exposes sensitive data
//

import Foundation
import OSLog

/// Production-safe logger for important events and errors
final class ProductionLogger {
    static let shared = ProductionLogger()

    private let logger = Logger(subsystem: "com.ea-solutions.WiesbadenAfterDark", category: "Production")

    private init() {}

    enum LogLevel {
        case info
        case warning
        case error
        case critical
    }

    // MARK: - Authentication Events

    /// Log authentication attempt (never logs phone numbers or tokens)
    func logAuthAttempt(success: Bool) {
        if success {
            logger.info("✅ Authentication successful")
        } else {
            logger.warning("❌ Authentication failed")
        }
    }

    /// Log token refresh event
    func logTokenRefresh(success: Bool) {
        if success {
            logger.info("🔄 Token refreshed successfully")
        } else {
            logger.error("❌ Token refresh failed")
        }
    }

    /// Log logout event
    func logLogout() {
        logger.info("👋 User logged out")
    }

    // MARK: - API Events

    /// Log API request (never logs sensitive headers or parameters)
    func logAPIRequest(method: String, endpoint: String) {
        // Only log in DEBUG builds to reduce production logs
        #if DEBUG
        logger.debug("🌐 \(method) \(endpoint)")
        #endif
    }

    /// Log API response
    func logAPIResponse(endpoint: String, statusCode: Int, success: Bool) {
        if success {
            #if DEBUG
            logger.debug("✅ \(endpoint) - \(statusCode)")
            #endif
        } else {
            logger.warning("❌ \(endpoint) failed - HTTP \(statusCode)")
        }
    }

    /// Log API error (sanitizes error messages)
    func logAPIError(_ error: Error, endpoint: String) {
        let sanitizedMessage = sanitizeError(error)
        logger.error("❌ API Error on \(endpoint): \(sanitizedMessage)")
    }

    // MARK: - Network Events

    /// Log network connectivity issues
    func logNetworkError(_ error: URLError) {
        switch error.code {
        case .notConnectedToInternet:
            logger.warning("📡 No internet connection")
        case .networkConnectionLost:
            logger.warning("📡 Connection lost")
        case .timedOut:
            logger.warning("⏱️ Request timed out")
        default:
            logger.warning("📡 Network error: \(error.code.rawValue)")
        }
    }

    // MARK: - App Lifecycle

    /// Log app launch
    func logAppLaunch() {
        logger.info("🚀 App launched")
    }

    /// Log app background/foreground
    func logAppState(background: Bool) {
        if background {
            logger.info("📱 App entered background")
        } else {
            logger.info("📱 App entered foreground")
        }
    }

    // MARK: - Payment Events (never log card numbers or amounts)

    /// Log payment attempt
    func logPaymentAttempt(success: Bool, method: String) {
        if success {
            logger.info("💳 Payment successful via \(method)")
        } else {
            logger.warning("💳 Payment failed via \(method)")
        }
    }

    // MARK: - Check-in Events

    /// Log venue check-in
    func logCheckIn(venueId: String, success: Bool) {
        if success {
            logger.info("📍 Check-in successful at venue: \(venueId)")
        } else {
            logger.warning("📍 Check-in failed at venue: \(venueId)")
        }
    }

    // MARK: - Generic Logging

    /// Log general message with level
    func log(_ message: String, level: LogLevel = .info, category: String = "App") {
        switch level {
        case .info:
            logger.info("\(category): \(message)")
        case .warning:
            logger.warning("\(category): \(message)")
        case .error:
            logger.error("\(category): \(message)")
        case .critical:
            logger.critical("\(category): \(message)")
        }
    }

    /// Log error with context (sanitizes sensitive data)
    func logError(_ error: Error, context: String) {
        let sanitizedMessage = sanitizeError(error)
        logger.error("[\(context)] Error: \(sanitizedMessage)")
    }

    // MARK: - Helper Methods

    /// Sanitizes error messages to remove sensitive data
    private func sanitizeError(_ error: Error) -> String {
        var message = error.localizedDescription

        // Remove potential tokens
        message = message.replacingOccurrences(of: #"Bearer\s+[A-Za-z0-9\-_]+\.[A-Za-z0-9\-_]+\.[A-Za-z0-9\-_]+"#,
                                                with: "Bearer [REDACTED]",
                                                options: .regularExpression)

        // Remove phone numbers (E.164 format)
        message = message.replacingOccurrences(of: #"\+\d{10,15}"#,
                                                with: "+[REDACTED]",
                                                options: .regularExpression)

        // Remove email addresses
        message = message.replacingOccurrences(of: #"[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}"#,
                                                with: "[EMAIL_REDACTED]",
                                                options: .regularExpression)

        return message
    }
}

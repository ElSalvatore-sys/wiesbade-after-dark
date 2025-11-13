//
//  APIClient.swift
//  WiesbadenAfterDark
//
//  Network client for communicating with the production backend
//

import Foundation

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int, message: String?)
    case decodingError(Error)
    case networkError(Error)
    case unauthorized
    case serverError

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid server response"
        case .httpError(let statusCode, let message):
            return message ?? "HTTP error: \(statusCode)"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .unauthorized:
            return "Unauthorized. Please log in again."
        case .serverError:
            return "Server error. Please try again later."
        }
    }
}

final class APIClient {
    // MARK: - Properties

    static let shared = APIClient()
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    // MARK: - Initialization

    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: configuration)

        self.decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601

        self.encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .iso8601
    }

    // MARK: - HTTP Methods

    /// Performs a GET request
    func get<T: Decodable>(
        _ endpoint: String,
        parameters: [String: String]? = nil,
        requiresAuth: Bool = false
    ) async throws -> T {
        let url = try buildURL(endpoint: endpoint, parameters: parameters)
        let request = try await buildRequest(url: url, method: "GET", requiresAuth: requiresAuth)

        return try await performRequest(request)
    }

    /// Performs a POST request
    func post<T: Decodable, B: Encodable>(
        _ endpoint: String,
        body: B,
        requiresAuth: Bool = false
    ) async throws -> T {
        let url = try buildURL(endpoint: endpoint)
        var request = try await buildRequest(url: url, method: "POST", requiresAuth: requiresAuth)
        request.httpBody = try encoder.encode(body)

        return try await performRequest(request)
    }

    /// Performs a POST request without response body
    func post<B: Encodable>(
        _ endpoint: String,
        body: B,
        requiresAuth: Bool = false
    ) async throws {
        let url = try buildURL(endpoint: endpoint)
        var request = try await buildRequest(url: url, method: "POST", requiresAuth: requiresAuth)
        request.httpBody = try encoder.encode(body)

        let _: EmptyResponse = try await performRequest(request)
    }

    /// Performs a PUT request
    func put<T: Decodable, B: Encodable>(
        _ endpoint: String,
        body: B,
        requiresAuth: Bool = true
    ) async throws -> T {
        let url = try buildURL(endpoint: endpoint)
        var request = try await buildRequest(url: url, method: "PUT", requiresAuth: requiresAuth)
        request.httpBody = try encoder.encode(body)

        return try await performRequest(request)
    }

    /// Performs a DELETE request
    func delete(
        _ endpoint: String,
        requiresAuth: Bool = true
    ) async throws {
        let url = try buildURL(endpoint: endpoint)
        let request = try await buildRequest(url: url, method: "DELETE", requiresAuth: requiresAuth)

        let _: EmptyResponse = try await performRequest(request)
    }

    // MARK: - Helper Methods

    private func buildURL(endpoint: String, parameters: [String: String]? = nil) throws -> URL {
        guard var components = URLComponents(string: APIConfig.baseURL + endpoint) else {
            throw APIError.invalidURL
        }

        if let parameters = parameters {
            components.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        }

        guard let url = components.url else {
            throw APIError.invalidURL
        }

        return url
    }

    private func buildRequest(
        url: URL,
        method: String,
        requiresAuth: Bool
    ) async throws -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method

        // Get auth token if required
        let tokenString: String? = if requiresAuth {
            if let authToken = try? KeychainService.shared.getToken(),
               !authToken.isExpired {
                authToken.accessToken  // Extract access token string
            } else {
                nil  // Token expired or not found
            }
        } else {
            nil
        }

        // Set headers
        let headers = APIConfig.headers(with: tokenString)
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }

        return request
    }

    private func performRequest<T: Decodable>(_ request: URLRequest) async throws -> T {
        do {
            return try await executeRequest(request)
        } catch APIError.unauthorized {
            // Token expired - attempt refresh and retry once
            #if DEBUG
            print("🔄 [APIClient] Token expired, attempting refresh...")
            #endif

            // Try to refresh the token
            do {
                let keychainService = KeychainService.shared
                guard let currentToken = try? keychainService.getToken() else {
                    throw APIError.unauthorized
                }

                // Call refresh endpoint
                let refreshedToken = try await refreshToken(currentToken.refreshToken)
                try keychainService.saveToken(refreshedToken)

                #if DEBUG
                print("✅ [APIClient] Token refreshed successfully, retrying request...")
                #endif

                // Rebuild request with new token
                var retryRequest = request
                retryRequest.setValue("Bearer \(refreshedToken.accessToken)", forHTTPHeaderField: "Authorization")

                // Retry the original request with new token
                return try await executeRequest(retryRequest)
            } catch {
                // Refresh failed - user must re-authenticate
                print("❌ [APIClient] Token refresh failed: \(error)")
                throw APIError.unauthorized
            }
        }
    }

    private func executeRequest<T: Decodable>(_ request: URLRequest) async throws -> T {
        // Log request (production-safe)
        let endpoint = request.url?.path ?? "unknown"
        ProductionLogger.shared.logAPIRequest(
            method: request.httpMethod ?? "?",
            endpoint: endpoint
        )

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            print("❌ [APIClient] Invalid response type")
            ProductionLogger.shared.log("Invalid response from server", level: .error, category: "API")
            throw APIError.invalidResponse
        }

        // DETAILED LOGGING FOR DEBUGGING
        print("📡 [APIClient] Response received")
        print("   Status code: \(httpResponse.statusCode)")
        print("   Endpoint: \(endpoint)")
        print("   Method: \(request.httpMethod ?? "?")")

        if httpResponse.statusCode == 401 {
            print("⚠️ [APIClient] 401 Unauthorized - Token might be invalid")
        } else if httpResponse.statusCode == 404 {
            print("⚠️ [APIClient] 404 Not Found - Resource doesn't exist")
        } else if !(200...299).contains(httpResponse.statusCode) {
            print("⚠️ [APIClient] HTTP error: \(httpResponse.statusCode)")
        }

        // Log response
        ProductionLogger.shared.logAPIResponse(
            endpoint: endpoint,
            statusCode: httpResponse.statusCode,
            success: (200...299).contains(httpResponse.statusCode)
        )

        // Handle different status codes
        switch httpResponse.statusCode {
        case 200...299:
            // Success - decode response
            do {
                let decoded = try decoder.decode(T.self, from: data)
                return decoded
            } catch {
                #if DEBUG
                print("❌ [APIClient] Decoding error: \(error)")
                if let json = try? JSONSerialization.jsonObject(with: data),
                   let prettyData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
                   let prettyString = String(data: prettyData, encoding: .utf8) {
                    print("📄 [APIClient] Response JSON:\n\(prettyString)")
                }
                #endif
                throw APIError.decodingError(error)
            }

        case 401:
            // Unauthorized - token expired or invalid
            throw APIError.unauthorized

        case 400...499:
            // Client error - try to decode error message
            let errorMessage = try? decoder.decode(ErrorResponse.self, from: data)
            throw APIError.httpError(statusCode: httpResponse.statusCode, message: errorMessage?.message)

        case 500...599:
            // Server error
            throw APIError.serverError

        default:
            throw APIError.httpError(statusCode: httpResponse.statusCode, message: nil)
        }
    }

    /// Refreshes the access token using the refresh token
    private func refreshToken(_ refreshToken: String) async throws -> AuthToken {
        struct RefreshRequest: Encodable {
            let refreshToken: String
        }

        struct RefreshResponse: Decodable {
            let accessToken: String
            let refreshToken: String
            let tokenType: String
            let expiresIn: Int
        }

        let url = try buildURL(endpoint: APIConfig.Endpoints.refreshToken)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = try encoder.encode(RefreshRequest(refreshToken: refreshToken))

        let response: RefreshResponse = try await executeRequest(request)

        let expiresAt = Date().addingTimeInterval(TimeInterval(response.expiresIn))
        return AuthToken(
            accessToken: response.accessToken,
            refreshToken: response.refreshToken,
            expiresAt: expiresAt,
            tokenType: response.tokenType
        )
    }
}

// MARK: - Response Types

private struct EmptyResponse: Decodable {}

private struct ErrorResponse: Decodable {
    let message: String
    let detail: String?
}

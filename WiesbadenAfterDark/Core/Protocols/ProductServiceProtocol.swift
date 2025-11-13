//
//  ProductServiceProtocol.swift
//  WiesbadenAfterDark
//
//  Core protocol for product operations
//  Enables dependency injection and easy testing
//

import Foundation

/// Defines the contract for product services
/// This protocol allows us to swap between mock and real implementations
protocol ProductServiceProtocol {
    /// Fetches all products for a specific venue
    /// - Parameter venueId: Venue UUID
    /// - Returns: Array of products
    /// - Throws: ProductError if the request fails
    func fetchProducts(venueId: UUID) async throws -> [Product]

    /// Fetches active products (in stock and available) for a venue
    /// - Parameter venueId: Venue UUID
    /// - Returns: Array of available products
    /// - Throws: ProductError if the request fails
    func getActiveProducts(venueId: UUID) async throws -> [Product]

    /// Fetches products with active bonus points for a venue
    /// - Parameter venueId: Venue UUID
    /// - Returns: Array of products with active bonuses
    /// - Throws: ProductError if the request fails
    func getProductsWithBonus(venueId: UUID) async throws -> [Product]

    /// Fetches products by category for a venue
    /// - Parameters:
    ///   - venueId: Venue UUID
    ///   - category: Product category to filter by
    /// - Returns: Array of products in the specified category
    /// - Throws: ProductError if the request fails
    func getProductsByCategory(venueId: UUID, category: ProductCategory) async throws -> [Product]

    /// Clears the product cache for a specific venue
    /// - Parameter venueId: Venue UUID to clear cache for
    func clearCache(for venueId: UUID)

    /// Clears all product caches
    func clearAllCaches()
}

/// Custom errors for product operations
enum ProductError: LocalizedError {
    case productNotFound
    case venueNotFound
    case outOfStock
    case productUnavailable
    case networkError(Error)
    case serverError(String)
    case invalidResponse
    case cacheMiss
    case unknownError

    var errorDescription: String? {
        switch self {
        case .productNotFound:
            return "Product not found"
        case .venueNotFound:
            return "Venue not found"
        case .outOfStock:
            return "This product is currently out of stock"
        case .productUnavailable:
            return "This product is currently unavailable"
        case .networkError:
            return "Connection error. Please check your internet."
        case .serverError(let message):
            return message
        case .invalidResponse:
            return "Invalid response from server"
        case .cacheMiss:
            return "Cache miss - data needs to be refreshed"
        case .unknownError:
            return "An unexpected error occurred. Please try again."
        }
    }
}

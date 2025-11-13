//
//  ProductService.swift
//  WiesbadenAfterDark
//
//  Real implementation of ProductServiceProtocol
//  Connects to backend API with caching strategy
//

import Foundation

/// Real product service that communicates with the production backend
final class ProductService: ProductServiceProtocol {
    // MARK: - Properties

    private let apiClient: APIClient
    private let cacheTimeout: TimeInterval = 300 // 5 minutes (same as venue service)

    // Cache structure: [venueId: (products, timestamp)]
    private var cache: [UUID: (products: [Product], timestamp: Date)] = [:]
    private let cacheQueue = DispatchQueue(label: "com.wiesbaden.productservice.cache")

    // MARK: - Singleton

    static let shared = ProductService()

    // MARK: - Initialization

    private init(apiClient: APIClient = .shared) {
        self.apiClient = apiClient
    }

    // MARK: - ProductServiceProtocol Implementation

    /// Fetches all products for a specific venue
    func fetchProducts(venueId: UUID) async throws -> [Product] {
        print("📦 [ProductService] Fetching products for venue: \(venueId)")

        // Check cache first
        if let cached = getCachedProducts(for: venueId) {
            print("✅ [ProductService] Returned \(cached.count) products from cache")
            return cached
        }

        // Fetch from API
        do {
            let endpoint = APIConfig.Endpoints.venueProducts(id: venueId.uuidString)
            let response: ProductsResponse = try await apiClient.get(
                endpoint,
                requiresAuth: false
            )

            let products = response.products.map { dto in
                convertDTOToProduct(dto)
            }

            // Update cache
            updateCache(venueId: venueId, products: products)

            print("✅ [ProductService] Fetched \(products.count) products from API")
            return products

        } catch let error as APIError {
            print("❌ [ProductService] API error: \(error.errorDescription ?? "Unknown")")
            throw mapAPIError(error)
        } catch {
            print("❌ [ProductService] Unknown error: \(error)")
            throw ProductError.unknownError
        }
    }

    /// Fetches active products (in stock and available) for a venue
    func getActiveProducts(venueId: UUID) async throws -> [Product] {
        print("🟢 [ProductService] Fetching active products for venue: \(venueId)")

        let allProducts = try await fetchProducts(venueId: venueId)
        let activeProducts = allProducts.filter { $0.canPurchase }

        print("✅ [ProductService] Found \(activeProducts.count) active products")
        return activeProducts
    }

    /// Fetches products with active bonus points for a venue
    func getProductsWithBonus(venueId: UUID) async throws -> [Product] {
        print("⭐ [ProductService] Fetching products with bonus for venue: \(venueId)")

        let allProducts = try await fetchProducts(venueId: venueId)
        let bonusProducts = allProducts.filter { $0.isBonusActive }

        print("✅ [ProductService] Found \(bonusProducts.count) products with active bonuses")
        return bonusProducts
    }

    /// Fetches products by category for a venue
    func getProductsByCategory(venueId: UUID, category: ProductCategory) async throws -> [Product] {
        print("🏷️ [ProductService] Fetching \(category.displayName) products for venue: \(venueId)")

        let allProducts = try await fetchProducts(venueId: venueId)
        let categoryProducts = allProducts.filter { $0.category == category }

        print("✅ [ProductService] Found \(categoryProducts.count) products in category")
        return categoryProducts
    }

    /// Clears the product cache for a specific venue
    func clearCache(for venueId: UUID) {
        cacheQueue.sync {
            cache.removeValue(forKey: venueId)
            print("🗑️ [ProductService] Cleared cache for venue: \(venueId)")
        }
    }

    /// Clears all product caches
    func clearAllCaches() {
        cacheQueue.sync {
            cache.removeAll()
            print("🗑️ [ProductService] Cleared all product caches")
        }
    }

    // MARK: - Cache Management

    private func getCachedProducts(for venueId: UUID) -> [Product]? {
        cacheQueue.sync {
            guard let cached = cache[venueId] else {
                print("💾 [ProductService] Cache miss for venue: \(venueId)")
                return nil
            }

            let age = Date().timeIntervalSince(cached.timestamp)
            if age > cacheTimeout {
                print("💾 [ProductService] Cache expired (age: \(Int(age))s)")
                cache.removeValue(forKey: venueId)
                return nil
            }

            print("💾 [ProductService] Cache hit (age: \(Int(age))s)")
            return cached.products
        }
    }

    private func updateCache(venueId: UUID, products: [Product]) {
        cacheQueue.sync {
            cache[venueId] = (products: products, timestamp: Date())
            print("💾 [ProductService] Updated cache for venue: \(venueId)")
        }
    }

    // MARK: - Helper Methods

    /// Converts DTO to Product model
    private func convertDTOToProduct(_ dto: ProductDTO) -> Product {
        return Product(
            id: dto.id,
            venueId: dto.venueId,
            name: dto.name,
            category: dto.category,
            price: dto.price,
            cost: dto.cost,
            stockQuantity: dto.stockQuantity,
            isAvailable: dto.isAvailable,
            bonusPointsActive: dto.bonusPointsActive,
            bonusMultiplier: dto.bonusMultiplier,
            bonusDescription: dto.bonusDescription,
            bonusStartDate: dto.bonusStartDate,
            bonusEndDate: dto.bonusEndDate,
            createdAt: dto.createdAt ?? Date(),
            updatedAt: dto.updatedAt ?? Date()
        )
    }

    /// Maps API errors to ProductError
    private func mapAPIError(_ error: APIError) -> ProductError {
        switch error {
        case .networkError(let underlying):
            return .networkError(underlying)
        case .httpError(let statusCode, let message):
            if statusCode == 404 {
                return .venueNotFound
            } else {
                return .serverError(message ?? "HTTP error: \(statusCode)")
            }
        case .invalidResponse, .decodingError:
            return .invalidResponse
        case .unauthorized, .serverError:
            return .serverError(error.errorDescription ?? "Server error")
        default:
            return .unknownError
        }
    }
}

// MARK: - DTOs (Data Transfer Objects)

/// Response wrapper for products endpoint
private struct ProductsResponse: Decodable {
    let products: [ProductDTO]
}

/// Product DTO matching backend API response
private struct ProductDTO: Decodable {
    let id: UUID
    let venueId: UUID
    let name: String
    let category: ProductCategory
    let price: Decimal
    let cost: Decimal?
    let stockQuantity: Int
    let isAvailable: Bool
    let bonusPointsActive: Bool
    let bonusMultiplier: Decimal
    let bonusDescription: String?
    let bonusStartDate: Date?
    let bonusEndDate: Date?
    let createdAt: Date?
    let updatedAt: Date?
}

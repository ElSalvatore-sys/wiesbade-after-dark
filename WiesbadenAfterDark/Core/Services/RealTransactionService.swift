//
//  RealTransactionService.swift
//  WiesbadenAfterDark
//
//  Production transaction service with backend integration
//

import Foundation
import SwiftData

/// Production implementation of TransactionServiceProtocol with backend sync
final class RealTransactionService: TransactionServiceProtocol {
    // MARK: - Properties

    private let apiClient: APIClient
    private let modelContext: ModelContext

    // MARK: - Initialization

    init(modelContext: ModelContext, apiClient: APIClient = .shared) {
        self.modelContext = modelContext
        self.apiClient = apiClient
    }

    // MARK: - Backend Integration

    /// Fetches transactions from the backend with pagination
    func fetchTransactions(userId: UUID, page: Int = 1, limit: Int = 20) async throws -> [PointTransaction] {
        let endpoint = "/api/v1/transactions/user/\(userId.uuidString)"
        let parameters = [
            "page": String(page),
            "limit": String(limit)
        ]

        let response: TransactionListResponse = try await apiClient.get(
            endpoint,
            parameters: parameters,
            requiresAuth: true
        )

        #if DEBUG
        print("📊 [TransactionService] Fetched \(response.transactions.count) transactions (page \(page))")
        print("   Total: \(response.pagination.total)")
        #endif

        return response.transactions.map { dto in
            convertDTOToModel(dto)
        }
    }

    /// Creates a new transaction on the backend
    func createTransaction(_ transaction: PointTransaction) async throws -> PointTransaction {
        let endpoint = "/api/v1/transactions"
        let dto = convertModelToDTO(transaction)

        let response: TransactionDTO = try await apiClient.post(
            endpoint,
            body: dto,
            requiresAuth: true
        )

        #if DEBUG
        print("✅ [TransactionService] Created transaction: \(response.id)")
        #endif

        return convertDTOToModel(response)
    }

    // MARK: - Sync Management

    /// Syncs transactions from backend to local SwiftData storage
    func syncTransactions(userId: UUID) async throws {
        #if DEBUG
        print("🔄 [TransactionService] Starting transaction sync for user \(userId)")
        #endif

        var allTransactions: [PointTransaction] = []
        var currentPage = 1
        var hasMorePages = true

        // Fetch all pages
        while hasMorePages {
            let endpoint = "/api/v1/transactions/user/\(userId.uuidString)"
            let parameters = [
                "page": String(currentPage),
                "limit": "20"
            ]

            let response: TransactionListResponse = try await apiClient.get(
                endpoint,
                parameters: parameters,
                requiresAuth: true
            )

            let transactions = response.transactions.map { dto in
                convertDTOToModel(dto)
            }

            allTransactions.append(contentsOf: transactions)

            // Check if there are more pages
            let totalPages = (response.pagination.total + 19) / 20 // Round up
            hasMorePages = currentPage < totalPages

            #if DEBUG
            print("   Page \(currentPage)/\(totalPages): \(transactions.count) transactions")
            #endif

            currentPage += 1
        }

        // Update local storage
        try await updateLocalStorage(transactions: allTransactions, userId: userId)

        #if DEBUG
        print("✅ [TransactionService] Sync completed: \(allTransactions.count) transactions")
        #endif
    }

    // MARK: - Local Storage Management

    /// Gets transaction history from local SwiftData storage
    func getTransactionHistory(userId: UUID, venueId: UUID? = nil) -> [PointTransaction] {
        // Extract venueId to local variable for predicate type inference
        let descriptor: FetchDescriptor<PointTransaction>
        if let unwrappedVenueId = venueId {
            descriptor = FetchDescriptor<PointTransaction>(
                predicate: #Predicate { $0.userId == userId && $0.venueId == unwrappedVenueId },
                sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
            )
        } else {
            descriptor = FetchDescriptor<PointTransaction>(
                predicate: #Predicate { $0.userId == userId },
                sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
            )
        }

        do {
            let transactions = try modelContext.fetch(descriptor)
            #if DEBUG
            print("📖 [TransactionService] Fetched \(transactions.count) transactions from local storage")
            #endif
            return transactions
        } catch {
            #if DEBUG
            print("❌ [TransactionService] Failed to fetch from local storage: \(error)")
            #endif
            return []
        }
    }

    /// Filters transactions by type, date range, and venue
    func filterTransactions(
        userId: UUID,
        type: TransactionType? = nil,
        startDate: Date? = nil,
        endDate: Date? = nil,
        venueId: UUID? = nil
    ) -> [PointTransaction] {
        // Build predicate based on available filters
        // Note: Swift 6 predicates don't support dynamic combination well,
        // so we create specific predicates for common filter combinations

        let descriptor: FetchDescriptor<PointTransaction>

        // Create predicate based on available filters
        switch (type, startDate, endDate, venueId) {
        case (let t?, let start?, let end?, let v?):
            descriptor = FetchDescriptor<PointTransaction>(
                predicate: #Predicate { $0.userId == userId && $0.type == t && $0.timestamp >= start && $0.timestamp <= end && $0.venueId == v },
                sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
            )
        case (let t?, let start?, let end?, nil):
            descriptor = FetchDescriptor<PointTransaction>(
                predicate: #Predicate { $0.userId == userId && $0.type == t && $0.timestamp >= start && $0.timestamp <= end },
                sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
            )
        case (let t?, let start?, nil, let v?):
            descriptor = FetchDescriptor<PointTransaction>(
                predicate: #Predicate { $0.userId == userId && $0.type == t && $0.timestamp >= start && $0.venueId == v },
                sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
            )
        case (let t?, nil, let end?, let v?):
            descriptor = FetchDescriptor<PointTransaction>(
                predicate: #Predicate { $0.userId == userId && $0.type == t && $0.timestamp <= end && $0.venueId == v },
                sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
            )
        case (let t?, let start?, nil, nil):
            descriptor = FetchDescriptor<PointTransaction>(
                predicate: #Predicate { $0.userId == userId && $0.type == t && $0.timestamp >= start },
                sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
            )
        case (let t?, nil, let end?, nil):
            descriptor = FetchDescriptor<PointTransaction>(
                predicate: #Predicate { $0.userId == userId && $0.type == t && $0.timestamp <= end },
                sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
            )
        case (let t?, nil, nil, let v?):
            descriptor = FetchDescriptor<PointTransaction>(
                predicate: #Predicate { $0.userId == userId && $0.type == t && $0.venueId == v },
                sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
            )
        case (let t?, nil, nil, nil):
            descriptor = FetchDescriptor<PointTransaction>(
                predicate: #Predicate { $0.userId == userId && $0.type == t },
                sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
            )
        case (nil, let start?, let end?, let v?):
            descriptor = FetchDescriptor<PointTransaction>(
                predicate: #Predicate { $0.userId == userId && $0.timestamp >= start && $0.timestamp <= end && $0.venueId == v },
                sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
            )
        case (nil, let start?, let end?, nil):
            descriptor = FetchDescriptor<PointTransaction>(
                predicate: #Predicate { $0.userId == userId && $0.timestamp >= start && $0.timestamp <= end },
                sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
            )
        case (nil, let start?, nil, let v?):
            descriptor = FetchDescriptor<PointTransaction>(
                predicate: #Predicate { $0.userId == userId && $0.timestamp >= start && $0.venueId == v },
                sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
            )
        case (nil, nil, let end?, let v?):
            descriptor = FetchDescriptor<PointTransaction>(
                predicate: #Predicate { $0.userId == userId && $0.timestamp <= end && $0.venueId == v },
                sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
            )
        case (nil, let start?, nil, nil):
            descriptor = FetchDescriptor<PointTransaction>(
                predicate: #Predicate { $0.userId == userId && $0.timestamp >= start },
                sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
            )
        case (nil, nil, let end?, nil):
            descriptor = FetchDescriptor<PointTransaction>(
                predicate: #Predicate { $0.userId == userId && $0.timestamp <= end },
                sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
            )
        case (nil, nil, nil, let v?):
            descriptor = FetchDescriptor<PointTransaction>(
                predicate: #Predicate { $0.userId == userId && $0.venueId == v },
                sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
            )
        case (nil, nil, nil, nil):
            descriptor = FetchDescriptor<PointTransaction>(
                predicate: #Predicate { $0.userId == userId },
                sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
            )
        }

        do {
            let transactions = try modelContext.fetch(descriptor)
            #if DEBUG
            print("🔍 [TransactionService] Filtered \(transactions.count) transactions")
            if let type = type { print("   Type: \(type.rawValue)") }
            if let venueId = venueId { print("   Venue: \(venueId)") }
            if let startDate = startDate { print("   From: \(startDate)") }
            if let endDate = endDate { print("   To: \(endDate)") }
            #endif
            return transactions
        } catch {
            #if DEBUG
            print("❌ [TransactionService] Failed to filter transactions: \(error)")
            #endif
            return []
        }
    }

    /// Gets total count of transactions for pagination
    func getTotalTransactionCount(userId: UUID) -> Int {
        let descriptor = FetchDescriptor<PointTransaction>(
            predicate: #Predicate { $0.userId == userId }
        )

        do {
            let count = try modelContext.fetchCount(descriptor)
            return count
        } catch {
            #if DEBUG
            print("❌ [TransactionService] Failed to count transactions: \(error)")
            #endif
            return 0
        }
    }

    // MARK: - Private Helpers

    /// Updates local SwiftData storage with fetched transactions
    private func updateLocalStorage(transactions: [PointTransaction], userId: UUID) async throws {
        // Get existing transaction IDs from local storage
        let existingDescriptor = FetchDescriptor<PointTransaction>(
            predicate: #Predicate { $0.userId == userId }
        )

        let existingTransactions = try modelContext.fetch(existingDescriptor)
        let existingIds = Set(existingTransactions.map { $0.id })

        // Insert new transactions only
        var insertedCount = 0
        for transaction in transactions {
            if !existingIds.contains(transaction.id) {
                modelContext.insert(transaction)
                insertedCount += 1
            }
        }

        // Save changes
        try modelContext.save()

        #if DEBUG
        print("💾 [TransactionService] Inserted \(insertedCount) new transactions")
        #endif
    }

    // MARK: - DTO Conversion

    /// Converts backend DTO to SwiftData model
    private func convertDTOToModel(_ dto: TransactionDTO) -> PointTransaction {
        // Map backend type to app type
        let type: TransactionType
        switch dto.type.lowercased() {
        case "earn": type = .earn
        case "redeem": type = .redeem
        case "bonus": type = .bonus
        case "refund": type = .refund
        default: type = .earn
        }

        // Map backend source to app source
        let source: TransactionSource
        switch dto.source.lowercased() {
        case "checkin", "check-in": source = .checkIn
        case "reward", "rewardredemption": source = .rewardRedemption
        case "streakbonus": source = .streakBonus
        case "eventbonus": source = .eventBonus
        case "referralbonus": source = .referralBonus
        case "promotionalbonus", "promotion": source = .promotionalBonus
        case "refund": source = .refund
        default: source = .checkIn
        }

        // Get venue name from metadata or use default
        let venueName = dto.metadata?["venueName"] as? String ?? "Unknown Venue"

        // Generate description
        let description = generateDescription(type: type, source: source, venueName: venueName)

        return PointTransaction(
            id: dto.id,
            userId: dto.userId,
            venueId: dto.venueId,
            venueName: venueName,
            type: type,
            source: source,
            amount: dto.amount,
            transactionDescription: description,
            balanceBefore: dto.balanceBefore,
            balanceAfter: dto.balanceAfter,
            checkInId: dto.checkInId,
            rewardId: dto.metadata?["rewardId"] as? UUID,
            eventId: dto.metadata?["eventId"] as? UUID,
            timestamp: dto.createdAt,
            createdAt: dto.createdAt
        )
    }

    /// Converts SwiftData model to backend DTO
    private func convertModelToDTO(_ transaction: PointTransaction) -> TransactionDTO {
        var metadata: [String: Any] = [
            "venueName": transaction.venueName
        ]

        if let rewardId = transaction.rewardId {
            metadata["rewardId"] = rewardId.uuidString
        }

        if let eventId = transaction.eventId {
            metadata["eventId"] = eventId.uuidString
        }

        return TransactionDTO(
            id: transaction.id,
            userId: transaction.userId,
            venueId: transaction.venueId,
            amount: transaction.amount,
            type: transaction.type.rawValue.lowercased(),
            source: transaction.source.rawValue.replacingOccurrences(of: " ", with: "").lowercased(),
            balanceBefore: transaction.balanceBefore,
            balanceAfter: transaction.balanceAfter,
            createdAt: transaction.createdAt,
            checkInId: transaction.checkInId,
            metadata: metadata
        )
    }

    /// Generates transaction description based on type and source
    private func generateDescription(type: TransactionType, source: TransactionSource, venueName: String) -> String {
        switch source {
        case .checkIn:
            return "Check-in at \(venueName)"
        case .rewardRedemption:
            return "Redeemed reward at \(venueName)"
        case .streakBonus:
            return "Streak bonus"
        case .eventBonus:
            return "Event bonus at \(venueName)"
        case .referralBonus:
            return "Referral bonus"
        case .promotionalBonus:
            return "Promotional bonus"
        case .refund:
            return "Refund at \(venueName)"
        }
    }
}

// MARK: - DTOs

/// Backend transaction response structure
struct TransactionDTO: Codable {
    let id: UUID
    let userId: UUID
    let venueId: UUID
    let amount: Int
    let type: String
    let source: String
    let balanceBefore: Int
    let balanceAfter: Int
    let createdAt: Date
    let checkInId: UUID?
    let metadata: [String: Any]?

    enum CodingKeys: String, CodingKey {
        case id, userId, venueId, amount, type, source
        case balanceBefore, balanceAfter, createdAt, checkInId, metadata
    }

    init(
        id: UUID,
        userId: UUID,
        venueId: UUID,
        amount: Int,
        type: String,
        source: String,
        balanceBefore: Int,
        balanceAfter: Int,
        createdAt: Date,
        checkInId: UUID? = nil,
        metadata: [String: Any]? = nil
    ) {
        self.id = id
        self.userId = userId
        self.venueId = venueId
        self.amount = amount
        self.type = type
        self.source = source
        self.balanceBefore = balanceBefore
        self.balanceAfter = balanceAfter
        self.createdAt = createdAt
        self.checkInId = checkInId
        self.metadata = metadata
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        userId = try container.decode(UUID.self, forKey: .userId)
        venueId = try container.decode(UUID.self, forKey: .venueId)
        amount = try container.decode(Int.self, forKey: .amount)
        type = try container.decode(String.self, forKey: .type)
        source = try container.decode(String.self, forKey: .source)
        balanceBefore = try container.decode(Int.self, forKey: .balanceBefore)
        balanceAfter = try container.decode(Int.self, forKey: .balanceAfter)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        checkInId = try container.decodeIfPresent(UUID.self, forKey: .checkInId)

        // Decode metadata as dictionary
        if let metadataDict = try? container.decode([String: AnyCodable].self, forKey: .metadata) {
            metadata = metadataDict.mapValues { $0.value }
        } else {
            metadata = nil
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(userId, forKey: .userId)
        try container.encode(venueId, forKey: .venueId)
        try container.encode(amount, forKey: .amount)
        try container.encode(type, forKey: .type)
        try container.encode(source, forKey: .source)
        try container.encode(balanceBefore, forKey: .balanceBefore)
        try container.encode(balanceAfter, forKey: .balanceAfter)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encodeIfPresent(checkInId, forKey: .checkInId)

        // Encode metadata
        if let metadata = metadata {
            let encodableMetadata = metadata.mapValues { AnyCodable($0) }
            try container.encode(encodableMetadata, forKey: .metadata)
        }
    }
}

/// Pagination metadata from backend
struct PaginationMetadata: Codable {
    let page: Int
    let limit: Int
    let total: Int
}

/// Transaction list response with pagination
struct TransactionListResponse: Codable {
    let transactions: [TransactionDTO]
    let pagination: PaginationMetadata
}

/// Helper for encoding/decoding Any values
struct AnyCodable: Codable {
    let value: Any

    init(_ value: Any) {
        self.value = value
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let intValue = try? container.decode(Int.self) {
            value = intValue
        } else if let doubleValue = try? container.decode(Double.self) {
            value = doubleValue
        } else if let stringValue = try? container.decode(String.self) {
            value = stringValue
        } else if let boolValue = try? container.decode(Bool.self) {
            value = boolValue
        } else if let arrayValue = try? container.decode([AnyCodable].self) {
            value = arrayValue.map { $0.value }
        } else if let dictValue = try? container.decode([String: AnyCodable].self) {
            value = dictValue.mapValues { $0.value }
        } else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Unsupported type"
            )
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch value {
        case let intValue as Int:
            try container.encode(intValue)
        case let doubleValue as Double:
            try container.encode(doubleValue)
        case let stringValue as String:
            try container.encode(stringValue)
        case let boolValue as Bool:
            try container.encode(boolValue)
        case let arrayValue as [Any]:
            try container.encode(arrayValue.map { AnyCodable($0) })
        case let dictValue as [String: Any]:
            try container.encode(dictValue.mapValues { AnyCodable($0) })
        default:
            throw EncodingError.invalidValue(
                value,
                EncodingError.Context(
                    codingPath: container.codingPath,
                    debugDescription: "Unsupported type"
                )
            )
        }
    }
}
